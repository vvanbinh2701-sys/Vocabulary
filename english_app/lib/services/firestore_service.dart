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

  /// Đánh dấu một bài ngữ pháp là đã hoàn thành trong Firestore
  Future<void> markGrammarLessonCompleted(String lessonId) async {
    await _db.collection('grammar_lessons').doc(lessonId).update({
      'isCompleted': true,
    });
  }

  /// Cập nhật trạng thái thuộc từ vựng (Mới / Đã thuộc) lên Firestore
  Future<void> updateVocabularyMastery(String wordId, String masteryLevel) async {
    await _db.collection('vocabularies').doc(wordId).update({
      'masteryLevel': masteryLevel,
    });
  }

  /// Cập nhật trạng thái thuộc dòng hội thoại (Mới / Đã thuộc) lên Firestore
  Future<void> updateConversationMastery(String lineId, String masteryLevel) async {
    await _db.collection('conversation_lines').doc(lineId).update({
      'masteryLevel': masteryLevel,
    });
  }

  /// Xóa toàn bộ collection conversations cũ (đã migrate sang conversation_lines)
  Future<void> deleteOldConversations() async {
    final snapshot = await _db.collection('conversations').get();
    if (snapshot.docs.isEmpty) return;

    const chunkSize = 400;
    for (int i = 0; i < snapshot.docs.length; i += chunkSize) {
      final batch = _db.batch();
      final chunk = snapshot.docs.sublist(
          i, i + chunkSize > snapshot.docs.length ? snapshot.docs.length : i + chunkSize);
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
      final chunk = ops.sublist(i, i + chunkSize > ops.length ? ops.length : i + chunkSize);
      final batch = _db.batch();
      for (final op in chunk) {
        await op(batch);
      }
      await batch.commit();
    }
  }
}
