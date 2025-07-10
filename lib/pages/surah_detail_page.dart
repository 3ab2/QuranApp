import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailPage({super.key, required this.surahNumber, required this.surahName});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  List<dynamic> verses = [];
  bool isLoading = true;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchSurah();
  }

  Future<void> fetchSurah() async {
    final url =
        'https://api.quran.com:443/v4/quran/verses/uthmani?chapter_number=${widget.surahNumber}';
    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() {
        verses = data['verses'];
        isLoading = false;
      });
    }
  }

  Future<void> playAudio() async {
    final audioUrl = "https://verses.quran.com/${widget.surahNumber.toString().padLeft(3, '0')}.mp3";
    try {
      await _player.setUrl(audioUrl);
      _player.play();
    } catch (e) {
      print("خطأ فـ الصوت: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.surahName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ElevatedButton.icon(
                  onPressed: playAudio,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('تشغيل التلاوة'),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: verses.length,
                    itemBuilder: (context, index) {
                      final verse = verses[index];
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          '${verse['text_uthmani']} ﴿${verse['verse_number']}﴾',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 22),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
} 