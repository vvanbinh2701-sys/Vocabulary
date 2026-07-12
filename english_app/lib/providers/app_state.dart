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
    _authSub = _authService.authStateChanges.listen(_setFirebaseUser);
    _setFirebaseUser(_authService.currentUser);
    loadDataFromFirestore();
  }

  final AuthService _authService;
  final FirestoreService _firestoreService;
  late final StreamSubscription<User?> _authSub;

  // ----- User & Auth -----
  String? userName;
  String? userEmail;
  bool get isLoggedIn => userEmail != null;
  bool authReady = false;

  void _setFirebaseUser(User? user) {
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

      final vocab = await _firestoreService.getVocabularies();
      sampleVocab = vocab;

      final grammar = await _firestoreService.getGrammarLessons();
      grammarLessons = grammar;

      // Load tất cả dòng hội thoại từ collection conversation_lines
      final allLines = <ConversationLine>[];
      for (var t in _firestoreTopics.where((topic) => topic.categoryId == 'conversation')) {
        final lines = await _firestoreService.getConversationLines(t.id);
        allLines.addAll(lines);
      }
      conversationLines = allLines;
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu từ Firestore: $e');
    } finally {
      isLoadingData = false;
      notifyListeners();
    }
  }

  /// Hàm tiện ích giúp đẩy toàn bộ dữ liệu mẫu từ file JSON lên Firestore
  Future<void> seedInitialData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/firebase_seed/firestore_data.json');
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
          .map((g) => GrammarLesson.fromMap(Map<String, dynamic>.from(g), g['id']))
          .toList();

      // Parsing conversation lines (collection mới)
      final List<ConversationLine> seedConvLines = (data['conversation_lines'] as List)
          .map((c) => ConversationLine.fromMap(Map<String, dynamic>.from(c), c['id']))
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

    // Cập nhật local list ngay
    grammarLessons = List.of(grammarLessons)
      ..[idx] = grammarLessons[idx].copyWith(isCompleted: true);

    // Cập nhật % tiến độ grammar
    final completed = grammarLessons.where((l) => l.isCompleted).length;
    final total = grammarLessons.length;
    if (total > 0) progressByCategory['grammar'] = completed / total;

    notifyListeners();

    // Đồng bộ lên Firestore nền
    try {
      await _firestoreService.markGrammarLessonCompleted(lessonId);
    } catch (e) {
      debugPrint('Lỗi cập nhật Firestore: $e');
    }
  }

  // ----- Favorites -----
  final Set<String> favoriteWordIds = {};

  void toggleFavorite(String wordId) {
    if (favoriteWordIds.contains(wordId)) {
      favoriteWordIds.remove(wordId);
    } else {
      favoriteWordIds.add(wordId);
    }
    notifyListeners();
  }

  bool isFavorite(String wordId) => favoriteWordIds.contains(wordId);

  // ----- Toggle trạng thái thuộc từ vựng (Mới ↔ Đã thuộc) -----
  void toggleWordMastered(String wordId) {
    final idx = sampleVocab.indexWhere((v) => v.id == wordId);
    if (idx == -1) return;

    final current = sampleVocab[idx];
    final newLevel = current.masteryLevel == 'Đã thuộc' ? 'Mới' : 'Đã thuộc';

    sampleVocab = List.of(sampleVocab)
      ..[idx] = Vocabulary(
        id: current.id,
        word: current.word,
        meaning: current.meaning,
        pronunciation: current.pronunciation,
        example: current.example,
        category: current.category,
        topicId: current.topicId,
        masteryLevel: newLevel,
        imageUrl: current.imageUrl,
      );

    // Cập nhật % tiến độ cho category 'vocab'
    _updateVocabProgress();

    notifyListeners();

    // Đồng bộ lên Firestore nền
    try {
      _firestoreService.updateVocabularyMastery(wordId, newLevel);
    } catch (e) {
      debugPrint('Lỗi cập nhật mastery từ vựng: $e');
    }
  }

  void _updateVocabProgress() {
    if (sampleVocab.isEmpty) return;
    final mastered = sampleVocab.where((v) => v.masteryLevel == 'Đã thuộc').length;
    progressByCategory['vocab'] = mastered / sampleVocab.length;
  }

  // ----- Toggle trạng thái thuộc dòng hội thoại (Mới ↔ Đã thuộc) -----
  void toggleConversationMastered(String lineId) {
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

    // Đồng bộ lên Firestore nền
    try {
      _firestoreService.updateConversationMastery(lineId, newLevel);
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
