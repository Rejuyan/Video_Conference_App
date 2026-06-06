import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VMeetTheme {
  // Custom curated colors
  static const Color background = Color(0xFF0F0E17);     // Soothing Twilight Plum
  static const Color surface = Color(0xFF1B1A24);        // Warm Slate Card
  static const Color surfaceElevated = Color(0xFF282736); // Lighter Warm Slate
  
  // Soft, comfortable accents
  static const Color primary = Color(0xFFC7D2FE);        // Gentle Lavender
  static const Color secondary = Color(0xFFFCA5A5);      // Dusty Rose
  static const Color accent = Color(0xFFA7F3D0);         // Soft Mint Green (Active)
  static const Color destructive = Color(0xFFFECDD3);     // Muted Coral Red
  static const Color textPrimary = Color(0xFFF3F4F6);     // Off White
  static const Color textSecondary = Color(0xFF9CA3AF);   // Soft Gray
  static const Color border = Color(0xFF374151);          // Warm Border Gray

  // Linear Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFC7D2FE), Color(0xFF818CF8)], // Lavender to Periwinkle
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFCA5A5), Color(0xFFF43F5E)], // Dusty Rose to Soft Coral
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonMixGradient = LinearGradient(
    colors: [Color(0xFFC7D2FE), Color(0xFFFCA5A5)], // Lavender to Dusty Rose
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A090F), Color(0xFF14131C), Color(0xFF0D0C13)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Custom light glow shadows
  static List<BoxShadow> glowShadow(Color color, {double radius = 12}) {
    return [
      BoxShadow(
        color: color.withAlpha(50),
        blurRadius: radius,
        spreadRadius: 2,
      ),
      BoxShadow(
        color: color.withAlpha(25),
        blurRadius: radius * 2,
        spreadRadius: 4,
      ),
    ];
  }

  // Dark Theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: border,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: destructive,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface.withAlpha(150),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(color: textSecondary),
        hintStyle: GoogleFonts.outfit(color: textSecondary.withAlpha(120)),
      ),
    );
  }
}
