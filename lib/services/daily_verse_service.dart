import 'package:shared_preferences/shared_preferences.dart';

class DailyVerse {
  final int surahNumber;
  final int ayahNumber;
  final String surahNameEnglish;
  final String surahNameTurkish;
  final String surahNameArabic;
  final String arabicText;
  final String englishTranslation;
  final String turkishTranslation;
  final String arabicTranslation;

  const DailyVerse({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahNameEnglish,
    required this.surahNameTurkish,
    required this.surahNameArabic,
    required this.arabicText,
    required this.englishTranslation,
    required this.turkishTranslation,
    required this.arabicTranslation,
  });

  String getReference(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'tr':
        return '$surahNameTurkish Suresi $ayahNumber. Ayet';
      case 'ar':
        return 'سورة $surahNameArabic $ayahNumber';
      default:
        return 'Qur\'an $surahNumber:$ayahNumber';
    }
  }

  String getTranslation(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'tr':
        return turkishTranslation;
      case 'ar':
        return arabicTranslation;
      default:
        return englishTranslation;
    }
  }
}

class DailyVerseService {
  static const List<DailyVerse> _curatedVerses = [
    DailyVerse(
      surahNumber: 8,
      ayahNumber: 28,
      surahNameEnglish: 'An-Anfal',
      surahNameTurkish: 'Enfâl',
      surahNameArabic: 'الأنفال',
      arabicText: 'وَاعْلَمُوا أَنَّمَا أَمْوَالُكُمْ وَأَوْلَادُكُمْ فِتْنَةٌ وَأَنَّ اللَّهَ عِنْدَهُ أَجْرٌ عَظِيمٌ',
      englishTranslation: '"And know that your properties and your children are but a trial and that Allah has with Him a great reward."',
      turkishTranslation: '"Bilin ki mallarınız ve çocuklarınız ancak birer imtihandır. Büyük mükâfat ise Allah katındadır."',
      arabicTranslation: '"واعملوا أنما أموالكم وأولادكم فتنة وأن الله عنده أجر عظيم"',
    ),
    DailyVerse(
      surahNumber: 2,
      ayahNumber: 152,
      surahNameEnglish: 'Al-Baqarah',
      surahNameTurkish: 'Bakara',
      surahNameArabic: 'البقرة',
      arabicText: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      englishTranslation: '"So remember Me; I will remember you. And be grateful to Me and do not deny Me."',
      turkishTranslation: '"Beni anın ki Ben de sizi anayım. Bana şükredin, nankörlük etmeyin."',
      arabicTranslation: '"فاذكروني أذكركم واشكروا لي ولا تكفرون"',
    ),
    DailyVerse(
      surahNumber: 94,
      ayahNumber: 5,
      surahNameEnglish: 'Ash-Sharh',
      surahNameTurkish: 'İnşirâh',
      surahNameArabic: 'الشرح',
      arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      englishTranslation: '"For indeed, with hardship will come ease. Indeed, with hardship will come ease."',
      turkishTranslation: '"Şüphesiz zorlukla beraber bir kolaylık vardır. Gerçekten zorlukla beraber bir kolaylık vardır."',
      arabicTranslation: '"فإن مع العسر يسرا إن مع العسر يسرا"',
    ),
    DailyVerse(
      surahNumber: 13,
      ayahNumber: 28,
      surahNameEnglish: 'Ar-Ra\'d',
      surahNameTurkish: 'Ra\'d',
      surahNameArabic: 'الرعد',
      arabicText: 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      englishTranslation: '"Unquestionably, by the remembrance of Allah do hearts find peace."',
      turkishTranslation: '"Bilin ki kalpler ancak Allah\'ı anmakla huzur bulur."',
      arabicTranslation: '"ألا بذكر الله تطمئن القلوب"',
    ),
    DailyVerse(
      surahNumber: 3,
      ayahNumber: 139,
      surahNameEnglish: 'Ali \'Imran',
      surahNameTurkish: 'Âl-i İmrân',
      surahNameArabic: 'آل عمران',
      arabicText: 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنْتُمُ الْأَعْلَوْنَ إِنْ كُنْتُمْ مُؤْمِنِينَ',
      englishTranslation: '"So do not weaken and do not grieve, and you will be superior if you are true believers."',
      turkishTranslation: '"Gevşemeyin, üzülmeyin! Eğer inanıyorsanız üstün olan sizsiniz."',
      arabicTranslation: '"ولا تهنوا ولا تحزنوا وأنتم الأعلون إن كنتم مؤمنين"',
    ),
    DailyVerse(
      surahNumber: 65,
      ayahNumber: 2,
      surahNameEnglish: 'At-Talaq',
      surahNameTurkish: 'Talâq',
      surahNameArabic: 'الطلاق',
      arabicText: 'وَمَنْ يَتَّقِ اللَّهَ يَجْعَلْ لَهُ مَخْرَجًا ۝ وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ',
      englishTranslation: '"And whoever fears Allah - He will make for him a way out and will provide for him from where he does not expect."',
      turkishTranslation: '"Kim Allah\'a karşı gelmekten sakınırsa, Allah ona bir çıkış yolu ihsan eder ve ona beklemediği yerden rızık verir."',
      arabicTranslation: '"ومن يتق الله يجعل له مخرجا ويرزقه من حيث لا يحتسب"',
    ),
  ];

  /// Returns today's Verse of the Day deterministically based on the calendar date.
  DailyVerse getTodayVerse({DateTime? date}) {
    final now = date ?? DateTime.now();
    final dayOfYear = DateTime(now.year, now.month, now.day)
        .difference(DateTime(now.year, 1, 1))
        .inDays;
    final index = dayOfYear % _curatedVerses.length;
    return _curatedVerses[index];
  }

  /// Syncs the current daily verse data to shared storage for native Android/iOS home screen widgets.
  Future<void> syncToHomeScreenWidget(String languageCode) async {
    try {
      final verse = getTodayVerse();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('widget_verse_arabic', verse.arabicText);
      await prefs.setString('widget_verse_translation', verse.getTranslation(languageCode));
      await prefs.setString('widget_verse_reference', verse.getReference(languageCode));
    } catch (_) {}
  }
}
