import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF3F6F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF183E2C);
  static const Color forest = Color(0xFF18583D);
  static const Color sage = Color(0xFF39815C);
  static const Color amber = Color(0xFFF5C87A);
  static const Color terracotta = Color(0xFFE8916A);
  static const Color mutedTerracotta = Color(0xFFD4756A);

  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: sage,
      onPrimary: Colors.white,
      secondary: amber,
      tertiary: terracotta,
      surface: surface,
      error: mutedTerracotta,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: surface,
        indicatorColor: sage.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
        ),
      ),
    );
  }
}
