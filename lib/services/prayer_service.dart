import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:audioplayers/audioplayers.dart';
import '../models/prayer_model.dart';

class PrayerService {
  static final PrayerService _instance = PrayerService._internal();
  factory PrayerService() => _instance;
  PrayerService._internal() {
    tz.initializeTimeZones();
  }

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  PrayerTimes? _prayerTimes;
  Location? _location;
  AdhanSettings? _settings;
  List<Muezzin> _muezzins = [];
  List<AdhanSound> _adhanSounds = [];

  PrayerTimes? get prayerTimes => _prayerTimes;
  Location? get location => _location;
  AdhanSettings? get settings => _settings;
  List<Muezzin> get muezzins => _muezzins;
  List<AdhanSound> get adhanSounds => _adhanSounds;

  Future<void> initialize() async {
    await _initializeNotifications();
    await _loadSettings();
    await _loadMuezzins();
    await _loadAdhanSounds();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await _notifications.initialize(initializationSettings);
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
        final String data = await rootBundle.loadString('assets/data/adhan_settings.json');
        final Map<String, dynamic> jsonData = json.decode(data);
        _settings = AdhanSettings.fromJson(jsonData['default_settings']);
      }
    } catch (e) {
      print('Erreur lors du chargement des paramètres: $e');
    }
  }

  Future<void> _loadMuezzins() async {
    try {
      final String data = await rootBundle.loadString('assets/data/adhan_settings.json');
      final Map<String, dynamic> jsonData = json.decode(data);
      final List<dynamic> muezzinsList = jsonData['muezzins'];
      
      _muezzins = muezzinsList.map((json) => Muezzin.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors du chargement des muezzins: $e');
    }
  }

  Future<void> _loadAdhanSounds() async {
    try {
      final String data = await rootBundle.loadString('assets/data/adhan_settings.json');
      final Map<String, dynamic> jsonData = json.decode(data);
      final List<dynamic> soundsList = jsonData['adhan_sounds'];
      
      _adhanSounds = soundsList.map((json) => AdhanSound.fromJson(json)).toList();
    } catch (e) {
      print('Erreur lors du chargement des sons d\'adhan: $e');
    }
  }

  Future<void> saveSettings(AdhanSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('adhan_settings', json.encode(settings.toJson()));
      _settings = settings;
    } catch (e) {
      print('Erreur lors de la sauvegarde des paramètres: $e');
    }
  }

  Future<Location?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Pour simplifier, on utilise les coordonnées directement
      // Le nom de la ville peut être obtenu via une API externe si nécessaire
      _location = Location(
        city: 'Unknown',
        country: 'Unknown',
        latitude: position.latitude,
        longitude: position.longitude,
      );

      return _location;
    } catch (e) {
      print('Erreur lors de l\'obtention de la localisation: $e');
      return null;
    }
  }

  Future<PrayerTimes?> getPrayerTimes({Location? customLocation}) async {
    try {
      Location? locationToUse = customLocation ?? _location;
      if (locationToUse == null) {
        locationToUse = await getCurrentLocation();
      }
      
      if (locationToUse == null) {
        // Utiliser des données par défaut si la localisation échoue
        print('Utilisation des données par défaut pour مكة المكرمة');
        _location = Location(
          city: 'مكة المكرمة',
          country: 'Saudi Arabia',
          latitude: 21.4225,
          longitude: 39.8262,
        );
        locationToUse = _location!;
      }

      final url = 'https://api.aladhan.com/v1/timings?latitude=${locationToUse.latitude}&longitude=${locationToUse.longitude}&method=2';
      print('Tentative de récupération des horaires depuis: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout lors de la requête API');
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('Réponse API reçue: ${response.body.substring(0, 200)}...');
          
          if (data['data'] != null && data['data']['timings'] != null) {
            final timings = data['data']['timings'];
            
            // Valider les données avant de créer PrayerTimes
            if (_validateTimings(timings)) {
              _prayerTimes = PrayerTimes.fromJson(timings);
              _location = locationToUse;
              
              print('Horaires de prière récupérés avec succès');
              
              // Programmer les notifications si activées
              if (_settings?.adhanEnabled == true) {
                await _schedulePrayerNotifications();
              }
              
              return _prayerTimes;
            } else {
              print('Données de timing invalides, utilisation des données par défaut');
              return _getDefaultPrayerTimes(locationToUse);
            }
          } else {
            print('Structure de données API invalide');
            return _getDefaultPrayerTimes(locationToUse);
          }
        } catch (e) {
          print('Erreur lors du parsing JSON: $e');
          return _getDefaultPrayerTimes(locationToUse);
        }
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        // Utiliser des données par défaut
        return _getDefaultPrayerTimes(locationToUse);
      }
    } catch (e) {
      print('Erreur lors de l\'obtention des horaires de prière: $e');
      // Utiliser des données par défaut en cas d'erreur
      if (customLocation != null) {
        return _getDefaultPrayerTimes(customLocation);
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
    
    print('Utilisation des horaires par défaut');
    return defaultTimes;
  }

  bool _validateTimings(Map<String, dynamic> timings) {
    final requiredFields = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    
    for (final field in requiredFields) {
      if (timings[field] == null || timings[field].toString().isEmpty) {
        print('Champ manquant ou vide: $field');
        return false;
      }
    }
    
    return true;
  }

  Future<void> _schedulePrayerNotifications() async {
    if (_prayerTimes == null || _settings == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Fonction pour programmer une notification
    Future<void> scheduleNotification(String prayerName, String time, int minutesBefore) async {
      final timeParts = time.split(':');
      final prayerTime = DateTime(
        today.year,
        today.month,
        today.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      // Si l'heure de prière est déjà passée aujourd'hui, programmer pour demain
      if (prayerTime.isBefore(now)) {
        prayerTime.add(const Duration(days: 1));
      }

      final notificationTime = prayerTime.subtract(Duration(minutes: minutesBefore));

      if (notificationTime.isAfter(now)) {
        await _notifications.zonedSchedule(
          _getPrayerNotificationId(prayerName),
          'وقت الصلاة',
          'حان وقت صلاة $prayerName',
          tz.TZDateTime.from(notificationTime, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_notifications',
              'Prayer Notifications',
              channelDescription: 'Notifications for prayer times',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }

    // Programmer les notifications pour chaque prière
    await scheduleNotification('الفجر', _prayerTimes!.fajr, _settings!.notificationBeforeMinutes);
    await scheduleNotification('الظهر', _prayerTimes!.dhuhr, _settings!.notificationBeforeMinutes);
    await scheduleNotification('العصر', _prayerTimes!.asr, _settings!.notificationBeforeMinutes);
    await scheduleNotification('المغرب', _prayerTimes!.maghrib, _settings!.notificationBeforeMinutes);
    await scheduleNotification('العشاء', _prayerTimes!.isha, _settings!.notificationBeforeMinutes);
  }

  int _getPrayerNotificationId(String prayerName) {
    final prayerIds = {
      'الفجر': 1,
      'الظهر': 2,
      'العصر': 3,
      'المغرب': 4,
      'العشاء': 5,
    };
    return prayerIds[prayerName] ?? 0;
  }

  Future<void> playAdhan(String prayerName) async {
    if (_settings?.adhanEnabled != true) return;

    try {
      // Trouver le son d'adhan approprié
      AdhanSound? adhanSound;
      if (prayerName == 'الفجر') {
        adhanSound = _adhanSounds.firstWhere((sound) => sound.id == 'fajr_adhan');
      } else {
        adhanSound = _adhanSounds.firstWhere((sound) => sound.id == 'regular_adhan');
      }

      await _audioPlayer.stop();
      await _audioPlayer.setVolume(_settings?.volume ?? 0.8);
      await _audioPlayer.play(UrlSource(adhanSound.audioUrl));
    } catch (e) {
      print('Erreur lors de la lecture de l\'adhan: $e');
    }
  }

  Future<void> stopAdhan() async {
    await _audioPlayer.stop();
  }

  Muezzin? getSelectedMuezzin() {
    if (_settings == null) return null;
    return _muezzins.firstWhere(
      (muezzin) => muezzin.id == _settings!.selectedMuezzin,
      orElse: () => _muezzins.first,
    );
  }

  AdhanSound? getSelectedAdhanSound() {
    if (_settings == null) return null;
    return _adhanSounds.firstWhere(
      (sound) => sound.id == _settings!.selectedAdhanSound,
      orElse: () => _adhanSounds.first,
    );
  }

  void dispose() {
    _audioPlayer.dispose();
  }
} 