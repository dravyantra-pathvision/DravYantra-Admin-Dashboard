// app/theme.dart
// Premium dark admin theme for DravYantra Admin Panel.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  AdminTheme._();

  // ── Palette ──────────────────────────────────────────────────────────────────
  static const Color background   = Color(0xFF0A0D14);
  static const Color surface      = Color(0xFF12161F);
  static const Color card         = Color(0xFF1A1F2E);
  static const Color cardHover    = Color(0xFF1E2438);
  static const Color border       = Color(0xFF252D40);

  static const Color primary      = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark  = Color(0xFF4F46E5);

  static const Color secondary    = Color(0xFF06B6D4); // Cyan
  static const Color success      = Color(0xFF10B981); // Emerald
  static const Color warning      = Color(0xFFF59E0B); // Amber
  static const Color danger       = Color(0xFFEF4444); // Red
  static const Color info         = Color(0xFF3B82F6); // Blue

  static const Color textPrimary  = Color(0xFFF1F5F9);
  static const Color textSecondary= Color(0xFF94A3B8);
  static const Color textMuted    = Color(0xFF475569);

  static const Color sidebarBg    = Color(0xFF0D1017);
  static const Color sidebarActive= Color(0xFF1A1F2E);

  // ── Gradients ────────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF0D1017), Color(0xFF0F1520)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Theme ────────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary:   primary,
        secondary: secondary,
        surface:   surface,
        error:     danger,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor:    textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: const CardTheme(
        color:     card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:          true,
        fillColor:       surface,
        border:          OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: border),
        ),
        enabledBorder:   OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: border),
        ),
        focusedBorder:   OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle:      const TextStyle(color: textSecondary),
        hintStyle:       const TextStyle(color: textMuted),
        prefixIconColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      dividerColor: border,
      iconTheme:    const IconThemeData(color: textSecondary, size: 20),
      appBarTheme: const AppBarTheme(
        backgroundColor: sidebarBg,
        elevation:       0,
        titleTextStyle:  TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        iconTheme:       IconThemeData(color: textSecondary),
      ),
    );
  }
}
