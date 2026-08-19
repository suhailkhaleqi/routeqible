import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/core/localization/language_service.dart';
import 'package:routeqible/core/localization/supported_languages.dart';
import 'package:routeqible/core/theme/app_theme.dart';
import 'package:routeqible/core/theme/theme_service.dart';
import 'package:routeqible/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  await themeService.init();

  final languageService = LanguageService();
  await languageService.init();

  runApp(RouteQibleApp(
    themeService: themeService,
    languageService: languageService,
  ));
}

class RouteQibleApp extends StatelessWidget {
  final ThemeService themeService;
  final LanguageService languageService;

  const RouteQibleApp({
    super.key,
    required this.themeService,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeService, languageService]),
      builder: (context, _) {
        final currentLocale = languageService.currentLanguage.locale;

        return MaterialApp(
          title: 'RouteQibla',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          locale: currentLocale,
          supportedLocales: SupportedLanguages.languages.map((e) => e.locale).toList(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MainNavigationScreen(
            themeService: themeService,
            languageService: languageService,
          ),
        );
      },
    );
  }
}
