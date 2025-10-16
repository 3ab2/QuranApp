import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quran_service.dart';
import '../widgets/top_bar.dart';

class VerseNumber extends StatefulWidget {
  final Map<String, dynamic> verse;
  final bool isFav;
  final double fontSize;
  final VoidCallback onLike;

  const VerseNumber({required this.verse, required this.isFav, required this.fontSize, required this.onLike, super.key});

  @override
  State<VerseNumber> createState() => _VerseNumberState();
}

class _VerseNumberState extends State<VerseNumber> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green.shade200.withValues(alpha: 128 / 255),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                widget.verse['verse_key'].split(':')[1],
                style: TextStyle(fontSize: widget.fontSize * 0.7, fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: AnimatedOpacity(
                opacity: hovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: widget.onLike,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isFav ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFav ? Colors.red : Colors.grey,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailPage({required this.surahNumber, required this.surahName, super.key});

  @override
  SurahDetailPageState createState() => SurahDetailPageState();
}

class SurahDetailPageState extends State<SurahDetailPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> verses = [];
  List<Map<String, dynamic>> filteredVerses = [];
  bool loaded = false;
  double fontSize = 22.0;
  String searchQuery = '';
  bool isSearching = false;
  Set<String> favorites = {};

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _loadPreferences();
    loadData();
  }

  Future<void> loadData() async {
    verses = await QuranService.getVersesBySurah(widget.surahNumber);
    filteredVerses = verses;
    setState(() {
      loaded = true;
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      fontSize = prefs.getDouble('fontSize') ?? 22.0;
      favorites = (prefs.getStringList('favorites') ?? []).toSet();
    });
  }

  Future<void> _saveFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('fontSize', fontSize);
  }

  Future<void> _saveFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favorites.toList());
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;
    const Color gold = Color(0xFFD4AF37);
    const Color darkGreen = Color(0xFF006400);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(),
            const SizedBox(height: 20),
            // App Bar Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: darkGreen),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: isSearching
                        ? TextField(
                            autofocus: true,
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                                filteredVerses = verses.where((v) => v['text'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search verses...',
                              border: InputBorder.none,
                            ),
                          )
                        : Text(
                            widget.surahName,
                            style: GoogleFonts.amiri(
                              color: darkGreen,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  if (!isSearching)
                    IconButton(
                      icon: const Icon(Icons.search, color: darkGreen),
                      onPressed: () {
                        setState(() {
                          isSearching = true;
                        });
                      },
                    ),
                  if (isSearching)
                    IconButton(
                      icon: const Icon(Icons.close, color: darkGreen),
                      onPressed: () {
                        setState(() {
                          isSearching = false;
                          searchQuery = '';
                          filteredVerses = verses;
                        });
                      },
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: darkGreen),
                    onSelected: (value) {
                      if (value == 'increase_font') {
                        setState(() {
                          fontSize += 2;
                        });
                        _saveFontSize();
                      } else if (value == 'decrease_font') {
                        setState(() {
                          fontSize = max(14.0, fontSize - 2);
                        });
                        _saveFontSize();
                      }
                      // Handle other menu actions
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'increase_font', child: Text('Increase Font Size')),
                      const PopupMenuItem(value: 'decrease_font', child: Text('Decrease Font Size')),
                      const PopupMenuItem(value: 'about', child: Text('About')),
                      const PopupMenuItem(value: 'help', child: Text('Help')),
                      const PopupMenuItem(value: 'rate', child: Text('Rate Us')),
                      const PopupMenuItem(value: 'sources', child: Text('Trusted Sources')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: loaded
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                              style: GoogleFonts.amiri(
                                fontSize: fontSize + 2,
                                fontWeight: FontWeight.bold,
                                color: gold,
                                shadows: [
                                  Shadow(
                                    color: gold.withValues(alpha: 0.5),
                                    offset: const Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: RichText(
                                text: TextSpan(
                                  children: filteredVerses.expand((verse) {
                                    bool isFav = favorites.contains(verse['verse_key']);
                                    return [
                                      TextSpan(
                                        text: verse['text'],
                                        style: GoogleFonts.amiri(
                                          fontSize: fontSize,
                                          color: const Color.fromARGB(255, 24, 27, 24),
                                          shadows: [
                                            Shadow(
                                              color: gold.withValues(alpha: 0.3),
                                              offset: const Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' (${verse['verse_key'].split(':')[1]}) ',
                                        style: GoogleFonts.amiri(
                                          fontSize: fontSize,
                                          color: const Color.fromARGB(255, 5, 122, 15),
                                          shadows: [
                                            Shadow(
                                              color: gold.withValues(alpha: 0.3),
                                              offset: const Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              if (isFav) {
                                                favorites.remove(verse['verse_key']);
                                              } else {
                                                favorites.add(verse['verse_key']);
                                              }
                                            });
                                            _saveFavorites();
                                          },
                                      ),
                                    ];
                                  }).toList(),
                                ),
                                softWrap: true,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator(color: darkGreen)),
            ),
          ],
        ),
      ),
    );
  }
}
