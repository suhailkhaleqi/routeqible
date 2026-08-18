import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routeqible/main.dart';
import 'package:routeqible/models/app_location.dart';
import 'package:routeqible/services/compass_service.dart';
import 'package:routeqible/services/location_service.dart';
import 'package:routeqible/services/permission_service.dart';
import 'package:routeqible/services/prayer_time_service.dart';
import 'package:routeqible/screens/qibla_screen.dart';

class _FakePermissionService extends PermissionService {
  @override
  Future<bool> hasLocationPermission() async => true;

  @override
  Future<bool> requestLocationPermission() async => true;
}

class _FakeLocationService extends LocationService {
  @override
  Future<AppLocation> getCurrentLocation() async {
    return const AppLocation(
      latitude: 41.0082,
      longitude: 28.9784,
      label: 'Istanbul, Turkey',
    );
  }
}

class _FakeCompassService extends CompassService {
  @override
  Stream<double?> get headingStream => Stream.value(90.0);
}

void main() {
  testWidgets('RouteQible home screen loads location and prayer times',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QiblaScreen(
          permissionService: _FakePermissionService(),
          locationService: _FakeLocationService(),
          compassService: _FakeCompassService(),
          prayerTimeService: PrayerTimeService(),
        ),
      ),
    );

    expect(find.text('Getting your location...'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('RouteQible'), findsOneWidget);
    expect(find.text('Istanbul, Turkey'), findsOneWidget);
    expect(find.text('Prayer Times'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
  });

  testWidgets('RouteQible app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RouteQibleApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
