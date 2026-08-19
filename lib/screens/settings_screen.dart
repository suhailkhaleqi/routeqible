import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/core/localization/language_service.dart';
import 'package:routeqible/core/theme/theme_service.dart';
import 'package:routeqible/screens/language_selection_screen.dart';
import 'package:routeqible/screens/theme_selection_screen.dart';

/// Main Settings screen providing localized configuration for Language and Theme.
class SettingsScreen extends StatelessWidget {
  final ThemeService themeService;
  final LanguageService languageService;

  const SettingsScreen({
    super.key,
    required this.themeService,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([themeService, languageService]),
        builder: (context, _) {
          final selectedLanguage = languageService.currentLanguage;
          final selectedThemeText =
              themeService.isDarkMode ? l10n.darkMode : l10n.lightMode;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Language Setting Tile
              _buildSettingsTile(
                context: context,
                icon: Icons.language_rounded,
                title: l10n.language,
                subtitle: '${selectedLanguage.name} (${selectedLanguage.nativeName})',
                theme: theme,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LanguageSelectionScreen(
                        languageService: languageService,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Theme Setting Tile
              _buildSettingsTile(
                context: context,
                icon: themeService.isDarkMode
                    ? Icons.nightlight_round
                    : Icons.wb_sunny_rounded,
                title: l10n.theme,
                subtitle: selectedThemeText,
                theme: theme,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ThemeSelectionScreen(
                        themeService: themeService,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (theme.cardTheme.shape as RoundedRectangleBorder?)
                  ?.side
                  .color ??
              theme.dividerColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.tealAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: AppColors.tealAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
