import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/models/quran/quran_chapter.dart';

/// Item tile for rendering a Surah in the main Quran list.
class SurahListTile extends StatelessWidget {
  final QuranChapter chapter;
  final VoidCallback onTap;

  const SurahListTile({
    super.key,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final borderColor = (theme.cardTheme.shape as RoundedRectangleBorder?)?.side.color ?? theme.dividerColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.tealAccent.withValues(alpha: 0.1),
          highlightColor: AppColors.tealAccent.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Surah Number Badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.tealAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.tealAccent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      chapter.formattedNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.tealAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Surah English Name & Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.englishName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        chapter.englishNameTranslation,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldBright.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${chapter.numberOfAyahs} ${l10n.verses}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.goldBright,
                              ),
                            ),
                          ),
                          if (chapter.revelationTypeFormatted.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '•  ${chapter.revelationTypeFormatted}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Surah Arabic Name
                Text(
                  chapter.name,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldBright,
                    height: 1.2,
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
