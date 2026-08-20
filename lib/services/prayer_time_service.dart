import 'package:adhan/adhan.dart';
import 'package:routeqible/models/prayer_times.dart';
import 'package:routeqible/services/timezone_service.dart';

class PrayerTimeService {
  /// Dynamically resolves accurate regional calculation parameters based on country/region.
  CalculationParameters resolveCalculationParameters({
    required double latitude,
    required double longitude,
    String? countryName,
    Madhab madhab = Madhab.shafi,
  }) {
    final country = countryName?.toLowerCase().trim() ?? '';
    CalculationParameters params;

    if (country.contains('united states') ||
        country.contains('america') ||
        country.contains('usa') ||
        country.contains('canada') ||
        country == 'us' ||
        country == 'ca') {
      params = CalculationMethod.north_america.getParameters();
    } else if (country.contains('turkey') ||
        country.contains('türkiye') ||
        country.contains('turkiye') ||
        country == 'tr') {
      params = CalculationMethod.turkey.getParameters();
    } else if (country.contains('saudi') ||
        country.contains('makkah') ||
        country.contains('mecca') ||
        country.contains('arabia') ||
        country.contains('uae') ||
        country.contains('emirates') ||
        country.contains('dubai') ||
        country.contains('qatar') ||
        country.contains('kuwait') ||
        country.contains('bahrain') ||
        country == 'sa' ||
        country == 'ae') {
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
    String? cityName,
    bool isManual = false,
    Duration? customUtcOffset,
    DateTime? date,
    Madhab madhab = Madhab.shafi,
  }) {
    final utcOffset = customUtcOffset ??
        TimezoneService.getUtcOffset(
          latitude: latitude,
          longitude: longitude,
          country: countryName,
          city: cityName,
          isManual: isManual,
        );

    final nowUtc = DateTime.now().toUtc();
    final targetNow = nowUtc.add(utcOffset);
    final targetDate = date ?? targetNow;

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

    final entries = <PrayerTimeEntry>[
      _entry(
        PrayerName.fajr,
        'Fajr',
        prayerTimes.fajr,
        utcOffset,
      ),
      _entry(
        PrayerName.sunrise,
        'Sunrise',
        prayerTimes.sunrise,
        utcOffset,
      ),
      _entry(
        PrayerName.dhuhr,
        'Dhuhr',
        prayerTimes.dhuhr,
        utcOffset,
      ),
      _entry(
        PrayerName.asr,
        'Asr',
        prayerTimes.asr,
        utcOffset,
      ),
      _entry(
        PrayerName.maghrib,
        'Maghrib',
        prayerTimes.maghrib,
        utcOffset,
      ),
      _entry(
        PrayerName.isha,
        'Isha',
        prayerTimes.isha,
        utcOffset,
      ),
    ];

    return DailyPrayerTimes(
      prayers: entries,
      nextPrayer: _nextPrayer(entries, targetNow),
      date: targetDate,
    );
  }

  /// Calculates prayer times for every day of the given month using accurate location parameters and timezone offsets.
  List<DailyPrayerTimes> calculateMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    String? countryName,
    String? cityName,
    bool isManual = false,
    Duration? customUtcOffset,
    DateTime? monthDate,
    Madhab madhab = Madhab.shafi,
  }) {
    final utcOffset = customUtcOffset ??
        TimezoneService.getUtcOffset(
          latitude: latitude,
          longitude: longitude,
          country: countryName,
          city: cityName,
          isManual: isManual,
        );

    final nowUtc = DateTime.now().toUtc();
    final targetNow = nowUtc.add(utcOffset);
    final refDate = monthDate ?? targetNow;
    final daysInMonth = DateTime(refDate.year, refDate.month + 1, 0).day;
    final monthlyList = <DailyPrayerTimes>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(refDate.year, refDate.month, day);
      final dailyTimes = calculatePrayerTimes(
        latitude: latitude,
        longitude: longitude,
        countryName: countryName,
        cityName: cityName,
        isManual: isManual,
        customUtcOffset: utcOffset,
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
    DateTime rawTime,
    Duration utcOffset,
  ) {
    // rawTime is in UTC from adhan library
    final utcTime = rawTime.toUtc();
    // Convert to target city local time by adding target UTC offset
    final targetLocalTime = utcTime.add(utcOffset);
    final hours = targetLocalTime.hour.toString().padLeft(2, '0');
    final minutes = targetLocalTime.minute.toString().padLeft(2, '0');
    final formattedTime = '$hours:$minutes';

    return PrayerTimeEntry(
      name: name,
      time: targetLocalTime,
      displayName: displayName,
      formattedTime: formattedTime,
    );
  }

  PrayerName? _nextPrayer(List<PrayerTimeEntry> prayers, DateTime targetNow) {
    for (final prayer in prayers) {
      if (prayer.time.isAfter(targetNow)) {
        return prayer.name;
      }
    }
    return null;
  }
}
