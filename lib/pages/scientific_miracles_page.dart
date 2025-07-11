import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/scientific_miracle_model.dart';
import '../services/miracle_service.dart';

class ScientificMiraclesPage extends StatefulWidget {
  const ScientificMiraclesPage({super.key});
  @override
  _ScientificMiraclesPageState createState() => _ScientificMiraclesPageState();
}

class _ScientificMiraclesPageState extends State<ScientificMiraclesPage> {
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('الإعجاز العلمي في القرآن', style: TextStyle(fontFamily: 'Amiri')),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن آية أو شرح أو تصنيف...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  filled: true,
                  fillColor: Colors.white,
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
                      label: const Text('الكل', style: TextStyle(fontFamily: 'Amiri')),
                      selected: selectedCategory == null,
                      onSelected: (_) {
                        setState(() { selectedCategory = null; filter(); });
                      },
                    ),
                  ),
                  ...categories.map((cat) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(cat, style: const TextStyle(fontFamily: 'Amiri')),
                      selected: selectedCategory == cat,
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
                ? const Center(child: Text('لا توجد نتائج', style: TextStyle(fontFamily: 'Amiri', fontSize: 18)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final miracle = filtered[index];
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            miracle.verse,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Amiri'),
                            textAlign: TextAlign.right,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 8),
                              Text('سورة ${miracle.surah} - آية ${miracle.ayah}', style: const TextStyle(fontFamily: 'Amiri')),
                              const SizedBox(height: 4),
                              Text(
                                miracle.explanation,
                                style: const TextStyle(fontSize: 15, color: Colors.black87, fontFamily: 'Amiri'),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(miracle.category, style: const TextStyle(fontSize: 13, color: Colors.indigo, fontFamily: 'Amiri')),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.volume_up, color: Colors.indigo),
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
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 