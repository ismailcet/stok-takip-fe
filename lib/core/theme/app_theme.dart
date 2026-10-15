import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFF5EAD8);
  static const surface = Color(0xFFEBDDC5);
  static const text = Color(0xFF201E1D);

  static const accent = Color(0xFFC67139);
  static const accentDark = Color(0xFF8C491A);
  static const accentLight = Color(0xFFF6A06B);

  static const accentGreen = Color(0xFF7A8A5E);
  static const accentGreenDark = Color(0xFF56633F);

  // Barkod tarama gibi tam ekran koyu yüzeyler için
  static const scannerBackground = Color(0xFF201E1D);

  // Hata/uyarı durumları (PIN yanlış, barkod okunamadı vb.)
  static const danger = Color(0xFFFF8A80);
  static const dangerDark = Color(0xFF5C2B2E);
}

class AppTheme {
  AppTheme._();

  static const double buttonHeight = 64;

  static ThemeData light() {
    final base = GoogleFonts.figtreeTextTheme();

    final textTheme = base.copyWith(
      headlineLarge: GoogleFonts.figtree(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      headlineMedium: GoogleFonts.figtree(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      headlineSmall: GoogleFonts.figtree(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      titleLarge: GoogleFonts.figtree(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleMedium: GoogleFonts.figtree(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      bodyLarge: GoogleFonts.figtree(
        fontSize: 18,
        height: 1.4,
        color: AppColors.text,
      ),
      bodyMedium: GoogleFonts.figtree(
        fontSize: 16,
        height: 1.4,
        color: AppColors.text,
      ),
      labelLarge: GoogleFonts.figtree(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
        primary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.text,
        foregroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.figtree(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.background,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          minimumSize: const Size.fromHeight(buttonHeight),
          textStyle: GoogleFonts.figtree(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size.fromHeight(buttonHeight),
          side: BorderSide(color: AppColors.text.withOpacity(0.15), width: 2),
          textStyle: GoogleFonts.figtree(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.figtree(
          fontSize: 16,
          color: AppColors.text.withOpacity(0.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.text.withOpacity(0.1), width: 2),
        ),
      ),
    );
  }
}
