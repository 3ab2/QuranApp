import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/surah_data.dart';

class SurahDetailPage extends StatefulWidget {
  final int number;
  const SurahDetailPage({required this.number, super.key});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final AudioPlayer _player = AudioPlayer();
  List<dynamic> verses = [];
  bool isPlaying = false;
  int lastReadVerse = 1;

  @override
  void initState() {
    super.initState();
    loadVerses();
    loadLastRead();
  }

  Future<void> loadVerses() async {
    final res = await http.get(Uri.parse(
        'https://api.quran.com/api/v4/quran/verses/uthmani?chapter_number=${widget.number}'));
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      setState(() => verses = data['verses']);
    }
  }

  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => lastReadVerse =
        prefs.getInt('last_surah_${widget.number}') ?? 1);
  }

  Future<void> saveLastRead(int verse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah_${widget.number}', verse);
  }

  Future<void> playAudio() async {
    final surah = surahs.firstWhere((s) => s['number'] == widget.number);
    await _player.setUrl(surah['audioUrl']);
    _player.play();
    setState(() => isPlaying = true);
    _player.playerStateStream.listen((st) {
      if (st.processingState == ProcessingState.completed) {
        setState(() => isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    final title =
        surahs.firstWhere((s) => s['number'] == widget.number)['name'];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('سورة $title'), backgroundColor: Colors.indigo),
        body: Column(children: [
          ElevatedButton.icon(
            icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
            label: Text(isPlaying ? 'إيقاف التلاوة' : 'تشغيل التلاوة'),
            onPressed: playAudio,
          ),
          Expanded(
            child: verses.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: verses.length,
                    itemBuilder: (c, i) {
                      final v = verses[i];
                      final num = v['verse_number'];
                      return ListTile(
                        title: Text(
                          '${v['text_uthmani']} ﴿$num﴾',
                          textAlign: TextAlign.right,
                        ),
                        selected: num == lastReadVerse,
                        onTap: () {
                          saveLastRead(num);
                          setState(() => lastReadVerse = num);
                        },
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
} 