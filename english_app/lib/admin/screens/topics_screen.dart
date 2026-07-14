import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_dialogs.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final topics = provider.topics;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Tat ca chu de',
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
                child: Text(' chu de',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.primary)),
              ),
            ]),
            const SizedBox(height: 20),
            Expanded(
              child: topics.isEmpty
                  ? const Center(
                      child: Text('Chua co chu de nao.',
                          style: TextStyle(color: AdminColors.textLight)))
                  : LayoutBuilder(
                      builder: (ctx, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1000
                            ? 4
                            : constraints.maxWidth > 700
                                ? 3
                                : constraints.maxWidth > 450
                                    ? 2
                                    : 1;
                        return GridView.builder(
                          itemCount: topics.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85),
                          itemBuilder: (_, i) => _TopicCard(
                            topic: topics[i],
                            onEdit: () =>
                                _editTopic(context, provider, topics[i]),
                            onDelete: () =>
                                _deleteTopic(context, provider, topics[i]),
                          ),
                        );
                      },
                    ),
            ),
          ]),
        ),
        Positioned(
          right: 40,
          bottom: 40,
          child: FloatingActionButton.extended(
            onPressed:
                provider.isSaving ? null : () => _addTopic(context, provider),
            backgroundColor: AdminColors.primary,
            icon: provider.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.add_rounded),
            label: const Text('Them chu de',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  static Future<void> _addTopic(BuildContext context, AdminProvider p) async {
    final r = await TopicDialog.show(context);
    if (r != null && context.mounted) {
      await p.addTopic(r);
      _msg(context, 'Da them "${r.title}"');
    }
  }

  static Future<void> _editTopic(
      BuildContext context, AdminProvider p, Topic t) async {
    final r = await TopicDialog.show(context, topic: t);
    if (r != null && context.mounted) {
      await p.updateTopic(r);
      _msg(context, 'Da cap nhat "${r.title}"');
    }
  }

  static Future<void> _deleteTopic(
      BuildContext context, AdminProvider p, Topic t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xac nhan xoa'),
        content:
            Text('Xoa chu de ""? Tat ca tu vung trong chu de cung se bi xoa.'),
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
    if (ok == true && context.mounted) {
      await p.deleteTopic(t.id);
      _msg(context, 'Da xoa "${t.title}"');
    }
  }

  static void _msg(BuildContext c, String m) {
    ScaffoldMessenger.of(c).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  }
}

class _TopicCard extends StatelessWidget {
  final Topic topic;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TopicCard(
      {required this.topic, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ]),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                      color: AdminColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14)),
                  alignment: Alignment.center,
                  child:
                      Text(topic.icon, style: const TextStyle(fontSize: 24))),
              const SizedBox(height: 14),
              Text(topic.title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(children: [
                Icon(Icons.menu_book_rounded,
                    size: 14, color: AdminColors.primary.withOpacity(0.7)),
                const SizedBox(width: 5),
                Text(' tu',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.primary.withOpacity(0.8))),
                const Spacer(),
                _miniBtn(
                    Icons.edit_outlined, AdminColors.textSecondary, onEdit),
                const SizedBox(width: 4),
                _miniBtn(Icons.delete_outlined, AdminColors.error, onDelete),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _miniBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6)),
          child: Icon(icon, size: 15, color: color)),
    );
  }
}
