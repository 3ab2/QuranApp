/// Curated Qur'anic supplication entry (see `assets/data/quranic_duas.json`).
class QuranicDua {
  final String id;
  final String arabicText;
  final int surahNumber;
  final int ayahStart;
  final int? ayahEnd;
  final String meaningEn;
  final String meaningFr;
  final String meaningAr;
  final List<String> categories;
  final List<String> searchKeywords;

  const QuranicDua({
    required this.id,
    required this.arabicText,
    required this.surahNumber,
    required this.ayahStart,
    this.ayahEnd,
    required this.meaningEn,
    required this.meaningFr,
    required this.meaningAr,
    required this.categories,
    required this.searchKeywords,
  });

  /// Strict parse (throws on invalid shape).
  factory QuranicDua.fromJson(Map<String, dynamic> j) {
    final parsed = tryFromJson(j);
    if (parsed == null) {
      throw FormatException('Invalid QuranicDua: ${j['id']}');
    }
    return parsed;
  }

  /// Lenient parse: returns `null` if required fields are missing or invalid.
  static QuranicDua? tryFromJson(Map<String, dynamic> j) {
    try {
      final id = j['id'];
      final arabicText = j['arabicText'];
      if (id is! String || id.isEmpty) return null;
      if (arabicText is! String || arabicText.trim().isEmpty) return null;

      final surah = _readInt(j['surah']);
      final ayahStart = _readInt(j['ayahStart']);
      if (surah == null || ayahStart == null) return null;
      if (surah < 1 || surah > 114 || ayahStart < 1) return null;

      final ayEndRaw = j['ayahEnd'];
      int? ayahEnd;
      if (ayEndRaw != null) {
        ayahEnd = _readInt(ayEndRaw);
        if (ayahEnd != null && ayahEnd < ayahStart) return null;
      }

      return QuranicDua(
        id: id,
        arabicText: arabicText.trim(),
        surahNumber: surah,
        ayahStart: ayahStart,
        ayahEnd: ayahEnd,
        meaningEn: j['meaningEn'] is String ? (j['meaningEn'] as String) : '',
        meaningFr: j['meaningFr'] is String ? (j['meaningFr'] as String) : '',
        meaningAr: j['meaningAr'] is String ? (j['meaningAr'] as String) : '',
        categories: (j['categories'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList(),
        searchKeywords: (j['searchKeywords'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList(),
      );
    } catch (_) {
      return null;
    }
  }

  static int? _readInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  String referenceLabel() {
    final end = ayahEnd;
    if (end == null || end == ayahStart) return '$surahNumber:$ayahStart';
    return '$surahNumber:$ayahStart–$end';
  }

  String meaningForLocale(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return meaningAr.isNotEmpty ? meaningAr : meaningEn;
      case 'fr':
        return meaningFr.isNotEmpty ? meaningFr : meaningEn;
      default:
        return meaningEn;
    }
  }
}
