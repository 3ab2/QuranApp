import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class QuranService {
  Map<String, List<dynamic>> _quranData = {};

  QuranService();

  /// Load the Quran JSON from assets
  Future<void> loadQuran() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/quran.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // The JSON is a map of chapter numbers to lists of verses
      _quranData = jsonData.map((key, value) => MapEntry(key, value as List<dynamic>));
    } catch (e) {
      // Log error instead of printing
      _quranData = {};
    }
  }

  /// Static method to get verses by surah number
  static Future<List<Map<String, dynamic>>> getVersesBySurah(int surahNumber) async {
    final service = QuranService();
    await service.loadQuran();
    final rawVerses = service._quranData[surahNumber.toString()] ?? [];
    final filteredVerses = rawVerses.where((v) => v['chapter'] != null && v['verse'] != null && v['text'] != null).toList();
    return filteredVerses.map((verse) {
      final verseMap = Map<String, dynamic>.from(verse as Map);
      verseMap['verse_key'] = '${verse['chapter']}:${verse['verse']}';
      return verseMap;
    }).toList();
  }
}
