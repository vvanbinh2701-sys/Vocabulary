import 'package:flutter/material.dart';
import '../theme/admin_theme.dart';

/// Card thống kê cho Dashboard
class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconBgColor = AdminColors.primaryLight,
    this.iconColor = AdminColors.primary,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          // ── Icon ──
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 16),

          // ── Text ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AdminColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatNumber(value),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AdminColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AdminColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Arrow indicator ──
          const Icon(Icons.chevron_right_rounded,
              color: AdminColors.textLight, size: 18),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      return '${k.toStringAsFixed(k < 10 ? 1 : 0)}k';
    }
    return n.toString();
  }
}
