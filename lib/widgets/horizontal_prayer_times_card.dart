import 'package:flutter/material.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/models/prayer_times.dart';

/// Compact horizontal Prayer Times bar widget displayed at the top of the Home page.
class HorizontalPrayerTimesCard extends StatelessWidget {
  final DailyPrayerTimes? prayerTimes;
  final VoidCallback? onTap;

  const HorizontalPrayerTimesCard({
    super.key,
    this.prayerTimes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (prayerTimes == null) {
      return const SizedBox.shrink();
    }

    final obligatoryPrayers = prayerTimes!.prayers.where((p) => p.name != PrayerName.sunrise).toList();
    final nextPrayerName = prayerTimes!.nextPrayer;

    // Determine remaining countdown to next prayer
    String? countdownText;
    if (nextPrayerName != null) {
      final nextEntry = prayerTimes!.prayers.firstWhere(
        (p) => p.name == nextPrayerName,
        orElse: () => prayerTimes!.prayers.first,
      );
      final now = DateTime.now();
      final diff = nextEntry.time.difference(now);
      if (!diff.isNegative) {
        final h = diff.inHours;
        final m = diff.inMinutes.remainder(60);
        countdownText = h > 0 ? '${h}h ${m}m' : '${m}m';
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2218),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF283D2F), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row: Title & Trailing Chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.prayerTimes,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5B869),
                    letterSpacing: 0.2,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFE5B869),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Prayer Row (Fajr, Dhuhr, Asr, Maghrib, Isha)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: obligatoryPrayers.map((prayer) {
                final isNext = prayer.name == nextPrayerName;
                final localizedName = _getLocalizedPrayerName(l10n, prayer.name);

                return Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Countdown Pill Badge (if next prayer)
                      SizedBox(
                        height: 22,
                        child: isNext && countdownText != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3827),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF4EBE96).withValues(alpha: 0.4), width: 1),
                                ),
                                child: Text(
                                  countdownText,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE5B869),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 4),

                      // Time Display (HH:mm)
                      Text(
                        prayer.formattedTime,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                          color: isNext ? const Color(0xFFE5B869) : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Prayer Name
                      Text(
                        localizedName,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                          color: isNext ? const Color(0xFFE5B869) : const Color(0xFFA0B5A7),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Active Dot Indicator
                      SizedBox(
                        height: 6,
                        child: isNext
                            ? Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5B869),
                                  shape: BoxShape.circle,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedPrayerName(AppLocalizations l10n, PrayerName name) {
    switch (name) {
      case PrayerName.fajr:
        return l10n.fajr;
      case PrayerName.dhuhr:
        return l10n.dhuhr;
      case PrayerName.asr:
        return l10n.asr;
      case PrayerName.maghrib:
        return l10n.maghrib;
      case PrayerName.isha:
        return l10n.isha;
      case PrayerName.sunrise:
        return l10n.sunrise;
    }
  }
}
