import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:quran_app/models/prayer_model.dart';
import 'package:quran_app/prayer/prayer_timeline.dart';

/// Lightweight 1 Hz clock for prayer UX. Cancel in [dispose].
class PrayerLiveClock extends ChangeNotifier {
  PrayerLiveClock();

  Timer? _timer;
  PrayerTimes? _times;
  int _preAlertMinutes = 5;
  DateTime _now = DateTime.now();

  PrayerTimes? get times => _times;
  int get preAlertMinutes => _preAlertMinutes;

  PrayerDashboardSnapshot? get snapshot {
    final t = _times;
    if (t == null) return null;
    return computePrayerDashboard(
      now: _now,
      times: t,
      preAlertMinutes: _preAlertMinutes,
    );
  }

  void configure({
    required PrayerTimes times,
    required int preAlertMinutes,
  }) {
    _times = times;
    _preAlertMinutes = preAlertMinutes.clamp(1, 120);
    _now = DateTime.now();
    notifyListeners();
  }

  void start() {
    _timer?.cancel();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
