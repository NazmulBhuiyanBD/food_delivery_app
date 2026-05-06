import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Color Palette (Stitch Tokens)
  static const Color primary = Color(0xFFAB2D00);
  static const Color primaryContainer = Color(0xFFFF7851);
  static const Color surface = Color(0xFFFFF4F3);
  static const Color onSurface = Color(0xFF4E2120);
  static const Color secondary = Color(0xFF5C5B5B);
  static const Color tertiary = Color(0xFF833E9A);
  
  static const Color surfaceContainerLow = Color(0xFFFEEDEB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E1);

  // 2. Gradients & Effects
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static const BoxShadow ambientShadow = BoxShadow(
    color: Color(0x0F4E2120), // 6% opacity of onSurface
    blurRadius: 40,
    offset: Offset(0, 10),
  );

  // 3. Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHighest: surfaceContainerHighest,
      ),
      
      // Typography
      textTheme: GoogleFonts.beVietnamProTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.beVietnamPro(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.beVietnamPro(
          color: onSurface,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),

      // Component Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.beVietnamPro(color: onSurface.withOpacity(0.5)),
      ),
    );
  }
}
