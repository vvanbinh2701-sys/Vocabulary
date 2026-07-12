import 'dart:math';

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final String topicTitle;
  final List<Vocabulary> words;

  const QuizScreen({super.key, required this.topicTitle, required this.words});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final List<_QuizQuestion> _questions;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _checked = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _questions = _buildQuestions(widget.words);
  }

  List<_QuizQuestion> _buildQuestions(List<Vocabulary> words) {
    final random = Random();
    final allMeanings = words.map((w) => w.meaning).toSet().toList();

    return words.map((word) {
      final correct = word.meaning;
      final wrongAnswers = allMeanings.where((m) => m != correct).toList()..shuffle(random);
      final options = <String>[correct];
      options.addAll(wrongAnswers.take(3));
      while (options.length < 4) {
        options.add('...?');
      }
      options.shuffle(random);

      return _QuizQuestion(
        prompt: 'Nghĩa của "${word.word}" là gì?',
        options: options,
        correctAnswer: correct,
      );
    }).toList();
  }

  void _selectOption(String option) {
    if (_checked) return;
    setState(() {
      _selectedOption = option;
    });
  }

  void _checkAnswer() {
    if (_selectedOption == null) return;
    setState(() {
      _checked = true;
      _isCorrect = _selectedOption == _questions[_currentIndex].correctAnswer;
    });
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedOption = null;
      _checked = false;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.topicTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trắc nghiệm',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 24)),
            const SizedBox(height: 6),
            const Text('Chọn đáp án ABCD cho mỗi câu hỏi.',
                style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 20),
            Text('Câu ${_currentIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                    color: AppColors.textGrey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: Text(question.prompt,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 20),
            ...question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final label = String.fromCharCode(65 + index);
              final selected = _selectedOption == option;
              final correct = question.correctAnswer == option;
              final showCorrect = _checked && correct;
              final showWrong = _checked && selected && !correct;

              return GestureDetector(
                onTap: () => _selectOption(option),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: showCorrect
                        ? AppColors.primaryGreen.withValues(alpha: 0.18)
                        : showWrong
                            ? AppColors.red.withValues(alpha: 0.18)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppColors.primaryGreen : AppColors.cardBorder,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryGreen : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            )),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text('$label. $option',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            if (_checked)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      _isCorrect ? Icons.check_circle : Icons.close_rounded,
                      color: _isCorrect ? AppColors.primaryGreen : AppColors.red,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isCorrect
                            ? 'Chính xác! Bạn trả lời đúng.'
                            : 'Sai rồi. Đáp án đúng là: ${question.correctAnswer}.',
                        style: TextStyle(
                          color: _isCorrect ? AppColors.primaryGreen : AppColors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: DuoButton(
                    label: _checked ? 'CÂU TIẾP' : 'KIỂM TRA',
                    color: _checked ? AppColors.primaryGreen : AppColors.blue,
                    shadowColor: _checked ? AppColors.darkGreen : AppColors.darkBlue,
                    onTap: _checked
                        ? _nextQuestion
                        : (_selectedOption == null ? null : _checkAnswer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String prompt;
  final List<String> options;
  final String correctAnswer;

  _QuizQuestion({
    required this.prompt,
    required this.options,
    required this.correctAnswer,
  });
}
