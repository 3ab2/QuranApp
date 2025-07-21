import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({Key? key}) : super(key: key);

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  List surahs = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? currentIndex;
  bool isPlaying = false;
  Duration? lastPosition;

  @override
  void initState() {
    super.initState();
    loadSurahs();
    restoreLastPlayed();
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  Future<void> loadSurahs() async {
    final jsonString = await rootBundle.loadString('assets/data/surahs.json');
    final data = json.decode(jsonString);
    setState(() {
      surahs = data;
    });
  }

  Future<void> playSurah(int index, {Duration? position}) async {
    final surah = surahs[index];
    final url = surah['audio'];
    await _audioPlayer.setUrl(url);
    if (position != null) {
      await _audioPlayer.seek(position);
    }
    await _audioPlayer.play();
    setState(() {
      currentIndex = index;
      isPlaying = true;
    });
    saveLastPlayed(index, position: position ?? Duration.zero);
  }

  Future<void> saveLastPlayed(int index, {Duration position = Duration.zero}) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastSurah', index);
    prefs.setInt('lastPosition', position.inMilliseconds);
  }

  Future<void> restoreLastPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSurah = prefs.getInt('lastSurah');
    final lastPositionMs = prefs.getInt('lastPosition');
    if (lastSurah != null && lastPositionMs != null) {
      setState(() {
        currentIndex = lastSurah;
        lastPosition = Duration(milliseconds: lastPositionMs);
      });
    }
  }

  Widget buildBottomPlayer() {
    if (currentIndex == null) return const SizedBox.shrink();
    final surah = surahs[currentIndex!];
    return Container(
      color: Colors.green.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surah['name'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textDirection: TextDirection.rtl,
                ),
                StreamBuilder<Duration>(
                  stream: _audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final total = _audioPlayer.duration ?? Duration.zero;
                    return Slider(
                      value: position.inSeconds.toDouble(),
                      max: total.inSeconds.toDouble() > 0 ? total.inSeconds.toDouble() : 1,
                      onChanged: (v) async {
                        await _audioPlayer.seek(Duration(seconds: v.toInt()));
                        saveLastPlayed(currentIndex!, position: Duration(seconds: v.toInt()));
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: currentIndex! > 0 ? () => playSurah(currentIndex! - 1) : null,
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (isPlaying) {
                _audioPlayer.pause();
                saveLastPlayed(currentIndex!, position: _audioPlayer.position);
              } else {
                playSurah(currentIndex!, position: _audioPlayer.position);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: currentIndex! < surahs.length - 1 ? () => playSurah(currentIndex! + 1) : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الاستماع للتلاوة'),
          backgroundColor: Colors.green.shade700,
        ),
        body: surahs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: surahs.length,
                itemBuilder: (context, index) {
                  final surah = surahs[index];
                  return ListTile(
                    title: Text(
                      surah['name'],
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    leading: CircleAvatar(
                      child: Text(surah['number'].toString()),
                      backgroundColor: Colors.green.shade200,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        currentIndex == index && isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.green.shade700,
                      ),
                      onPressed: () {
                        if (currentIndex == index && isPlaying) {
                          _audioPlayer.pause();
                          saveLastPlayed(index, position: _audioPlayer.position);
                        } else {
                          playSurah(index, position: (currentIndex == index) ? _audioPlayer.position : null);
                        }
                      },
                    ),
                    onTap: () {
                      playSurah(index, position: (currentIndex == index) ? _audioPlayer.position : null);
                    },
                  );
                },
              ),
        bottomNavigationBar: buildBottomPlayer(),
      ),
    );
  }
} 