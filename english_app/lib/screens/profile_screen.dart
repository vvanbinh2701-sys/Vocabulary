import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/avatar_presets.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'reminder_screen.dart';
import 'security_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final avatar = getAvatarById(app.avatarId);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Hồ sơ',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: avatar != null
                        ? avatar.color.withValues(alpha: 0.15)
                        : AppColors.primaryGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: avatar?.color ?? AppColors.primaryGreen,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      avatar?.emoji ?? '👤',
                      style: const TextStyle(fontSize: 42),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  app.userName ?? 'Khách',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900),
                ),
                Text(
                  app.userEmail ?? '',
                  style: const TextStyle(color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Streak',
                  value: '${app.currentStreak}',
                  icon: Icons.local_fire_department,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: 'Yêu thích',
                  value: '${app.favoriteWordIds.length}',
                  icon: Icons.favorite,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _MenuTile(
            icon: Icons.edit_outlined,
            label: 'Cập nhật thông tin cá nhân',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.security_outlined,
            label: 'Bảo mật',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SecurityScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.notifications_outlined,
            label: 'Thông báo nhắc nhở',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReminderScreen()),
            ),
          ),
          _MenuTile(
            icon: Icons.help_outline,
            label: 'Trợ giúp & Hỗ trợ',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const HelpSupportScreen()),
            ),
          ),
          const SizedBox(height: 12),
          DuoButton(
            label: 'ĐĂNG XUẤT',
            color: AppColors.red,
            shadowColor: const Color(0xFFCC3A3A),
            icon: Icons.logout,
            onTap: () => _logout(context, app),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, AppState app) async {
    await app.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 2),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textDark),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
