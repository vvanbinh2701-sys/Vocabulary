import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';
import '../services/tts_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _showFavorites = true;
  final _tts = TtsService();

  @override
  void dispose() {
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final categories = {
      'vocab': ('Từ vựng', AppColors.primaryGreen),
      'grammar': ('Ngữ pháp', AppColors.blue),
      'conversation': ('Hội thoại', AppColors.purple),
      'phrase': ('Câu', AppColors.orange),
    };

    // Lấy danh sách từ yêu thích
    final favWords = app.sampleVocab
        .where((v) => app.isFavorite(v.id))
        .toList();

    // Kiểm tra mục tiêu
    final wordGoalDone = app.wordsStudiedToday >= 5;
    final grammarGoalDone = app.grammarDoneToday >= 1;
    final practiceGoalDone = app.practiceSessionsToday >= 3;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          // ----- Header -----
          Text('Lộ trình học tập',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(fontSize: 24)),
          const SizedBox(height: 16),

          // ----- Streak Card -----
          _StreakCard(streak: app.currentStreak, record: app.longestStreak),
          const SizedBox(height: 20),

          // ----- Huy hiệu -----
          _BadgesSection(streak: app.currentStreak),
          const SizedBox(height: 20),

          // ----- Mục tiêu hàng ngày -----
          _SectionHeader(title: 'MỤC TIÊU HÀNG NGÀY'),
          const SizedBox(height: 10),
          _DailyGoalItem(
            icon: Icons.menu_book_rounded,
            label: 'Học 5 từ mới',
            isDone: wordGoalDone,
            progress: '${app.wordsStudiedToday}/5',
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 8),
          _DailyGoalItem(
            icon: Icons.checklist_rounded,
            label: 'Hoàn thành 1 bài ngữ pháp',
            isDone: grammarGoalDone,
            progress: '${app.grammarDoneToday}/1',
            color: AppColors.blue,
          ),
          const SizedBox(height: 8),
          _DailyGoalItem(
            icon: Icons.fitness_center_rounded,
            label: 'Luyện tập',
            isDone: practiceGoalDone,
            progress: '${app.practiceSessionsToday}/3',
            color: AppColors.orange,
          ),
          const SizedBox(height: 20),

          // ----- Tiến độ theo đề tài -----
          _SectionHeader(title: 'TIẾN ĐỘ THEO ĐỀ TÀI'),
          const SizedBox(height: 10),
          ...categories.entries.map((e) {
            final percent = app.progressByCategory[e.key] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryProgressCard(
                label: e.value.$1,
                percent: percent,
                color: e.value.$2,
              ),
            );
          }),
          const SizedBox(height: 20),

          // ----- Mục yêu thích -----
          _CollapsibleFavorites(
            isExpanded: _showFavorites,
            onToggle: () => setState(() => _showFavorites = !_showFavorites),
            words: favWords,
            tts: _tts,
            app: app,
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// STREAK CARD
// ====================================================================
class _StreakCard extends StatelessWidget {
  final int streak;
  final int record;
  const _StreakCard({required this.streak, required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.orange, AppColors.yellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE08600),
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 44)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak ngày liên tục',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kỷ lục: $record ngày',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// BADGES
// ====================================================================
class _BadgesSection extends StatelessWidget {
  final int streak;
  const _BadgesSection({required this.streak});

  @override
  Widget build(BuildContext context) {
    final badges = [
      _BadgeData('7 Ngày', Icons.emoji_events_rounded, streak >= 7, AppColors.yellow),
      _BadgeData('Chăm chỉ', Icons.whatshot_rounded, streak >= 3, AppColors.orange),
      _BadgeData('30 Ngày', Icons.military_tech_rounded, streak >= 30, AppColors.blue),
      _BadgeData('Cao thủ', Icons.diamond_rounded, streak >= 60, AppColors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'HUY HIỆU'),
        const SizedBox(height: 10),
        Row(
          children: [
            ...badges.map((b) => Expanded(
                  child: _BadgeItem(data: b),
                )),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '→',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BadgeData {
  final String label;
  final IconData icon;
  final bool unlocked;
  final Color color;
  const _BadgeData(this.label, this.icon, this.unlocked, this.color);
}

class _BadgeItem extends StatelessWidget {
  final _BadgeData data;
  const _BadgeItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            data.icon,
            color: data.unlocked ? data.color : AppColors.cardBorder,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: data.unlocked ? AppColors.textDark : AppColors.cardBorder,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// SECTION HEADER
// ====================================================================
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.textGrey,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ====================================================================
// DAILY GOAL ITEM
// ====================================================================
class _DailyGoalItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool isDone;
  final String progress;
  final Color color;

  const _DailyGoalItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.isDone,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? color.withOpacity(0.4) : AppColors.cardBorder,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDone ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDone ? color : AppColors.cardBorder,
                width: 2,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDone ? AppColors.textGrey : AppColors.textDark,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            progress,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isDone ? color : AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// CATEGORY PROGRESS CARD
// ====================================================================
class _CategoryProgressCard extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;
  const _CategoryProgressCard({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14)),
              Text('${(percent * 100).round()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// FAVORITES (COLLAPSIBLE)
// ====================================================================
class _CollapsibleFavorites extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Vocabulary> words;
  final TtsService tts;
  final AppState app;

  const _CollapsibleFavorites({
    required this.isExpanded,
    required this.onToggle,
    required this.words,
    required this.tts,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              _SectionHeader(title: 'MỤC YÊU THÍCH'),
              const Spacer(),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textGrey,
                size: 22,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (!isExpanded) const SizedBox.shrink(),
        if (isExpanded && words.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: const Center(
              child: Text(
                'Chưa có từ yêu thích nào\nHãy ❤️ từ vựng bạn muốn ôn tập nhé!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey, fontSize: 13, height: 1.5),
              ),
            ),
          ),
        if (isExpanded && words.isNotEmpty)
          ...words.map((word) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FavoriteWordCard(
                  word: word,
                  tts: tts,
                  app: app,
                ),
              )),
      ],
    );
  }
}

// ====================================================================
// FAVORITE WORD CARD
// ====================================================================
class _FavoriteWordCard extends StatelessWidget {
  final Vocabulary word;
  final TtsService tts;
  final AppState app;

  const _FavoriteWordCard({
    required this.word,
    required this.tts,
    required this.app,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: Row(
        children: [
          // Tim icon
          GestureDetector(
            onTap: () => app.toggleFavorite(word.id),
            child: Icon(
              Icons.favorite,
              color: AppColors.red,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Nội dung từ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                if (word.pronunciation.isNotEmpty)
                  Text(
                    word.pronunciation,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                Text(
                  word.meaning,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Nút phát âm
          GestureDetector(
            onTap: () => tts.speakWord(word.word),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                size: 20,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
