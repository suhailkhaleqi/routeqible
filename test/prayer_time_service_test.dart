import 'package:flutter_test/flutter_test.dart';
import 'package:routeqible/models/prayer_times.dart';
import 'package:routeqible/services/prayer_time_service.dart';

void main() {
  group('PrayerTimeService', () {
    late PrayerTimeService service;

    setUp(() {
      service = PrayerTimeService();
    });

    test('returns five daily prayers for a fixed location and date', () {
      final result = service.calculatePrayerTimes(
        latitude: 41.0082,
        longitude: 28.9784,
        date: DateTime(2026, 8, 18),
      );

      expect(result.prayers, hasLength(5));
      expect(result.prayers.map((p) => p.displayName), [
        'Fajr',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ]);
    });

    test('formats prayer times as HH:mm', () {
      final result = service.calculatePrayerTimes(
        latitude: 41.0082,
        longitude: 28.9784,
        date: DateTime(2026, 8, 18),
      );

      final timePattern = RegExp(r'^\d{1,2}:\d{2}$');
      for (final prayer in result.prayers) {
        expect(prayer.formattedTime, matches(timePattern));
      }
    });

    test('marks next upcoming prayer when before Dhuhr', () {
      final noon = DateTime(2026, 8, 18, 10, 0);
      final result = service.calculatePrayerTimes(
        latitude: 41.0082,
        longitude: 28.9784,
        date: noon,
      );

      expect(result.nextPrayer, isNotNull);
      expect(
        result.nextPrayer,
        isIn([
          PrayerName.fajr,
          PrayerName.dhuhr,
          PrayerName.asr,
          PrayerName.maghrib,
          PrayerName.isha,
        ]),
      );
    });
  });
}
