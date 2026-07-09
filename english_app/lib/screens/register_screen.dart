import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'home_shell.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await context.read<AppState>().register(
            _nameCtrl.text.trim(),
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _showError(_firebaseMessage(e));
    } catch (_) {
      _showError('Không thể tạo tài khoản. Vui lòng thử lại.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email này đã có tài khoản.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Hãy dùng ít nhất 6 ký tự.';
      case 'network-request-failed':
        return 'Không có kết nối mạng.';
      default:
        return e.message ?? 'Đăng ký thất bại.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bắt đầu hành trình của bạn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tạo tài khoản miễn phí để lưu tiến độ học',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
                decoration: _decoration('Họ và tên', Icons.person_outline),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) return 'Vui lòng nhập email';
                  if (!email.contains('@')) return 'Email không hợp lệ';
                  return null;
                },
                decoration: _decoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                validator: (value) {
                  final password = value ?? '';
                  if (password.isEmpty) return 'Vui lòng nhập mật khẩu';
                  if (password.length < 6) {
                    return 'Mật khẩu cần ít nhất 6 ký tự';
                  }
                  return null;
                },
                decoration: _decoration(
                  'Mật khẩu',
                  Icons.lock_outline,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textGrey,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              DuoButton(
                label: _loading ? 'ĐANG ĐĂNG KÝ...' : 'ĐĂNG KÝ',
                color: AppColors.primaryGreen,
                shadowColor: AppColors.darkGreen,
                onTap: _loading ? null : _register,
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: _loading
                      ? null
                      : () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          ),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                      children: [
                        TextSpan(text: 'Đã có tài khoản? '),
                        TextSpan(
                          text: 'Đăng nhập',
                          style: TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.textGrey),
      suffixIcon: suffix,
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
        borderSide: const BorderSide(color: AppColors.blue, width: 2),
      ),
    );
  }
}
