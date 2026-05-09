import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran App'**
  String get appTitle;

  /// No description provided for @homeQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get homeQuran;

  /// No description provided for @homeTafsir.
  ///
  /// In en, this message translates to:
  /// **'Tafsir'**
  String get homeTafsir;

  /// No description provided for @homeAudio.
  ///
  /// In en, this message translates to:
  /// **'Recitations'**
  String get homeAudio;

  /// No description provided for @homeStories.
  ///
  /// In en, this message translates to:
  /// **'Prophets Stories'**
  String get homeStories;

  /// No description provided for @homeAdhan.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get homeAdhan;

  /// No description provided for @homeMiracles.
  ///
  /// In en, this message translates to:
  /// **'Miracles'**
  String get homeMiracles;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @topBarAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get topBarAbout;

  /// No description provided for @topBarHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get topBarHelp;

  /// No description provided for @topBarRate.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get topBarRate;

  /// No description provided for @topBarSources.
  ///
  /// In en, this message translates to:
  /// **'Trusted sources'**
  String get topBarSources;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAdhanEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enable Adhan'**
  String get settingsAdhanEnabled;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsPrayerReminder.
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminder'**
  String get settingsPrayerReminder;

  /// No description provided for @settingsSelectReciter.
  ///
  /// In en, this message translates to:
  /// **'Select Reciter'**
  String get settingsSelectReciter;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settingsSelectLanguage;

  /// No description provided for @settingsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get settingsVolume;

  /// No description provided for @settingsClearTempData.
  ///
  /// In en, this message translates to:
  /// **'Clear Temporary Data'**
  String get settingsClearTempData;

  /// No description provided for @settingsTempDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Temporary data deleted'**
  String get settingsTempDataDeleted;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @audioPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Listen to Recitation'**
  String get audioPageTitle;

  /// No description provided for @audioLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load surah audio list.'**
  String get audioLoadError;

  /// No description provided for @audioLocalPlayback.
  ///
  /// In en, this message translates to:
  /// **'Playing from downloaded local file'**
  String get audioLocalPlayback;

  /// No description provided for @audioPlayError.
  ///
  /// In en, this message translates to:
  /// **'Unable to play recitation. No valid local file and no online source available.'**
  String get audioPlayError;

  /// No description provided for @adhanPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Adhan and Prayer Times'**
  String get adhanPageTitle;

  /// No description provided for @adhanLoadingPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Loading prayer times...'**
  String get adhanLoadingPrayerTimes;

  /// No description provided for @adhanLocationNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Location not detected'**
  String get adhanLocationNotDetected;

  /// No description provided for @adhanLocationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap settings to choose location'**
  String get adhanLocationPrompt;

  /// No description provided for @adhanLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Location Settings'**
  String get adhanLocationSettings;

  /// No description provided for @tafsirTitle.
  ///
  /// In en, this message translates to:
  /// **'Al-Muyassar Tafsir'**
  String get tafsirTitle;

  /// No description provided for @tafsirLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading tafsir...'**
  String get tafsirLoading;

  /// No description provided for @tafsirRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get tafsirRetry;

  /// No description provided for @tafsirFetchError.
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch tafsir. Please try again later.'**
  String get tafsirFetchError;

  /// No description provided for @tafsirNetworkError.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Check your internet connection and try again.'**
  String get tafsirNetworkError;

  /// No description provided for @tafsirContextTitle.
  ///
  /// In en, this message translates to:
  /// **'Tafsir - Surah {surah} Ayah {ayah}'**
  String tafsirContextTitle(Object surah, Object ayah);

  /// No description provided for @storyPlay.
  ///
  /// In en, this message translates to:
  /// **'Play story'**
  String get storyPlay;

  /// No description provided for @storyStop.
  ///
  /// In en, this message translates to:
  /// **'Stop audio'**
  String get storyStop;

  /// No description provided for @storyAudioError.
  ///
  /// In en, this message translates to:
  /// **'Unable to play story audio.'**
  String get storyAudioError;

  /// No description provided for @storyNoAudio.
  ///
  /// In en, this message translates to:
  /// **'No narration available for this story'**
  String get storyNoAudio;

  /// No description provided for @storyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Stories are unavailable right now.'**
  String get storyLoadError;

  /// No description provided for @storyRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get storyRetry;

  /// No description provided for @storyReadDone.
  ///
  /// In en, this message translates to:
  /// **'Read completed'**
  String get storyReadDone;

  /// No description provided for @surahSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search verses...'**
  String get surahSearchHint;

  /// No description provided for @surahIncreaseFont.
  ///
  /// In en, this message translates to:
  /// **'Increase Font Size'**
  String get surahIncreaseFont;

  /// No description provided for @surahDecreaseFont.
  ///
  /// In en, this message translates to:
  /// **'Decrease Font Size'**
  String get surahDecreaseFont;

  /// No description provided for @surahOpenTafsir.
  ///
  /// In en, this message translates to:
  /// **'Open Tafsir'**
  String get surahOpenTafsir;

  /// No description provided for @tafsirUnavailableForAyah.
  ///
  /// In en, this message translates to:
  /// **'Tafsir is not available for this context.'**
  String get tafsirUnavailableForAyah;

  /// No description provided for @surahOpenTafsirCurrentAyah.
  ///
  /// In en, this message translates to:
  /// **'Open tafsir for selected ayah'**
  String get surahOpenTafsirCurrentAyah;

  /// No description provided for @tafsirSourceMuyassarNote.
  ///
  /// In en, this message translates to:
  /// **'Primary text: Arabic Al-Muyassar (Quran.com). More editions later.'**
  String get tafsirSourceMuyassarNote;

  /// No description provided for @tafsirSelectSurah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get tafsirSelectSurah;

  /// No description provided for @tafsirBrowseSurahs.
  ///
  /// In en, this message translates to:
  /// **'Surahs'**
  String get tafsirBrowseSurahs;

  /// No description provided for @tafsirAyahNumber.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get tafsirAyahNumber;

  /// No description provided for @tafsirGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get tafsirGo;

  /// No description provided for @tafsirSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Ayah, tafsir, surah, or scientific topic…'**
  String get tafsirSearchHint;

  /// No description provided for @tafsirSearchCacheHint.
  ///
  /// In en, this message translates to:
  /// **'Tafsir search includes this page, cached surahs, and miracle topics.'**
  String get tafsirSearchCacheHint;

  /// No description provided for @tafsirSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No results. Try different words or open a surah to load its tafsir.'**
  String get tafsirSearchEmpty;

  /// No description provided for @tafsirJumpInvalidAyah.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid ayah number for this surah.'**
  String get tafsirJumpInvalidAyah;

  /// No description provided for @tafsirJumpNotInFeed.
  ///
  /// In en, this message translates to:
  /// **'This ayah is not in the current list. It may be missing from the source for this surah.'**
  String get tafsirJumpNotInFeed;

  /// No description provided for @miraclesOpenTafsir.
  ///
  /// In en, this message translates to:
  /// **'Open Al-Muyassar tafsir'**
  String get miraclesOpenTafsir;

  /// No description provided for @miraclesContinueInTafsirPage.
  ///
  /// In en, this message translates to:
  /// **'Continue reading on the Tafsir page'**
  String get miraclesContinueInTafsirPage;

  /// No description provided for @miraclesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get miraclesLoading;

  /// No description provided for @miraclesTafsirPreview.
  ///
  /// In en, this message translates to:
  /// **'Tafsir preview'**
  String get miraclesTafsirPreview;

  /// No description provided for @miraclesModerateNote.
  ///
  /// In en, this message translates to:
  /// **'Short educational notes only; consult qualified scholars for creed and law.'**
  String get miraclesModerateNote;

  /// No description provided for @quranContinueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get quranContinueReading;

  /// No description provided for @quranBookmarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Reading position saved.'**
  String get quranBookmarkSaved;

  /// No description provided for @quranSurahPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Find surah…'**
  String get quranSurahPickerHint;

  /// No description provided for @quranSurahNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get quranSurahNumberLabel;

  /// No description provided for @quranMadaniShort.
  ///
  /// In en, this message translates to:
  /// **'Madani'**
  String get quranMadaniShort;

  /// No description provided for @quranMakkiShort.
  ///
  /// In en, this message translates to:
  /// **'Makki'**
  String get quranMakkiShort;

  /// No description provided for @quranSearchClose.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get quranSearchClose;

  /// No description provided for @quranSearchOpen.
  ///
  /// In en, this message translates to:
  /// **'Search Quran'**
  String get quranSearchOpen;

  /// No description provided for @quranSaveBookmark.
  ///
  /// In en, this message translates to:
  /// **'Save reading position'**
  String get quranSaveBookmark;

  /// No description provided for @quranLineSpacingIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase line spacing'**
  String get quranLineSpacingIncrease;

  /// No description provided for @quranLineSpacingDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease line spacing'**
  String get quranLineSpacingDecrease;

  /// No description provided for @quranMushafModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Mushaf layout (coming soon)'**
  String get quranMushafModeToggle;

  /// No description provided for @quranReaderSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Ayah text, surah name, or number…'**
  String get quranReaderSearchHint;

  /// No description provided for @quranSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matches. Try other words or a surah number.'**
  String get quranSearchEmpty;

  /// No description provided for @quranBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get quranBackToHome;

  /// No description provided for @tilawatDownloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Surah saved for offline listening.'**
  String get tilawatDownloadComplete;

  /// No description provided for @tilawatDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Check your connection.'**
  String get tilawatDownloadFailed;

  /// No description provided for @tilawatDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get tilawatDownloaded;

  /// No description provided for @tilawatDownloadForOffline.
  ///
  /// In en, this message translates to:
  /// **'Download for offline'**
  String get tilawatDownloadForOffline;

  /// No description provided for @tilawatAutoPlayNext.
  ///
  /// In en, this message translates to:
  /// **'Auto-play next surah'**
  String get tilawatAutoPlayNext;

  /// No description provided for @tilawatSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get tilawatSleepTimer;

  /// No description provided for @tilawatSleepOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get tilawatSleepOff;

  /// No description provided for @tilawatSleepMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String tilawatSleepMinutes(int minutes);

  /// No description provided for @tilawatSleepEndsAt.
  ///
  /// In en, this message translates to:
  /// **'Playback stops around {time}'**
  String tilawatSleepEndsAt(String time);

  /// No description provided for @tilawatContinueListening.
  ///
  /// In en, this message translates to:
  /// **'Continue listening'**
  String get tilawatContinueListening;

  /// No description provided for @tilawatTooltipSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer — choose when playback stops'**
  String get tilawatTooltipSleepTimer;

  /// No description provided for @tilawatTooltipDownload.
  ///
  /// In en, this message translates to:
  /// **'Download for offline listening'**
  String get tilawatTooltipDownload;

  /// No description provided for @tilawatTooltipAutoNext.
  ///
  /// In en, this message translates to:
  /// **'Automatically play the next surah'**
  String get tilawatTooltipAutoNext;

  /// No description provided for @tilawatTooltipRepeatOne.
  ///
  /// In en, this message translates to:
  /// **'Repeat this surah'**
  String get tilawatTooltipRepeatOne;

  /// No description provided for @tilawatReciterFallbackNotice.
  ///
  /// In en, this message translates to:
  /// **'Reciter audio not available. Switching to default reciter ({name}).'**
  String tilawatReciterFallbackNotice(String name);

  /// No description provided for @tilawatSleepChooseDuration.
  ///
  /// In en, this message translates to:
  /// **'Choose duration'**
  String get tilawatSleepChooseDuration;

  /// No description provided for @tilawatSleepOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get tilawatSleepOneHour;

  /// No description provided for @tilawatSleepOneHourThirty.
  ///
  /// In en, this message translates to:
  /// **'1 hour 30 minutes'**
  String get tilawatSleepOneHourThirty;

  /// No description provided for @tilawatSleepTwoHours.
  ///
  /// In en, this message translates to:
  /// **'2 hours'**
  String get tilawatSleepTwoHours;

  /// No description provided for @tilawatSleepActiveRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min remaining'**
  String tilawatSleepActiveRemaining(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
