import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:routeqible/models/prayer_times.dart';

class PrayerTimeService {
  /// Dynamically resolves accurate calculation parameters based on geographic location/country.
  CalculationParameters resolveCalculationParameters({
    required double latitude,
    required double longitude,
    String? countryName,
    Madhab madhab = Madhab.shafi,
  }) {
    final country = countryName?.toLowerCase().trim() ?? '';
    CalculationParameters params;

    if (country.contains('turkey') ||
        country.contains('türkiye') ||
        country.contains('turkiye') ||
        country == 'tr') {
      params = CalculationMethod.turkey.getParameters();
    } else if (country.contains('saudi') ||
        country.contains('makkah') ||
        country.contains('mecca') ||
        country.contains('arabia') ||
        country == 'sa') {
      params = CalculationMethod.umm_al_qura.getParameters();
    } else if (country.contains('egypt') ||
        country.contains('cairo') ||
        country == 'eg') {
      params = CalculationMethod.egyptian.getParameters();
    } else if (country.contains('pakistan') ||
        country.contains('india') ||
        country.contains('bangladesh') ||
        country == 'pk' ||
        country == 'in' ||
        country == 'bd') {
      params = CalculationMethod.karachi.getParameters();
    } else if (country.contains('dubai') ||
        country.contains('uae') ||
        country.contains('emirates') ||
        country == 'ae') {
      params = CalculationMethod.dubai.getParameters();
    } else if (country.contains('qatar') || country == 'qa') {
      params = CalculationMethod.qatar.getParameters();
    } else if (country.contains('kuwait') || country == 'kw') {
      params = CalculationMethod.kuwait.getParameters();
    } else if (country.contains('states') ||
        country.contains('canada') ||
        country.contains('america') ||
        country == 'us' ||
        country == 'ca') {
      params = CalculationMethod.north_america.getParameters();
    } else {
      params = CalculationMethod.muslim_world_league.getParameters();
    }

    params.madhab = madhab;
    params.highLatitudeRule = HighLatitudeRule.middle_of_the_night;
    return params;
  }

  DailyPrayerTimes calculatePrayerTimes({
    required double latitude,
    required double longitude,
    String? countryName,
    DateTime? date,
    Madhab madhab = Madhab.shafi,
  }) {
    final targetDate = date ?? DateTime.now();
    final coordinates = Coordinates(latitude, longitude);
    final params = resolveCalculationParameters(
      latitude: latitude,
      longitude: longitude,
      countryName: countryName,
      madhab: madhab,
    );

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
        PrayerName.sunrise,
        'Sunrise',
        prayerTimes.sunrise,
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
      date: targetDate,
    );
  }

  /// Calculates prayer times for every day of the given month using accurate location parameters.
  List<DailyPrayerTimes> calculateMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    String? countryName,
    DateTime? monthDate,
    Madhab madhab = Madhab.shafi,
  }) {
    final refDate = monthDate ?? DateTime.now();
    final daysInMonth = DateTime(refDate.year, refDate.month + 1, 0).day;
    final monthlyList = <DailyPrayerTimes>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(refDate.year, refDate.month, day);
      final dailyTimes = calculatePrayerTimes(
        latitude: latitude,
        longitude: longitude,
        countryName: countryName,
        date: date,
        madhab: madhab,
      );
      monthlyList.add(dailyTimes);
    }

    return monthlyList;
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
