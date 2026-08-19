import 'package:flutter/material.dart';
import 'package:routeqible/constants/app_colors.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/core/localization/language_model.dart';
import 'package:routeqible/core/localization/language_service.dart';
import 'package:routeqible/core/localization/supported_languages.dart';

/// Screen allowing the user to select and apply their preferred language with an explicit Apply action.
class LanguageSelectionScreen extends StatefulWidget {
  final LanguageService languageService;

  const LanguageSelectionScreen({super.key, required this.languageService});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late LanguageModel _selectedLanguage;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    // Initialize temporary selection with current active language
    _selectedLanguage = widget.languageService.currentLanguage;
  }

  Future<void> _applyLanguage() async {
    setState(() {
      _isApplying = true;
    });

    // Save and update global language state
    await widget.languageService.setLanguage(_selectedLanguage);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.language)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: SupportedLanguages.languages.length,
              itemBuilder: (context, index) {
                final lang = SupportedLanguages.languages[index];
                final isSelected = _selectedLanguage.code == lang.code;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.tealAccent.withValues(alpha: 0.1)
                        : theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.tealAccent
                          : (theme.cardTheme.shape as RoundedRectangleBorder?)
                                    ?.side
                                    .color ??
                                theme.dividerColor,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      lang.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      lang.nativeName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.tealAccent
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected
                          ? AppColors.tealAccent
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                      size: 22,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Bottom Apply Button Container
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                border: Border(
                  top: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isApplying ? null : _applyLanguage,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tealAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isApplying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              l10n.applyLanguage,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
