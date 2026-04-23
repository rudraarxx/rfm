import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RFMTheme {
  // Brand Colors - YouTube Music Style
  static const Color background = Color(0xFF030303);
  static const Color surface = Color(0xFF0F0F0F);
  static const Color surfaceContainer = Color(0xFF212121);
  
  static const Color primary = Color(0xFFFF0000); // YouTube Red
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFAAAAAA);
  static const Color pureWhite = Color(0xFFFFFFFF);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      surface: background,
      onSurface: onSurface,
      surfaceContainer: surface,
      secondary: secondaryText,
    ),
    
    // Typography: Modern & Clean (Roboto)
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
      headlineLarge: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: pureWhite,
      ),
      titleLarge: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: pureWhite,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: pureWhite,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: secondaryText,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryText,
        letterSpacing: 0.5,
      ),
    ),

    // Component Themes: Rounded & Premium
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: surface,
      elevation: 0,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: GoogleFonts.roboto(fontWeight: FontWeight.bold),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceContainer,
      labelStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainer,
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      hintStyle: const TextStyle(color: secondaryText),
    ),
  );

  static ThemeData lightTheme = darkTheme;
}
