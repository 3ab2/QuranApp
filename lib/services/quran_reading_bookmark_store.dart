import 'package:shared_preferences/shared_preferences.dart';

/// Persisted reading position for the continuous Quran reader.
/// Service-only; no UI dependencies.
class QuranReadingBookmark {
  final int surahNumber;
  final int ayahNumber;
  final double? scrollOffsetPx;

  const QuranReadingBookmark({
    required this.surahNumber,
    required this.ayahNumber,
    this.scrollOffsetPx,
  });
}

class QuranReadingBookmarkStore {
  QuranReadingBookmarkStore._();
  static final QuranReadingBookmarkStore instance = QuranReadingBookmarkStore._();

  static const _kSurah = 'quranReadingBookmarkSurah';
  static const _kAyah = 'quranReadingBookmarkAyah';
  static const _kOffset = 'quranReadingBookmarkOffset';

  Future<QuranReadingBookmark?> load() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getInt(_kSurah);
    final a = p.getInt(_kAyah);
    if (s == null || a == null || s < 1 || s > 114 || a < 1) return null;
    final o = p.getDouble(_kOffset);
    return QuranReadingBookmark(surahNumber: s, ayahNumber: a, scrollOffsetPx: o);
  }

  Future<void> save(QuranReadingBookmark b) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kSurah, b.surahNumber);
    await p.setInt(_kAyah, b.ayahNumber);
    if (b.scrollOffsetPx != null) {
      await p.setDouble(_kOffset, b.scrollOffsetPx!);
    } else {
      await p.remove(_kOffset);
    }
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSurah);
    await p.remove(_kAyah);
    await p.remove(_kOffset);
  }
}
