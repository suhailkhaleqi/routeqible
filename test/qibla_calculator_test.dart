import 'package:flutter_test/flutter_test.dart';
import 'package:routeqible/services/qibla_calculator.dart';

void main() {
  group('calculateQiblaBearing', () {
    test('returns bearing toward Kaaba from Istanbul', () {
      // Istanbul coordinates
      const latitude = 41.0082;
      const longitude = 28.9784;

      final bearing = calculateQiblaBearing(latitude, longitude);

      expect(bearing, greaterThan(150));
      expect(bearing, lessThan(165));
    });

    test('returns bearing toward Kaaba from London', () {
      const latitude = 51.5074;
      const longitude = -0.1278;

      final bearing = calculateQiblaBearing(latitude, longitude);

      expect(bearing, greaterThan(110));
      expect(bearing, lessThan(125));
    });

    test('returns value in 0-360 range', () {
      final bearing = calculateQiblaBearing(-33.8688, 151.2093);

      expect(bearing, greaterThanOrEqualTo(0));
      expect(bearing, lessThan(360));
    });
  });
}
