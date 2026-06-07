import 'package:flutter/material.dart';

// ── Theme-aware color set (light ↔ dark) ─────────────────────────────────────
class AppColors extends ThemeExtension<AppColors> {
  final Color bg;
  final Color card;
  final Color surface;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  const AppColors({
    required this.bg,
    required this.card,
    required this.surface,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  static const AppColors light = AppColors(
    bg: Color(0xFFFAFAF8),
    card: Color(0xFFFFFFFF),
    surface: Color(0xFFF3F4F6),
    divider: Color(0xFFE5E7EB),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9CA3AF),
  );

  static const AppColors dark = AppColors(
    bg: Color(0xFF0F1117),
    card: Color(0xFF1C1E2B),
    surface: Color(0xFF252736),
    divider: Color(0xFF2E3048),
    textPrimary: Color(0xFFEEEEF5),
    textSecondary: Color(0xFF9B9BB5),
    textTertiary: Color(0xFF6B6B85),
  );

  @override
  AppColors copyWith({
    Color? bg, Color? card, Color? surface, Color? divider,
    Color? textPrimary, Color? textSecondary, Color? textTertiary,
  }) => AppColors(
    bg: bg ?? this.bg,
    card: card ?? this.card,
    surface: surface ?? this.surface,
    divider: divider ?? this.divider,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
  );

  @override
  AppColors lerp(AppColors other, double t) => AppColors(
    bg: Color.lerp(bg, other.bg, t)!,
    card: Color.lerp(card, other.card, t)!,
    surface: Color.lerp(surface, other.surface, t)!,
    divider: Color.lerp(divider, other.divider, t)!,
    textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
  );
}

// Convenience extension — dùng context.colors.bg thay vì AppTheme.lightBg
extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

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
    extensions: const [AppColors.light],
  );

  // ── Dark theme ───────────────────────────────────────
  static const Color darkBg = Color(0xFF0F1117);
  static const Color darkCard = Color(0xFF1C1E2B);
  static const Color darkSurface = Color(0xFF252736);
  static const Color darkDivider = Color(0xFF2E3048);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: darkBg,
    cardColor: darkCard,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBg,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
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
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white60),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? primary : Colors.white38,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? primary.withValues(alpha: 0.4)
            : Colors.white12,
      ),
    ),
    dividerColor: darkDivider,
    extensions: const [AppColors.dark],
  );
}
