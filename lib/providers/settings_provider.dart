import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/quran_audio_service.dart';
import '../ui/app_tokens.dart';

class SettingsProvider extends ChangeNotifier {
  // Preferences keys
  static const _kDarkMode = 'darkMode';
  static const _kSelectedReciter = 'selectedReciter';
  static const _kSelectedLanguage = 'selectedLanguage';
  static const _kVolume = 'volume';

  // State
  bool _isDarkMode = false;
  String _selectedReciter = QuranAudioService.defaultReciterName;
  String _selectedLanguage = 'العربية';
  double _volume = 0.7;

  // Init
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_kDarkMode) ?? false;
    _selectedReciter =
        prefs.getString(_kSelectedReciter) ?? QuranAudioService.defaultReciterName;
    _selectedLanguage = prefs.getString(_kSelectedLanguage) ?? 'العربية';
    _volume = prefs.getDouble(_kVolume) ?? 0.7;
    notifyListeners();
  }

  // Theme
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get isDarkMode => _isDarkMode;

  // Other settings
  String get selectedReciter => _selectedReciter;
  String get selectedLanguage => _selectedLanguage;
  double get volume => _volume;
  Locale get locale {
    switch (_selectedLanguage) {
      case 'English':
      case 'Anglais':
      case 'الإنجليزية':
        return const Locale('en');
      case 'Français':
      case 'French':
      case 'الفرنسية':
        return const Locale('fr');
      case 'العربية':
      case 'Arabic':
      case 'Arabe':
      default:
        return const Locale('ar');
    }
  }

  static ThemeData _productionPolish(ThemeData base, ColorScheme scheme) {
    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
      highlightColor: scheme.primary.withValues(alpha: 0.06),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.2),
      ),
    );
  }

  // Soft, eye-friendly palettes
  ThemeData getThemeData() {
    final baseLight = ThemeData.light(useMaterial3: true);
    final baseDark = ThemeData.dark(useMaterial3: true);

    const primaryLight = Color(0xFF0B5D3B); // deep green
    const primaryDark = Color(0xFF8DD3B0); // soft mint for dark
    const accentGoldLight = Color(0xFFC9A227); // muted gold
    const accentGoldDark = Color(0xFFE0C572);

    const lightScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: Colors.white,
      secondary: accentGoldLight,
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      surface: Color(0xFFF7F7F9),
      onSurface: Color(0xFF1C1C1E),
    );

    const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Color(0xFF0B3A28),
      secondary: accentGoldDark,
      onSecondary: Color(0xFF2B2A20),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF680003),
      surface: Color(0xFF171819), // deep but soft gray
      onSurface: Color(0xFFE6E6E6),
    );

    final light = baseLight.copyWith(
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.surface,
      cardColor: lightScheme.surface,
      dividerColor: lightScheme.secondary.withValues(alpha: 0.2),
      appBarTheme: AppBarTheme(
        backgroundColor: lightScheme.surface,
        foregroundColor: lightScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: baseLight.textTheme.apply(
        bodyColor: lightScheme.onSurface,
        displayColor: lightScheme.onSurface,
      ),
      sliderTheme: baseLight.sliderTheme.copyWith(
        activeTrackColor: lightScheme.primary,
        thumbColor: lightScheme.primary,
        inactiveTrackColor: lightScheme.primary.withValues(alpha: 0.3),
      ),
      switchTheme: baseLight.switchTheme.copyWith(
        thumbColor: WidgetStatePropertyAll(lightScheme.primary),
        trackColor: WidgetStatePropertyAll(lightScheme.primary.withValues(alpha: 0.3)),
      ),
      iconTheme: IconThemeData(color: lightScheme.onSurface),
      popupMenuTheme: PopupMenuThemeData(
        color: lightScheme.surface,
        textStyle: TextStyle(color: lightScheme.onSurface),
      ),
    );

    final dark = baseDark.copyWith(
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.surface,
      cardColor: darkScheme.surface,
      dividerColor: darkScheme.onSurface.withValues(alpha: 0.12),
      appBarTheme: AppBarTheme(
        backgroundColor: darkScheme.surface,
        foregroundColor: darkScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: baseDark.textTheme.apply(
        bodyColor: darkScheme.onSurface,
        displayColor: darkScheme.onSurface,
      ),
      sliderTheme: baseDark.sliderTheme.copyWith(
        activeTrackColor: darkScheme.primary,
        thumbColor: darkScheme.primary,
        inactiveTrackColor: darkScheme.primary.withValues(alpha: 0.35),
      ),
      switchTheme: baseDark.switchTheme.copyWith(
        thumbColor: WidgetStatePropertyAll(darkScheme.primary),
        trackColor: WidgetStatePropertyAll(darkScheme.primary.withValues(alpha: 0.35)),
      ),
      iconTheme: IconThemeData(color: darkScheme.onSurface),
      popupMenuTheme: PopupMenuThemeData(
        color: darkScheme.surface,
        textStyle: TextStyle(color: darkScheme.onSurface),
      ),
    );

    return _isDarkMode ? dark : light;
  }

  ThemeData getLightThemeData() {
    final baseLight = ThemeData.light(useMaterial3: true);
    const primaryLight = Color(0xFF0B5D3B);
    const accentGoldLight = Color(0xFFC9A227);
    const lightScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: Colors.white,
      secondary: accentGoldLight,
      onSecondary: Colors.white,
      error: Color(0xFFB00020),
      onError: Colors.white,
      surface: Color(0xFFF7F7F9),
      onSurface: Color(0xFF1C1C1E),
    );
    final light = baseLight.copyWith(
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.surface,
      cardColor: lightScheme.surface,
      dividerColor: lightScheme.secondary.withValues(alpha: 0.2),
      appBarTheme: AppBarTheme(
        backgroundColor: lightScheme.surface,
        foregroundColor: lightScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: baseLight.textTheme.apply(
        bodyColor: lightScheme.onSurface,
        displayColor: lightScheme.onSurface,
      ),
      sliderTheme: baseLight.sliderTheme.copyWith(
        activeTrackColor: lightScheme.primary,
        thumbColor: lightScheme.primary,
        inactiveTrackColor: lightScheme.primary.withValues(alpha: 0.3),
      ),
      switchTheme: baseLight.switchTheme.copyWith(
        thumbColor: WidgetStatePropertyAll(lightScheme.primary),
        trackColor: WidgetStatePropertyAll(lightScheme.primary.withValues(alpha: 0.3)),
      ),
      iconTheme: IconThemeData(color: lightScheme.onSurface),
      popupMenuTheme: PopupMenuThemeData(
        color: lightScheme.surface,
        textStyle: TextStyle(color: lightScheme.onSurface),
      ),
    );
    return _productionPolish(light, lightScheme);
  }

  ThemeData getDarkThemeData() {
    final baseDark = ThemeData.dark(useMaterial3: true);
    const primaryDark = Color(0xFF8DD3B0);
    const accentGoldDark = Color(0xFFE0C572);
    const darkScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Color(0xFF0B3A28),
      secondary: accentGoldDark,
      onSecondary: Color(0xFF2B2A20),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF680003),
      surface: Color(0xFF171819),
      onSurface: Color(0xFFE6E6E6),
    );
    final dark = baseDark.copyWith(
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.surface,
      cardColor: darkScheme.surface,
      dividerColor: darkScheme.onSurface.withValues(alpha: 0.12),
      appBarTheme: AppBarTheme(
        backgroundColor: darkScheme.surface,
        foregroundColor: darkScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: baseDark.textTheme.apply(
        bodyColor: darkScheme.onSurface,
        displayColor: darkScheme.onSurface,
      ),
      sliderTheme: baseDark.sliderTheme.copyWith(
        activeTrackColor: darkScheme.primary,
        thumbColor: darkScheme.primary,
        inactiveTrackColor: darkScheme.primary.withValues(alpha: 0.35),
      ),
      switchTheme: baseDark.switchTheme.copyWith(
        thumbColor: WidgetStatePropertyAll(darkScheme.primary),
        trackColor: WidgetStatePropertyAll(darkScheme.primary.withValues(alpha: 0.35)),
      ),
      iconTheme: IconThemeData(color: darkScheme.onSurface),
      popupMenuTheme: PopupMenuThemeData(
        color: darkScheme.surface,
        textStyle: TextStyle(color: darkScheme.onSurface),
      ),
    );
    return _productionPolish(dark, darkScheme);
  }

  // Mutators with persistence
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
    notifyListeners();
  }

  Future<void> setSelectedReciter(String value) async {
    _selectedReciter = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedReciter, value);
    notifyListeners();
  }

  Future<void> setSelectedLanguage(String value) async {
    _selectedLanguage = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedLanguage, value);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kVolume, value);
    notifyListeners();
  }
}
