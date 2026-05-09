import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/download_provider.dart';

class AudioDetailsPage extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Map<String, dynamic> surah;
  final int currentIndex;
  final bool isPlaying;
  final Function(int) onPlaySurah;
  final Function() onPause;
  final Function() onResume;
  final Function(int) onSeek;
  final String reciterName;

  const AudioDetailsPage({
    super.key,
    required this.audioPlayer,
    required this.surah,
    required this.currentIndex,
    required this.isPlaying,
    required this.onPlaySurah,
    required this.onPause,
    required this.onResume,
    required this.onSeek,
    this.reciterName = 'محمد اللحيدان',
  });

  @override
  State<AudioDetailsPage> createState() => _AudioDetailsPageState();
}

class _AudioDetailsPageState extends State<AudioDetailsPage> {
  late bool _isPlaying;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.isPlaying;
    _playerStateSubscription = widget.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            widget.surah['name'],
            style: GoogleFonts.amiri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background Image with Blur
            Positioned.fill(
              child: Image.asset(
                'assets/images/lhdan.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: cs.surface,
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.green.shade200.withValues(alpha: 0.4),
                    Colors.white.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: kToolbarHeight + 20), // Space for app bar
                  // Surah Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          widget.surah['name'],
                          style: GoogleFonts.amiri(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.reciterName,
                          style: GoogleFonts.amiri(
                            fontSize: 18,
                            color: cs.onSurface.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Centered Play/Pause Button and Download Icon
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 80,
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: cs.primary,
                          ),
                          onPressed: _isPlaying ? widget.onPause : widget.onResume,
                        ),
                        const SizedBox(height: 20),
                        Consumer<DownloadProvider>(
                          builder: (context, downloadProvider, child) {
                            final surahNumber = widget.currentIndex + 1;
                            final isDownloaded = downloadProvider.isDownloaded[widget.currentIndex] == true;
                            final isDownloading = downloadProvider.isDownloading[widget.currentIndex] == true;

                            return IconButton(
                              iconSize: 48,
                              icon: isDownloaded
                                  ? Icon(Icons.check, color: cs.primary)
                                  : isDownloading
                                      ? SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                                        )
                                      : Icon(Icons.cloud_download, color: cs.onSurface),
                              onPressed: isDownloaded || isDownloading
                                  ? null
                                  : () => downloadProvider.downloadSurah(context, surahNumber),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Progress Bar and Controls
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Progress Bar
                        StreamBuilder<Duration>(
                          stream: widget.audioPlayer.positionStream,
                          builder: (context, positionSnapshot) {
                            final position = positionSnapshot.data ?? Duration.zero;
                            return StreamBuilder<Duration?>(
                              stream: widget.audioPlayer.durationStream,
                              builder: (context, durationSnapshot) {
                                final total = durationSnapshot.data ?? Duration.zero;
                                return Column(
                                  children: [
                                    Slider(
                                      value: position.inSeconds.toDouble().clamp(0.0, total.inSeconds.toDouble() > 0 ? total.inSeconds.toDouble() : 1.0),
                                      max: total.inSeconds.toDouble() > 0 ? total.inSeconds.toDouble() : 1.0,
                                      activeColor: cs.primary,
                                      onChanged: (v) {
                                        widget.onSeek(v.toInt());
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(position),
                                            style: TextStyle(color: cs.onSurface),
                                          ),
                                          Text(
                                            _formatDuration(total),
                                            style: TextStyle(color: cs.onSurface),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        // Skip Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             IconButton(
                              iconSize: 48,
                              icon: Icon(Icons.skip_next, color: cs.onSurface),
                              onPressed: widget.currentIndex < 113 ? () => widget.onPlaySurah(widget.currentIndex + 1) : null,
                            ),
                            const SizedBox(width: 40),
                            IconButton(
                              iconSize: 48,
                              icon: Icon(Icons.skip_previous, color: cs.onSurface),
                              onPressed: widget.currentIndex > 0 ? () => widget.onPlaySurah(widget.currentIndex - 1) : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
