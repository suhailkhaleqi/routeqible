import 'package:flutter/material.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/models/prayer_times.dart';

class PrayerTimesList extends StatelessWidget {
  const PrayerTimesList({
    super.key,
    required this.prayerTimes,
    this.onTapViewFullMonth,
  });

  final DailyPrayerTimes prayerTimes;
  final VoidCallback? onTapViewFullMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F2218),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF283D2F), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: prayerTimes.prayers.map((prayer) {
              final isSunrise = prayer.name == PrayerName.sunrise;
              final isNext = prayer.name == prayerTimes.nextPrayer;
              final isPassed = !isNext && prayer.time.isBefore(now) && !isSunrise;

              if (isNext) {
                // Highlighted Next / Upcoming Prayer Row
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF253B2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFE5B869),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        prayer.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5B869),
                        ),
                      ),
                      if (prayer.name == PrayerName.maghrib) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.wb_twilight,
                          color: Color(0xFFE5B869),
                          size: 18,
                        ),
                      ],
                      const Spacer(),
                      // "Next" Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF8C7540), width: 1),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE5B869),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        prayer.formattedTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5B869),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Normal Prayer / Sunrise Row
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    if (isSunrise) ...[
                      const Icon(
                        Icons.wb_sunny_outlined,
                        color: Color(0xFFD4AF37),
                        size: 18,
                      ),
                    ] else if (isPassed) ...[
                      const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF8DA693),
                        size: 18,
                      ),
                    ] else ...[
                      const Icon(
                        Icons.circle_outlined,
                        color: Color(0xFF536958),
                        size: 18,
                      ),
                    ],
                    const SizedBox(width: 14),
                    Text(
                      prayer.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isSunrise ? const Color(0xFFD4AF37) : const Color(0xFFE0EAE3),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      prayer.formattedTime,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC0D1C5),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        // Centered "View Full Month" Button
        if (onTapViewFullMonth != null) ...[
          Center(
            child: OutlinedButton.icon(
              onPressed: onTapViewFullMonth,
              icon: const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFFE5B869),
                size: 18,
              ),
              label: Text(
                l10n.viewFullMonth,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE5B869),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFF14291E),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                side: const BorderSide(color: Color(0xFF48604F), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
