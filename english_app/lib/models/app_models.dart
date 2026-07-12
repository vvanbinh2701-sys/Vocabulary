class Vocabulary {
  final String id;
  final String word;
  final String meaning;
  final String pronunciation;
  final String example;
  final String category;
  final String topicId;
  final String masteryLevel;
  final String? imageUrl;

  Vocabulary({
    required this.id,
    required this.word,
    required this.meaning,
    required this.pronunciation,
    required this.example,
    required this.category,
    required this.topicId,
    this.masteryLevel = 'Mới',
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'pronunciation': pronunciation,
      'example': example,
      'category': category,
      'topicId': topicId,
      'masteryLevel': masteryLevel,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  factory Vocabulary.fromMap(Map<String, dynamic> map, String docId) {
    return Vocabulary(
      id: docId,
      word: map['word'] ?? '',
      meaning: map['meaning'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      example: map['example'] ?? '',
      category: map['category'] ?? '',
      topicId: map['topicId'] ?? '',
      masteryLevel: map['masteryLevel'] ?? 'Mới',
      imageUrl: map['imageUrl'],
    );
  }
}

/// Một chủ đề con bên trong đề tài lớn (Từ vựng / Hội thoại / Câu).
/// Ví dụ: đề tài "Từ vựng" sẽ có nhiều Topic như "Gia đình", "Đồ ăn"...
class ConversationLine {
  final String id;
  final String topicId;
  final String speaker;
  final String english;
  final String vietnamese;
  final String masteryLevel;

  ConversationLine({
    required this.id,
    required this.topicId,
    required this.speaker,
    required this.english,
    required this.vietnamese,
    this.masteryLevel = 'Mới',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'speaker': speaker,
      'english': english,
      'vietnamese': vietnamese,
      'masteryLevel': masteryLevel,
    };
  }

  factory ConversationLine.fromMap(Map<String, dynamic> map, [String? docId]) {
    return ConversationLine(
      id: map['id'] ?? docId ?? '',
      topicId: map['topicId'] ?? '',
      speaker: map['speaker'] ?? '',
      english: map['english'] ?? '',
      vietnamese: map['vietnamese'] ?? '',
      masteryLevel: map['masteryLevel'] ?? 'Mới',
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'icon': icon,
      'itemCount': itemCount,
    };
  }

  factory Topic.fromMap(Map<String, dynamic> map, String docId) {
    return Topic(
      id: docId,
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      icon: map['icon'] ?? '',
      itemCount: map['itemCount'] ?? 0,
    );
  }
}

/// Phân nhóm các bài học ngữ pháp lớn.
class GrammarCategory {
  final String id;
  final String title;
  final String summary;
  final String icon;
  final int itemCount;

  GrammarCategory({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.itemCount,
  });
}

/// Một phần nhỏ trong bài học ngữ pháp, dùng để hiển thị nội dung giống mẫu.
class GrammarSection {
  final String title;
  final String content;

  GrammarSection({required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }

  factory GrammarSection.fromMap(Map<String, dynamic> map) {
    return GrammarSection(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }
}

/// Bài lý thuyết ngữ pháp (Thì, câu gián tiếp, câu bị động...).
class GrammarLesson {
  final String id;
  final String categoryId;
  final String title;
  final String summary;
  final String content;
  final List<GrammarSection> sections;
  final bool isCompleted;

  GrammarLesson({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.summary,
    required this.content,
    this.sections = const [],
    this.isCompleted = false,
  });

  GrammarLesson copyWith({bool? isCompleted}) {
    return GrammarLesson(
      id: id,
      categoryId: categoryId,
      title: title,
      summary: summary,
      content: content,
      sections: sections,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'title': title,
      'summary': summary,
      'content': content,
      'isCompleted': isCompleted,
      'sections': sections.map((s) => s.toMap()).toList(),
    };
  }

  factory GrammarLesson.fromMap(Map<String, dynamic> map, String docId) {
    var rawSections = map['sections'] as List?;
    List<GrammarSection> sectionsList = [];
    if (rawSections != null) {
      sectionsList = rawSections
          .map((s) => GrammarSection.fromMap(Map<String, dynamic>.from(s)))
          .toList();
    }
    return GrammarLesson(
      id: docId,
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      summary: map['summary'] ?? '',
      content: map['content'] ?? '',
      sections: sectionsList,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
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
