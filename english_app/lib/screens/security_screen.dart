import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'change_password_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bảo mật')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _MenuTile(
              icon: Icons.lock_outline,
              label: 'Đổi mật khẩu',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.email_outlined,
              label: 'Đặt lại mật khẩu qua email',
              onTap: () => _showResetPasswordDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showResetPasswordDialog(BuildContext context) async {
    final app = context.read<AppState>();
    final email = app.userEmail;
    if (email == null || email.isEmpty) return;

    // ---- Confirmation dialog ----
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('✉️'),
            SizedBox(width: 8),
            Text('Đặt lại mật khẩu',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Email đặt lại mật khẩu sẽ được gửi đến:'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  email,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nhấn "Gửi email" để nhận đường dẫn đặt lại mật khẩu.',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Gửi email'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // ---- Loading ----
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );

    try {
      await app.sendPasswordResetEmail(email);

      if (!context.mounted) return;
      Navigator.pop(context);

      // ---- Success dialog ----
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('✅'),
              SizedBox(width: 8),
              Text('Thành công',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: SingleChildScrollView(
            child: const Text(
              'Mật khẩu đã được thay đổi.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);

      // ---- Error dialog ----
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text('❌'),
              SizedBox(width: 8),
              Text('Lỗi', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              _mapError(e),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'too-many-requests':
        return 'Thử lại sau ít phút.';
      case 'network-request-failed':
        return 'Không có kết nối Internet.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}

/// Widget menu item dùng chung trong màn hình Security
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
