import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'welcome_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final app = context.read<AppState>();
    final email = app.userEmail;

    if (email == null || email.isEmpty) {
      if (!mounted) return;
      _showError('Không tìm thấy email người dùng.');
      return;
    }

    try {
      await app.changePassword(
        email: email,
        currentPassword: _currentPassCtrl.text,
        newPassword: _newPassCtrl.text,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      // Thành công → dialog + sign out
      await _showSuccessAndSignOut();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(_mapChangePasswordError(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(e.toString());
    }
  }

  String _mapChangePasswordError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mật khẩu hiện tại không đúng.';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu.';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại.';
      case 'network-request-failed':
        return 'Không có kết nối Internet.';
      case 'too-many-requests':
        return 'Thử lại sau ít phút.';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  Future<void> _showSuccessAndSignOut() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('✅'),
            SizedBox(width: 8),
            Text('Thành công',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            'Mật khẩu đã được thay đổi.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    // Đăng xuất và về màn hình chào
    await context.read<AppState>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('❌'),
            SizedBox(width: 8),
            Text('Lỗi', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(message),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mật khẩu hiện tại
              const Text(
                'Mật khẩu hiện tại',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _currentPassCtrl,
                obscureText: _obscureCurrent,
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại' : null,
                decoration: _inputDecoration(
                  hint: 'Nhập mật khẩu hiện tại',
                  suffix: IconButton(
                    icon: Icon(
                      _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mật khẩu mới
              const Text(
                'Mật khẩu mới',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                  if (value.length < 8) return 'Mật khẩu phải có ít nhất 8 ký tự';
                  return null;
                },
                decoration: _inputDecoration(
                  hint: 'Nhập mật khẩu mới (tối thiểu 8 ký tự)',
                  suffix: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Xác nhận mật khẩu mới
              const Text(
                'Xác nhận mật khẩu mới',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: _obscureConfirm,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu mới';
                  if (value != _newPassCtrl.text) return 'Mật khẩu xác nhận không khớp';
                  return null;
                },
                decoration: _inputDecoration(
                  hint: 'Nhập lại mật khẩu mới',
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Nút đổi mật khẩu
              DuoButton(
                label: _loading ? 'Đang xử lý...' : 'ĐỔI MẬT KHẨU',
                color: AppColors.primaryGreen,
                shadowColor: AppColors.darkGreen,
                onTap: _loading ? null : _changePassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required Widget suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cardBorder, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.cardBorder, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffix,
    );
  }
}
