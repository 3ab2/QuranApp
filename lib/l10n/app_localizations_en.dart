// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Quran App';

  @override
  String get homeQuran => 'Quran';

  @override
  String get homeTafsir => 'Tafsir';

  @override
  String get homeAudio => 'Recitations';

  @override
  String get homeStories => 'Prophets Stories';

  @override
  String get homeAdhan => 'Adhan';

  @override
  String get homeMiracles => 'Miracles';

  @override
  String get homeSettings => 'Settings';

  @override
  String get topBarAbout => 'About';

  @override
  String get topBarHelp => 'Help';

  @override
  String get topBarRate => 'Rate us';

  @override
  String get topBarSources => 'Trusted sources';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAdhanEnabled => 'Enable Adhan';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsPrayerReminder => 'Prayer Reminder';

  @override
  String get settingsSelectReciter => 'Select Reciter';

  @override
  String get settingsSelectLanguage => 'Select Language';

  @override
  String get settingsVolume => 'Volume';

  @override
  String get settingsClearTempData => 'Clear Temporary Data';

  @override
  String get settingsTempDataDeleted => 'Temporary data deleted';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get audioPageTitle => 'Listen to Recitation';

  @override
  String get audioLoadError => 'Unable to load surah audio list.';

  @override
  String get audioLocalPlayback => 'Playing from downloaded local file';

  @override
  String get audioPlayError =>
      'Unable to play recitation. No valid local file and no online source available.';

  @override
  String get adhanPageTitle => 'Adhan and Prayer Times';

  @override
  String get adhanLoadingPrayerTimes => 'Loading prayer times...';

  @override
  String get adhanLocationNotDetected => 'Location not detected';

  @override
  String get adhanLocationPrompt => 'Tap settings to choose location';

  @override
  String get adhanLocationSettings => 'Location Settings';

  @override
  String get tafsirTitle => 'Al-Muyassar Tafsir';

  @override
  String get tafsirLoading => 'Loading tafsir...';

  @override
  String get tafsirRetry => 'Retry';

  @override
  String get tafsirFetchError =>
      'Unable to fetch tafsir. Please try again later.';

  @override
  String get tafsirNetworkError =>
      'A network error occurred. Check your internet connection and try again.';

  @override
  String tafsirContextTitle(Object surah, Object ayah) {
    return 'Tafsir - Surah $surah Ayah $ayah';
  }

  @override
  String get storyPlay => 'Play story';

  @override
  String get storyStop => 'Stop audio';

  @override
  String get storyAudioError => 'Unable to play story audio.';

  @override
  String get storyNoAudio => 'No narration available for this story';

  @override
  String get storyLoadError => 'Stories are unavailable right now.';

  @override
  String get storyRetry => 'Retry';

  @override
  String get storyReadDone => 'Read completed';

  @override
  String get surahSearchHint => 'Search verses...';

  @override
  String get surahIncreaseFont => 'Increase Font Size';

  @override
  String get surahDecreaseFont => 'Decrease Font Size';

  @override
  String get surahOpenTafsir => 'Open Tafsir';

  @override
  String get tafsirUnavailableForAyah =>
      'Tafsir is not available for this context.';

  @override
  String get surahOpenTafsirCurrentAyah => 'Open tafsir for selected ayah';

  @override
  String get tafsirSourceMuyassarNote =>
      'Primary text: Arabic Al-Muyassar (Quran.com). More editions later.';

  @override
  String get tafsirSelectSurah => 'Surah';

  @override
  String get tafsirBrowseSurahs => 'Surahs';

  @override
  String get tafsirAyahNumber => 'Ayah';

  @override
  String get tafsirGo => 'Go';

  @override
  String get tafsirSearchHint => 'Ayah, tafsir, surah, or scientific topic…';

  @override
  String get tafsirSearchCacheHint =>
      'Tafsir search includes this page, cached surahs, and miracle topics.';

  @override
  String get tafsirSearchEmpty =>
      'No results. Try different words or open a surah to load its tafsir.';

  @override
  String get tafsirJumpInvalidAyah =>
      'Enter a valid ayah number for this surah.';

  @override
  String get tafsirJumpNotInFeed =>
      'This ayah is not in the current list. It may be missing from the source for this surah.';

  @override
  String get miraclesOpenTafsir => 'Open Al-Muyassar tafsir';

  @override
  String get miraclesContinueInTafsirPage =>
      'Continue reading on the Tafsir page';

  @override
  String get miraclesLoading => 'Loading…';

  @override
  String get miraclesTafsirPreview => 'Tafsir preview';

  @override
  String get miraclesModerateNote =>
      'Short educational notes only; consult qualified scholars for creed and law.';

  @override
  String get quranContinueReading => 'Continue';

  @override
  String get quranBookmarkSaved => 'Reading position saved.';

  @override
  String get quranSurahPickerHint => 'Find surah…';

  @override
  String get quranSurahNumberLabel => 'Surah';

  @override
  String get quranMadaniShort => 'Madani';

  @override
  String get quranMakkiShort => 'Makki';

  @override
  String get quranSearchClose => 'Close search';

  @override
  String get quranSearchOpen => 'Search Quran';

  @override
  String get quranSaveBookmark => 'Save reading position';

  @override
  String get quranLineSpacingIncrease => 'Increase line spacing';

  @override
  String get quranLineSpacingDecrease => 'Decrease line spacing';

  @override
  String get quranMushafModeToggle => 'Mushaf layout (coming soon)';

  @override
  String get quranReaderSearchHint => 'Ayah text, surah name, or number…';

  @override
  String get quranSearchEmpty =>
      'No matches. Try other words or a surah number.';

  @override
  String get quranBackToHome => 'Home';

  @override
  String get tilawatDownloadComplete => 'Surah saved for offline listening.';

  @override
  String get tilawatDownloadFailed => 'Download failed. Check your connection.';

  @override
  String get tilawatDownloaded => 'Downloaded';

  @override
  String get tilawatDownloadForOffline => 'Download for offline';

  @override
  String get tilawatAutoPlayNext => 'Auto-play next surah';

  @override
  String get tilawatSleepTimer => 'Sleep timer';

  @override
  String get tilawatSleepOff => 'Off';

  @override
  String tilawatSleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String tilawatSleepEndsAt(String time) {
    return 'Playback stops around $time';
  }

  @override
  String get tilawatContinueListening => 'Continue listening';

  @override
  String get tilawatTooltipSleepTimer =>
      'Sleep timer — choose when playback stops';

  @override
  String get tilawatTooltipDownload => 'Download for offline listening';

  @override
  String get tilawatTooltipAutoNext => 'Automatically play the next surah';

  @override
  String get tilawatTooltipRepeatOne => 'Repeat this surah';

  @override
  String tilawatReciterFallbackNotice(String name) {
    return 'Reciter audio not available. Switching to default reciter ($name).';
  }

  @override
  String get tilawatSleepChooseDuration => 'Choose duration';

  @override
  String get tilawatSleepOneHour => '1 hour';

  @override
  String get tilawatSleepOneHourThirty => '1 hour 30 minutes';

  @override
  String get tilawatSleepTwoHours => '2 hours';

  @override
  String tilawatSleepActiveRemaining(int minutes) {
    return '$minutes min remaining';
  }
}
