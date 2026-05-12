import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../app_navigator.dart';
import '../pages/story_narration_full_player_page.dart';
import '../pages/tilawat_full_player_page.dart';
import '../providers/tilawat_audio_controller.dart';

/// Bottom bar: left transport controls, right surah/reciter + mosque; progress below.
class TilawatMiniPlayerBar extends StatelessWidget {
  const TilawatMiniPlayerBar({super.key});

  static const double _controlIconSize = 24;
  static const double _controlTap = 44;
  static const double _mosqueSize = 26;

  /// Height of the bar **above** [MediaQuery.padding.bottom] (system inset is added
  /// separately by layouts). Keep in sync with the [Column] inside [build]
  /// (top padding + row + gap + progress row + inner bottom padding before safe area).
  static const double obstructionInsetAboveSafeBottom =
      10 + _controlTap + 10 + _miniProgressTrackHeight + 8;

  /// Slider row visual height (thumb + track + theme padding).
  static const double _miniProgressTrackHeight = 48;

  @override
  Widget build(BuildContext context) {
    final tilawat = context.watch<TilawatAudioController>();
    if (!tilawat.showMiniPlayer) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottom = MediaQuery.paddingOf(context).bottom;

    final bool story = tilawat.isStoryNarrationSession;
    final surah = tilawat.currentSurahMap;
    if (!story && surah == null) return const SizedBox.shrink();

    final idx = tilawat.currentSurahIndex ?? 0;
    final canPrev = story
        ? tilawat.storySkipHasPrevious
        : idx > 0;
    final canNext = story
        ? tilawat.storySkipHasNext
        : idx < tilawat.surahs.length - 1;

    final muted = cs.onSurface.withValues(alpha: 0.28);

    // Web: keep the shell bar out of reading-order focus traversal to avoid
    // "inactive element" crashes when the browser tab regains focus (Flutter 3.22+).
    Widget bar = Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      color: cs.surfaceContainerHighest.withValues(alpha: 0.97),
      child: InkWell(
        onTap: () {
          if (tilawat.isStoryNarrationSession) {
            appNavigatorKey.currentState
                ?.push(StoryNarrationFullPlayerPage.route());
          } else {
            appNavigatorKey.currentState?.push(TilawatFullPlayerPage.route());
          }
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 10, 14, 8 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Force physical row order: controls LEFT, info RIGHT (RTL app must not mirror this bar).
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniTransportIcon(
                          icon: Icons.skip_previous_rounded,
                          iconSize: _controlIconSize,
                          minSize: _controlTap,
                          color: canPrev ? cs.onSurface : muted,
                          onPressed:
                              canPrev ? () => tilawat.skipPrevious() : null,
                        ),
                        const SizedBox(width: 2),
                        _MiniTransportIcon(
                          icon: tilawat.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          iconSize: _controlIconSize,
                          minSize: _controlTap,
                          color: cs.primary,
                          emphasized: true,
                          colorScheme: cs,
                          onPressed: () => tilawat.togglePlayPause(),
                        ),
                        const SizedBox(width: 2),
                        _MiniTransportIcon(
                          icon: Icons.skip_next_rounded,
                          iconSize: _controlIconSize,
                          minSize: _controlTap,
                          color: canNext ? cs.onSurface : muted,
                          onPressed:
                              canNext ? () => tilawat.skipNext() : null,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  story
                                      ? (tilawat.activeStoryTitle ?? '')
                                      : (surah!['name']?.toString() ?? ''),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  textDirection: TextDirection.rtl,
                                  style: GoogleFonts.amiri(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  story
                                      ? (tilawat.activeStoryNarratorLabel ?? '')
                                      : tilawat.currentReciterLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  textDirection: TextDirection.rtl,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    height: 1.2,
                                    color: cs.onSurface.withValues(alpha: 0.62),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            story
                                ? Icons.auto_stories_rounded
                                : Icons.mosque_rounded,
                            size: _mosqueSize,
                            color: cs.primary.withValues(alpha: 0.72),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _MiniProgress(audioPlayer: tilawat.player, onSeek: tilawat.seek),
            ],
          ),
        ),
      ),
    );
    if (kIsWeb) {
      bar = ExcludeFocus(excluding: true, child: bar);
    }
    return bar;
  }
}

class _MiniTransportIcon extends StatelessWidget {
  const _MiniTransportIcon({
    required this.icon,
    required this.iconSize,
    required this.minSize,
    required this.color,
    required this.onPressed,
    this.emphasized = false,
    this.colorScheme,
  });

  final IconData icon;
  final double iconSize;
  final double minSize;
  final Color color;
  final VoidCallback? onPressed;
  final bool emphasized;
  final ColorScheme? colorScheme;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme ?? Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize, color: color),
      style: IconButton.styleFrom(
        minimumSize: Size(minSize, minSize),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        backgroundColor: emphasized
            ? cs.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        shape: const CircleBorder(),
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({
    required this.audioPlayer,
    required this.onSeek,
  });

  final AudioPlayer audioPlayer;
  final void Function(Duration) onSeek;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return StreamBuilder<Duration>(
      stream: audioPlayer.positionStream,
      builder: (context, posSnap) {
        final pos = posSnap.data ?? Duration.zero;
        return StreamBuilder<Duration?>(
          stream: audioPlayer.durationStream,
          builder: (context, durSnap) {
            final total = durSnap.data ?? Duration.zero;
            final maxMs = total.inMilliseconds > 0
                ? total.inMilliseconds.toDouble()
                : 1.0;
            final v = pos.inMilliseconds.toDouble().clamp(0.0, maxMs);
            return SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: v,
                max: maxMs,
                activeColor: cs.primary,
                inactiveColor: cs.outline.withValues(alpha: 0.32),
                onChanged: (x) => onSeek(Duration(milliseconds: x.round())),
              ),
            );
          },
        );
      },
    );
  }
}

/// Animates extra bottom [MediaQuery] padding so [SafeArea] / scroll views clear
/// the docked mini player without abrupt jumps.
class _MediaQueryBottomBoost extends ImplicitlyAnimatedWidget {
  const _MediaQueryBottomBoost({
    required this.boost,
    required this.child,
  })  : super(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );

  final double boost;
  final Widget child;

  @override
  ImplicitlyAnimatedWidgetState<_MediaQueryBottomBoost> createState() =>
      _MediaQueryBottomBoostState();
}

class _MediaQueryBottomBoostState
    extends AnimatedWidgetBaseState<_MediaQueryBottomBoost> {
  Tween<double>? _boostTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _boostTween = visitor(
      _boostTween,
      widget.boost,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final delta = _boostTween!.evaluate(animation);
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(
          bottom: mq.padding.bottom + delta,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Wraps [child] (usually [MaterialApp]) and pins the mini player above system UI.
class TilawatAppShell extends StatelessWidget {
  const TilawatAppShell({super.key, required this.child});

  final Widget child;

  static bool _isBarVisible(TilawatAudioController tilawat) =>
      tilawat.showMiniPlayer &&
      (tilawat.currentSurahMap != null || tilawat.isStoryNarrationSession);

  @override
  Widget build(BuildContext context) {
    return Consumer<TilawatAudioController>(
      builder: (context, tilawat, _) {
        final showBar = _isBarVisible(tilawat);
        final extraBottom = showBar
            ? TilawatMiniPlayerBar.obstructionInsetAboveSafeBottom
            : 0.0;
        final mq = MediaQuery.of(context);
        final systemBottom = mq.padding.bottom;
        final barTopFromStackBottom =
            TilawatMiniPlayerBar.obstructionInsetAboveSafeBottom +
                systemBottom;
        final theme = Theme.of(context);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            _MediaQueryBottomBoost(
              boost: extraBottom,
              child: child,
            ),
            if (showBar)
              Positioned(
                left: 0,
                right: 0,
                height: 32,
                bottom: barTopFromStackBottom,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.colorScheme.surface.withValues(alpha: 0.14),
                          theme.colorScheme.surface.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TilawatMiniPlayerBar(),
            ),
          ],
        );
      },
    );
  }
}
