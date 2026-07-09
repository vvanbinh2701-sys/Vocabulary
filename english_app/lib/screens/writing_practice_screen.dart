import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

/// Luyện viết: hiển thị nghĩa tiếng Việt, người dùng gõ lại từ tiếng Anh.
class WritingPracticeScreen extends StatefulWidget {
  final List<Vocabulary> words;
  const WritingPracticeScreen({super.key, required this.words});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  final _ctrl = TextEditingController();
  int _index = 0;
  int _correctCount = 0;
  bool _checked = false;
  bool _isCorrect = false;

  void _check() {
    final word = widget.words[_index];
    final answer = _ctrl.text.trim().toLowerCase();
    setState(() {
      _checked = true;
      _isCorrect = answer == word.word.toLowerCase();
      if (_isCorrect) _correctCount++;
    });
  }

  void _next() {
    setState(() {
      _index++;
      _checked = false;
      _isCorrect = false;
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.words;

    if (_index >= words.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Luyện viết')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✍️', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Bạn viết đúng $_correctCount / ${words.length} từ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 32),
                DuoButton(
                  label: 'LUYỆN LẠI',
                  color: AppColors.blue,
                  shadowColor: AppColors.darkBlue,
                  onTap: () => setState(() {
                    _index = 0;
                    _correctCount = 0;
                    _checked = false;
                    _ctrl.clear();
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final word = words[_index];

    return Scaffold(
      appBar: AppBar(title: const Text('Luyện viết')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Câu ${_index + 1} / ${words.length}', style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _index / words.length,
                minHeight: 8,
                backgroundColor: AppColors.cardBorder,
                valueColor: const AlwaysStoppedAnimation(AppColors.blue),
              ),
            ),
            const SizedBox(height: 28),
            const Text('Viết từ tiếng Anh có nghĩa là:', style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 8),
            Text(word.meaning, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 28),
            TextField(
              controller: _ctrl,
              enabled: !_checked,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'Nhập câu trả lời...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _checked ? (_isCorrect ? AppColors.primaryGreen : AppColors.red) : AppColors.cardBorder, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: _checked ? (_isCorrect ? AppColors.primaryGreen : AppColors.red) : AppColors.cardBorder, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.blue, width: 2),
                ),
              ),
              onSubmitted: (_) => _checked ? null : _check(),
            ),
            if (_checked) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(_isCorrect ? Icons.check_circle : Icons.cancel, color: _isCorrect ? AppColors.primaryGreen : AppColors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isCorrect ? 'Chính xác!' : 'Đáp án đúng: ${word.word}',
                      style: TextStyle(color: _isCorrect ? AppColors.primaryGreen : AppColors.red, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            DuoButton(
              label: _checked ? (_index == words.length - 1 ? 'XEM KẾT QUẢ' : 'TIẾP THEO') : 'KIỂM TRA',
              color: AppColors.blue,
              shadowColor: AppColors.darkBlue,
              onTap: _checked ? _next : _check,
            ),
          ],
        ),
      ),
    );
  }
}
