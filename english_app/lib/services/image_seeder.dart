import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/app_models.dart';

/// Tự động tải ảnh từ Unsplash, upload lên Firebase Storage,
/// và cập nhật imageUrl vào Firestore.
class ImageSeeder {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed ảnh cho danh sách từ vựng. Trả về số lượng thành công / tổng.
  Future<String> seedImages(List<Vocabulary> words) async {
    int success = 0;
    int total = words.length;

    for (final word in words) {
      try {
        // Bỏ qua nếu đã có ảnh
        if (word.imageUrl != null && word.imageUrl!.isNotEmpty) {
          success++;
          continue;
        }

        // Tải ảnh từ Unsplash
        final query = _buildQuery(word.word);
        final imageBytes = await _downloadImage(query);
        if (imageBytes == null) continue;

        // Upload lên Firebase Storage
        final ref = _storage.ref().child('vocab_images/${word.id}.jpg');
        await ref.putData(imageBytes);
        final downloadUrl = await ref.getDownloadURL();

        // Cập nhật Firestore
        await _firestore.collection('vocabularies').doc(word.id).update({
          'imageUrl': downloadUrl,
        });

        success++;
      } catch (e) {
        // Bỏ qua từ bị lỗi, tiếp tục từ tiếp theo
      }
    }

    return '$success/$total ảnh đã tải thành công';
  }

  /// Tạo query tìm ảnh phù hợp
  String _buildQuery(String word) {
    const special = {
      'Family': 'happy+family',
      'Mother': 'mother+happy',
      'Father': 'father+happy',
      'Sibling': 'siblings+happy',
      'Grandfather': 'grandfather+elderly',
      'Rice': 'rice+food+bowl',
      'Noodle': 'noodles+food',
      'Bread': 'bread+food',
      'Cheese': 'cheese+food',
      'Travel': 'travel+adventure',
      'Airport': 'airport',
      'Passport': 'passport+travel',
      'Luggage': 'luggage+travel',
      'Hotel': 'hotel+room',
      'School': 'school+building',
      'Teacher': 'teacher+classroom',
      'Homework': 'homework+study',
      'Classmate': 'students+classroom',
      'Library': 'library+books',
      'Doctor': 'doctor+hospital',
      'Engineer': 'engineer+work',
      'Artist': 'artist+painting',
      'Pilot': 'pilot+airplane',
      'Chef': 'chef+cooking',
      'Lion': 'lion+animal',
      'Elephant': 'elephant+animal',
      'Monkey': 'monkey+animal',
      'Rabbit': 'rabbit+animal',
      'Dolphin': 'dolphin+ocean',
      'Apple': 'apple+fruit',
    };
    return special[word] ?? word.toLowerCase();
  }

  /// Tải ảnh từ Unsplash Source
  Future<Uint8List?> _downloadImage(String query) async {
    try {
      final url = Uri.parse('https://source.unsplash.com/400x400/?$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (_) {}
    return null;
  }
}
