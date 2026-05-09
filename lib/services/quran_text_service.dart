import 'dart:convert';

import 'package:flutter/services.dart';

/// Read-only access to bundled Uthmani text (`assets/data/quran.json`).
/// Isolated from audio / adhan / stories.
class QuranTextService {
  QuranTextService._();
  static final QuranTextService instance = QuranTextService._();

  Map<int, List<({int verse, String text})>>? _byChapter;

  Future<void> ensureLoaded() async {
    if (_byChapter != null) return;
    final raw = await rootBundle.loadString('assets/data/quran.json');
    final decoded = json.decode(raw) as Map<String, dynamic>;
    final out = <int, List<({int verse, String text})>>{};
    for (final e in decoded.entries) {
      final chapter = int.parse(e.key);
      final rows = e.value as List<dynamic>;
      out[chapter] = rows.map((row) {
        final m = row as Map<String, dynamic>;
        return (verse: m['verse'] as int, text: m['text'] as String);
      }).toList();
    }
    _byChapter = out;
  }

  String? verseText(int surah, int ayah) {
    final ch = _byChapter?[surah];
    if (ch == null) return null;
    for (final v in ch) {
      if (v.verse == ayah) return v.text;
    }
    return null;
  }

  Map<int, List<({int verse, String text})>>? get chaptersOrNull => _byChapter;
}
