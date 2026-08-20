/// Service for resolving accurate target location UTC timezone offsets.
class TimezoneService {
  /// Returns the Duration offset from UTC for a given location.
  static Duration getUtcOffset({
    required double latitude,
    required double longitude,
    String? country,
    String? city,
    bool isManual = false,
  }) {
    if (!isManual) {
      // Current GPS location: use physical device's active timezone offset
      return DateTime.now().timeZoneOffset;
    }

    final c = country?.toLowerCase().trim() ?? '';

    // United States & Canada timezone offsets (by longitude / country)
    if (c.contains('united states') ||
        c.contains('america') ||
        c.contains('usa') ||
        c.contains('canada') ||
        c == 'us' ||
        c == 'ca') {
      if (longitude > -80) {
        // Eastern Time (New York, Boston, Miami, Washington) -> UTC-4 (EDT) / UTC-5 (EST)
        return const Duration(hours: -4);
      } else if (longitude > -95) {
        // Central Time (Chicago, Houston, Dallas) -> UTC-5 (CDT)
        return const Duration(hours: -5);
      } else if (longitude > -110) {
        // Mountain Time (Denver, Phoenix) -> UTC-6 (MDT)
        return const Duration(hours: -6);
      } else {
        // Pacific Time (Los Angeles, San Francisco, Seattle) -> UTC-7 (PDT)
        return const Duration(hours: -7);
      }
    }

    // Türkiye (UTC+3)
    if (c.contains('turkey') ||
        c.contains('türkiye') ||
        c.contains('turkiye') ||
        c == 'tr') {
      return const Duration(hours: 3);
    }

    // Saudi Arabia & Gulf Cooperation Council (Makkah, Madinah, Riyadh, Dubai, Qatar, Kuwait) -> UTC+3
    if (c.contains('saudi') ||
        c.contains('arabia') ||
        c.contains('makkah') ||
        c.contains('mecca') ||
        c.contains('uae') ||
        c.contains('emirates') ||
        c.contains('dubai') ||
        c.contains('qatar') ||
        c.contains('kuwait') ||
        c.contains('bahrain') ||
        c == 'sa' ||
        c == 'ae') {
      return const Duration(hours: 3);
    }

    // United Kingdom / Ireland -> UTC+1 (BST) / UTC+0 (GMT)
    if (c.contains('united kingdom') ||
        c.contains('uk') ||
        c.contains('england') ||
        c.contains('ireland') ||
        c == 'gb') {
      return const Duration(hours: 1);
    }

    // Western & Central Europe (France, Germany, Italy, Spain, Netherlands, Belgium, Austria) -> UTC+2 (CEST)
    if (c.contains('france') ||
        c.contains('germany') ||
        c.contains('italy') ||
        c.contains('spain') ||
        c.contains('netherlands') ||
        c.contains('belgium') ||
        c.contains('switzerland') ||
        c.contains('austria') ||
        c == 'fr' ||
        c == 'de' ||
        c == 'it' ||
        c == 'es') {
      return const Duration(hours: 2);
    }

    // Egypt / Jordan / Lebanon / Palestine / Syria -> UTC+3
    if (c.contains('egypt') ||
        c.contains('jordan') ||
        c.contains('lebanon') ||
        c.contains('palestine') ||
        c.contains('syria') ||
        c == 'eg') {
      return const Duration(hours: 3);
    }

    // Pakistan -> UTC+5
    if (c.contains('pakistan') || c == 'pk') {
      return const Duration(hours: 5);
    }

    // India & Sri Lanka -> UTC+5:30
    if (c.contains('india') || c.contains('sri lanka') || c == 'in') {
      return const Duration(hours: 5, minutes: 30);
    }

    // Bangladesh -> UTC+6
    if (c.contains('bangladesh') || c == 'bd') {
      return const Duration(hours: 6);
    }

    // Indonesia -> UTC+7 (Western / Jakarta) / UTC+8 (Central / Bali)
    if (c.contains('indonesia') || c == 'id') {
      return longitude > 115 ? const Duration(hours: 8) : const Duration(hours: 7);
    }

    // Japan & Korea -> UTC+9
    if (c.contains('japan') || c.contains('korea') || c == 'jp' || c == 'kr') {
      return const Duration(hours: 9);
    }

    // Australia (Sydney / Melbourne) -> UTC+10
    if (c.contains('australia') || c == 'au') {
      return const Duration(hours: 10);
    }

    // General fallback: mathematical offset based on longitude (15 degrees = 1 hour)
    final hoursOffset = (longitude / 15.0).round();
    return Duration(hours: hoursOffset);
  }
}
