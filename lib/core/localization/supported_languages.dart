import 'package:routeqible/core/localization/language_model.dart';

/// Centralized list of the 30 most widely used languages in the world specified for RouteQibla.
abstract class SupportedLanguages {
  static const LanguageModel defaultLanguage = LanguageModel(
    code: 'en',
    name: 'English',
    nativeName: 'English',
  );

  static const List<LanguageModel> languages = [
    LanguageModel(code: 'en', name: 'English', nativeName: 'English'),
    LanguageModel(code: 'es', name: 'Spanish', nativeName: 'Español'),
    LanguageModel(code: 'zh', name: 'Mandarin Chinese', nativeName: '中文'),
    LanguageModel(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    LanguageModel(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    LanguageModel(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    LanguageModel(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    LanguageModel(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    LanguageModel(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    LanguageModel(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ'),
    LanguageModel(code: 'de', name: 'German', nativeName: 'Deutsch'),
    LanguageModel(code: 'jv', name: 'Javanese', nativeName: 'Basa Jawa'),
    LanguageModel(code: 'ko', name: 'Korean', nativeName: '한국어'),
    LanguageModel(code: 'fr', name: 'French', nativeName: 'Français'),
    LanguageModel(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    LanguageModel(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    LanguageModel(code: 'tr', name: 'Turkish', nativeName: 'Türkçe'),
    LanguageModel(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    LanguageModel(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt'),
    LanguageModel(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    LanguageModel(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    LanguageModel(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    LanguageModel(code: 'fa', name: 'Persian', nativeName: 'فارسی'),
    LanguageModel(code: 'pl', name: 'Polish', nativeName: 'Polski'),
    LanguageModel(code: 'uk', name: 'Ukrainian', nativeName: 'Українська'),
    LanguageModel(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
    LanguageModel(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    LanguageModel(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ'),
    LanguageModel(code: 'th', name: 'Thai', nativeName: 'ไทย'),
    LanguageModel(code: 'nl', name: 'Dutch', nativeName: 'Nederlands'),
  ];

  static LanguageModel findByCode(String code) {
    return languages.firstWhere(
      (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      orElse: () => defaultLanguage,
    );
  }
}
