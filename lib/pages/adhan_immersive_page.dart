import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:quran_app/pages/prayer_qibla_page.dart';
import 'package:quran_app/services/prayer_service.dart';

/// Calm full-screen surface while Adhan plays (subtle motion only).
class AdhanImmersivePage extends StatefulWidget {
  final String prayerNameAr;
  final String prayerNameEn;
  final AudioPlayer player;
  final PrayerService prayerService;

  const AdhanImmersivePage({
    super.key,
    required this.prayerNameAr,
    required this.prayerNameEn,
    required this.player,
    required this.prayerService,
  });

  @override
  State<AdhanImmersivePage> createState() => _AdhanImmersivePageState();
}

class _AdhanImmersivePageState extends State<AdhanImmersivePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  Timer? _clockTimer;
  bool _muted = false;
  double _savedVolume = 0.85;

  @override
  void initState() {
    super.initState();
    _savedVolume = widget.prayerService.settings?.volume ?? 0.85;
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  Future<void> _stopAndPop() async {
    try {
      await widget.player.stop();
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _snooze() async {
    try {
      await widget.player.stop();
    } catch (_) {}
    await widget.prayerService.scheduleAdhanSnoozeReminder(
      prayerLabel: '${widget.prayerNameAr} / ${widget.prayerNameEn}',
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _toggleMute() {
    setState(() {
      _muted = !_muted;
      if (_muted) {
        widget.player.setVolume(0);
      } else {
        widget.player.setVolume(_savedVolume);
      }
    });
  }

  void _openQibla() {
    final nav = Navigator.of(context);
    nav.pop();
    nav.push<void>(
      MaterialPageRoute<void>(builder: (_) => const PrayerQiblaPage()),
    );
  }

  String _clockLine() {
    final n = DateTime.now();
    final h = n.hour.toString().padLeft(2, '0');
    final m = n.minute.toString().padLeft(2, '0');
    final s = n.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _breath,
          builder: (context, _) {
            final t = CurvedAnimation(
              parent: _breath,
              curve: Curves.easeInOutSine,
            ).value;
            final wash = Color.lerp(
              theme.colorScheme.primary.withValues(alpha: 0.22),
              theme.colorScheme.tertiary.withValues(alpha: 0.18),
              t,
            )!;
            return Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.scaffoldBackgroundColor,
                        wash,
                        theme.scaffoldBackgroundColor,
                      ],
                      stops: const [0.0, 0.52, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            onPressed: _stopAndPop,
                            icon: const Icon(Icons.close),
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.prayerNameAr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 36,
                            height: 1.1,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.prayerNameEn,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 17,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.72),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _clockLine(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            letterSpacing: 2,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.85),
                          ),
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              color: theme.colorScheme.surface
                                  .withValues(alpha: 0.35),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _ChromeButton(
                                    icon: Icons.stop_circle_outlined,
                                    label: l10n.prayerAdhanStop,
                                    onTap: _stopAndPop,
                                  ),
                                  _ChromeButton(
                                    icon: Icons.snooze,
                                    label: l10n.prayerAdhanSnooze,
                                    onTap: _snooze,
                                  ),
                                  _ChromeButton(
                                    icon: _muted
                                        ? Icons.volume_off
                                        : Icons.volume_up_outlined,
                                    label: _muted
                                        ? l10n.prayerAdhanUnmute
                                        : l10n.prayerAdhanMute,
                                    onTap: _toggleMute,
                                  ),
                                  _ChromeButton(
                                    icon: Icons.explore_outlined,
                                    label: l10n.prayerOpenQibla,
                                    onTap: _openQibla,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.prayerImmersiveHint,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            fontSize: 12,
                            height: 1.4,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ChromeButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.amiri(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
