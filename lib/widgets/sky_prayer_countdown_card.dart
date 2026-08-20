import 'dart:async';
import 'package:flutter/material.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/models/prayer_times.dart';
import 'package:routeqible/services/timezone_service.dart';

class SkyPrayerCountdownCard extends StatefulWidget {
  final AppLocation location;
  final DailyPrayerTimes prayerTimes;

  const SkyPrayerCountdownCard({
    super.key,
    required this.location,
    required this.prayerTimes,
  });

  @override
  State<SkyPrayerCountdownCard> createState() => _SkyPrayerCountdownCardState();
}

class _SkyPrayerCountdownCardState extends State<SkyPrayerCountdownCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  PrayerName? _currentActivePrayer;
  DateTime? _targetTime;
  double _progressRatio = 0.5;

  @override
  void initState() {
    super.initState();
    _calculateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateCountdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SkyPrayerCountdownCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateCountdown();
  }

  void _calculateCountdown() {
    final utcOffset = TimezoneService.getUtcOffset(
      latitude: widget.location.latitude,
      longitude: widget.location.longitude,
      country: widget.location.displayCountry,
      city: widget.location.displayCity,
      isManual: widget.location.isManual,
    );

    final nowUtc = DateTime.now().toUtc();
    final locationNow = nowUtc.add(utcOffset);
    final prayers = widget.prayerTimes.prayers;

    PrayerName? active;
    PrayerName? next;
    DateTime? target;
    DateTime? start;

    for (int i = 0; i < prayers.length; i++) {
      final p = prayers[i];
      if (locationNow.isBefore(p.time)) {
        next = p.name;
        target = p.time;
        if (i > 0) {
          active = prayers[i - 1].name;
          start = prayers[i - 1].time;
        } else {
          active = PrayerName.isha;
          final fajrToday = prayers.firstWhere((item) => item.name == PrayerName.fajr);
          start = fajrToday.time.subtract(const Duration(hours: 6));
        }
        break;
      }
    }

    if (next == null) {
      // All prayers for today passed -> next is tomorrow Fajr
      final fajrToday = prayers.firstWhere((p) => p.name == PrayerName.fajr);
      target = fajrToday.time.add(const Duration(days: 1));
      final ishaToday = prayers.firstWhere((p) => p.name == PrayerName.isha);
      start = ishaToday.time;
      active = PrayerName.isha;
    }

    final diff = target != null ? target.difference(locationNow) : Duration.zero;

    double ratio = 0.5;
    if (start != null && target != null) {
      final totalSeconds = target.difference(start).inSeconds;
      final elapsedSeconds = locationNow.difference(start).inSeconds;
      if (totalSeconds > 0) {
        ratio = (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
      }
    }

    if (mounted) {
      setState(() {
        _currentActivePrayer = active;
        _targetTime = target;
        _remaining = diff.isNegative ? Duration.zero : diff;
        _progressRatio = ratio;
      });
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _getStatusText(AppLocalizations l10n) {
    switch (_currentActivePrayer) {
      case PrayerName.fajr:
        return 'Fajr Ends';
      case PrayerName.sunrise:
        return 'Dhuhr Starts';
      case PrayerName.dhuhr:
        return 'Asr Starts';
      case PrayerName.asr:
        return 'Maghrib Starts';
      case PrayerName.maghrib:
        return 'Isha Starts';
      case PrayerName.isha:
        return 'Fajr Starts';
      default:
        return 'Next Prayer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cityName = widget.location.displayCity;

    final targetTimeStr = _targetTime != null
        ? '${_targetTime!.hour.toString().padLeft(2, '0')}:${_targetTime!.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF5B86E5),
            Color(0xFF7BA0EE),
            Color(0xFFE0A97E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Header Row: Status & Location (NO SETTINGS GEAR)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Status Text & Icon
              Row(
                children: [
                  const Icon(
                    Icons.wb_twilight_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _getStatusText(l10n),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // Right: Location Name Only (No gear icon)
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    cityName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Central Live Countdown Display with Arc Trajectory
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Curved Arc Trajectory
                Positioned.fill(
                  child: CustomPaint(
                    painter: ArcTrajectoryPainter(progressRatio: _progressRatio),
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Active Prayer Title Label
                    Text(
                      (_currentActivePrayer?.name ?? 'FAJR').toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Running Live Digital Timer Countdown (HH:MM:SS)
                    Text(
                      _formatDuration(_remaining),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Target Time Subtitle
                    Text(
                      targetTimeStr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Horizontal Prayer Pills (6 Pills)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: widget.prayerTimes.prayers.map((prayer) {
              final isCurrent = prayer.name == _currentActivePrayer;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.25),
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        prayer.displayName,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prayer.formattedTime,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to draw the curved arc trajectory with a circular sun/moon position badge
class ArcTrajectoryPainter extends CustomPainter {
  final double progressRatio;

  ArcTrajectoryPainter({this.progressRatio = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final p0 = Offset(10, size.height * 0.75);
    final p1 = Offset(size.width / 2, size.height * 0.15);
    final p2 = Offset(size.width - 10, size.height * 0.75);

    path.moveTo(p0.dx, p0.dy);
    path.quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    canvas.drawPath(path, paint);

    // Calculate position on Bezier curve for current progress ratio t
    final t = progressRatio.clamp(0.0, 1.0);
    final bx = (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
    final by = (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;

    final badgeCenter = Offset(bx, by);
    final badgePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(badgeCenter, 12, badgePaint);
  }

  @override
  bool shouldRepaint(covariant ArcTrajectoryPainter oldDelegate) {
    return oldDelegate.progressRatio != progressRatio;
  }
}
