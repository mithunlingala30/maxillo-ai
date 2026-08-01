import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central design system for MaxilloAI, mirrored from the Figma spec:
/// White primary background, Medical Blue, Teal accents, soft greys,
/// rounded 20px cards, soft shadows and a dark navy -> blue -> teal
/// gradient used for headers.
class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color navy = Color(0xFF0F172A);
  static const Color deepBlue = Color(0xFF1E3A8A);
  static const Color teal = Color(0xFF14B8A6);
  static const Color tealDark = Color(0xFF0D9488);
  static const Color softGrey = Color(0xFFF8FAFC);
  static const Color background = Color(0xFFF8FAFF);
  static const Color darkText = Color(0xFF334155);
  static const Color heading = Color(0xFF0F172A);
  static const Color subText = Color(0xFF64748B);
  static const Color placeholder = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFEA580C);
  static const Color warningBg = Color(0xFFFFF7ED);
  static const Color risk = Color(0xFFDC2626);
  static const Color riskBg = Color(0xFFFEE2E2);
  static const Color blueBg = Color(0xFFEFF6FF);
  static const Color tealBg = Color(0xFFF0FDFA);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleBg = Color(0xFFF5F3FF);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment(-0.5, -1),
    end: Alignment(0.6, 1),
    colors: [navy, deepBlue, tealDark],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlueDark, primaryBlue],
  );

  static const LinearGradient tealButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealDark, teal],
  );
}

class AppRadius {
  AppRadius._();
  static const double card = 20;
  static const double button = 18;
  static const double sheet = 28;
}

class AppShadows {
  AppShadows._();
  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.28),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        primary: AppColors.primaryBlue,
        secondary: AppColors.teal,
        surface: Colors.white,
      ),
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.heading,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.heading,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.heading,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.darkText,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.subText,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.8),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.subText, fontSize: 13),
        hintStyle: GoogleFonts.inter(color: AppColors.placeholder, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          minimumSize: const Size.fromHeight(42),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
