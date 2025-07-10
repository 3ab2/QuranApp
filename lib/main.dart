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
        '/quran': (context) => QuranPage(),
        '/adhan': (context) => const AdhanPage(),
        '/tafsir': (context) => const TafsirPage(),
        '/audio': (context) => const AudioPage(),
        '/stories': (context) => const StoriesPage(),
        '/miracles': (context) => const MiraclesPage(),
        '/search': (context) => const SearchPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
} 