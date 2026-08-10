// app/theme.dart
// Fleet Owner App matching theme for DravYantra Admin Panel.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  AdminTheme._();

  // ── Palette (100% Matched with Fleet Owner App) ──────────────────────────────
  static const Color background   = Color(0xFFF1F5F9); // Clean Light Slate (#f1f5f9)
  static const Color surface      = Colors.white;      // Pure White Card Surface (#ffffff)
  static const Color card         = Colors.white;      // Pure White Card (#ffffff)
  static const Color cardHover    = Color(0xFFF8FAFC); // Hover Slate (#f8fafc)
  static const Color border       = Color(0xFFE2E8F0); // Light Slate Border (#e2e8f0)

  static const Color primary      = Color(0xFF1D4ED8); // Fleet Owner Brand Blue (#1d4ed8)
  static const Color primaryLight = Color(0xFF3B82F6); // Sky Blue (#3b82f6)
  static const Color primaryDark  = Color(0xFF1E40AF); // Deep Royal Blue (#1e40af)

  static const Color secondary    = Color(0xFF0284C7); // Cyan Blue (#0284c7)
  static const Color success      = Color(0xFF16A34A); // Emerald Green (#16a34a)
  static const Color warning      = Color(0xFFD97706); // Amber Warning (#d97706)
  static const Color danger       = Color(0xFFDC2626); // Crimson Red (#dc2626)
  static const Color info         = Color(0xFF2563EB); // Info Blue (#2563eb)

  static const Color textPrimary  = Color(0xFF0F172A); // Slate 900 Text (#0f172a)
  static const Color textSecondary= Color(0xFF475569); // Slate 600 Text (#475569)
  static const Color textMuted    = Color(0xFF94A3B8); // Slate 400 Text (#94a3b8)

  static const Color sidebarBg    = Color(0xFF0F172A); // Dark Slate Navigation Sidebar (#0f172a)
  static const Color sidebarActive= Color(0xFF1D4ED8); // Royal Blue Active Pill (#1d4ed8)

  // ── Gradients ────────────────────────────────────────────────────────────────
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

  // ── Theme Definition ─────────────────────────────────────────────────────────
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
        backgroundColor: surface,
        elevation:       0,
        titleTextStyle:  TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        iconTheme:       IconThemeData(color: textSecondary),
      ),
    );
  }

  // Alias for backward compatibility
  static ThemeData get darkTheme => lightTheme;
  static ThemeData get theme => lightTheme;
}
