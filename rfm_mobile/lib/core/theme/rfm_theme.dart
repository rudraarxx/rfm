import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RFMTheme {
  // Brand Colors - The Analog Machinist
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color primary = Color(0xFFFFB3B0);
  static const Color primaryContainer = Color(0xFFDA1A32);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color outline = Color(0xFFAD8886);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      primaryContainer: primaryContainer,
      surface: surface,
      onSurface: onSurface,
      outline: outline,
    ),
    
    // Typography: Technical Authority vs Editorial Clarity
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -1.14,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: onSurface,
        letterSpacing: -0.64,
      ),
      titleLarge: GoogleFonts.workSans(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyLarge: GoogleFonts.workSans(
        fontSize: 16,
        color: onSurface,
        height: 1.6,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: onSurface,
        letterSpacing: 2.0,
      ),
    ),

    // Forged Elements: Sharp Corners
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      color: surfaceContainerHigh,
      elevation: 0,
    ),

    buttonTheme: const ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: primaryContainer,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainerLowest,
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: outline, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: outline.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.zero,
      ),
    ),
  );

  // Gradient for Primary Actions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    transform: GradientRotation(135 * 3.14159 / 180),
  );
}
