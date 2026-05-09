import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../app_navigator.dart';
import '../providers/download_provider.dart';
import '../providers/tilawat_audio_controller.dart';
import '../ui/app_tokens.dart';

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
                  _TilawatSleepSheetTile(
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
                    _TilawatSleepSheetTile(
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
            const _TilawatAtmosphereBackground(),
            _TilawatBackgroundWatermark(
              surahName: surah['name']?.toString() ?? '',
              reciter: tilawat.currentReciterLabel,
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
                      child: _MainTransportRow(
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

class _TilawatSleepSheetTile extends StatelessWidget {
  const _TilawatSleepSheetTile({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Icon(icon, size: 22, color: colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
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

/// Symmetrical transport: previous (screen left) | play/pause (dominant) | next (screen right).
class _MainTransportRow extends StatelessWidget {
  const _MainTransportRow({
    required this.colorScheme,
    required this.canSkipPrevious,
    required this.canSkipNext,
    required this.isPlaying,
    required this.onPrevious,
    required this.onPlayPause,
    required this.onNext,
  });

  final ColorScheme colorScheme;
  final bool canSkipPrevious;
  final bool canSkipNext;
  final bool isPlaying;
  final VoidCallback onPrevious;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final sideActive = colorScheme.onSurface.withValues(alpha: 0.9);
    final sideMuted = colorScheme.onSurface.withValues(alpha: 0.3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: IconButton(
              onPressed: canSkipPrevious ? onPrevious : null,
              iconSize: 48,
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              style: IconButton.styleFrom(
                foregroundColor:
                    canSkipPrevious ? sideActive : sideMuted,
              ),
              icon: const Icon(Icons.skip_previous_rounded),
            ),
          ),
        ),
        IconButton(
          onPressed: onPlayPause,
          iconSize: 84,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 92, minHeight: 92),
          icon: Icon(
            isPlaying
                ? Icons.pause_circle_filled_rounded
                : Icons.play_circle_filled_rounded,
            color: colorScheme.primary,
          ),
        ),
        Expanded(
          child: Center(
            child: IconButton(
              onPressed: canSkipNext ? onNext : null,
              iconSize: 48,
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              style: IconButton.styleFrom(
                foregroundColor: canSkipNext ? sideActive : sideMuted,
              ),
              icon: const Icon(Icons.skip_next_rounded),
            ),
          ),
        ),
      ],
    );
  }
}

/// Large soft watermark behind controls (does not receive pointer events).
class _TilawatBackgroundWatermark extends StatelessWidget {
  const _TilawatBackgroundWatermark({
    required this.surahName,
    required this.reciter,
  });

  final String surahName;
  final String reciter;

  @override
  Widget build(BuildContext context) {
    if (surahName.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final blend = Color.lerp(cs.primary, cs.secondary, 0.4)!;

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          return Align(
            alignment: const Alignment(0, -0.05),
            child: ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
                child: Opacity(
                  opacity: 0.95,
                  child: Transform.rotate(
                    angle: -0.045,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: w * 0.9,
                          child: Text(
                            surahName,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.amiri(
                              fontSize: 88,
                              fontWeight: FontWeight.w600,
                              height: 1.02,
                              color: blend.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        if (reciter.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            reciter,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.amiri(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: cs.secondary.withValues(alpha: 0.08),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: cs.surface.withValues(alpha: 0.42),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Tooltip(
              message: l10n.tilawatTooltipSleepTimer,
              child: _BarIconButton(
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
                  child: _BarIconButton(
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
              child: _BarIconButton(
                selected: tilawat.autoPlayNext,
                icon: Icons.playlist_play_rounded,
                selectedIcon: Icons.playlist_play_rounded,
                onPressed: () =>
                    tilawat.setAutoPlayNext(!tilawat.autoPlayNext),
                colorScheme: cs,
              ),
            ),
            Tooltip(
              message: l10n.tilawatTooltipRepeatOne,
              child: _BarIconButton(
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
        ),
      ),
    );
  }
}

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onPressed,
    required this.colorScheme,
    this.isLoading = false,
    this.loadingProgress,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;
  final bool isLoading;
  final double? loadingProgress;

  @override
  Widget build(BuildContext context) {
    final loading = isLoading;
    final active = selected || loading;
    final fg = active ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.55);
    final bg = selected && !loading
        ? colorScheme.primary.withValues(alpha: 0.14)
        : Colors.transparent;

    Widget child = Icon(
      selected ? selectedIcon : icon,
      size: 22,
      color: loading
          ? colorScheme.onSurface.withValues(alpha: 0.35)
          : fg,
    );

    if (loading) {
      child = SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                value: loadingProgress != null && loadingProgress! > 0 && loadingProgress! < 1
                    ? loadingProgress
                    : null,
                color: colorScheme.primary,
              ),
            ),
            Icon(icon, size: 14, color: colorScheme.primary.withValues(alpha: 0.9)),
          ],
        ),
      );
    }

    return Material(
      color: bg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: child),
        ),
      ),
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

class _TilawatAtmosphereBackground extends StatefulWidget {
  const _TilawatAtmosphereBackground();

  @override
  State<_TilawatAtmosphereBackground> createState() =>
      _TilawatAtmosphereBackgroundState();
}

class _TilawatAtmosphereBackgroundState
    extends State<_TilawatAtmosphereBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0B5D3B),
                  const Color(0xFF1A7A52),
                  t,
                )!,
                Color.lerp(
                  const Color(0xFFC9A227),
                  const Color(0xFFE8D089),
                  1 - t,
                )!,
                theme.colorScheme.surface,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: theme.colorScheme.surface.withValues(alpha: 0.25),
            ),
          ),
        );
      },
    );
  }
}
