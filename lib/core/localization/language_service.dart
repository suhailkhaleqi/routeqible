import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routeqible/core/localization/language_model.dart';
import 'package:routeqible/core/localization/supported_languages.dart';

/// Manages application language selection state and local storage persistence.
class LanguageService extends ChangeNotifier {
  static const String _storageKey = 'app_selected_language_code';

  LanguageModel _currentLanguage = SupportedLanguages.defaultLanguage;

  LanguageModel get currentLanguage => _currentLanguage;

  /// Loads saved language preference from SharedPreferences (defaults to English).
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_storageKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        _currentLanguage = SupportedLanguages.findByCode(savedCode);
        notifyListeners();
      }
    } catch (_) {
      // Storage fallback
    }
  }

  /// Updates selected language and persists it to SharedPreferences.
  Future<void> setLanguage(LanguageModel language) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, language.code);
    } catch (_) {
      // Storage fallback
    }
  }
}
