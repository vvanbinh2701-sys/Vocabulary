import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';
import '../services/image_seeder.dart';
import 'practice_screen.dart';

/// Tab "Luyện tập" trên thanh điều hướng dưới cùng.
/// Gồm 3 hình thức ôn tập tổng hợp + bộ lọc từ vựng.
class PracticeHubScreen extends StatefulWidget {
  const PracticeHubScreen({super.key});

  @override
  State<PracticeHubScreen> createState() => _PracticeHubScreenState();
}

class _PracticeHubScreenState extends State<PracticeHubScreen> {
  int _filterIndex = 0;
  bool _isSeeding = false;
  String _seedResult = '';

  Future<void> _seedImages(AppState app) async {
    setState(() {
      _isSeeding = true;
      _seedResult = '';
    });

    final vocabWords = app.sampleVocab.where((v) => v.category == 'vocab').toList();
    final seeder = ImageSeeder();
    final result = await seeder.seedImages(vocabWords);

    // Reload từ Firestore để lấy imageUrl mới
    await app.loadDataFromFirestore();

    setState(() {
      _isSeeding = false;
      _seedResult = result;
    });
  }

  List<Vocabulary> _filteredWords(List<Vocabulary> all) {
    return switch (_filterIndex) {
      1 => all.where((v) => v.masteryLevel == 'Mới').toList(),
      2 => all.where((v) => v.masteryLevel == 'Đã thuộc').toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final allWords = app.sampleVocab;
    final words = _filteredWords(allWords);
    final newCount = allWords.where((v) => v.masteryLevel == 'Mới').length;
    final masteredCount = allWords.where((v) => v.masteryLevel == 'Đã thuộc').length;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Luyện tập',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          const Text('Chọn một hình thức để ôn lại từ vựng',
              style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 20),

          // Bộ lọc
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả (${allWords.length})',
                  isSelected: _filterIndex == 0,
                  onTap: () => setState(() => _filterIndex = 0),
                ),
                _FilterChip(
                  label: 'Chưa thuộc ($newCount)',
                  isSelected: _filterIndex == 1,
                  onTap: () => setState(() => _filterIndex = 1),
                ),
                _FilterChip(
                  label: 'Đã thuộc ($masteredCount)',
                  isSelected: _filterIndex == 2,
                  onTap: () => setState(() => _filterIndex = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (words.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: const Center(
                child: Text('Không có từ nào trong bộ lọc này',
                    style: TextStyle(color: AppColors.textGrey)),
              ),
            )
          else ...[
            _PracticeModeCard(
              title: 'Học hình ảnh',
              subtitle: 'Xem từ và nghĩa qua thẻ ảnh',
              icon: Icons.image_rounded,
              color: AppColors.primaryGreen,
              shadow: AppColors.darkGreen,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeScreen(
                    categoryId: 'practice_hub',
                    categoryTitle: 'Học hình ảnh',
                    initialTabIndex: 0,
                    customWords: words,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PracticeModeCard(
              title: 'Sắp xếp câu',
              subtitle: 'Ghép các từ thành câu đúng',
              icon: Icons.format_line_spacing_rounded,
              color: AppColors.blue,
              shadow: AppColors.darkBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeScreen(
                    categoryId: 'practice_hub',
                    categoryTitle: 'Sắp xếp câu',
                    initialTabIndex: 1,
                    customWords: words,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PracticeModeCard(
              title: 'Hội thoại AI',
              subtitle: 'Nhập từ và AI tạo hội thoại',
              icon: Icons.chat_bubble_rounded,
              color: AppColors.orange,
              shadow: const Color(0xFFE08600),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeScreen(
                    categoryId: 'practice_hub',
                    categoryTitle: 'Hội thoại AI',
                    initialTabIndex: 2,
                    customWords: words,
                  ),
                ),
              ),
            ),
          ],
          // Nút tải ảnh tự động
          const SizedBox(height: 24),
          if (_seedResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_seedResult,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700)),
            ),
          GestureDetector(
            onTap: _isSeeding ? null : () => _seedImages(app),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isSeeding ? AppColors.textGrey : AppColors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: _isSeeding
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('📸 TẢI ẢNH TỰ ĐỘNG (30 từ)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ảnh sẽ được tải từ Unsplash và lưu vào Firebase Storage',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGrey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textGrey,
            ),
          ),
        ),
      ),
    );
  }
}

class _PracticeModeCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color, shadow;
  final VoidCallback onTap;

  const _PracticeModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.shadow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border(bottom: BorderSide(color: shadow, width: 4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}
