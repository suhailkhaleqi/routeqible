import 'package:flutter/material.dart';
import 'package:routeqible/models/prayer_times.dart';

class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({
    super.key,
    required this.prayerTimes,
  });

  final DailyPrayerTimes prayerTimes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Prayer Times',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (prayerTimes.nextPrayer == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'All prayers for today have passed. Next: Fajr tomorrow.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ...prayerTimes.prayers.map((prayer) {
              final isNext = prayer.name == prayerTimes.nextPrayer;
              return ListTile(
                dense: true,
                title: Text(
                  prayer.displayName,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext ? theme.colorScheme.primary : null,
                  ),
                ),
                trailing: Text(
                  prayer.formattedTime,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext ? theme.colorScheme.primary : null,
                  ),
                ),
                leading: isNext
                    ? Icon(
                        Icons.notifications_active_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      )
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
