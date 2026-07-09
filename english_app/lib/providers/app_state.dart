import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_models.dart';
import '../services/auth_service.dart';

/// Quản lý trạng thái chung: user, streak, tiến độ, danh sách yêu thích.
/// Hiện đang dùng dữ liệu mẫu (mock) - sau này thay bằng gọi Firebase
/// thông qua AuthService / ProgressService / FavoriteService như trong
/// class diagram của bạn.
class AppState extends ChangeNotifier {
  AppState({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _authSub = _authService.authStateChanges.listen(_setFirebaseUser);
    _setFirebaseUser(_authService.currentUser);
  }

  final AuthService _authService;
  late final StreamSubscription<User?> _authSub;

  // ----- User & Auth (mock) -----
  String? userName;
  String? userEmail;
  bool get isLoggedIn => userEmail != null;
  bool authReady = false;

  void _setFirebaseUser(User? user) {
    userEmail = user?.email;
    userName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName
        : user?.email?.split('@').first;
    authReady = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> register(String name, String email, String password) async {
    await _authService.register(name: name, email: email, password: password);
  }

  Future<void> updateUserName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _authService.updateDisplayName(trimmed);
    userName = trimmed;
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }

  // ----- Streak -----
  int currentStreak = 4;
  int longestStreak = 12;

  // ----- Progress (theo categoryId -> % hoàn thành) -----
  final Map<String, double> progressByCategory = {
    'vocab': 0.62,
    'grammar': 0.30,
    'conversation': 0.15,
    'phrase': 0.45,
  };

  final List<HistoryItem> history = [
    HistoryItem(
        lessonTitle: 'Từ vựng: Chủ đề Gia đình',
        studiedAt: DateTime.now().subtract(const Duration(hours: 3)),
        percent: 0.8),
    HistoryItem(
        lessonTitle: 'Hội thoại: Ở nhà hàng',
        studiedAt: DateTime.now().subtract(const Duration(days: 1)),
        percent: 1.0),
    HistoryItem(
        lessonTitle: 'Ngữ pháp: Thì hiện tại đơn',
        studiedAt: DateTime.now().subtract(const Duration(days: 2)),
        percent: 0.5),
  ];

  void updateProgress(String categoryId, double percent) {
    progressByCategory[categoryId] = percent;
    currentStreak += 1;
    notifyListeners();
  }

  // ----- Favorites -----
  final Set<String> favoriteWordIds = {};

  void toggleFavorite(String wordId) {
    if (favoriteWordIds.contains(wordId)) {
      favoriteWordIds.remove(wordId);
    } else {
      favoriteWordIds.add(wordId);
    }
    notifyListeners();
  }

  bool isFavorite(String wordId) => favoriteWordIds.contains(wordId);

  // ----- Dữ liệu mẫu cho luyện tập -----
  // topicId được gán cho từng từ để biết từ đó thuộc chủ đề con nào.
  final List<Vocabulary> sampleVocab = [
    Vocabulary(
        id: 'v1',
        word: 'Family',
        meaning: 'Gia đình',
        pronunciation: '/ˈfæməli/',
        example: 'I love my family.',
        category: 'vocab',
        topicId: 'vocab_family'),
    Vocabulary(
        id: 'v2',
        word: 'Mother',
        meaning: 'Mẹ',
        pronunciation: '/ˈmʌðər/',
        example: 'My mother is a teacher.',
        category: 'vocab',
        topicId: 'vocab_family'),
    Vocabulary(
        id: 'v3',
        word: 'Father',
        meaning: 'Bố',
        pronunciation: '/ˈfɑːðər/',
        example: 'My father works hard.',
        category: 'vocab',
        topicId: 'vocab_family'),
    Vocabulary(
        id: 'v4',
        word: 'Sibling',
        meaning: 'Anh chị em',
        pronunciation: '/ˈsɪblɪŋ/',
        example: 'I have two siblings.',
        category: 'vocab',
        topicId: 'vocab_family'),
    Vocabulary(
        id: 'v5',
        word: 'Apple',
        meaning: 'Quả táo',
        pronunciation: '/ˈæpl/',
        example: 'I eat an apple every day.',
        category: 'vocab',
        topicId: 'vocab_food'),
    Vocabulary(
        id: 'v6',
        word: 'Rice',
        meaning: 'Cơm/Gạo',
        pronunciation: '/raɪs/',
        example: 'We eat rice for dinner.',
        category: 'vocab',
        topicId: 'vocab_food'),
    Vocabulary(
        id: 'v7',
        word: 'Noodle',
        meaning: 'Mì',
        pronunciation: '/ˈnuːdl/',
        example: 'I like beef noodles.',
        category: 'vocab',
        topicId: 'vocab_food'),
    Vocabulary(
        id: 'v8',
        word: 'Travel',
        meaning: 'Du lịch',
        pronunciation: '/ˈtrævl/',
        example: 'I want to travel the world.',
        category: 'vocab',
        topicId: 'vocab_travel'),
    Vocabulary(
        id: 'v9',
        word: 'Airport',
        meaning: 'Sân bay',
        pronunciation: '/ˈeəpɔːt/',
        example: 'The airport is busy today.',
        category: 'vocab',
        topicId: 'vocab_travel'),
    Vocabulary(
        id: 'v10',
        word: 'Passport',
        meaning: 'Hộ chiếu',
        pronunciation: '/ˈpɑːspɔːt/',
        example: 'Don\'t forget your passport.',
        category: 'vocab',
        topicId: 'vocab_travel'),
    Vocabulary(
        id: 'v11',
        word: 'School',
        meaning: 'Trường học',
        pronunciation: '/skuːl/',
        example: 'I go to school every day.',
        category: 'vocab',
        topicId: 'vocab_school'),
    Vocabulary(
        id: 'v12',
        word: 'Teacher',
        meaning: 'Giáo viên',
        pronunciation: '/ˈtiːtʃər/',
        example: 'The teacher is kind.',
        category: 'vocab',
        topicId: 'vocab_school'),
    Vocabulary(
        id: 'v13',
        word: 'Homework',
        meaning: 'Bài tập về nhà',
        pronunciation: '/ˈhəʊmwɜːk/',
        example: 'I finished my homework.',
        category: 'vocab',
        topicId: 'vocab_school'),
    Vocabulary(
        id: 'c1',
        word: 'Hello, how are you?',
        meaning: 'Xin chào, bạn khoẻ không?',
        pronunciation: '',
        example: 'Lời chào hỏi thông thường.',
        category: 'conversation',
        topicId: 'conv_greeting'),
    Vocabulary(
        id: 'c2',
        word: 'Nice to meet you.',
        meaning: 'Rất vui được gặp bạn.',
        pronunciation: '',
        example: 'Dùng khi gặp ai đó lần đầu.',
        category: 'conversation',
        topicId: 'conv_greeting'),
    Vocabulary(
        id: 'c3',
        word: 'Can I have the menu, please?',
        meaning: 'Cho tôi xin thực đơn được không?',
        pronunciation: '',
        example: 'Dùng khi gọi món ở nhà hàng.',
        category: 'conversation',
        topicId: 'conv_restaurant'),
    Vocabulary(
        id: 'c4',
        word: 'The bill, please.',
        meaning: 'Cho tôi xin hoá đơn.',
        pronunciation: '',
        example: 'Dùng khi thanh toán.',
        category: 'conversation',
        topicId: 'conv_restaurant'),
    Vocabulary(
        id: 'c5',
        word: 'How much does it cost?',
        meaning: 'Cái này giá bao nhiêu?',
        pronunciation: '',
        example: 'Dùng khi mua sắm.',
        category: 'conversation',
        topicId: 'conv_shopping'),
    Vocabulary(
        id: 'p1',
        word: 'Take it easy.',
        meaning: 'Thư giãn đi / Đừng lo lắng.',
        pronunciation: '',
        example: 'Mẫu câu an ủi.',
        category: 'phrase',
        topicId: 'phrase_daily'),
    Vocabulary(
        id: 'p2',
        word: 'It depends.',
        meaning: 'Còn tuỳ.',
        pronunciation: '',
        example: 'Dùng khi chưa chắc chắn.',
        category: 'phrase',
        topicId: 'phrase_daily'),
    Vocabulary(
        id: 'p3',
        word: 'I am on my way.',
        meaning: 'Tôi đang trên đường tới.',
        pronunciation: '',
        example: 'Thông báo đang di chuyển.',
        category: 'phrase',
        topicId: 'phrase_work'),
    Vocabulary(
        id: 'p4',
        word: 'Let\'s get started.',
        meaning: 'Hãy bắt đầu thôi.',
        pronunciation: '',
        example: 'Mở đầu cuộc họp.',
        category: 'phrase',
        topicId: 'phrase_work'),
  ];

  List<Vocabulary> vocabByTopic(String topicId) =>
      sampleVocab.where((v) => v.topicId == topicId).toList();

  // ----- Các chủ đề con bên trong từng đề tài lớn -----
  List<ConversationLine> conversationByTopic(String topicId) {
    final lessons = <String, List<ConversationLine>>{
      'conv_greeting': [
        ConversationLine(
            speaker: 'Anna',
            english: 'Hi, my name is Anna. What is your name?',
            vietnamese: 'Chào, tôi tên là Anna. Bạn tên là gì?'),
        ConversationLine(
            speaker: 'Ben',
            english: 'Hello Anna, I am Ben. Nice to meet you.',
            vietnamese: 'Chào Anna, tôi là Ben. Rất vui được gặp bạn.'),
        ConversationLine(
            speaker: 'Anna',
            english: 'Nice to meet you too. How are you today?',
            vietnamese:
                'Tôi cũng rất vui được gặp bạn. Hôm nay bạn khỏe không?'),
        ConversationLine(
            speaker: 'Ben',
            english: 'I am good, thank you. How about you?',
            vietnamese: 'Tôi khỏe, cảm ơn bạn. Còn bạn thì sao?'),
        ConversationLine(
            speaker: 'Anna',
            english: 'I am great. Welcome to our English class.',
            vietnamese:
                'Tôi rất tốt. Chào mừng bạn đến với lớp tiếng Anh của chúng ta.'),
      ],
      'conv_restaurant': [
        ConversationLine(
            speaker: 'Waiter',
            english: 'Good evening. Are you ready to order?',
            vietnamese: 'Chào buổi tối. Quý khách đã sẵn sàng gọi món chưa?'),
        ConversationLine(
            speaker: 'Customer',
            english: 'Yes, can I have the menu, please?',
            vietnamese: 'Rồi, cho tôi xin thực đơn được không?'),
        ConversationLine(
            speaker: 'Waiter',
            english: 'Of course. Here you are.',
            vietnamese: 'Tất nhiên rồi. Của quý khách đây.'),
        ConversationLine(
            speaker: 'Customer',
            english: 'I would like chicken rice and a glass of water.',
            vietnamese: 'Tôi muốn cơm gà và một ly nước.'),
        ConversationLine(
            speaker: 'Waiter',
            english: 'Sure. Your food will be ready soon.',
            vietnamese: 'Vâng. Món ăn của quý khách sẽ có sớm.'),
      ],
      'conv_shopping': [
        ConversationLine(
            speaker: 'Customer',
            english: 'Excuse me, how much does this shirt cost?',
            vietnamese: 'Xin lỗi, chiếc áo này giá bao nhiêu?'),
        ConversationLine(
            speaker: 'Seller',
            english: 'It is twenty dollars.',
            vietnamese: 'Nó có giá hai mươi đô la.'),
        ConversationLine(
            speaker: 'Customer',
            english: 'Do you have it in blue?',
            vietnamese: 'Bạn có màu xanh không?'),
        ConversationLine(
            speaker: 'Seller',
            english: 'Yes, we do. What size do you need?',
            vietnamese: 'Có. Bạn cần cỡ nào?'),
        ConversationLine(
            speaker: 'Customer',
            english: 'Medium, please.',
            vietnamese: 'Cỡ vừa, làm ơn.'),
      ],
    };

    return lessons[topicId] ?? const <ConversationLine>[];
  }

  List<Topic> topicsOf(String categoryId) {
    final all = <Topic>[
      Topic(
          id: 'vocab_family',
          categoryId: 'vocab',
          title: 'Gia đình',
          icon: '👨‍👩‍👧',
          itemCount: 4),
      Topic(
          id: 'vocab_food',
          categoryId: 'vocab',
          title: 'Đồ ăn',
          icon: '🍜',
          itemCount: 3),
      Topic(
          id: 'vocab_travel',
          categoryId: 'vocab',
          title: 'Du lịch',
          icon: '✈️',
          itemCount: 3),
      Topic(
          id: 'vocab_school',
          categoryId: 'vocab',
          title: 'Trường học',
          icon: '🏫',
          itemCount: 3),
      Topic(
          id: 'conv_greeting',
          categoryId: 'conversation',
          title: 'Chào hỏi',
          icon: '👋',
          itemCount: 2),
      Topic(
          id: 'conv_restaurant',
          categoryId: 'conversation',
          title: 'Ở nhà hàng',
          icon: '🍽️',
          itemCount: 2),
      Topic(
          id: 'conv_shopping',
          categoryId: 'conversation',
          title: 'Mua sắm',
          icon: '🛍️',
          itemCount: 1),
      Topic(
          id: 'phrase_daily',
          categoryId: 'phrase',
          title: 'Giao tiếp hàng ngày',
          icon: '💬',
          itemCount: 2),
      Topic(
          id: 'phrase_work',
          categoryId: 'phrase',
          title: 'Công việc',
          icon: '💼',
          itemCount: 2),
    ];
    return all.where((t) => t.categoryId == categoryId).toList();
  }

  // ----- Danh mục lý thuyết Ngữ pháp -----
  final List<GrammarLesson> grammarLessons = [
    GrammarLesson(
      id: 'g1',
      title: 'Thì hiện tại đơn',
      summary: 'Diễn tả thói quen, sự thật hiển nhiên',
      content:
          'Thì hiện tại đơn dùng để diễn tả thói quen, hành động lặp đi lặp lại hoặc sự thật hiển nhiên.\n\nCông thức: S + V(s/es) + O\n\nVí dụ: She goes to school every day.',
      isCompleted: true,
    ),
    GrammarLesson(
      id: 'g2',
      title: 'Thì hiện tại tiếp diễn',
      summary: 'Diễn tả hành động đang xảy ra',
      content:
          'Thì hiện tại tiếp diễn dùng để diễn tả hành động đang xảy ra ngay lúc nói.\n\nCông thức: S + am/is/are + V-ing\n\nVí dụ: I am studying English now.',
    ),
    GrammarLesson(
      id: 'g3',
      title: 'Thì quá khứ đơn',
      summary: 'Diễn tả hành động đã xảy ra và kết thúc',
      content:
          'Thì quá khứ đơn dùng để diễn tả hành động đã xảy ra và kết thúc trong quá khứ.\n\nCông thức: S + V-ed/V2 + O\n\nVí dụ: I visited my grandparents last week.',
    ),
    GrammarLesson(
      id: 'g4',
      title: 'Câu bị động',
      summary: 'Nhấn mạnh đối tượng chịu tác động',
      content:
          'Câu bị động dùng khi muốn nhấn mạnh đối tượng chịu tác động của hành động hơn là người thực hiện.\n\nCông thức: S + be + V3/ed + (by O)\n\nVí dụ: The cake was made by my mother.',
    ),
    GrammarLesson(
      id: 'g5',
      title: 'Câu gián tiếp',
      summary: 'Thuật lại lời nói của người khác',
      content:
          'Câu gián tiếp (Reported speech) dùng để thuật lại lời nói của người khác mà không trích dẫn nguyên văn.\n\nVí dụ: She said, "I am tired." → She said that she was tired.',
    ),
    GrammarLesson(
      id: 'g6',
      title: 'Câu điều kiện',
      summary: 'Diễn tả điều kiện và kết quả',
      content:
          'Câu điều kiện gồm 3 loại chính: loại 1 (có thật ở hiện tại/tương lai), loại 2 (giả định không có thật ở hiện tại), loại 3 (giả định không có thật trong quá khứ).\n\nVí dụ: If it rains, I will stay home.',
    ),
  ];
}
