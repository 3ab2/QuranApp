import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/models/prayer_model.dart';

class ArabCityRow {
  final String nameAr;
  final String nameEn;
  final String nameFr;
  final double lat;
  final double lon;

  const ArabCityRow({
    required this.nameAr,
    required this.nameEn,
    required this.nameFr,
    required this.lat,
    required this.lon,
  });

  factory ArabCityRow.fromJson(Map<String, dynamic> j) {
    return ArabCityRow(
      nameAr: j['ar']?.toString() ?? '',
      nameEn: j['en']?.toString() ?? '',
      nameFr: j['fr']?.toString() ?? '',
      lat: (j['lat'] as num?)?.toDouble() ?? 0,
      lon: (j['lon'] as num?)?.toDouble() ?? 0,
    );
  }

  String labelForLocale(String code) {
    switch (code) {
      case 'ar':
        return nameAr;
      case 'fr':
        return nameFr;
      default:
        return nameEn;
    }
  }

  Location toLocation({
    required String countryLabel,
    required String timezoneId,
    required String localeCode,
  }) {
    final city = labelForLocale(localeCode);
    return Location(
      city: city,
      country: countryLabel,
      latitude: lat,
      longitude: lon,
      timezoneId: timezoneId,
    );
  }
}

class ArabCountryRow {
  final String id;
  final String nameAr;
  final String nameEn;
  final String nameFr;
  final String timezoneId;
  final List<ArabCityRow> cities;

  ArabCountryRow({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameFr,
    required this.timezoneId,
    required this.cities,
  });

  factory ArabCountryRow.fromJson(Map<String, dynamic> j) {
    final raw = j['cities'] as List<dynamic>? ?? [];
    return ArabCountryRow(
      id: j['id']?.toString() ?? '',
      nameAr: j['ar']?.toString() ?? '',
      nameEn: j['en']?.toString() ?? '',
      nameFr: j['fr']?.toString() ?? '',
      timezoneId: j['tz']?.toString() ?? '',
      cities: raw
          .map((e) => ArabCityRow.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  String labelForLocale(String code) {
    switch (code) {
      case 'ar':
        return nameAr;
      case 'fr':
        return nameFr;
      default:
        return nameEn;
    }
  }
}

class ArabRegionsRepository {
  ArabRegionsRepository._();
  static final ArabRegionsRepository instance = ArabRegionsRepository._();

  List<ArabCountryRow>? _countries;

  Future<List<ArabCountryRow>> loadCountries() async {
    if (_countries != null) return _countries!;
    final raw = await _loadArabRegionsJson();
    final map = json.decode(raw) as Map<String, dynamic>;
    final list = map['countries'] as List<dynamic>? ?? [];
    _countries = list
        .map((e) => ArabCountryRow.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return _countries!;
  }

  void resetCacheForTests() {
    _countries = null;
  }

  /// Web: [rootBundle] keys that start with `assets/` become `assets/assets/...`
  /// in the browser and often 404; load the same bytes over HTTP instead.
  static Future<String> _loadArabRegionsJson() async {
    if (kIsWeb) {
      const paths = <String>[
        'assets/data/arab_regions.json',
        'assets/assets/data/arab_regions.json',
      ];
      for (final path in paths) {
        final uri = Uri.base.resolve(path);
        try {
          final response = await http
              .get(uri)
              .timeout(const Duration(seconds: 15));
          if (response.statusCode == 200 && response.body.isNotEmpty) {
            return response.body;
          }
        } catch (_) {
          continue;
        }
      }
    }
    return rootBundle.loadString('assets/data/arab_regions.json');
  }
}
