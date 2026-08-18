enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

class PrayerTimeEntry {
  const PrayerTimeEntry({
    required this.name,
    required this.time,
    required this.displayName,
    required this.formattedTime,
  });

  final PrayerName name;
  final DateTime time;
  final String displayName;
  final String formattedTime;
}

class DailyPrayerTimes {
  const DailyPrayerTimes({
    required this.prayers,
    required this.nextPrayer,
  });

  final List<PrayerTimeEntry> prayers;
  final PrayerName? nextPrayer;
}
