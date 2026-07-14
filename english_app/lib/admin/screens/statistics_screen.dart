import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_models.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final vocabs = provider.vocabularies;
    final topics = provider.topics;

    // ---- REAL DATA ----
    // 1. Tu vung theo chu de (bar chart)
    final topicStats = _buildTopicStats(vocabs, topics);

    // 2. Phan bo trinh do (pie chart)
    final levelStats = _buildLevelStats(vocabs);

    // 3. Tong quan categories
    final catStats = _buildCategoryStats(vocabs);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Thong ke he thong', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh_rounded, color: AdminColors.textSecondary), tooltip: 'Lam moi', onPressed: () => provider.refreshDashboard()),
            ]),
            const SizedBox(height: 20),

            if (isWide)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 3, child: _buildBarChart(topicStats)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildPieChart(levelStats)),
              ])
            else ...[
              _buildBarChart(topicStats),
              const SizedBox(height: 20),
              _buildPieChart(levelStats),
            ],
            const SizedBox(height: 20),
            _buildCatBarChart(catStats),
          ]);
        },
      ),
    );
  }

  // ======== DATA BUILDERS ========

  List<_CData> _buildTopicStats(List<Vocabulary> vocabs, List<Topic> topics) {
    final map = <String, int>{};
    for (var v in vocabs) {
      map[v.topicId] = (map[v.topicId] ?? 0) + 1;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(6).toList();
    return top.asMap().entries.map((e) {
      final topic = topics.where((t) => t.id == e.value.key).firstOrNull;
      return _CData(
        topic?.title ?? e.value.key,
        e.value.value,
        AdminColors.chartPalette[e.key % 5],
      );
    }).toList();
  }

  List<_PSegment> _buildLevelStats(List<Vocabulary> vocabs) {
    final map = <String, int>{};
    for (var v in vocabs) {
      final level = v.masteryLevel.isEmpty ? 'Moi' : v.masteryLevel;
      map[level] = (map[level] ?? 0) + 1;
    }
    final total = vocabs.length;
    if (total == 0) return [_PSegment(100, AdminColors.textLight, 'Chua co du lieu')];
    final colors = [AdminColors.chartGreen, AdminColors.chartBlue, AdminColors.chartOrange, AdminColors.chartPurple];
    return map.entries.toList().asMap().entries.map((e) {
      return _PSegment((e.value.value / total) * 100, colors[e.key % 4], e.value.key);
    }).toList();
  }

  List<_CData> _buildCategoryStats(List<Vocabulary> vocabs) {
    final map = <String, int>{};
    for (var v in vocabs) {
      final cat = v.category.isEmpty ? 'Khac' : v.category;
      map[cat] = (map[cat] ?? 0) + 1;
    }
    return map.entries.map((e) => _CData(e.key, e.value, AdminColors.chartPalette[e.key.hashCode.abs() % 5])).toList();
  }

  // ======== CHART WIDGETS ========

  Widget _buildBarChart(List<_CData> data) {
    if (data.isEmpty) return _emptyCard('Tu vung theo chu de', 'Chua co du lieu');
    final maxVal = data.map((d) => d.value).reduce((a, b) => a > b ? a : b).toDouble();
    return _chartContainer(
      title: 'Tu vung theo chu de',
      subtitle: 'Top  chu de nhieu tu nhat',
      child: SizedBox(height: 220,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((d) {
            final h = maxVal > 0 ? (d.value / maxVal) * 170 : 0;
            return Expanded(
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AdminColors.textSecondary)),
                  const SizedBox(height: 4),
                  AnimatedContainer(duration: const Duration(milliseconds: 800), curve: Curves.easeOutCubic, height: h,
                    decoration: BoxDecoration(color: d.color, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 8),
                  Text(d.label, style: const TextStyle(fontSize: 10, color: AdminColors.textLight), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCatBarChart(List<_CData> data) {
    if (data.isEmpty) return _emptyCard('Tu vung theo danh muc', 'Chua co du lieu');
    final maxVal = data.map((d) => d.value).reduce((a, b) => a > b ? a : b).toDouble();
    return _chartContainer(
      title: 'Tu vung theo danh muc',
      subtitle: 'Phan bo tu vung theo category (vocab/phrase/...)',
      child: SizedBox(height: 180,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((d) {
            final h = maxVal > 0 ? (d.value / maxVal) * 140 : 0;
            return Expanded(
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AdminColors.textSecondary)),
                  const SizedBox(height: 6),
                  AnimatedContainer(duration: const Duration(milliseconds: 800), curve: Curves.easeOutCubic, height: h, width: 40,
                    decoration: BoxDecoration(color: d.color, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 8),
                  Text(d.label, style: const TextStyle(fontSize: 11, color: AdminColors.textLight), textAlign: TextAlign.center),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart(List<_PSegment> segments) {
    if (segments.isEmpty) return _emptyCard('Phan bo trinh do', 'Chua co du lieu');
    return _chartContainer(
      title: 'Phan bo trinh do',
      subtitle: 'Ty le tu vung theo muc do thanh thao',
      child: SizedBox(height: 220,
        child: Row(children: [
          Expanded(flex: 3, child: CustomPaint(size: const Size(180, 180), painter: _PieChartPainter(segments: segments))),
          Expanded(flex: 2,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
              children: segments.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _legendDot(e.value.color, e.value.label, '%'),
              )).toList(),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _legendDot(Color color, String label, String pct) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AdminColors.textPrimary))),
      Text(pct, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AdminColors.textSecondary)),
    ]);
  }

  Widget _chartContainer({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AdminColors.textLight)),
        const SizedBox(height: 20),
        child,
      ]),
    );
  }

  Widget _emptyCard(String title, String msg) {
    return Container(
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFF1F5F9))),
      child: Column(children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AdminColors.textPrimary)),
        const SizedBox(height: 20),
        Icon(Icons.bar_chart_rounded, size: 48, color: AdminColors.textLight.withOpacity(0.4)),
        const SizedBox(height: 8),
        Text(msg, style: const TextStyle(color: AdminColors.textLight)),
      ]),
    );
  }
}

// ---- DATA ----
class _CData { final String label; final int value; final Color color; _CData(this.label, this.value, this.color); }
class _PSegment { final double percent; final Color color; final String label; _PSegment(this.percent, this.color, this.label); }

// ---- PAINTERS ----
class _PieChartPainter extends CustomPainter {
  final List<_PSegment> segments;
  _PieChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    double startAngle = -pi / 2;
    for (var seg in segments) {
      final sweep = (seg.percent / 100) * 2 * pi;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, true, Paint()..color = seg.color..style = PaintingStyle.fill);
      startAngle += sweep;
    }
    canvas.drawCircle(center, radius * 0.55, Paint()..color = Colors.white..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
