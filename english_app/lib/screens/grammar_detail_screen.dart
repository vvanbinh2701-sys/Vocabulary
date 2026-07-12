import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../providers/app_state.dart';

class GrammarDetailScreen extends StatelessWidget {
  final GrammarLesson lesson;
  const GrammarDetailScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book_rounded,
                      color: Colors.white, size: 28),
                  const SizedBox(height: 10),
                  Text(lesson.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(lesson.summary,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Lý thuyết',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 14),
            if (lesson.sections.isNotEmpty)
              ...lesson.sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder, width: 2),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      title: Text(section.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 15)),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        Text(section.content,
                            style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: AppColors.textDark)),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: Text(lesson.content,
                    style: const TextStyle(
                        fontSize: 14, height: 1.6, color: AppColors.textDark)),
              ),
            const SizedBox(height: 24),
            Builder(
              builder: (context) {
                final isCompleted = context.watch<AppState>().grammarLessons
                    .firstWhere((l) => l.id == lesson.id,
                        orElse: () => lesson)
                    .isCompleted;

                if (isCompleted) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryGreen, width: 2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.primaryGreen),
                        SizedBox(width: 8),
                        Text(
                          'ĐÃ HOÀN THÀNH',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return DuoButton(
                  label: 'ĐÃ HIỂU, ĐÁNH DẤU HOÀN THÀNH',
                  color: AppColors.primaryGreen,
                  shadowColor: AppColors.darkGreen,
                  onTap: () async {
                    await context.read<AppState>().markGrammarCompleted(lesson.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tuyệt vời! Bài học đã được đánh dấu hoàn thành 🎉'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
