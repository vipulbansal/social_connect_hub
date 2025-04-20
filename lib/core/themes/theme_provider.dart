import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier{
  static const String _themePreferenceKey = 'theme_preference';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemePreference();
  }


  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePreferenceKey);
    if (savedTheme != null) {
      setThemeMode(_themeFromString(savedTheme));
    }
  }

  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, _themeToString(mode));
  }

  /// Set the theme mode and update dark mode status
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;

    switch (mode) {
      case ThemeMode.system:
        final window = WidgetsBinding.instance.window;
        _isDarkMode = window.platformBrightness == Brightness.dark;
        break;
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
    }

    _saveThemePreference(mode);
    notifyListeners();
  }


  /// Convert ThemeMode to string for storage
  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _themeFromString(String value) {
    switch (value) {
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

}