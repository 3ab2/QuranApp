import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

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
    const Color backgroundColor = Colors.white;
    const Color gold = Color(0xFFD4AF37);
    const Color softGreen = Color(0xFF90EE90);
    const Color darkGreen = Color(0xFF006400);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
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
                        'الاستماع للتلاوة',
                        style: GoogleFonts.amiri(
                          color: darkGreen,
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
                child: surahs.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: darkGreen))
                    : ListView.builder(
                        itemCount: surahs.length,
                        itemBuilder: (context, index) {
                          final surah = surahs[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text(
                                surah['name'],
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.amiri(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: darkGreen,
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: softGreen.withValues(alpha: 0.5),
                                child: Text(
                                  surah['number'].toString(),
                                  style: const TextStyle(color: darkGreen),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  currentIndex == index && isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: darkGreen,
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
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: buildBottomPlayer(),
      ),
    );
  }
} 