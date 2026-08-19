import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/core/localization/language_service.dart';
import 'package:routeqible/core/localization/supported_languages.dart';
import 'package:routeqible/core/theme/app_theme.dart';
import 'package:routeqible/core/theme/theme_service.dart';
import 'package:routeqible/screens/main_navigation_screen.dart';
import 'package:routeqible/services/notification_service.dart';
import 'package:routeqible/services/prayer_tracker_service.dart';
import 'package:routeqible/services/qada_tracker_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeService = ThemeService();
  await themeService.init();

  final languageService = LanguageService();
  await languageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final trackerService = PrayerTrackerService();
  await trackerService.init();

  final qadaService = QadaTrackerService();
  await qadaService.init();

  runApp(
    RouteQibleApp(
      themeService: themeService,
      languageService: languageService,
      notificationService: notificationService,
      trackerService: trackerService,
      qadaService: qadaService,
    ),
  );
}

class RouteQibleApp extends StatelessWidget {
  final ThemeService themeService;
  final LanguageService languageService;
  final NotificationService notificationService;
  final PrayerTrackerService trackerService;
  final QadaTrackerService qadaService;

  const RouteQibleApp({
    super.key,
    required this.themeService,
    required this.languageService,
    required this.notificationService,
    required this.trackerService,
    required this.qadaService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        themeService,
        languageService,
        notificationService,
        trackerService,
        qadaService,
      ]),
      builder: (context, _) {
        final currentLocale = languageService.currentLanguage.locale;

        return MaterialApp(
          title: 'RouteQibla',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          locale: currentLocale,
          supportedLocales: SupportedLanguages.languages
              .map((e) => e.locale)
              .toList(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: MainNavigationScreen(
            themeService: themeService,
            languageService: languageService,
            notificationService: notificationService,
            trackerService: trackerService,
            qadaService: qadaService,
          ),
        );
      },
    );
  }
}
