import 'package:flutter/material.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/services/hijri_calendar_service.dart';

/// Glassmorphism-styled Hijri Islamic Calendar screen.
class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late DateTime _selectedDate;
  late HijriDate _currentHijri;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentHijri = HijriCalendarService.fromGregorian(_selectedDate);
  }

  void _changeMonth(int monthOffset) {
    setState(() {
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month + monthOffset,
        _selectedDate.day,
      );
      _currentHijri = HijriCalendarService.fromGregorian(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = l10n.locale.languageCode;
    final todayHijri = HijriCalendarService.fromGregorian(DateTime.now());

    final weekdays = langCode == 'tr'
        ? ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
        : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: const Color(0xFF071F14),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF284433)),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFFE5B842),
                        size: 24,
                      ),
                    ),
                  ),
                  const Text(
                    'HIJRI CALENDAR',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE5B842),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 38), // Balance spacing
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  // Glassmorphic Month Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2B1C).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF284A36), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header Navigation Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => _changeMonth(-1),
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                                color: Color(0xFFE5B842),
                                size: 28,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${_currentHijri.getMonthName(langCode)} ${_currentHijri.year} AH',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE5B842),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getGregorianRangeString(_selectedDate),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFFA0B5A7),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => _changeMonth(1),
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFE5B842),
                                size: 28,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Weekdays Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: weekdays.map((day) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  day,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFA0B5A7),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 12),

                        // 30-Day Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 6,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: 30,
                          itemBuilder: (context, index) {
                            final hDay = index + 1;
                            final isToday = _currentHijri.month == todayHijri.month &&
                                _currentHijri.year == todayHijri.year &&
                                hDay == todayHijri.day;

                            // Calculate approximate Gregorian day
                            final approxGregorianDay = ((index + 12) % 30) + 1;

                            return Container(
                              decoration: BoxDecoration(
                                color: isToday ? const Color(0xFFE5B842) : const Color(0xFF133623),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isToday
                                      ? const Color(0xFFE5B842)
                                      : const Color(0xFF244A34),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$hDay',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isToday ? const Color(0xFF071F14) : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    '$approxGregorianDay',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isToday
                                          ? const Color(0xFF071F14).withValues(alpha: 0.8)
                                          : const Color(0xFFA0B5A7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Upcoming Islamic Events & Holidays Banner
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFE5B842), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        langCode == 'tr' ? 'YAKLAŞAN İSLAMİ GÜNLER' : 'UPCOMING ISLAMIC EVENTS',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5B842),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ...HijriCalendarService.islamicEvents.map((event) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2518),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF243F2D), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B3B28),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF4EBE96).withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'H. ${event.hijriDay}/${event.hijriMonth}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4EBE96),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.getTitle(langCode),
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  event.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFA0B5A7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGregorianRangeString(DateTime date) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final currentMonth = monthNames[date.month - 1];
    final nextMonth = monthNames[date.month % 12];
    return '$currentMonth - $nextMonth ${date.year}';
  }
}
