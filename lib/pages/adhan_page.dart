import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import '../models/prayer_model.dart';
import '../services/prayer_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/common_ui.dart';
import '../ui/app_tokens.dart';

class AdhanPage extends StatefulWidget {
  const AdhanPage({super.key});

  @override
  State<AdhanPage> createState() => _AdhanPageState();
}

class _AdhanPageState extends State<AdhanPage> {
  final PrayerService _prayerService = PrayerService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  PrayerTimes? _prayerTimes;
  AdhanSettings? _settings;
  bool _isLoading = true;
  String? _currentlyPlayingPrayer;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _prayerService.initialize();
    await _loadPrayerTimes();
    if (!mounted) return;
    setState(() {
      _settings = _prayerService.settings;
      _isLoading = false;
    });
  }

  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Essayer d'obtenir la localisation automatique
      final prayerTimes = await _prayerService.getPrayerTimes();

      if (prayerTimes != null) {
        if (!mounted) return;
        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
        });
      } else {
        // Si la localisation automatique échoue, montrer les options
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _showLocationDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showLocationDialog();
    }
  }

  void _showLocationDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title:
            const Text('تحديد الموقع', style: TextStyle(fontFamily: 'Amiri')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 48, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text(
              'لم يتم تحديد موقعك تلقائيًا. يمكنك:',
              style: TextStyle(fontFamily: 'Amiri'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _requestLocationPermission();
                },
                icon: const Icon(Icons.gps_fixed),
                label: const Text('استخدام GPS',
                    style: TextStyle(fontFamily: 'Amiri')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showManualLocationDialog();
                },
                icon: const Icon(Icons.edit_location),
                label: const Text('إدخال الموقع يدويًا',
                    style: TextStyle(fontFamily: 'Amiri')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _useDefaultLocation();
                },
                icon: const Icon(Icons.location_city),
                label: const Text('استخدام مكة المكرمة',
                    style: TextStyle(fontFamily: 'Amiri')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Amiri')),
          ),
        ],
      ),
    );
  }

  Future<void> _useDefaultLocation() async {
    final defaultLocation = Location(
      city: 'مكة المكرمة',
      country: 'Saudi Arabia',
      latitude: 21.4225,
      longitude: 39.8262,
    );

    await _loadPrayerTimesWithCustomLocation(defaultLocation);
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _loadPrayerTimes();
      } else {
        if (!mounted) return;
        _showLocationDialog();
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('خطأ في طلب إذن الموقع');
    }
  }

  void _showManualLocationDialog() {
    final TextEditingController cityController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    final TextEditingController latController = TextEditingController();
    final TextEditingController lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إدخال الموقع يدويًا',
            style: TextStyle(fontFamily: 'Amiri')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Villes communes
              const Text('مدن شائعة:',
                  style: TextStyle(
                      fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildCityChip(
                      'مكة المكرمة',
                      'Saudi Arabia',
                      21.4225,
                      39.8262,
                      cityController,
                      countryController,
                      latController,
                      lngController),
                  _buildCityChip(
                      'المدينة المنورة',
                      'Saudi Arabia',
                      24.5247,
                      39.5692,
                      cityController,
                      countryController,
                      latController,
                      lngController),
                  _buildCityChip(
                      'الرياض',
                      'Saudi Arabia',
                      24.7136,
                      46.6753,
                      cityController,
                      countryController,
                      latController,
                      lngController),
                  _buildCityChip(
                      'جدة',
                      'Saudi Arabia',
                      21.5433,
                      39.1679,
                      cityController,
                      countryController,
                      latController,
                      lngController),
                  _buildCityChip(
                      'القاهرة',
                      'Egypt',
                      30.0444,
                      31.2357,
                      cityController,
                      countryController,
                      latController,
                      lngController),
                  _buildCityChip(
                      'الاسكندرية',
                      'Egypt',
                      31.2001,
                      29.9187,
                      cityController,
                      countryController,
                      latController,
                      lngController),
                  _buildCityChip(
                      'الرباط',
                      'Morocco',
                      34.0209,
                      -6.8416,
                      cityController,
                      countryController,
                      latController,
                      lngController),
                  _buildCityChip(
                      'الدار البيضاء',
                      'Morocco',
                      33.5731,
                      -7.5898,
                      cityController,
                      countryController,
                      latController,
                      lngController),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'المدينة',
                  labelStyle: TextStyle(fontFamily: 'Amiri'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: countryController,
                decoration: const InputDecoration(
                  labelText: 'البلد',
                  labelStyle: TextStyle(fontFamily: 'Amiri'),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'خط العرض (Latitude)',
                  labelStyle: TextStyle(fontFamily: 'Amiri'),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(
                  labelText: 'خط الطول (Longitude)',
                  labelStyle: TextStyle(fontFamily: 'Amiri'),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Amiri')),
          ),
          ElevatedButton(
            onPressed: () async {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);

              if (lat != null && lng != null) {
                final customLocation = Location(
                  city: cityController.text.isNotEmpty
                      ? cityController.text
                      : 'Unknown',
                  country: countryController.text.isNotEmpty
                      ? countryController.text
                      : 'Unknown',
                  latitude: lat,
                  longitude: lng,
                );

                Navigator.pop(context);
                await _loadPrayerTimesWithCustomLocation(customLocation);
              } else {
                _showErrorSnackBar('يرجى إدخال إحداثيات صحيحة');
              }
            },
            child: const Text('حفظ', style: TextStyle(fontFamily: 'Amiri')),
          ),
        ],
      ),
    );
  }

  Widget _buildCityChip(
      String city,
      String country,
      double lat,
      double lng,
      TextEditingController cityController,
      TextEditingController countryController,
      TextEditingController latController,
      TextEditingController lngController) {
    return ActionChip(
      label:
          Text(city, style: const TextStyle(fontFamily: 'Amiri', fontSize: 12)),
      onPressed: () {
        cityController.text = city;
        countryController.text = country;
        latController.text = lat.toString();
        lngController.text = lng.toString();
      },
    );
  }

  Future<void> _loadPrayerTimesWithCustomLocation(
      Location customLocation) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final prayerTimes =
          await _prayerService.getPrayerTimes(customLocation: customLocation);
      if (!mounted) return;
      setState(() {
        _prayerTimes = prayerTimes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('خطأ في تحميل أوقات الصلاة');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Amiri')),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _playAdhan(String prayerName) async {
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        _currentlyPlayingPrayer = null;
      });
    } else {
      try {
        final audioSource =
            await _prayerService.resolveAdhanAudioSource(prayerName);
        if (audioSource == null) {
          if (!mounted) return;
          _showErrorSnackBar('ملفات الأذان غير متوفرة حاليًا');
          return;
        }
        if (audioSource.isAsset) {
          await _audioPlayer.setAsset(audioSource.uri);
        } else {
          await _audioPlayer.setUrl(audioSource.uri);
        }
        await _audioPlayer.play();
        if (!mounted) return;
        setState(() {
          _currentlyPlayingPrayer = prayerName;
        });
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('خطأ في تشغيل الأذان');
      }
    }
  }

  Future<void> _showSettingsDialog() async {
    final currentSettings = _prayerService.settings;
    if (currentSettings == null) return;

    bool adhanEnabled = currentSettings.adhanEnabled;
    int notificationMinutes = currentSettings.notificationBeforeMinutes;
    double volume = currentSettings.volume;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إعدادات الأذان',
              style: TextStyle(fontFamily: 'Amiri')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // تفعيل/تعطيل الأذان
                SwitchListTile(
                  title: const Text('تفعيل الأذان',
                      style: TextStyle(fontFamily: 'Amiri')),
                  value: adhanEnabled,
                  onChanged: (value) {
                    setDialogState(() {
                      adhanEnabled = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // دقائق الإشعار قبل الصلاة
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'دقائق الإشعار قبل الصلاة',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: notificationMinutes.toString(),
                  onChanged: (value) {
                    notificationMinutes = int.tryParse(value) ?? 5;
                  },
                ),

                const SizedBox(height: 16),

                // مستوى الصوت
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('مستوى الصوت: ${(volume * 100).round()}%',
                        style: const TextStyle(fontFamily: 'Amiri')),
                    Slider(
                      value: volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) {
                        setDialogState(() {
                          volume = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Amiri')),
            ),
            ElevatedButton(
              onPressed: () async {
                final newSettings = AdhanSettings(
                  adhanEnabled: adhanEnabled,
                  notificationBeforeMinutes: notificationMinutes,
                  autoLocation: currentSettings.autoLocation,
                  volume: volume,
                );

                await _prayerService.saveSettings(newSettings);
                if (context.mounted) {
                  setState(() {
                    _settings = newSettings;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ', style: TextStyle(fontFamily: 'Amiri')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(
      String prayerName, String time, IconData icon, Color color) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: AppCard(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            prayerName,
            style: GoogleFonts.amiri(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: cs.onSurface,
            ),
          ),
          subtitle: Text(
            time,
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_settings?.adhanEnabled == true)
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final isPlaying = playerState?.playing ?? false;

                    final isCurrentSource =
                        _currentlyPlayingPrayer == prayerName;

                    return IconButton(
                      icon: Icon(
                        isPlaying && isCurrentSource
                            ? Icons.stop
                            : Icons.play_arrow,
                        color: isPlaying && isCurrentSource
                            ? theme.colorScheme.error
                            : cs.onSurface,
                      ),
                      onPressed: () => _playAdhan(prayerName),
                    );
                  },
                ),
              IconButton(
                icon: Icon(Icons.info_outline, color: cs.onSurface),
                onPressed: () => _showPrayerInfo(prayerName),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrayerInfo(String prayerName) {
    final prayerInfo = {
      'الفجر': 'صلاة الفجر هي أول صلاة في اليوم، وتصلى عند طلوع الفجر الصادق.',
      'الشروق': 'وقت شروق الشمس، وهو الوقت الذي تظهر فيه الشمس في الأفق.',
      'الظهر': 'صلاة الظهر تصلى عندما تكون الشمس في وسط السماء.',
      'العصر': 'صلاة العصر تصلى عندما يصبح ظل الشيء مثله.',
      'المغرب': 'صلاة المغرب تصلى عند غروب الشمس.',
      'العشاء': 'صلاة العشاء تصلى عند اختفاء الشفق الأحمر.',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('معلومات عن $prayerName',
            style: const TextStyle(fontFamily: 'Amiri')),
        content: Text(
          prayerInfo[prayerName] ?? 'لا توجد معلومات متاحة',
          style: const TextStyle(fontFamily: 'Amiri'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Amiri')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(
                title: l10n.adhanPageTitle,
                trailing: [
                  IconButton(
                    icon: Icon(Icons.settings,
                        color: theme.colorScheme.onSurface),
                    onPressed: _showSettingsDialog,
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.refresh, color: theme.colorScheme.onSurface),
                    onPressed: _loadPrayerTimes,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: _isLoading
                    ? AppLoadingView(label: l10n.adhanLoadingPrayerTimes)
                    : _prayerTimes == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off,
                                    size: 64,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6)),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.adhanLocationNotDetected,
                                  style: GoogleFonts.amiri(
                                    fontSize: 18,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.adhanLocationPrompt,
                                  style: GoogleFonts.amiri(
                                      color: theme.colorScheme.onSurface),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _showLocationDialog,
                                  icon: const Icon(Icons.settings),
                                  label: Text(
                                    l10n.adhanLocationSettings,
                                    style: GoogleFonts.amiri(),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // معلومات الموقع
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: theme.colorScheme.secondary
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: theme.colorScheme.onSurface),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _prayerService.locationDisplayName,
                                            style: GoogleFonts.amiri(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'Timezone: ${_prayerService.resolvedTimeZone}',
                                            style: GoogleFonts.amiri(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // أوقات الصلاة
                              Expanded(
                                child: ListView(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  children: [
                                    _buildPrayerCard(
                                        'الفجر',
                                        _prayerTimes!.fajr,
                                        Icons.wb_sunny,
                                        Colors.orange),
                                    _buildPrayerCard(
                                        'الشروق',
                                        _prayerTimes!.sunrise,
                                        Icons.wb_sunny_outlined,
                                        Colors.yellow),
                                    _buildPrayerCard(
                                        'الظهر',
                                        _prayerTimes!.dhuhr,
                                        Icons.wb_sunny,
                                        Colors.orange),
                                    _buildPrayerCard('العصر', _prayerTimes!.asr,
                                        Icons.wb_sunny, Colors.orange),
                                    _buildPrayerCard(
                                        'المغرب',
                                        _prayerTimes!.maghrib,
                                        Icons.nightlight,
                                        Colors.purple),
                                    _buildPrayerCard(
                                        'العشاء',
                                        _prayerTimes!.isha,
                                        Icons.nightlight_round,
                                        Colors.indigo),
                                  ],
                                ),
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
