import 'package:routeqible/models/quran/quran_chapter.dart';
import 'package:routeqible/models/quran/quran_verse.dart';
import 'package:routeqible/services/quran_api_service.dart';

/// Repository managing Al Quran Cloud API calls & in-memory caching.
class QuranRepository {
  final QuranApiService _apiService;

  // In-Memory Caches (No database used)
  List<QuranChapter>? _surahsCache;
  final Map<int, List<QuranVerse>> _versesCache = {};

  QuranRepository({QuranApiService? apiService})
      : _apiService = apiService ?? QuranApiService();

  /// Retrieves the list of all 114 Surahs metadata from Al Quran Cloud API.
  Future<List<QuranChapter>> getSurahs({bool forceRefresh = false}) async {
    if (!forceRefresh && _surahsCache != null && _surahsCache!.isNotEmpty) {
      return _surahsCache!;
    }
    final surahs = await _apiService.fetchSurahs();
    _surahsCache = surahs;
    return surahs;
  }

  /// Retrieves verses (Arabic Uthmani + English Sahih International) for a specific Surah.
  Future<List<QuranVerse>> getSurahVerses(int surahNumber, {bool forceRefresh = false}) async {
    if (!forceRefresh && _versesCache.containsKey(surahNumber) && _versesCache[surahNumber]!.isNotEmpty) {
      return _versesCache[surahNumber]!;
    }
    final verses = await _apiService.fetchSurahVerses(surahNumber);
    _versesCache[surahNumber] = verses;
    return verses;
  }

  /// Instant local filtering of the loaded 114 Surah list.
  /// Filters by Surah number, English name, Arabic name, or translation title.
  List<QuranChapter> filterSurahsLocally(List<QuranChapter> surahs, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return surahs;

    return surahs.where((chapter) {
      final matchesNumber = chapter.number.toString() == q || chapter.formattedNumber == q;
      final matchesEnglish = chapter.englishName.toLowerCase().contains(q) ||
          chapter.englishNameTranslation.toLowerCase().contains(q);
      final matchesArabic = chapter.name.contains(q);

      return matchesNumber || matchesEnglish || matchesArabic;
    }).toList();
  }

  /// Clears in-memory caches.
  void clearMemoryCache() {
    _surahsCache = null;
    _versesCache.clear();
  }
}
