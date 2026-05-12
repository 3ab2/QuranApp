import 'package:flutter/foundation.dart';

/// Optional “mosque mode”: reserved for future platform integration (DND / audio
/// ducking). Calling this is safe on all platforms — today it only logs in debug.
class MosqueModeController {
  MosqueModeController._();

  static String? _lastApproachSignature;

  /// Called when the UI enters the pre-prayer “approaching” window (at most once
  /// per prayer per local day).
  static Future<void> onApproachingPrayerWindow({
    required bool enabled,
    required String nextPrayerNameAr,
    required DateTime now,
  }) async {
    if (!enabled) return;
    final day = '${now.year}-${now.month}-${now.day}';
    final sig = '$day|$nextPrayerNameAr';
    if (_lastApproachSignature == sig) return;
    _lastApproachSignature = sig;
    if (kDebugMode) {
      debugPrint(
        'Mosque mode (reserved): approaching $nextPrayerNameAr — '
        'native silence/DND hooks not wired in this build.',
      );
    }
  }

  static void resetApproachSignatureForTests() {
    _lastApproachSignature = null;
  }
}
