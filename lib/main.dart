import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'providers/download_provider.dart';
import 'pages/home_page.dart';
import 'pages/quran_page.dart';
import 'pages/adhan_page.dart';
import 'pages/tafsir_page.dart';
import 'pages/audio_page.dart';
import 'pages/stories_page.dart';
import 'pages/settings_page.dart';
import 'pages/story_detail_page.dart';
import 'pages/surah_detail_page.dart';
import 'data/surah_data.dart';
import 'pages/scientific_miracles_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();
  final downloadProvider = DownloadProvider();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => settingsProvider),
        ChangeNotifierProvider(create: (context) => downloadProvider),
      ],
      child: const QuranApp(),
    ),
  );
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? 'Quran App',
          debugShowCheckedModeBanner: false,
          theme: settings.getLightThemeData(),
          darkTheme: settings.getDarkThemeData(),
          themeMode: settings.themeMode,
          initialRoute: '/',
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
            Locale('fr'),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('ar');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('ar');
          },
          routes: {
            '/': (context) => const HomePage(),
            '/quran': (context) => const QuranPage(),
            for (var s in surahs)
              '/surah/${s['number']}': (context) => SurahDetailPage(
                  surahNumber: s['number'], surahName: s['name']),
            '/adhan': (context) => const AdhanPage(),
            '/tafsir': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              int? parseInt(dynamic value) {
                if (value is int) return value;
                if (value is String) {
                  return int.tryParse(value.split(':').first);
                }
                return null;
              }

              return TafsirPage(
                surahNumber: parseInt(args?['surahNumber']),
                ayahNumber: parseInt(args?['ayahNumber']),
              );
            },
            '/audio': (context) => const AudioPage(),
            '/stories': (context) => const StoriesPage(),
            '/scientific-miracles': (context) => const ScientificMiraclesPage(),
            '/settings': (context) => const SettingsPage(),
          },
          onGenerateRoute: (settings) {
            final name = settings.name;
            if (name != null && name.startsWith('/story/')) {
              final id = Uri.decodeComponent(name.substring('/story/'.length));
              if (id.isNotEmpty) {
                return MaterialPageRoute(
                  builder: (context) => StoryDetailPage(id: id),
                  settings: settings,
                );
              }
            }
            return null;
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      },
    );
  }
}
