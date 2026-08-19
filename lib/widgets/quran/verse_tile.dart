import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/models/quran/quran_verse.dart';

/// Item tile for rendering an individual verse in the Surah reader.
class VerseTile extends StatelessWidget {
  final QuranVerse verse;

  const VerseTile({
    super.key,
    required this.verse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = (theme.cardTheme.shape as RoundedRectangleBorder?)?.side.color ?? theme.dividerColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: Verse Number Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tealAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.tealAccent.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${verse.numberInSurah}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.tealAccent,
                  ),
                ),
              ),
              Text(
                'Juz ${verse.juz}',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Arabic Uthmani Text (RTL)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              verse.textArabic,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.9,
                letterSpacing: 0.2,
              ),
            ),
          ),

          if (verse.translationText.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 12),

            // Translation Text (LTR)
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                verse.translationText,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
