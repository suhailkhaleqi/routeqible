import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/models/prayer_times.dart';
import 'package:routeqible/widgets/compass_arrow.dart';
import 'package:routeqible/widgets/horizontal_prayer_times_card.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({
    super.key,
    required this.location,
    required this.qiblaBearing,
    required this.deviceHeading,
    required this.qiblaDiff,
    required this.isAligned,
    required this.guidanceText,
    required this.showCalibrationHint,
    required this.onTapSearchLocation,
    this.prayerTimes,
    this.distanceToKaabaKm,
    this.isLoading = false,
    this.onRefresh,
  });

  final AppLocation? location;
  final double? qiblaBearing;
  final double? deviceHeading;
  final double? qiblaDiff;
  final bool isAligned;
  final String guidanceText;
  final bool showCalibrationHint;
  final VoidCallback onTapSearchLocation;
  final DailyPrayerTimes? prayerTimes;
  final double? distanceToKaabaKm;
  final bool isLoading;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteQibla'),
        actions: [
          if (onRefresh != null)
            IconButton(
              onPressed: isLoading ? null : () => onRefresh!(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading && location == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.tealAccent),
            SizedBox(height: 16),
            Text(
              'Getting location...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (location == null || qiblaBearing == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Location unavailable. Please search for a city or enable GPS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onTapSearchLocation,
                icon: const Icon(Icons.search),
                label: const Text('Select Location'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tealAccent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget content = Column(
      children: [
        // Horizontal Prayer Times Bar at top of Home page
        HorizontalPrayerTimesCard(
          prayerTimes: prayerTimes,
        ),
        const SizedBox(height: 4),

        // Compass Section
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CompassArrow(
                  qiblaBearing: qiblaBearing!,
                  deviceHeading: deviceHeading,
                  qiblaDiff: qiblaDiff,
                  isAligned: isAligned,
                  guidanceText: guidanceText,
                  showCalibrationHint: showCalibrationHint,
                  locationLabel: location?.displayLabel,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.tealAccent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: content,
            ),
          ],
        ),
      );
    }

    return content;
  }
}
