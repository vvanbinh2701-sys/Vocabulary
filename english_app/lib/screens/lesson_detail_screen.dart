import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class LessonDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: Text(topicTitle)),
      body: categoryId == 'conversation'
          ? _ConversationLesson(lines: app.conversationByTopic(topicId))
          : _WordLesson(
              words: app.vocabByTopic(topicId),
              isPhraseLesson: categoryId == 'phrase',
            ),
    );
  }
}

class _WordLesson extends StatelessWidget {
  final List<Vocabulary> words;
  final bool isPhraseLesson;

  const _WordLesson({
    required this.words,
    required this.isPhraseLesson,
  });

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu cho chủ đề này',
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: words.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final word = words[i];
        return _LessonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NumberBadge(
                      number: i + 1,
                      color: isPhraseLesson
                          ? AppColors.orange
                          : AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (word.pronunciation.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            word.pronunciation,
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                word.meaning,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  word.example,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConversationLesson extends StatelessWidget {
  final List<ConversationLine> lines;

  const _ConversationLesson({required this.lines});

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bài hội thoại cho chủ đề này',
          style: TextStyle(color: AppColors.textGrey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: lines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final line = lines[i];
        final isLeft = i.isEven;
        final color = isLeft ? AppColors.blue : AppColors.primaryGreen;

        return Align(
          alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.84),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.speaker,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    line.english,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    line.vietnamese,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
