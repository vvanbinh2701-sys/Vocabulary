import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../models/app_models.dart';
import 'lesson_detail_screen.dart';

/// Hiển thị khi người dùng nhấn vào đề tài Từ vựng / Hội thoại / Câu.
/// Có thanh tìm kiếm ngay trong màn hình này để lọc nhanh từ/câu mong muốn,
/// đồng thời liệt kê các chủ đề con để người dùng chọn học theo nhóm.
class CategoryTopicsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryTitle;
  const CategoryTopicsScreen(
      {super.key, required this.categoryId, required this.categoryTitle});

  @override
  State<CategoryTopicsScreen> createState() => _CategoryTopicsScreenState();
}

class _CategoryTopicsScreenState extends State<CategoryTopicsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final topics = app.topicsOf(widget.categoryId);

    // Kết quả tìm kiếm trực tiếp trong toàn bộ từ/câu thuộc đề tài này
    final searchResults = _query.isEmpty
        ? <Vocabulary>[]
        : app.sampleVocab
            .where((v) => v.category == widget.categoryId)
            .where((v) =>
                v.word.toLowerCase().contains(_query.toLowerCase()) ||
                v.meaning.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Container(
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
                  hintText:
                      'Tìm trong ${widget.categoryTitle.toLowerCase()}...',
                  hintStyle:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textGrey),
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
          ),
          Expanded(
            child: _query.isNotEmpty
                ? _buildSearchList(searchResults)
                : _buildTopicGrid(context, topics, app),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchList(List<Vocabulary> results) {
    if (results.isEmpty) {
      return const Center(
          child: Text('Không tìm thấy kết quả',
              style: TextStyle(color: AppColors.textGrey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final v = results[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v.word,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 2),
              Text(v.meaning,
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 13)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopicGrid(
      BuildContext context, List<Topic> topics, AppState app) {
    if (topics.isEmpty) {
      return const Center(
          child: Text('Chưa có chủ đề nào',
              style: TextStyle(color: AppColors.textGrey)));
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemCount: topics.length,
      itemBuilder: (context, i) {
        final t = topics[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonDetailScreen(
                categoryId: widget.categoryId,
                topicId: t.id,
                topicTitle: t.title,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.icon, style: const TextStyle(fontSize: 30)),
                const Spacer(),
                Text(t.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${t.itemCount} mục',
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
