import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/constants/kaaba.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/core/localization/language_service.dart';
import 'package:routeqible/core/theme/theme_service.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/models/prayer_times.dart';
import 'package:routeqible/screens/menu_screen.dart';
import 'package:routeqible/screens/prayers_screen.dart';
import 'package:routeqible/screens/qibla_screen.dart';
import 'package:routeqible/screens/quran_screen.dart';
import 'package:routeqible/screens/settings_screen.dart';
import 'package:routeqible/services/compass_service.dart';
import 'package:routeqible/services/location_service.dart';
import 'package:routeqible/services/location_storage_service.dart';
import 'package:routeqible/services/notification_service.dart';
import 'package:routeqible/services/permission_service.dart';
import 'package:routeqible/services/prayer_time_service.dart';
import 'package:routeqible/services/prayer_tracker_service.dart';
import 'package:routeqible/services/qada_tracker_service.dart';
import 'package:routeqible/services/qibla_calculator.dart';
import 'package:routeqible/widgets/location_search_modal.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    required this.themeService,
    required this.languageService,
    required this.notificationService,
    required this.trackerService,
    required this.qadaService,
    this.permissionService,
    this.locationService,
    this.compassService,
    this.prayerTimeService,
    this.storageService,
  });

  final ThemeService themeService;
  final LanguageService languageService;
  final NotificationService notificationService;
  final PrayerTrackerService trackerService;
  final QadaTrackerService qadaService;
  final PermissionService? permissionService;
  final LocationService? locationService;
  final CompassService? compassService;
  final PrayerTimeService? prayerTimeService;
  final LocationStorageService? storageService;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final PermissionService _permissionService;
  late final LocationService _locationService;
  late final CompassService _compassService;
  late final PrayerTimeService _prayerTimeService;
  late final LocationStorageService _storageService;

  late final AnimationController _rotationController;

  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _isLoading = true;
  AppLocation? _location;
  DailyPrayerTimes? _prayerTimes;
  double? _qiblaBearing;
  double? _distanceToKaabaKm;

  // Heading & Compass sensor state
  double? _smoothedHeading;
  bool _showCalibrationHint = false;
  bool _isAligned = false;
  bool _wasAligned = false;

  static const double _alignEnterThreshold = 3.0;
  static const double _alignExitThreshold = 5.0;
  static const double _lpfAlpha = 0.2;
  static const double _poorAccuracyThreshold = 20.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionService = widget.permissionService ?? PermissionService();
    _locationService = widget.locationService ?? LocationService();
    _compassService = widget.compassService ?? CompassService();
    _prayerTimeService = widget.prayerTimeService ?? PrayerTimeService();
    _storageService = widget.storageService ?? LocationStorageService();

    // Continuous rotation controller for outer center menu ring
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compassSubscription?.cancel();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _initialize() async {
    await _loadData();
    _startCompass();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final savedLocation = await _storageService.loadSavedLocation();
    if (savedLocation != null && savedLocation.isManual) {
      if (!mounted) return;
      _applyLocationData(savedLocation);
      return;
    }

    await _loadGpsLocation();
  }

  Future<void> _loadGpsLocation() async {
    try {
      var hasPermission = await _permissionService.hasLocationPermission();
      if (!hasPermission) {
        hasPermission = await _permissionService.requestLocationPermission();
      }

      if (!hasPermission) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final location = await _locationService.getCurrentLocation();
      if (!mounted) return;
      _applyLocationData(location);
    } on LocationServiceDisabledException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyLocationData(AppLocation location) {
    final qiblaBearing = calculateQiblaBearing(
      location.latitude,
      location.longitude,
    );
    final prayerTimes = _prayerTimeService.calculatePrayerTimes(
      latitude: location.latitude,
      longitude: location.longitude,
      countryName: location.displayCountry,
      cityName: location.displayCity,
      isManual: location.isManual,
      customUtcOffset: location.customUtcOffset,
    );
    final distanceMeters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      kaabaLatitude,
      kaabaLongitude,
    );

    setState(() {
      _location = location;
      _qiblaBearing = qiblaBearing;
      _prayerTimes = prayerTimes;
      _distanceToKaabaKm = distanceMeters / 1000;
      _isLoading = false;
    });

    // Schedule local prayer notifications asynchronously
    widget.notificationService.schedulePrayerNotifications(
      prayerTimes: prayerTimes,
      cityName: location.displayCity,
    );
  }

  void _onSelectManualLocation(AppLocation loc) {
    _applyLocationData(loc);
    _storageService.saveLocation(loc);
  }

  Future<void> _onUseCurrentLocation() async {
    await _storageService.clearSavedLocation();
    await _loadGpsLocation();
  }

  void _openLocationSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSearchModal(
        onSelectLocation: _onSelectManualLocation,
        onUseCurrentLocation: _onUseCurrentLocation,
      ),
    );
  }

  void _startCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = _compassService.eventStream.listen((event) {
      if (!mounted) return;
      final raw = event.heading;
      if (raw == null) return;

      double smoothed;
      if (_smoothedHeading == null) {
        smoothed = raw;
      } else {
        double delta = raw - _smoothedHeading!;
        if (delta > 180) delta -= 360;
        if (delta < -180) delta += 360;
        smoothed = (_smoothedHeading! + _lpfAlpha * delta + 360) % 360;
      }

      final acc = event.accuracy;
      final poorAccuracy = acc != null && acc > _poorAccuracyThreshold;

      bool aligned = _isAligned;
      final bearing = _qiblaBearing;
      if (bearing != null) {
        final diff = _shortestAngle(bearing, smoothed).abs();
        if (!aligned && diff <= _alignEnterThreshold) aligned = true;
        if (aligned && diff > _alignExitThreshold) aligned = false;

        if (aligned && !_wasAligned) {
          HapticFeedback.mediumImpact();
        }
      }

      setState(() {
        _smoothedHeading = smoothed;
        _showCalibrationHint = poorAccuracy;
        _isAligned = aligned;
        _wasAligned = aligned;
      });
    });
  }

  static double _shortestAngle(double target, double current) {
    return ((target - current + 540) % 360) - 180;
  }

  double? get _qiblaDiff {
    if (_qiblaBearing == null || _smoothedHeading == null) return null;
    return _shortestAngle(_qiblaBearing!, _smoothedHeading!);
  }

  String getGuidanceText(AppLocalizations l10n) {
    final diff = _qiblaDiff;
    if (diff == null) return l10n.calibratingCompass;
    final absDiff = diff.abs();
    if (absDiff <= _alignEnterThreshold) return l10n.facingQibla;
    if (absDiff <= 10) return '${l10n.almostThere} \u2014 ${absDiff.round()}\u00b0';
    if (diff > 0) return '${l10n.turnRight} ${absDiff.round()}\u00b0';
    return '${l10n.turnLeft} ${absDiff.round()}\u00b0';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final navTheme = theme.bottomNavigationBarTheme;
    final navBgColor = navTheme.backgroundColor ?? theme.colorScheme.surface;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 0: Home (Qibla Screen)
          QiblaScreen(
            location: _location,
            qiblaBearing: _qiblaBearing,
            deviceHeading: _smoothedHeading,
            qiblaDiff: _qiblaDiff,
            isAligned: _isAligned,
            guidanceText: getGuidanceText(l10n),
            showCalibrationHint: _showCalibrationHint,
            onTapSearchLocation: _openLocationSearch,
            prayerTimes: _prayerTimes,
            distanceToKaabaKm: _distanceToKaabaKm,
            isLoading: _isLoading,
            onRefresh: _loadData,
          ),
          // 1: Prayers (Prayer Times Screen)
          PrayersScreen(
            location: _location,
            prayerTimes: _prayerTimes,
            onTapSearchLocation: _openLocationSearch,
            trackerService: widget.trackerService,
            prayerTimeService: _prayerTimeService,
            qadaService: widget.qadaService,
            distanceToKaabaKm: _distanceToKaabaKm,
            isLoading: _isLoading,
            onRefresh: _loadData,
          ),
          // 2: Menu Screen (Center Tab)
          MenuScreen(),
          // 3: Quran Screen
          const QuranScreen(),
          // 4: Settings Screen
          SettingsScreen(
            themeService: widget.themeService,
            languageService: widget.languageService,
            notificationService: widget.notificationService,
            location: _location,
            onTapSearchLocation: _openLocationSearch,
            distanceToKaabaKm: _distanceToKaabaKm,
          ),
        ],
      ),

      // Custom 5-Item Bottom Navigation Bar featuring Elevated Animated Center Menu
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: navBgColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 0: Home Tab
            Expanded(
              child: _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: l10n.home,
                index: 0,
                theme: theme,
              ),
            ),
            // 1: Prayers Tab
            Expanded(
              child: _buildNavItem(
                icon: Icons.mosque_outlined,
                activeIcon: Icons.mosque,
                label: l10n.prayers,
                index: 1,
                theme: theme,
              ),
            ),

            // 2: Elevated Animated Center Menu Tab
            Expanded(
              child: _buildCenterMenuTab(
                label: l10n.menu,
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ),

            // 3: Quran Tab
            Expanded(
              child: _buildNavItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book,
                label: l10n.quran,
                index: 3,
                theme: theme,
              ),
            ),
            // 4: Settings Tab
            Expanded(
              child: _buildNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: l10n.settings,
                index: 4,
                theme: theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required ThemeData theme,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? (Theme.of(context).bottomNavigationBarTheme.selectedItemColor ?? AppColors.tealAccent)
        : (Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? theme.colorScheme.onSurfaceVariant);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterMenuTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating elevated circular button container
          Transform.translate(
            offset: const Offset(0, -10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Continuous rotating outer translucent ring
                RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFE5B842).withValues(alpha: isSelected ? 0.8 : 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 2,
                          left: 23,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5B842),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          left: 23,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5B842),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 23,
                          left: 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5B842),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 23,
                          right: 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE5B842),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Inner Warm Gold Circle Button
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5B842),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE5B842).withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: Color(0xFF0F2218),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Label
          Transform.translate(
            offset: const Offset(0, -6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFFE5B842) : const Color(0xFFE5B842).withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
