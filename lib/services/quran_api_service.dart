import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:routeqible/models/quran/quran_chapter.dart';
import 'package:routeqible/models/quran/quran_verse.dart';

/// Custom exception thrown when Quran API operations fail.
class QuranApiException implements Exception {
  final String message;
  final int? statusCode;

  QuranApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'QuranApiException: $message (Status: $statusCode)';
}

/// Service for interacting directly with the official Al Quran Cloud REST API (https://api.alquran.cloud).
class QuranApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  final http.Client _client;

  QuranApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mobile-friendly HTTP headers with standard User-Agent
  Map<String, String> get _standardHeaders => const {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Linux; Android 11; RouteQible) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      };

  /// Helper to perform HTTP GET with automatic retries and mobile timeout protection.
  Future<http.Response> _getWithRetry(
    Uri uri, {
    Duration timeout = const Duration(seconds: 25),
    int maxAttempts = 3,
  }) async {
    String? lastErrorMsg;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        debugPrint('[QuranApiService] Attempt $attempt GET $uri');
        final response = await _client.get(uri, headers: _standardHeaders).timeout(timeout);

        if (response.statusCode == 200) {
          return response;
        }

        if (response.statusCode == 429) {
          throw QuranApiException('Rate limit exceeded (429). Please wait a moment and try again.', 429);
        }

        lastErrorMsg = 'Server returned HTTP ${response.statusCode}';
      } on SocketException catch (e) {
        lastErrorMsg = 'Network connection issue: ${e.message}';
        debugPrint('[QuranApiService] SocketException on attempt $attempt: $e');
      } on TimeoutException {
        lastErrorMsg = 'Request timed out while connecting to Quran API';
        debugPrint('[QuranApiService] TimeoutException on attempt $attempt');
      } catch (e) {
        if (e is QuranApiException) rethrow;
        lastErrorMsg = 'Unable to connect to Quran service: $e';
        debugPrint('[QuranApiService] Exception on attempt $attempt: $e');
      }

      if (attempt < maxAttempts) {
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    throw QuranApiException(
      lastErrorMsg ?? 'Unable to connect to Quran API. Please check your internet connection and try again.',
    );
  }

  /// Fetches all 114 Surahs metadata from Al Quran Cloud API (`GET /v1/surah`).
  Future<List<QuranChapter>> fetchSurahs() async {
    final uri = Uri.parse('$baseUrl/surah');
    final response = await _getWithRetry(uri, timeout: const Duration(seconds: 25));

    final data = json.decode(response.body);
    if (data is Map && data['code'] == 200 && data['data'] is List) {
      final List rawList = data['data'];
      return rawList.map((e) => QuranChapter.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    throw QuranApiException('Invalid Surah response format from server');
  }

  /// Fetches Arabic Uthmani text & English translation for a specific Surah
  /// using the combined multi-edition endpoint (`GET /v1/surah/{number}/editions/{editions}`).
  Future<List<QuranVerse>> fetchSurahVerses(
    int surahNumber, {
    String arabicEdition = 'quran-uthmani',
    String translationEdition = 'en.sahih',
  }) async {
    final uri = Uri.parse('$baseUrl/surah/$surahNumber/editions/$arabicEdition,$translationEdition');
    final response = await _getWithRetry(uri, timeout: const Duration(seconds: 30));

    final data = json.decode(response.body);
    if (data is Map && data['code'] == 200 && data['data'] is List) {
      final List editionsData = data['data'];
      if (editionsData.length >= 2) {
        final Map<String, dynamic> arabicEditionObj = editionsData[0];
        final Map<String, dynamic> translationEditionObj = editionsData[1];

        final List arabicAyahs = arabicEditionObj['ayahs'] as List? ?? [];
        final List translationAyahs = translationEditionObj['ayahs'] as List? ?? [];

        final List<QuranVerse> verses = [];
        final minLength = arabicAyahs.length < translationAyahs.length
            ? arabicAyahs.length
            : translationAyahs.length;

        for (int i = 0; i < minLength; i++) {
          verses.add(QuranVerse.fromEditions(
            arabicAyah: Map<String, dynamic>.from(arabicAyahs[i]),
            translationAyah: Map<String, dynamic>.from(translationAyahs[i]),
          ));
        }

        return verses;
      }
    }

    throw QuranApiException('Failed to load Surah $surahNumber content from server');
  }
}
