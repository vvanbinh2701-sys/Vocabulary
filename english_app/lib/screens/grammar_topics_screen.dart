import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';
import 'grammar_detail_screen.dart';

/// Hiển thị khi nhấn vào đề tài "Học Ngữ pháp": danh sách các bài lý thuyết
/// (Thì, câu gián tiếp, câu bị động...) kèm thanh tìm kiếm.
class GrammarTopicsScreen extends StatefulWidget {
  const GrammarTopicsScreen({super.key});

  @override
  State<GrammarTopicsScreen> createState() => _GrammarTopicsScreenState();
}

class _GrammarTopicsScreenState extends State<GrammarTopicsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lessons = app.grammarLessons
        .where((g) => g.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Học Ngữ pháp')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Tìm bài ngữ pháp (vd: thì, bị động...)',
                  hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColors.textGrey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: lessons.isEmpty
                ? const Center(child: Text('Không tìm thấy bài học', style: TextStyle(color: AppColors.textGrey)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: lessons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _LessonCard(lesson: lessons[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final GrammarLesson lesson;
  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GrammarDetailScreen(lesson: lesson))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (lesson.isCompleted ? AppColors.primaryGreen : AppColors.blue).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                lesson.isCompleted ? Icons.check_circle : Icons.menu_book_rounded,
                color: lesson.isCompleted ? AppColors.primaryGreen : AppColors.blue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(lesson.summary, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
