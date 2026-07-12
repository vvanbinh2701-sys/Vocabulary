import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';
import 'grammar_detail_screen.dart';

/// Cấu trúc một nhóm ngữ pháp (Tenses, Conditionals, ...)
class _GrammarGroup {
  final String title;
  final String emoji;
  final List<String> lessonIds;

  const _GrammarGroup({
    required this.title,
    required this.emoji,
    required this.lessonIds,
  });
}

/// Danh sách các nhóm ngữ pháp
const _groups = [
  _GrammarGroup(
    title: 'Các Thì',
    emoji: '⏰',
    lessonIds: [
      'g1',
      'g2',
      'g3',
      'g4',
      'g5',
      'g7',
      'g8',
      'g9',
      'g10',
      'g11',
      'g12',
      'g13'
    ],
  ),
  _GrammarGroup(
    title: 'So sánh',
    emoji: '📊',
    lessonIds: ['g6'],
  ),
  _GrammarGroup(
    title: 'Câu Điều Kiện',
    emoji: '❓',
    lessonIds: ['g14', 'g15', 'g16', 'g17', 'g18'],
  ),
  _GrammarGroup(
    title: 'Câu Bị Động',
    emoji: '🔄',
    lessonIds: ['g19', 'g20', 'g21'],
  ),
  _GrammarGroup(
    title: 'Câu Tường Thuật',
    emoji: '💬',
    lessonIds: ['g22', 'g23', 'g24'],
  ),
  _GrammarGroup(
    title: 'Động Từ Khuyết Thiếu',
    emoji: '🔑',
    lessonIds: ['g25', 'g26', 'g27', 'g28', 'g29', 'g30'],
  ),
  _GrammarGroup(
    title: 'Mệnh Đề Quan Hệ',
    emoji: '🔗',
    lessonIds: ['g31', 'g32', 'g33'],
  ),
  _GrammarGroup(
    title: 'Từ Loại',
    emoji: '📝',
    lessonIds: ['g34', 'g35', 'g36', 'g37', 'g38', 'g39'],
  ),
  _GrammarGroup(
    title: 'Cấu Trúc Nâng Cao',
    emoji: '🚀',
    lessonIds: ['g40', 'g41', 'g42', 'g43', 'g44', 'g45', 'g46'],
  ),
];

/// Hiển thị khi nhấn vào đề tài "Học Ngữ pháp": danh sách các bài lý thuyết
/// được phân nhóm theo chủ đề, kèm thanh tìm kiếm.
class GrammarTopicsScreen extends StatefulWidget {
  const GrammarTopicsScreen({super.key});

  @override
  State<GrammarTopicsScreen> createState() => _GrammarTopicsScreenState();
}

class _GrammarTopicsScreenState extends State<GrammarTopicsScreen> {
  String _query = '';
  final Set<String> _expandedGroups = {'Các Thì'}; // Mặc định mở nhóm "Các Thì"

  void _toggleGroup(String title) {
    setState(() {
      if (_expandedGroups.contains(title)) {
        _expandedGroups.remove(title);
      } else {
        _expandedGroups.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final allLessons = app.grammarLessons;
    final isSearching = _query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Học Ngữ pháp')),
      body: Column(
        children: [
          // Thanh tìm kiếm
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
            child: isSearching
                ? _buildSearchResults(allLessons)
                : _buildGroupedList(allLessons),
          ),
        ],
      ),
    );
  }

  /// Hiển thị kết quả tìm kiếm dạng danh sách phẳng
  Widget _buildSearchResults(List<GrammarLesson> allLessons) {
    final results = allLessons
        .where((g) => g.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy bài học',
            style: TextStyle(color: AppColors.textGrey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _LessonCard(lesson: results[i]),
    );
  }

  /// Hiển thị danh sách phân nhóm có thể xổ xuống / thu gọn
  Widget _buildGroupedList(List<GrammarLesson> allLessons) {
    final lessonMap = {for (var l in allLessons) l.id: l};

    // Xây dựng danh sách items: header + (nếu đang mở thì mới thêm lessons)
    final List<dynamic> items = [];
    for (final group in _groups) {
      final groupLessons = group.lessonIds
          .map((id) => lessonMap[id])
          .whereType<GrammarLesson>()
          .toList();
      if (groupLessons.isEmpty) continue;

      final completed = groupLessons.where((l) => l.isCompleted).length;
      final isExpanded = _expandedGroups.contains(group.title);
      items.add(_GroupHeader(
        group: group,
        total: groupLessons.length,
        completed: completed,
        isExpanded: isExpanded,
        onTap: () => _toggleGroup(group.title),
      ));
      if (isExpanded) {
        items.addAll(groupLessons);
      }
    }

    if (items.isEmpty) {
      return const Center(
        child: Text('Chưa có bài học',
            style: TextStyle(color: AppColors.textGrey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item is _GroupHeader) {
          return Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: item,
          );
        } else if (item is GrammarLesson) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LessonCard(lesson: item),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Widget header của mỗi nhóm ngữ pháp, bấm vào để xổ xuống / thu gọn
class _GroupHeader extends StatelessWidget {
  final _GrammarGroup group;
  final int total;
  final int completed;
  final bool isExpanded;
  final VoidCallback onTap;

  const _GroupHeader({
    required this.group,
    required this.total,
    required this.completed,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(group.emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    '$completed/$total bài đã hoàn thành',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),
            ),
            // Progress pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: completed == total && total > 0
                    ? AppColors.primaryGreen.withOpacity(0.15)
                    : AppColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                total > 0 ? '${(completed / total * 100).round()}%' : '0%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: completed == total && total > 0
                      ? AppColors.primaryGreen
                      : AppColors.blue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Icon xổ xuống / thu gọn
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textGrey),
            ),
          ],
        ),
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
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => GrammarDetailScreen(lesson: lesson))),
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
                color: (lesson.isCompleted
                        ? AppColors.primaryGreen
                        : AppColors.blue)
                    .withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                lesson.isCompleted
                    ? Icons.check_circle
                    : Icons.menu_book_rounded,
                color: lesson.isCompleted
                    ? AppColors.primaryGreen
                    : AppColors.blue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(lesson.summary,
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 12)),
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
