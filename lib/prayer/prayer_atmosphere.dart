import 'package:flutter/material.dart';
import 'package:quran_app/prayer/prayer_timeline.dart';

/// Subtle gradient tokens for the prayer dashboard (low GPU cost).
class PrayerAtmosphere {
  final List<Color> gradient;
  final Color accent;

  const PrayerAtmosphere({
    required this.gradient,
    required this.accent,
  });

  static PrayerAtmosphere forSlot(String nameAr, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    switch (nameAr) {
      case 'الفجر':
        return PrayerAtmosphere(
          gradient: [
            const Color(0xFF0B1B33),
            const Color(0xFF1E3A5F),
            if (isDark) const Color(0xFF0D1520) else const Color(0xFFE8F0FA),
          ],
          accent: const Color(0xFF7EB6FF),
        );
      case 'المغرب':
        return PrayerAtmosphere(
          gradient: [
            const Color(0xFF2A1410),
            const Color(0xFF5C2E18),
            if (isDark) const Color(0xFF120A08) else const Color(0xFFFFE8D6),
          ],
          accent: const Color(0xFFFFB088),
        );
      case 'العشاء':
        return PrayerAtmosphere(
          gradient: [
            const Color(0xFF0A0E18),
            const Color(0xFF151C2E),
            if (isDark) const Color(0xFF050608) else const Color(0xFFE4E8F2),
          ],
          accent: const Color(0xFFB8A9E8),
        );
      default:
        return PrayerAtmosphere(
          gradient: [
            const Color(0xFF132018),
            const Color(0xFF1E2E24),
            if (isDark) const Color(0xFF0A100C) else const Color(0xFFE6EDE8),
          ],
          accent: const Color(0xFF8BC9A3),
        );
    }
  }

  static PrayerAtmosphere fromSnapshot(
    PrayerDashboardSnapshot s,
    Brightness brightness,
  ) {
    return forSlot(s.nextPrayer.nameAr, brightness);
  }
}
