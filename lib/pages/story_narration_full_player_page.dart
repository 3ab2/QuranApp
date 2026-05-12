import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_navigator.dart';
import '../providers/tilawat_audio_controller.dart';
import '../ui/app_tokens.dart';
import '../widgets/media_full_player_chrome.dart';
import '../widgets/playback_speed_sheet.dart';

/// Presets aligned with [TilawatFullPlayerPage] sleep sheet.
const List<int> _kStoryNarrationSleepOptions = [10, 20, 30, 45, 60, 90, 120];

String _storySleepOptionLabel(AppLocalizations l10n, int minutes) {
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

/// Full-screen archive story narration — same chrome as [TilawatFullPlayerPage].
class StoryNarrationFullPlayerPage extends StatefulWidget {
  const StoryNarrationFullPlayerPage({super.key});

  static Route<void> route() {
    return PageRouteBuilder<void>(
      settings: const RouteSettings(name: storyNarrationFullPlayerRouteName),
      pageBuilder: (context, a1, a2) => const StoryNarrationFullPlayerPage(),
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
  State<StoryNarrationFullPlayerPage> createState() =>
      _StoryNarrationFullPlayerPageState();
}

class _StoryNarrationFullPlayerPageState extends State<StoryNarrationFullPlayerPage> {
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
                  for (final m in _kStoryNarrationSleepOptions) ...[
                    const SizedBox(height: 6),
                    MediaSleepSheetTile(
                      icon: m <= 30
                          ? Icons.bedtime_outlined
                          : Icons.timer_outlined,
                      label: _storySleepOptionLabel(l10n, m),
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

  Future<void> _openPlaybackSpeedSheet(
    AppLocalizations l10n,
    TilawatAudioController tilawat,
  ) async {
    const speeds = <double>[0.75, 1.0, 1.25, 1.5, 2.0];
    final next = await showPlaybackSpeedSheet(
      context,
      speeds: speeds,
      current: tilawat.player.speed,
      title: l10n.playbackSpeedSheetTitle,
    );
    if (next == null || !mounted) return;
    final prefs = await SharedPreferences.getInstance();
    await tilawat.player.setSpeed(next);
    await prefs.setDouble('stories.audio.speed', next);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tilawat = context.watch<TilawatAudioController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (!tilawat.isStoryNarrationSession || tilawat.activeStoryId == null) {
      return Scaffold(
        body: Center(child: Text(l10n.storyNoAudio)),
      );
    }

    final title = tilawat.activeStoryTitle ?? '';
    final narrator = (tilawat.activeStoryNarratorLabel ?? '').trim();

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
              title: title,
              subtitle: narrator,
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Icon(Icons.auto_stories_rounded, size: 52, color: cs.primary),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      title,
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
                  if (narrator.isNotEmpty)
                    Text(
                      narrator,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        color: cs.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                  const Spacer(),
                  _StoryNarrationFullProgressBar(
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
                        canSkipPrevious: tilawat.storySkipHasPrevious,
                        canSkipNext: tilawat.storySkipHasNext,
                        isPlaying: tilawat.isPlaying,
                        onPrevious: () => unawaited(tilawat.skipPrevious()),
                        onPlayPause: () => unawaited(tilawat.togglePlayPause()),
                        onNext: () => unawaited(tilawat.skipNext()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MediaSecondaryActionsShell(
                      colorScheme: cs,
                      children: [
                        Tooltip(
                          message: l10n.tilawatTooltipSleepTimer,
                          child: MediaBarIconButton(
                            selected: tilawat.sleepTimerEndsAt != null,
                            icon: Icons.bedtime_outlined,
                            selectedIcon: Icons.bedtime_rounded,
                            onPressed: () => _openSleepSheet(l10n, tilawat),
                            colorScheme: cs,
                          ),
                        ),
                        Tooltip(
                          message: '${tilawat.player.speed.toStringAsFixed(2)}x',
                          child: MediaBarIconButton(
                            selected: (tilawat.player.speed - 1.0).abs() > 0.01,
                            icon: Icons.speed_rounded,
                            selectedIcon: Icons.speed_rounded,
                            onPressed: () => unawaited(
                              _openPlaybackSpeedSheet(l10n, tilawat),
                            ),
                            colorScheme: cs,
                          ),
                        ),
                        const SizedBox(width: 44),
                        const SizedBox(width: 44),
                      ],
                    ),
                  ),
                  if (tilawat.sleepTimerEndsAt != null) ...[
                    const SizedBox(height: 8),
                    _StoryNarrationSleepActiveSummary(
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

class _StoryNarrationSleepActiveSummary extends StatefulWidget {
  const _StoryNarrationSleepActiveSummary({
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
  State<_StoryNarrationSleepActiveSummary> createState() =>
      _StoryNarrationSleepActiveSummaryState();
}

class _StoryNarrationSleepActiveSummaryState
    extends State<_StoryNarrationSleepActiveSummary> {
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

class _StoryNarrationFullProgressBar extends StatelessWidget {
  const _StoryNarrationFullProgressBar({
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
