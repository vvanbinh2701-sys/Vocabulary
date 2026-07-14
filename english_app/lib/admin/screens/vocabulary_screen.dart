import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_dialogs.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});
  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int _rowsPerPage = 10;
  int _currentPage = 0;

  List<Vocabulary> get _allRows => context.read<AdminProvider>().vocabularies;

  List<Vocabulary> get _filteredRows {
    final query = context.read<AdminProvider>().searchQuery.toLowerCase();
    if (query.isEmpty) return _allRows;
    return _allRows
        .where((v) =>
            v.word.toLowerCase().contains(query) ||
            v.meaning.toLowerCase().contains(query))
        .toList();
  }

  List<Vocabulary> get _paginatedRows {
    final filtered = _filteredRows;
    final start = _currentPage * _rowsPerPage;
    if (start >= filtered.length) return [];
    return filtered.sublist(
        start, (start + _rowsPerPage).clamp(0, filtered.length));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final filtered = _filteredRows;
    final totalPages =
        filtered.isEmpty ? 1 : (filtered.length / _rowsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildActionBar(provider),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9))),
            child: provider.vocabularies.isEmpty
                ? const Center(
                    child: Text(
                        'Chua co tu vung nao. Nhan \"Them tu moi\" de bat dau.',
                        style: TextStyle(color: AdminColors.textLight)))
                : Column(children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: 700,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFFF8FAFC)),
                              columnSpacing: 24,
                              columns: const [
                                DataColumn(
                                    label: Text('Word', style: _headerStyle)),
                                DataColumn(
                                    label:
                                        Text('Meaning', style: _headerStyle)),
                                DataColumn(
                                    label: Text('Pronunciation',
                                        style: _headerStyle)),
                                DataColumn(
                                    label: Text('Topic', style: _headerStyle)),
                                DataColumn(
                                    label: Text('Level', style: _headerStyle)),
                                DataColumn(
                                    label:
                                        Text('Actions', style: _headerStyle)),
                              ],
                              rows: _paginatedRows
                                  .map((v) => _buildRow(provider, v))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildPagination(totalPages, filtered.length),
                  ]),
          ),
        ),
      ]),
    );
  }

  DataRow _buildRow(AdminProvider provider, Vocabulary v) {
    final topicTitle = provider.topics
            .where((t) => t.id == v.topicId)
            .map((t) => t.title)
            .singleOrNull ??
        v.topicId;
    return DataRow(cells: [
      DataCell(Text(v.word,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
      DataCell(Text(v.meaning,
          style:
              const TextStyle(fontSize: 13, color: AdminColors.textSecondary))),
      DataCell(Text(v.pronunciation,
          style: const TextStyle(fontSize: 12, color: AdminColors.textLight))),
      DataCell(_chip(topicTitle, AdminColors.chartBlue)),
      DataCell(_levelChip(v.masteryLevel)),
      DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.edit_outlined, AdminColors.chartGreen,
            () => _edit(provider, v)),
        const SizedBox(width: 6),
        _btn(Icons.delete_outlined, AdminColors.error,
            () => _delete(provider, v)),
      ])),
    ]);
  }

  Widget _buildActionBar(AdminProvider provider) {
    return Row(children: [
      const Text('Tat ca tu vung',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AdminColors.textPrimary)),
      const SizedBox(width: 10),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: AdminColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Text(' tu',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AdminColors.primary)),
      ),
      const Spacer(),
      ElevatedButton.icon(
        onPressed: provider.isSaving ? null : () => _add(provider),
        icon: provider.isSaving
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.add_rounded, size: 18),
        label: const Text('Them tu moi'),
      ),
    ]);
  }

  Future<void> _add(AdminProvider p) async {
    final r = await VocabularyDialog.show(context, topics: p.topics);
    if (r != null && mounted) {
      await p.addVocabulary(r);
      _showMsg('Da them "${r.word}"');
    }
  }

  Future<void> _edit(AdminProvider p, Vocabulary v) async {
    final r = await VocabularyDialog.show(context, vocab: v, topics: p.topics);
    if (r != null && mounted) {
      await p.updateVocabulary(r);
      _showMsg('Da cap nhat "${r.word}"');
    }
  }

  Future<void> _delete(AdminProvider p, Vocabulary v) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xac nhan xoa'),
        content: Text('Xoa \"\"? Hanh dong nay khong the hoan tac.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Huy')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
              child: const Text('Xoa')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await p.deleteVocabulary(v.id);
      _showMsg('Da xoa "${v.word}"');
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  Widget _btn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 16, color: color)),
    );
  }

  Widget _chip(String t, Color c) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
        child: Text(t,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: c)));
  }

  Widget _levelChip(String l) {
    final c = l == 'Thanh thao'
        ? AdminColors.success
        : l == 'Dang hoc'
            ? AdminColors.warning
            : AdminColors.textLight;
    return _chip(l, c);
  }

  Widget _buildPagination(int totalPages, int totalItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9)))),
      child: Row(children: [
        Text('/',
            style: const TextStyle(fontSize: 12, color: AdminColors.textLight)),
        const Spacer(),
        IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            onPressed:
                _currentPage > 0 ? () => setState(() => _currentPage--) : null),
        Text('/',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            onPressed: _currentPage < totalPages - 1
                ? () => setState(() => _currentPage++)
                : null),
      ]),
    );
  }

  static const _headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AdminColors.textSecondary,
      letterSpacing: 0.3);
}
