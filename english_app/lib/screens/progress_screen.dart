import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final categories = {
      'vocab': ('Từ vựng', AppColors.primaryGreen),
      'grammar': ('Ngữ pháp', AppColors.blue),
      'conversation': ('Hội thoại', AppColors.purple),
      'phrase': ('Câu', AppColors.orange),
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Lộ trình học tập', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
          const SizedBox(height: 16),

          // Streak card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.orange, AppColors.yellow]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 44)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${app.currentStreak} ngày liên tục', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    Text('Kỷ lục: ${app.longestStreak} ngày', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Tiến độ theo đề tài', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17)),
          const SizedBox(height: 12),
          ...categories.entries.map((e) {
            final percent = app.progressByCategory[e.key] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.value.$1, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        Text('${(percent * 100).round()}%', style: TextStyle(fontWeight: FontWeight.w800, color: e.value.$2)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percent,
                        minHeight: 9,
                        backgroundColor: AppColors.cardBorder,
                        valueColor: AlwaysStoppedAnimation(e.value.$2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          Text('Lịch sử học tập', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 17)),
          const SizedBox(height: 12),
          ...app.history.map((h) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.12), shape: BoxShape.circle),
                      child: Icon(
                        h.percent >= 1.0 ? Icons.check_circle : Icons.timelapse,
                        color: AppColors.primaryGreen,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.lessonTitle, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(_formatTime(h.studiedAt), style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('${(h.percent * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}
