import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RFMTheme {
  // Brand Colors: Web Parity
  static const Color surface = Color(0xFF0A0A0A);
  static const Color surfaceContainerLowest = Color(0xFF050505);
  static const Color surfaceContainerLow = Color(0xFF0F0F0F);
  static const Color surfaceContainerHigh = Color(0xFF1A1A1A);
  
  static const Color primary = Color(0xFFD4AF37); // Brass
  static const Color primaryContainer = Color(0xFFD4AF37);
  static const Color accent = Color(0xFFFFB03B); // Amber
  static const Color onSurface = Color(0xFFEAEAEA);
  static const Color outline = Color(0xFF333333);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Cinematic Background Blobs
  static const Color blob1 = Color(0x33D4AF37); // Brass/20
  static const Color blob2 = Color(0x26FFB03B); // Amber/15

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: surface,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: surface,
      secondary: accent,
      primaryContainer: primaryContainer,
      onPrimaryContainer: Colors.black,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainerHigh: surfaceContainerHigh,
      outline: outline,
    ),
    
    // Typography: Matching Web's Font Scaling
    textTheme: TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 72,
        fontWeight: FontWeight.w400,
        color: pureWhite,
        letterSpacing: -0.05 * 72,
        height: 0.9,
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
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.2,
      ),
      bodyLarge: GoogleFonts.workSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: onSurface,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.workSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: onSurface.withOpacity(0.7),
        height: 1.5,
      ),
      labelSmall: GoogleFonts.spaceGrotesk(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: primary,
        letterSpacing: 2.5,
      ),
    ),

    // Component Themes: Rounded & Glass-aligned
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: surfaceContainerLow,
      elevation: 0,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryContainer,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainerHigh,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: outline),
        borderRadius: BorderRadius.circular(20),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: outline.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primary),
        borderRadius: BorderRadius.circular(20),
      ),
      labelStyle: GoogleFonts.spaceGrotesk(color: onSurface.withOpacity(0.4)),
    ),
  );

  static ThemeData lightTheme = darkTheme; 
}
