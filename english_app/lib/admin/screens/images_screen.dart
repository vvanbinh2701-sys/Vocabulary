import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_models.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';

class ImagesScreen extends StatefulWidget {
  const ImagesScreen({super.key});
  @override
  State<ImagesScreen> createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _uploading = false;
  List<_ImageEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final provider = context.read<AdminProvider>();
    final vocabs = provider.vocabularies;
    final entries = vocabs
        .where((v) => v.imageUrl != null && v.imageUrl!.isNotEmpty)
        .map((v) => _ImageEntry(
              vocabId: v.id,
              word: v.word,
              imageUrl: v.imageUrl!,
              topicId: v.topicId,
            ))
        .toList();
    if (mounted) setState(() => _entries = entries);
  }

  Future<void> _pickAndUpload() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploading = true);

    try {
      final fileName =
          'vocab_images/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final ref = _storage.ref(fileName);
      await ref.putFile(File(picked.path));
      final downloadUrl = await ref.getDownloadURL();

      // Mở dialog chọn từ vựng để gán ảnh
      if (mounted) {
        final vocab = await _showVocabPicker();
        if (vocab != null) {
          await _firestore
              .collection('vocabularies')
              .doc(vocab.id)
              .update({'imageUrl': downloadUrl});
          await context.read<AdminProvider>().refreshVocabularies();
          _showMsg('Da upload anh cho "${vocab.word}"');
          _loadImages();
        } else {
          // Khong chon tu vung -> xoa anh vua upload
          await ref.delete();
          _showMsg('Da huy upload');
        }
      }
    } catch (e) {
      _showMsg('Loi upload: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<Vocabulary?> _showVocabPicker() async {
    final provider = context.read<AdminProvider>();
    final vocabs = provider.vocabularies;

    final result = await showDialog<Vocabulary>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Chon tu vung de gan anh'),
        content: SizedBox(
          width: 350,
          height: 400,
          child: vocabs.isEmpty
              ? const Center(child: Text('Chua co tu vung nao'))
              : ListView.builder(
                  itemCount: vocabs.length,
                  itemBuilder: (_, i) {
                    final v = vocabs[i];
                    return ListTile(
                      leading:
                          CircleAvatar(child: Text(v.word[0].toUpperCase())),
                      title: Text(v.word),
                      subtitle: Text(v.meaning),
                      onTap: () => Navigator.pop(ctx, v),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Huy')),
        ],
      ),
    );
    return result;
  }

  Future<void> _deleteImage(_ImageEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xac nhan xoa anh'),
        content: Text('Xoa anh cua tu "${entry.word}"?'),
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
    if (ok != true || !mounted) return;

    try {
      // Xoa URL khoi Firestore
      await _firestore
          .collection('vocabularies')
          .doc(entry.vocabId)
          .update({'imageUrl': FieldValue.delete()});
      // Xoa file khoi Storage (neu co quyen)
      try {
        await _storage.refFromURL(entry.imageUrl).delete();
      } catch (_) {}
      await context.read<AdminProvider>().refreshVocabularies();
      _showMsg('Da xoa anh cua "${entry.word}"');
      _loadImages();
    } catch (e) {
      _showMsg('Loi xoa: $e');
    }
  }

  Future<void> _changeImage(_ImageEntry entry) async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      // Xoa anh cu
      try {
        await _storage.refFromURL(entry.imageUrl).delete();
      } catch (_) {}

      final fileName =
          'vocab_images/${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final ref = _storage.ref(fileName);
      await ref.putFile(File(picked.path));
      final newUrl = await ref.getDownloadURL();

      await _firestore
          .collection('vocabularies')
          .doc(entry.vocabId)
          .update({'imageUrl': newUrl});
      await context.read<AdminProvider>().refreshVocabularies();
      _showMsg('Da cap nhat anh cho "${entry.word}"');
      _loadImages();
    } catch (e) {
      _showMsg('Loi: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showMsg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Quan ly hinh anh',
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
            child: Text('${_entries.length} anh',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.primary)),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _uploading ? null : _pickAndUpload,
            icon: _uploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_upload_outlined, size: 16),
            label: Text(_uploading ? 'Dang tai...' : 'Tai anh len'),
          ),
        ]),
        const SizedBox(height: 20),
        Expanded(
          child: _entries.isEmpty
              ? const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.image_not_supported_outlined,
                      size: 64, color: AdminColors.textLight),
                  SizedBox(height: 12),
                  Text('Chua co anh nao. Nhan "Tai anh len" de them.',
                      style: TextStyle(color: AdminColors.textLight)),
                ]))
              : LayoutBuilder(
                  builder: (ctx, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900
                        ? 4
                        : constraints.maxWidth > 600
                            ? 3
                            : 2;
                    return GridView.builder(
                      itemCount: _entries.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9),
                      itemBuilder: (_, i) => _ImageCard(
                        entry: _entries[i],
                        onEdit: () => _changeImage(_entries[i]),
                        onDelete: () => _deleteImage(_entries[i]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final _ImageEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ImageCard(
      {required this.entry, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(entry.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image,
                        size: 40, color: AdminColors.textLight))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(entry.word,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('Topic: ',
                style: const TextStyle(
                    fontSize: 10, color: AdminColors.textLight)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              _btn(Icons.swap_horiz_rounded, AdminColors.textSecondary, onEdit),
              const SizedBox(width: 4),
              _btn(Icons.delete_outlined, AdminColors.error, onDelete),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _btn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(5)),
          child: Icon(icon, size: 14, color: color)),
    );
  }
}

class _ImageEntry {
  final String vocabId;
  final String word;
  final String imageUrl;
  final String topicId;
  _ImageEntry(
      {required this.vocabId,
      required this.word,
      required this.imageUrl,
      required this.topicId});
}
