import 'dart:math';

import 'package:routeqible/constants/kaaba.dart';

/// Returns the initial great-circle bearing from [latitude]/[longitude] to the Kaaba.
double calculateQiblaBearing(double latitude, double longitude) {
  final lat1 = _toRadians(latitude);
  final lat2 = _toRadians(kaabaLatitude);
  final deltaLng = _toRadians(kaabaLongitude - longitude);

  final y = sin(deltaLng) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);
  final bearing = atan2(y, x);

  return (_toDegrees(bearing) + 360) % 360;
}

double _toRadians(double degrees) => degrees * pi / 180;

double _toDegrees(double radians) => radians * 180 / pi;
