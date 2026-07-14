import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/admin_theme.dart';
import '../models/admin_models.dart';
import '../providers/admin_provider.dart';

/// Sidebar cho Admin Dashboard với icon, hover effect, animation
class AdminSidebar extends StatelessWidget {
  final bool collapsed;

  const AdminSidebar({super.key, required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: collapsed
              ? AdminSizes.sidebarCollapsedWidth
              : AdminSizes.sidebarWidth,
          color: AdminColors.sidebarBg,
          child: Column(
            children: [
              // ── Logo area ──
              _buildLogoHeader(collapsed),
              const Divider(color: Color(0xFF334155), height: 1),
              const SizedBox(height: 12),

              // ── Navigation items ──
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  children: [
                    ...List.generate(sidebarItems.length, (i) {
                      return _SidebarNavItem(
                        item: sidebarItems[i],
                        selected: provider.selectedSidebarIndex == i,
                        collapsed: collapsed,
                        onTap: () => provider.selectSidebarItem(i),
                      );
                    }),
                  ],
                ),
              ),

              // ── Logout button ──
              const Divider(color: Color(0xFF334155), height: 1),
              _SidebarNavItem(
                item: const SidebarItem(
                  title: 'Logout',
                  icon: Icons.logout_rounded,
                  route: 'logout',
                ),
                selected: false,
                collapsed: collapsed,
                onTap: () => provider.selectSidebarItem(sidebarItems.length),
                isLogout: true,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        // ── Toggle handle ở cạnh phải sidebar ──
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () => provider.toggleSidebar(),
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: Container(
                width: 4,
                color: Colors.transparent,
                // Hiển thị handle khi hover
                child: Center(
                  child: Container(
                    width: 2,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoHeader(bool collapsed) {
    return Container(
      height: AdminSizes.appBarHeight,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 20),
      child: collapsed
          ? const Center(
              child: Icon(Icons.school_rounded, color: Colors.white, size: 24),
            )
          : Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AdminColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'EngMaster',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AdminColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                        color: AdminColors.primaryLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Một item trong sidebar có hover + animation
class _SidebarNavItem extends StatefulWidget {
  final SidebarItem item;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;
  final bool isLogout;

  const _SidebarNavItem({
    required this.item,
    required this.selected,
    required this.collapsed,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.selected
        ? AdminColors.sidebarActive
        : _hovered
            ? AdminColors.sidebarHover
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 4 : 0,
            vertical: 1,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: widget.collapsed ? 0 : 14,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: widget.collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Tooltip(
                    message: widget.collapsed ? widget.item.title : '',
                    waitDuration: const Duration(milliseconds: 400),
                    child: Icon(
                      widget.item.icon,
                      color: widget.selected
                          ? Colors.white
                          : widget.isLogout
                              ? AdminColors.error.withOpacity(0.8)
                              : const Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ),
                  if (!widget.collapsed) ...[
                    const SizedBox(width: 12),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: widget.selected
                            ? Colors.white
                            : widget.isLogout
                                ? AdminColors.error.withOpacity(0.8)
                                : const Color(0xFFCBD5E1),
                        fontSize: 14,
                        fontWeight:
                            widget.selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      child: Text(widget.item.title),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
