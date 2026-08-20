import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DhikrPreset {
  final String id;
  final String title;
  final String targetCountText;
  final String reference;
  final int totalGoal;
  final List<DhikrStage> stages;

  const DhikrPreset({
    required this.id,
    required this.title,
    required this.targetCountText,
    required this.reference,
    required this.totalGoal,
    required this.stages,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetCountText': targetCountText,
        'reference': reference,
        'totalGoal': totalGoal,
        'stages': stages.map((s) => s.toJson()).toList(),
      };

  factory DhikrPreset.fromJson(Map<String, dynamic> json) => DhikrPreset(
        id: json['id'],
        title: json['title'],
        targetCountText: json['targetCountText'],
        reference: json['reference'],
        totalGoal: json['totalGoal'],
        stages: (json['stages'] as List).map((s) => DhikrStage.fromJson(s)).toList(),
      );
}

class DhikrStage {
  final String arabic;
  final String transliteration;
  final String englishMeaning;
  final String turkishMeaning;
  final int targetCount;

  const DhikrStage({
    required this.arabic,
    required this.transliteration,
    required this.englishMeaning,
    required this.turkishMeaning,
    required this.targetCount,
  });

  Map<String, dynamic> toJson() => {
        'arabic': arabic,
        'transliteration': transliteration,
        'englishMeaning': englishMeaning,
        'turkishMeaning': turkishMeaning,
        'targetCount': targetCount,
      };

  factory DhikrStage.fromJson(Map<String, dynamic> json) => DhikrStage(
        arabic: json['arabic'],
        transliteration: json['transliteration'],
        englishMeaning: json['englishMeaning'],
        turkishMeaning: json['turkishMeaning'],
        targetCount: json['targetCount'],
      );
}

class TasbihService {
  static const List<DhikrPreset> defaultPresets = [
    DhikrPreset(
      id: 'post_prayer',
      title: 'Post-Prayer Tasbih',
      targetCountText: '100×',
      reference: 'Sahih al-Bukhari 3113',
      totalGoal: 100,
      stages: [
        DhikrStage(
          arabic: 'سُبْحَانَ ٱللَّٰهِ',
          transliteration: 'Subhanallah',
          englishMeaning: 'Glory be to Allah',
          turkishMeaning: 'Allah noksan sıfatlardan münezzehtir',
          targetCount: 33,
        ),
        DhikrStage(
          arabic: 'ٱلْحَمْدُ لِلَّٰهِ',
          transliteration: 'Alhamdulillah',
          englishMeaning: 'Praise be to Allah',
          turkishMeaning: 'Hamd Allah\'a mahsustur',
          targetCount: 33,
        ),
        DhikrStage(
          arabic: 'ٱللَّٰهُ أَكْبَرُ',
          transliteration: 'Allahu Akbar',
          englishMeaning: 'Allah is Greatest',
          turkishMeaning: 'Allah en büyüktür',
          targetCount: 33,
        ),
        DhikrStage(
          arabic: 'لَا إِلٰهَ إِلَّا ٱللَّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ ٱلْمُلْكُ وَلَهُ ٱلْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
          transliteration: 'La ilaha illallah...',
          englishMeaning: 'None has the right to be worshipped except Allah alone...',
          turkishMeaning: 'Allah\'tan başka ilah yoktur, O tektir, ortağı yoktur...',
          targetCount: 1,
        ),
      ],
    ),
    DhikrPreset(
      id: 'istighfar',
      title: 'Istighfar',
      targetCountText: '100×',
      reference: 'Sahih al-Bukhari 6307',
      totalGoal: 100,
      stages: [
        DhikrStage(
          arabic: 'أَسْتَغْفِرُ ٱللَّٰهَ وَأَتُوبُ إِلَيْهِ',
          transliteration: 'Astaghfirullah wa atubu ilayh',
          englishMeaning: 'I seek forgiveness from Allah and repent to Him',
          turkishMeaning: 'Allah\'tan bağışlanma diler ve O\'na tövbe ederim',
          targetCount: 100,
        ),
      ],
    ),
    DhikrPreset(
      id: 'tahlil',
      title: 'Tahlil',
      targetCountText: '100×',
      reference: 'Sahih Muslim 2693',
      totalGoal: 100,
      stages: [
        DhikrStage(
          arabic: 'لَا إِلٰهَ إِلَّا ٱللَّٰهُ',
          transliteration: 'La ilaha illallah',
          englishMeaning: 'There is no god but Allah',
          turkishMeaning: 'Allah\'tan başka ilah yoktur',
          targetCount: 100,
        ),
      ],
    ),
    DhikrPreset(
      id: 'salawat',
      title: 'Salawat',
      targetCountText: '100×',
      reference: 'Sunan Ibn Majah 907',
      totalGoal: 100,
      stages: [
        DhikrStage(
          arabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
          transliteration: 'Allahumma salli \'ala Muhammad',
          englishMeaning: 'O Allah, send blessings upon Muhammad',
          turkishMeaning: 'Allah\'ım! Hz. Muhammed\'e ve ailesine salât eyle',
          targetCount: 100,
        ),
      ],
    ),
    DhikrPreset(
      id: 'before_sleeping',
      title: 'Before Sleeping',
      targetCountText: '100×',
      reference: 'Sahih al-Bukhari 3113',
      totalGoal: 100,
      stages: [
        DhikrStage(
          arabic: 'سُبْحَانَ ٱللَّٰهِ',
          transliteration: 'Subhanallah',
          englishMeaning: 'Glory be to Allah (33x)',
          turkishMeaning: 'Subhanallah (33 kere)',
          targetCount: 33,
        ),
        DhikrStage(
          arabic: 'ٱلْحَمْدُ لِلَّٰهِ',
          transliteration: 'Alhamdulillah',
          englishMeaning: 'Praise be to Allah (33x)',
          turkishMeaning: 'Alhamdulillah (33 kere)',
          targetCount: 33,
        ),
        DhikrStage(
          arabic: 'ٱللَّٰهُ أَكْبَرُ',
          transliteration: 'Allahu Akbar',
          englishMeaning: 'Allah is Greatest (34x)',
          turkishMeaning: 'Allahu Akbar (34 kere)',
          targetCount: 34,
        ),
      ],
    ),
    DhikrPreset(
      id: 'muawwizat',
      title: 'Al-Mu\'awwizat',
      targetCountText: '9×',
      reference: 'Sunan Abi Dawud 5082',
      totalGoal: 9,
      stages: [
        DhikrStage(
          arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          transliteration: 'Surah Al-Ikhlas, Al-Falaq, An-Nas',
          englishMeaning: 'The 3 Protective Surahs',
          turkishMeaning: '3 Muavvizeteyn Sureleri',
          targetCount: 9,
        ),
      ],
    ),
  ];

  List<DhikrPreset> customPresets = [];
  DhikrPreset activePreset = defaultPresets[0];
  int currentStageIndex = 0;
  int currentSubCount = 0;
  int sessionTotalCount = 0;
  bool isCompleted = false;

  List<DhikrPreset> get allPresets => [...defaultPresets, ...customPresets];

  DhikrStage get currentStage => activePreset.stages[currentStageIndex];

  Future<void> init() async {
    await loadCustomWirdhs();
  }

  Future<void> loadCustomWirdhs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('custom_wirdhs_key');
      if (jsonStr != null) {
        final List list = jsonDecode(jsonStr);
        customPresets = list.map((item) => DhikrPreset.fromJson(item)).toList();
      }
    } catch (_) {}
  }

  Future<void> addCustomWirdh({
    required String title,
    required int targetCount,
    String? arabicText,
    String? notes,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final arabic = (arabicText != null && arabicText.trim().isNotEmpty) ? arabicText.trim() : title;

    final newPreset = DhikrPreset(
      id: id,
      title: title,
      targetCountText: '$targetCount×',
      reference: notes ?? 'Custom Wirdh',
      totalGoal: targetCount,
      stages: [
        DhikrStage(
          arabic: arabic,
          transliteration: title,
          englishMeaning: 'Custom Wirdh',
          turkishMeaning: 'Özel Vird',
          targetCount: targetCount,
        ),
      ],
    );

    customPresets.add(newPreset);
    selectPreset(newPreset);

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = customPresets.map((p) => p.toJson()).toList();
      await prefs.setString('custom_wirdhs_key', jsonEncode(jsonList));
    } catch (_) {}
  }

  void selectPreset(DhikrPreset preset) {
    activePreset = preset;
    reset();
  }

  void reset() {
    currentStageIndex = 0;
    currentSubCount = 0;
    sessionTotalCount = 0;
    isCompleted = false;
  }

  void increment() {
    if (isCompleted) return;

    // Trigger subtle tap vibration
    HapticFeedback.lightImpact();

    currentSubCount++;
    sessionTotalCount++;

    final stage = currentStage;
    if (currentSubCount >= stage.targetCount) {
      // Completed current stage
      if (currentStageIndex < activePreset.stages.length - 1) {
        // Heavy vibration when switching stages (e.g. 33 -> next stage)
        HapticFeedback.mediumImpact();
        currentStageIndex++;
        currentSubCount = 0;
      } else {
        // Fully completed all stages!
        HapticFeedback.heavyImpact();
        isCompleted = true;
      }
    }

    _saveProgress();
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbih_total_count', sessionTotalCount);
    } catch (_) {}
  }
}
