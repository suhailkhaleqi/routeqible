import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/services/prayer_time_service.dart';

/// Modal bottom sheet displaying the full 30-day prayer schedule for a location.
class MonthlyPrayerScheduleModal extends StatelessWidget {
  final AppLocation location;
  final PrayerTimeService prayerTimeService;

  const MonthlyPrayerScheduleModal({
    super.key,
    required this.location,
    required this.prayerTimeService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final monthlyTimes = prayerTimeService.calculateMonthlyPrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      countryName: location.displayCountry,
      cityName: location.displayCity,
      isManual: location.isManual,
      customUtcOffset: location.customUtcOffset,
      monthDate: now,
    );

    final monthName = DateFormat('MMMM yyyy').format(now);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = (theme.cardTheme.shape as RoundedRectangleBorder?)?.side.color ?? theme.dividerColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Modal Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      monthName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.displayCity.isNotEmpty
                          ? '${location.displayCity}, ${location.displayCountry}'
                          : location.displayCountry,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: borderColor, height: 1),

          // Schedule List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: monthlyTimes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final daily = monthlyTimes[index];
                final date = daily.date ?? now;
                final isToday = date.day == now.day && date.month == now.month && date.year == now.year;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.tealAccent.withValues(alpha: 0.15)
                        : cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isToday ? AppColors.tealAccent : borderColor,
                      width: isToday ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Date Badge
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isToday
                              ? AppColors.tealAccent
                              : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isToday ? Colors.white : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Times grid
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: daily.prayers.map((prayer) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: Column(
                                  children: [
                                    Text(
                                      prayer.displayName,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isToday
                                            ? AppColors.tealAccent
                                            : theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      prayer.formattedTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
