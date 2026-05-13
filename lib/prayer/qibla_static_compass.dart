import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ui/app_tokens.dart';

/// Ambient, interactive Qibla compass for web/desktop fallback (no fake sensors).
class QiblaStaticCompass extends StatefulWidget {
  final double? bearingDegrees;
  final String? caption;
  final String? dragHint;
  final bool interactive;

  const QiblaStaticCompass({
    super.key,
    required this.bearingDegrees,
    this.caption,
    this.dragHint,
    this.interactive = true,
  });

  @override
  State<QiblaStaticCompass> createState() => _QiblaStaticCompassState();
}

class _QiblaStaticCompassState extends State<QiblaStaticCompass>
    with TickerProviderStateMixin {
  late final AnimationController _ambient;
  late final AnimationController _spring;
  final ValueNotifier<double> _dragRad = ValueNotifier(0);
  double _springFrom = 0;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
    _spring = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    )..addListener(_onSpring);
  }

  void _onSpring() {
    final t = Curves.easeOutCubic.transform(_spring.value);
    _dragRad.value = _springFrom * (1 - t);
  }

  @override
  void dispose() {
    _ambient.dispose();
    _spring.dispose();
    _dragRad.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d, double size) {
    if (!widget.interactive) return;
    _spring.stop();
    _dragRad.value += d.delta.dx / size * 1.35;
  }

  void _onPanEnd() {
    if (!widget.interactive || _dragRad.value.abs() < 0.001) return;
    _springFrom = _dragRad.value;
    _spring.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bearing = widget.bearingDegrees;

    return LayoutBuilder(
      builder: (context, c) {
        final size = math.min(c.maxWidth, 280.0);

        return AnimatedBuilder(
          animation: Listenable.merge([_ambient, _dragRad]),
          builder: (context, child) {
            final breath = 1 + math.sin(_ambient.value * math.pi) * 0.018;
            final wobble = math.sin(_ambient.value * math.pi * 2) * 0.012;
            final glow = 0.28 + math.sin(_ambient.value * math.pi) * 0.14;
            final bearingRad =
                bearing == null ? 0.0 : bearing * math.pi / 180;
            final dialRotation = (bearing == null ? 0.0 : -bearingRad) +
                _dragRad.value +
                wobble;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.caption != null && widget.caption!.isNotEmpty) ...[
                  Text(
                    widget.caption!,
                    textAlign: TextAlign.center,
                    style: AppTypography.body(cs, opacity: 0.78),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                GestureDetector(
                  onPanUpdate: widget.interactive
                      ? (d) => _onPanUpdate(d, size)
                      : null,
                  onPanEnd: widget.interactive ? (_) => _onPanEnd() : null,
                  child: Transform.scale(
                    scale: breath,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft outer glow toward Qibla (fixed upward when aligned)
                          if (bearing != null)
                            CustomPaint(
                              size: Size.square(size),
                              painter: _QiblaGlowPainter(
                                color: cs.primary.withValues(alpha: glow),
                              ),
                            ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: cs.outline.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary
                                      .withValues(alpha: glow * 0.35),
                                  blurRadius: 28,
                                  spreadRadius: 1,
                                ),
                                ...AppShadows.cardElevated(context),
                              ],
                              gradient: RadialGradient(
                                colors: [
                                  cs.surfaceContainerHighest
                                      .withValues(alpha: 0.62),
                                  cs.primaryContainer
                                      .withValues(alpha: 0.18),
                                  cs.surfaceContainerHighest
                                      .withValues(alpha: 0.12),
                                ],
                                stops: const [0.35, 0.72, 1.0],
                              ),
                            ),
                            child: ClipOval(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: dialRotation,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CustomPaint(
                                          size: Size.square(size),
                                          painter: _CompassRosePainter(
                                            tickColor: cs.onSurface
                                                .withValues(alpha: 0.22),
                                            qiblaColor: cs.primary
                                                .withValues(alpha: 0.55),
                                            qiblaBearingRad: bearingRad,
                                          ),
                                        ),
                                        if (bearing != null)
                                          Transform.rotate(
                                            angle: bearingRad,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  top: size * 0.11,
                                                ),
                                                child: _KaabaMarker(
                                                  size: size * 0.13,
                                                  color: cs.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Fixed needle — points to Qibla when dial is aligned
                          if (bearing != null)
                            Icon(
                              Icons.navigation_rounded,
                              size: size * 0.34,
                              color: cs.primary.withValues(alpha: 0.94),
                            )
                          else
                            Icon(
                              Icons.explore_outlined,
                              size: size * 0.3,
                              color: cs.onSurface.withValues(alpha: 0.35),
                            ),
                          Positioned(
                            bottom: size * 0.09,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: cs.surface.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  'N',
                                  style: GoogleFonts.amiri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (widget.interactive &&
                    widget.dragHint != null &&
                    bearing != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    widget.dragHint!,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption(cs, opacity: 0.62),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _KaabaMarker extends StatelessWidget {
  final double size;
  final Color color;

  const _KaabaMarker({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.65), width: 1.2),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          Icons.mosque_rounded,
          size: size * 0.62,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _QiblaGlowPainter extends CustomPainter {
  final Color color;

  _QiblaGlowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.55),
        radius: 0.55,
        colors: [color, color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r * 0.92, paint);
  }

  @override
  bool shouldRepaint(covariant _QiblaGlowPainter old) => old.color != color;
}

class _CompassRosePainter extends CustomPainter {
  final Color tickColor;
  final Color qiblaColor;
  final double qiblaBearingRad;

  _CompassRosePainter({
    required this.tickColor,
    required this.qiblaColor,
    required this.qiblaBearingRad,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 * 0.88;

    if (qiblaBearingRad != 0) {
      final arcPaint = Paint()
        ..color = qiblaColor.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      final start = -math.pi / 2 + qiblaBearingRad - 0.14;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r - 6),
        start,
        0.28,
        false,
        arcPaint,
      );
    }

    final tick = Paint()
      ..color = tickColor
      ..strokeWidth = 1.2;
    for (var i = 0; i < 36; i++) {
      final ang = i * math.pi / 18;
      final major = i % 9 == 0;
      final inner = major ? r - 14 : r - 8;
      canvas.drawLine(
        Offset(c.dx + inner * math.sin(ang), c.dy - inner * math.cos(ang)),
        Offset(c.dx + r * math.sin(ang), c.dy - r * math.cos(ang)),
        tick..strokeWidth = major ? 1.6 : 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassRosePainter old) =>
      old.tickColor != tickColor ||
      old.qiblaColor != qiblaColor ||
      old.qiblaBearingRad != qiblaBearingRad;
}
