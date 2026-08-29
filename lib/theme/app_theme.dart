import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Palette ──────────────────────────────────────────────────────────
  static const Color primaryGreen   = Color(0xFF05B257);
  static const Color tealAccent     = Color(0xFF007A87);
  static const Color darkNavy       = Color(0xFF0D1B2A);
  static const Color midBlue        = Color(0xFF1A3050);
  static const Color surfaceLight   = Color(0xFFF0F4F8);
  static const Color cardWhite      = Color(0xFFFFFFFF);
  static const Color textPrimary    = Color(0xFF0D1B2A);
  static const Color textSecondary  = Color(0xFF5A6878);
  static const Color borderColor    = Color(0xFFE2E8F0);
  static const Color shimmerBase    = Color(0xFFE8EEF4);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // ── Category Colors ────────────────────────────────────────────────────────
  static const Map<String, Color> categoryColors = {
    'Certificats':          Color(0xFF05B257),
    'Signature':            Color(0xFF007A87),
    'Identité Numérique':   Color(0xFF6366F1),
    'Horodatage':           Color(0xFFF59E0B),
    'Authentification':     Color(0xFFEF4444),
    'PKI':                  Color(0xFF8B5CF6),
  };

  static Color categoryColor(String cat) =>
      categoryColors[cat] ?? primaryGreen;

  // ── Solution Colors ────────────────────────────────────────────────────────
  static const Color tunsignColor  = Color(0xFF05B257);
  static const Color cevColor      = Color(0xFF007A87);
  static const Color digigoColor   = Color(0xFF6366F1);
  static const Color tunstampColor = Color(0xFFF59E0B);

  static const Map<String, Color> solutionColors = {
    'tunsign':  tunsignColor,
    'cev':      cevColor,
    'digigo':   digigoColor,
    'tunstamp': tunstampColor,
  };

  static Color solutionColor(String key) =>
      solutionColors[key.toLowerCase()] ?? primaryGreen;

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryGreen, tealAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkHeroGradient = LinearGradient(
    colors: [darkNavy, midBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient categoryGradient(String cat) => LinearGradient(
    colors: [categoryColor(cat), categoryColor(cat).withOpacity(0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient solutionGradient(String key) {
    final c = solutionColor(key);
    return LinearGradient(
      colors: [c, c.withOpacity(0.72)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static const LinearGradient aboutGradient = LinearGradient(
    colors: [Color(0xFF0D1B2A), Color(0xFF1A3050), Color(0xFF05B257)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  // ── Shadows ────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: darkNavy.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get heroBannerShadow => [
    BoxShadow(
      color: primaryGreen.withOpacity(0.25),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> solutionCardShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.22),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Glass Decoration ───────────────────────────────────────────────────────
  static BoxDecoration glassDecoration({
    Color? tint,
    double opacity = 0.12,
    double borderRadius = 20,
  }) =>
      BoxDecoration(
        color: (tint ?? Colors.white).withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.0,
        ),
      );

  // ── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get light {
    final cs = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: tealAccent,
      surface: cardWhite,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      surfaceContainerLow: surfaceLight,
      surfaceContainerHighest: const Color(0xFFE2E8F0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: surfaceLight,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge:  GoogleFonts.inter(fontSize: 34, fontWeight: FontWeight.w800, color: textPrimary),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
        headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
        headlineSmall:  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleLarge:  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        titleSmall:  GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
        bodyLarge:   GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary, height: 1.6),
        bodyMedium:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary, height: 1.5),
        bodySmall:   GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary, height: 1.4),
        labelLarge:  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1),
        labelSmall:  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardWhite,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primaryGreen.withOpacity(0.12),
        checkmarkColor: primaryGreen,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: const BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primaryGreen, width: 1.5)),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: textSecondary),
      ),
      dividerTheme: const DividerThemeData(color: borderColor, thickness: 1, space: 1),
    );
  }
}
