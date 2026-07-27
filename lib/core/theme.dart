import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { light, dark }

class FitzaTheme {
  // Brand Colors - Clean Soft UI
  static const Color primaryDark = Color(0xFF0A84FF); // Premium Blue
  static const Color accentNeon = Color(0xFF30D158);  // Success Green
  static const Color energyOrange = Color(0xFFFF9F0A); // Sunset Orange
  
  static const Color bgDarkObsidian = Color(0xFF121212); // Soft Dark Gray
  static const Color bgDarkCard = Color(0xFF1C1C1E);     // Slightly Lighter Gray
  
  static const Color primaryLight = Color(0xFF007AFF); // Apple Blue
  static const Color accentTealLight = Color(0xFF34C759); // Apple Green
  static const Color bgLight = Color(0xFFF2F2F7); // Very Light Gray
  static const Color bgLightCard = Colors.white;

  // Gradients (Subtle for Soft UI)
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF005BB5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFFC70039)], 
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient limeGradient = LinearGradient(
    colors: [Color(0xFF30D158), Color(0xFF249D42)], 
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Default gradients mapping to old variables for compatibility
  static const Gradient orangeGradient = pinkGradient; 
  static const Gradient emeraldGradient = limeGradient;
  static const Gradient blueGradient = primaryGradient;

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
    }
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      secondary: accentNeon,
      bg: bgDarkObsidian,
      surface: bgDarkCard,
      textColor: Colors.white,
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primary: primaryLight,
      secondary: accentTealLight,
      bg: bgLight,
      surface: bgLightCard,
      textColor: const Color(0xFF1C1C1E),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color bg,
    required Color surface,
    required Color textColor,
  }) {
    final isDark = brightness == Brightness.dark;
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF8E8E93);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        error: const Color(0xFFFF453A),
        onError: Colors.white,
        surface: surface,
        onSurface: textColor,
      ),
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: textColor),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor),
        displaySmall: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor),
        headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: textColor),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: textColor),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: textColor),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: GoogleFonts.inter(color: bodyColor, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: bodyColor, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 20, color: textColor),
        iconTheme: IconThemeData(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0),
        ),
      ),
    );
  }
}
