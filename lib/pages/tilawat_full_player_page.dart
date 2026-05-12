import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../app_navigator.dart';
import '../providers/download_provider.dart';
import '../providers/tilawat_audio_controller.dart';
import '../ui/app_tokens.dart';
import '../widgets/media_full_player_chrome.dart';

/// Presets shown in the sleep timer sheet (minutes).
const List<int> _kTilawatSleepOptions = [10, 20, 30, 45, 60, 90, 120];

String _tilawatSleepOptionLabel(AppLocalizations l10n, int minutes) {
  switch (minutes) {
    case 60:
      return l10n.tilawatSleepOneHour;
    case 90:
      return l10n.tilawatSleepOneHourThirty;
    case 120:
      return l10n.tilawatSleepTwoHours;
    default:
      return l10n.tilawatSleepMinutes(minutes);
  }
}

class TilawatFullPlayerPage extends StatefulWidget {
  const TilawatFullPlayerPage({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: tilawatFullPlayerRouteName),
      pageBuilder: (context, a1, a2) => const TilawatFullPlayerPage(),
      transitionDuration: AppMotion.medium,
      reverseTransitionDuration: AppMotion.fast,
      transitionsBuilder: (context, animation, secondary, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  @override
  State<TilawatFullPlayerPage> createState() => _TilawatFullPlayerPageState();
}

class _TilawatFullPlayerPageState extends State<TilawatFullPlayerPage> {
  TilawatAudioController? _tilawat;
  bool _fullScreenRegistered = false;

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$m:$s';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tilawat ??= context.read<TilawatAudioController>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tilawat?.beginFullScreenSession();
      _fullScreenRegistered = true;
    });
  }

  @override
  void dispose() {
    if (_fullScreenRegistered) {
      _tilawat?.endFullScreenSession();
    }
    super.dispose();
  }

  void _openSleepSheet(AppLocalizations l10n, TilawatAudioController tilawat) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final viewInsets = MediaQuery.viewInsetsOf(ctx);
        final maxH = MediaQuery.sizeOf(ctx).height * 0.88;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.tilawatSleepChooseDuration,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  MediaSleepSheetTile(
                    icon: Icons.timer_off_outlined,
                    label: l10n.tilawatSleepOff,
                    colorScheme: cs,
                    onTap: () {
                      tilawat.clearSleepTimer();
                      Navigator.pop(ctx);
                    },
                  ),
                  for (final m in _kTilawatSleepOptions) ...[
                    const SizedBox(height: 6),
                    MediaSleepSheetTile(
                      icon: m <= 30
                          ? Icons.bedtime_outlined
                          : Icons.timer_outlined,
                      label: _tilawatSleepOptionLabel(l10n, m),
                      colorScheme: cs,
                      onTap: () {
                        tilawat.setSleepTimerMinutes(m);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                  SizedBox(
                    height: MediaQuery.viewPaddingOf(ctx).bottom.clamp(4, 20),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tilawat = context.watch<TilawatAudioController>();
    final surah = tilawat.currentSurahMap;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (surah == null) {
      return Scaffold(
        body: Center(child: Text(l10n.audioLoadError)),
      );
    }

    final surahNum = surah['number'] as int;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.expand_more_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const MediaAtmosphereBackground(),
            MediaBackgroundWatermark(
              title: surah['name']?.toString() ?? '',
              subtitle: tilawat.currentReciterLabel,
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Icon(Icons.mosque_rounded, size: 52, color: cs.primary),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      surah['name']?.toString() ?? '',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tilawat.currentReciterLabel,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 17,
                      color: cs.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const Spacer(),
                  _FullProgressBar(
                    player: tilawat.player,
                    onSeek: (d) {
                      tilawat.seek(d);
                      tilawat.persistProgressDebounced();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: StreamBuilder<Duration>(
                      stream: tilawat.player.positionStream,
                      builder: (context, snap) {
                        final pos = snap.data ?? Duration.zero;
                        return StreamBuilder<Duration?>(
                          stream: tilawat.player.durationStream,
                          builder: (context, dSnap) {
                            final t = dSnap.data ?? Duration.zero;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _fmt(pos),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.85),
                                  ),
                                ),
                                Text(
                                  _fmt(t),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: MediaMainTransportRow(
                        colorScheme: cs,
                        canSkipPrevious: tilawat.currentSurahIndex! > 0,
                        canSkipNext: tilawat.currentSurahIndex! <
                            tilawat.surahs.length - 1,
                        isPlaying: tilawat.isPlaying,
                        onPrevious: () => tilawat.skipPrevious(),
                        onPlayPause: () => tilawat.togglePlayPause(),
                        onNext: () => tilawat.skipNext(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _TilawatSecondaryActionsBar(
                      l10n: l10n,
                      tilawat: tilawat,
                      surah: surah,
                      surahNum: surahNum,
                      onOpenSleep: () => _openSleepSheet(l10n, tilawat),
                    ),
                  ),
                  if (tilawat.sleepTimerEndsAt != null) ...[
                    const SizedBox(height: 8),
                    _TilawatSleepActiveSummary(
                      l10n: l10n,
                      endsAt: tilawat.sleepTimerEndsAt!,
                      theme: theme,
                      colorScheme: cs,
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TilawatSleepActiveSummary extends StatefulWidget {
  const _TilawatSleepActiveSummary({
    required this.l10n,
    required this.endsAt,
    required this.theme,
    required this.colorScheme,
  });

  final AppLocalizations l10n;
  final DateTime endsAt;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  State<_TilawatSleepActiveSummary> createState() =>
      _TilawatSleepActiveSummaryState();
}

class _TilawatSleepActiveSummaryState extends State<_TilawatSleepActiveSummary> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 12), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.endsAt.difference(DateTime.now());
    if (left.inSeconds <= 0) {
      return const SizedBox.shrink();
    }
    final mins = left.inMinutes.ceil().clamp(1, 9999);
    final timeStr = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(widget.endsAt),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.l10n.tilawatSleepActiveRemaining(mins),
          style: widget.theme.textTheme.labelLarge?.copyWith(
            color: widget.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          widget.l10n.tilawatSleepEndsAt(timeStr),
          style: widget.theme.textTheme.labelSmall?.copyWith(
            color: widget.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TilawatSecondaryActionsBar extends StatelessWidget {
  const _TilawatSecondaryActionsBar({
    required this.l10n,
    required this.tilawat,
    required this.surah,
    required this.surahNum,
    required this.onOpenSleep,
  });

  final AppLocalizations l10n;
  final TilawatAudioController tilawat;
  final Map<String, dynamic> surah;
  final int surahNum;
  final VoidCallback onOpenSleep;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MediaSecondaryActionsShell(
      colorScheme: cs,
      children: [
        Tooltip(
          message: l10n.tilawatTooltipSleepTimer,
          child: MediaBarIconButton(
            selected: tilawat.sleepTimerEndsAt != null,
            icon: Icons.bedtime_outlined,
            selectedIcon: Icons.bedtime_rounded,
            onPressed: onOpenSleep,
            colorScheme: cs,
          ),
        ),
        Consumer<DownloadProvider>(
          builder: (context, dl, _) {
            final rec = tilawat.currentReciterLabel;
            final done = dl.isDownloaded(surahNum, rec);
            final loading = dl.isDownloading(surahNum, rec);
            final p = dl.downloadProgress(surahNum, rec);
            return Tooltip(
              message: done
                  ? l10n.tilawatDownloaded
                  : l10n.tilawatTooltipDownload,
              child: MediaBarIconButton(
                selected: done,
                icon: Icons.download_rounded,
                selectedIcon: Icons.offline_pin_rounded,
                onPressed: done || loading
                    ? null
                    : () async {
                        final ok = await dl.downloadSurah(
                          surahNumber: surahNum,
                          surah: surah,
                          reciter: rec,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? l10n.tilawatDownloadComplete
                                  : l10n.tilawatDownloadFailed,
                            ),
                          ),
                        );
                      },
                colorScheme: cs,
                isLoading: loading,
                loadingProgress: p,
              ),
            );
          },
        ),
        Tooltip(
          message: l10n.tilawatTooltipAutoNext,
          child: MediaBarIconButton(
            selected: tilawat.autoPlayNext,
            icon: Icons.playlist_play_rounded,
            selectedIcon: Icons.playlist_play_rounded,
            onPressed: () => tilawat.setAutoPlayNext(!tilawat.autoPlayNext),
            colorScheme: cs,
          ),
        ),
        Tooltip(
          message: l10n.tilawatTooltipRepeatOne,
          child: MediaBarIconButton(
            selected: tilawat.repeatCurrentSurah,
            icon: Icons.repeat_one_rounded,
            selectedIcon: Icons.repeat_one_rounded,
            onPressed: () => tilawat.setRepeatCurrentSurah(
              !tilawat.repeatCurrentSurah,
            ),
            colorScheme: cs,
          ),
        ),
      ],
    );
  }
}

class _FullProgressBar extends StatelessWidget {
  const _FullProgressBar({
    required this.player,
    required this.onSeek,
  });

  final AudioPlayer player;
  final void Function(Duration) onSeek;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      builder: (context, posSnap) {
        final pos = posSnap.data ?? Duration.zero;
        return StreamBuilder<Duration?>(
          stream: player.durationStream,
          builder: (context, durSnap) {
            final total = durSnap.data ?? Duration.zero;
            final maxMs =
                total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0;
            final v = pos.inMilliseconds.toDouble().clamp(0.0, maxMs);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                  value: v,
                  max: maxMs,
                  activeColor: cs.primary,
                  inactiveColor: cs.secondary.withValues(alpha: 0.35),
                  onChanged: (x) =>
                      onSeek(Duration(milliseconds: x.round())),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
