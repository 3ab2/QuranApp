import 'tafsir_entry.dart';

enum TafsirSearchHitKind {
  surahName,
  ayahText,
  tafsirCached,
  scientificTopic,
}

class TafsirSearchHit {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final String? tafsirSnippet;
  final double score;
  final TafsirSearchHitKind kind;
  final TafsirSource? source;

  const TafsirSearchHit({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    this.tafsirSnippet,
    required this.score,
    required this.kind,
    this.source,
  });
}
