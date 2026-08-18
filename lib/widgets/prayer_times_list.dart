import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/models/prayer_times.dart';

class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({
    super.key,
    required this.prayerTimes,
  });

  final DailyPrayerTimes prayerTimes;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Prayer Times',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (prayerTimes.nextPrayer == null)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'All prayers for today have passed. Next: Fajr tomorrow.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ...prayerTimes.prayers.map((prayer) {
              final isNext = prayer.name == prayerTimes.nextPrayer;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isNext
                      ? AppColors.tealAccent.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  dense: true,
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                  leading: isNext
                      ? const Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.tealAccent,
                          size: 20,
                        )
                      : const SizedBox(width: 20),
                  title: Text(
                    prayer.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                      color: isNext ? AppColors.tealAccent : AppColors.textPrimary,
                    ),
                  ),
                  trailing: Text(
                    prayer.formattedTime,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                      color: isNext ? AppColors.tealAccent : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
