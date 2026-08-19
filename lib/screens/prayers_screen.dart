import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/models/prayer_times.dart';
import 'package:routeqible/widgets/location_card.dart';
import 'package:routeqible/widgets/prayer_times_list.dart';

class PrayersScreen extends StatelessWidget {
  const PrayersScreen({
    super.key,
    required this.location,
    required this.prayerTimes,
    required this.onTapSearchLocation,
    this.distanceToKaabaKm,
    this.isLoading = false,
    this.onRefresh,
  });

  final AppLocation? location;
  final DailyPrayerTimes? prayerTimes;
  final VoidCallback onTapSearchLocation;
  final double? distanceToKaabaKm;
  final bool isLoading;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.prayerTimes),
        actions: [
          if (onRefresh != null)
            IconButton(
              onPressed: isLoading ? null : () => onRefresh!(),
              icon: const Icon(Icons.refresh),
              tooltip: l10n.retry,
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (isLoading && prayerTimes == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.tealAccent),
            const SizedBox(height: 16),
            Text(
              l10n.prayerTimesUnavailable,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (location == null || prayerTimes == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              Text(
                l10n.prayerTimesUnavailable,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onTapSearchLocation,
                icon: const Icon(Icons.search),
                label: Text(l10n.selectLocation),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tealAccent,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget content = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        LocationCard(
          location: location!,
          onTapSearch: onTapSearchLocation,
          distanceToKaabaKm: distanceToKaabaKm,
        ),
        const SizedBox(height: 16),
        PrayerTimesList(prayerTimes: prayerTimes!),
      ],
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.tealAccent,
        child: content,
      );
    }

    return content;
  }
}
