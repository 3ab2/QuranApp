import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:quran_app/widgets/back_button_widget.dart';

import 'qibla_fallback_view.dart';
import 'qibla_math.dart';

bool _supportsLiveCompass() =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

Widget buildPrayerQiblaPage(BuildContext context) {
  if (!_supportsLiveCompass()) {
    return const QiblaFallbackView();
  }
  return const _QiblaScaffold();
}

class _QiblaScaffold extends StatefulWidget {
  const _QiblaScaffold();

  @override
  State<_QiblaScaffold> createState() => _QiblaScaffoldState();
}

class _QiblaScaffoldState extends State<_QiblaScaffold> {
  bool _ready = false;
  String? _error;
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final status = await FlutterQiblah.checkLocationStatus();
      if (!status.enabled) {
        setState(() => _error = 'location_service');
        return;
      }
      if (status.status == LocationPermission.denied) {
        await FlutterQiblah.requestPermissions();
      }
      if (!mounted) return;
      final pos = await Geolocator.getLastKnownPosition();
      final fresh = pos ?? await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _distanceKm = qiblaHaversineKm(
          fresh.latitude,
          fresh.longitude,
          kKaabaLatitude,
          kKaabaLongitude,
        );
        _ready = true;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'generic');
      }
    }
  }

  @override
  void dispose() {
    FlutterQiblah().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (_error != null) {
      return QiblaFallbackView(
        statusBanner: _error == 'location_service'
            ? l10n.prayerQiblaLocationDisabled
            : l10n.prayerQiblaError,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const BackButtonWidget(),
                  Expanded(
                    child: Text(
                      l10n.prayerQiblaTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (!_ready)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: _QiblaCompassBody(distanceKm: _distanceKm),
              ),
          ],
        ),
      ),
    );
  }
}

class _QiblaCompassBody extends StatefulWidget {
  final double? distanceKm;

  const _QiblaCompassBody({this.distanceKm});

  @override
  State<_QiblaCompassBody> createState() => _QiblaCompassBodyState();
}

class _QiblaCompassBodyState extends State<_QiblaCompassBody> {
  DateTime _lastHaptic = DateTime.fromMillisecondsSinceEpoch(0);

  bool _isAligned(double qiblahDeg) {
    final x = qiblahDeg % 360;
    final n = x < 0 ? x + 360 : x;
    return n < 6 || n > 354;
  }

  void _maybeHaptic(bool aligned) {
    if (!aligned) return;
    final now = DateTime.now();
    if (now.difference(_lastHaptic) < const Duration(seconds: 2)) return;
    _lastHaptic = now;
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dist = widget.distanceKm;

    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return QiblaFallbackView(
            embedded: true,
            statusBanner: l10n.prayerQiblaError,
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final q = snapshot.data!;
        final aligned = _isAligned(q.qiblah);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _maybeHaptic(aligned);
        });

        final angle = -q.qiblah * math.pi / 180;

        return LayoutBuilder(
          builder: (context, c) {
            final size = math.min(c.maxWidth, c.maxHeight * 0.72);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  if (dist != null)
                    Text(
                      l10n.prayerQiblaDistanceKm(
                        dist < 10 ? dist.toStringAsFixed(1) : dist.round().toString(),
                      ),
                      style: GoogleFonts.amiri(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    aligned
                        ? l10n.prayerQiblaAlignedHint
                        : l10n.prayerQiblaRotateHint,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 15,
                      height: 1.45,
                      color: aligned
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size.square(size),
                              painter: _CompassRosePainter(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            Transform.rotate(
                              angle: angle,
                              child: Icon(
                                Icons.navigation_rounded,
                                size: size * 0.38,
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.92),
                              ),
                            ),
                            Positioned(
                              bottom: size * 0.08,
                              child: Text(
                                'N',
                                style: GoogleFonts.amiri(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  final Color color;

  _CompassRosePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 * 0.88;
    final tick = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    for (var i = 0; i < 36; i++) {
      final ang = i * math.pi / 18;
      final inner = i % 9 == 0 ? r - 14 : r - 8;
      final outer = r;
      canvas.drawLine(
        Offset(c.dx + inner * math.sin(ang), c.dy - inner * math.cos(ang)),
        Offset(c.dx + outer * math.sin(ang), c.dy - outer * math.cos(ang)),
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassRosePainter oldDelegate) =>
      oldDelegate.color != color;
}

