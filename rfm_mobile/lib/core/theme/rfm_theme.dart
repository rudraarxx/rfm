import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RFMTheme {
  // Brand Colors
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1A1A1A);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  
  static const Color primary = Color(0xFFFFB3B0);
  static const Color primaryContainer = Color(0xFFDA1A32);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color outline = Color(0xFFAD8886);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Gradient helper
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
    stops: [0.0, 1.0],
    transform: GradientRotation(135 * 3.14159 / 180),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: surface,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh,
      outline: outline,
    ),
    
    // Typography: Technical Precision (Space Grotesk) vs Editorial Clarity (Work Sans)
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: pureWhite,
        letterSpacing: -0.02 * 57,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: pureWhite,
        letterSpacing: -0.02 * 45,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: pureWhite,
        letterSpacing: -0.02 * 32,
      ),
      titleLarge: GoogleFonts.workSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.workSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: onSurface,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.workSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: onSurface.withOpacity(0.8),
        height: 1.5,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: primary,
        letterSpacing: 1.5,
      ),
    ),

    // Component Themes: Sharp Corners
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      color: surfaceContainerLow,
      elevation: 0,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryContainer,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainerHigh,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: outline, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: outline, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: primary, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      labelStyle: GoogleFonts.spaceGrotesk(color: outline),
    ),
  );

  static ThemeData lightTheme = darkTheme; // Defaulting to dark for The Machinist aesthetic
}
