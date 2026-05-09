import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/prayer_model.dart';

class PrayerService {
  static final PrayerService _instance = PrayerService._internal();
  factory PrayerService() => _instance;
  PrayerService._internal() {
    tz.initializeTimeZones();
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  Set<String>? _availableAssets;
  final Set<String> _loggedMissingAssets = {};
  String _resolvedTimeZone = 'UTC';

  PrayerTimes? _prayerTimes;
  Location? _location;
  AdhanSettings? _settings;

  PrayerTimes? get prayerTimes => _prayerTimes;
  Location? get location => _location;
  AdhanSettings? get settings => _settings;
  String get resolvedTimeZone => _resolvedTimeZone;

  String get locationDisplayName {
    final location = _location;
    final city = location?.city.trim() ?? '';
    final country = location?.country.trim() ?? '';
    if (city.toLowerCase().startsWith('unknown location')) {
      return 'Unknown location (using device timezone)';
    }
    if (city.isNotEmpty && city.toLowerCase() != 'unknown') {
      return country.isNotEmpty && country.toLowerCase() != 'unknown'
          ? '$city, $country'
          : city;
    }
    if (_resolvedTimeZone.isNotEmpty && _resolvedTimeZone != 'UTC') {
      return _resolvedTimeZone;
    }
    return 'Unknown location (using device timezone)';
  }

  Future<void> initialize() async {
    await _configureLocalTimezone();
    await _initializeNotifications();
    await _requestNotificationPermissions();
    await _loadSettings();
    await _restoreAndRescheduleIfPossible();
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final timezoneName = timezoneInfo.identifier;
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      _resolvedTimeZone = timezoneName;
      debugPrint('Timezone resolved: $_resolvedTimeZone');
    } catch (e) {
      final fallback = tz.getLocation('UTC');
      tz.setLocalLocation(fallback);
      _resolvedTimeZone = 'UTC';
      debugPrint('Timezone fallback to UTC due to error: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint(
            'Android notifications permission: ${granted == true ? 'granted' : 'denied'}');
      }

      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
            alert: true, badge: true, sound: true);
        debugPrint(
            'iOS notifications permission: ${granted == true ? 'granted' : 'denied'}');
      }
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('adhan_settings');

      if (settingsJson != null) {
        final settingsMap = json.decode(settingsJson);
        _settings = AdhanSettings.fromJson(settingsMap);
      } else {
        // Charger les paramètres par défaut
        final String data =
            await rootBundle.loadString('assets/data/adhan_settings.json');
        final Map<String, dynamic> jsonData = json.decode(data);
        _settings = AdhanSettings.fromJson(jsonData['default_settings']);
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des paramètres: $e');
    }
  }

  Future<void> saveSettings(AdhanSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('adhan_settings', json.encode(settings.toJson()));
      _settings = settings;
      if (settings.adhanEnabled) {
        await _schedulePrayerNotifications();
      } else {
        await _cancelPrayerNotifications();
      }
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  Future<Location?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Pour simplifier, on utilise les coordonnées directement
      // Le nom de la ville peut être obtenu via une API externe si nécessaire
      _location = Location(
        city: _resolvedTimeZone,
        country: 'Device timezone',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return _location;
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention de la localisation: $e');
      return null;
    }
  }

  Future<PrayerTimes?> getPrayerTimes({Location? customLocation}) async {
    try {
      await _configureLocalTimezone();
      Location? locationToUse = customLocation ?? _location;
      locationToUse ??= await getCurrentLocation();

      if (locationToUse == null) {
        // Utiliser des données par défaut si la localisation échoue
        debugPrint('Utilisation des données par défaut pour مكة المكرمة');
        _location = Location(
          city: 'Unknown location (using device timezone)',
          country: _resolvedTimeZone,
          latitude: 21.4225,
          longitude: 39.8262,
        );
        locationToUse = _location!;
      }

      final url =
          'https://api.aladhan.com/v1/timings?latitude=${locationToUse.latitude}&longitude=${locationToUse.longitude}&method=2';
      debugPrint('Tentative de récupération des horaires depuis: $url');

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout lors de la requête API');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          debugPrint(
              'Réponse API reçue: ${response.body.substring(0, 200)}...');

          if (data['data'] != null && data['data']['timings'] != null) {
            final timings = data['data']['timings'];

            // Valider les données avant de créer PrayerTimes
            if (_validateTimings(timings)) {
              _prayerTimes = PrayerTimes.fromJson(timings);
              _location = locationToUse;
              await _persistLatestPrayerSnapshot();

              debugPrint('Horaires de prière récupérés avec succès');

              // Programmer les notifications si activées
              if (_settings?.adhanEnabled == true) {
                await _schedulePrayerNotifications();
              }

              return _prayerTimes;
            } else {
              debugPrint(
                  'Données de timing invalides, utilisation des données par défaut');
              return _getDefaultPrayerTimes(locationToUse);
            }
          } else {
            debugPrint('Structure de données API invalide');
            return _getDefaultPrayerTimes(locationToUse);
          }
        } catch (e) {
          debugPrint('Erreur lors du parsing JSON: $e');
          return _getDefaultPrayerTimes(locationToUse);
        }
      } else {
        debugPrint('Erreur API: ${response.statusCode} - ${response.body}');
        // Utiliser des données par défaut
        return _getDefaultPrayerTimes(locationToUse);
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'obtention des horaires de prière: $e');
      // Utiliser des données par défaut en cas d'erreur
      if (customLocation != null) {
        return _getDefaultPrayerTimes(customLocation);
      }
      if (_location != null) {
        return _getDefaultPrayerTimes(_location!);
      }
    }
    return null;
  }

  PrayerTimes _getDefaultPrayerTimes(Location location) {
    // Données par défaut pour مكة المكرمة
    final defaultTimes = PrayerTimes(
      fajr: '04:30',
      sunrise: '06:00',
      dhuhr: '12:30',
      asr: '15:45',
      maghrib: '18:30',
      isha: '20:00',
    );

    _prayerTimes = defaultTimes;
    _location = location;
    _persistLatestPrayerSnapshot();

    debugPrint('Utilisation des horaires par défaut');
    return defaultTimes;
  }

  bool _validateTimings(Map<String, dynamic> timings) {
    final requiredFields = [
      'Fajr',
      'Sunrise',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha'
    ];

    for (final field in requiredFields) {
      if (timings[field] == null || timings[field].toString().isEmpty) {
        debugPrint('Champ manquant ou vide: $field');
        return false;
      }
    }

    return true;
  }

  Future<void> _schedulePrayerNotifications() async {
    if (_prayerTimes == null || _settings == null) return;
    await _configureLocalTimezone();
    final hasPermission = await _hasNotificationPermission();
    if (!hasPermission) {
      debugPrint('Notification scheduling skipped: permission denied');
      return;
    }
    await _cancelPrayerNotifications();

    final now = tz.TZDateTime.now(tz.local);
    debugPrint('Scheduling prayer pre-alerts at $now ($_resolvedTimeZone)');

    Future<void> schedulePreAlert(
        String prayerName, String prayerNameEn, String time) async {
      final nextPrayerTime = PrayerService.computeNextPrayerDateTime(
        now: now,
        prayerTime: time,
      );

      final notificationTime =
          PrayerService.computePreAlertDateTime(nextPrayerTime);

      if (notificationTime.isAfter(now)) {
        await _notifications.zonedSchedule(
          _getPrePrayerNotificationId(prayerName),
          'Prayer Reminder',
          '$prayerNameEn in 5 minutes - prepare for prayer',
          tz.TZDateTime.from(notificationTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_pre_alerts',
              'Prayer Reminders',
              channelDescription:
                  'Pre-alert notifications 5 minutes before prayer times',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        debugPrint(
            'Pre-alert scheduled for $prayerName at $notificationTime ($_resolvedTimeZone)');
      } else {
        debugPrint(
            'Pre-alert skipped for $prayerName: computed time is in the past');
      }
    }

    await schedulePreAlert('الفجر', 'Fajr', _prayerTimes!.fajr);
    await schedulePreAlert('الظهر', 'Dhuhr', _prayerTimes!.dhuhr);
    await schedulePreAlert('العصر', 'Asr', _prayerTimes!.asr);
    await schedulePreAlert('المغرب', 'Maghrib', _prayerTimes!.maghrib);
    await schedulePreAlert('العشاء', 'Isha', _prayerTimes!.isha);
  }

  Future<void> _cancelPrayerNotifications() async {
    for (final id in [1, 2, 3, 4, 5, 101, 102, 103, 104, 105]) {
      await _notifications.cancel(id);
    }
  }

  Future<bool> _hasNotificationPermission() async {
    try {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('Permission status check failed: $e');
      return false;
    }
  }

  Future<void> _persistLatestPrayerSnapshot() async {
    if (_prayerTimes == null || _location == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cached_prayer_times',
        json.encode({
          'Fajr': _prayerTimes!.fajr,
          'Sunrise': _prayerTimes!.sunrise,
          'Dhuhr': _prayerTimes!.dhuhr,
          'Asr': _prayerTimes!.asr,
          'Maghrib': _prayerTimes!.maghrib,
          'Isha': _prayerTimes!.isha,
        }),
      );
      await prefs.setString(
        'cached_location',
        json.encode({
          'city': _location!.city,
          'country': _location!.country,
          'latitude': _location!.latitude,
          'longitude': _location!.longitude,
        }),
      );
    } catch (e) {
      debugPrint('Failed to persist prayer snapshot: $e');
    }
  }

  Future<void> _restoreAndRescheduleIfPossible() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timesJson = prefs.getString('cached_prayer_times');
      final locationJson = prefs.getString('cached_location');
      if (timesJson == null || locationJson == null) {
        debugPrint('No cached prayer snapshot found to restore');
        return;
      }

      final times = json.decode(timesJson) as Map<String, dynamic>;
      final location = json.decode(locationJson) as Map<String, dynamic>;
      _prayerTimes = PrayerTimes.fromJson(times);
      _location = Location(
        city: location['city']?.toString() ?? 'Unknown',
        country: location['country']?.toString() ?? 'Unknown',
        latitude: (location['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (location['longitude'] as num?)?.toDouble() ?? 0.0,
      );
      if (_settings?.adhanEnabled == true) {
        await _schedulePrayerNotifications();
        debugPrint('Notifications restored from cached prayer snapshot');
      }
    } catch (e) {
      debugPrint('Failed to restore cached prayer snapshot: $e');
    }
  }

  Future<void> _loadAssetManifestIfNeeded() async {
    if (_availableAssets != null) return;
    try {
      final manifestRaw = await rootBundle.loadString('AssetManifest.json');
      final decoded = json.decode(manifestRaw) as Map<String, dynamic>;
      _availableAssets = decoded.keys.toSet();
    } catch (e) {
      debugPrint('Failed to read AssetManifest for adhan lookup: $e');
      _availableAssets = <String>{};
    }
  }

  Future<String?> resolveAdhanAssetPath(String prayerName) async {
    await _loadAssetManifestIfNeeded();
    const map = {
      'الفجر': 'assets/sounds/adhan/fajr.mp3',
      'الظهر': 'assets/sounds/adhan/dhuhr.mp3',
      'العصر': 'assets/sounds/adhan/asr.mp3',
      'المغرب': 'assets/sounds/adhan/maghrib.mp3',
      'العشاء': 'assets/sounds/adhan/isha.mp3',
    };
    const defaultAsset = 'assets/sounds/adhan/default_adhan.mp3';
    final specificAsset = map[prayerName] ?? defaultAsset;

    if (_availableAssets!.contains(specificAsset)) {
      return specificAsset;
    }
    final specificKey = 'missing:$specificAsset';
    if (_loggedMissingAssets.add(specificKey)) {
      debugPrint(
          'Missing adhan asset for $prayerName: $specificAsset. Trying default.');
    }
    if (_availableAssets!.contains(defaultAsset)) {
      return defaultAsset;
    }
    const defaultKey = 'missing:assets/sounds/adhan/default_adhan.mp3';
    if (_loggedMissingAssets.add(defaultKey)) {
      debugPrint(
          'Missing default adhan asset: $defaultAsset. Playback disabled.');
    }
    return null;
  }

  Future<AdhanAudioSource?> resolveAdhanAudioSource(String prayerName) async {
    final asset = await resolveAdhanAssetPath(prayerName);
    if (asset != null) {
      return AdhanAudioSource.asset(asset);
    }

    final remoteUrl =
        _adhanRemoteFallbacks[prayerName] ?? _adhanRemoteFallbacks['default'];
    if (remoteUrl == null || remoteUrl.isEmpty) {
      return null;
    }
    return AdhanAudioSource.remote(remoteUrl);
  }

  @visibleForTesting
  static DateTime computeNextPrayerDateTime({
    required DateTime now,
    required String prayerTime,
  }) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(prayerTime);
    final hour = int.tryParse(match?.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match?.group(2) ?? '') ?? 0;
    final candidate = DateTime(now.year, now.month, now.day, hour, minute);
    if (candidate.isBefore(now)) {
      return candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  @visibleForTesting
  static DateTime computePreAlertDateTime(DateTime prayerDateTime) {
    return prayerDateTime.subtract(const Duration(minutes: 5));
  }

  int _getPrePrayerNotificationId(String prayerName) {
    final prayerIds = {
      'الفجر': 101,
      'الظهر': 102,
      'العصر': 103,
      'المغرب': 104,
      'العشاء': 105,
    };
    return prayerIds[prayerName] ?? 100;
  }

  void dispose() {
    // No-op for now; retained for compatibility with existing callers.
  }
}

const Map<String, String> _adhanRemoteFallbacks = {
  'الفجر': 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3',
  'الظهر': 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3',
  'العصر': 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3',
  'المغرب': 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3',
  'العشاء': 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3',
  'default': 'https://praytimes.org/audio/sunni/Adhan-Makkah.mp3',
};

class AdhanAudioSource {
  final String uri;
  final bool isAsset;

  const AdhanAudioSource._({
    required this.uri,
    required this.isAsset,
  });

  const AdhanAudioSource.asset(String assetPath)
      : this._(uri: assetPath, isAsset: true);

  const AdhanAudioSource.remote(String url) : this._(uri: url, isAsset: false);
}
