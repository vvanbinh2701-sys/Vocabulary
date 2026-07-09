import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'category_topics_screen.dart';
import 'grammar_topics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final categories = [
      _CategoryData(
        'grammar',
        'Học Ngữ pháp',
        'Nắm vững cấu trúc câu',
        Icons.menu_book_rounded,
        AppColors.blue,
        AppColors.darkBlue,
      ),
      _CategoryData(
        'vocab',
        'Học Từ vựng',
        'Mở rộng vốn từ mỗi ngày',
        Icons.style_rounded,
        AppColors.primaryGreen,
        AppColors.darkGreen,
      ),
      _CategoryData(
        'conversation',
        'Học Hội thoại',
        'Giao tiếp tự nhiên hơn',
        Icons.chat_bubble_rounded,
        AppColors.purple,
        const Color(0xFFA557E0),
      ),
      _CategoryData(
        'phrase',
        'Học Câu',
        'Mẫu câu thông dụng',
        Icons.format_quote_rounded,
        AppColors.orange,
        const Color(0xFFE08600),
      ),
    ];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào, ${app.userName ?? "bạn"} 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'Sẵn sàng học hôm nay chưa?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StreakBadge(streak: app.currentStreak),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Học theo đề tài',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final c = categories[i];
                  final percent = app.progressByCategory[c.id] ?? 0;
                  return _CategoryCard(
                    data: c,
                    percent: percent,
                    onTap: () {
                      if (c.id == 'grammar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GrammarTopicsScreen(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryTopicsScreen(
                              categoryId: c.id,
                              categoryTitle: c.title,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
                childCount: categories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _CategoryData {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color shadow;

  _CategoryData(
    this.id,
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.shadow,
  );
}

class _CategoryCard extends StatelessWidget {
  final _CategoryData data;
  final double percent;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.data,
    required this.percent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: data.color,
          borderRadius: BorderRadius.circular(20),
          border: Border(bottom: BorderSide(color: data.shadow, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, color: Colors.white, size: 24),
            ),
            const Spacer(),
            Text(
              data.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(percent * 100).round()}% hoàn thành',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;

  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.yellow.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.orange,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
