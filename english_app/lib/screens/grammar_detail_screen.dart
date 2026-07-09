import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';

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
                  const Icon(Icons.menu_book_rounded, color: Colors.white, size: 28),
                  const SizedBox(height: 10),
                  Text(lesson.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(lesson.summary, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Lý thuyết', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: Text(lesson.content, style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textDark)),
            ),
            const SizedBox(height: 24),
            DuoButton(
              label: 'ĐÃ HIỂU, ĐÁNH DẤU HOÀN THÀNH',
              color: AppColors.primaryGreen,
              shadowColor: AppColors.darkGreen,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã ghi nhận tiến độ bài học này 🎉')),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
