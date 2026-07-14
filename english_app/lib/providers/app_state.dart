import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Quản lý trạng thái chung: user, streak, tiến độ, danh sách yêu thích.
class AppState extends ChangeNotifier {
  AppState({AuthService? authService, FirestoreService? firestoreService})
      : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService() {
    _authSub = _authService.authStateChanges.listen((user) {
      final wasLoggedIn = isLoggedIn;
      _setFirebaseUser(user);
      if (user != null && !wasLoggedIn) loadDataFromFirestore();
    });
    _setFirebaseUser(_authService.currentUser);
    loadDataFromFirestore();
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  late final StreamSubscription<User?> _authSub;

  // ----- User & Auth -----
  String? userName;
  String? userEmail;
  String? _userId;
  String? get uid => _userId;
  bool get isLoggedIn => userEmail != null;
  bool authReady = false;

  void _setFirebaseUser(User? user) {
    _userId = user?.uid;
    userEmail = user?.email;
    userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName
        : user?.email?.split('@').first;
    authReady = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> register(String name, String email, String password) async {
    await _authService.register(name: name, email: email, password: password);
  }

  Future<void> updateUserName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _authService.updateDisplayName(trimmed);
    userName = trimmed;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  // ----- Firestore Integration -----
  bool isLoadingData = false;
  List<Topic> _firestoreTopics = [];
  List<ConversationLine> conversationLines = [];

  Future<void> loadDataFromFirestore() async {
    isLoadingData = true;
    notifyListeners();
    try {
      final topics = await _firestoreService.getTopics();
      _firestoreTopics = topics;

      // Load base vocab + grammar + conversation
      final vocab = await _firestoreService.getVocabularies();
      sampleVocab = vocab;

      final grammar = await _firestoreService.getGrammarLessons();
      grammarLessons = grammar;

      final allLines = <ConversationLine>[];
      for (var t in _firestoreTopics
          .where((topic) => topic.categoryId == 'conversation')) {
        final lines = await _firestoreService.getConversationLines(t.id);
        allLines.addAll(lines);
      }
      conversationLines = allLines;

      // Load user-specific progress & favorites
      await _loadUserData();
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu từ Firestore: $e');
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
  }

  /// Load user-specific progress & favorites, áp dụng lên dữ liệu gốc
  Future<void> _loadUserData() async {
    final userId = uid;
    if (userId == null) {
      debugPrint('⚠ _loadUserData: userId is null');
      return;
    }

    try {
      // Load toàn bộ dữ liệu user trong 1 lần đọc
      final userData = await _firestoreService.getUserData(userId);

      // Load favorites
      favoriteWordIds.clear();
      final favMap = userData['favoriteWordIds'] as Map<String, dynamic>? ?? {};
      for (final entry in favMap.entries) {
        if (entry.value == true) favoriteWordIds.add(entry.key);
      }
      debugPrint('✅ Loaded ${favoriteWordIds.length} favorites for user $userId');

      // Load progress (masteryLevel, grammar completed)
      final wordProg = userData['wordProgress'] as Map<String, dynamic>? ?? {};
      final grammarProg = userData['grammarProgress'] as Map<String, dynamic>? ?? {};
      final convProg = userData['convProgress'] as Map<String, dynamic>? ?? {};

      // Áp dụng masteryLevel lên sampleVocab
      if (sampleVocab.isNotEmpty) {
        sampleVocab = sampleVocab.map((v) {
          final level = wordProg[v.id];
          if (level == null || level == '') return v;
          return Vocabulary(
            id: v.id,
            word: v.word,
            meaning: v.meaning,
            pronunciation: v.pronunciation,
            example: v.example,
            exampleVi: v.exampleVi,
            category: v.category,
            topicId: v.topicId,
            masteryLevel: level as String,
            imageUrl: v.imageUrl,
          );
        }).toList();
      }

      // Áp dụng isCompleted lên grammarLessons
      if (grammarLessons.isNotEmpty) {
        grammarLessons = grammarLessons.map((g) {
          final completed = grammarProg[g.id];
          if (completed != true) return g;
          return g.copyWith(isCompleted: true);
        }).toList();
      }

      // Áp dụng masteryLevel lên conversationLines
      if (conversationLines.isNotEmpty) {
        conversationLines = conversationLines.map((c) {
          final level = convProg[c.id];
          if (level == null || level == '') return c;
          return ConversationLine(
            id: c.id,
            topicId: c.topicId,
            speaker: c.speaker,
            english: c.english,
            vietnamese: c.vietnamese,
            masteryLevel: level as String,
          );
        }).toList();
      }

      // Load daily goals
      final dailyGoals = userData['dailyGoals'] as Map<String, dynamic>?;
      if (dailyGoals != null) {
        final savedDate = dailyGoals['date'] as String? ?? '';
        final today = DateTime.now().toIso8601String().substring(0, 10);
        if (savedDate == today) {
          // Cùng ngày → khôi phục số liệu
          _dailyGoalDate = savedDate;
          wordsStudiedToday = dailyGoals['wordsStudied'] as int? ?? 0;
          grammarDoneToday = dailyGoals['grammarDone'] as int? ?? 0;
          practiceSessionsToday = dailyGoals['practiceSessions'] as int? ?? 0;
        }
        // Khác ngày → để mặc định 0, _resetDailyIfNeeded sẽ xử lý
      }

      // Tính lại % tiến độ
      _recalculateAllProgress();
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu user: $e');
    }
  }

  /// Tính lại % tiến độ cho tất cả categories
  void _recalculateAllProgress() {
    // Vocab
    if (sampleVocab.isNotEmpty) {
      final mastered = sampleVocab.where((v) => v.masteryLevel == 'Đã thuộc').length;
      progressByCategory['vocab'] = mastered / sampleVocab.length;
    }
    // Grammar
    if (grammarLessons.isNotEmpty) {
      final completed = grammarLessons.where((g) => g.isCompleted).length;
      progressByCategory['grammar'] = completed / grammarLessons.length;
    }
    // Conversation
    final convTotal = conversationLines.length;
    if (convTotal > 0) {
      final mastered = conversationLines.where((c) => c.masteryLevel == 'Đã thuộc').length;
      progressByCategory['conversation'] = mastered / convTotal;
    }
    // Phrase (dùng chung sampleVocab với category='phrase')
    final phraseWords = sampleVocab.where((v) => v.category == 'phrase').toList();
    if (phraseWords.isNotEmpty) {
      final mastered = phraseWords.where((v) => v.masteryLevel == 'Đã thuộc').length;
      progressByCategory['phrase'] = mastered / phraseWords.length;
    }
  }

  /// Hàm tiện ích giúp đẩy toàn bộ dữ liệu mẫu từ file JSON lên Firestore
  Future<void> seedInitialData() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/firebase_seed/firestore_data.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // Parsing topics
      final List<Topic> seedTopics = (data['topics'] as List)
          .map((t) => Topic.fromMap(Map<String, dynamic>.from(t), t['id']))
          .toList();

      // Parsing vocabularies
      final List<Vocabulary> seedVocabs = (data['vocabularies'] as List)
          .map((v) => Vocabulary.fromMap(Map<String, dynamic>.from(v), v['id']))
          .toList();

      // Parsing grammar lessons
      final List<GrammarLesson> seedGrammars = (data['grammar_lessons'] as List)
          .map((g) =>
              GrammarLesson.fromMap(Map<String, dynamic>.from(g), g['id']))
          .toList();

      // Parsing conversation lines (collection mới)
      final List<ConversationLine> seedConvLines = (data['conversation_lines']
              as List)
          .map((c) =>
              ConversationLine.fromMap(Map<String, dynamic>.from(c), c['id']))
          .toList();

      await _firestoreService.seedData(
        topics: seedTopics,
        vocabularies: seedVocabs,
        grammarLessons: seedGrammars,
        conversationLines: seedConvLines,
      );
      // Xóa collection conversations cũ sau khi migrate
      await _firestoreService.deleteOldConversations();
      await loadDataFromFirestore();
    } catch (e) {
      debugPrint('Lỗi seed data lên Firestore: $e');
    }
  }

  // ----- Streak -----
  int currentStreak = 0;
  int longestStreak = 0;

  // ----- Daily Goals -----
  String _dailyGoalDate = '';
  int wordsStudiedToday = 0;
  int grammarDoneToday = 0;
  int practiceSessionsToday = 0;

  void _resetDailyIfNeeded() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_dailyGoalDate != today) {
      _dailyGoalDate = today;
      wordsStudiedToday = 0;
      grammarDoneToday = 0;
      practiceSessionsToday = 0;
    }
  }

  void _saveDailyGoals() {
    final userId = uid;
    if (userId == null) return;
    _firestoreService.saveDailyGoals(
      userId, _dailyGoalDate, wordsStudiedToday, grammarDoneToday, practiceSessionsToday,
    );
  }

  /// Gọi khi người dùng học một từ (vào flashcard, quiz, practice...)
  void trackWordStudied() {
    _resetDailyIfNeeded();
    wordsStudiedToday++;
    _saveDailyGoals();
    notifyListeners();
  }

  /// Gọi khi người dùng hoàn thành 1 bài ngữ pháp
  void trackGrammarDone() {
    _resetDailyIfNeeded();
    grammarDoneToday++;
    _saveDailyGoals();
    notifyListeners();
  }

  /// Gọi khi người dùng mở 1 buổi luyện tập
  void trackPracticeSession() {
    _resetDailyIfNeeded();
    practiceSessionsToday++;
    _saveDailyGoals();
    notifyListeners();
  }

  // ----- Progress (theo categoryId -> % hoàn thành) -----
  final Map<String, double> progressByCategory = {
    'vocab': 0.0,
    'grammar': 0.0,
    'conversation': 0.0,
    'phrase': 0.0,
  };

  final List<HistoryItem> history = [];

  void updateProgress(String categoryId, double percent) {
    progressByCategory[categoryId] = percent;
    currentStreak += 1;
    notifyListeners();
  }

  /// Đánh dấu một bài ngữ pháp là đã hoàn thành.
  /// Cập nhật local state ngay lập tức để UI phản hồi tức thì,
  /// sau đó đồng bộ lên Firestore nền.
  Future<void> markGrammarCompleted(String lessonId) async {
    final idx = grammarLessons.indexWhere((l) => l.id == lessonId);
    if (idx == -1 || grammarLessons[idx].isCompleted) return;
    trackGrammarDone();

    // Cập nhật local list ngay
    grammarLessons = List.of(grammarLessons)
      ..[idx] = grammarLessons[idx].copyWith(isCompleted: true);

    // Cập nhật % tiến độ grammar
    final completed = grammarLessons.where((l) => l.isCompleted).length;
    final total = grammarLessons.length;
    if (total > 0) progressByCategory['grammar'] = completed / total;

    notifyListeners();

    // Đồng bộ lên Firestore nền (theo user)
    try {
      final userId = uid;
      if (userId != null) {
        await _firestoreService.updateUserGrammarCompleted(userId, lessonId, true);
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật Firestore: $e');
    }
  }

  // ----- Favorites (theo user) -----
  final Set<String> favoriteWordIds = {};

  Future<void> toggleFavorite(String wordId) async {
    final userId = uid;
    if (userId == null) return;

    if (favoriteWordIds.contains(wordId)) {
      favoriteWordIds.remove(wordId);
      try {
        await _firestoreService.removeFavorite(userId, wordId);
      } catch (e) {
        debugPrint('Lỗi xóa favorite: $e');
      }
    } else {
      favoriteWordIds.add(wordId);
      try {
        await _firestoreService.addFavorite(userId, wordId);
      } catch (e) {
        debugPrint('Lỗi thêm favorite: $e');
      }
    }
    notifyListeners();
  }

  bool isFavorite(String wordId) => favoriteWordIds.contains(wordId);

  // ----- Toggle trạng thái thuộc từ vựng (Mới ↔ Đã thuộc) -----
  Future<void> toggleWordMastered(String wordId) async {
    final idx = sampleVocab.indexWhere((v) => v.id == wordId);
    if (idx == -1) return;
    trackWordStudied();

    final current = sampleVocab[idx];
    final newLevel = current.masteryLevel == 'Đã thuộc' ? 'Mới' : 'Đã thuộc';

    sampleVocab = List.of(sampleVocab)
      ..[idx] = Vocabulary(
        id: current.id,
        word: current.word,
        meaning: current.meaning,
        pronunciation: current.pronunciation,
        example: current.example,
        exampleVi: current.exampleVi,
        category: current.category,
        topicId: current.topicId,
        masteryLevel: newLevel,
        imageUrl: current.imageUrl,
      );

    // Cập nhật % tiến độ cho category 'vocab'
    _updateVocabProgress();

    notifyListeners();

    // Đồng bộ lên Firestore nền (theo user)
    try {
      final userId = uid;
      if (userId != null) {
        await _firestoreService.updateUserWordMastery(userId, wordId, newLevel);
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật mastery từ vựng: $e');
    }
  }

  void _updateVocabProgress() {
    if (sampleVocab.isEmpty) return;
    final mastered =
        sampleVocab.where((v) => v.masteryLevel == 'Đã thuộc').length;
    progressByCategory['vocab'] = mastered / sampleVocab.length;
  }

  // ----- Toggle trạng thái thuộc dòng hội thoại (Mới ↔ Đã thuộc) -----
  Future<void> toggleConversationMastered(String lineId) async {
    final idx = conversationLines.indexWhere((l) => l.id == lineId);
    if (idx == -1) return;

    final current = conversationLines[idx];
    final newLevel = current.masteryLevel == 'Đã thuộc' ? 'Mới' : 'Đã thuộc';

    conversationLines = List.of(conversationLines)
      ..[idx] = ConversationLine(
        id: current.id,
        topicId: current.topicId,
        speaker: current.speaker,
        english: current.english,
        vietnamese: current.vietnamese,
        masteryLevel: newLevel,
      );

    notifyListeners();

    // Đồng bộ lên Firestore nền (theo user)
    try {
      final userId = uid;
      if (userId != null) {
        await _firestoreService.updateUserConvMastery(userId, lineId, newLevel);
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật mastery hội thoại: $e');
    }
  }

  /// Trả về % hoàn thành của một chủ đề (dùng chung cho vocab + conversation + phrase)
  double topicProgress(String topicId) {
    // Kiểm tra trong vocab trước
    final words = vocabByTopic(topicId);
    if (words.isNotEmpty) {
      final mastered = words.where((v) => v.masteryLevel == 'Đã thuộc').length;
      return mastered / words.length;
    }
    // Kiểm tra trong conversation
    final lines = conversationByTopic(topicId);
    if (lines.isNotEmpty) {
      final mastered = lines.where((l) => l.masteryLevel == 'Đã thuộc').length;
      return mastered / lines.length;
    }
    return 0.0;
  }

  // ----- Dữ liệu chính động -----
  List<Vocabulary> sampleVocab = [];
  List<GrammarLesson> grammarLessons = [];

  List<Vocabulary> vocabByTopic(String topicId) =>
      sampleVocab.where((v) => v.topicId == topicId).toList();

  List<ConversationLine> conversationByTopic(String topicId) {
    return conversationLines.where((l) => l.topicId == topicId).toList();
  }

  List<Topic> topicsOf(String categoryId) {
    return _firestoreTopics.where((t) => t.categoryId == categoryId).toList();
  }
}
