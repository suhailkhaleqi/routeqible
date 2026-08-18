import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routeqible/models/app_location.dart';

class LocationService {
  Future<AppLocation> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    String? city;
    String? country;
    String? label;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        city = placemark.locality;
        if (city == null || city.isEmpty) {
          city = placemark.subAdministrativeArea ?? placemark.administrativeArea;
        }
        country = placemark.country;
        final parts = <String>[
          if (city != null && city.isNotEmpty) city,
          if (country != null && country.isNotEmpty) country,
        ];
        if (parts.isNotEmpty) {
          label = parts.join(', ');
        }
      }
    } catch (_) {
      // Geocoding is optional; coordinates are enough.
    }

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
      country: country,
      label: label,
      isManual: false,
    );
  }
}
