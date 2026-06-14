import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFD9A736); // Resonator Gold/Amber
  static const Color accentColor = Color(0xFF00D2C4); // Echo Soundwave Cyan
  static const Color darkBg = Color(0xFF0B0C0E); // Deep Obsidian Black
  static const Color cardColor = Color(0xFF16181C); // Tech Grey Card
  static const Color containerBg = Color(0xFF1F2228); // Tech Input Field Grey
  static const Color borderColor = Color(0xFF2E333D); // Border Grey

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Orbitron',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      cardTheme: const CardThemeData(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: darkBg,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.4),
          textStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: containerBg,
        labelStyle: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey[400]),
        hintStyle: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey[600]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.displayLarge),
        displayMedium: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.displayMedium),
        displaySmall: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.displaySmall),
        headlineLarge: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.headlineLarge),
        headlineMedium: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.headlineMedium),
        headlineSmall: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.headlineSmall),
        titleLarge: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.titleLarge),
        titleMedium: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.titleMedium),
        titleSmall: GoogleFonts.orbitron(textStyle: baseTheme.textTheme.titleSmall),
      ),
    );
  }
}
