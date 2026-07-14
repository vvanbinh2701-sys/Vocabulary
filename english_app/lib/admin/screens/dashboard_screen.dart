import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';
import '../models/admin_models.dart';
import '../widgets/stat_card.dart';

/// Dashboard chính của Admin - tự động refresh stats khi vào màn hình
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh stats mỗi lần vào dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().refreshDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final stats = provider.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting ──
          _buildGreeting(provider),
          const SizedBox(height: 24),

          // ── Stat Cards Row ──
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: [
                  StatCard(
                    title: 'Tổng từ vựng',
                    value: stats.totalVocab,
                    icon: Icons.menu_book_rounded,
                    iconBgColor: AdminColors.chartBlue,
                    iconColor: AdminColors.chartBlue,
                    subtitle: '+12 tuần này',
                  ),
                  StatCard(
                    title: 'Tổng chủ đề',
                    value: stats.totalTopics,
                    icon: Icons.folder_rounded,
                    iconBgColor: AdminColors.chartGreen,
                    iconColor: AdminColors.chartGreen,
                    subtitle: '5 danh mục',
                  ),
                  StatCard(
                    title: 'Tổng người dùng',
                    value: stats.totalUsers,
                    icon: Icons.people_rounded,
                    iconBgColor: AdminColors.chartPurple,
                    iconColor: AdminColors.chartPurple,
                    subtitle: '+3 hôm nay',
                  ),
                  StatCard(
                    title: 'Tổng lượt học',
                    value: stats.totalSessions,
                    icon: Icons.play_circle_rounded,
                    iconBgColor: AdminColors.chartOrange,
                    iconColor: AdminColors.chartOrange,
                    subtitle: '30 ngày qua',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // ── Bottom section: Chart + Activity + Quick Actions ──
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 750;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildChartCard()),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: Column(children: [
                        _buildRecentActivity(),
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                      ]),
                    ),
                  ],
                );
              }
              return Column(children: [
                _buildChartCard(),
                const SizedBox(height: 16),
                _buildRecentActivity(),
                const SizedBox(height: 16),
                _buildQuickActions(),
              ]);
            },
          ),

          const SizedBox(height: 24),

          // ── Top Vocabulary ──
          _buildTopVocabulary(),
        ],
      ),
    );
  }

  Widget _buildGreeting(AdminProvider provider) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AdminColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.admin_panel_settings_rounded,
              color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, ${provider.currentAdmin?.name ?? "Admin"}!',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AdminColors.textPrimary),
              ),
              const SizedBox(height: 2),
              const Text('Đây là tổng quan hệ thống hôm nay',
                  style: TextStyle(
                      fontSize: 13, color: AdminColors.textSecondary)),
            ],
          ),
        ),
        // Nút refresh stats
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AdminColors.textSecondary),
          tooltip: 'Làm mới thống kê',
          onPressed: () => provider.refreshDashboard(),
        ),
      ],
    );
  }

  /// Biểu đồ cột đơn giản (không dùng thư viện ngoài)
  Widget _buildChartCard() {
    final data = [
      _ChartData('T2', 42),
      _ChartData('T3', 58),
      _ChartData('T4', 35),
      _ChartData('T5', 72),
      _ChartData('T6', 65),
      _ChartData('T7', 88),
      _ChartData('CN', 50),
    ];

    final maxValue =
        data.map((d) => d.value).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lượt học theo ngày',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            '7 ngày qua',
            style: TextStyle(fontSize: 12, color: AdminColors.textLight),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                final height = (d.value / maxValue) * 160;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutCubic,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AdminColors.primary,
                                AdminColors.primaryLight
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d.label,
                          style: const TextStyle(
                              fontSize: 11, color: AdminColors.textLight),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Recent Activity
  Widget _buildRecentActivity() {
    final activities = [
      _ActItem('Thêm từ vựng mới', 'admin', '5 phút trước',
          Icons.add_circle_outline, AdminColors.chartGreen),
      _ActItem('Cập nhật chủ đề', 'admin', '12 phút trước', Icons.edit_outlined,
          AdminColors.chartBlue),
      _ActItem('Người dùng mới', 'user1', '28 phút trước',
          Icons.person_add_outlined, AdminColors.chartPurple),
      _ActItem('Hoàn thành bài học', 'user2', '1 giờ trước',
          Icons.check_circle_outline, AdminColors.chartOrange),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hoạt động gần đây',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ...activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: a.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a.icon, color: a.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AdminColors.textPrimary)),
                          Text('${a.user} • ${a.time}',
                              style: const TextStyle(
                                  fontSize: 11, color: AdminColors.textLight)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// Quick Actions
  Widget _buildQuickActions() {
    final actions = [
      _QuickAct('Thêm từ mới', Icons.add_rounded, AdminColors.primary),
      _QuickAct('Thêm chủ đề', Icons.create_new_folder_rounded,
          AdminColors.chartBlue),
      _QuickAct(
          'Xuất báo cáo', Icons.download_rounded, AdminColors.chartPurple),
      _QuickAct('Xem logs', Icons.terminal_rounded, AdminColors.textSecondary),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thao tác nhanh',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminColors.textPrimary),
          ),
          const SizedBox(height: 14),
          ...actions.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(a.icon, color: a.color, size: 18),
                        const SizedBox(width: 10),
                        Text(a.label,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: a.color)),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// Top Vocabulary
  Widget _buildTopVocabulary() {
    final topWords = [
      _TopWord('Beautiful', 'Đẹp', 245),
      _TopWord('Important', 'Quan trọng', 198),
      _TopWord('Experience', 'Kinh nghiệm', 176),
      _TopWord('Knowledge', 'Kiến thức', 154),
      _TopWord('Challenge', 'Thử thách', 132),
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Từ vựng phổ biến nhất',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ...topWords.asMap().entries.map((entry) {
            final i = entry.key;
            final w = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AdminColors.chartPalette[i % 5].withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AdminColors.chartPalette[i % 5]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(w.word,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AdminColors.textPrimary)),
                  ),
                  Text(w.meaning,
                      style: const TextStyle(
                          fontSize: 12, color: AdminColors.textLight)),
                  const SizedBox(width: 16),
                  Text('${w.count}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AdminColors.textSecondary)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Helper data classes ──

class _ChartData {
  final String label;
  final int value;
  _ChartData(this.label, this.value);
}

class _ActItem {
  final String title;
  final String user;
  final String time;
  final IconData icon;
  final Color color;
  _ActItem(this.title, this.user, this.time, this.icon, this.color);
}

class _QuickAct {
  final String label;
  final IconData icon;
  final Color color;
  _QuickAct(this.label, this.icon, this.color);
}

class _TopWord {
  final String word;
  final String meaning;
  final int count;
  _TopWord(this.word, this.meaning, this.count);
}
