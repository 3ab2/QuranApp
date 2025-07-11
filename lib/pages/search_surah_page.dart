import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SearchSurahPage extends StatefulWidget {
  const SearchSurahPage({super.key});
  @override
  State<SearchSurahPage> createState() => _SearchSurahPageState();
}

class _SearchSurahPageState extends State<SearchSurahPage> {
  List _surahs = [];
  List _filteredSurahs = [];
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    final String data = await rootBundle.loadString('assets/data/surahs.json');
    final List jsonResult = json.decode(data);
    setState(() {
      _surahs = jsonResult;
      _filteredSurahs = _surahs;
    });
  }

  void _filterSurahs(String query) {
    final results = _surahs.where((surah) =>
        surah['name'].toString().contains(query)).toList();
    setState(() {
      _filteredSurahs = results;
    });
  }

  void _playAudio(String url) async {
    await _player.stop();
    await _player.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('البحث في السور', style: TextStyle(fontFamily: 'Amiri')),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                onChanged: _filterSurahs,
                decoration: InputDecoration(
                  labelText: 'ابحث عن سورة',
                  labelStyle: const TextStyle(fontFamily: 'Amiri'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.search),
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              child: _filteredSurahs.isEmpty
                ? const Center(child: Text('لا توجد نتائج', style: TextStyle(fontFamily: 'Amiri', fontSize: 18)))
                : ListView.builder(
                    itemCount: _filteredSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = _filteredSurahs[index];
                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            '${surah["name"]}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Amiri', fontSize: 18),
                          ),
                          subtitle: Text(
                            'عدد الآيات: ${surah["numberOfAyahs"]} • ${surah["revelationType"]}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontFamily: 'Amiri'),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Text(
                              '${surah["number"]}',
                              style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontFamily: 'Amiri'),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow, color: Colors.indigo),
                            onPressed: () => _playAudio(surah['audio']),
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
} 