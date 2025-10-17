import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/back_button_widget.dart';
import '../providers/settings_provider.dart';

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
  String selectedReciter = 'ماهر المعيقلي';
  double volume = 0.7;
  late SettingsProvider settings;

  @override
  void initState() {
    super.initState();
    loadSurahs();
    restoreLastPlayed();
    _loadSettings();
    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    settings = Provider.of<SettingsProvider>(context);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedReciter = prefs.getString('selectedReciter') ?? 'ماهر المعيقلي';
      volume = prefs.getDouble('volume') ?? 0.7;
    });
    _audioPlayer.setVolume(volume);
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
    // Use selected reciter from settings
    final reciter = settings.selectedReciter;
    // Assuming audio URLs are structured like 'https://example.com/{reciter}/{surah_number}.mp3'
    // Adjust based on actual API structure
    final url = surah['audio'].replaceAll('{reciter}', reciter.toLowerCase().replaceAll(' ', '-'));
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

  

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // Themed background
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
                child: surahs.isEmpty
                    ? Center(child: CircularProgressIndicator(color: cs.primary))
                    : ListView.builder(
                        itemCount: surahs.length,
                        itemBuilder: (context, index) {
                          final surah = surahs[index];
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
                              title: Text(
                                surah['name'],
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.amiri(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: cs.primary.withValues(alpha: 0.2),
                                child: Text(
                                  surah['number'].toString(),
                                  style: TextStyle(color: cs.onSurface),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  currentIndex == index && isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: cs.onSurface,
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
        bottomNavigationBar: buildBottomPlayerThemed(context),
      ),
    );
  }

  Widget buildBottomPlayerThemed(BuildContext context) {
    if (currentIndex == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final surah = surahs[currentIndex!];
    return Container(
      color: cs.primary.withValues(alpha: 0.12),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
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
                      activeColor: cs.primary,
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
            icon: Icon(Icons.skip_previous, color: cs.onSurface),
            onPressed: currentIndex! > 0 ? () => playSurah(currentIndex! - 1) : null,
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: cs.onSurface),
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
            icon: Icon(Icons.skip_next, color: cs.onSurface),
            onPressed: currentIndex! < surahs.length - 1 ? () => playSurah(currentIndex! + 1) : null,
          ),
        ],
      ),
    );
  }
}
