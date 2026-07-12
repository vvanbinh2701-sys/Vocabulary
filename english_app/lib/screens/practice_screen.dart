import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';
import '../services/deepseek_service.dart';

/// Màn hình luyện tập cho một chủ đề con.
/// Thay vì flashcard + luyện viết + ghép cặp, dùng 3 hình thức phù hợp với app.
class PracticeScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  final int initialTabIndex;
  final List<Vocabulary>? customWords;
  const PracticeScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
    this.initialTabIndex = 0,
    this.customWords,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.customWords ??
        context.watch<AppState>().vocabByTopic(widget.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.primaryGreen,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800),
          tabs: const [
            Tab(text: 'Học hình ảnh'),
            Tab(text: 'Sắp xếp câu'),
            Tab(text: 'Hội thoại AI'),
          ],
        ),
      ),
      body: words.isEmpty
          ? const Center(
              child: Text('Chưa có dữ liệu cho chủ đề này',
                  style: TextStyle(color: AppColors.textGrey)),
            )
          : TabBarView(
              controller: _tab,
              children: [
                _ImageLearningTab(words: words),
                _SentenceArrangeTab(words: words),
                const _AiDialogueTab(),
              ],
            ),
    );
  }
}

class _ImageLearningTab extends StatefulWidget {
  final List<Vocabulary> words;
  const _ImageLearningTab({required this.words});

  @override
  State<_ImageLearningTab> createState() => _ImageLearningTabState();
}

class _ImageLearningTabState extends State<_ImageLearningTab> {
  int _index = 0;
  bool _showMeaning = false;

  static const _colors = [
    AppColors.primaryGreen,
    AppColors.blue,
    AppColors.orange,
    AppColors.purple,
  ];

  /// Map từ vựng → emoji minh họa
  static const _emojiMap = {
    'dog': '🐕',
    'cat': '🐈',
    'bird': '🐦',
    'fish': '🐟',
    'elephant': '🐘',
    'tiger': '🐅',
    'lion': '🦁',
    'monkey': '🐒',
    'horse': '🐴',
    'cow': '🐄',
    'mother': '👩',
    'father': '👨',
    'family': '👨‍👩‍👧‍👦',
    'brother': '👦',
    'sister': '👧',
    'apple': '🍎',
    'banana': '🍌',
    'rice': '🍚',
    'bread': '🍞',
    'water': '💧',
    'doctor': '🩺',
    'teacher': '📚',
    'student': '🎒',
    'nurse': '💊',
    'school': '🏫',
    'house': '🏠',
    'hospital': '🏥',
    'restaurant': '🍽️',
    'shop': '🛍️',
    'car': '🚗',
    'bus': '🚌',
    'plane': '✈️',
    'bike': '🚲',
    'pen': '🖊️',
    'book': '📖',
    'phone': '📱',
    'computer': '💻',
    'hello': '👋',
    'go': '🚶',
    'eat': '🍽️',
    'sleep': '😴',
    'run': '🏃',
    'beautiful': '✨',
    'big': '🐋',
    'small': '🐜',
    'happy': '😊',
    'sad': '😢',
  };

  String _emojiFor(String word) {
    final lower = word.toLowerCase();
    for (final entry in _emojiMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    // Fallback: dùng chữ cái đầu
    return String.fromCharCode(lower.codeUnitAt(0) - 32 + 0x1F1E6);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final words = widget.words;
    if (words.isEmpty) {
      return const Center(
          child: Text('Không có từ nào',
              style: TextStyle(color: AppColors.textGrey)));
    }
    final word = words[_index];
    final color = _colors[_index % _colors.length];
    final isMastered = word.masteryLevel == 'Đã thuộc';
    final emoji = _emojiFor(word.word);
    final hasImage = word.imageUrl != null && word.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Từ ${_index + 1} / ${words.length}',
              style: const TextStyle(
                  color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index + 1) / words.length,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showMeaning = !_showMeaning),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24)),
                        child: Container(
                          width: double.infinity,
                          color: color,
                          child: hasImage
                              ? Image.network(
                                  word.imageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: Text(emoji,
                                          style: const TextStyle(fontSize: 72)),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                          child: Text(emoji,
                                              style: const TextStyle(
                                                  fontSize: 72))),
                                )
                              : Center(
                                  child: Text(emoji,
                                      style: const TextStyle(fontSize: 72)),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: _showMeaning
                            ? [
                                Text(word.meaning,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                Text('"${word.example}"',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        fontStyle: FontStyle.italic),
                                    textAlign: TextAlign.center),
                              ]
                            : [
                                Text(word.word,
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: color),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                Text(word.pronunciation,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textGrey)),
                                const SizedBox(height: 20),
                                const Text('Chạm để xem nghĩa 👆',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey)),
                              ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Nút đánh dấu đã thuộc
          GestureDetector(
            onTap: () => app.toggleWordMastered(word.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isMastered
                    ? AppColors.primaryGreen.withOpacity(0.12)
                    : AppColors.textGrey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMastered
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color: isMastered
                        ? AppColors.primaryGreen
                        : AppColors.textGrey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isMastered ? 'Đã thuộc' : 'Đánh dấu đã thuộc',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isMastered
                          ? AppColors.primaryGreen
                          : AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DuoButton(
                  label: 'TRƯỚC',
                  color: AppColors.textGrey,
                  shadowColor: const Color(0xFF555555),
                  onTap: _index == 0
                      ? null
                      : () => setState(() {
                            _index--;
                            _showMeaning = false;
                          }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DuoButton(
                  label:
                      _index == words.length - 1 ? 'HOÀN THÀNH' : 'TIẾP THEO',
                  color: color,
                  shadowColor: AppColors.darkGreen,
                  onTap: () {
                    if (_index == words.length - 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Bạn đã xem hết bộ hình ảnh này 🎉')),
                      );
                    } else {
                      setState(() {
                        _index++;
                        _showMeaning = false;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SentenceArrangeTab extends StatefulWidget {
  final List<Vocabulary> words;
  const _SentenceArrangeTab({required this.words});

  @override
  State<_SentenceArrangeTab> createState() => _SentenceArrangeTabState();
}

class _SentenceArrangeTabState extends State<_SentenceArrangeTab> {
  int _index = 0;
  late List<String> _shuffledTokens;
  late List<String> _selectedTokens;
  bool _checked = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _prepareSentence();
  }

  void _prepareSentence() {
    final word = widget.words[_index];
    final sentence = _extractSentence(word.example, word.word);
    final tokens = sentence
        .replaceAll(RegExp(r'[.,!?]'), '')
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();
    _shuffledTokens = List.of(tokens)..shuffle(Random());
    _selectedTokens = [];
    _checked = false;
    _isCorrect = false;
  }

  String _extractSentence(String example, String word) {
    if (example.trim().isEmpty) {
      return 'I love $word.';
    }
    final match = RegExp(r'([^.!?]+[.!?])').firstMatch(example);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return example.trim();
  }

  void _toggleToken(String token) {
    setState(() {
      if (_selectedTokens.contains(token)) {
        _selectedTokens.remove(token);
        _shuffledTokens.add(token);
      } else if (_shuffledTokens.contains(token)) {
        _shuffledTokens.remove(token);
        _selectedTokens.add(token);
      }
      _checked = false;
    });
  }

  void _checkAnswer() {
    final word = widget.words[_index];
    final sentence = _extractSentence(word.example, word.word);
    final correct = sentence
        .replaceAll(RegExp(r'[.,!?]'), '')
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();
    final answer = List.of(_selectedTokens);
    setState(() {
      _checked = true;
      _isCorrect = answer.length == correct.length &&
          answer
              .asMap()
              .entries
              .every((entry) => entry.value == correct[entry.key]);
    });
  }

  void _nextSentence() {
    if (_index < widget.words.length - 1) {
      setState(() {
        _index++;
        _prepareSentence();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.words[_index];
    final sentence = _extractSentence(word.example, word.word);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Câu ${_index + 1} / ${widget.words.length}',
              style: const TextStyle(
                  color: AppColors.textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_index + 1) / widget.words.length,
              minHeight: 8,
              backgroundColor: AppColors.cardBorder,
              valueColor: const AlwaysStoppedAnimation(AppColors.blue),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sắp xếp câu đúng thứ tự',
                    style:
                        TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 10),
                Text('Dùng từ: "${word.word}"',
                    style: const TextStyle(color: AppColors.textGrey)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedTokens
                      .map((token) => GestureDetector(
                            onTap: () => _toggleToken(token),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(token,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _shuffledTokens
                      .map((token) => GestureDetector(
                            onTap: () => _toggleToken(token),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                    color: AppColors.cardBorder, width: 2),
                              ),
                              child: Text(token,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                if (_checked)
                  Text(
                    _isCorrect
                        ? 'Bạn ghép đúng rồi! 🎉'
                        : 'Câu chưa đúng, hãy thử lại.',
                    style: TextStyle(
                      color:
                          _isCorrect ? AppColors.primaryGreen : AppColors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (_checked && _isCorrect) ...[
                  const SizedBox(height: 10),
                  Text('Câu chính xác: $sentence',
                      style: const TextStyle(color: AppColors.textGrey)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DuoButton(
                  label: 'LÀM LẠI',
                  color: AppColors.textGrey,
                  shadowColor: const Color(0xFF555555),
                  onTap: () => setState(_prepareSentence),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DuoButton(
                  label: _index == widget.words.length - 1
                      ? 'HOÀN THÀNH'
                      : 'KIỂM TRA',
                  color: AppColors.blue,
                  shadowColor: AppColors.darkBlue,
                  onTap: _selectedTokens.isEmpty ? null : _checkAnswer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DuoButton(
            label: 'CHUYỂN NHÓM TIẾP',
            color: AppColors.primaryGreen,
            shadowColor: AppColors.darkGreen,
            onTap: _index == widget.words.length - 1 ? null : _nextSentence,
          ),
        ],
      ),
    );
  }
}

class _AiDialogueTab extends StatefulWidget {
  const _AiDialogueTab();

  @override
  State<_AiDialogueTab> createState() => _AiDialogueTabState();
}

class _AiDialogueTabState extends State<_AiDialogueTab> {
  final _textController = TextEditingController();
  String _dialogue = '';
  bool _isLoading = false;
  String _error = '';

  // TODO: Thay bằng API Key DeepSeek từ https://platform.deepseek.com/api_keys
  static const _apiKey = 'sk-68f37fb858bf44a9afbf0d4240a0b76b';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _generateDialogue() async {
    final term = _textController.text.trim();
    if (term.isEmpty) {
      setState(() => _error = 'Vui lòng nhập một từ tiếng Anh.');
      return;
    }

    setState(() {
      _isLoading = true;
      _dialogue = '';
      _error = '';
    });

    final service = DeepSeekService(apiKey: _apiKey);
    final result = await service.generateDialogue(term);
    setState(() {
      _dialogue = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nhập một từ bất kỳ',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: TextField(
              controller: _textController,
              onSubmitted: (_) => _generateDialogue(),
              decoration: const InputDecoration(
                hintText: 'Nhập từ tiếng Anh...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 18),
          DuoButton(
            label: _isLoading ? 'ĐANG TẠO...' : 'TẠO HỘI THOẠI',
            color: AppColors.primaryGreen,
            shadowColor: AppColors.darkGreen,
            onTap: _isLoading ? null : _generateDialogue,
          ),
          if (_isLoading) ...[
            const SizedBox(height: 18),
            const Center(child: CircularProgressIndicator()),
          ],
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder, width: 2),
              ),
              child: SingleChildScrollView(
                child: _error.isNotEmpty
                    ? Text(_error,
                        style:
                            const TextStyle(color: AppColors.red, height: 1.6))
                    : _dialogue.isEmpty
                        ? const Text(
                            'Nhập một từ tiếng Anh và nhấn "Tạo hội thoại" để AI (DeepSeek) tạo một đoạn hội thoại mẫu.\n\nVí dụ: nhập "travel" rồi nhấn nút.',
                            style: TextStyle(
                                height: 1.6, color: AppColors.textGrey))
                        : Text(_dialogue,
                            style: const TextStyle(
                                height: 1.8,
                                color: AppColors.textDark,
                                fontSize: 15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
