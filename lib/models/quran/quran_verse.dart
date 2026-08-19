/// Represents an individual Ayah (Verse) combining Arabic Uthmani text & Translation.
class QuranVerse {
  final int number; // Global verse number
  final int numberInSurah; // Verse index inside the Surah (1, 2, ...)
  final String textArabic; // Arabic text (quran-uthmani)
  final String translationText; // Translation text (e.g., en.sahih)
  final int juz;
  final int page;

  const QuranVerse({
    required this.number,
    required this.numberInSurah,
    required this.textArabic,
    required this.translationText,
    this.juz = 1,
    this.page = 1,
  });

  factory QuranVerse.fromEditions({
    required Map<String, dynamic> arabicAyah,
    required Map<String, dynamic> translationAyah,
  }) {
    return QuranVerse(
      number: arabicAyah['number'] is int
          ? arabicAyah['number']
          : int.tryParse(arabicAyah['number']?.toString() ?? '0') ?? 0,
      numberInSurah: arabicAyah['numberInSurah'] is int
          ? arabicAyah['numberInSurah']
          : int.tryParse(arabicAyah['numberInSurah']?.toString() ?? '0') ?? 0,
      textArabic: arabicAyah['text']?.toString() ?? '',
      translationText: translationAyah['text']?.toString() ?? '',
      juz: arabicAyah['juz'] is int ? arabicAyah['juz'] : 1,
      page: arabicAyah['page'] is int ? arabicAyah['page'] : 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'numberInSurah': numberInSurah,
      'textArabic': textArabic,
      'translationText': translationText,
      'juz': juz,
      'page': page,
    };
  }
}
