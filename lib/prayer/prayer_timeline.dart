import 'package:quran_app/models/prayer_model.dart';
import 'package:quran_app/prayer/prayer_schedule_util.dart';

/// Same calendar rule as [PrayerScheduleUtil.nextPrayerInstantTz].
DateTime _nextPrayerOccurrence({
  required DateTime now,
  required String prayerTime,
}) {
  return PrayerScheduleUtil.nextPrayerInstantTz(now: now, prayerTime: prayerTime);
}

/// Live prayer dashboard state derived from [PrayerTimes] and clock.
enum PrayerUrgencyPhase {
  /// More than [preAlertMinutes] before the next prayer.
  calm,

  /// Within the pre-alert window before the next prayer.
  approaching,

  /// At or shortly after the adhan moment for the upcoming prayer.
  atAdhan,

  /// Grace window after adhan (optional UX copy).
  grace,
}

class PrayerSlot {
  final String nameAr;
  final String nameEn;
  final String timeRaw;

  const PrayerSlot({
    required this.nameAr,
    required this.nameEn,
    required this.timeRaw,
  });
}

class PrayerDashboardSnapshot {
  final PrayerSlot currentPeriod;
  final PrayerSlot nextPrayer;
  final DateTime nextPrayerAt;
  final Duration remaining;
  final PrayerUrgencyPhase phase;
  final int preAlertMinutes;

  const PrayerDashboardSnapshot({
    required this.currentPeriod,
    required this.nextPrayer,
    required this.nextPrayerAt,
    required this.remaining,
    required this.phase,
    required this.preAlertMinutes,
  });
}

/// Ordered fard slots (no sunrise).
List<PrayerSlot> fardSlotsOrdered(PrayerTimes t) {
  return [
    PrayerSlot(nameAr: 'الفجر', nameEn: 'Fajr', timeRaw: t.fajr),
    PrayerSlot(nameAr: 'الظهر', nameEn: 'Dhuhr', timeRaw: t.dhuhr),
    PrayerSlot(nameAr: 'العصر', nameEn: 'Asr', timeRaw: t.asr),
    PrayerSlot(nameAr: 'المغرب', nameEn: 'Maghrib', timeRaw: t.maghrib),
    PrayerSlot(nameAr: 'العشاء', nameEn: 'Isha', timeRaw: t.isha),
  ];
}

PrayerDashboardSnapshot computePrayerDashboard({
  required DateTime now,
  required PrayerTimes times,
  required int preAlertMinutes,
}) {
  final slots = fardSlotsOrdered(times);
  final lead = Duration(minutes: preAlertMinutes.clamp(1, 120));
  const graceAfterAdhan = Duration(minutes: 45);

  DateTime? bestNext;
  PrayerSlot? bestSlot;

  for (final s in slots) {
    final t = _nextPrayerOccurrence(now: now, prayerTime: s.timeRaw);
    final cur = bestNext;
    if (cur == null || t.isBefore(cur)) {
      bestNext = t;
      bestSlot = s;
    }
  }

  final bn = bestNext ?? now;
  final bs = bestSlot ?? slots.first;

  final idxNext = slots.indexOf(bs);
  final idxCur = (idxNext - 1 + slots.length) % slots.length;
  final current = slots[idxCur];

  final rawRemaining = bn.difference(now);
  final remaining = rawRemaining.isNegative ? Duration.zero : rawRemaining;

  final PrayerUrgencyPhase phase;
  if (now.isBefore(bn)) {
    if (bn.difference(now) > lead) {
      phase = PrayerUrgencyPhase.calm;
    } else {
      phase = PrayerUrgencyPhase.approaching;
    }
  } else if (now.isBefore(bn.add(graceAfterAdhan))) {
    phase = PrayerUrgencyPhase.atAdhan;
  } else {
    phase = PrayerUrgencyPhase.grace;
  }

  return PrayerDashboardSnapshot(
    currentPeriod: current,
    nextPrayer: bs,
    nextPrayerAt: bn,
    remaining: remaining,
    phase: phase,
    preAlertMinutes: preAlertMinutes.clamp(1, 120),
  );
}
