import 'package:flutter/material.dart';

class AppTheme{

  // Static property to track current theme
  static bool _isDarkMode = false;

  // Method to set dark mode status
  static void setDarkMode(bool isDarkMode) {
    _isDarkMode = isDarkMode;
  }

  // Light theme colors
  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: const Color(0xFF2563EB),
    onPrimary: Colors.white,
    secondary: const Color(0xFF8B5CF6),     // Purple
    onSecondary: Colors.white,
    error: const Color(0xFFDC2626),         // Red
    onError: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF0F172A),      // Navy
  );

  // Dark theme colors
  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFF2563EB),
    onPrimary: Colors.white,
    secondary: const Color(0xFF8B5CF6),     // Purple
    onSecondary: Colors.white,
    error: const Color(0xFFDC2626),         // Red
    onError: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF0F172A),      // Navy
  );

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: _lightColorScheme,
    brightness: Brightness.light,
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    colorScheme: _lightColorScheme,
    brightness: Brightness.dark,
  );


}