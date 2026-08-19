import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Standalone state/storage service handling daily prayer logging, progress, and streak tracking.
class PrayerTrackerService extends ChangeNotifier {
  static const List<String> obligatoryPrayers = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
  ];

  Map<String, Set<String>> _loggedPrayersByDate = {};
  int _currentStreak = 0;
  bool _isInitialized = false;

  int get currentStreak => _currentStreak;

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> init() async {
    if (_isInitialized) return;
    await _loadState();
    _isInitialized = true;
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('tracker_'));

      final map = <String, Set<String>>{};
      for (final key in keys) {
        final dateKey = key.replaceFirst('tracker_', '');
        final list = prefs.getStringList(key) ?? [];
        map[dateKey] = list.toSet();
      }

      _loggedPrayersByDate = map;
      _recalculateStreak();
      notifyListeners();
    } catch (_) {}
  }

  /// Returns whether a prayer is completed for the specified date (defaults to today).
  bool isPrayerCompleted(String prayerName, {DateTime? date}) {
    final key = _formatDateKey(date ?? DateTime.now());
    return _loggedPrayersByDate[key]?.contains(prayerName) ?? false;
  }

  /// Returns the number of completed obligatory prayers (0..5) for a date.
  int getCompletedCount({DateTime? date}) {
    final key = _formatDateKey(date ?? DateTime.now());
    final set = _loggedPrayersByDate[key];
    if (set == null) return 0;
    return obligatoryPrayers.where((p) => set.contains(p)).length;
  }

  /// Toggles completion of a prayer and updates streak & persistence.
  Future<void> togglePrayer(String prayerName, {DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final key = _formatDateKey(targetDate);

    final set = Set<String>.from(_loggedPrayersByDate[key] ?? {});
    if (set.contains(prayerName)) {
      set.remove(prayerName);
    } else {
      set.add(prayerName);
    }

    _loggedPrayersByDate[key] = set;
    _recalculateStreak();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('tracker_$key', set.toList());
    } catch (_) {}
  }

  /// Recalculates consecutive daily completion streak.
  void _recalculateStreak() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    int streak = 0;

    // Check if today is completed (5/5)
    final todayKey = _formatDateKey(todayDate);
    final todaySet = _loggedPrayersByDate[todayKey] ?? {};
    final isTodayComplete = obligatoryPrayers.every((p) => todaySet.contains(p));

    if (isTodayComplete) {
      streak++;
    }

    // Iterate backwards from yesterday
    DateTime checkDate = todayDate.subtract(const Duration(days: 1));
    while (true) {
      final key = _formatDateKey(checkDate);
      final set = _loggedPrayersByDate[key] ?? {};
      final isComplete = obligatoryPrayers.every((p) => set.contains(p));

      if (isComplete) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    _currentStreak = streak;
  }
}
