import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:routeqible/constants/kaaba.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/models/prayer_times.dart';
import 'package:routeqible/services/compass_service.dart';
import 'package:routeqible/services/location_service.dart';
import 'package:routeqible/services/location_storage_service.dart';
import 'package:routeqible/services/permission_service.dart';
import 'package:routeqible/services/prayer_time_service.dart';
import 'package:routeqible/services/qibla_calculator.dart';
import 'package:routeqible/widgets/compass_arrow.dart';
import 'package:routeqible/widgets/location_card.dart';
import 'package:routeqible/widgets/location_search_modal.dart';
import 'package:routeqible/widgets/prayer_times_list.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({
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
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with WidgetsBindingObserver {
  late final PermissionService _permissionService;
  late final LocationService _locationService;
  late final CompassService _compassService;
  late final PrayerTimeService _prayerTimeService;
  late final LocationStorageService _storageService;

  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _isLoading = true;
  String? _errorMessage;
  bool _permissionDenied = false;

  AppLocation? _location;
  DailyPrayerTimes? _prayerTimes;
  double? _qiblaBearing;
  double? _distanceToKaabaKm;

  double? _smoothedHeading;
  bool _showCalibrationHint = false;

  bool _isAligned = false;
  static const double _alignEnterThreshold = 3.0;
  static const double _alignExitThreshold = 5.0;
  bool _wasAligned = false;

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
      _errorMessage = null;
      _permissionDenied = false;
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
          _permissionDenied = true;
          _errorMessage = 'Location permission is required to show Qibla direction and prayer times.';
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
        _errorMessage = 'Location services are turned off. Please enable GPS and try again.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to get your location. Please try again.';
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

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteQible'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting location...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return _ErrorView(
        message: _errorMessage!,
        permissionDenied: _permissionDenied,
        onRetry: _loadData,
      );
    }

    if (_location == null || _qiblaBearing == null || _prayerTimes == null) {
      return _ErrorView(
        message: 'Something went wrong. Please try again.',
        onRetry: _loadData,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          LocationCard(
            location: _location!,
            onTapSearch: _openLocationSearch,
            distanceToKaabaKm: _distanceToKaabaKm,
          ),
          const SizedBox(height: 16),
          CompassArrow(
            qiblaBearing: _qiblaBearing!,
            deviceHeading: _smoothedHeading,
            qiblaDiff: _qiblaDiff,
            isAligned: _isAligned,
            guidanceText: _guidanceText,
            showCalibrationHint: _showCalibrationHint,
            locationLabel: _location?.displayLabel,
          ),
          const SizedBox(height: 16),
          PrayerTimesList(prayerTimes: _prayerTimes!),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    this.permissionDenied = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool permissionDenied;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              permissionDenied ? Icons.location_off : Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
