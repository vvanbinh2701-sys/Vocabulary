import 'dart:math' as math;
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

class _FlashcardOnlyScreenState extends State<FlashcardOnlyScreen> with SingleTickerProviderStateMixin {
  int _index = 0;
  bool _showMeaning = false;
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller cho hiệu ứng lật trong 300ms
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Chu kỳ chạy từ 0.0 (mặt trước) đến 1.0 (mặt sau)
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Hàm xử lý kích hoạt hiệu ứng lật thẻ
  void _toggleCard() {
    setState(() {
      _showMeaning = !_showMeaning;
      if (_showMeaning) {
        _animationController.forward(); // Lật ra sau
      } else {
        _animationController.reverse(); // Lật về trước
      }
    });
  }

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
                onTap: _toggleCard,
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * math.pi;
                    final isBack = angle >= math.pi / 2;

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..rotateY(isBack ? math.pi : 0),
                        alignment: Alignment.center,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isBack ? AppColors.blue : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.cardBorder, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 12,
                                right: 12,
                                child: IconButton(
                                  icon: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    color: isFav
                                        ? AppColors.red
                                        : (isBack ? Colors.white : AppColors.textGrey),
                                  ),
                                  onPressed: () => app.toggleFavorite(word.id),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: isBack
                                        ? [
                                            Text(word.meaning,
                                                style: const TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.w900,
                                                    color: Colors.white),
                                                textAlign: TextAlign.center),
                                            const SizedBox(height: 12),
                                            Text('"${word.example}"',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontStyle: FontStyle.italic),
                                                textAlign: TextAlign.center),
                                          ]
                                        : [
                                            Text(word.word,
                                                style: const TextStyle(
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.w900),
                                                textAlign: TextAlign.center),
                                            const SizedBox(height: 8),
                                            if (word.pronunciation.isNotEmpty)
                                              Text(word.pronunciation,
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      color: AppColors.textGrey)),
                                            const SizedBox(height: 20),
                                            const Text('Chạm để xem nghĩa 👆',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textGrey)),
                                          ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                              _animationController.reset();
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
                          _animationController.reset();
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
