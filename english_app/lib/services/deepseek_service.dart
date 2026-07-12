import 'dart:convert';
import 'package:http/http.dart' as http;

/// Gọi DeepSeek API để tạo hội thoại mẫu từ một từ vựng tiếng Anh.
/// Nếu API lỗi sẽ tự động dùng fallback local.
class DeepSeekService {
  final String apiKey;

  DeepSeekService({required this.apiKey});

  /// Tạo một đoạn hội thoại ngắn giữa 2 người, ưu tiên DeepSeek API,
  /// fallback về template local nếu API lỗi.
  Future<String> generateDialogue(String word) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.deepseek.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an English teaching assistant. Create a short dialogue (4-6 lines) '
                  'between two people (A and B) using the given English word naturally. '
                  'Format each line as: "A: [English sentence]" on one line, '
                  'then "[Vietnamese translation]" on the next line. '
                  'Make it natural and conversational. Do not add any other text.'
            },
            {
              'role': 'user',
              'content': 'Create a dialogue using the word: $word'
            }
          ],
          'max_tokens': 500,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'] as String?;
        if (text != null && text.isNotEmpty) return text;
      }
    } catch (_) {
      // API lỗi → dùng fallback
    }

    return _buildFallbackDialogue(word);
  }

  String _buildFallbackDialogue(String word) {
    return 'A: Have you heard about "$word" before?\n'
        'Bạn đã từng nghe về "$word" chưa?\n'
        'B: Yes! I use "$word" quite often in my daily life.\n'
        'Có chứ! Tôi dùng "$word" khá thường xuyên trong cuộc sống.\n'
        'A: Can you give me an example with "$word"?\n'
        'Bạn có thể cho tôi một ví dụ với "$word" không?\n'
        'B: Sure! "I really like $word because it is very useful."\n'
        'Tất nhiên! "Tôi rất thích $word vì nó rất hữu ích."\n'
        'A: That makes sense. I will try to use "$word" more often.\n'
        'Điều đó hợp lý đấy. Tôi sẽ cố dùng "$word" thường xuyên hơn.\n'
        'B: Great! Practice makes perfect.\n'
        'Tuyệt! Luyện tập sẽ giúp bạn hoàn thiện hơn.';
  }
}

