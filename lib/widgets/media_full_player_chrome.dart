import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ui/app_tokens.dart';

/// Soft animated Islamic-style gradient backdrop (shared by Tilawat + Stories players).
class MediaAtmosphereBackground extends StatefulWidget {
  const MediaAtmosphereBackground({super.key});

  @override
  State<MediaAtmosphereBackground> createState() =>
      _MediaAtmosphereBackgroundState();
}

class _MediaAtmosphereBackgroundState extends State<MediaAtmosphereBackground>
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

/// Large soft watermark (RTL title + subtitle); ignores pointers.
class MediaBackgroundWatermark extends StatelessWidget {
  const MediaBackgroundWatermark({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (title.isEmpty) return const SizedBox.shrink();
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
                            title,
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
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
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

/// Previous (left) | play/pause (center) | next (right) — matches Tilawat full player.
class MediaMainTransportRow extends StatelessWidget {
  const MediaMainTransportRow({
    super.key,
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
                foregroundColor: canSkipPrevious ? sideActive : sideMuted,
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

/// Rounded “pill” bar matching Tilawat secondary actions container.
class MediaSecondaryActionsShell extends StatelessWidget {
  const MediaSecondaryActionsShell({
    super.key,
    required this.colorScheme,
    required this.children,
  });

  final ColorScheme colorScheme;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: colorScheme.surface.withValues(alpha: 0.42),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: children,
        ),
      ),
    );
  }
}

/// Circular icon control (Tilawat full player secondary bar).
class MediaBarIconButton extends StatelessWidget {
  const MediaBarIconButton({
    super.key,
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
    final fg = active
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.55);
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
                value: loadingProgress != null &&
                        loadingProgress! > 0 &&
                        loadingProgress! < 1
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

/// Sleep sheet list tile (Tilawat visual style).
class MediaSleepSheetTile extends StatelessWidget {
  const MediaSleepSheetTile({
    super.key,
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
      borderRadius: AppRadius.card,
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
