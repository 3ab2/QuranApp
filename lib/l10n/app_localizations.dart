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
  /// **'Quran Noor — Quran, Adhan & Duas'**
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

  /// No description provided for @storyPauseAudio.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get storyPauseAudio;

  /// No description provided for @playbackSpeedSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get playbackSpeedSheetTitle;

  /// No description provided for @storyYoutubeStreamUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not start the narration stream. Check your connection and try again.'**
  String get storyYoutubeStreamUnavailable;

  /// No description provided for @storyYoutubeWebAudioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Story narration in the background is not available in the web browser. Use the app on a phone or tablet for full playback.'**
  String get storyYoutubeWebAudioUnavailable;

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

  /// No description provided for @prophetStoriesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by prophet name or story…'**
  String get prophetStoriesSearchHint;

  /// No description provided for @prophetStoriesSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No prophet stories match. Try different words.'**
  String get prophetStoriesSearchEmpty;

  /// No description provided for @prophetStoriesSearchOpenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search stories'**
  String get prophetStoriesSearchOpenTooltip;

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

  /// No description provided for @miraclesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Scientific miracles in the Qur\'an'**
  String get miraclesPageTitle;

  /// No description provided for @miraclesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search verse, topic, or scientific explanation…'**
  String get miraclesSearchHint;

  /// No description provided for @miraclesEmptyResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get miraclesEmptyResults;

  /// No description provided for @miraclesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get miraclesFilterAll;

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

  /// No description provided for @storyYoutubePlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Story narration'**
  String get storyYoutubePlayerTitle;

  /// No description provided for @storyYoutubeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No verified YouTube narration is linked for this story yet.'**
  String get storyYoutubeUnavailable;

  /// No description provided for @storyYoutubeInvalidChannel.
  ///
  /// In en, this message translates to:
  /// **'This video is not from an approved channel.'**
  String get storyYoutubeInvalidChannel;

  /// No description provided for @storyYoutubeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the YouTube player. Check your connection and try again.'**
  String get storyYoutubeLoadError;

  /// No description provided for @storyYoutubeNarrator.
  ///
  /// In en, this message translates to:
  /// **'Narrator'**
  String get storyYoutubeNarrator;

  /// No description provided for @storyYoutubePrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous story'**
  String get storyYoutubePrevious;

  /// No description provided for @storyYoutubeNext.
  ///
  /// In en, this message translates to:
  /// **'Next story'**
  String get storyYoutubeNext;

  /// No description provided for @storyYoutubeBackgroundHint.
  ///
  /// In en, this message translates to:
  /// **'Background playback depends on your device; keep the app in recent apps for best results.'**
  String get storyYoutubeBackgroundHint;

  /// No description provided for @storyYoutubeOpenPlayer.
  ///
  /// In en, this message translates to:
  /// **'Listen to the story'**
  String get storyYoutubeOpenPlayer;

  /// No description provided for @storyYoutubeNoNarration.
  ///
  /// In en, this message translates to:
  /// **'No narration available for this story.'**
  String get storyYoutubeNoNarration;

  /// No description provided for @storyYoutubeSleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get storyYoutubeSleepTimer;

  /// No description provided for @storyYoutubeSleepOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get storyYoutubeSleepOff;

  /// No description provided for @storyYoutubeSleepMinutes.
  ///
  /// In en, this message translates to:
  /// **'Stop after {minutes} min'**
  String storyYoutubeSleepMinutes(int minutes);

  /// No description provided for @storyYoutubeSleepEnded.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer stopped playback.'**
  String get storyYoutubeSleepEnded;

  /// No description provided for @storyYoutubePlaybackSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'{speed}x'**
  String storyYoutubePlaybackSpeedLabel(String speed);

  /// No description provided for @storyYoutubeCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy video link'**
  String get storyYoutubeCopyLink;

  /// No description provided for @storyYoutubeLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'YouTube link copied to clipboard.'**
  String get storyYoutubeLinkCopied;

  /// No description provided for @storyYoutubeFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Fullscreen'**
  String get storyYoutubeFullscreen;

  /// No description provided for @storyYoutubeDownloadHint.
  ///
  /// In en, this message translates to:
  /// **'Use the link icon to copy the watch URL. Offline download of YouTube video is not available in this app.'**
  String get storyYoutubeDownloadHint;

  /// No description provided for @prayerPhaseCalm.
  ///
  /// In en, this message translates to:
  /// **'Next prayer'**
  String get prayerPhaseCalm;

  /// No description provided for @prayerPhaseApproaching.
  ///
  /// In en, this message translates to:
  /// **'Prayer is approaching'**
  String get prayerPhaseApproaching;

  /// No description provided for @prayerPhaseAtAdhan.
  ///
  /// In en, this message translates to:
  /// **'It is now time for prayer'**
  String get prayerPhaseAtAdhan;

  /// No description provided for @prayerPhaseGrace.
  ///
  /// In en, this message translates to:
  /// **'Take this moment with calm'**
  String get prayerPhaseGrace;

  /// No description provided for @prayerCountdownRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {hms}'**
  String prayerCountdownRemaining(String hms);

  /// No description provided for @prayerCurrentPeriod.
  ///
  /// In en, this message translates to:
  /// **'Current period: {name}'**
  String prayerCurrentPeriod(String name);

  /// No description provided for @prayerAtAdhanMoment.
  ///
  /// In en, this message translates to:
  /// **'The adhan moment — refocus gently on Allah'**
  String get prayerAtAdhanMoment;

  /// No description provided for @prayerOpenQibla.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get prayerOpenQibla;

  /// No description provided for @prayerAdhanStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get prayerAdhanStop;

  /// No description provided for @prayerAdhanSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get prayerAdhanSnooze;

  /// No description provided for @prayerAdhanMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get prayerAdhanMute;

  /// No description provided for @prayerAdhanUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get prayerAdhanUnmute;

  /// No description provided for @prayerImmersiveHint.
  ///
  /// In en, this message translates to:
  /// **'Soft motion only — designed for a peaceful heart'**
  String get prayerImmersiveHint;

  /// No description provided for @prayerQiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get prayerQiblaTitle;

  /// No description provided for @prayerQiblaWebUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Live compass qibla uses device sensors and is available in the mobile app.'**
  String get prayerQiblaWebUnavailable;

  /// No description provided for @prayerQiblaLocationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Enable location services and grant permission to use the compass qibla.'**
  String get prayerQiblaLocationDisabled;

  /// No description provided for @prayerQiblaError.
  ///
  /// In en, this message translates to:
  /// **'Could not read compass data on this device.'**
  String get prayerQiblaError;

  /// No description provided for @prayerQiblaEmulatorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Live compass sensors are unavailable on this device or emulator. Use the static Qibla guide below.'**
  String get prayerQiblaEmulatorUnavailable;

  /// No description provided for @prayerQiblaDistanceKm.
  ///
  /// In en, this message translates to:
  /// **'About {km} km to the Kaaba'**
  String prayerQiblaDistanceKm(String km);

  /// No description provided for @prayerQiblaAlignedHint.
  ///
  /// In en, this message translates to:
  /// **'You are aligned — may Allah accept your prayer'**
  String get prayerQiblaAlignedHint;

  /// No description provided for @prayerQiblaRotateHint.
  ///
  /// In en, this message translates to:
  /// **'Turn slowly until the needle steadies toward the Kaaba'**
  String get prayerQiblaRotateHint;

  /// No description provided for @prayerQiblaFallbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla direction from your location'**
  String get prayerQiblaFallbackSubtitle;

  /// No description provided for @prayerQiblaFallbackExplanation.
  ///
  /// In en, this message translates to:
  /// **'The live compass needs your phone\'s magnetic and direction sensors. It works fully inside the mobile app.'**
  String get prayerQiblaFallbackExplanation;

  /// No description provided for @prayerQiblaFallbackBrowserNote.
  ///
  /// In en, this message translates to:
  /// **'Web and desktop browsers often cannot access the sensors needed for a live compass.'**
  String get prayerQiblaFallbackBrowserNote;

  /// No description provided for @prayerQiblaFallbackStaticHint.
  ///
  /// In en, this message translates to:
  /// **'Approximate Qibla from your saved location'**
  String get prayerQiblaFallbackStaticHint;

  /// No description provided for @prayerQiblaFallbackAngle.
  ///
  /// In en, this message translates to:
  /// **'Qibla bearing: {angle} from north'**
  String prayerQiblaFallbackAngle(String angle);

  /// No description provided for @prayerQiblaFallbackLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get prayerQiblaFallbackLocationTitle;

  /// No description provided for @prayerQiblaFallbackLocationUnknown.
  ///
  /// In en, this message translates to:
  /// **'Location not set yet'**
  String get prayerQiblaFallbackLocationUnknown;

  /// No description provided for @prayerQiblaFallbackLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Set your city on the Prayer page to see the Qibla angle for where you are.'**
  String get prayerQiblaFallbackLocationHint;

  /// No description provided for @prayerQiblaFallbackKaabaTitle.
  ///
  /// In en, this message translates to:
  /// **'Toward the Kaaba'**
  String get prayerQiblaFallbackKaabaTitle;

  /// No description provided for @prayerQiblaFallbackMobileTitle.
  ///
  /// In en, this message translates to:
  /// **'Live compass on mobile'**
  String get prayerQiblaFallbackMobileTitle;

  /// No description provided for @prayerQiblaFallbackMobileBody.
  ///
  /// In en, this message translates to:
  /// **'Open this app on your phone for a real-time compass that follows your movement toward the Qibla.'**
  String get prayerQiblaFallbackMobileBody;

  /// No description provided for @prayerQiblaFallbackDragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag gently to explore — release to realign with Qibla'**
  String get prayerQiblaFallbackDragHint;

  /// No description provided for @prayerQiblaFallbackInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla at a glance'**
  String get prayerQiblaFallbackInfoTitle;

  /// No description provided for @prayerQiblaFallbackAngleLabel.
  ///
  /// In en, this message translates to:
  /// **'Qibla angle'**
  String get prayerQiblaFallbackAngleLabel;

  /// No description provided for @prayerQiblaFallbackDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'To Kaaba'**
  String get prayerQiblaFallbackDistanceLabel;

  /// No description provided for @prayerQiblaFallbackHeadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Compass mode'**
  String get prayerQiblaFallbackHeadingLabel;

  /// No description provided for @prayerQiblaFallbackHeadingValue.
  ///
  /// In en, this message translates to:
  /// **'Static guide'**
  String get prayerQiblaFallbackHeadingValue;

  /// No description provided for @prayerSettingsReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder before prayer'**
  String get prayerSettingsReminder;

  /// No description provided for @prayerReminderEnabledHelp.
  ///
  /// In en, this message translates to:
  /// **'A simple notification a few minutes before each prayer so you can prepare.'**
  String get prayerReminderEnabledHelp;

  /// No description provided for @prayerAdhanEnabledHelp.
  ///
  /// In en, this message translates to:
  /// **'Notification at the exact prayer time and manual adhan playback from the prayer list.'**
  String get prayerAdhanEnabledHelp;

  /// No description provided for @prayerReminderPreset5.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get prayerReminderPreset5;

  /// No description provided for @prayerReminderPreset10.
  ///
  /// In en, this message translates to:
  /// **'10 min'**
  String get prayerReminderPreset10;

  /// No description provided for @prayerReminderPreset15.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get prayerReminderPreset15;

  /// No description provided for @prayerReminderCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Custom (1–120 min)'**
  String get prayerReminderCustomHint;

  /// No description provided for @prayerMuezzinVoice.
  ///
  /// In en, this message translates to:
  /// **'Muezzin / Adhan voice'**
  String get prayerMuezzinVoice;

  /// No description provided for @prayerPreviewVoice.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get prayerPreviewVoice;

  /// No description provided for @prayerMosqueMode.
  ///
  /// In en, this message translates to:
  /// **'Mosque mode (experimental)'**
  String get prayerMosqueMode;

  /// No description provided for @prayerMosqueModeHelp.
  ///
  /// In en, this message translates to:
  /// **'When enabled, a reserved hook runs in the approaching window. Full silent/DND requires future OS integration.'**
  String get prayerMosqueModeHelp;

  /// No description provided for @prayerAfterAdhkar.
  ///
  /// In en, this message translates to:
  /// **'After prayer — short dhikr'**
  String get prayerAfterAdhkar;

  /// No description provided for @prayerAfterAdhkarBody.
  ///
  /// In en, this message translates to:
  /// **'Say subhanAllah (33), alhamdulillah (33), Allahu akbar (33) — or recite Ayat al-Kursi with calm.'**
  String get prayerAfterAdhkarBody;

  /// No description provided for @prayerSpiritualTip0.
  ///
  /// In en, this message translates to:
  /// **'Call upon Allah with ease — He is near.'**
  String get prayerSpiritualTip0;

  /// No description provided for @prayerSpiritualTip1.
  ///
  /// In en, this message translates to:
  /// **'Two rakahs of duha bring light to the day.'**
  String get prayerSpiritualTip1;

  /// No description provided for @prayerSpiritualTip2.
  ///
  /// In en, this message translates to:
  /// **'Pause before the prayer — silence is also worship.'**
  String get prayerSpiritualTip2;

  /// No description provided for @prayerSpiritualTip3.
  ///
  /// In en, this message translates to:
  /// **'Let your heart arrive before your body rises.'**
  String get prayerSpiritualTip3;

  /// No description provided for @prayerLocationSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer location'**
  String get prayerLocationSheetTitle;

  /// No description provided for @prayerLocationAutoGps.
  ///
  /// In en, this message translates to:
  /// **'Automatic (GPS)'**
  String get prayerLocationAutoGps;

  /// No description provided for @prayerLocationAutoGpsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your current position for prayer times.'**
  String get prayerLocationAutoGpsSubtitle;

  /// No description provided for @prayerLocationUseGpsNow.
  ///
  /// In en, this message translates to:
  /// **'Use current position'**
  String get prayerLocationUseGpsNow;

  /// No description provided for @prayerLocationSearchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search country'**
  String get prayerLocationSearchCountry;

  /// No description provided for @prayerLocationSearchCity.
  ///
  /// In en, this message translates to:
  /// **'Search city'**
  String get prayerLocationSearchCity;

  /// No description provided for @prayerLocationGpsDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for automatic mode.'**
  String get prayerLocationGpsDenied;

  /// No description provided for @prayerLocationGpsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read your position. Try manual selection.'**
  String get prayerLocationGpsFailed;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clarity, reverence, and a calm daily rhythm with the Book of Allah.'**
  String get aboutSubtitle;

  /// No description provided for @aboutHeroMission.
  ///
  /// In en, this message translates to:
  /// **'A quiet companion for reading, listening, understanding, and remembering.'**
  String get aboutHeroMission;

  /// No description provided for @aboutSectionMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get aboutSectionMissionTitle;

  /// No description provided for @aboutSectionMissionBody.
  ///
  /// In en, this message translates to:
  /// **'Bring the Qur\'an, trusted explanation, and wholesome listening closer to your day — without noise or clutter.'**
  String get aboutSectionMissionBody;

  /// No description provided for @aboutSectionVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get aboutSectionVisionTitle;

  /// No description provided for @aboutSectionVisionBody.
  ///
  /// In en, this message translates to:
  /// **'A spiritually aligned experience: beautiful typography, respectful sources, and tools that support focus rather than distraction.'**
  String get aboutSectionVisionBody;

  /// No description provided for @aboutSectionWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why this app'**
  String get aboutSectionWhyTitle;

  /// No description provided for @aboutSectionWhyBody.
  ///
  /// In en, this message translates to:
  /// **'Many people want one trustworthy place for Mushaf reading, tafsir context, tilawat, prayer awareness, and gentle storytelling — built with adab and clarity.'**
  String get aboutSectionWhyBody;

  /// No description provided for @aboutSectionPillarsTitle.
  ///
  /// In en, this message translates to:
  /// **'What you will find here'**
  String get aboutSectionPillarsTitle;

  /// No description provided for @aboutPillarQuran.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an reader with search, bookmarks, and readable Arabic layout.'**
  String get aboutPillarQuran;

  /// No description provided for @aboutPillarTafsir.
  ///
  /// In en, this message translates to:
  /// **'Al-Muyassar tafsir stream for context beside the ayat.'**
  String get aboutPillarTafsir;

  /// No description provided for @aboutPillarTilawat.
  ///
  /// In en, this message translates to:
  /// **'Recitations with offline downloads for travel and low connectivity.'**
  String get aboutPillarTilawat;

  /// No description provided for @aboutPillarStories.
  ///
  /// In en, this message translates to:
  /// **'Prophet stories with careful narration policy and curated references.'**
  String get aboutPillarStories;

  /// No description provided for @aboutSectionPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy and respect'**
  String get aboutSectionPrivacyTitle;

  /// No description provided for @aboutSectionPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'We design for local-first use where possible, minimal surprises, and content choices that respect sacred text and scholars\' boundaries.'**
  String get aboutSectionPrivacyBody;

  /// No description provided for @aboutSectionOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline-first mindset'**
  String get aboutSectionOfflineTitle;

  /// No description provided for @aboutSectionOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Core text and downloads are meant to work when networks fail — so remembrance stays within reach.'**
  String get aboutSectionOfflineBody;

  /// No description provided for @aboutSectionLangTitle.
  ///
  /// In en, this message translates to:
  /// **'Multilingual interface'**
  String get aboutSectionLangTitle;

  /// No description provided for @aboutSectionLangBody.
  ///
  /// In en, this message translates to:
  /// **'Arabic, English, and French UI so families and students can navigate comfortably.'**
  String get aboutSectionLangBody;

  /// No description provided for @aboutIllustrationCaption.
  ///
  /// In en, this message translates to:
  /// **'Barakallahu feekum for walking this path with us.'**
  String get aboutIllustrationCaption;

  /// No description provided for @aboutAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutAppVersion(Object version);

  /// No description provided for @aboutCreditsLine.
  ///
  /// In en, this message translates to:
  /// **'Crafted with care for the Ummah. All good is from Allah; any mistake is ours.'**
  String get aboutCreditsLine;

  /// No description provided for @aboutDeveloperCredit.
  ///
  /// In en, this message translates to:
  /// **'Development — ELKARCH ABDELHAMID · القرش عبد الحميد'**
  String get aboutDeveloperCredit;

  /// No description provided for @helpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short answers, calm layout — so you spend less time searching and more time benefiting.'**
  String get helpSubtitle;

  /// No description provided for @helpCardIntro.
  ///
  /// In en, this message translates to:
  /// **'Use the sections below for quick orientation, then open the FAQ for finer details.'**
  String get helpCardIntro;

  /// No description provided for @helpSectionGuides.
  ///
  /// In en, this message translates to:
  /// **'Quick guides'**
  String get helpSectionGuides;

  /// No description provided for @helpGuideQuranTitle.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an page'**
  String get helpGuideQuranTitle;

  /// No description provided for @helpGuideQuranBody.
  ///
  /// In en, this message translates to:
  /// **'Open a surah, adjust font and spacing, search ayat, and jump to tafsir from the reader tools.'**
  String get helpGuideQuranBody;

  /// No description provided for @helpGuideTilawatTitle.
  ///
  /// In en, this message translates to:
  /// **'Tilawat (recitations)'**
  String get helpGuideTilawatTitle;

  /// No description provided for @helpGuideTilawatBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a reciter in Settings, play from the audio page, expand the mini-player, and use the full player for speed and repeat controls.'**
  String get helpGuideTilawatBody;

  /// No description provided for @helpGuideDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Download surahs'**
  String get helpGuideDownloadTitle;

  /// No description provided for @helpGuideDownloadBody.
  ///
  /// In en, this message translates to:
  /// **'Use the download action on tilawat where available; files are stored for offline playback when the reciter mirror allows it.'**
  String get helpGuideDownloadBody;

  /// No description provided for @helpGuidePrayerNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer notifications'**
  String get helpGuidePrayerNotifyTitle;

  /// No description provided for @helpGuidePrayerNotifyBody.
  ///
  /// In en, this message translates to:
  /// **'Enable reminders in Settings, set location in the Adhan section, and allow notification permission so gentle alerts can arrive in time.'**
  String get helpGuidePrayerNotifyBody;

  /// No description provided for @helpGuideBackgroundAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Background audio'**
  String get helpGuideBackgroundAudioTitle;

  /// No description provided for @helpGuideBackgroundAudioBody.
  ///
  /// In en, this message translates to:
  /// **'Tilawat can continue while you browse; story narration may be limited on web browsers — use the mobile app for full background listening.'**
  String get helpGuideBackgroundAudioBody;

  /// No description provided for @helpGuideBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get helpGuideBookmarkTitle;

  /// No description provided for @helpGuideBookmarkBody.
  ///
  /// In en, this message translates to:
  /// **'Save your reading position from the surah reader when offered; return later from the continue-reading entry points on the Qur\'an page.'**
  String get helpGuideBookmarkBody;

  /// No description provided for @helpSectionFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get helpSectionFaq;

  /// No description provided for @helpFaqQuranTitle.
  ///
  /// In en, this message translates to:
  /// **'How do I search within a surah?'**
  String get helpFaqQuranTitle;

  /// No description provided for @helpFaqQuranBody.
  ///
  /// In en, this message translates to:
  /// **'Open the surah, enable search from the reader toolbar, type a phrase or surah number, then tap a result to scroll there.'**
  String get helpFaqQuranBody;

  /// No description provided for @helpFaqTilawatTitle.
  ///
  /// In en, this message translates to:
  /// **'Why does audio stop when I leave a page?'**
  String get helpFaqTilawatTitle;

  /// No description provided for @helpFaqTilawatBody.
  ///
  /// In en, this message translates to:
  /// **'If the mini-player is hidden, start playback again from Tilawat; on web, the browser may pause audio unless the mini-player session is active.'**
  String get helpFaqTilawatBody;

  /// No description provided for @helpFaqDownloadTitle.
  ///
  /// In en, this message translates to:
  /// **'Why did a download fail?'**
  String get helpFaqDownloadTitle;

  /// No description provided for @helpFaqDownloadBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and storage; some mirrors may be temporarily unavailable — try again after a few minutes.'**
  String get helpFaqDownloadBody;

  /// No description provided for @helpFaqNotifyTitle.
  ///
  /// In en, this message translates to:
  /// **'I do not receive prayer alerts'**
  String get helpFaqNotifyTitle;

  /// No description provided for @helpFaqNotifyBody.
  ///
  /// In en, this message translates to:
  /// **'Confirm OS notification permission, disable battery restrictions for the app if your vendor blocks alarms, and verify location or manual city selection for correct times.'**
  String get helpFaqNotifyBody;

  /// No description provided for @helpFaqBgAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Can I play stories in the background on the website?'**
  String get helpFaqBgAudioTitle;

  /// No description provided for @helpFaqBgAudioBody.
  ///
  /// In en, this message translates to:
  /// **'Browsers limit background media; install the Android build for narration that continues while the screen is off.'**
  String get helpFaqBgAudioBody;

  /// No description provided for @helpFaqBookmarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is my bookmark stored?'**
  String get helpFaqBookmarkTitle;

  /// No description provided for @helpFaqBookmarkBody.
  ///
  /// In en, this message translates to:
  /// **'It is kept on this device so you can resume reading locally — it is not uploaded to a server.'**
  String get helpFaqBookmarkBody;

  /// No description provided for @helpFaqTroubleTitle.
  ///
  /// In en, this message translates to:
  /// **'General troubleshooting'**
  String get helpFaqTroubleTitle;

  /// No description provided for @helpFaqTroubleBody.
  ///
  /// In en, this message translates to:
  /// **'Restart the app, confirm date and time are automatic, update to the latest version, and if an error repeats note the page you were on before contacting us.'**
  String get helpFaqTroubleBody;

  /// No description provided for @rateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your stars lift the team and keep improvements coming.'**
  String get rateSubtitle;

  /// No description provided for @rateHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Jazakum Allahu khayran'**
  String get rateHeroTitle;

  /// No description provided for @rateHeroBody.
  ///
  /// In en, this message translates to:
  /// **'If this app helped your Qur\'an or salah, sharing a kind rating spreads benefit to others who are searching.'**
  String get rateHeroBody;

  /// No description provided for @rateStarsCaption.
  ///
  /// In en, this message translates to:
  /// **'Five hearts behind five stars — thank you for your trust.'**
  String get rateStarsCaption;

  /// No description provided for @rateBtnStore.
  ///
  /// In en, this message translates to:
  /// **'Rate on Play Store'**
  String get rateBtnStore;

  /// No description provided for @rateBtnShare.
  ///
  /// In en, this message translates to:
  /// **'Share the app'**
  String get rateBtnShare;

  /// No description provided for @rateBtnFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get rateBtnFeedback;

  /// No description provided for @rateSnackStoreFail.
  ///
  /// In en, this message translates to:
  /// **'Could not open the store from this device.'**
  String get rateSnackStoreFail;

  /// No description provided for @rateSnackShareFail.
  ///
  /// In en, this message translates to:
  /// **'Could not open the share sheet.'**
  String get rateSnackShareFail;

  /// No description provided for @rateSnackMailFail.
  ///
  /// In en, this message translates to:
  /// **'Could not open your email app from this device.'**
  String get rateSnackMailFail;

  /// No description provided for @rateShareText.
  ///
  /// In en, this message translates to:
  /// **'Try this Qur\'an app: {url}'**
  String rateShareText(Object url);

  /// No description provided for @rateFeedbackSubject.
  ///
  /// In en, this message translates to:
  /// **'Quran app feedback'**
  String get rateFeedbackSubject;

  /// No description provided for @sourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transparency builds trust — here is how content reaches you.'**
  String get sourcesSubtitle;

  /// No description provided for @sourcesIntro.
  ///
  /// In en, this message translates to:
  /// **'We prefer established hosts, documented APIs, and clearly attributed texts. When in doubt, we stay conservative.'**
  String get sourcesIntro;

  /// No description provided for @sourcesTrustLine.
  ///
  /// In en, this message translates to:
  /// **'Curated pathways — not anonymous scrapers.'**
  String get sourcesTrustLine;

  /// No description provided for @sourcesVisitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Official site'**
  String get sourcesVisitWebsite;

  /// No description provided for @sourcesQuranTitle.
  ///
  /// In en, this message translates to:
  /// **'Qur\'an text (Mushaf)'**
  String get sourcesQuranTitle;

  /// No description provided for @sourcesQuranBody.
  ///
  /// In en, this message translates to:
  /// **'Arabic ayat are bundled in-app from a Uthmani-style dataset aligned with widely reviewed Tanzil-class releases for faithful typography.'**
  String get sourcesQuranBody;

  /// No description provided for @sourcesTafsirTitle.
  ///
  /// In en, this message translates to:
  /// **'Tafsir (Al-Muyassar)'**
  String get sourcesTafsirTitle;

  /// No description provided for @sourcesTafsirBody.
  ///
  /// In en, this message translates to:
  /// **'Arabic Al-Muyassar commentary is retrieved via Quran.com public APIs with edition identifiers documented by the service.'**
  String get sourcesTafsirBody;

  /// No description provided for @sourcesPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer times'**
  String get sourcesPrayerTitle;

  /// No description provided for @sourcesPrayerBody.
  ///
  /// In en, this message translates to:
  /// **'Coordinates and calculation method are sent to Aladhan (Islamic Network) timings API; results are displayed for your chosen location.'**
  String get sourcesPrayerBody;

  /// No description provided for @sourcesAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Recitation audio'**
  String get sourcesAudioTitle;

  /// No description provided for @sourcesAudioBody.
  ///
  /// In en, this message translates to:
  /// **'Streams and downloads use reputable reciter mirrors such as MP3 Quran and Quranicaudio-style hosts referenced in the surah catalog.'**
  String get sourcesAudioBody;

  /// No description provided for @sourcesStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Prophet stories (narration)'**
  String get sourcesStoriesTitle;

  /// No description provided for @sourcesStoriesBody.
  ///
  /// In en, this message translates to:
  /// **'YouTube narration is restricted to an allow-listed channel policy; each story prefers a single verified video mapping.'**
  String get sourcesStoriesBody;

  /// No description provided for @sourcesMiraclesTitle.
  ///
  /// In en, this message translates to:
  /// **'Scientific miracles section'**
  String get sourcesMiraclesTitle;

  /// No description provided for @sourcesMiraclesBody.
  ///
  /// In en, this message translates to:
  /// **'Topics are curated with moderate wording and explicit ayah links; they are educational pointers — not a fatwa or creed textbook.'**
  String get sourcesMiraclesBody;

  /// No description provided for @sourcesOpenLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open this link on this device.'**
  String get sourcesOpenLinkFailed;

  /// No description provided for @homeQuranicDuas.
  ///
  /// In en, this message translates to:
  /// **'Quranic duas'**
  String get homeQuranicDuas;

  /// No description provided for @homeKhatmDua.
  ///
  /// In en, this message translates to:
  /// **'Khatm dua'**
  String get homeKhatmDua;

  /// No description provided for @quranicDuasTitle.
  ///
  /// In en, this message translates to:
  /// **'Duas from the Qur\'an'**
  String get quranicDuasTitle;

  /// No description provided for @quranicDuasSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search text, topic, or surah…'**
  String get quranicDuasSearchHint;

  /// No description provided for @quranicDuasSearchOpenTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search duas'**
  String get quranicDuasSearchOpenTooltip;

  /// No description provided for @quranicDuasFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter by surah and topic'**
  String get quranicDuasFilterTooltip;

  /// No description provided for @quranicDuasFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get quranicDuasFilterTitle;

  /// No description provided for @quranicDuasAllSurahs.
  ///
  /// In en, this message translates to:
  /// **'All surahs'**
  String get quranicDuasAllSurahs;

  /// No description provided for @quranicDuasAllTopics.
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get quranicDuasAllTopics;

  /// No description provided for @quranicDuasApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get quranicDuasApplyFilters;

  /// No description provided for @quranicDuasClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get quranicDuasClearFilters;

  /// No description provided for @quranicDuasEmpty.
  ///
  /// In en, this message translates to:
  /// **'No duas match your search or filters.'**
  String get quranicDuasEmpty;

  /// No description provided for @quranicDuasLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load duas. Pull to retry or reopen the page.'**
  String get quranicDuasLoadError;

  /// No description provided for @quranicDuasOpenQuran.
  ///
  /// In en, this message translates to:
  /// **'Open in Qur\'an'**
  String get quranicDuasOpenQuran;

  /// No description provided for @quranicDuasOpenTafsir.
  ///
  /// In en, this message translates to:
  /// **'Open tafsir'**
  String get quranicDuasOpenTafsir;

  /// No description provided for @quranicDuasCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get quranicDuasCopy;

  /// No description provided for @quranicDuasShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get quranicDuasShare;

  /// No description provided for @quranicDuasFavoriteOn.
  ///
  /// In en, this message translates to:
  /// **'Saved locally'**
  String get quranicDuasFavoriteOn;

  /// No description provided for @quranicDuasFavoriteOff.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get quranicDuasFavoriteOff;

  /// No description provided for @quranicDuasCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard.'**
  String get quranicDuasCopied;

  /// No description provided for @quranicDuasShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Du\'a from the Qur\'an'**
  String get quranicDuasShareSubject;

  /// No description provided for @khatmDuaTitle.
  ///
  /// In en, this message translates to:
  /// **'Khatm al-Qur\'an supplication'**
  String get khatmDuaTitle;

  /// No description provided for @khatmDuaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A calm reading for completion and gratitude'**
  String get khatmDuaSubtitle;

  /// No description provided for @khatmDuaLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this page. Try again.'**
  String get khatmDuaLoadError;

  /// No description provided for @khatmDuaAudioSoon.
  ///
  /// In en, this message translates to:
  /// **'Audio recitation will be offered in a future update.'**
  String get khatmDuaAudioSoon;

  /// No description provided for @khatmDuaFooterNote.
  ///
  /// In en, this message translates to:
  /// **'This layout is for reading and reflection; follow wording your scholars or community recommend for khatm.'**
  String get khatmDuaFooterNote;

  /// No description provided for @duaTopicMercy.
  ///
  /// In en, this message translates to:
  /// **'Mercy'**
  String get duaTopicMercy;

  /// No description provided for @duaTopicForgiveness.
  ///
  /// In en, this message translates to:
  /// **'Forgiveness'**
  String get duaTopicForgiveness;

  /// No description provided for @duaTopicRizq.
  ///
  /// In en, this message translates to:
  /// **'Provision'**
  String get duaTopicRizq;

  /// No description provided for @duaTopicPatience.
  ///
  /// In en, this message translates to:
  /// **'Patience'**
  String get duaTopicPatience;

  /// No description provided for @duaTopicGuidance.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get duaTopicGuidance;

  /// No description provided for @duaTopicProtection.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get duaTopicProtection;

  /// No description provided for @duaTopicParents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get duaTopicParents;

  /// No description provided for @duaTopicSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get duaTopicSuccess;

  /// No description provided for @duaTopicGratitude.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get duaTopicGratitude;

  /// No description provided for @duaTopicKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get duaTopicKnowledge;

  /// No description provided for @duaTopicRefuge.
  ///
  /// In en, this message translates to:
  /// **'Trust & refuge'**
  String get duaTopicRefuge;

  /// No description provided for @duaTopicFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get duaTopicFamily;

  /// No description provided for @duaTopicTaqwa.
  ///
  /// In en, this message translates to:
  /// **'God-consciousness'**
  String get duaTopicTaqwa;

  /// No description provided for @duaTopicHealing.
  ///
  /// In en, this message translates to:
  /// **'Hardship & healing'**
  String get duaTopicHealing;

  /// No description provided for @duaRefLine.
  ///
  /// In en, this message translates to:
  /// **'{surahName} · {ayahPart}'**
  String duaRefLine(Object surahName, Object ayahPart);
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
