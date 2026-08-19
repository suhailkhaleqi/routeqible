import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages application theme state (Light / Dark) and local storage persistence.
class ThemeService extends ChangeNotifier {
  static const String _storageKey = 'app_selected_theme_mode';

  // Light Mode is default per prompt requirements
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Loads saved theme preference from SharedPreferences (defaults to Light Mode).
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_storageKey);
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
        notifyListeners();
      } else if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
        notifyListeners();
      }
    } catch (_) {
      // Storage fallback
    }
  }

  /// Updates application theme and persists preference to SharedPreferences.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {
      // Storage fallback
    }
  }

  /// Toggles between Light and Dark mode.
  Future<void> toggleTheme() async {
    final nextMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(nextMode);
  }
}
