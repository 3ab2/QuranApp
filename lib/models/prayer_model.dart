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

  Location({
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class AdhanSettings {
  final bool adhanEnabled;
  final String selectedMuezzin;
  final String selectedAdhanSound;
  final int notificationBeforeMinutes;
  final bool autoLocation;
  final double volume;

  AdhanSettings({
    required this.adhanEnabled,
    required this.selectedMuezzin,
    required this.selectedAdhanSound,
    required this.notificationBeforeMinutes,
    required this.autoLocation,
    required this.volume,
  });

  factory AdhanSettings.fromJson(Map<String, dynamic> json) {
    return AdhanSettings(
      adhanEnabled: json['adhan_enabled'] ?? true,
      selectedMuezzin: json['selected_muezzin'] ?? 'mishary_alafasy',
      selectedAdhanSound: json['selected_adhan_sound'] ?? 'regular_adhan',
      notificationBeforeMinutes: json['notification_before_minutes'] ?? 5,
      autoLocation: json['auto_location'] ?? true,
      volume: json['volume']?.toDouble() ?? 0.8,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adhan_enabled': adhanEnabled,
      'selected_muezzin': selectedMuezzin,
      'selected_adhan_sound': selectedAdhanSound,
      'notification_before_minutes': notificationBeforeMinutes,
      'auto_location': autoLocation,
      'volume': volume,
    };
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