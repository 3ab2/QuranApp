import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:quran_app/models/prayer_model.dart';
import 'package:quran_app/prayer/arab_regions_repository.dart';
import 'package:quran_app/services/prayer_service.dart';
import 'package:quran_app/ui/app_tokens.dart';
import 'package:quran_app/widgets/common_ui.dart';

/// Premium country → city picker with search (Arabic-friendly).
Future<void> showPrayerLocationPickerSheet({
  required BuildContext context,
  required AdhanSettings currentSettings,
  required Future<void> Function(AdhanSettings updated) onApply,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final locale = Localizations.localeOf(context).languageCode;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final h = MediaQuery.sizeOf(ctx).height * 0.88;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SizedBox(
          height: h.clamp(360, 720),
          child: _PrayerLocationPickerBody(
            locale: locale,
            l10n: l10n,
            currentSettings: currentSettings,
            onApply: onApply,
          ),
        ),
      );
    },
  );
}

class _PrayerLocationPickerBody extends StatefulWidget {
  final String locale;
  final AppLocalizations l10n;
  final AdhanSettings currentSettings;
  final Future<void> Function(AdhanSettings updated) onApply;

  const _PrayerLocationPickerBody({
    required this.locale,
    required this.l10n,
    required this.currentSettings,
    required this.onApply,
  });

  @override
  State<_PrayerLocationPickerBody> createState() =>
      _PrayerLocationPickerBodyState();
}

class _PrayerLocationPickerBodyState extends State<_PrayerLocationPickerBody> {
  final _countryQuery = TextEditingController();
  final _cityQuery = TextEditingController();
  List<ArabCountryRow> _all = [];
  ArabCountryRow? _selectedCountry;
  bool _loading = true;
  bool _auto = true;

  @override
  void initState() {
    super.initState();
    _auto = widget.currentSettings.autoLocation;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final rows = await ArabRegionsRepository.instance.loadCountries();
    if (!mounted) return;
    setState(() {
      _all = rows;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _countryQuery.dispose();
    _cityQuery.dispose();
    super.dispose();
  }

  List<ArabCountryRow> get _filteredCountries {
    final q = _countryQuery.text.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((c) {
      return c.nameAr.toLowerCase().contains(q) ||
          c.nameEn.toLowerCase().contains(q) ||
          c.nameFr.toLowerCase().contains(q) ||
          c.id.toLowerCase().contains(q);
    }).toList();
  }

  List<ArabCityRow> get _filteredCities {
    final c = _selectedCountry;
    if (c == null) return const [];
    final q = _cityQuery.text.trim().toLowerCase();
    if (q.isEmpty) return c.cities;
    return c.cities.where((city) {
      return city.nameAr.toLowerCase().contains(q) ||
          city.nameEn.toLowerCase().contains(q) ||
          city.nameFr.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _useAutoGps() async {
    final nav = Navigator.of(context);
    final svc = PrayerService();
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final ok = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.prayerLocationGpsDenied)),
        );
      }
      return;
    }
    final loc = await svc.getCurrentLocation();
    if (loc == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.l10n.prayerLocationGpsFailed)),
        );
      }
      return;
    }
    final next = widget.currentSettings.copyWith(
      autoLocation: true,
      clearManualPrayerLocation: true,
    );
    await widget.onApply(next);
    if (mounted) nav.pop();
  }

  Future<void> _pickCity(ArabCityRow city) async {
    final country = _selectedCountry!;
    final countryLabel = country.labelForLocale(widget.locale);
    final loc = city.toLocation(
      countryLabel: countryLabel,
      timezoneId: country.timezoneId,
      localeCode: widget.locale,
    );
    final next = widget.currentSettings.copyWith(
      autoLocation: false,
      manualPrayerLocation: loc,
    );
    await widget.onApply(next);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = widget.l10n;

    if (_loading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ));
    }

    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(
            l10n.prayerLocationSheetTitle,
            style: GoogleFonts.amiri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: AppCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.prayerLocationAutoGps,
                    style: GoogleFonts.amiri(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    l10n.prayerLocationAutoGpsSubtitle,
                    style: GoogleFonts.amiri(fontSize: 12),
                  ),
                  value: _auto,
                  onChanged: (v) => setState(() {
                    _auto = v;
                    if (v) _selectedCountry = null;
                  }),
                ),
                if (_auto)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: FilledButton.icon(
                      onPressed: _useAutoGps,
                      icon: const Icon(Icons.my_location, size: 20),
                      label: Text(
                        l10n.prayerLocationUseGpsNow,
                        style: GoogleFonts.amiri(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!_auto) ...[
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _countryQuery,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                prefixIcon: const Icon(Icons.search, size: 22),
                hintText: l10n.prayerLocationSearchCountry,
                hintStyle: GoogleFonts.amiri(),
              ),
              style: GoogleFonts.amiri(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: _selectedCountry == null ? 220 : 160,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _filteredCountries.length,
              itemBuilder: (context, i) {
                final c = _filteredCountries[i];
                final sel = _selectedCountry?.id == c.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Material(
                    color: sel
                        ? theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.55)
                        : theme.cardColor,
                    borderRadius: AppRadius.card,
                    child: InkWell(
                      borderRadius: AppRadius.card,
                      onTap: () => setState(() {
                        _selectedCountry = c;
                        _cityQuery.clear();
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c.labelForLocale(widget.locale),
                                style: GoogleFonts.amiri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              c.timezoneId,
                              style: GoogleFonts.amiri(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedCountry != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              child: TextField(
                controller: _cityQuery,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon: const Icon(Icons.location_city_outlined, size: 22),
                  hintText: l10n.prayerLocationSearchCity,
                  hintStyle: GoogleFonts.amiri(),
                ),
                style: GoogleFonts.amiri(),
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _filteredCities.length,
                itemBuilder: (context, i) {
                  final city = _filteredCities[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(
                      city.labelForLocale(widget.locale),
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${city.lat.toStringAsFixed(2)}, ${city.lon.toStringAsFixed(2)}',
                      style: GoogleFonts.amiri(fontSize: 12),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.primary,
                    ),
                    onTap: () => _pickCity(city),
                  );
                },
              ),
            ),
          ],
        ],
      ],
    ),
    );
  }
}
