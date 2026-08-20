class HijriDate {
  final int year;
  final int month;
  final int day;
  final String monthNameEnglish;
  final String monthNameTurkish;
  final String monthNameArabic;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
    required this.monthNameEnglish,
    required this.monthNameTurkish,
    required this.monthNameArabic,
  });

  String getMonthName(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'tr':
        return monthNameTurkish;
      case 'ar':
        return monthNameArabic;
      default:
        return monthNameEnglish;
    }
  }

  String formatFull(String langCode) {
    return '$day ${getMonthName(langCode)} $year AH';
  }
}

class IslamicEvent {
  final String titleEnglish;
  final String titleTurkish;
  final String titleArabic;
  final int hijriMonth;
  final int hijriDay;
  final String description;

  const IslamicEvent({
    required this.titleEnglish,
    required this.titleTurkish,
    required this.titleArabic,
    required this.hijriMonth,
    required this.hijriDay,
    required this.description,
  });

  String getTitle(String langCode) {
    switch (langCode.toLowerCase()) {
      case 'tr':
        return titleTurkish;
      case 'ar':
        return titleArabic;
      default:
        return titleEnglish;
    }
  }
}

class HijriCalendarService {
  static const List<String> _hijriMonthsEn = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Awwal',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah',
  ];

  static const List<String> _hijriMonthsTr = [
    'Muharrem',
    'Sefer',
    'Rebiülevvel',
    'Rebiülâhir',
    'Cemaziyelevvel',
    'Cemaziyelâhir',
    'Recep',
    'Şaban',
    'Ramazan',
    'Şevval',
    'Zilkade',
    'Zilhicce',
  ];

  static const List<String> _hijriMonthsAr = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static const List<IslamicEvent> islamicEvents = [
    IslamicEvent(
      titleEnglish: 'Islamic New Year 1448',
      titleTurkish: 'Hicri Yılbaşı 1448',
      titleArabic: 'رأس السنة الهجرية 1448',
      hijriMonth: 1,
      hijriDay: 1,
      description: '1st of Muharram — Beginning of the Hijri Year',
    ),
    IslamicEvent(
      titleEnglish: 'Day of Ashura',
      titleTurkish: 'Aşure Günü',
      titleArabic: 'يوم عاشوراء',
      hijriMonth: 1,
      hijriDay: 10,
      description: '10th of Muharram — Day of victory & gratitude',
    ),
    IslamicEvent(
      titleEnglish: 'Mawlid al-Nabi (Prophet\'s Birthday)',
      titleTurkish: 'Mevlid Kandili',
      titleArabic: 'مولد النبي ﷺ',
      hijriMonth: 3,
      hijriDay: 12,
      description: '12th of Rabi\' al-Awwal — Birth of Prophet Muhammad ﷺ',
    ),
    IslamicEvent(
      titleEnglish: 'Isra and Mi\'raj',
      titleTurkish: 'Miraç Kandili',
      titleArabic: 'الإسراء والمعراج',
      hijriMonth: 7,
      hijriDay: 27,
      description: '27th of Rajab — Night Journey of Prophet Muhammad ﷺ',
    ),
    IslamicEvent(
      titleEnglish: 'Night of Bara\'at (Mid-Sha\'ban)',
      titleTurkish: 'Berat Kandili',
      titleArabic: 'ليلة النصف من شعبان',
      hijriMonth: 8,
      hijriDay: 15,
      description: '15th of Sha\'ban — Night of forgiveness & prayer',
    ),
    IslamicEvent(
      titleEnglish: '1st Day of Ramadan',
      titleTurkish: 'Ramazan-ı Şerif Başlangıcı',
      titleArabic: 'أول أيام شهر رمضان',
      hijriMonth: 9,
      hijriDay: 1,
      description: '1st of Ramadan — Month of Fasting & Quran',
    ),
    IslamicEvent(
      titleEnglish: 'Laylat al-Qadr (Night of Power)',
      titleTurkish: 'Kadir Gecesi',
      titleArabic: 'ليلة القدر',
      hijriMonth: 9,
      hijriDay: 27,
      description: '27th of Ramadan — Night better than a thousand months',
    ),
    IslamicEvent(
      titleEnglish: 'Eid al-Fitr',
      titleTurkish: 'Ramazan Bayramı',
      titleArabic: 'عيد الفطر المبارك',
      hijriMonth: 10,
      hijriDay: 1,
      description: '1st of Shawwal — Celebration of completing Ramadan',
    ),
    IslamicEvent(
      titleEnglish: 'Day of Arafah',
      titleTurkish: 'Arefet Günü',
      titleArabic: 'يوم عرفة',
      hijriMonth: 12,
      hijriDay: 9,
      description: '9th of Dhu al-Hijjah — Pinnacle of Hajj pilgrimage',
    ),
    IslamicEvent(
      titleEnglish: 'Eid al-Adha',
      titleTurkish: 'Kurban Bayramı',
      titleArabic: 'عيد الأضحى المبارك',
      hijriMonth: 12,
      hijriDay: 10,
      description: '10th of Dhu al-Hijjah — Feast of Sacrifice',
    ),
  ];

  static HijriDate fromGregorian(DateTime date) {
    int y = date.year;
    int m = date.month;
    int d = date.day;

    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();
    int jdn = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524;

    int l = jdn - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) + (((l / 5670).floor()) * (((43 * l) / 15238).floor()));
    l = l - (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) - (((j / 16).floor()) * (((15238 * j) / 43).floor())) + 29;
    int mH = ((24 * l) / 709).floor();
    int dH = l - ((709 * mH) / 24).floor();
    int yH = 30 * n + j - 30;

    int safeMonth = mH.clamp(1, 12);
    int safeDay = dH.clamp(1, 30);

    return HijriDate(
      year: yH,
      month: safeMonth,
      day: safeDay,
      monthNameEnglish: _hijriMonthsEn[safeMonth - 1],
      monthNameTurkish: _hijriMonthsTr[safeMonth - 1],
      monthNameArabic: _hijriMonthsAr[safeMonth - 1],
    );
  }
}
