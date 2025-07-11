import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/prophets_data.dart';

class StoryDetailPage extends StatefulWidget {
  final String id;
  const StoryDetailPage({required this.id, super.key});

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  late Map<String, dynamic> p;
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool read = false;

  @override
  void initState() {
    super.initState();
    p = prophets.firstWhere((e) => e["id"] == widget.id);
    _loadReadState();
  }

  Future<void> _loadReadState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => read = prefs.getBool('read_${widget.id}') ?? false);
  }

  Future<void> _toggleRead() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => read = !read);
    await prefs.setBool('read_${widget.id}', read);
  }

  Future<void> _playAudio() async {
    await _player.setUrl(p["audioUrl"]);
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(p["name"]), backgroundColor: Colors.teal),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            ElevatedButton.icon(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              label: Text(isPlaying ? 'إيقاف الصوت' : 'تشغيل القصة'),
              onPressed: _playAudio,
            ),
            Expanded(child: SingleChildScrollView(child: Text(p["story"], style: const TextStyle(fontSize: 18, height: 1.6)))),
            Row(
              children: [
                Checkbox(value: read, onChanged: (_) => _toggleRead()),
                const Text('تمت القراءة'),
              ],
            )
          ]),
        ),
      ),
    );
  }
} 