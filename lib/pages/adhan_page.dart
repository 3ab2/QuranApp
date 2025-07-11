import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_model.dart';
import '../services/prayer_service.dart';

class AdhanPage extends StatefulWidget {
  const AdhanPage({super.key});

  @override
  State<AdhanPage> createState() => _AdhanPageState();
}

class _AdhanPageState extends State<AdhanPage> {
  final PrayerService _prayerService = PrayerService();
  
  PrayerTimes? _prayerTimes;
  Location? _location;
  AdhanSettings? _settings;
  bool _isLoading = true;
  bool _isPlayingAdhan = false;
  String? _currentPlayingPrayer;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _prayerService.initialize();
    await _loadPrayerTimes();
    setState(() {
      _settings = _prayerService.settings;
      _isLoading = false;
    });
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Essayer d'obtenir la localisation automatique
      final prayerTimes = await _prayerService.getPrayerTimes();
      final location = _prayerService.location;
      
      if (prayerTimes != null && location != null) {
        setState(() {
          _prayerTimes = prayerTimes;
          _location = location;
          _isLoading = false;
        });
      } else {
        // Si la localisation automatique échoue, montrer les options
        setState(() {
          _isLoading = false;
        });
        _showLocationDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showLocationDialog();
    }
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تحديد الموقع', style: TextStyle(fontFamily: 'Amiri')),
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
                label: const Text('استخدام GPS', style: TextStyle(fontFamily: 'Amiri')),
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
                label: const Text('إدخال الموقع يدويًا', style: TextStyle(fontFamily: 'Amiri')),
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
                label: const Text('استخدام مكة المكرمة', style: TextStyle(fontFamily: 'Amiri')),
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
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        await _loadPrayerTimes();
      } else {
        _showLocationDialog();
      }
    } catch (e) {
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
        title: const Text('إدخال الموقع يدويًا', style: TextStyle(fontFamily: 'Amiri')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Villes communes
              const Text('مدن شائعة:', style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildCityChip('مكة المكرمة', 'Saudi Arabia', 21.4225, 39.8262, cityController, countryController, latController, lngController),
                  _buildCityChip('المدينة المنورة', 'Saudi Arabia', 24.5247, 39.5692, cityController, countryController, latController, lngController),
                  _buildCityChip('الرياض', 'Saudi Arabia', 24.7136, 46.6753, cityController, countryController, latController, lngController),
                  _buildCityChip('جدة', 'Saudi Arabia', 21.5433, 39.1679, cityController, countryController, latController, lngController),
                  _buildCityChip('القاهرة', 'Egypt', 30.0444, 31.2357, cityController, countryController, latController, lngController),
                  _buildCityChip('الاسكندرية', 'Egypt', 31.2001, 29.9187, cityController, countryController, latController, lngController),
                  _buildCityChip('الرباط', 'Morocco', 34.0209, -6.8416, cityController, countryController, latController, lngController),
                  _buildCityChip('الدار البيضاء', 'Morocco', 33.5731, -7.5898, cityController, countryController, latController, lngController),
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
                  city: cityController.text.isNotEmpty ? cityController.text : 'Unknown',
                  country: countryController.text.isNotEmpty ? countryController.text : 'Unknown',
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

  Widget _buildCityChip(String city, String country, double lat, double lng, 
      TextEditingController cityController, TextEditingController countryController, 
      TextEditingController latController, TextEditingController lngController) {
    return ActionChip(
      label: Text(city, style: const TextStyle(fontFamily: 'Amiri', fontSize: 12)),
      onPressed: () {
        cityController.text = city;
        countryController.text = country;
        latController.text = lat.toString();
        lngController.text = lng.toString();
      },
    );
  }

  Future<void> _loadPrayerTimesWithCustomLocation(Location customLocation) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prayerTimes = await _prayerService.getPrayerTimes(customLocation: customLocation);
      
      setState(() {
        _prayerTimes = prayerTimes;
        _location = customLocation;
        _isLoading = false;
      });
    } catch (e) {
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
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _playAdhan(String prayerName) async {
    if (_isPlayingAdhan) {
      await _prayerService.stopAdhan();
      setState(() {
        _isPlayingAdhan = false;
        _currentPlayingPrayer = null;
      });
    } else {
      await _prayerService.playAdhan(prayerName);
      setState(() {
        _isPlayingAdhan = true;
        _currentPlayingPrayer = prayerName;
      });
    }
  }

  Future<void> _showSettingsDialog() async {
    final currentSettings = _prayerService.settings;
    if (currentSettings == null) return;

    bool adhanEnabled = currentSettings.adhanEnabled;
    String selectedMuezzin = currentSettings.selectedMuezzin;
    String selectedAdhanSound = currentSettings.selectedAdhanSound;
    int notificationMinutes = currentSettings.notificationBeforeMinutes;
    double volume = currentSettings.volume;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('إعدادات الأذان', style: TextStyle(fontFamily: 'Amiri')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // تفعيل/تعطيل الأذان
                SwitchListTile(
                  title: const Text('تفعيل الأذان', style: TextStyle(fontFamily: 'Amiri')),
                  value: adhanEnabled,
                  onChanged: (value) {
                    setDialogState(() {
                      adhanEnabled = value;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // اختيار المؤذن
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'اختر المؤذن',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  value: selectedMuezzin,
                  items: _prayerService.muezzins.map((muezzin) {
                    return DropdownMenuItem(
                      value: muezzin.id,
                      child: Text('${muezzin.name} (${muezzin.nameEn})', style: const TextStyle(fontFamily: 'Amiri')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedMuezzin = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // اختيار صوت الأذان
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'صوت الأذان',
                    labelStyle: TextStyle(fontFamily: 'Amiri'),
                  ),
                  value: selectedAdhanSound,
                  items: _prayerService.adhanSounds.map((sound) {
                    return DropdownMenuItem(
                      value: sound.id,
                      child: Text('${sound.name} (${sound.nameEn})', style: const TextStyle(fontFamily: 'Amiri')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedAdhanSound = value!;
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
                    Text('مستوى الصوت: ${(volume * 100).round()}%', style: const TextStyle(fontFamily: 'Amiri')),
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
                  selectedMuezzin: selectedMuezzin,
                  selectedAdhanSound: selectedAdhanSound,
                  notificationBeforeMinutes: notificationMinutes,
                  autoLocation: currentSettings.autoLocation,
                  volume: volume,
                );
                
                await _prayerService.saveSettings(newSettings);
                setState(() {
                  _settings = newSettings;
                });
                
                Navigator.pop(context);
              },
              child: const Text('حفظ', style: TextStyle(fontFamily: 'Amiri')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(String prayerName, String time, IconData icon, Color color) {
    final isCurrentPrayer = _currentPlayingPrayer == prayerName;
    
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          prayerName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Amiri',
          ),
        ),
        subtitle: Text(
          time,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontFamily: 'Amiri',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_settings?.adhanEnabled == true)
              IconButton(
                icon: Icon(
                  isCurrentPrayer ? Icons.stop : Icons.play_arrow,
                  color: isCurrentPrayer ? Colors.red : Colors.indigo,
                ),
                onPressed: () => _playAdhan(prayerName),
              ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.indigo),
              onPressed: () => _showPrayerInfo(prayerName),
            ),
          ],
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
        title: Text('معلومات عن $prayerName', style: const TextStyle(fontFamily: 'Amiri')),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('الأذان وأوقات الصلاة', style: TextStyle(fontFamily: 'Amiri')),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsDialog,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPrayerTimes,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.indigo),
                    SizedBox(height: 16),
                    Text('جاري تحميل أوقات الصلاة...', style: TextStyle(fontFamily: 'Amiri')),
                  ],
                ),
              )
            : _prayerTimes == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'لم يتم تحديد موقعك',
                          style: TextStyle(fontSize: 18, fontFamily: 'Amiri'),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'اضغط على زر الإعدادات لاختيار الموقع',
                          style: TextStyle(fontFamily: 'Amiri'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showLocationDialog,
                          icon: const Icon(Icons.settings),
                          label: const Text('إعدادات الموقع', style: TextStyle(fontFamily: 'Amiri')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // معلومات الموقع
                      if (_location != null)
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.indigo.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.indigo),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _location!.city,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                    Text(
                                      _location!.country,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // أوقات الصلاة
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          children: [
                            _buildPrayerCard('الفجر', _prayerTimes!.fajr, Icons.wb_sunny, Colors.orange),
                            _buildPrayerCard('الشروق', _prayerTimes!.sunrise, Icons.wb_sunny_outlined, Colors.yellow),
                            _buildPrayerCard('الظهر', _prayerTimes!.dhuhr, Icons.wb_sunny, Colors.orange),
                            _buildPrayerCard('العصر', _prayerTimes!.asr, Icons.wb_sunny, Colors.orange),
                            _buildPrayerCard('المغرب', _prayerTimes!.maghrib, Icons.nightlight, Colors.purple),
                            _buildPrayerCard('العشاء', _prayerTimes!.isha, Icons.nightlight_round, Colors.indigo),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
    );
  }

  @override
  void dispose() {
    _prayerService.stopAdhan();
    super.dispose();
  }
} 