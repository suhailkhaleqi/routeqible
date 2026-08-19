import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Standalone state/storage service handling Qada (make-up) prayer counts and persistence.
class QadaTrackerService extends ChangeNotifier {
  static const List<String> prayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  final Map<String, int> _counts = {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };

  bool _isInitialized = false;

  Map<String, int> get counts => Map.unmodifiable(_counts);

  int get totalOwed => _counts.values.fold(0, (sum, val) => sum + val);

  int getCount(String prayer) => _counts[prayer] ?? 0;

  Future<void> init() async {
    if (_isInitialized) return;
    await _loadCounts();
    _isInitialized = true;
  }

  Future<void> _loadCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final p in prayers) {
        final key = 'qada_${p.toLowerCase()}';
        _counts[p] = prefs.getInt(key) ?? 0;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> increment(String prayer) async {
    if (!_counts.containsKey(prayer)) return;
    _counts[prayer] = (_counts[prayer] ?? 0) + 1;
    notifyListeners();
    await _saveCount(prayer);
  }

  Future<void> decrement(String prayer) async {
    if (!_counts.containsKey(prayer)) return;
    final current = _counts[prayer] ?? 0;
    if (current <= 0) return;
    _counts[prayer] = current - 1;
    notifyListeners();
    await _saveCount(prayer);
  }

  Future<void> _saveCount(String prayer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'qada_${prayer.toLowerCase()}';
      await prefs.setInt(key, _counts[prayer] ?? 0);
    } catch (_) {}
  }
}
