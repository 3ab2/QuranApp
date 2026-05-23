import 'package:timezone/timezone.dart' as tz;

/// Cross-platform-safe prayer instant math in [tz.local] (set by [PrayerService]).
///
/// Never use `DateTime(y, m, d, h, min)` for prayer wall-clock here: on Android it
/// follows the **device** zone, while prayer API strings are in **tz.local**
/// (manual city TZ or device TZ). Mixing the two breaks pre-prayer reminders.
///
/// iOS: keep using the same helpers when wiring UNCalendarNotificationTrigger so
/// wall-clock math stays identical to Android scheduling.
class PrayerScheduleUtil {
  PrayerScheduleUtil._();

  static final RegExp _timePart = RegExp(r'(\d{1,2}):(\d{2})');

  /// Next occurrence of [prayerTime] (e.g. `04:30` or `18:30 (+01)`) on or after [now].
  static tz.TZDateTime nextPrayerInstantTz({
    required DateTime now,
    required String prayerTime,
  }) {
    final tzNow = now is tz.TZDateTime ? now : tz.TZDateTime.from(now, tz.local);
    final match = _timePart.firstMatch(prayerTime);
    final hour = int.tryParse(match?.group(1) ?? '') ?? 0;
    final minute = int.tryParse(match?.group(2) ?? '') ?? 0;
    var candidate = tz.TZDateTime(
      tz.local,
      tzNow.year,
      tzNow.month,
      tzNow.day,
      hour,
      minute,
    );
    if (!candidate.isAfter(tzNow)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  static tz.TZDateTime preAlertInstant({
    required DateTime prayerInstant,
    Duration lead = const Duration(minutes: 5),
  }) {
    final p =
        prayerInstant is tz.TZDateTime ? prayerInstant : tz.TZDateTime.from(prayerInstant, tz.local);
    return p.subtract(lead);
  }
}
