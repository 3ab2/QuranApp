/// Shared [SharedPreferences] keys for tilawat playback (UI + background handler).
abstract final class TilawatPlaybackKeys {
  static const lastSurahIndex = 'lastSurah';
  static const lastPositionMs = 'lastPosition';
  static const autoPlayNext = 'tilawat_autoPlayNext';
  static const repeatCurrentSurah = 'tilawat_repeatCurrent';
  /// Wall-clock end time for sleep timer; absent or 0 means off.
  static const sleepEndsAtEpochMs = 'tilawat_sleepEndsAtEpochMs';
}
