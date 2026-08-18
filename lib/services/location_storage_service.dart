import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:routeqible/models/app_location.dart';

class LocationStorageService {
  static const String _storageKey = 'selected_app_location';

  Future<void> saveLocation(AppLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(location.toJson());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {
      // Storage error fallback
    }
  }

  Future<AppLocation?> loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        return AppLocation.fromJson(map);
      }
    } catch (_) {
      // Storage error fallback
    }
    return null;
  }

  Future<void> clearSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {
      // Storage error fallback
    }
  }
}
