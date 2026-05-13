import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_model.dart';
import '../services/prayer_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';
import 'qibla_info_panel.dart';
import 'qibla_math.dart';
import 'qibla_static_compass.dart';

/// Polished Qibla experience when live compass sensors are unavailable.
class QiblaFallbackView extends StatefulWidget {
  final String? statusBanner;

  /// When true, renders only scrollable cards (for embedding inside live compass shell).
  final bool embedded;

  const QiblaFallbackView({
    super.key,
    this.statusBanner,
    this.embedded = false,
  });

  @override
  State<QiblaFallbackView> createState() => _QiblaFallbackViewState();
}

class _QiblaFallbackViewState extends State<QiblaFallbackView> {
  Location? _location;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final fromService = PrayerService().location;
    if (_isValidLocation(fromService)) {
      if (mounted) {
        setState(() {
          _location = fromService;
          _loading = false;
        });
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_location');
      if (raw != null) {
        final map = json.decode(raw) as Map<String, dynamic>;
        final loc = Location(
          city: map['city']?.toString() ?? '',
          country: map['country']?.toString() ?? '',
          latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
          timezoneId: map['timezone_id']?.toString(),
        );
        if (_isValidLocation(loc) && mounted) {
          setState(() {
            _location = loc;
            _loading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  bool _isValidLocation(Location? loc) {
    if (loc == null) return false;
    if (loc.latitude == 0 && loc.longitude == 0) return false;
    return true;
  }

  String _locationLabel(Location loc, AppLocalizations l10n) {
    final city = loc.city.trim();
    final country = loc.country.trim();
    if (city.isNotEmpty &&
        country.isNotEmpty &&
        city.toLowerCase() != 'unknown' &&
        country.toLowerCase() != 'unknown') {
      return '$city, $country';
    }
    if (city.isNotEmpty && city.toLowerCase() != 'unknown') return city;
    return l10n.prayerQiblaFallbackLocationUnknown;
  }

  Widget _statusBanner(BuildContext context) {
    if (widget.statusBanner == null) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        widget.embedded ? AppSpacing.sm : 0,
        AppSpacing.pageH,
        AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.tertiaryContainer.withValues(alpha: 0.45),
          borderRadius: AppRadius.card,
          border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            widget.statusBanner!,
            textAlign: TextAlign.center,
            style: AppTypography.body(cs, opacity: 0.88),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final loc = _location;
    final bearing =
        loc == null ? null : qiblaBearingDegrees(loc.latitude, loc.longitude);
    final distanceKm = loc == null
        ? null
        : qiblaHaversineKm(
            loc.latitude,
            loc.longitude,
            kKaabaLatitude,
            kKaabaLongitude,
          );

    if (_loading) {
      return AppLoadingView(label: l10n.prayerQiblaTitle);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageH,
        AppSpacing.sm,
        AppSpacing.pageH,
        AppSpacing.listBottom,
      ),
      children: [
        QiblaFadeSlide(
          index: 0,
          child: AppCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: QiblaStaticCompass(
              bearingDegrees: bearing,
              interactive: !widget.embedded,
              caption: bearing == null
                  ? null
                  : l10n.prayerQiblaFallbackStaticHint,
              dragHint: l10n.prayerQiblaFallbackDragHint,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        QiblaFadeSlide(
          index: 1,
          child: QiblaInfoPanel(
            bearingDegrees: bearing,
            distanceKm: distanceKm,
            locationKnown: loc != null,
            locationLabel: loc == null
                ? l10n.prayerQiblaFallbackLocationUnknown
                : _locationLabel(loc, l10n),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        QiblaFadeSlide(
          index: 2,
          child: AppCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.mosque_rounded,
                      size: AppIconSizes.lg,
                      color: cs.primary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.prayerQiblaFallbackKaabaTitle,
                        style: AppTypography.sectionTitle(cs),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.prayerQiblaFallbackExplanation,
                  style: AppTypography.body(cs, opacity: 0.9),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.prayerQiblaFallbackBrowserNote,
                  style: AppTypography.caption(cs, opacity: 0.7),
                ),
              ],
            ),
          ),
        ),
        if (!widget.embedded) ...[
          const SizedBox(height: AppSpacing.md),
          QiblaFadeSlide(
            index: 3,
            child: AppCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.phone_android_rounded,
                        color: cs.primary,
                        size: AppIconSizes.lg,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.prayerQiblaFallbackMobileTitle,
                          style: AppTypography.listTitle(cs),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.prayerQiblaFallbackMobileBody,
                          style: AppTypography.body(cs, opacity: 0.82),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statusBanner(context),
          Expanded(child: _content(context)),
        ],
      );
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBar(),
              AppPageHeader(
                title: l10n.prayerQiblaTitle,
                subtitle: l10n.prayerQiblaFallbackSubtitle,
              ),
              const SizedBox(height: AppSpacing.afterHeader),
              _statusBanner(context),
              Expanded(child: _content(context)),
            ],
          ),
        ),
      ),
    );
  }
}
