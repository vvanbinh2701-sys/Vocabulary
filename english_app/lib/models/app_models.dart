class Vocabulary {
  final String id;
  final String word;
  final String meaning;
  final String pronunciation;
  final String example;
  final String category;
  final String topicId;

  Vocabulary({
    required this.id,
    required this.word,
    required this.meaning,
    required this.pronunciation,
    required this.example,
    required this.category,
    required this.topicId,
  });
}

/// Một chủ đề con bên trong đề tài lớn (Từ vựng / Hội thoại / Câu).
/// Ví dụ: đề tài "Từ vựng" sẽ có nhiều Topic như "Gia đình", "Đồ ăn"...
class ConversationLine {
  final String speaker;
  final String english;
  final String vietnamese;

  ConversationLine({
    required this.speaker,
    required this.english,
    required this.vietnamese,
  });
}

class Topic {
  final String id;
  final String categoryId; // 'vocab' | 'conversation' | 'phrase'
  final String title;
  final String icon; // emoji minh hoạ
  final int itemCount;

  Topic({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.icon,
    required this.itemCount,
  });
}

/// Bài lý thuyết ngữ pháp (Thì, câu gián tiếp, câu bị động...).
class GrammarLesson {
  final String id;
  final String title;
  final String summary;
  final String content;
  final bool isCompleted;

  GrammarLesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.isCompleted = false,
  });
}

class LearningCategory {
  final String id;
  final String title;
  final String subtitle;
  final String icon; // tên icon (dùng IconData ở UI)
  final int colorIndex;

  LearningCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorIndex,
  });
}

class HistoryItem {
  final String lessonTitle;
  final DateTime studiedAt;
  final double percent;

  HistoryItem({
    required this.lessonTitle,
    required this.studiedAt,
    required this.percent,
  });
}
