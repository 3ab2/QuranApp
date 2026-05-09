import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/tafsir_entry.dart';
import '../quran_text_service.dart';

/// Fetches tafsir from Quran.com API v4 (`/tafsirs/{id}/by_chapter|by_ayah`) and
/// persists JSON per chapter on disk. Does not depend on Quran audio / stories / adhan.
class TafsirRepository {
  TafsirRepository({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  /// Quran.com content API (not `/quran/tafsirs/...`, which returns empty `tafsirs`).
  static const _base = 'https://api.quran.com/api/v4';

  static const _chapterPerPage = '400';

  /// On web, [path_provider] has no implementation — keep chapter JSON in memory.
  final Map<String, String> _memoryCacheJson = {};

  void _log(String message) {
    debugPrint('[TafsirRepository] $message');
  }

  String _memoryCacheKey(TafsirSource source, int chapter) {
    final id = source.quranComResourceId ?? 0;
    return '${source.cacheKey}_r${id}_c$chapter';
  }

  String _stripHtml(String? raw) {
    if (raw == null) return '';
    var t = raw.replaceAll(RegExp(r'<[^>]*>'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }

  Future<Directory> _cacheDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'tafsir_cache'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _cacheFile(TafsirSource source, int chapter) async {
    final dir = await _cacheDir();
    final id = source.quranComResourceId ?? 0;
    return File(p.join(dir.path, '${source.cacheKey}_r${id}_c$chapter.json'));
  }

  List<TafsirEntry> _parseCachedJsonMap(Map<String, dynamic> data, int chapter, TafsirSource source) {
    final name = data['surahName'] as String? ?? '';
    return _parseAnyResponse(
      data,
      surahNumber: chapter,
      surahName: name,
      source: source,
    );
  }

  Future<List<TafsirEntry>?> _readCache(TafsirSource source, int chapter) async {
    if (kIsWeb) {
      try {
        final key = _memoryCacheKey(source, chapter);
        final text = _memoryCacheJson[key];
        if (text == null) {
          _log('cache MISS (web) chapter=$chapter');
          return null;
        }
        final data = json.decode(text) as Map<String, dynamic>;
        final parsed = _parseCachedJsonMap(data, chapter, source);
        _log('cache READ (web) chapter=$chapter entries=${parsed.length}');
        return parsed;
      } catch (e, st) {
        _log('cache READ ERROR (web) chapter=$chapter $e\n$st');
        return null;
      }
    }
    try {
      final f = await _cacheFile(source, chapter);
      if (!await f.exists()) {
        _log('cache MISS file=${f.path}');
        return null;
      }
      final text = await f.readAsString();
      final data = json.decode(text) as Map<String, dynamic>;
      final parsed = _parseCachedJsonMap(data, chapter, source);
      _log('cache READ chapter=$chapter entries=${parsed.length}');
      return parsed;
    } catch (e, st) {
      _log('cache READ ERROR chapter=$chapter $e\n$st');
      return null;
    }
  }

  Future<void> _writeCache(
    TafsirSource source,
    int chapter,
    Map<String, dynamic> apiBody,
    String surahName,
  ) async {
    try {
      final enriched = Map<String, dynamic>.from(apiBody)..['surahName'] = surahName;
      final payload = json.encode(enriched);
      if (kIsWeb) {
        _memoryCacheJson[_memoryCacheKey(source, chapter)] = payload;
        _log('cache WRITE (web) chapter=$chapter');
        return;
      }
      final f = await _cacheFile(source, chapter);
      await f.writeAsString(payload);
      _log('cache WRITE chapter=$chapter path=${f.path}');
    } catch (e, st) {
      _log('cache WRITE ERROR $e\n$st');
    }
  }

  /// Supports current API (`tafsirs` list, `tafsir` single) and legacy `tafsir.verses`.
  List<TafsirEntry> _parseAnyResponse(
    Map<String, dynamic> data, {
    required int surahNumber,
    required String surahName,
    required TafsirSource source,
  }) {
    final quran = QuranTextService.instance;

    final single = data['tafsir'];
    if (single is Map<String, dynamic>) {
      final text = _stripHtml(single['text'] as String?);
      if (text.isNotEmpty) {
        int? ayah;
        final versesMap = single['verses'];
        if (versesMap is Map && versesMap.isNotEmpty) {
          final firstKey = versesMap.keys.first.toString();
          if (firstKey.contains(':')) {
            ayah = int.tryParse(firstKey.split(':').last);
          }
        }
        ayah ??= _readVerseNumber(single);
        if (ayah != null) {
          final ayahText = quran.verseText(surahNumber, ayah) ?? '';
          return [
            TafsirEntry(
              surahNumber: surahNumber,
              ayahNumber: ayah,
              surahName: surahName,
              ayahText: ayahText,
              tafsirText: text,
              tafsirSource: source,
            ),
          ];
        }
      }
    }

    final flat = data['tafsirs'];
    if (flat is List) {
      final out = <TafsirEntry>[];
      for (final raw in flat) {
        if (raw is! Map<String, dynamic>) continue;
        final text = _stripHtml(raw['text'] as String?);
        if (text.isEmpty) continue;
        final verseNumber = _readVerseNumber(raw);
        if (verseNumber == null) continue;
        final sn = _readSurahFromVerseKey(raw['verse_key'], surahNumber);
        final ayahText = quran.verseText(sn, verseNumber) ?? '';
        out.add(TafsirEntry(
          surahNumber: sn,
          ayahNumber: verseNumber,
          surahName: surahName,
          ayahText: ayahText,
          tafsirText: text,
          tafsirSource: source,
        ));
      }
      out.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));
      return out;
    }

    final nested = (data['tafsir'] is Map<String, dynamic>)
        ? (data['tafsir'] as Map<String, dynamic>)['verses'] as List?
        : null;
    if (nested != null) {
      final out = <TafsirEntry>[];
      for (final raw in nested) {
        if (raw is! Map<String, dynamic>) continue;
        final verseNumber = _readVerseNumber(raw);
        if (verseNumber == null) continue;
        final text = _stripHtml(raw['text'] as String?);
        if (text.isEmpty) continue;
        final ayahText = quran.verseText(surahNumber, verseNumber) ?? '';
        out.add(TafsirEntry(
          surahNumber: surahNumber,
          ayahNumber: verseNumber,
          surahName: surahName,
          ayahText: ayahText,
          tafsirText: text,
          tafsirSource: source,
        ));
      }
      out.sort((a, b) => a.ayahNumber.compareTo(b.ayahNumber));
      return out;
    }

    return [];
  }

  int _readSurahFromVerseKey(dynamic verseKey, int fallbackSurah) {
    if (verseKey is String && verseKey.contains(':')) {
      final s = int.tryParse(verseKey.split(':').first);
      if (s != null) return s;
    }
    return fallbackSurah;
  }

  int? _readVerseNumber(Map<String, dynamic> raw) {
    final v = raw['verse_number'];
    if (v is int) return v;
    if (v is String) return int.tryParse(v);
    final key = raw['verse_key'];
    if (key is String && key.contains(':')) {
      final parts = key.split(':');
      if (parts.length >= 2) return int.tryParse(parts[1]);
    }
    return null;
  }

  /// Loads a full surah of tafsir. Uses cache when [forceNetwork] is false.
  Future<List<TafsirEntry>> loadChapter({
    required TafsirSource source,
    required int surahNumber,
    required String surahName,
    bool forceNetwork = false,
  }) async {
    await QuranTextService.instance.ensureLoaded();
    final resourceId = source.quranComResourceId;
    if (resourceId == null) {
      final cached = await _readCache(source, surahNumber);
      return cached ?? [];
    }

    if (!forceNetwork) {
      final cached = await _readCache(source, surahNumber);
      if (cached != null && cached.isNotEmpty) return cached;
    }

    final uri = Uri.parse('$_base/tafsirs/$resourceId/by_chapter/$surahNumber').replace(
      queryParameters: {'per_page': _chapterPerPage},
    );
    _log('GET chapter surah=$surahNumber url=$uri');

    try {
      final response = await _http.get(uri);
      _log('chapter response status=${response.statusCode} len=${response.body.length}');
      if (response.statusCode != 200) {
        _log('chapter HTTP error body=${response.body.length > 280 ? response.body.substring(0, 280) : response.body}');
        final fallback = await _readCache(source, surahNumber);
        return fallback ?? [];
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final parsed = _parseAnyResponse(
        data,
        surahNumber: surahNumber,
        surahName: surahName,
        source: source,
      );
      _log('chapter parsed count=${parsed.length}');
      if (parsed.isEmpty) {
        _log('chapter PARSE EMPTY keys=${data.keys.join(',')}');
        final fallback = await _readCache(source, surahNumber);
        return fallback ?? [];
      }
      await _writeCache(source, surahNumber, data, surahName);
      return parsed;
    } catch (e, st) {
      _log('chapter EXCEPTION $e\n$st');
      final fallback = await _readCache(source, surahNumber);
      return fallback ?? [];
    }
  }

  /// Single-ayah fetch (e.g. deep links). Uses `/by_ayah/{verse_key}`.
  Future<TafsirEntry?> loadAyah({
    required TafsirSource source,
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
  }) async {
    await QuranTextService.instance.ensureLoaded();
    final resourceId = source.quranComResourceId;
    if (resourceId == null) {
      _log('loadAyah: no resourceId for source=${source.name}');
      return null;
    }

    final verseKey = '$surahNumber:$ayahNumber';
    final uri = Uri.parse('$_base/tafsirs/$resourceId/by_ayah/$verseKey');
    _log('GET ayah verse_key=$verseKey url=$uri');

    try {
      final response = await _http.get(uri);
      _log('ayah response status=${response.statusCode} len=${response.body.length}');
      if (response.statusCode != 200) {
        _log('ayah HTTP error body=${response.body.length > 400 ? response.body.substring(0, 400) : response.body}');
        return _loadAyahFromChapterCache(
          source: source,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          surahName: surahName,
        );
      }
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = _parseAnyResponse(
        data,
        surahNumber: surahNumber,
        surahName: surahName,
        source: source,
      );
      if (list.isEmpty) {
        _log('ayah PARSE EMPTY verse_key=$verseKey keys=${data.keys.join(',')}');
        return _loadAyahFromChapterCache(
          source: source,
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          surahName: surahName,
        );
      }
      try {
        return list.firstWhere((e) => e.ayahNumber == ayahNumber);
      } catch (_) {
        return list.first;
      }
    } catch (e, st) {
      _log('ayah EXCEPTION verse_key=$verseKey $e\n$st');
      return _loadAyahFromChapterCache(
        source: source,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
      );
    }
  }

  Future<TafsirEntry?> _loadAyahFromChapterCache({
    required TafsirSource source,
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
  }) async {
    _log('fallback loadChapter cache/network surah=$surahNumber ayah=$ayahNumber');
    final chapter = await loadChapter(
      source: source,
      surahNumber: surahNumber,
      surahName: surahName,
      forceNetwork: false,
    );
    try {
      return chapter.firstWhere((e) => e.ayahNumber == ayahNumber);
    } catch (_) {
      _log('fallback chapter miss ayah=$ayahNumber (have ${chapter.length} rows)');
      return null;
    }
  }

  /// Returns chapters that already have a non-empty cache file.
  Future<List<int>> listCachedChapters(TafsirSource source) async {
    final id = source.quranComResourceId ?? 0;
    final prefix = '${source.cacheKey}_r${id}_c';
    if (kIsWeb) {
      final out = <int>[];
      for (final key in _memoryCacheJson.keys) {
        if (!key.startsWith(prefix)) continue;
        final tail = key.substring(prefix.length);
        final n = int.tryParse(tail);
        if (n != null) out.add(n);
      }
      out.sort();
      return out;
    }
    try {
      final dir = await _cacheDir();
      if (!await dir.exists()) return [];
      final out = <int>[];
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final name = p.basename(entity.path);
        if (!name.startsWith(prefix) || !name.endsWith('.json')) continue;
        final tail = name.substring(prefix.length, name.length - 5);
        final n = int.tryParse(tail);
        if (n != null) out.add(n);
      }
      out.sort();
      return out;
    } catch (e, st) {
      _log('listCachedChapters ERROR $e\n$st');
      return [];
    }
  }

  Future<List<TafsirEntry>> readCachedChapter(
    TafsirSource source,
    int chapter,
    String surahName,
  ) async {
    await QuranTextService.instance.ensureLoaded();
    final cached = await _readCache(source, chapter);
    if (cached == null) return [];
    if (cached.isNotEmpty && cached.first.surahName.isEmpty && surahName.isNotEmpty) {
      return cached
          .map(
            (e) => TafsirEntry(
              surahNumber: e.surahNumber,
              ayahNumber: e.ayahNumber,
              surahName: surahName,
              ayahText: e.ayahText,
              tafsirText: e.tafsirText,
              tafsirSource: e.tafsirSource,
              tags: e.tags,
            ),
          )
          .toList();
    }
    return cached;
  }
}
