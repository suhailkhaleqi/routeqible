import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/services/daily_verse_service.dart';

/// Dynamic "Verse of the Day" header card matching the screenshot design.
class VerseOfTheDayCard extends StatelessWidget {
  final DailyVerse verse;
  final DailyVerseService verseService;

  const VerseOfTheDayCard({
    super.key,
    required this.verse,
    required this.verseService,
  });

  void _shareVerse(BuildContext context, String langCode, AppLocalizations l10n) {
    final text = '${verse.arabicText}\n\n${verse.getTranslation(langCode)}\n\n— ${verse.getReference(langCode)}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.shareVerse),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _pinWidgetToHome(BuildContext context, String langCode, AppLocalizations l10n) async {
    await verseService.syncToHomeScreenWidget(langCode);

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F2218),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF283D2F), width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.widgets_outlined, color: Color(0xFF4EBE96)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.addToHomeScreen,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.widgetSynced,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0B5A7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF182F22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verse.arabicText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    verse.getReference(langCode),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4EBE96),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF4EBE96), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = l10n.locale.languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2517),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF1B3C27), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Sparkle Icon + Title & Action Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF4EBE96),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.verseOfTheDay,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4EBE96),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Add Widget to Home Screen Icon
                  IconButton(
                    onPressed: () => _pinWidgetToHome(context, langCode, l10n),
                    icon: const Icon(
                      Icons.widgets_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: l10n.addToHomeScreen,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 8),
                  // Share Icon
                  IconButton(
                    onPressed: () => _shareVerse(context, langCode, l10n),
                    icon: const Icon(
                      Icons.ios_share_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: l10n.shareVerse,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Uthmani Arabic Script
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              verse.arabicText,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.65,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Localized Translation Text
          Text(
            verse.getTranslation(langCode),
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFFC8D7CE),
              height: 1.4,
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 14),

          // Surah & Ayah Reference Tag
          Text(
            verse.getReference(langCode),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4EBE96),
            ),
          ),
        ],
      ),
    );
  }
}
