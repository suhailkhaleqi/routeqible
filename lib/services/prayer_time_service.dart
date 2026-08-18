import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:routeqible/models/prayer_times.dart';

class PrayerTimeService {
  DailyPrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) {
    final targetDate = date ?? DateTime.now();
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();
    final prayerTimes = PrayerTimes(
      coordinates,
      DateComponents.from(targetDate),
      params,
    );

    final timeFormat = DateFormat.Hm();
    final entries = <PrayerTimeEntry>[
      _entry(
        PrayerName.fajr,
        'Fajr',
        prayerTimes.fajr,
        timeFormat,
      ),
      _entry(
        PrayerName.dhuhr,
        'Dhuhr',
        prayerTimes.dhuhr,
        timeFormat,
      ),
      _entry(
        PrayerName.asr,
        'Asr',
        prayerTimes.asr,
        timeFormat,
      ),
      _entry(
        PrayerName.maghrib,
        'Maghrib',
        prayerTimes.maghrib,
        timeFormat,
      ),
      _entry(
        PrayerName.isha,
        'Isha',
        prayerTimes.isha,
        timeFormat,
      ),
    ];

    return DailyPrayerTimes(
      prayers: entries,
      nextPrayer: _nextPrayer(entries, targetDate),
    );
  }

  PrayerTimeEntry _entry(
    PrayerName name,
    String displayName,
    DateTime time,
    DateFormat timeFormat,
  ) {
    return PrayerTimeEntry(
      name: name,
      time: time,
      displayName: displayName,
      formattedTime: timeFormat.format(time),
    );
  }

  PrayerName? _nextPrayer(List<PrayerTimeEntry> prayers, DateTime now) {
    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) {
        return prayer.name;
      }
    }
    return null;
  }
}
