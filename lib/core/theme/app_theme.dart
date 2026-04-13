import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors — Sunshine Learning ─────────────────
  static const Color primary = Color(0xFFFF6B35);      // Cam đỏ năng động
  static const Color secondary = Color(0xFF4ECDC4);    // Teal tươi
  static const Color accent = Color(0xFFFFE66D);       // Vàng rực
  static const Color purple = Color(0xFFA855F7);       // Tím
  static const Color pink = Color(0xFFEC4899);         // Hồng
  static const Color green = Color(0xFF22C55E);        // Xanh lá
  static const Color blue = Color(0xFF3B82F6);         // Xanh dương

  // ── Background / Surface ─────────────────────────────
  static const Color lightBg = Color(0xFFFAFAF8);      // Nền kem sáng
  static const Color cardBg = Color(0xFFFFFFFF);       // Card trắng
  static const Color surfaceColor = Color(0xFFF3F4F6); // Surface xám nhạt
  static const Color dividerColor = Color(0xFFE5E7EB); // Divider xám

  // ── Text ─────────────────────────────────────────────
  static const Color textDark = Color(0xFF1A1A2E);     // Text đậm
  static const Color textMedium = Color(0xFF6B7280);   // Text vừa
  static const Color textLight = Color(0xFF9CA3AF);    // Text nhạt

  // ── Gradients ────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFE66D), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // List gradient tuần hoàn cho deck cards
  static const List<LinearGradient> deckGradients = [
    primaryGradient,
    tealGradient,
    purpleGradient,
    yellowGradient,
    greenGradient,
  ];

  // List màu icon deck
  static const List<Color> deckIconColors = [
    Color(0xFFFF6B35),
    Color(0xFF4ECDC4),
    Color(0xFFA855F7),
    Color(0xFFFFE66D),
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
  ];

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: lightBg,
    cardColor: cardBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: textMedium),
      hintStyle: const TextStyle(color: textLight),
    ),
  );

  // Giữ darkTheme để không break code cũ, nhưng redirect về light
  static ThemeData get darkTheme => lightTheme;
}
