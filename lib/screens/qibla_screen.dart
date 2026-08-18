import 'dart:async';

import 'package:flutter/material.dart';
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

  StreamSubscription<double?>? _compassSubscription;

  bool _isLoading = true;
  String? _errorMessage;
  bool _permissionDenied = false;

  AppLocation? _location;
  DailyPrayerTimes? _prayerTimes;
  double? _qiblaBearing;
  double? _deviceHeading;
  double? _distanceToKaabaKm;

  double? _lastHeading;
  static const double _headingDeadZone = 5;

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
    _compassSubscription = _compassService.headingStream.listen((heading) {
      if (!mounted || heading == null) return;

      if (_lastHeading != null) {
        final delta = (heading - _lastHeading!).abs();
        if (delta < _headingDeadZone) return;
      }

      _lastHeading = heading;
      setState(() => _deviceHeading = heading);
    });
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
          Center(
            child: CompassArrow(
              qiblaBearing: _qiblaBearing!,
              deviceHeading: _deviceHeading,
            ),
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
