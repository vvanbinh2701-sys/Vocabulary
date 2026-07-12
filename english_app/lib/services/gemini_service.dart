import 'package:google_generative_ai/google_generative_ai.dart';

/// Gọi Google Gemini API để tạo hội thoại mẫu từ một từ vựng tiếng Anh.
/// Nếu API lỗi (quota, mạng...) sẽ tự động dùng fallback local.
class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  /// Tạo một đoạn hội thoại ngắn giữa 2 người, ưu tiên Gemini API,
  /// fallback về template local nếu API lỗi.
  Future<String> generateDialogue(String word) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'You are an English teaching assistant. Create a short dialogue (4-6 lines) between two people (A and B) '
          'using the given English word naturally. '
          'Format each line as: "A: [English sentence]" on one line, '
          'then "[Vietnamese translation]" on the next line. '
          'Make it natural and conversational. Do not add any other text.',
        ),
      );

      final response = await model.generateContent([
        Content.text('Create a dialogue using the word: $word'),
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!;
      }
    } catch (_) {
      // API lỗi → dùng fallback local
    }

    return _buildFallbackDialogue(word);
  }

  /// Hội thoại fallback khi API không khả dụng
  String _buildFallbackDialogue(String word) {
    return 'Không có đoạn hội thoại phù hợp';
  }
}
