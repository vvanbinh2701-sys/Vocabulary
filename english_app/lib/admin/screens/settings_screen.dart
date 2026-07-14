import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';

/// Trang Cài đặt Admin
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  String _language = 'vi';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final admin = provider.currentAdmin;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cài đặt hệ thống',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AdminColors.textPrimary),
              ),
              const SizedBox(height: 24),

              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildProfileSection(admin)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildPasswordSection()),
                  ],
                )
              else ...[
                _buildProfileSection(admin),
                const SizedBox(height: 20),
                _buildPasswordSection(),
              ],

              const SizedBox(height: 20),

              // ── Preferences ──
              _buildPreferencesSection(),
            ],
          );
        },
      ),
    );
  }

  /// Thông tin Admin
  Widget _buildProfileSection(dynamic admin) {
    return _sectionCard(
      title: 'Thông tin Admin',
      icon: Icons.person_rounded,
      children: [
        _infoRow('Tên', admin?.name ?? 'Admin'),
        _infoRow('Email', admin?.email ?? 'admin@example.com'),
        _infoRow('Role', 'Admin', valueColor: AdminColors.primary),
        _infoRow('Số điện thoại', admin?.phone ?? 'Chưa cập nhật'),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: const Text('Chỉnh sửa thông tin'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AdminColors.textSecondary,
            side: BorderSide(color: Colors.grey.shade300),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  /// Đổi mật khẩu
  Widget _buildPasswordSection() {
    return _sectionCard(
      title: 'Đổi mật khẩu',
      icon: Icons.lock_outlined,
      children: [
        const Text('Cập nhật mật khẩu mới để bảo mật tài khoản.',
            style: TextStyle(fontSize: 13, color: AdminColors.textSecondary)),
        const SizedBox(height: 14),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mật khẩu hiện tại',
            prefixIcon: Icon(Icons.lock_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mật khẩu mới',
            prefixIcon: Icon(Icons.lock_reset_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            prefixIcon: Icon(Icons.check_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_rounded, size: 16),
          label: const Text('Đổi mật khẩu'),
        ),
      ],
    );
  }

  /// Tùy chọn: Dark Mode, Language
  Widget _buildPreferencesSection() {
    return _sectionCard(
      title: 'Tùy chọn',
      icon: Icons.tune_rounded,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Dark Mode',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: const Text('Bật giao diện tối',
              style: TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
          value: _darkMode,
          onChanged: (v) => setState(() => _darkMode = v),
          activeColor: AdminColors.primary,
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ngôn ngữ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: const Text('Chọn ngôn ngữ hiển thị',
              style: TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
          trailing: DropdownButton<String>(
            value: _language,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'vi', child: Text('🇻🇳 Tiếng Việt')),
              DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
            ],
            onChanged: (v) => setState(() => _language = v!),
          ),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Thông báo',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: const Text('Nhận thông báo qua email',
              style: TextStyle(fontSize: 12, color: AdminColors.textSecondary)),
          trailing: Switch(
            value: true,
            onChanged: (_) {},
            activeColor: AdminColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AdminColors.textLight)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AdminColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
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
          Row(
            children: [
              Icon(icon, size: 20, color: AdminColors.primary),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AdminColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
