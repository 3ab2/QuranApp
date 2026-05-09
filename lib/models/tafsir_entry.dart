/// Identifies a tafsir edition. Only [alMuyassar] is wired to the live API today;
/// others are reserved for future resource IDs.
enum TafsirSource {
  alMuyassar,
  ibnKathir,
  jalalayn,
}

extension TafsirSourceMeta on TafsirSource {
  /// Quran.com `resource_id` when available; `null` means not enabled yet in-app.
  int? get quranComResourceId => switch (this) {
        TafsirSource.alMuyassar => 16,
        TafsirSource.ibnKathir => null,
        TafsirSource.jalalayn => null,
      };

  String get arabicLabel => switch (this) {
        TafsirSource.alMuyassar => 'التفسير الميسر',
        TafsirSource.ibnKathir => 'تفسير ابن كثير',
        TafsirSource.jalalayn => 'تفسير الجلالين',
      };

  /// Stable key for filesystem cache.
  String get cacheKey => name;
}

class TafsirEntry {
  final int surahNumber;
  final int ayahNumber;
  final String surahName;
  final String ayahText;
  final String tafsirText;
  final TafsirSource tafsirSource;
  final List<String> tags;

  const TafsirEntry({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahName,
    required this.ayahText,
    required this.tafsirText,
    required this.tafsirSource,
    this.tags = const [],
  });

  String get verseKey => '$surahNumber:$ayahNumber';
}
