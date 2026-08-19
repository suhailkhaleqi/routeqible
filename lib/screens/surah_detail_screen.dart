import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/models/quran/quran_chapter.dart';
import 'package:routeqible/models/quran/quran_verse.dart';
import 'package:routeqible/services/quran_api_service.dart';
import 'package:routeqible/services/quran_repository.dart';
import 'package:routeqible/widgets/quran/verse_tile.dart';

/// Screen for reading the verses of a selected Surah loaded from Al Quran Cloud API.
class SurahDetailScreen extends StatefulWidget {
  final QuranChapter chapter;
  final QuranRepository? repository;

  const SurahDetailScreen({
    super.key,
    required this.chapter,
    this.repository,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late final QuranRepository _repository;
  bool _isLoading = true;
  String? _errorMessage;
  List<QuranVerse> _verses = [];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? QuranRepository();
    _loadVerses();
  }

  Future<void> _loadVerses({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verses = await _repository.getSurahVerses(
        widget.chapter.number,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _verses = verses;
        _isLoading = false;
      });
    } on QuranApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load Surah. Please check your internet connection.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;

    return Scaffold(
      appBar: AppBar(
        title: Text(chapter.englishName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _loadVerses(forceRefresh: true),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildReaderContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.tealAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading ${widget.chapter.englishName}...',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unable to load Quran content.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadVerses(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tealAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReaderContent() {
    final chapter = widget.chapter;

    return CustomScrollView(
      slivers: [
        // Header Banner Card
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.darkBrownStart,
                  AppColors.darkBrownEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.goldBright.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  chapter.name,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldBright,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  chapter.englishName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (chapter.englishNameTranslation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    chapter.englishNameTranslation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMetaChip('${chapter.numberOfAyahs} Verses'),
                    if (chapter.revelationTypeFormatted.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildMetaChip(chapter.revelationTypeFormatted),
                    ],
                    const SizedBox(width: 8),
                    _buildMetaChip('Surah ${chapter.formattedNumber}'),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Verses List (Lazy Rendered via SliverList)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return VerseTile(verse: _verses[index]);
            },
            childCount: _verses.length,
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );
  }

  Widget _buildMetaChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
