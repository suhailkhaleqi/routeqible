import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/models/quran/quran_chapter.dart';
import 'package:routeqible/screens/surah_detail_screen.dart';
import 'package:routeqible/services/quran_api_service.dart';
import 'package:routeqible/services/quran_repository.dart';
import 'package:routeqible/widgets/quran/surah_list_tile.dart';

/// Main screen for the Quran section, displaying the 114 Surahs from Al Quran Cloud with live search.
class QuranScreen extends StatefulWidget {
  final QuranRepository? repository;

  const QuranScreen({
    super.key,
    this.repository,
  });

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late final QuranRepository _repository;

  bool _isLoading = true;
  String? _errorMessage;

  List<QuranChapter> _allChapters = [];
  List<QuranChapter> _filteredChapters = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? QuranRepository();
    _loadChapters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChapters({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final chapters = await _repository.getSurahs(forceRefresh: forceRefresh);
      if (!mounted) return;
      setState(() {
        _allChapters = chapters;
        _filteredChapters = chapters;
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
        _errorMessage = null;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredChapters = _repository.filterSurahsLocally(_allChapters, query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredChapters = _allChapters;
    });
  }

  void _openSurahDetail(QuranChapter chapter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SurahDetailScreen(
          chapter: chapter,
          repository: _repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = (theme.cardTheme.shape as RoundedRectangleBorder?)?.side.color ?? theme.dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quran),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.retry,
            onPressed: () => _loadChapters(forceRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 15),
              decoration: InputDecoration(
                hintText: l10n.searchQuran,
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.tealAccent),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: borderColor, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.tealAccent, width: 1.5),
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: _isLoading
                ? _buildLoadingState(l10n, theme)
                : _errorMessage != null
                    ? _buildErrorState(l10n, theme)
                    : _buildSurahList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.tealAccent),
          const SizedBox(height: 16),
          Text(
            l10n.loadingQuran,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? l10n.unableToLoadQuran,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadChapters(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
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

  Widget _buildSurahList(ThemeData theme) {
    if (_filteredChapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No Surah matching "${_searchController.text}"',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _filteredChapters.length,
      itemBuilder: (context, index) {
        final chapter = _filteredChapters[index];
        return SurahListTile(
          chapter: chapter,
          onTap: () => _openSurahDetail(chapter),
        );
      },
    );
  }
}
