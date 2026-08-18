import 'package:geocoding/geocoding.dart';
import 'package:routeqible/models/app_location.dart';

class LocationSearchService {
  // Built-in curated index of major global cities for instant, offline-capable suggestions
  static const List<AppLocation> _curatedWorldCities = [
    AppLocation(city: 'Istanbul', country: 'Turkiye', latitude: 41.0082, longitude: 28.9784, isManual: true),
    AppLocation(city: 'Bursa', country: 'Turkiye', latitude: 40.1950, longitude: 29.0600, isManual: true),
    AppLocation(city: 'Ankara', country: 'Turkiye', latitude: 39.9334, longitude: 32.8597, isManual: true),
    AppLocation(city: 'Izmir', country: 'Turkiye', latitude: 38.4237, longitude: 27.1428, isManual: true),
    AppLocation(city: 'Antalya', country: 'Turkiye', latitude: 36.8969, longitude: 30.7133, isManual: true),
    AppLocation(city: 'Konya', country: 'Turkiye', latitude: 37.8746, longitude: 32.4932, isManual: true),
    AppLocation(city: 'Makkah', country: 'Saudi Arabia', latitude: 21.4225, longitude: 39.8262, isManual: true),
    AppLocation(city: 'Madinah', country: 'Saudi Arabia', latitude: 24.4672, longitude: 39.6111, isManual: true),
    AppLocation(city: 'Riyadh', country: 'Saudi Arabia', latitude: 24.7136, longitude: 46.6753, isManual: true),
    AppLocation(city: 'Jeddah', country: 'Saudi Arabia', latitude: 21.5433, longitude: 39.1728, isManual: true),
    AppLocation(city: 'Dubai', country: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708, isManual: true),
    AppLocation(city: 'Abu Dhabi', country: 'United Arab Emirates', latitude: 24.4539, longitude: 54.3773, isManual: true),
    AppLocation(city: 'London', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278, isManual: true),
    AppLocation(city: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.0060, isManual: true),
    AppLocation(city: 'Chicago', country: 'United States', latitude: 41.8781, longitude: -87.6298, isManual: true),
    AppLocation(city: 'Los Angeles', country: 'United States', latitude: 34.0522, longitude: -118.2437, isManual: true),
    AppLocation(city: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522, isManual: true),
    AppLocation(city: 'Berlin', country: 'Germany', latitude: 52.5200, longitude: 13.4050, isManual: true),
    AppLocation(city: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503, isManual: true),
    AppLocation(city: 'Kabul', country: 'Afghanistan', latitude: 34.5553, longitude: 69.2075, isManual: true),
    AppLocation(city: 'Tashkent', country: 'Uzbekistan', latitude: 41.2995, longitude: 69.2401, isManual: true),
    AppLocation(city: 'Cairo', country: 'Egypt', latitude: 30.0444, longitude: 31.2357, isManual: true),
    AppLocation(city: 'Jakarta', country: 'Indonesia', latitude: -6.2088, longitude: 106.8456, isManual: true),
    AppLocation(city: 'Kuala Lumpur', country: 'Malaysia', latitude: 3.1390, longitude: 101.6869, isManual: true),
    AppLocation(city: 'Islamabad', country: 'Pakistan', latitude: 33.6844, longitude: 73.0479, isManual: true),
    AppLocation(city: 'Toronto', country: 'Canada', latitude: 43.6532, longitude: -79.3832, isManual: true),
    AppLocation(city: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093, isManual: true),
  ];

  Future<List<AppLocation>> searchLocations(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return const [];

    final results = <AppLocation>[];
    final seen = <String>{};

    for (final loc in _curatedWorldCities) {
      final cityMatch = (loc.city ?? '').toLowerCase().contains(cleanQuery);
      final countryMatch = (loc.country ?? '').toLowerCase().contains(cleanQuery);
      final fullMatch = loc.displayLabel.toLowerCase().contains(cleanQuery);

      if (cityMatch || countryMatch || fullMatch) {
        final key = '${loc.latitude.toStringAsFixed(2)}_${loc.longitude.toStringAsFixed(2)}';
        if (!seen.contains(key)) {
          seen.add(key);
          results.add(loc);
        }
      }
    }

    try {
      final locations = await locationFromAddress(query);
      for (final loc in locations.take(5)) {
        try {
          final placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final pm = placemarks.first;
            String? city = pm.locality;
            if (city == null || city.isEmpty) {
              city = pm.subAdministrativeArea ?? pm.administrativeArea ?? pm.name;
            }
            final country = pm.country ?? '';

            if (city != null && city.isNotEmpty) {
              final key = '${loc.latitude.toStringAsFixed(2)}_${loc.longitude.toStringAsFixed(2)}';
              if (!seen.contains(key)) {
                seen.add(key);
                results.add(AppLocation(
                  latitude: loc.latitude,
                  longitude: loc.longitude,
                  city: city,
                  country: country,
                  label: '$city, $country',
                  isManual: true,
                ));
              }
            }
          }
        } catch (_) {
          // Reverse geocoding error fallback
        }
      }
    } catch (_) {
      // Global geocoding error fallback
    }

    return results;
  }
}
