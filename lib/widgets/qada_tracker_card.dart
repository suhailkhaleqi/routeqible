import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/services/qada_tracker_service.dart';

/// Interactive Qada (Make-up) Prayers tracker component with total summary badge, info callout, and +/- controls.
class QadaTrackerCard extends StatelessWidget {
  final QadaTrackerService qadaService;

  const QadaTrackerCard({
    super.key,
    required this.qadaService,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: qadaService,
      builder: (context, _) {
        final totalOwed = qadaService.totalOwed;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
              // Header Row: Icon + Qada Title & Total Owed Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: Color(0xFFE5B869),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.qadaTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5B869),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14291E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF48604F), width: 1),
                    ),
                    child: Text(
                      '$totalOwed ${l10n.owed}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFE5B869),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Informational Callout Box: What is Qada?
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF384E3F),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFE5B869),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.whatIsQada,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.qadaDescription,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFA0B5A7),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 5 Obligatory Prayer Counter Rows
              ...QadaTrackerService.prayers.map((prayer) {
                final count = qadaService.getCount(prayer);
                final localizedPrayerName = _getLocalizedPrayerName(l10n, prayer);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizedPrayerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE0EAE3),
                        ),
                      ),
                      Row(
                        children: [
                          // Decrement (-) Button
                          InkWell(
                            onTap: count > 0 ? () => qadaService.decrement(prayer) : null,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B3D2B),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: count > 0 ? AppColors.tealAccent : const Color(0xFF2B4434),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.remove_rounded,
                                color: count > 0 ? AppColors.tealAccent : const Color(0xFF475E4F),
                                size: 20,
                              ),
                            ),
                          ),

                          // Count Display
                          SizedBox(
                            width: 36,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: count > 0 ? const Color(0xFFE5B869) : const Color(0xFFA0B5A7),
                              ),
                            ),
                          ),

                          // Increment (+) Button
                          InkWell(
                            onTap: () => qadaService.increment(prayer),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF283B2C),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF8C7540), width: 1),
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Color(0xFFE5B869),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getLocalizedPrayerName(AppLocalizations l10n, String englishName) {
    switch (englishName) {
      case 'Fajr':
        return l10n.fajr;
      case 'Dhuhr':
        return l10n.dhuhr;
      case 'Asr':
        return l10n.asr;
      case 'Maghrib':
        return l10n.maghrib;
      case 'Isha':
        return l10n.isha;
      default:
        return englishName;
    }
  }
}
