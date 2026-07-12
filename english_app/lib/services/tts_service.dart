import 'package:flutter_tts/flutter_tts.dart';

/// Dịch vụ đọc văn bản tiếng Anh thành tiếng nói (Text-to-Speech).
/// Dùng engine TTS có sẵn trên thiết bị → miễn phí, offline.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42); // chậm vừa, dễ nghe cho người học
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  /// Đọc một câu tiếng Anh.
  /// [text] là câu cần đọc (chỉ đọc tiếng Anh, bỏ qua tiếng Việt).
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _ensureInit();
    await _tts.speak(text.trim());
  }

  /// Dừng đọc ngay lập tức.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Đọc chậm hơn (dành cho từ đơn).
  Future<void> speakWord(String word) async {
    if (word.trim().isEmpty) return;
    await _ensureInit();
    await _tts.setSpeechRate(0.35);
    await _tts.speak(word.trim());
    // Reset lại tốc độ sau khi đọc
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(0.42);
  }

  void dispose() {
    _tts.stop();
  }
}
