import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color violetPrimary = Color(0xFF6D28D9);
  static const Color violetDark = Color(0xFF5B21B6);
  static const Color tealSuccess = Color(0xFF0D9488);
  static const Color pinkAlert = Color(0xFFDB2777);
  static const Color amberWarning = Color(0xFFD97706);

  static const Color whiteMain = Color(0xFFFFFFFF);
  static const Color greySecondary = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: violetPrimary,
      onPrimary: Colors.white,
      secondary: tealSuccess,
      onSecondary: Colors.white,
      error: pinkAlert,
      onError: Colors.white,
      surface: Color(0xFFF9FAFF),
      onSurface: textDark,
      surfaceContainerHighest: Color(0xFFF1F5F9),
      onSurfaceVariant: textMuted,
      outline: Color(0xFFE2E8F0),
      outlineVariant: Color(0xFFEAEFF7),
      shadow: Color(0x1A0F172A),
      inverseSurface: textDark,
      onInverseSurface: Colors.white,
      tertiary: amberWarning,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFF2E2),
      onTertiaryContainer: Color(0xFF7C2D12),
      primaryContainer: Color(0xFFEDE9FE),
      onPrimaryContainer: Color(0xFF2E1065),
      secondaryContainer: Color(0xFFCCFBF1),
      onSecondaryContainer: Color(0xFF134E4A),
      errorContainer: Color(0xFFFCE7F3),
      onErrorContainer: Color(0xFF831843),
      scrim: Colors.black54,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: Brightness.light);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      cardColor: Colors.white,
      dividerColor: scheme.outlineVariant,
      splashColor: violetPrimary.withOpacity(0.08),
      highlightColor: violetPrimary.withOpacity(0.04),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: scheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurface, textColor: scheme.onSurface),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: violetPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: violetPrimary, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w400),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: scheme.onInverseSurface, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: violetPrimary,
      onPrimary: Colors.white,
      secondary: tealSuccess,
      onSecondary: Colors.white,
      error: Color(0xFFF472B6),
      onError: Color(0xFF4A044E),
      surface: Color(0xFF020617),
      onSurface: Color(0xFFF8FAFC),
      surfaceContainerHighest: Color(0xFF0F172A),
      onSurfaceVariant: Color(0xFF94A3B8),
      outline: Color(0xFF334155),
      outlineVariant: Color(0xFF111827),
      shadow: Colors.black54,
      inverseSurface: Color(0xFFF8FAFC),
      onInverseSurface: Color(0xFF020617),
      tertiary: Color(0xFFF59E0B),
      onTertiary: Color(0xFF3B2200),
      tertiaryContainer: Color(0xFF45300A),
      onTertiaryContainer: Color(0xFFFDE68A),
      primaryContainer: Color(0xFF2E1065),
      onPrimaryContainer: Color(0xFFEDE9FE),
      secondaryContainer: Color(0xFF0F3A35),
      onSecondaryContainer: Color(0xFF99F6E4),
      errorContainer: Color(0xFF500724),
      onErrorContainer: Color(0xFFFBCFE8),
      scrim: Colors.black87,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: Brightness.dark);
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      cardColor: scheme.surfaceContainerHighest,
      dividerColor: scheme.outlineVariant,
      splashColor: violetPrimary.withOpacity(0.12),
      highlightColor: violetPrimary.withOpacity(0.06),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: scheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHighest,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      listTileTheme: ListTileThemeData(iconColor: scheme.onSurface, textColor: scheme.onSurface),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: violetPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(0.9),
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: violetPrimary, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.w400),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: scheme.onSurface, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> get brandShadow => [
        BoxShadow(
          color: violetPrimary.withOpacity(0.20),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ];

  static List<BoxShadow> get cardShadow => softShadow;
  static List<BoxShadow> get premiumShadow => brandShadow;
}
