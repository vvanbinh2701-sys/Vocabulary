import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/admin_theme.dart';
import '../providers/admin_provider.dart';
import 'admin_main_screen.dart';

/// Màn hình đăng nhập admin - chỉ cho phép role=admin
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AdminProvider>();
    final success = await provider.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        (route) => false,
      );
    } else if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AdminColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                padding: EdgeInsets.all(isSmall ? 28 : 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Logo + Title ──
                      _buildHeader(isSmall),
                      const SizedBox(height: 36),

                      // ── Email field ──
                      _buildLabel('Email'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Vui lòng nhập email';
                          if (!v.contains('@')) return 'Email không hợp lệ';
                          return null;
                        },
                        decoration: _inputDeco(
                            'admin@example.com', Icons.email_outlined),
                      ),
                      const SizedBox(height: 18),

                      // ── Password field ──
                      _buildLabel('Mật khẩu'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Vui lòng nhập mật khẩu'
                            : null,
                        decoration: _inputDeco('••••••••', Icons.lock_outlined)
                            .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            color: AdminColors.textLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Login button ──
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _handleLogin,
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Đăng nhập Admin',
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ),

                      // ── Error ──
                      if (provider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AdminColors.error.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AdminColors.error.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AdminColors.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.errorMessage!,
                                  style: const TextStyle(
                                      color: AdminColors.error, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      // ── Footer ──
                      Text(
                        '🔐 Chỉ tài khoản có quyền Admin mới được truy cập',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AdminColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AdminColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.admin_panel_settings_rounded,
              color: AdminColors.primary, size: 34),
        ),
        const SizedBox(height: 18),
        Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: isSmall ? 22 : 26,
            fontWeight: FontWeight.w800,
            color: AdminColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Quản trị hệ thống học từ vựng',
          style: TextStyle(
            fontSize: 14,
            color: AdminColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AdminColors.textPrimary,
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AdminColors.textLight),
    );
  }
}
