import 'package:flutter/material.dart';

/// Bảng màu lấy cảm hứng từ Duolingo: xanh lá tươi, vàng cam, xanh dương,
/// nền sáng, bo góc lớn, đổ bóng nhẹ kiểu "nút bấm 3D".
class AppColors {
  static const primaryGreen = Color(0xFF58CC02);
  static const darkGreen = Color(0xFF58A700);
  static const blue = Color(0xFF1CB0F6);
  static const darkBlue = Color(0xFF1899D6);
  static const yellow = Color(0xFFFFC800);
  static const red = Color(0xFFFF4B4B);
  static const purple = Color(0xFFCE82FF);
  static const orange = Color(0xFFFF9600);
  static const background = Color(0xFFF7F7F7);
  static const cardBorder = Color(0xFFE5E5E5);
  static const textDark = Color(0xFF3C3C3C);
  static const textGrey = Color(0xFF777777);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.blue,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textDark),
        bodyLarge: TextStyle(color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textGrey),
      ),
    );
  }
}

/// Nút bấm kiểu Duolingo: khối màu, viền dưới dày tạo hiệu ứng nổi 3D,
/// khi bấm sẽ "lún" xuống.
class DuoButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color shadowColor;
  final VoidCallback? onTap;
  final IconData? icon;
  final double height;

  const DuoButton({
    super.key,
    required this.label,
    required this.color,
    required this.shadowColor,
    this.onTap,
    this.icon,
    this.height = 54,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: _pressed ? 4 : 0),
        height: widget.height,
        decoration: BoxDecoration(
          color: disabled ? AppColors.cardBorder : widget.color,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            bottom: BorderSide(
              color: disabled
                  ? AppColors.cardBorder
                  : (_pressed ? widget.color : widget.shadowColor),
              width: _pressed ? 0 : 4,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
