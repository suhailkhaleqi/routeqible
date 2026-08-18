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
import 'package:routeqible/services/permission_service.dart';
import 'package:routeqible/services/prayer_time_service.dart';
import 'package:routeqible/services/qibla_calculator.dart';
import 'package:routeqible/widgets/compass_arrow.dart';
import 'package:routeqible/widgets/location_card.dart';
import 'package:routeqible/widgets/prayer_times_list.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({
    super.key,
    this.permissionService,
    this.locationService,
    this.compassService,
    this.prayerTimeService,
  });

  final PermissionService? permissionService;
  final LocationService? locationService;
  final CompassService? compassService;
  final PrayerTimeService? prayerTimeService;

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with WidgetsBindingObserver {
  late final PermissionService _permissionService;
  late final LocationService _locationService;
  late final CompassService _compassService;
  late final PrayerTimeService _prayerTimeService;

  StreamSubscription<CompassEvent>? _compassSubscription;

  bool _isLoading = true;
  String? _errorMessage;
  bool _permissionDenied = false;

  AppLocation? _location;
  DailyPrayerTimes? _prayerTimes;
  double? _qiblaBearing;
  double? _distanceToKaabaKm;

  // ── Heading state ──────────────────────────────────────────────────────────
  // Smoothed heading from circular low-pass filter (true-north, 0-360).
  double? _smoothedHeading;

  // Sensor accuracy in ±degrees — drives the calibration hint.
  // Whether compass accuracy is poor enough to show a calibration hint.
  bool _showCalibrationHint = false;

  // ── Alignment hysteresis ───────────────────────────────────────────────────
  // Use a two-threshold approach: enter aligned at ≤3°, exit at >5°.
  // This prevents flickering when hovering right at the boundary.
  bool _isAligned = false;
  static const double _alignEnterThreshold = 3.0;
  static const double _alignExitThreshold = 5.0;

  // Fire haptics only on the transition into aligned.
  bool _wasAligned = false;

  // ── Low-pass filter ────────────────────────────────────────────────────────
  // Alpha=0.2: 20% of gap closed per tick. Responsive yet smooth.
  static const double _lpfAlpha = 0.2;

  // ── Accuracy threshold ─────────────────────────────────────────────────────
  // Show calibration hint when accuracy error > 20°.
  static const double _poorAccuracyThreshold = 20.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionService = widget.permissionService ?? PermissionService();
    _locationService = widget.locationService ?? LocationService();
    _compassService = widget.compassService ?? CompassService();
    _prayerTimeService = widget.prayerTimeService ?? PrayerTimeService();
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

      if (!mounted) return;

      setState(() {
        _location = location;
        _qiblaBearing = qiblaBearing;
        _prayerTimes = prayerTimes;
        _distanceToKaabaKm = distanceMeters / 1000;
        _isLoading = false;
      });
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

  void _startCompass() {
    _compassSubscription?.cancel();
    _compassSubscription = _compassService.eventStream.listen((event) {
      if (!mounted) return;
      final raw = event.heading;
      if (raw == null) return;

      // ── Circular low-pass filter ────────────────────────────────────────
      // Standard linear averaging fails near the 0°/360° boundary
      // (e.g. averaging 359° and 1° naively gives 180°). We normalise the
      // delta to [-180, 180] first so the blend always takes the short arc.
      double smoothed;
      if (_smoothedHeading == null) {
        smoothed = raw;
      } else {
        double delta = raw - _smoothedHeading!;
        // Normalise delta to [-180, 180].
        if (delta > 180) delta -= 360;
        if (delta < -180) delta += 360;
        smoothed = (_smoothedHeading! + _lpfAlpha * delta + 360) % 360;
      }

      // ── Accuracy / calibration hint ─────────────────────────────────────
      final acc = event.accuracy;
      final poorAccuracy = acc != null && acc > _poorAccuracyThreshold;

      // ── Alignment with hysteresis ───────────────────────────────────────
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

  // ── Angle maths ─────────────────────────────────────────────────────────

  /// Returns the signed shortest-arc difference from [current] to [target],
  /// in the range [-180, 180].
  /// Positive  → turn right (clockwise).
  /// Negative  → turn left  (counter-clockwise).
  static double _shortestAngle(double target, double current) {
    return ((target - current + 540) % 360) - 180;
  }

  /// Signed difference between Qibla and current heading [-180, 180].
  double? get _qiblaDiff {
    if (_qiblaBearing == null || _smoothedHeading == null) return null;
    return _shortestAngle(_qiblaBearing!, _smoothedHeading!);
  }

  /// Human-readable turn instruction.
  String get _guidanceText {
    final diff = _qiblaDiff;
    if (diff == null) return 'Calibrating compass...';
    final absDiff = diff.abs();
    if (absDiff <= _alignEnterThreshold) return "You're facing Qibla ✓";
    if (absDiff <= 10) return 'Almost there — ${absDiff.round()}°';
    if (diff > 0) return 'Turn right ${absDiff.round()}°';
    return 'Turn left ${absDiff.round()}°';
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
            Text('Getting your location...'),
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
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          LocationCard(
            location: _location!,
            distanceToKaabaKm: _distanceToKaabaKm,
          ),
          const SizedBox(height: 24),
          CompassArrow(
            qiblaBearing: _qiblaBearing!,
            deviceHeading: _smoothedHeading,
            qiblaDiff: _qiblaDiff,
            isAligned: _isAligned,
            guidanceText: _guidanceText,
            showCalibrationHint: _showCalibrationHint,
            locationLabel: _location?.label,
          ),
          const SizedBox(height: 24),
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
