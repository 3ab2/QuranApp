import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/quran_page.dart';
import 'pages/adhan_page.dart';
import 'pages/tafsir_page.dart';
import 'pages/audio_page.dart';
import 'pages/stories_page.dart';
import 'pages/miracles_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'pages/story_detail_page.dart';
import 'data/prophets_data.dart';
import 'pages/surah_detail_page.dart';
import 'data/surah_data.dart';
import 'pages/scientific_miracles_page.dart';
import 'pages/splash_screen.dart';
import 'pages/search_surah_page.dart';

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adhan Quran App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Amiri',
        brightness: Brightness.light,
      ),
      home: const HomePage(),
      routes: {
        '/quran': (context) => const QuranPage(),
        for (var s in surahs)
          '/surah/${s['number']}': (context) => SurahDetailPage(number: s['number']),
        '/adhan': (context) => const AdhanPage(),
        '/tafsir': (context) => const TafsirPage(),
        '/audio': (context) => const AudioPage(),
        '/stories': (context) => const StoriesPage(),
        for (var p in prophets)
          '/story/${p["id"]}': (context) => StoryDetailPage(id: p["id"]),
        '/miracles': (context) => MiraclesPage(),
        '/scientific-miracles': (context) => ScientificMiraclesPage(),
        '/search': (context) => const SearchPage(),
        '/search-surah': (context) => const SearchSurahPage(),
        '/settings': (context) => const SettingsPage(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
} 