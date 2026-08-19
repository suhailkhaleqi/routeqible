import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/services/notification_service.dart';

/// Screen allowing granular control over master notification switch and individual prayer alarms.
class NotificationSettingsScreen extends StatelessWidget {
  final NotificationService notificationService;

  const NotificationSettingsScreen({
    super.key,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = (theme.cardTheme.shape as RoundedRectangleBorder?)?.side.color ?? theme.dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayerNotifications),
      ),
      body: ListenableBuilder(
        listenable: notificationService,
        builder: (context, _) {
          final isMasterOn = notificationService.masterEnabled;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Master Switch Card
              Container(
                decoration: BoxDecoration(
                  color: isMasterOn
                      ? AppColors.tealAccent.withValues(alpha: 0.1)
                      : cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isMasterOn ? AppColors.tealAccent : borderColor,
                    width: isMasterOn ? 1.5 : 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMasterOn
                              ? AppColors.tealAccent
                              : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isMasterOn
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_rounded,
                          size: 24,
                          color: isMasterOn ? Colors.white : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.prayerNotifications,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isMasterOn ? l10n.notificationsEnabled : l10n.notificationsDisabled,
                              style: TextStyle(
                                fontSize: 13,
                                color: isMasterOn ? AppColors.tealAccent : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isMasterOn,
                        activeTrackColor: AppColors.tealAccent.withValues(alpha: 0.4),
                        activeThumbColor: AppColors.tealAccent,
                        onChanged: (val) {
                          notificationService.setMasterEnabled(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (isMasterOn) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'PRAYER TIME ALARMS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                _buildPrayerToggleTile(context, theme, 'Fajr', 'Fajr Prayer', borderColor, cardColor),
                const SizedBox(height: 8),
                _buildPrayerToggleTile(context, theme, 'Dhuhr', 'Dhuhr Prayer', borderColor, cardColor),
                const SizedBox(height: 8),
                _buildPrayerToggleTile(context, theme, 'Asr', 'Asr Prayer', borderColor, cardColor),
                const SizedBox(height: 8),
                _buildPrayerToggleTile(context, theme, 'Maghrib', 'Maghrib Prayer', borderColor, cardColor),
                const SizedBox(height: 8),
                _buildPrayerToggleTile(context, theme, 'Isha', 'Isha Prayer', borderColor, cardColor),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrayerToggleTile(
    BuildContext context,
    ThemeData theme,
    String prayerKey,
    String displayName,
    Color borderColor,
    Color cardColor,
  ) {
    final isEnabled = notificationService.prayerPreferences[prayerKey] ?? true;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          displayName,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing: Switch(
          value: isEnabled,
          activeTrackColor: AppColors.tealAccent.withValues(alpha: 0.4),
          activeThumbColor: AppColors.tealAccent,
          onChanged: (val) {
            notificationService.setPrayerEnabled(prayerKey, val);
          },
        ),
      ),
    );
  }
}
