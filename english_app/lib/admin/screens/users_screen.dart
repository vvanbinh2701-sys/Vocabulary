import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';
import '../models/admin_models.dart';

/// Trang quản lý người dùng
class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final users = provider.users;
    final searchQuery = provider.searchQuery.toLowerCase();

    final filtered = searchQuery.isEmpty
        ? users
        : users
            .where((u) =>
                u.name.toLowerCase().contains(searchQuery) ||
                u.email.toLowerCase().contains(searchQuery))
            .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              const Text(
                'Quản lý người dùng',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textPrimary),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AdminColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${users.length} users',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.primary),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => provider.refreshUsers(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Làm mới'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AdminColors.textSecondary,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── User table ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: users.isEmpty
                  ? const Center(
                      child: Text('Chưa có người dùng nào.',
                          style: TextStyle(color: AdminColors.textLight)))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: 750,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                                const Color(0xFFF8FAFC)),
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(
                                  label: Text('Người dùng', style: _hStyle)),
                              DataColumn(label: Text('Email', style: _hStyle)),
                              DataColumn(label: Text('Role', style: _hStyle)),
                              DataColumn(
                                  label: Text('Ngày tạo', style: _hStyle)),
                              DataColumn(
                                  label: Text('Trạng thái', style: _hStyle)),
                              DataColumn(
                                  label: Text('Thao tác', style: _hStyle)),
                            ],
                            rows: filtered
                                .map((u) => _buildUserRow(context, u))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildUserRow(BuildContext context, AdminUser user) {
    final dateStr =
        '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}';
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return DataRow(cells: [
      DataCell(Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:
                user.isAdmin ? AdminColors.primary : AdminColors.chartBlue,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Text(user.name,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      )),
      DataCell(Text(user.email,
          style:
              const TextStyle(fontSize: 13, color: AdminColors.textSecondary))),
      DataCell(_buildRoleBadge(user)),
      DataCell(Text(dateStr,
          style:
              const TextStyle(fontSize: 13, color: AdminColors.textSecondary))),
      DataCell(_buildStatusBadge(user)),
      DataCell(_buildActionPopup(context, user)),
    ]);
  }

  Widget _buildRoleBadge(AdminUser user) {
    final isAdmin = user.isAdmin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAdmin
            ? AdminColors.primary.withOpacity(0.1)
            : AdminColors.chartBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAdmin ? 'Admin' : 'User',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAdmin ? AdminColors.primary : AdminColors.chartBlue,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AdminUser user) {
    final isActive = user.status == 'active';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AdminColors.success : AdminColors.warning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? AdminColors.success : AdminColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildActionPopup(BuildContext context, AdminUser user) {
    final provider = context.read<AdminProvider>();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz_rounded, color: AdminColors.textLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) {
        switch (action) {
          case 'toggle_role':
            provider.updateUserRole(user.uid, user.isAdmin ? 'user' : 'admin');
            break;
          case 'toggle_status':
            provider.updateUserStatus(
                user.uid, user.status == 'active' ? 'inactive' : 'active');
            break;
          case 'delete':
            _showDeleteConfirm(context, user);
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'toggle_role',
          child: Row(
            children: [
              Icon(
                  user.isAdmin
                      ? Icons.arrow_downward_rounded
                      : Icons.admin_panel_settings_rounded,
                  size: 18,
                  color: AdminColors.textSecondary),
              const SizedBox(width: 10),
              Text(user.isAdmin ? 'Hạ xuống User' : 'Nâng lên Admin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_status',
          child: Row(
            children: [
              Icon(
                  user.status == 'active'
                      ? Icons.block_rounded
                      : Icons.check_circle_outline_rounded,
                  size: 18,
                  color: AdminColors.textSecondary),
              const SizedBox(width: 10),
              Text(user.status == 'active' ? 'Vô hiệu hóa' : 'Kích hoạt'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: const Row(
            children: [
              Icon(Icons.delete_outlined, size: 18, color: AdminColors.error),
              SizedBox(width: 10),
              Text('Xóa', style: TextStyle(color: AdminColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, AdminUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa người dùng "${user.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  static const _hStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: AdminColors.textSecondary,
      letterSpacing: 0.3);
}
