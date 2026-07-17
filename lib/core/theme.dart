import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { light, dark, ocean, forest, sunset }

class FitzaTheme {
  // Brand Colors
  static const Color primaryDark = Color(0xFF6366F1); // Indigo
  static const Color accentNeon = Color(0xFF10B981);  // Mint/Emerald
  static const Color energyOrange = Color(0xFFF97316); // Energetic Orange
  static const Color bgDarkObsidian = Color(0xFF0F172A); // Slate 900
  static const Color bgDarkCard = Color(0xFF1E293B);     // Slate 800

  static const Color primaryLight = Color(0xFF4F46E5);
  static const Color accentTealLight = Color(0xFF0D9488);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgLightCard = Colors.white;

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient orangeGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFF43F5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.ocean:
        return oceanTheme;
      case AppThemeMode.forest:
        return forestTheme;
      case AppThemeMode.sunset:
        return sunsetTheme;
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
      textColor: const Color(0xFF0F172A),
    );
  }

  static ThemeData get oceanTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF0284C7), // Light Blue
      secondary: const Color(0xFF38BDF8), // Cyan
      bg: const Color(0xFF082F49), // Deep Ocean Blue
      surface: const Color(0xFF0C4A6E), // Card Ocean
      textColor: Colors.white,
    );
  }

  static ThemeData get forestTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: const Color(0xFF16A34A), // Green
      secondary: const Color(0xFF84CC16), // Lime
      bg: const Color(0xFF14532D), // Deep Forest
      surface: const Color(0xFF166534), // Card Forest
      textColor: Colors.white,
    );
  }

  static ThemeData get sunsetTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: const Color(0xFFEA580C), // Orange
      secondary: const Color(0xFFFACC15), // Yellow
      bg: const Color(0xFF7C2D12), // Deep Orange
      surface: const Color(0xFF9A3412), // Card Orange
      textColor: Colors.white,
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
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF334155);

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
        error: Colors.redAccent,
        onError: Colors.white,
        surface: surface,
        onSurface: textColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor),
        bodyLarge: GoogleFonts.outfit(color: bodyColor),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 2,
        shadowColor: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
