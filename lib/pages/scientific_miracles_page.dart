import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/scientific_miracle_model.dart';
import '../services/miracle_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class ScientificMiraclesPage extends StatefulWidget {
  const ScientificMiraclesPage({super.key});

  @override
  ScientificMiraclesPageState createState() => ScientificMiraclesPageState();
}

class ScientificMiraclesPageState extends State<ScientificMiraclesPage> {
  List<ScientificMiracle> miracles = [];
  List<ScientificMiracle> filtered = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  String search = '';
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final data = await MiracleService.loadMiracles();
    setState(() {
      miracles = data;
      filtered = data;
    });
  }

  void playAudio(String url) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(url));
  }

  void filter() {
    setState(() {
      filtered = miracles.where((m) {
        final matchesText = search.isEmpty ||
            m.verse.contains(search) ||
            m.surah.contains(search) ||
            m.explanation.contains(search) ||
            m.category.contains(search);
        final matchesCat = selectedCategory == null || m.category == selectedCategory;
        return matchesText && matchesCat;
      }).toList();
    });
  }

  List<String> get categories => miracles.map((m) => m.category).toSet().toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: 20),

              // Back Button and Page Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const BackButtonWidget(),
                    Expanded(
                      child: Text(
                        'الإعجاز العلمي في القرآن',
                        style: GoogleFonts.amiri(
                          color: cs.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث عن آية أو شرح أو تصنيف...',
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                          filled: true,
                          fillColor: theme.cardColor,
                        ),
                        onChanged: (val) {
                          search = val;
                          filter();
                        },
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ChoiceChip(
                              label: Text('الكل', style: GoogleFonts.amiri(color: cs.onSurface)),
                              selected: selectedCategory == null,
                              selectedColor: cs.primary,
                              backgroundColor: theme.cardColor,
                              onSelected: (_) { setState(() { selectedCategory = null; filter(); }); },
                            ),
                          ),
                          ...categories.map((cat) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: ChoiceChip(
                                  label: Text(cat, style: GoogleFonts.amiri(color: selectedCategory == cat ? cs.onPrimary : cs.onSurface)),
                                  selected: selectedCategory == cat,
                                  selectedColor: cs.primary,
                                  backgroundColor: theme.cardColor,
                                  onSelected: (_) {
                                    setState(() { selectedCategory = cat; filter(); });
                                  },
                                ),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد نتائج',
                                style: GoogleFonts.amiri(
                                  fontSize: 18,
                                  color: cs.onSurface,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final miracle = filtered[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.shadowColor.withValues(alpha: 0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    title: Text(
                                      miracle.verse,
                                      style: GoogleFonts.amiri(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: cs.onSurface,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'سورة ${miracle.surah} - آية ${miracle.ayah}',
                                          style: GoogleFonts.amiri(
                                        color: cs.onSurface.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          miracle.explanation,
                                          style: GoogleFonts.amiri(
                                            fontSize: 15,
                                            color: cs.onSurface.withValues(alpha: 0.85),
                                          ),
                                          textDirection: TextDirection.rtl,
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: cs.primary.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            miracle.category,
                                            style: GoogleFonts.amiri(
                                              fontSize: 13,
                                              color: cs.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.volume_up, color: cs.onSurface),
                                      onPressed: () => playAudio(miracle.audio),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
 