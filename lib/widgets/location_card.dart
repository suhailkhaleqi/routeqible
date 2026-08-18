import 'package:flutter/material.dart';
import 'package:routeqible/models/app_location.dart';

class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    this.distanceToKaabaKm,
  });

  final AppLocation location;
  final double? distanceToKaabaKm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.displayLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${location.latitude.toStringAsFixed(4)}, '
                    '${location.longitude.toStringAsFixed(4)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (distanceToKaabaKm != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${distanceToKaabaKm!.round()} km to Makkah',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
