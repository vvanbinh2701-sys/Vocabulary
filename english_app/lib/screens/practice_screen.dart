import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';

/// Màn hình học chi tiết một chủ đề con (vd: "Gia đình" trong Từ vựng).
/// categoryId ở đây thực chất là topicId (vd: 'vocab_family').
class PracticeScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  const PracticeScreen({super.key, required this.categoryId, required this.categoryTitle});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final words = context.watch<AppState>().vocabByTopic(widget.categoryId);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primaryGreen,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800),
          tabs: const [
            Tab(text: 'Flashcard'),
            Tab(text: 'Trắc nghiệm'),
          ],
        ),
      ),
      body: words.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu cho chủ đề này', style: TextStyle(color: AppColors.textGrey)))
          : TabBarView(
              controller: _tab,
              children: [
                _FlashcardTab(words: words),
                _QuizTab(words: words),
              ],
            ),
    );
  }
}

// ---------------- FLASHCARD TAB ----------------

class _FlashcardTab extends StatefulWidget {
  final List<Vocabulary> words;
  const _FlashcardTab({required this.words});

  @override
  State<_FlashcardTab> createState() => _FlashcardTabState();
}

class _FlashcardTabState extends State<_FlashcardTab> {
  int _index = 0;
  bool _showMeaning = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final words = widget.words;
    final word = words[_index];
    final isFav = app.isFavorite(word.id);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Thẻ ${_index + 1} / ${words.length}', style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index + 1) / words.length,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showMeaning = !_showMeaning),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Container(
                  key: ValueKey('$_index$_showMeaning'),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _showMeaning ? AppColors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? AppColors.red : (_showMeaning ? Colors.white : AppColors.textGrey),
                          ),
                          onPressed: () => app.toggleFavorite(word.id),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _showMeaning
                                ? [
                                    Text(word.meaning, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center),
                                    const SizedBox(height: 12),
                                    Text('"${word.example}"', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                                  ]
                                : [
                                    Text(word.word, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                                    const SizedBox(height: 8),
                                    Text(word.pronunciation, style: const TextStyle(fontSize: 16, color: AppColors.textGrey)),
                                    const SizedBox(height: 20),
                                    const Text('Chạm để xem nghĩa 👆', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                                  ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DuoButton(
                  label: 'TRƯỚC',
                  color: AppColors.textGrey,
                  shadowColor: const Color(0xFF555555),
                  onTap: _index == 0
                      ? null
                      : () => setState(() {
                            _index--;
                            _showMeaning = false;
                          }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DuoButton(
                  label: _index == words.length - 1 ? 'HOÀN THÀNH' : 'TIẾP THEO',
                  color: AppColors.primaryGreen,
                  shadowColor: AppColors.darkGreen,
                  onTap: () {
                    if (_index == words.length - 1) {
                      app.updateProgress(word.category, 1.0);
                      _showCompleteDialog(context);
                    } else {
                      setState(() {
                        _index++;
                        _showMeaning = false;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Chúc mừng!'),
        content: const Text('Bạn đã hoàn thành bộ flashcard này. Tiến độ và streak đã được cập nhật.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }
}

// ---------------- QUIZ TAB ----------------

class _QuizTab extends StatefulWidget {
  final List<Vocabulary> words;
  const _QuizTab({required this.words});

  @override
  State<_QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<_QuizTab> {
  int _index = 0;
  int _score = 0;
  String? _selected;
  bool _answered = false;

  List<String> _generateOptions(List<Vocabulary> pool, Vocabulary correct) {
    final others = pool.where((v) => v.id != correct.id).map((v) => v.meaning).toList()..shuffle();
    final opts = [correct.meaning, ...others.take(min(3, others.length))];
    opts.shuffle(Random());
    return opts;
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.words;

    if (_index >= words.length) {
      return _ResultView(score: _score, total: words.length, onRetry: () => setState(() {
        _index = 0;
        _score = 0;
        _answered = false;
        _selected = null;
      }));
    }

    final word = words[_index];
    final options = _generateOptions(words, word);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Câu ${_index + 1} / ${words.length}', style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index) / words.length,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.blue),
            ),
          ),
          const SizedBox(height: 28),
          const Text('"${''}"', style: TextStyle(fontSize: 0)), // spacer noop
          Text('Từ "${word.word}" có nghĩa là gì?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final opt = options[i];
                final isCorrect = opt == word.meaning;
                Color bg = Colors.white;
                Color border = AppColors.cardBorder;
                if (_answered) {
                  if (isCorrect) {
                    bg = AppColors.primaryGreen.withOpacity(0.15);
                    border = AppColors.primaryGreen;
                  } else if (opt == _selected) {
                    bg = AppColors.red.withOpacity(0.12);
                    border = AppColors.red;
                  }
                }
                return GestureDetector(
                  onTap: _answered
                      ? null
                      : () {
                          setState(() {
                            _selected = opt;
                            _answered = true;
                            if (isCorrect) _score++;
                          });
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border, width: 2),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(opt, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                        if (_answered && isCorrect) const Icon(Icons.check_circle, color: AppColors.primaryGreen),
                        if (_answered && !isCorrect && opt == _selected) const Icon(Icons.cancel, color: AppColors.red),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          DuoButton(
            label: _index == words.length - 1 ? 'XEM KẾT QUẢ' : 'CÂU TIẾP THEO',
            color: AppColors.blue,
            shadowColor: AppColors.darkBlue,
            onTap: _answered
                ? () => setState(() {
                      _index++;
                      _answered = false;
                      _selected = null;
                    })
                : null,
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onRetry;
  const _ResultView({required this.score, required this.total, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : score / total;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(percent >= 0.7 ? '🏆' : '💪', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Bạn đúng $score/$total câu', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(
            percent >= 0.7 ? 'Tuyệt vời, bạn nắm rất chắc!' : 'Cố lên, luyện thêm chút nữa nhé!',
            style: const TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 32),
          DuoButton(label: 'LÀM LẠI', color: AppColors.primaryGreen, shadowColor: AppColors.darkGreen, onTap: onRetry),
        ],
      ),
    );
  }
}
