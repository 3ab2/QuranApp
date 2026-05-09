import 'package:shared_preferences/shared_preferences.dart';

/// Reader typography and future mushaf toggle; isolated from other modules.
class QuranReaderPreferences {
  QuranReaderPreferences._();
  static final QuranReaderPreferences instance = QuranReaderPreferences._();

  static const _kLineHeight = 'quranReaderLineHeight';
  static const _kMushafMode = 'quranReaderMushafModeReady';

  /// Typographic line height multiplier (TextStyle.height).
  static const double defaultLineHeight = 1.45;

  Future<double> loadLineHeight() async {
    final p = await SharedPreferences.getInstance();
    return p.getDouble(_kLineHeight) ?? defaultLineHeight;
  }

  Future<void> saveLineHeight(double h) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kLineHeight, h.clamp(1.15, 2.0));
  }

  /// Placeholder flag for a future mushaf layout mode.
  Future<bool> loadMushafModeReady() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kMushafMode) ?? false;
  }

  Future<void> saveMushafModeReady(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kMushafMode, v);
  }
}
