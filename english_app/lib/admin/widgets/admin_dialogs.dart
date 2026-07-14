import 'package:flutter/material.dart';
import '../../models/app_models.dart';
import '../theme/admin_theme.dart';

/// Dialog thêm / sửa từ vựng
class VocabularyDialog extends StatefulWidget {
  final Vocabulary? vocab; // null = thêm mới, có = sửa
  final List<Topic> topics; // danh sách chủ đề để chọn

  const VocabularyDialog({super.key, this.vocab, required this.topics});

  /// Mở dialog, trả về Vocabulary nếu OK, null nếu Cancel
  static Future<Vocabulary?> show(BuildContext context,
      {Vocabulary? vocab, required List<Topic> topics}) {
    return showDialog<Vocabulary>(
      context: context,
      builder: (_) => VocabularyDialog(vocab: vocab, topics: topics),
    );
  }

  @override
  State<VocabularyDialog> createState() => _VocabularyDialogState();
}

class _VocabularyDialogState extends State<VocabularyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _wordCtrl;
  late final TextEditingController _meaningCtrl;
  late final TextEditingController _pronCtrl;
  late final TextEditingController _exampleCtrl;
  late final TextEditingController _exampleViCtrl;
  String _selectedTopicId = '';
  bool get isEdit => widget.vocab != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vocab;
    _wordCtrl = TextEditingController(text: v?.word ?? '');
    _meaningCtrl = TextEditingController(text: v?.meaning ?? '');
    _pronCtrl = TextEditingController(text: v?.pronunciation ?? '');
    _exampleCtrl = TextEditingController(text: v?.example ?? '');
    _exampleViCtrl = TextEditingController(text: v?.exampleVi ?? '');
    _selectedTopicId =
        v?.topicId ?? (widget.topics.isNotEmpty ? widget.topics.first.id : '');
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _pronCtrl.dispose();
    _exampleCtrl.dispose();
    _exampleViCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEdit ? '✏️ Sửa từ vựng' : '➕ Thêm từ vựng mới',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('Từ tiếng Anh', _wordCtrl, 'VD: Beautiful',
                    Icons.text_fields),
                const SizedBox(height: 14),
                _field('Nghĩa tiếng Việt', _meaningCtrl, 'VD: Đẹp',
                    Icons.translate),
                const SizedBox(height: 14),
                _field('Phiên âm', _pronCtrl, 'VD: /ˈbjuːtɪfl/',
                    Icons.record_voice_over),
                const SizedBox(height: 14),
                _field('Ví dụ', _exampleCtrl, 'VD: She is beautiful',
                    Icons.format_quote,
                    maxLines: 2),
                const SizedBox(height: 14),
                _field('Ví dụ tiếng Việt', _exampleViCtrl, 'VD: Cô ấy thật đẹp',
                    Icons.format_quote,
                    maxLines: 2),
                const SizedBox(height: 14),
                // Chọn chủ đề
                DropdownButtonFormField<String>(
                  value: _selectedTopicId.isNotEmpty ? _selectedTopicId : null,
                  decoration: _inputDeco('Chủ đề', Icons.folder_rounded),
                  items: widget.topics
                      .map((t) => DropdownMenuItem(
                          value: t.id, child: Text('${t.icon} ${t.title}')))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTopicId = v ?? ''),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Chọn chủ đề' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final vocab = Vocabulary(
      id: widget.vocab?.id ?? 'vocab_${DateTime.now().millisecondsSinceEpoch}',
      word: _wordCtrl.text.trim(),
      meaning: _meaningCtrl.text.trim(),
      pronunciation: _pronCtrl.text.trim(),
      example: _exampleCtrl.text.trim(),
      exampleVi: _exampleViCtrl.text.trim().isEmpty
          ? null
          : _exampleViCtrl.text.trim(),
      category: 'vocab',
      topicId: _selectedTopicId,
      masteryLevel: widget.vocab?.masteryLevel ?? 'Mới',
      imageUrl: widget.vocab?.imageUrl,
    );

    Navigator.pop(context, vocab);
  }

  Widget _field(
      String label, TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: _inputDeco(label, icon).copyWith(hintText: hint),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Không được để trống' : null,
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
    );
  }
}

/// Dialog thêm / sửa chủ đề
class TopicDialog extends StatefulWidget {
  final Topic? topic;

  const TopicDialog({super.key, this.topic});

  static Future<Topic?> show(BuildContext context, {Topic? topic}) {
    return showDialog<Topic>(
      context: context,
      builder: (_) => TopicDialog(topic: topic),
    );
  }

  @override
  State<TopicDialog> createState() => _TopicDialogState();
}

class _TopicDialogState extends State<TopicDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _descCtrl;
  bool get isEdit => widget.topic != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.topic?.title ?? '');
    _iconCtrl = TextEditingController(text: widget.topic?.icon ?? '📚');
    _descCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _iconCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEdit ? '✏️ Sửa chủ đề' : '➕ Thêm chủ đề mới',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Tên chủ đề',
                    prefixIcon: Icon(Icons.title, size: 20)),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _iconCtrl,
                decoration: const InputDecoration(
                    labelText: 'Icon (emoji)',
                    prefixIcon: Icon(Icons.emoji_emotions, size: 20),
                    hintText: 'VD: 📚'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Không được để trống'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'Mô tả (tùy chọn)',
                    prefixIcon: Icon(Icons.description, size: 20)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Cập nhật' : 'Thêm mới'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final topic = Topic(
      id: widget.topic?.id ?? 'topic_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: widget.topic?.categoryId ?? 'vocab',
      title: _titleCtrl.text.trim(),
      icon: _iconCtrl.text.trim(),
      itemCount: widget.topic?.itemCount ?? 0,
    );

    Navigator.pop(context, topic);
  }
}
