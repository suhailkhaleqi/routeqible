import 'dart:async';
import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/services/location_search_service.dart';

class LocationSearchModal extends StatefulWidget {
  const LocationSearchModal({
    super.key,
    required this.onSelectLocation,
    required this.onUseCurrentLocation,
    this.searchService,
  });

  final ValueChanged<AppLocation> onSelectLocation;
  final VoidCallback onUseCurrentLocation;
  final LocationSearchService? searchService;

  @override
  State<LocationSearchModal> createState() => _LocationSearchModalState();
}

class _LocationSearchModalState extends State<LocationSearchModal> {
  late final LocationSearchService _searchService;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  bool _isSearching = false;
  List<AppLocation> _results = [];
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchService = widget.searchService ?? LocationSearchService();
    _performSearch('a');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
        _hasSearched = false;
        _errorMessage = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final res = await _searchService.searchLocations(query);
      if (!mounted) return;
      setState(() {
        _results = res;
        _isSearching = false;
        _hasSearched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _errorMessage = 'Unable to search locations. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header title & close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              onChanged: _onQueryChanged,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search city or country...',
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7)),
                prefixIcon: const Icon(Icons.search, color: AppColors.tealAccent),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _controller.clear();
                          _onQueryChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.tealAccent, width: 1.5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Use Current Location Option
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                widget.onUseCurrentLocation();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.tealAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.tealAccent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.my_location, color: AppColors.tealAccent, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use my current location',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.tealAccent,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Detect coordinates automatically via GPS',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.tealAccent),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceBorder, height: 1),

          // Search results or loading state
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.tealAccent),
            SizedBox(height: 12),
            Text(
              'Searching locations...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.orange),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_hasSearched && _results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.search_off, size: 44, color: AppColors.textSecondary),
              SizedBox(height: 12),
              Text(
                'No locations found.',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Try searching for a city or country name.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      separatorBuilder: (context, index) => const Divider(color: AppColors.surfaceBorder, height: 1, indent: 56),
      itemBuilder: (context, index) {
        final loc = _results[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_city_outlined, color: AppColors.tealAccent, size: 20),
          ),
          title: Text(
            loc.displayCity,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            loc.displayCountry.isNotEmpty ? loc.displayCountry : '${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(Icons.north_west, size: 16, color: AppColors.textSecondary),
          onTap: () {
            Navigator.of(context).pop();
            widget.onSelectLocation(loc);
          },
        );
      },
    );
  }
}
