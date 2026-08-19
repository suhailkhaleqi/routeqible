/// Represents a Surah (Chapter) metadata from Al Quran Cloud API.
class QuranChapter {
  final int number;
  final String name; // Arabic name, e.g., "سُورَةُ ٱلْفَاتِحَةِ"
  final String englishName; // e.g., "Al-Faatiha"
  final String englishNameTranslation; // e.g., "The Opening"
  final int numberOfAyahs;
  final String revelationType; // "Meccan" or "Medinan"

  const QuranChapter({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory QuranChapter.fromJson(Map<String, dynamic> json) {
    return QuranChapter(
      number: json['number'] is int
          ? json['number']
          : int.tryParse(json['number']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      englishName: json['englishName']?.toString() ?? '',
      englishNameTranslation: json['englishNameTranslation']?.toString() ?? '',
      numberOfAyahs: json['numberOfAyahs'] is int
          ? json['numberOfAyahs']
          : int.tryParse(json['numberOfAyahs']?.toString() ?? '0') ?? 0,
      revelationType: json['revelationType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'name': name,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'numberOfAyahs': numberOfAyahs,
      'revelationType': revelationType,
    };
  }

  String get revelationTypeFormatted {
    if (revelationType.isEmpty) return '';
    return '${revelationType[0].toUpperCase()}${revelationType.substring(1)}';
  }

  String get formattedNumber => number.toString().padLeft(2, '0');
}
