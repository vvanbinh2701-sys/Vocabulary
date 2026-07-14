import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_models.dart';

/// Service CRUD cho Admin - ghi vào CÙNG collection Firestore mà User app đọc
/// → Dữ liệu đồng bộ realtime giữa Admin và User
class AdminFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════
  //  VOCABULARY CRUD
  // ═══════════════════════════════════════════════════════════════

  /// Thêm từ vựng mới
  Future<void> addVocabulary(Vocabulary vocab) async {
    final docRef = _db.collection('vocabularies').doc(vocab.id);
    await docRef.set(vocab.toMap());
  }

  /// Cập nhật từ vựng
  Future<void> updateVocabulary(Vocabulary vocab) async {
    await _db.collection('vocabularies').doc(vocab.id).update(vocab.toMap());
  }

  /// Xóa từ vựng
  Future<void> deleteVocabulary(String id) async {
    await _db.collection('vocabularies').doc(id).delete();
  }

  /// Lấy tất cả từ vựng (realtime stream)
  Stream<List<Vocabulary>> vocabulariesStream() {
    return _db.collection('vocabularies').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Vocabulary.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Lấy tất cả từ vựng (một lần)
  Future<List<Vocabulary>> getVocabularies() async {
    final snapshot = await _db.collection('vocabularies').get();
    return snapshot.docs
        .map((doc) => Vocabulary.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════
  //  TOPIC CRUD
  // ═══════════════════════════════════════════════════════════════

  /// Thêm chủ đề mới
  Future<void> addTopic(Topic topic) async {
    await _db.collection('topics').doc(topic.id).set(topic.toMap());
  }

  /// Cập nhật chủ đề
  Future<void> updateTopic(Topic topic) async {
    await _db.collection('topics').doc(topic.id).update(topic.toMap());
  }

  /// Xóa chủ đề (đồng thời xóa cả từ vựng thuộc chủ đề đó)
  Future<void> deleteTopic(String topicId) async {
    // Xóa topic
    await _db.collection('topics').doc(topicId).delete();

    // Xóa tất cả từ vựng thuộc topic này
    final vocabSnapshot = await _db
        .collection('vocabularies')
        .where('topicId', isEqualTo: topicId)
        .get();

    const chunkSize = 400;
    for (int i = 0; i < vocabSnapshot.docs.length; i += chunkSize) {
      final batch = _db.batch();
      final chunk = vocabSnapshot.docs.sublist(
        i,
        i + chunkSize > vocabSnapshot.docs.length
            ? vocabSnapshot.docs.length
            : i + chunkSize,
      );
      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Lấy tất cả chủ đề (realtime stream)
  Stream<List<Topic>> topicsStream() {
    return _db.collection('topics').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Topic.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Lấy tất cả chủ đề (một lần)
  Future<List<Topic>> getTopics() async {
    final snapshot = await _db.collection('topics').get();
    return snapshot.docs
        .map((doc) => Topic.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════
  //  GRAMMAR CRUD
  // ═══════════════════════════════════════════════════════════════

  Future<void> addGrammarLesson(GrammarLesson lesson) async {
    await _db.collection('grammar_lessons').doc(lesson.id).set(lesson.toMap());
  }

  Future<void> updateGrammarLesson(GrammarLesson lesson) async {
    await _db
        .collection('grammar_lessons')
        .doc(lesson.id)
        .update(lesson.toMap());
  }

  Future<void> deleteGrammarLesson(String id) async {
    await _db.collection('grammar_lessons').doc(id).delete();
  }

  Future<List<GrammarLesson>> getGrammarLessons() async {
    final snapshot = await _db.collection('grammar_lessons').get();
    return snapshot.docs
        .map((doc) => GrammarLesson.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ═══════════════════════════════════════════════════════════════
  //  STATS cho Dashboard
  // ═══════════════════════════════════════════════════════════════

  Future<Map<String, int>> getStats() async {
    final results = await Future.wait([
      _db.collection('vocabularies').count().get(),
      _db.collection('topics').count().get(),
      _db.collection('users').count().get(),
      _db.collection('grammar_lessons').count().get(),
    ]);

    return {
      'totalVocab': (results[0] as AggregateQuerySnapshot).count,
      'totalTopics': (results[1] as AggregateQuerySnapshot).count,
      'totalUsers': (results[2] as AggregateQuerySnapshot).count,
      'totalSessions': (results[3] as AggregateQuerySnapshot).count,
    };
  }
}
