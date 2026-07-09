import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import 'flashcard_only_screen.dart';
import 'matching_game_screen.dart';
import 'writing_practice_screen.dart';

/// Tab "Luyện tập" trên thanh điều hướng dưới cùng.
/// Gồm 3 hình thức ôn tập tổng hợp: Flashcard, Ghép từ, Luyện viết.
class PracticeHubScreen extends StatelessWidget {
  const PracticeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final words = app.sampleVocab;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Luyện tập', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
          const SizedBox(height: 4),
          const Text('Chọn một hình thức để ôn lại toàn bộ từ vựng', style: TextStyle(color: AppColors.textGrey)),
          const SizedBox(height: 24),
          _PracticeModeCard(
            title: 'Flashcard',
            subtitle: 'Lật thẻ để ghi nhớ từ vựng nhanh',
            icon: Icons.style_rounded,
            color: AppColors.primaryGreen,
            shadow: AppColors.darkGreen,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardOnlyScreen(words: words))),
          ),
          const SizedBox(height: 16),
          _PracticeModeCard(
            title: 'Trò chơi ghép cặp',
            subtitle: 'Ghép từ tiếng Anh với nghĩa tiếng Việt',
            icon: Icons.extension_rounded,
            color: AppColors.purple,
            shadow: const Color(0xFFA557E0),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchingGameScreen(words: words))),
          ),
          const SizedBox(height: 16),
          _PracticeModeCard(
            title: 'Luyện viết',
            subtitle: 'Gõ lại từ tiếng Anh theo nghĩa cho sẵn',
            icon: Icons.edit_note_rounded,
            color: AppColors.blue,
            shadow: AppColors.darkBlue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => WritingPracticeScreen(words: words))),
          ),
        ],
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
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
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
