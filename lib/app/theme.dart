// app/theme.dart
// Fleet Owner App matching theme for DravYantra Admin Panel.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTheme {
  AdminTheme._();

  // ── Palette (Clean White & Blue with High-Contrast Slate Borders) ─────────
  static const Color background   = Color(0xFFF1F5F9); // Clean Light Slate (#f1f5f9) - Unchanged
  static const Color surface      = Colors.white;      // Pure White Surface (#ffffff) - Unchanged
  static const Color card         = Colors.white;      // Pure White Card (#ffffff) - Unchanged
  static const Color cardHover    = Color(0xFFF8FAFC); // Hover Slate (#f8fafc)
  static const Color border       = Color(0xFFCBD5E1); // Crisp Slate 300 Border (#cbd5e1) for high visibility

  static const Color primary      = Color(0xFF1D4ED8); // Fleet Owner Brand Blue (#1d4ed8)
  static const Color primaryLight = Color(0xFF2563EB); // Royal Blue (#2563eb)
  static const Color primaryDark  = Color(0xFF1E40AF); // Deep Royal Blue (#1e40af)

  static const Color secondary    = Color(0xFF0284C7); // Cyan Blue (#0284c7)
  static const Color success      = Color(0xFF15803D); // Emerald Green (#15803d)
  static const Color warning      = Color(0xFFB45309); // Amber Warning (#b45309)
  static const Color danger       = Color(0xFFDC2626); // Crimson Red (#dc2626)
  static const Color info         = Color(0xFF1D4ED8); // Info Blue (#1d4ed8)

  static const Color textPrimary  = Color(0xFF0F172A); // Slate 900 Ultra-Dark Text (#0f172a)
  static const Color textSecondary= Color(0xFF334155); // Slate 700 High-Contrast Secondary (#334155)
  static const Color textMuted    = Color(0xFF64748B); // Slate 500 Legible Muted Text (#64748b)

  static const Color sidebarBg    = Color(0xFF0F172A); // Dark Slate Navigation Sidebar (#0f172a)
  static const Color sidebarActive= Color(0xFF1D4ED8); // Royal Blue Active Pill (#1d4ed8)

  // ── Card Elevation Shadow for 3D Separation from BG ──────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

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
        filled:          true,
        fillColor:       surface,
        border:          OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: border, width: 1.2),
        ),
        enabledBorder:   OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: border, width: 1.2),
        ),
        focusedBorder:   OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:   const BorderSide(color: primary, width: 1.8),
        ),
        labelStyle:      const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
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
          elevation: 1,
        ),
      ),
      dividerColor: border,
      iconTheme:    const IconThemeData(color: textSecondary, size: 20),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation:       1,
        shadowColor:     Color(0x0F0F172A),
        titleTextStyle:  TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        iconTheme:       IconThemeData(color: textSecondary),
      ),
    );
  }

  // Alias for backward compatibility
  static ThemeData get darkTheme => lightTheme;
  static ThemeData get theme => lightTheme;
}
