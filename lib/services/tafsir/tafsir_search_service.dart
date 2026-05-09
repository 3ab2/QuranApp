import '../../data/surah_data.dart';
import '../../models/scientific_miracle_model.dart';
import '../../models/tafsir_entry.dart';
import '../../models/tafsir_search_hit.dart';
import '../quran_text_service.dart';
import 'tafsir_repository.dart';

/// Ranking and querying for tafsir explorer search. Uses bundled Quran text,
/// optional on-disk tafsir cache, and curated scientific miracle metadata.
class TafsirSearchService {
  TafsirSearchService({
    required TafsirRepository repository,
  }) : _repo = repository;

  final TafsirRepository _repo;

  static double _containsScore(String haystack, String needle, double base) {
    if (needle.isEmpty) return 0;
    if (haystack == needle) return base + 40;
    if (haystack.startsWith(needle)) return base + 25;
    if (haystack.contains(needle)) return base;
    return 0;
  }

  static String _normalize(String s) {
    var t = s.trim().toLowerCase();
    const drop = '\u0640';
    t = t.replaceAll(drop, '');
    return t;
  }

  /// Runs a ranked search. [surahFilter] limits ayah/tafsir scans to one surah when set.
  Future<List<TafsirSearchHit>> search(
    String query, {
    int? surahFilter,
    TafsirSource source = TafsirSource.alMuyassar,
    List<ScientificMiracle>? scientificMiracles,
  }) async {
    final qRaw = query.trim();
    if (qRaw.isEmpty) return [];

    final q = _normalize(qRaw);
    final quran = QuranTextService.instance;
    await quran.ensureLoaded();
    final chapters = quran.chaptersOrNull;
    if (chapters == null) return [];

    final hits = <String, TafsirSearchHit>{};

    void put(TafsirSearchHit hit) {
      final key = '${hit.surahNumber}:${hit.ayahNumber}:${hit.kind.name}';
      final prev = hits[key];
      if (prev == null || hit.score > prev.score) {
        hits[key] = hit;
      }
    }

    for (final s in surahs) {
      final surahNumber = s['number'] as int;
      final surahName = s['name'] as String;
      if (surahFilter != null && surahNumber != surahFilter) continue;

      final nameNorm = _normalize(surahName);
      final surahScore = _containsScore(nameNorm, q, 95);
      if (surahScore > 0) {
        final verses = chapters[surahNumber];
        if (verses != null && verses.isNotEmpty) {
          final first = verses.first;
          put(TafsirSearchHit(
            surahNumber: surahNumber,
            surahName: surahName,
            ayahNumber: first.verse,
            ayahText: first.text,
            score: surahScore,
            kind: TafsirSearchHitKind.surahName,
            source: source,
          ));
        }
      }
    }

    final chapterNums = surahFilter != null ? [surahFilter] : chapters.keys.toList()..sort();

    for (final surahNumber in chapterNums) {
      final verses = chapters[surahNumber];
      if (verses == null) continue;
      final surahName = surahs.firstWhere(
        (x) => x['number'] == surahNumber,
        orElse: () => {'name': ''},
      )['name'] as String;

      for (final v in verses) {
        final textNorm = _normalize(v.text);
        final sc = _containsScore(textNorm, q, 72);
        if (sc > 0) {
          put(TafsirSearchHit(
            surahNumber: surahNumber,
            surahName: surahName,
            ayahNumber: v.verse,
            ayahText: v.text,
            score: sc,
            kind: TafsirSearchHitKind.ayahText,
            source: source,
          ));
        }
      }
    }

    final miracles = scientificMiracles;
    if (miracles != null) {
      for (final m in miracles) {
        if (surahFilter != null && m.resolvedSurahNumber != surahFilter) continue;
        final buf = StringBuffer()
          ..write(m.title)
          ..write(' ')
          ..write(m.scientificExplanation)
          ..write(' ')
          ..write(m.tafsirSummary)
          ..write(' ')
          ..write(m.verse)
          ..write(' ')
          ..write(m.categoryDisplay)
          ..write(' ');
        for (final t in m.topicTags) {
          buf.write(t);
          buf.write(' ');
        }
        final sc = _containsScore(_normalize(buf.toString()), q, 68);
        if (sc > 0) {
          final ayahText = quran.verseText(m.resolvedSurahNumber, m.primaryAyah) ?? m.verse;
          put(TafsirSearchHit(
            surahNumber: m.resolvedSurahNumber,
            surahName: m.surahName,
            ayahNumber: m.primaryAyah,
            ayahText: ayahText,
            tafsirSnippet: m.tafsirSummary.isNotEmpty ? m.tafsirSummary : null,
            score: sc,
            kind: TafsirSearchHitKind.scientificTopic,
            source: source,
          ));
        }
      }
    }

    if (source.quranComResourceId != null) {
      final List<int> cachedChapters;
      if (surahFilter != null) {
        final surahName = surahs.firstWhere(
          (x) => x['number'] == surahFilter,
          orElse: () => {'name': '', 'number': surahFilter},
        )['name'] as String;
        final snapshot = await _repo.readCachedChapter(source, surahFilter, surahName);
        cachedChapters = snapshot.isNotEmpty ? [surahFilter] : [];
      } else {
        cachedChapters = await _repo.listCachedChapters(source);
      }

      for (final chapter in cachedChapters) {
        if (surahFilter != null && chapter != surahFilter) continue;
        final surahName = surahs.firstWhere(
          (x) => x['number'] == chapter,
          orElse: () => {'name': ''},
        )['name'] as String;
        final entries = await _repo.readCachedChapter(source, chapter, surahName);
        for (final e in entries) {
          final sc = _containsScore(_normalize(e.tafsirText), q, 62);
          if (sc > 0) {
            final snippet = e.tafsirText.length > 160 ? '${e.tafsirText.substring(0, 160)}…' : e.tafsirText;
            put(TafsirSearchHit(
              surahNumber: e.surahNumber,
              surahName: e.surahName.isNotEmpty ? e.surahName : surahName,
              ayahNumber: e.ayahNumber,
              ayahText: e.ayahText,
              tafsirSnippet: snippet,
              score: sc,
              kind: TafsirSearchHitKind.tafsirCached,
              source: source,
            ));
          }
        }
      }
    }

    final list = hits.values.toList()
      ..sort((a, b) {
        final c = b.score.compareTo(a.score);
        if (c != 0) return c;
        if (a.surahNumber != b.surahNumber) return a.surahNumber.compareTo(b.surahNumber);
        return a.ayahNumber.compareTo(b.ayahNumber);
      });
    return list;
  }
}
