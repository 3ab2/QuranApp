import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import '../widgets/top_bar.dart';
import '../widgets/common_ui.dart';
import '../providers/settings_provider.dart';
import '../providers/download_provider.dart';
import '../services/quran_audio_service.dart';
import '../ui/app_tokens.dart';

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
  StreamSubscription<PlayerState>? _playerStateSubscription;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    loadSurahs();
    restoreLastPlayed();
    _loadSettings();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
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
    if (!mounted) return;
    setState(() {
      selectedReciter = prefs.getString('selectedReciter') ?? 'ماهر المعيقلي';
      volume = prefs.getDouble('volume') ?? 0.7;
    });
    _audioPlayer.setVolume(volume);
  }

  Future<void> loadSurahs() async {
    try {
      final data = await QuranAudioService.loadSurahs();
      if (!mounted) return;
      setState(() {
        surahs = data;
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'load_failed';
      });
    }
  }

  Future<void> playSurah(int index, {Duration? position}) async {
    if (surahs.isEmpty || index < 0 || index >= surahs.length) return;
    final surah = Map<String, dynamic>.from(surahs[index]);
    final reciter = settings.selectedReciter;
    final downloadProvider = context.read<DownloadProvider>();
    try {
      await _audioPlayer.stop();
      final result = await QuranAudioService.setPlayerSourceWithFallback(
        player: _audioPlayer,
        surahNumber: surah['number'] as int,
        surah: surah,
        reciter: reciter,
        downloadProvider: downloadProvider,
      );
      if (position != null) {
        await _audioPlayer.seek(position);
      }
      await _audioPlayer.play();
      if (!mounted) return;
      setState(() {
        currentIndex = index;
        isPlaying = true;
      });
      if (result.usingLocal) {
        final l10n = AppLocalizations.of(context)!;
        AppFeedback.showInfo(context, l10n.audioLocalPlayback);
      }
      saveLastPlayed(index, position: position ?? Duration.zero);
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      AppFeedback.showError(context, l10n.audioPlayError);
    }
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
      if (!mounted) return;
      setState(() {
        currentIndex = lastSurah;
        lastPosition = Duration(milliseconds: lastPositionMs);
      });
    }
  }

  

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        // Themed background
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(title: l10n.audioPageTitle),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  child: _loadError != null
                      ? AppErrorView(message: l10n.audioLoadError, onRetry: loadSurahs)
                      : surahs.isEmpty
                      ? AppLoadingView(label: '${l10n.audioPageTitle}...')
                      : ListView.builder(
                        itemCount: surahs.length,
                        itemBuilder: (context, index) {
                          final surah = surahs[index];
                          return AppCard(
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
