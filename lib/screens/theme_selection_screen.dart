import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/core/theme/theme_service.dart';

/// Screen allowing the user to select between Light Mode and Dark Mode.
class ThemeSelectionScreen extends StatelessWidget {
  final ThemeService themeService;

  const ThemeSelectionScreen({
    super.key,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.theme),
      ),
      body: ListenableBuilder(
        listenable: themeService,
        builder: (context, _) {
          final currentMode = themeService.themeMode;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildThemeCard(
                  context: context,
                  title: l10n.lightMode,
                  subtitle: l10n.lightModeSubtitle,
                  icon: Icons.wb_sunny_rounded,
                  mode: ThemeMode.light,
                  isSelected: currentMode == ThemeMode.light,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                _buildThemeCard(
                  context: context,
                  title: l10n.darkMode,
                  subtitle: l10n.darkModeSubtitle,
                  icon: Icons.nightlight_round,
                  mode: ThemeMode.dark,
                  isSelected: currentMode == ThemeMode.dark,
                  theme: theme,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.tealAccent.withValues(alpha: 0.1)
            : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.tealAccent
              : (theme.cardTheme.shape as RoundedRectangleBorder?)
                      ?.side
                      .color ??
                  theme.dividerColor,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.tealAccent.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            themeService.setThemeMode(mode);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.tealAccent
                        : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.white : AppColors.tealAccent,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? AppColors.tealAccent
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
