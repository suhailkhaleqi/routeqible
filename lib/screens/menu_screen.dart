import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/screens/hijri_calendar_screen.dart';
import 'package:routeqible/screens/tasbih_screen.dart';
import 'package:routeqible/services/daily_verse_service.dart';
import 'package:routeqible/widgets/verse_of_the_day_card.dart';

/// Menu screen displaying the dynamic "Verse of the Day" header card along with upcoming tool previews.
class MenuScreen extends StatelessWidget {
  final DailyVerseService verseService;

  MenuScreen({
    super.key,
    DailyVerseService? verseService,
  }) : verseService = verseService ?? DailyVerseService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final todayVerse = verseService.getTodayVerse();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.menu),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Dynamic Verse of the Day Header Card
            VerseOfTheDayCard(
              verse: todayVerse,
              verseService: verseService,
            ),

            // Feature List Items
            _buildFeatureTile(
              context: context,
              icon: Icons.touch_app_outlined,
              title: 'Digital Tasbih Counter',
              subtitle: 'Track your daily Dhikr and Tasbih count',
              badgeText: 'Open',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TasbihScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              context: context,
              icon: Icons.calendar_month_outlined,
              title: 'Hijri Islamic Calendar',
              subtitle: 'View Islamic dates, Ramadan, and Eid holidays',
              badgeText: 'Open',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HijriCalendarScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              context: context,
              icon: Icons.auto_stories_outlined,
              title: 'Daily Duas & Athkar',
              subtitle: 'Authentic Fortress of the Muslim supplications',
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(
              context: context,
              icon: Icons.format_quote_outlined,
              title: 'Hadith of the Day',
              subtitle: 'Daily prophetic wisdom and guidance',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    String badgeText = 'Soon',
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F2218),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF283D2F), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.tealAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: AppColors.tealAccent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFFA0B5A7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3827),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE5B842),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
