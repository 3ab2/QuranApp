import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:quran_app/services/prayer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Prayer schedule computation', () {
    test('keeps same day when prayer time is upcoming', () {
      final now = DateTime(2026, 5, 9, 3, 0);
      final next = PrayerService.computeNextPrayerDateTime(
        now: now,
        prayerTime: '04:30',
      );
      expect(next.year, 2026);
      expect(next.month, 5);
      expect(next.day, 9);
      expect(next.hour, 4);
      expect(next.minute, 30);
    });

    test('rolls over to next day when prayer time already passed', () {
      final now = DateTime(2026, 5, 9, 23, 50);
      final next = PrayerService.computeNextPrayerDateTime(
        now: now,
        prayerTime: '04:30',
      );
      expect(next.year, 2026);
      expect(next.month, 5);
      expect(next.day, 10);
      expect(next.hour, 4);
      expect(next.minute, 30);
    });

    test('parses API time strings with suffix safely', () {
      final now = DateTime(2026, 5, 9, 12, 0);
      final next = PrayerService.computeNextPrayerDateTime(
        now: now,
        prayerTime: '18:30 (+01)',
      );
      expect(next.year, 2026);
      expect(next.month, 5);
      expect(next.day, 9);
      expect(next.hour, 18);
      expect(next.minute, 30);
    });

    test('computes pre-adhan alert exactly five minutes before prayer', () {
      final prayerTime = DateTime(2026, 5, 9, 18, 30);
      final preAlert = PrayerService.computePreAlertDateTime(prayerTime);

      expect(preAlert.year, 2026);
      expect(preAlert.month, 5);
      expect(preAlert.day, 9);
      expect(preAlert.hour, 18);
      expect(preAlert.minute, 25);
    });

    test(
        'keeps pre-adhan alert on previous day for just-after-midnight prayers',
        () {
      final prayerTime = DateTime(2026, 5, 10, 0, 3);
      final preAlert = PrayerService.computePreAlertDateTime(prayerTime);

      expect(preAlert.year, 2026);
      expect(preAlert.month, 5);
      expect(preAlert.day, 9);
      expect(preAlert.hour, 23);
      expect(preAlert.minute, 58);
    });
  });

  group('Adhan audio assets', () {
    test('bundles required offline adhan mp3 files', () async {
      for (final assetPath in const [
        'assets/sounds/adhan/fajr.mp3',
        'assets/sounds/adhan/dhuhr.mp3',
        'assets/sounds/adhan/asr.mp3',
        'assets/sounds/adhan/maghrib.mp3',
        'assets/sounds/adhan/isha.mp3',
        'assets/sounds/adhan/default_adhan.mp3',
      ]) {
        final data = await rootBundle.load(assetPath);
        expect(data.lengthInBytes, greaterThan(1024), reason: assetPath);
      }
    });
  });
}
