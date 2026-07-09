import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';

class FlashcardOnlyScreen extends StatefulWidget {
  final List<Vocabulary> words;
  const FlashcardOnlyScreen({super.key, required this.words});

  @override
  State<FlashcardOnlyScreen> createState() => _FlashcardOnlyScreenState();
}

class _FlashcardOnlyScreenState extends State<FlashcardOnlyScreen> {
  int _index = 0;
  bool _showMeaning = false;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final words = widget.words;
    final word = words[_index];
    final isFav = app.isFavorite(word.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard')),
      body: Padding(
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
                                      Text(word.meaning, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white), textAlign: TextAlign.center),
                                      const SizedBox(height: 12),
                                      Text('"${word.example}"', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                                    ]
                                  : [
                                      Text(word.word, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                                      const SizedBox(height: 8),
                                      if (word.pronunciation.isNotEmpty) Text(word.pronunciation, style: const TextStyle(fontSize: 16, color: AppColors.textGrey)),
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
                        Navigator.pop(context);
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
      ),
    );
  }
}
