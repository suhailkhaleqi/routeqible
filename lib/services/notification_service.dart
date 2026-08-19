import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:routeqible/models/prayer_times.dart';

/// Standalone, modular service responsible for managing prayer time notification preferences,
/// requesting native permissions, and scheduling local alarms via flutter_local_notifications.
class NotificationService extends ChangeNotifier {
  static const String _keyMasterEnabled = 'app_prayer_notifications_enabled';
  static const String _keyNotifyFajr = 'app_notify_fajr';
  static const String _keyNotifyDhuhr = 'app_notify_dhuhr';
  static const String _keyNotifyAsr = 'app_notify_asr';
  static const String _keyNotifyMaghrib = 'app_notify_maghrib';
  static const String _keyNotifyIsha = 'app_notify_isha';

  static const String _channelId = 'prayer_notifications_channel';
  static const String _channelName = 'Prayer Notifications';
  static const String _channelDescription = 'Notifications for daily Islamic prayer times';

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _masterEnabled = true;
  final Map<String, bool> _prayerPreferences = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  bool get masterEnabled => _masterEnabled;
  Map<String, bool> get prayerPreferences => Map.unmodifiable(_prayerPreferences);

  /// Initializes timezone data, notifications plugin, and loads stored user preferences.
  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    await _loadPreferences();

    _isInitialized = true;
  }

  /// Loads stored notification preferences from SharedPreferences.
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _masterEnabled = prefs.getBool(_keyMasterEnabled) ?? true;
      _prayerPreferences['Fajr'] = prefs.getBool(_keyNotifyFajr) ?? true;
      _prayerPreferences['Dhuhr'] = prefs.getBool(_keyNotifyDhuhr) ?? true;
      _prayerPreferences['Asr'] = prefs.getBool(_keyNotifyAsr) ?? true;
      _prayerPreferences['Maghrib'] = prefs.getBool(_keyNotifyMaghrib) ?? true;
      _prayerPreferences['Isha'] = prefs.getBool(_keyNotifyIsha) ?? true;
      notifyListeners();
    } catch (_) {
      // Preference fallback
    }
  }

  /// Requests notification permissions for Android 13+ and iOS.
  Future<bool> requestPermissions() async {
    bool granted = false;
    try {
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        granted = status.isGranted;

        final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        if (androidImpl != null) {
          await androidImpl.requestNotificationsPermission();
          await androidImpl.requestExactAlarmsPermission();
        }
      } else if (Platform.isIOS) {
        final iosImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
        if (iosImpl != null) {
          final res = await iosImpl.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          granted = res ?? false;
        }
      }
    } catch (_) {
      // Permission request error fallback
    }
    return granted;
  }

  /// Toggles master notification switch and persists state.
  Future<void> setMasterEnabled(bool enabled, {DailyPrayerTimes? currentPrayerTimes, String? cityName}) async {
    if (_masterEnabled == enabled) return;

    _masterEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyMasterEnabled, enabled);
    } catch (_) {}

    if (enabled) {
      await requestPermissions();
      if (currentPrayerTimes != null && cityName != null) {
        await schedulePrayerNotifications(prayerTimes: currentPrayerTimes, cityName: cityName);
      }
    } else {
      await cancelAllNotifications();
    }
  }

  /// Toggles notification preference for an individual prayer.
  Future<void> setPrayerEnabled(String prayerName, bool enabled, {DailyPrayerTimes? currentPrayerTimes, String? cityName}) async {
    if (!_prayerPreferences.containsKey(prayerName)) return;
    if (_prayerPreferences[prayerName] == enabled) return;

    _prayerPreferences[prayerName] = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      switch (prayerName) {
        case 'Fajr':
          await prefs.setBool(_keyNotifyFajr, enabled);
          break;
        case 'Dhuhr':
          await prefs.setBool(_keyNotifyDhuhr, enabled);
          break;
        case 'Asr':
          await prefs.setBool(_keyNotifyAsr, enabled);
          break;
        case 'Maghrib':
          await prefs.setBool(_keyNotifyMaghrib, enabled);
          break;
        case 'Isha':
          await prefs.setBool(_keyNotifyIsha, enabled);
          break;
      }
    } catch (_) {}

    if (_masterEnabled && currentPrayerTimes != null && cityName != null) {
      await schedulePrayerNotifications(prayerTimes: currentPrayerTimes, cityName: cityName);
    }
  }

  /// Cancels all scheduled local notifications.
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }

  /// Schedules exact local notifications for the 5 daily prayer times based on city schedule.
  Future<void> schedulePrayerNotifications({
    required DailyPrayerTimes prayerTimes,
    required String cityName,
  }) async {
    await init();
    await cancelAllNotifications();

    if (!_masterEnabled) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('adhan'),
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = DateTime.now();
    int notificationId = 100;

    for (final prayer in prayerTimes.prayers) {
      final isPrayerEnabled = _prayerPreferences[prayer.displayName] ?? true;
      if (!isPrayerEnabled) continue;

      final pTime = prayer.time;
      if (pTime.isAfter(now)) {
        try {
          final scheduledTime = tz.TZDateTime.from(pTime, tz.local);
          await _notificationsPlugin.zonedSchedule(
            notificationId++,
            'Time for ${prayer.displayName}',
            'It is now prayer time for ${prayer.displayName} in $cityName.',
            scheduledTime,
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (_) {
          // Fallback if exact alarm permissions or schedule failed
        }
      }
    }
  }
}
