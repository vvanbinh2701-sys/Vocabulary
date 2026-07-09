import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo / linh vật minh hoạ bằng icon tròn nổi bật
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkGreen.withOpacity(0.3),
                      blurRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.translate_rounded, size: 72, color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'EngMaster',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Học tiếng Anh mỗi ngày,\nvui như chơi game!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white, height: 1.4),
              ),
              const Spacer(flex: 3),
              DuoButton(
                label: 'BẮT ĐẦU NGAY',
                color: Colors.white,
                shadowColor: const Color(0xFFE2E2E2),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                height: 56,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.darkGreen.withOpacity(0.25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'TÔI ĐÃ CÓ TÀI KHOẢN',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
