import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_sidebar.dart';
import '../models/admin_models.dart';

// Import tất cả màn hình con
import 'dashboard_screen.dart';
import 'vocabulary_screen.dart';
import 'topics_screen.dart';
import 'images_screen.dart';
import 'users_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

/// Shell chính của Admin Dashboard: Sidebar + AppBar + Nội dung
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final _searchCtrl = TextEditingController();

  /// Danh sách màn hình nội dung theo route
  final _screens = <String, Widget>{
    'dashboard': DashboardScreen(),
    'vocabulary': VocabularyScreen(),
    'topics': TopicsScreen(),
    'images': ImagesScreen(),
    'users': UsersScreen(),
    'statistics': StatisticsScreen(),
    'settings': SettingsScreen(),
  };

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final currentScreen =
        _screens[provider.currentRoute] ?? const DashboardScreen();
    final collapsed = provider.sidebarCollapsed;

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Row(
        children: [
          // ── Sidebar ──
          AdminSidebar(collapsed: collapsed),

          // ── Main content ──
          Expanded(
            child: Column(
              children: [
                // ── AppBar ──
                _buildAppBar(provider, collapsed),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),

                // ── Screen content ──
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey(provider.currentRoute),
                      child: currentScreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar với logo nhỏ, search, notification, avatar
  Widget _buildAppBar(AdminProvider provider, bool collapsed) {
    final isWide = MediaQuery.of(context).size.width > 700;

    return Container(
      height: AdminSizes.appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AdminColors.surface,
      child: Row(
        children: [
          // ── Toggle sidebar ──
          Tooltip(
            message:
                collapsed ? 'Nhấn để mở rộng menu' : 'Nhấn để thu gọn menu',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => provider.toggleSidebar(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AdminColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      collapsed ? Icons.menu_rounded : Icons.menu_open_rounded,
                      key: ValueKey(collapsed),
                      color: AdminColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Page title ──
          if (isWide) ...[
            const SizedBox(width: 4),
            Text(
              sidebarItems[provider.selectedSidebarIndex].title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AdminColors.textPrimary,
              ),
            ),
          ],

          const Spacer(),

          // ── Search (hide on narrow) ──
          if (isWide) ...[
            SizedBox(
              width: 260,
              child: TextField(
                controller: _searchCtrl,
                onChanged: provider.setSearchQuery,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: AdminColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],

          // ── Notification ──
          _buildIconBadge(icon: Icons.notifications_outlined, badgeCount: 3),
          const SizedBox(width: 14),

          // ── Admin info ──
          _buildAdminChip(provider, isWide),
        ],
      ),
    );
  }

  /// Icon với badge thông báo
  Widget _buildIconBadge({required IconData icon, required int badgeCount}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AdminColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AdminColors.textSecondary, size: 22),
        ),
        if (badgeCount > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AdminColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Chip hiển thị avatar + tên admin
  Widget _buildAdminChip(AdminProvider provider, bool showName) {
    final admin = provider.currentAdmin;
    final name = admin?.name ?? 'Admin';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AdminColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AdminColors.primary,
            child: Text(
              initial,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
          if (showName) ...[
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down,
                size: 16, color: AdminColors.textLight),
          ],
        ],
      ),
    );
  }
}
