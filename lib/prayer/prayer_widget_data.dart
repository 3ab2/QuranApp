import 'package:quran_app/prayer/prayer_timeline.dart';

/// Serializable snapshot for future home / lock-screen widgets (Android/iOS).
class PrayerWidgetData {
  final String cityLine;
  final String currentNameAr;
  final String nextNameAr;
  final String nextNameEn;
  final String nextAtIso;
  final String remainingHms;

  const PrayerWidgetData({
    required this.cityLine,
    required this.currentNameAr,
    required this.nextNameAr,
    required this.nextNameEn,
    required this.nextAtIso,
    required this.remainingHms,
  });

  Map<String, dynamic> toJson() => {
        'cityLine': cityLine,
        'currentNameAr': currentNameAr,
        'nextNameAr': nextNameAr,
        'nextNameEn': nextNameEn,
        'nextAtIso': nextAtIso,
        'remainingHms': remainingHms,
      };

  static PrayerWidgetData? build({
    required PrayerDashboardSnapshot snapshot,
    required String cityLine,
    required DateTime now,
  }) {
    final r = snapshot.remaining;
    final h = r.inHours;
    final m = r.inMinutes.remainder(60);
    final s = r.inSeconds.remainder(60);
    final hms =
        '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return PrayerWidgetData(
      cityLine: cityLine,
      currentNameAr: snapshot.currentPeriod.nameAr,
      nextNameAr: snapshot.nextPrayer.nameAr,
      nextNameEn: snapshot.nextPrayer.nameEn,
      nextAtIso: snapshot.nextPrayerAt.toIso8601String(),
      remainingHms: now.isBefore(snapshot.nextPrayerAt) ? hms : '00:00:00',
    );
  }
}
