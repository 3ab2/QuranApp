class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    return PrayerTimes(
      fajr: json['Fajr'] ?? json['fajr'] ?? '',
      sunrise: json['Sunrise'] ?? json['sunrise'] ?? '',
      dhuhr: json['Dhuhr'] ?? json['dhuhr'] ?? '',
      asr: json['Asr'] ?? json['asr'] ?? '',
      maghrib: json['Maghrib'] ?? json['maghrib'] ?? '',
      isha: json['Isha'] ?? json['isha'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }
}

class Location {
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  /// IANA timezone for prayer scheduling when this location is active (optional).
  final String? timezoneId;

  Location({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.timezoneId,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      timezoneId: json['timezone_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      if (timezoneId != null) 'timezone_id': timezoneId,
    };
  }
}

class AdhanSettings {
  final bool adhanEnabled;
  final int notificationBeforeMinutes;
  final bool autoLocation;
  final double volume;
  /// e.g. bundled_default, mishary, makkah — see [kAdhanVoiceCatalog].
  final String muezzinVoiceId;
  /// Reserved for future native DND / audio ducking; stored for UX continuity.
  final bool mosqueModeEnabled;
  /// When [autoLocation] is false, this location drives prayer times & tz.
  final Location? manualPrayerLocation;

  AdhanSettings({
    required this.adhanEnabled,
    required this.notificationBeforeMinutes,
    required this.autoLocation,
    required this.volume,
    this.muezzinVoiceId = 'bundled_default',
    this.mosqueModeEnabled = false,
    this.manualPrayerLocation,
  });

  factory AdhanSettings.fromJson(Map<String, dynamic> json) {
    Location? manual;
    final rawManual = json['manual_prayer_location'];
    if (rawManual is Map<String, dynamic>) {
      manual = Location.fromJson(rawManual);
    }
    return AdhanSettings(
      adhanEnabled: json['adhan_enabled'] ?? true,
      notificationBeforeMinutes: json['notification_before_minutes'] ?? 5,
      autoLocation: json['auto_location'] ?? true,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      muezzinVoiceId: json['muezzin_voice_id']?.toString() ?? 'bundled_default',
      mosqueModeEnabled: json['mosque_mode_enabled'] == true,
      manualPrayerLocation: manual,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adhan_enabled': adhanEnabled,
      'notification_before_minutes': notificationBeforeMinutes,
      'auto_location': autoLocation,
      'volume': volume,
      'muezzin_voice_id': muezzinVoiceId,
      'mosque_mode_enabled': mosqueModeEnabled,
      if (manualPrayerLocation != null)
        'manual_prayer_location': manualPrayerLocation!.toJson(),
    };
  }

  AdhanSettings copyWith({
    bool? adhanEnabled,
    int? notificationBeforeMinutes,
    bool? autoLocation,
    double? volume,
    String? muezzinVoiceId,
    bool? mosqueModeEnabled,
    Location? manualPrayerLocation,
    bool clearManualPrayerLocation = false,
  }) {
    return AdhanSettings(
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      notificationBeforeMinutes:
          notificationBeforeMinutes ?? this.notificationBeforeMinutes,
      autoLocation: autoLocation ?? this.autoLocation,
      volume: volume ?? this.volume,
      muezzinVoiceId: muezzinVoiceId ?? this.muezzinVoiceId,
      mosqueModeEnabled: mosqueModeEnabled ?? this.mosqueModeEnabled,
      manualPrayerLocation: clearManualPrayerLocation
          ? null
          : (manualPrayerLocation ?? this.manualPrayerLocation),
    );
  }
}

class Muezzin {
  final String id;
  final String name;
  final String nameEn;
  final String audioUrl;

  Muezzin({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.audioUrl,
  });

  factory Muezzin.fromJson(Map<String, dynamic> json) {
    return Muezzin(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'audio_url': audioUrl,
    };
  }
}

class AdhanSound {
  final String id;
  final String name;
  final String nameEn;
  final String audioUrl;

  AdhanSound({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.audioUrl,
  });

  factory AdhanSound.fromJson(Map<String, dynamic> json) {
    return AdhanSound(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      audioUrl: json['audio_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'audio_url': audioUrl,
    };
  }
} 