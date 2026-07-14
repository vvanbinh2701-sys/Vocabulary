import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'faq_screen.dart';
import 'contact_support_screen.dart';
import 'about_app_screen.dart';
import 'privacy_policy_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp & Hỗ trợ')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _HelpTile(
              icon: Icons.help_outline,
              title: 'FAQ',
              subtitle: 'Câu hỏi thường gặp',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FaqScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _HelpTile(
              icon: Icons.mail_outline,
              title: 'Liên hệ hỗ trợ',
              subtitle: 'Gửi phản hồi qua email',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ContactSupportScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _HelpTile(
              icon: Icons.info_outline,
              title: 'Về ứng dụng',
              subtitle: 'Thông tin ứng dụng',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutAppScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _HelpTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Chính sách bảo mật',
              subtitle: 'Cách dữ liệu người dùng được xử lý',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HelpTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
