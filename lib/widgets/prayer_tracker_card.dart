import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/services/prayer_tracker_service.dart';

/// Interactive Prayer Tracker component with completion progress bar, motivational banner, and streak tracking.
class PrayerTrackerCard extends StatelessWidget {
  final PrayerTrackerService trackerService;

  const PrayerTrackerCard({
    super.key,
    required this.trackerService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = DateTime.now();

    return ListenableBuilder(
      listenable: trackerService,
      builder: (context, _) {
        final completedCount = trackerService.getCompletedCount(date: today);
        final streakCount = trackerService.currentStreak;
        final progress = completedCount / 5.0;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: PRAYER TRACKER & Ratio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.prayerTracker,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  Text(
                    '$completedCount / 5',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFC0D1C5),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: const Color(0xFF1F3327),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tealAccent),
                ),
              ),

              const SizedBox(height: 16),

              // Motivational Banner Info Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF182F22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A4434), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF384E3F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.touch_app_rounded,
                        color: Color(0xFFE5B869),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Center Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.tapEachPrayer,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.completeAll5,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA0B5A7),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Right Streak Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B3D2B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF26A69A), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '🔥',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            streakCount > 0 ? '$streakCount ${l10n.streak}' : l10n.streak,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4EBE96),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 5 Obligatory Prayer Items Checklist
              ...PrayerTrackerService.obligatoryPrayers.map((prayerName) {
                final isDone = trackerService.isPrayerCompleted(prayerName, date: today);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    onTap: () {
                      trackerService.togglePrayer(prayerName, date: today);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_off_rounded,
                            color: isDone ? AppColors.tealAccent : const Color(0xFF475E4F),
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            prayerName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                              color: isDone ? Colors.white : const Color(0xFFE0EAE3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
