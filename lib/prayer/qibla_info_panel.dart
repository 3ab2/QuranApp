import 'package:flutter/material.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import 'qibla_math.dart';

class QiblaInfoPanel extends StatelessWidget {
  final double? bearingDegrees;
  final double? distanceKm;
  final String locationLabel;
  final bool locationKnown;

  const QiblaInfoPanel({
    super.key,
    required this.bearingDegrees,
    required this.distanceKm,
    required this.locationLabel,
    required this.locationKnown,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.prayerQiblaFallbackInfoTitle,
            style: AppTypography.sectionTitle(cs),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.explore_outlined,
                  label: l10n.prayerQiblaFallbackAngleLabel,
                  value: bearingDegrees == null
                      ? '—'
                      : formatQiblaBearing(bearingDegrees!),
                  highlight: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoTile(
                  icon: Icons.place_outlined,
                  label: l10n.prayerQiblaFallbackLocationTitle,
                  value: locationLabel,
                  highlight: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.social_distance_outlined,
                  label: l10n.prayerQiblaFallbackDistanceLabel,
                  value: distanceKm == null
                      ? '—'
                      : l10n.prayerQiblaDistanceKm(
                          distanceKm! < 10
                              ? distanceKm!.toStringAsFixed(1)
                              : distanceKm!.round().toString(),
                        ),
                  highlight: false,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _InfoTile(
                  icon: Icons.touch_app_outlined,
                  label: l10n.prayerQiblaFallbackHeadingLabel,
                  value: l10n.prayerQiblaFallbackHeadingValue,
                  highlight: false,
                ),
              ),
            ],
          ),
          if (!locationKnown) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.prayerQiblaFallbackLocationHint,
              textAlign: TextAlign.center,
              style: AppTypography.caption(cs, opacity: 0.72),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: AppMotion.medium,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: highlight
            ? cs.primaryContainer.withValues(alpha: 0.38)
            : cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: highlight
              ? cs.primary.withValues(alpha: 0.22)
              : cs.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: AppIconSizes.sm,
            color: highlight
                ? cs.primary.withValues(alpha: 0.9)
                : cs.onSurface.withValues(alpha: 0.55),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: AppTypography.caption(cs, opacity: 0.65)),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: AppMotion.medium,
            switchInCurve: Curves.easeOutCubic,
            child: Text(
              value,
              key: ValueKey(value),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: highlight
                  ? AppTypography.listTitle(cs).copyWith(
                      fontSize: 15,
                      color: cs.primary,
                    )
                  : AppTypography.body(cs, opacity: 0.88).copyWith(
                      fontSize: 14,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Staggered fade+slide entrance for fallback cards.
class QiblaFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;

  const QiblaFadeSlide({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.slow + Duration(milliseconds: index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
