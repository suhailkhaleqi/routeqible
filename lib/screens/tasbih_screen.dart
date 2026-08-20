import 'package:flutter/material.dart';
import 'package:routeqible/core/localization/app_localizations.dart';
import 'package:routeqible/services/tasbih_service.dart';

/// Dedicated Tasbih / Dhikr screen with ~1s intro animation, 2-column grid preset selector modal, and Custom Wirdh creator.
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with SingleTickerProviderStateMixin {
  final TasbihService _tasbihService = TasbihService();
  bool _showIntroSplash = true;

  late final AnimationController _splashController;
  late final Animation<double> _splashScaleAnimation;
  late final Animation<double> _splashOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _tasbihService.init();

    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _splashScaleAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _splashController, curve: Curves.easeOutCubic),
    );

    _splashOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _splashController, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _splashController.forward();

    // Hide intro splash after ~1000ms
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) {
        setState(() {
          _showIntroSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  void _openChooseDhikrSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChooseDhikrBottomSheet(
        tasbihService: _tasbihService,
        onSelect: (preset) {
          setState(() {
            _tasbihService.selectPreset(preset);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = l10n.locale.languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFF071F14),
      body: Stack(
        children: [
          // Main Tasbih Content
          SafeArea(
            child: Column(
              children: [
                // Top Custom App Bar (Cleaned up: Only Back Button & Centered Title)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF284433), width: 1),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Color(0xFFE5B842),
                            size: 24,
                          ),
                        ),
                      ),

                      // Header Title
                      const Text(
                        'DHIKR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5B842),
                          letterSpacing: 2.0,
                        ),
                      ),

                      const SizedBox(width: 38), // Balanced right spacing
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 8),

                      // Active Dhikr Selector Card ("Choose Dhikr")
                      InkWell(
                        onTap: () => _openChooseDhikrSheet(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F2518),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF243F2D), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A3B29),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: Color(0xFFE5B842),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CHOOSE DHIKR',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFA0B5A7),
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _tasbihService.activePreset.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1B3B28),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            _tasbihService.activePreset.targetCountText,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE5B842),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _tasbihService.activePreset.reference,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFFA0B5A7),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1A3B29),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFFE5B842),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Segment Progress Dots
                      if (_tasbihService.activePreset.stages.length > 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_tasbihService.activePreset.stages.length, (idx) {
                            final isActive = idx == _tasbihService.currentStageIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFFE5B842) : const Color(0xFF244231),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Arabic Calligraphy Text
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          _tasbihService.currentStage.arabic,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Transliteration & Meaning
                      Center(
                        child: Text(
                          _tasbihService.currentStage.transliteration,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE5B842),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          langCode == 'tr'
                              ? _tasbihService.currentStage.turkishMeaning
                              : _tasbihService.currentStage.englishMeaning,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFFA0B5A7),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Large Circular Tap Counter Button
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _tasbihService.increment();
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ripple ring
                              Container(
                                width: 230,
                                height: 230,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1E422F).withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              // Inner ripple ring
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF0D281B),
                                  border: Border.all(
                                    color: const Color(0xFF28543C),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE5B842).withValues(alpha: 0.1),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_tasbihService.currentSubCount}',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '/ ${_tasbihService.currentStage.targetCount}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFFA0B5A7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Session Progress Summary & Reference
                      Center(
                        child: Text(
                          '${_tasbihService.sessionTotalCount} / ${_tasbihService.activePreset.totalGoal}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE5B842),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          _tasbihService.activePreset.reference,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFA0B5A7),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Reset Action Button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _tasbihService.reset();
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE5B842),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ~1-Second Intro Splash Overlay
          if (_showIntroSplash)
            AnimatedBuilder(
              animation: _splashController,
              builder: (context, child) {
                return Opacity(
                  opacity: _splashOpacityAnimation.value,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF051A10), Color(0xFF0C2B1C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _splashScaleAnimation.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5B842).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE5B842).withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.wb_sunny_rounded,
                                color: Color(0xFFE5B842),
                                size: 42,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'DHIKR',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFE5B842),
                                letterSpacing: 4.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// "CHOOSE DHIKR" 2-Column Grid Bottom Sheet Modal featuring Custom Wirdh Creator.
class _ChooseDhikrBottomSheet extends StatefulWidget {
  final TasbihService tasbihService;
  final ValueChanged<DhikrPreset> onSelect;

  const _ChooseDhikrBottomSheet({
    required this.tasbihService,
    required this.onSelect,
  });

  @override
  State<_ChooseDhikrBottomSheet> createState() => _ChooseDhikrBottomSheetState();
}

class _ChooseDhikrBottomSheetState extends State<_ChooseDhikrBottomSheet> {
  void _showCreateCustomWirdhDialog(BuildContext context) {
    final titleController = TextEditingController();
    final countController = TextEditingController(text: '33');
    final arabicController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F2518),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF284433), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: Color(0xFFE5B842)),
            SizedBox(width: 10),
            Text(
              'Create Custom Wirdh',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Wirdh Name / Transliteration',
                labelStyle: TextStyle(color: Color(0xFFA0B5A7)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF284433))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5B842))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Target Count (e.g. 33, 100)',
                labelStyle: TextStyle(color: Color(0xFFA0B5A7)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF284433))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5B842))),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: arabicController,
              style: const TextStyle(color: Colors.white),
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'Arabic Calligraphy (Optional)',
                labelStyle: TextStyle(color: Color(0xFFA0B5A7)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF284433))),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5B842))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFA0B5A7))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5B842),
              foregroundColor: const Color(0xFF071F14),
            ),
            onPressed: () async {
              final title = titleController.text.trim();
              final count = int.tryParse(countController.text.trim()) ?? 33;
              final arabic = arabicController.text.trim();

              if (title.isNotEmpty) {
                await widget.tasbihService.addCustomWirdh(
                  title: title,
                  targetCount: count,
                  arabicText: arabic.isNotEmpty ? arabic : null,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                widget.onSelect(widget.tasbihService.activePreset);
              }
            },
            child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPresets = widget.tasbihService.allPresets;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF071F14),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF284433), width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF284433),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'CHOOSE DHIKR',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE5B842),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => _showCreateCustomWirdhDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F2518),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5B842).withValues(alpha: 0.5), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: Color(0xFFE5B842), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Create Custom Wirdh',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5B842),
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Color(0xFFE5B842)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: allPresets.length,
              itemBuilder: (context, index) {
                final preset = allPresets[index];
                final isSelected = preset.id == widget.tasbihService.activePreset.id;

                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelect(preset);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2518),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE5B842) : const Color(0xFF243F2D),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A3B29),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Color(0xFFE5B842),
                                size: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B3B28),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    preset.targetCountText,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE5B842),
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE5B842),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Color(0xFF071F14),
                                      size: 10,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFFE5B842) : Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              preset.reference,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFFA0B5A7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
