import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'flashcard_only_screen.dart';
import 'matching_game_screen.dart';
import 'quiz_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final String categoryId;
  final String topicId;
  final String topicTitle;

  const LessonDetailScreen({
    super.key,
    required this.categoryId,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final _searchCtrl = TextEditingController();
  final _tts = TtsService();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    final isConversation = widget.categoryId == 'conversation';
    final words = app.vocabByTopic(widget.topicId);
    final convLines = app.conversationByTopic(widget.topicId);

    final accent = widget.categoryId == 'phrase'
        ? AppColors.orange
        : AppColors.primaryGreen;

    // Filter either vocabulary items or conversation lines based on query
    final filteredWords = !isConversation
        ? (_query.isEmpty
            ? words
            : words.where((word) {
                final q = _query.toLowerCase();
                return word.word.toLowerCase().contains(q) ||
                    word.meaning.toLowerCase().contains(q) ||
                    word.pronunciation.toLowerCase().contains(q);
              }).toList())
        : <Vocabulary>[];

    final filteredLines = isConversation
        ? (_query.isEmpty
            ? convLines
            : convLines
                .where((line) =>
                    line.english.toLowerCase().contains(_query.toLowerCase()) ||
                    line.vietnamese
                        .toLowerCase()
                        .contains(_query.toLowerCase()))
                .toList())
        : <ConversationLine>[];

    final bottomPad = MediaQuery.of(context).padding.bottom + 20;
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicTitle)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad),
        children: [
          const SizedBox(height: 6),
          // Chỉ hiển thị game cards cho từ vựng, ẩn với hội thoại
          if (!isConversation && words.isNotEmpty)
            LayoutBuilder(
              builder: (context, constraints) {
                final screenH = MediaQuery.of(context).size.height;
                final cardHeight = (screenH * 0.14).clamp(96.0, 140.0);
                return SizedBox(
                  height: cardHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: _HorizontalShortcutCard(
                          title: 'Flashcard',
                          subtitle: 'Học qua thẻ ghi nhớ',
                          icon: Icons.style_rounded,
                          color: AppColors.primaryGreen,
                          shadow: AppColors.darkGreen,
                          onTap: () {
                                context.read<AppState>().trackPracticeSession();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FlashcardOnlyScreen(words: words),
                                  ),
                                );
                              },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HorizontalShortcutCard(
                          title: 'Trắc nghiệm',
                          subtitle: 'Chọn đáp án ABCD',
                          icon: Icons.quiz_rounded,
                          color: AppColors.blue,
                          shadow: AppColors.darkBlue,
                          onTap: () {
                                context.read<AppState>().trackPracticeSession();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(
                                      topicTitle: widget.topicTitle,
                                      words: words,
                                    ),
                                  ),
                                );
                              },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HorizontalShortcutCard(
                          title: 'Ghép cặp',
                          subtitle: 'Nối Anh - Việt',
                          icon: Icons.extension_rounded,
                          color: AppColors.purple,
                          shadow: const Color(0xFFA557E0),
                          onTap: () {
                                context.read<AppState>().trackPracticeSession();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MatchingGameScreen(words: words),
                                  ),
                                );
                              },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (!isConversation) const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: isConversation
                    ? 'Tìm kiếm hội thoại...'
                    : 'Tìm kiếm từ vựng...',
                hintStyle:
                    const TextStyle(color: AppColors.textGrey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close,
                            color: AppColors.textGrey, size: 18),
                        onPressed: () => setState(() {
                          _searchCtrl.clear();
                          _query = '';
                        }),
                      ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isConversation
                ? 'Bài hội thoại (${filteredLines.length})'
                : 'Danh sách từ vựng (${filteredWords.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (isConversation)
            (filteredLines.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Không tìm thấy đoạn hội thoại phù hợp',
                          style: TextStyle(color: AppColors.textGrey)),
                    ),
                  )
                : Column(
                    children: filteredLines.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final line = entry.value;
                      final isMastered = line.masteryLevel == 'Đã thuộc';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LessonCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _NumberBadge(number: idx + 1, color: accent),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(line.speaker,
                                                  style: TextStyle(
                                                      color: accent,
                                                      fontWeight:
                                                          FontWeight.w900)),
                                            ),
                                            _MasteryToggle(
                                              isMastered: isMastered,
                                              onTap: () => app
                                                  .toggleConversationMastered(
                                                      line.id),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(line.english,
                                                  style: const TextStyle(
                                                      color: AppColors.textDark,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      height: 1.35)),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _tts.speak(line.english),
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color:
                                                      accent.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                    Icons.volume_up_rounded,
                                                    size: 20,
                                                    color: accent),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(line.vietnamese,
                                  style: const TextStyle(
                                      color: AppColors.textGrey, height: 1.35)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ))
          else
            (filteredWords.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Không tìm thấy từ nào phù hợp',
                          style: TextStyle(color: AppColors.textGrey)),
                    ),
                  )
                : Column(
                    children: filteredWords.asMap().entries.map((entry) {
                      final index = entry.key;
                      final word = entry.value;
                      final isMastered = word.masteryLevel == 'Đã thuộc';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _LessonCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _NumberBadge(
                                      number: index + 1, color: accent),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                word.word,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w900,
                                                    color: AppColors.textDark),
                                              ),
                                            ),
                                            // Nút tròn toggle Mới ↔ Đã thuộc
                                            _MasteryToggle(
                                              isMastered: isMastered,
                                              onTap: () => app
                                                  .toggleWordMastered(word.id),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () =>
                                                  app.toggleFavorite(word.id),
                                              icon: Icon(
                                                app.isFavorite(word.id)
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: app.isFavorite(word.id)
                                                    ? AppColors.red
                                                    : AppColors.textGrey,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () =>
                                                  _tts.speakWord(word.word),
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color:
                                                      accent.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                    Icons.volume_up_rounded,
                                                    size: 18,
                                                    color: accent),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (word.pronunciation.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(word.pronunciation,
                                              style: const TextStyle(
                                                  color: AppColors.blue,
                                                  fontWeight: FontWeight.w700)),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                      child: Text(word.meaning,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textDark))),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(word.example,
                                    style: const TextStyle(
                                        color: AppColors.textGrey,
                                        fontStyle: FontStyle.italic,
                                        height: 1.35)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  )),
        ],
      ),
    );
  }
}

class _HorizontalShortcutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color shadow;
  final VoidCallback onTap;

  const _HorizontalShortcutCard({
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border(bottom: BorderSide(color: shadow, width: 4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Widget child;

  const _LessonCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: child,
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  final Color color;

  const _NumberBadge({
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Nút tròn toggle trạng thái thuộc từ vựng: Mới ↔ Đã thuộc
class _MasteryToggle extends StatelessWidget {
  final bool isMastered;
  final VoidCallback onTap;

  const _MasteryToggle({
    required this.isMastered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isMastered ? AppColors.primaryGreen : Colors.transparent,
          border: Border.all(
            color: isMastered
                ? AppColors.primaryGreen
                : AppColors.textGrey.withOpacity(0.4),
            width: 2.5,
          ),
        ),
        child: isMastered
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }
}
