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

    String? label;
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final parts = <String>[
          if (placemark.locality != null && placemark.locality!.isNotEmpty)
            placemark.locality!,
          if (placemark.country != null && placemark.country!.isNotEmpty)
            placemark.country!,
        ];
        if (parts.isNotEmpty) {
          label = parts.join(', ');
        }
      }
    } catch (_) {
      // Geocoding is optional; coordinates are enough for v1.
    }

    return AppLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      label: label,
    );
  }
}
