import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RFMTheme {
  static const Color mahogany = Color(0xFF2C1810);
  static const Color brass = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF050206);
  static const Color lightBackground = Color(0xFFF1F1F1);
  static const Color amber = Color(0xFFFFB03B);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: brass,
      secondary: mahogany,
      surface: Color(0xFF151216),
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.white70,
      ),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: brass,
      secondary: mahogany,
      surface: Colors.white,
      onSurface: Color(0xFF050206),
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFF050206),
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF050206),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.black54,
      ),
    ),
  );
}
