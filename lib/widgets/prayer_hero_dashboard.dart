import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:quran_app/prayer/prayer_atmosphere.dart';
import 'package:quran_app/prayer/prayer_timeline.dart';
import 'package:quran_app/ui/app_tokens.dart';
import 'package:quran_app/widgets/common_ui.dart';

String formatPrayerCountdownHms(Duration d) {
  final t = d.isNegative ? Duration.zero : d;
  final h = t.inHours;
  final m = t.inMinutes.remainder(60);
  final s = t.inSeconds.remainder(60);
  return '${h.toString().padLeft(2, '0')}:'
      '${m.toString().padLeft(2, '0')}:'
      '${s.toString().padLeft(2, '0')}';
}

/// Compact next-prayer summary (fits ~120–140dp height) aligned with [AppCard].
class PrayerHeroCompact extends StatelessWidget {
  final PrayerDashboardSnapshot snapshot;
  final String locationLine;
  final VoidCallback onOpenQibla;

  const PrayerHeroCompact({
    super.key,
    required this.snapshot,
    required this.locationLine,
    required this.onOpenQibla,
  });

  String _phaseLabel(AppLocalizations l10n) {
    switch (snapshot.phase) {
      case PrayerUrgencyPhase.calm:
        return l10n.prayerPhaseCalm;
      case PrayerUrgencyPhase.approaching:
        return l10n.prayerPhaseApproaching;
      case PrayerUrgencyPhase.atAdhan:
        return l10n.prayerPhaseAtAdhan;
      case PrayerUrgencyPhase.grace:
        return l10n.prayerPhaseGrace;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final atm =
        PrayerAtmosphere.fromSnapshot(snapshot, theme.brightness);
    final showCountdown = snapshot.nextPrayerAt.isAfter(DateTime.now()) &&
        snapshot.phase != PrayerUrgencyPhase.atAdhan;

    return AppCard(
      margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _phaseLabel(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.amiri(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      snapshot.nextPrayer.nameAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        height: 1.1,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      snapshot.nextPrayer.nameEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.amiri(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showCountdown)
                    Text(
                      formatPrayerCountdownHms(snapshot.remaining),
                      style: GoogleFonts.robotoMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.mosque_outlined,
                        size: 28,
                        color: theme.colorScheme.primary.withValues(alpha: 0.85),
                      ),
                    ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    tooltip: l10n.prayerOpenQibla,
                    onPressed: onOpenQibla,
                    icon: Icon(
                      Icons.explore_outlined,
                      size: 22,
                      color: atm.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            locationLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.amiri(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            l10n.prayerCurrentPeriod(snapshot.currentPeriod.nameAr),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.amiri(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}
