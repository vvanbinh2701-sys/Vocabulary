import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Lấy danh sách các chủ đề (Topics) từ Firestore
  Future<List<Topic>> getTopics() async {
    final snapshot = await _db.collection('topics').get();
    return snapshot.docs
        .map((doc) => Topic.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Lấy danh sách từ vựng từ Firestore
  Future<List<Vocabulary>> getVocabularies() async {
    final snapshot = await _db.collection('vocabularies').get();
    return snapshot.docs
        .map((doc) => Vocabulary.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Lấy danh sách bài học ngữ pháp từ Firestore
  Future<List<GrammarLesson>> getGrammarLessons() async {
    final snapshot = await _db.collection('grammar_lessons').get();
    return snapshot.docs
        .map((doc) => GrammarLesson.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Lấy dòng hội thoại của một topicId từ Firestore (collection mới: conversation_lines)
  Future<List<ConversationLine>> getConversationLines(String topicId) async {
    final snapshot = await _db
        .collection('conversation_lines')
        .where('topicId', isEqualTo: topicId)
        .get();
    return snapshot.docs
        .map((doc) => ConversationLine.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ================================================================
  //  USER-SPECIFIC DATA (lưu trong 1 document users/{uid})
  // ================================================================

  /// Đọc toàn bộ dữ liệu user: favorites + progress
  Future<Map<String, dynamic>> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return {};
    return doc.data() as Map<String, dynamic>;
  }

  /// Lưu masteryLevel của 1 từ vựng theo user
  Future<void> updateUserWordMastery(String uid, String wordId, String level) async {
    await _db.collection('users').doc(uid).set(
      {'wordProgress': {wordId: level}},
      SetOptions(merge: true),
    );
  }

  /// Lưu trạng thái hoàn thành bài ngữ pháp theo user
  Future<void> updateUserGrammarCompleted(String uid, String lessonId, bool completed) async {
    await _db.collection('users').doc(uid).set(
      {'grammarProgress': {lessonId: completed}},
      SetOptions(merge: true),
    );
  }

  /// Lưu masteryLevel của dòng hội thoại theo user
  Future<void> updateUserConvMastery(String uid, String lineId, String level) async {
    await _db.collection('users').doc(uid).set(
      {'convProgress': {lineId: level}},
      SetOptions(merge: true),
    );
  }

  // ----- Favorites (lưu trong users/{uid}/favoriteWordIds) -----

  /// Thêm từ vào danh sách yêu thích
  Future<void> addFavorite(String uid, String wordId) async {
    await _db.collection('users').doc(uid).set(
      {'favoriteWordIds': {wordId: true}},
      SetOptions(merge: true),
    );
  }

  /// Xóa từ khỏi danh sách yêu thích
  Future<void> removeFavorite(String uid, String wordId) async {
    await _db.collection('users').doc(uid).set(
      {'favoriteWordIds': {wordId: false}},
      SetOptions(merge: true),
    );
  }

  // ----- Daily Goals -----

  /// Lưu dữ liệu mục tiêu hàng ngày
  Future<void> saveDailyGoals(String uid, String date, int words, int grammar, int practice) async {
    await _db.collection('users').doc(uid).set({
      'dailyGoals': {
        'date': date,
        'wordsStudied': words,
        'grammarDone': grammar,
        'practiceSessions': practice,
      }
    }, SetOptions(merge: true));
  }

  // ----- Streak -----

  /// Lưu dữ liệu streak (chuỗi ngày học liên tục)
  Future<void> saveStreak(String uid, int currentStreak, int longestStreak, String lastActiveDate) async {
    await _db.collection('users').doc(uid).set({
      'streak': {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate': lastActiveDate,
      }
    }, SetOptions(merge: true));
  }

  // ----- User Profile (avatar, phone) -----

  /// Lưu thông tin hồ sơ người dùng (avatar, số điện thoại)
  Future<void> saveUserProfile(String uid, {String? avatarId, String? phone}) async {
    final Map<String, dynamic> data = {};
    if (avatarId != null) data['avatarId'] = avatarId;
    if (phone != null) data['phone'] = phone;
    if (data.isNotEmpty) {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    }
  }

  /// Xóa toàn bộ collection conversations cũ (đã migrate sang conversation_lines)
  Future<void> deleteOldConversations() async {
    final snapshot = await _db.collection('conversations').get();
    if (snapshot.docs.isEmpty) return;

    const chunkSize = 400;
    for (int i = 0; i < snapshot.docs.length; i += chunkSize) {
      final batch = _db.batch();
      final chunk = snapshot.docs.sublist(
          i,
          i + chunkSize > snapshot.docs.length
              ? snapshot.docs.length
              : i + chunkSize);
      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Hàm Seeder: Hỗ trợ đẩy dữ liệu lên Firestore
  /// Tự động chia nhỏ batch để tránh giới hạn 500 operations/batch của Firestore
  Future<void> seedData({
    required List<Topic> topics,
    required List<Vocabulary> vocabularies,
    required List<GrammarLesson> grammarLessons,
    required List<ConversationLine> conversationLines,
  }) async {
    // Gom toàn bộ thao tác vào một danh sách
    final List<Future<void> Function(WriteBatch)> ops = [];

    for (var topic in topics) {
      final docRef = _db.collection('topics').doc(topic.id);
      ops.add((batch) async => batch.set(docRef, topic.toMap()));
    }

    for (var vocab in vocabularies) {
      final docRef = _db.collection('vocabularies').doc(vocab.id);
      ops.add((batch) async => batch.set(docRef, vocab.toMap()));
    }

    for (var lesson in grammarLessons) {
      final docRef = _db.collection('grammar_lessons').doc(lesson.id);
      ops.add((batch) async => batch.set(docRef, lesson.toMap()));
    }

    for (var line in conversationLines) {
      final docRef = _db.collection('conversation_lines').doc(line.id);
      ops.add((batch) async => batch.set(docRef, line.toMap()));
    }

    // Commit từng batch tối đa 400 thao tác
    const chunkSize = 400;
    for (int i = 0; i < ops.length; i += chunkSize) {
      final chunk = ops.sublist(
          i, i + chunkSize > ops.length ? ops.length : i + chunkSize);
      final batch = _db.batch();
      for (final op in chunk) {
        await op(batch);
      }
      await batch.commit();
    }
  }
}
