// app/theme.dart
// Fleet Owner App matching theme for DravYantra Admin Panel.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  AdminTheme._();

  // ── Palette (Clean White & Blue with High-Contrast Slate Borders) ─────────
  static const Color background   = Color(0xFFF1F5F9);
  static const Color surface      = Colors.white;
  static const Color card         = Colors.white;
  static const Color cardHover    = Color(0xFFF8FAFC);
  static const Color border       = Color(0xFFCBD5E1);

  static const Color primary      = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDark  = Color(0xFF1E40AF);

  static const Color secondary    = Color(0xFF0284C7);
  static const Color success      = Color(0xFF15803D);
  static const Color warning      = Color(0xFFB45309);
  static const Color danger       = Color(0xFFDC2626);
  static const Color info         = Color(0xFF1D4ED8);

  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF334155);
  static const Color textMuted     = Color(0xFF64748B);

  static const Color sidebarBg     = Color(0xFF0F172A);
  static const Color sidebarActive = Color(0xFF1D4ED8);

  // ── Dark Mode Palette ─────────────────────────────────────────────────────
  static const Color darkBackground   = Color(0xFF0A0F1E);
  static const Color darkSurface      = Color(0xFF111827);
  static const Color darkCard         = Color(0xFF1F2937);
  static const Color darkBorder       = Color(0xFF374151);
  static const Color darkTextPrimary  = Color(0xFFF1F5F9);
  static const Color darkTextSecondary= Color(0xFF94A3B8);
  static const Color darkTextMuted    = Color(0xFF64748B);

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sidebarGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary:   primary,
        secondary: secondary,
        surface:   surface,
        error:     danger,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor:    textPrimary,
        displayColor: textPrimary,
      ),
      cardTheme: CardTheme(
        color:       card,
        elevation:   2,
        shadowColor: const Color(0xFF0F172A).withOpacity(0.08),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: border, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   surface,
        border:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: border, width: 1.2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: border, width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primary, width: 1.8)),
        labelStyle:  const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        hintStyle:   const TextStyle(color: textMuted),
        prefixIconColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          elevation: 1,
        ),
      ),
      dividerColor: border,
      iconTheme:    const IconThemeData(color: textSecondary, size: 20),
      appBarTheme:  const AppBarTheme(
        backgroundColor: surface,
        elevation:       1,
        shadowColor:     Color(0x0F0F172A),
        titleTextStyle:  TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        iconTheme:       IconThemeData(color: textSecondary),
      ),
    );
  }

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary:   primary,
        secondary: secondary,
        surface:   darkSurface,
        error:     danger,
        onPrimary: Colors.white,
        onSurface: darkTextPrimary,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor:    darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      cardTheme: CardTheme(
        color:       darkCard,
        elevation:   2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:      true,
        fillColor:   darkCard,
        border:      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: darkBorder, width: 1.2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: darkBorder, width: 1.2)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primary, width: 1.8)),
        labelStyle:  const TextStyle(color: darkTextSecondary, fontWeight: FontWeight.w500),
        hintStyle:   const TextStyle(color: darkTextMuted),
        prefixIconColor: darkTextSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          elevation: 1,
        ),
      ),
      dividerColor: darkBorder,
      iconTheme:    const IconThemeData(color: darkTextSecondary, size: 20),
      appBarTheme:  AppBarTheme(
        backgroundColor: darkSurface,
        elevation:       1,
        shadowColor:     Colors.black.withOpacity(0.3),
        titleTextStyle:  const TextStyle(color: darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        iconTheme:       const IconThemeData(color: darkTextSecondary),
      ),
    );
  }

  static ThemeData get theme => lightTheme;
}
