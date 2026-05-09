import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/surah_data.dart';

/// One logical row in the continuous reader list (virtualized).
class ReaderRow {
  final int surah;
  /// 0 = surah separator/header; -1 = full surah body (continuous mushaf text).
  final int ayah;

  const ReaderRow({required this.surah, required this.ayah});

  static const int surahBodySentinel = -1;

  bool get isSurahHeader => ayah == 0;
  bool get isSurahBody => ayah == surahBodySentinel;
  String get verseKey => ayah > 0 ? '$surah:$ayah' : '';
}

enum QuranSearchHitKind { surah, ayah }

class QuranSearchHit {
  final QuranSearchHitKind kind;
  final int surah;
  final int? ayah;
  final String primaryLabel;
  final String? secondaryLabel;
  final int rowIndex;

  const QuranSearchHit({
    required this.kind,
    required this.surah,
    this.ayah,
    required this.primaryLabel,
    this.secondaryLabel,
    required this.rowIndex,
  });
}

/// Single JSON load, flat row index, and search helpers for the continuous reader.
class QuranReaderRepository {
  QuranReaderRepository._();
  static final QuranReaderRepository instance = QuranReaderRepository._();

  final List<ReaderRow> _rows = [];
  final List<int> _surahHeaderIndex = List.filled(115, 0);
  final Map<String, int> _verseKeyToRow = {};
  final Map<int, List<Map<String, dynamic>>> _versesByChapter = {};

  final List<({int surah, int ayah, int rowIndex, String text, String norm})> _verseSearch = [];

  bool _built = false;

  bool get isReady => _built;
  int get rowCount => _rows.length;

  int surahHeaderRowIndex(int surah) {
    if (surah < 1 || surah > 114) return 0;
    return _surahHeaderIndex[surah];
  }

  ReaderRow rowAt(int index) => _rows[index];

  String? verseTextAt(int surah, int ayah) {
    final list = _versesByChapter[surah];
    if (list == null) return null;
    for (final v in list) {
      if (v['verse'] == ayah) return v['text'] as String?;
    }
    return null;
  }

  int? rowIndexForVerse(int surah, int ayah) => _verseKeyToRow['$surah:$ayah'];

  /// Scrollable list index of the continuous-text block for [surah] (1–114).
  int listIndexForSurahBody(int surah) {
    if (surah < 1 || surah > 114) return 0;
    return (surah - 1) * 2 + 1;
  }

  int verseCount(int surah) => _versesByChapter[surah]?.length ?? 0;

  List<Map<String, dynamic>> versesForSurah(int surah) =>
      List<Map<String, dynamic>>.from(_versesByChapter[surah] ?? const []);

  static String normalizeForSearch(String input) {
    var s = input.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED]'),
      '',
    );
    s = s.replaceAll('\u0640', '');
    return s.trim();
  }

  Future<void> ensureBuilt() async {
    if (_built) return;
    final jsonString = await rootBundle.loadString('assets/data/quran.json');
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    for (final e in jsonData.entries) {
      final chapter = int.parse(e.key);
      final rawList = e.value as List<dynamic>;
      final verses = <Map<String, dynamic>>[];
      for (final raw in rawList) {
        final m = Map<String, dynamic>.from(raw as Map);
        final ch = m['chapter'];
        final v = m['verse'];
        if (ch != null && v != null && m['text'] != null) {
          m['verse_key'] = '$ch:$v';
          verses.add(m);
        }
      }
      _versesByChapter[chapter] = verses;
    }

    for (var s = 1; s <= 114; s++) {
      _surahHeaderIndex[s] = _rows.length;
      _rows.add(ReaderRow(surah: s, ayah: 0));
      _rows.add(ReaderRow(surah: s, ayah: ReaderRow.surahBodySentinel));
      final bodyIdx = _rows.length - 1;
      final verses = _versesByChapter[s] ?? const [];
      for (final v in verses) {
        final ayah = v['verse'] as int;
        _verseKeyToRow['$s:$ayah'] = bodyIdx;
        final text = v['text'] as String;
        _verseSearch.add((
          surah: s,
          ayah: ayah,
          rowIndex: bodyIdx,
          text: text,
          norm: normalizeForSearch(text),
        ));
      }
    }

    _built = true;
  }

  /// Surah name from [surahs] metadata (Arabic).
  String surahName(int surah) {
    if (surah < 1 || surah > surahs.length) return '';
    return surahs[surah - 1]['name'] as String;
  }

  List<QuranSearchHit> search(String query, {int maxResults = 80}) {
    if (!_built || query.trim().isEmpty) return [];

    final qRaw = query.trim();
    final qNorm = normalizeForSearch(qRaw);
    final hits = <QuranSearchHit>[];
    final seen = <String>{};

    void addHit(QuranSearchHit h) {
      final key = '${h.kind}:${h.surah}:${h.ayah ?? 0}';
      if (seen.add(key)) hits.add(h);
    }

    final surahNum = int.tryParse(qRaw);
    if (surahNum != null && surahNum >= 1 && surahNum <= 114) {
      addHit(QuranSearchHit(
        kind: QuranSearchHitKind.surah,
        surah: surahNum,
        primaryLabel: '${surahName(surahNum)} — $surahNum',
        rowIndex: _surahHeaderIndex[surahNum],
      ));
    }

    for (var s = 1; s <= 114; s++) {
      final name = surahName(s);
      final nameNorm = normalizeForSearch(name);
      if (name.contains(qRaw) || nameNorm.contains(qNorm)) {
        addHit(QuranSearchHit(
          kind: QuranSearchHitKind.surah,
          surah: s,
          primaryLabel: '$name — $s',
          rowIndex: _surahHeaderIndex[s],
        ));
      }
    }

    if (qNorm.isNotEmpty) {
      for (final e in _verseSearch) {
        if (e.norm.contains(qNorm)) {
          addHit(QuranSearchHit(
            kind: QuranSearchHitKind.ayah,
            surah: e.surah,
            ayah: e.ayah,
            primaryLabel: '${surahName(e.surah)} : ${e.ayah}',
            secondaryLabel: _snippet(e.text, qRaw),
            rowIndex: e.rowIndex,
          ));
        }
        if (hits.length >= maxResults) break;
      }
    }

    return hits.take(maxResults).toList();
  }

  String _snippet(String text, String query, {int maxLen = 72}) {
    final plain = text.replaceAll('\n', ' ');
    if (plain.length <= maxLen) return plain;
    var i = plain.indexOf(query);
    if (i < 0) {
      final qn = normalizeForSearch(query);
      final nn = normalizeForSearch(plain);
      i = nn.indexOf(qn);
    }
    if (i <= 0) return '${plain.substring(0, maxLen)}…';
    final start = (i - 12).clamp(0, plain.length);
    final end = (start + maxLen).clamp(0, plain.length);
    final chunk = plain.substring(start, end);
    return start > 0 ? '…$chunk' : chunk;
  }
}
