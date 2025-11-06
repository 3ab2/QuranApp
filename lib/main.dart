import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'data/prophets_data.dart';
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
          title: 'Quran App',
          debugShowCheckedModeBanner: false,
          theme: settings.getLightThemeData(),
          darkTheme: settings.getDarkThemeData(),
          themeMode: settings.themeMode,
          home: const HomePage(),
          routes: {
            '/quran': (context) => const QuranPage(),
            for (var s in surahs)
              '/surah/${s['number']}': (context) => SurahDetailPage(surahNumber: s['number'], surahName: s['name']),
            '/adhan': (context) => const AdhanPage(),
            '/tafsir': (context) => const TafsirPage(),
            '/audio': (context) => const AudioPage(),
            '/stories': (context) => const StoriesPage(),
            for (var p in prophets)
              '/story/${p["id"]}': (context) => StoryDetailPage(id: p["id"]),
            '/scientific-miracles': (context) => const ScientificMiraclesPage(),
            '/settings': (context) => const SettingsPage(),

          },
        );
      },
    );
  }
}
