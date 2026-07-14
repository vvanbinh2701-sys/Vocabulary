import 'package:flutter/material.dart';

/// Bảng màu cho Admin Dashboard - phong cách hiện đại, tối giản
class AdminColors {
  AdminColors._();

  // Primary palette
  static const primary = Color(0xFF4CAF50);
  static const primaryLight = Color(0xFF81C784);
  static const primaryDark = Color(0xFF388E3C);

  // Background
  static const background = Color(0xFFF7F8FA);
  static const surface = Colors.white;
  static const sidebarBg = Color(0xFF1E293B);
  static const sidebarHover = Color(0xFF334155);
  static const sidebarActive = Color(0xFF4CAF50);

  // Text
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);
  static const textWhite = Color(0xFFF8FAFC);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Chart colors
  static const chartBlue = Color(0xFF3B82F6);
  static const chartGreen = Color(0xFF22C55E);
  static const chartOrange = Color(0xFFF97316);
  static const chartPurple = Color(0xFFA855F7);
  static const chartPink = Color(0xFFEC4899);

  static const List<Color> chartPalette = [
    chartBlue,
    chartGreen,
    chartOrange,
    chartPurple,
    chartPink,
  ];
}

/// Theme cho Admin Dashboard
class AdminTheme {
  AdminTheme._();

  static ThemeData light(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AdminColors.primary,
        primary: AdminColors.primary,
        secondary: AdminColors.primaryLight,
        surface: AdminColors.surface,
        error: AdminColors.error,
      ),
      scaffoldBackgroundColor: AdminColors.background,
      fontFamily: 'Roboto',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.surface,
        foregroundColor: AdminColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AdminColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: AdminColors.surface,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.06),
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdminColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.error),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: AdminColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AdminColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AdminColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AdminColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          color: AdminColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AdminColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AdminColors.textLight,
        ),
      ),
    );
  }
}

/// Kích thước cố định cho sidebar
class AdminSizes {
  AdminSizes._();

  static const double sidebarWidth = 260;
  static const double sidebarCollapsedWidth = 72;
  static const double appBarHeight = 70;
  static const double cardRadius = 16;
  static const double inputRadius = 12;
}
