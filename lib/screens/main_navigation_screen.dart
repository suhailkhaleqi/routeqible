import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/constants/kaaba.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/models/prayer_times.dart';
import 'package:routeqible/screens/prayers_screen.dart';
import 'package:routeqible/screens/qibla_screen.dart';
import 'package:routeqible/screens/quran_screen.dart';
import 'package:routeqible/screens/settings_screen.dart';
import 'package:routeqible/services/compass_service.dart';
import 'package:routeqible/services/location_service.dart';
import 'package:routeqible/services/location_storage_service.dart';
import 'package:routeqible/services/permission_service.dart';
import 'package:routeqible/services/prayer_time_service.dart';
import 'package:routeqible/services/qibla_calculator.dart';
import 'package:routeqible/widgets/location_search_modal.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({
    super.key,
    this.permissionService,
    this.locationService,
    this.compassService,
    this.prayerTimeService,
    this.storageService,
  });

  final PermissionService? permissionService;
  final LocationService? locationService;
  final CompassService? compassService;
  final PrayerTimeService? prayerTimeService;
  final LocationStorageService? storageService;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  late final PermissionService _permissionService;
  late final LocationService _locationService;
  late final CompassService _compassService;
  late final PrayerTimeService _prayerTimeService;
  late final LocationStorageService _storageService;

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
    _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compassSubscription?.cancel();
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

  String get _guidanceText {
    final diff = _qiblaDiff;
    if (diff == null) return 'Calibrating compass...';
    final absDiff = diff.abs();
    if (absDiff <= _alignEnterThreshold) return "You're facing Qibla \u2713";
    if (absDiff <= 10) return 'Almost there \u2014 ${absDiff.round()}\u00b0';
    if (diff > 0) return 'Turn right ${absDiff.round()}\u00b0';
    return 'Turn left ${absDiff.round()}\u00b0';
  }

  @override
  Widget build(BuildContext context) {
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
            guidanceText: _guidanceText,
            showCalibrationHint: _showCalibrationHint,
            onTapSearchLocation: _openLocationSearch,
            distanceToKaabaKm: _distanceToKaabaKm,
            isLoading: _isLoading,
            onRefresh: _loadData,
          ),
          // 1: Prayers (Prayer Times Screen)
          PrayersScreen(
            location: _location,
            prayerTimes: _prayerTimes,
            onTapSearchLocation: _openLocationSearch,
            distanceToKaabaKm: _distanceToKaabaKm,
            isLoading: _isLoading,
            onRefresh: _loadData,
          ),
          // 2: Quran (Placeholder Screen)
          const QuranScreen(),
          // 3: Settings (Placeholder Screen)
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.tealAccent,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mosque_outlined),
              activeIcon: Icon(Icons.mosque),
              label: 'Prayers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Quran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
