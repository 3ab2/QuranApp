import '../data/surah_data.dart';

/// Curated scientific “miracles” entry: moderate wording, linked to explicit ayat.
/// Full tafsir text is loaded via [TafsirRepository], not embedded here.
class ScientificMiracle {
  final int id;
  final String title;
  final String verse;
  final String surahName;
  final int surahNumber;
  final int ayah;
  final List<int> relatedAyahs;
  final String tafsirSummary;
  final String scientificExplanation;
  final String categoryKey;
  final List<String> topicTags;

  ScientificMiracle({
    required this.id,
    required this.title,
    required this.verse,
    required this.surahName,
    required this.surahNumber,
    required this.ayah,
    required this.relatedAyahs,
    required this.tafsirSummary,
    required this.scientificExplanation,
    required this.categoryKey,
    required this.topicTags,
  });

  int get primaryAyah => ayah;

  /// Localized or readable category label (key is stable for filtering).
  String get categoryDisplay => categoryKey;

  int get resolvedSurahNumber =>
      surahNumber > 0 ? surahNumber : (_resolveSurahNumber(surahName) ?? 1);

  factory ScientificMiracle.fromJson(Map<String, dynamic> json) {
    final surahNameRaw = json['surah'] as String? ?? '';
    final surahNum = json['surahNumber'] as int? ?? _resolveSurahNumber(surahNameRaw);
    final ayahVal = json['ayah'] as int? ?? 1;
    final relatedList = (json['relatedAyahs'] as List<dynamic>?)
            ?.map((e) => e is int ? e : int.tryParse('$e'))
            .whereType<int>()
            .toList() ??
        const <int>[];
    final relatedAyahsMerged = <int>{ayahVal, ...relatedList}.toList()..sort();

    final explanation = json['scientificExplanation'] as String? ??
        json['explanation'] as String? ??
        '';
    final categoryRaw =
        json['categoryKey'] as String? ?? json['category'] as String? ?? 'general';
    final tagsFromJson =
        (json['topicTags'] as List<dynamic>?)?.map((e) => '$e').toList();

    return ScientificMiracle(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['verse'] as String? ?? '',
      verse: json['verse'] as String? ?? '',
      surahName: surahNameRaw,
      surahNumber: surahNum ?? 0,
      ayah: ayahVal,
      relatedAyahs: relatedAyahsMerged,
      tafsirSummary: json['tafsirSummary'] as String? ?? '',
      scientificExplanation: explanation,
      categoryKey: categoryRaw,
      topicTags: tagsFromJson ?? _tagsForCategory(categoryRaw),
    );
  }

  static List<String> _tagsForCategory(String c) {
    switch (c) {
      case 'كون':
        return const ['الكون', 'السماء', 'الفلك', 'النجوم', 'البحر', 'الماء'];
      case 'جيولوجيا':
        return const ['الجبال', 'الأرض', 'القشرة', 'التكتونيات'];
      case 'طب':
        return const ['الإنسان', 'الجنين', 'الماء', 'الشفاء', 'الخلق'];
      case 'نبات':
        return const ['الرياح', 'التلقيح', 'النبات', 'الشجر'];
      default:
        return [c];
    }
  }

  static int? _resolveSurahNumber(String name) {
    for (final s in surahs) {
      if (s['name'] == name) return s['number'] as int;
    }
    return null;
  }
}
