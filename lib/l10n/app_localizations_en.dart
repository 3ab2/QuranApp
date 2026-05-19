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
  String get storyPauseAudio => 'Pause';

  @override
  String get playbackSpeedSheetTitle => 'Playback speed';

  @override
  String get storyYoutubeStreamUnavailable =>
      'Could not start the narration stream. Check your connection and try again.';

  @override
  String get storyYoutubeWebAudioUnavailable =>
      'Story narration in the background is not available in the web browser. Use the app on a phone or tablet for full playback.';

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
  String get prophetStoriesSearchHint => 'Search by prophet name or story…';

  @override
  String get prophetStoriesSearchEmpty =>
      'No prophet stories match. Try different words.';

  @override
  String get prophetStoriesSearchOpenTooltip => 'Search stories';

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
  String get miraclesPageTitle => 'Scientific miracles in the Qur\'an';

  @override
  String get miraclesSearchHint =>
      'Search verse, topic, or scientific explanation…';

  @override
  String get miraclesEmptyResults => 'No results';

  @override
  String get miraclesFilterAll => 'All';

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

  @override
  String get storyYoutubePlayerTitle => 'Story narration';

  @override
  String get storyYoutubeUnavailable =>
      'No verified YouTube narration is linked for this story yet.';

  @override
  String get storyYoutubeInvalidChannel =>
      'This video is not from an approved channel.';

  @override
  String get storyYoutubeLoadError =>
      'Could not load the YouTube player. Check your connection and try again.';

  @override
  String get storyYoutubeNarrator => 'Narrator';

  @override
  String get storyYoutubePrevious => 'Previous story';

  @override
  String get storyYoutubeNext => 'Next story';

  @override
  String get storyYoutubeBackgroundHint =>
      'Background playback depends on your device; keep the app in recent apps for best results.';

  @override
  String get storyYoutubeOpenPlayer => 'Listen to the story';

  @override
  String get storyYoutubeNoNarration =>
      'No narration available for this story.';

  @override
  String get storyYoutubeSleepTimer => 'Sleep timer';

  @override
  String get storyYoutubeSleepOff => 'Off';

  @override
  String storyYoutubeSleepMinutes(int minutes) {
    return 'Stop after $minutes min';
  }

  @override
  String get storyYoutubeSleepEnded => 'Sleep timer stopped playback.';

  @override
  String storyYoutubePlaybackSpeedLabel(String speed) {
    return '${speed}x';
  }

  @override
  String get storyYoutubeCopyLink => 'Copy video link';

  @override
  String get storyYoutubeLinkCopied => 'YouTube link copied to clipboard.';

  @override
  String get storyYoutubeFullscreen => 'Fullscreen';

  @override
  String get storyYoutubeDownloadHint =>
      'Use the link icon to copy the watch URL. Offline download of YouTube video is not available in this app.';

  @override
  String get prayerPhaseCalm => 'Next prayer';

  @override
  String get prayerPhaseApproaching => 'Prayer is approaching';

  @override
  String get prayerPhaseAtAdhan => 'It is now time for prayer';

  @override
  String get prayerPhaseGrace => 'Take this moment with calm';

  @override
  String prayerCountdownRemaining(String hms) {
    return 'Remaining: $hms';
  }

  @override
  String prayerCurrentPeriod(String name) {
    return 'Current period: $name';
  }

  @override
  String get prayerAtAdhanMoment =>
      'The adhan moment — refocus gently on Allah';

  @override
  String get prayerOpenQibla => 'Qibla';

  @override
  String get prayerAdhanStop => 'Stop';

  @override
  String get prayerAdhanSnooze => 'Snooze';

  @override
  String get prayerAdhanMute => 'Mute';

  @override
  String get prayerAdhanUnmute => 'Unmute';

  @override
  String get prayerImmersiveHint =>
      'Soft motion only — designed for a peaceful heart';

  @override
  String get prayerQiblaTitle => 'Qibla';

  @override
  String get prayerQiblaWebUnavailable =>
      'Live compass qibla uses device sensors and is available in the mobile app.';

  @override
  String get prayerQiblaLocationDisabled =>
      'Enable location services and grant permission to use the compass qibla.';

  @override
  String get prayerQiblaError => 'Could not read compass data on this device.';

  @override
  String get prayerQiblaEmulatorUnavailable =>
      'Live compass sensors are unavailable on this device or emulator. Use the static Qibla guide below.';

  @override
  String prayerQiblaDistanceKm(String km) {
    return 'About $km km to the Kaaba';
  }

  @override
  String get prayerQiblaAlignedHint =>
      'You are aligned — may Allah accept your prayer';

  @override
  String get prayerQiblaRotateHint =>
      'Turn slowly until the needle steadies toward the Kaaba';

  @override
  String get prayerQiblaFallbackSubtitle =>
      'Qibla direction from your location';

  @override
  String get prayerQiblaFallbackExplanation =>
      'The live compass needs your phone\'s magnetic and direction sensors. It works fully inside the mobile app.';

  @override
  String get prayerQiblaFallbackBrowserNote =>
      'Web and desktop browsers often cannot access the sensors needed for a live compass.';

  @override
  String get prayerQiblaFallbackStaticHint =>
      'Approximate Qibla from your saved location';

  @override
  String prayerQiblaFallbackAngle(String angle) {
    return 'Qibla bearing: $angle from north';
  }

  @override
  String get prayerQiblaFallbackLocationTitle => 'Your location';

  @override
  String get prayerQiblaFallbackLocationUnknown => 'Location not set yet';

  @override
  String get prayerQiblaFallbackLocationHint =>
      'Set your city on the Prayer page to see the Qibla angle for where you are.';

  @override
  String get prayerQiblaFallbackKaabaTitle => 'Toward the Kaaba';

  @override
  String get prayerQiblaFallbackMobileTitle => 'Live compass on mobile';

  @override
  String get prayerQiblaFallbackMobileBody =>
      'Open this app on your phone for a real-time compass that follows your movement toward the Qibla.';

  @override
  String get prayerQiblaFallbackDragHint =>
      'Drag gently to explore — release to realign with Qibla';

  @override
  String get prayerQiblaFallbackInfoTitle => 'Qibla at a glance';

  @override
  String get prayerQiblaFallbackAngleLabel => 'Qibla angle';

  @override
  String get prayerQiblaFallbackDistanceLabel => 'To Kaaba';

  @override
  String get prayerQiblaFallbackHeadingLabel => 'Compass mode';

  @override
  String get prayerQiblaFallbackHeadingValue => 'Static guide';

  @override
  String get prayerSettingsReminder => 'Reminder before prayer';

  @override
  String get prayerReminderEnabledHelp =>
      'A simple notification a few minutes before each prayer so you can prepare.';

  @override
  String get prayerAdhanEnabledHelp =>
      'Notification at the exact prayer time and manual adhan playback from the prayer list.';

  @override
  String get prayerReminderPreset5 => '5 min';

  @override
  String get prayerReminderPreset10 => '10 min';

  @override
  String get prayerReminderPreset15 => '15 min';

  @override
  String get prayerReminderCustomHint => 'Custom (1–120 min)';

  @override
  String get prayerMuezzinVoice => 'Muezzin / Adhan voice';

  @override
  String get prayerPreviewVoice => 'Preview';

  @override
  String get prayerMosqueMode => 'Mosque mode (experimental)';

  @override
  String get prayerMosqueModeHelp =>
      'When enabled, a reserved hook runs in the approaching window. Full silent/DND requires future OS integration.';

  @override
  String get prayerAfterAdhkar => 'After prayer — short dhikr';

  @override
  String get prayerAfterAdhkarBody =>
      'Say subhanAllah (33), alhamdulillah (33), Allahu akbar (33) — or recite Ayat al-Kursi with calm.';

  @override
  String get prayerSpiritualTip0 => 'Call upon Allah with ease — He is near.';

  @override
  String get prayerSpiritualTip1 =>
      'Two rakahs of duha bring light to the day.';

  @override
  String get prayerSpiritualTip2 =>
      'Pause before the prayer — silence is also worship.';

  @override
  String get prayerSpiritualTip3 =>
      'Let your heart arrive before your body rises.';

  @override
  String get prayerLocationSheetTitle => 'Prayer location';

  @override
  String get prayerLocationAutoGps => 'Automatic (GPS)';

  @override
  String get prayerLocationAutoGpsSubtitle =>
      'Use your current position for prayer times.';

  @override
  String get prayerLocationUseGpsNow => 'Use current position';

  @override
  String get prayerLocationSearchCountry => 'Search country';

  @override
  String get prayerLocationSearchCity => 'Search city';

  @override
  String get prayerLocationGpsDenied =>
      'Location permission is required for automatic mode.';

  @override
  String get prayerLocationGpsFailed =>
      'Could not read your position. Try manual selection.';

  @override
  String get aboutSubtitle =>
      'Clarity, reverence, and a calm daily rhythm with the Book of Allah.';

  @override
  String get aboutHeroMission =>
      'A quiet companion for reading, listening, understanding, and remembering.';

  @override
  String get aboutSectionMissionTitle => 'Mission';

  @override
  String get aboutSectionMissionBody =>
      'Bring the Qur\'an, trusted explanation, and wholesome listening closer to your day — without noise or clutter.';

  @override
  String get aboutSectionVisionTitle => 'Vision';

  @override
  String get aboutSectionVisionBody =>
      'A spiritually aligned experience: beautiful typography, respectful sources, and tools that support focus rather than distraction.';

  @override
  String get aboutSectionWhyTitle => 'Why this app';

  @override
  String get aboutSectionWhyBody =>
      'Many people want one trustworthy place for Mushaf reading, tafsir context, tilawat, prayer awareness, and gentle storytelling — built with adab and clarity.';

  @override
  String get aboutSectionPillarsTitle => 'What you will find here';

  @override
  String get aboutPillarQuran =>
      'Qur\'an reader with search, bookmarks, and readable Arabic layout.';

  @override
  String get aboutPillarTafsir =>
      'Al-Muyassar tafsir stream for context beside the ayat.';

  @override
  String get aboutPillarTilawat =>
      'Recitations with offline downloads for travel and low connectivity.';

  @override
  String get aboutPillarStories =>
      'Prophet stories with careful narration policy and curated references.';

  @override
  String get aboutSectionPrivacyTitle => 'Privacy and respect';

  @override
  String get aboutSectionPrivacyBody =>
      'We design for local-first use where possible, minimal surprises, and content choices that respect sacred text and scholars\' boundaries.';

  @override
  String get aboutSectionOfflineTitle => 'Offline-first mindset';

  @override
  String get aboutSectionOfflineBody =>
      'Core text and downloads are meant to work when networks fail — so remembrance stays within reach.';

  @override
  String get aboutSectionLangTitle => 'Multilingual interface';

  @override
  String get aboutSectionLangBody =>
      'Arabic, English, and French UI so families and students can navigate comfortably.';

  @override
  String get aboutIllustrationCaption =>
      'Barakallahu feekum for walking this path with us.';

  @override
  String aboutAppVersion(Object version) {
    return 'Version $version';
  }

  @override
  String get aboutCreditsLine =>
      'Crafted with care for the Ummah. All good is from Allah; any mistake is ours.';

  @override
  String get helpSubtitle =>
      'Short answers, calm layout — so you spend less time searching and more time benefiting.';

  @override
  String get helpCardIntro =>
      'Use the sections below for quick orientation, then open the FAQ for finer details.';

  @override
  String get helpSectionGuides => 'Quick guides';

  @override
  String get helpGuideQuranTitle => 'Qur\'an page';

  @override
  String get helpGuideQuranBody =>
      'Open a surah, adjust font and spacing, search ayat, and jump to tafsir from the reader tools.';

  @override
  String get helpGuideTilawatTitle => 'Tilawat (recitations)';

  @override
  String get helpGuideTilawatBody =>
      'Pick a reciter in Settings, play from the audio page, expand the mini-player, and use the full player for speed and repeat controls.';

  @override
  String get helpGuideDownloadTitle => 'Download surahs';

  @override
  String get helpGuideDownloadBody =>
      'Use the download action on tilawat where available; files are stored for offline playback when the reciter mirror allows it.';

  @override
  String get helpGuidePrayerNotifyTitle => 'Prayer notifications';

  @override
  String get helpGuidePrayerNotifyBody =>
      'Enable reminders in Settings, set location in the Adhan section, and allow notification permission so gentle alerts can arrive in time.';

  @override
  String get helpGuideBackgroundAudioTitle => 'Background audio';

  @override
  String get helpGuideBackgroundAudioBody =>
      'Tilawat can continue while you browse; story narration may be limited on web browsers — use the mobile app for full background listening.';

  @override
  String get helpGuideBookmarkTitle => 'Bookmarks';

  @override
  String get helpGuideBookmarkBody =>
      'Save your reading position from the surah reader when offered; return later from the continue-reading entry points on the Qur\'an page.';

  @override
  String get helpSectionFaq => 'FAQ';

  @override
  String get helpFaqQuranTitle => 'How do I search within a surah?';

  @override
  String get helpFaqQuranBody =>
      'Open the surah, enable search from the reader toolbar, type a phrase or surah number, then tap a result to scroll there.';

  @override
  String get helpFaqTilawatTitle => 'Why does audio stop when I leave a page?';

  @override
  String get helpFaqTilawatBody =>
      'If the mini-player is hidden, start playback again from Tilawat; on web, the browser may pause audio unless the mini-player session is active.';

  @override
  String get helpFaqDownloadTitle => 'Why did a download fail?';

  @override
  String get helpFaqDownloadBody =>
      'Check your connection and storage; some mirrors may be temporarily unavailable — try again after a few minutes.';

  @override
  String get helpFaqNotifyTitle => 'I do not receive prayer alerts';

  @override
  String get helpFaqNotifyBody =>
      'Confirm OS notification permission, disable battery restrictions for the app if your vendor blocks alarms, and verify location or manual city selection for correct times.';

  @override
  String get helpFaqBgAudioTitle =>
      'Can I play stories in the background on the website?';

  @override
  String get helpFaqBgAudioBody =>
      'Browsers limit background media; install the Android build for narration that continues while the screen is off.';

  @override
  String get helpFaqBookmarkTitle => 'Where is my bookmark stored?';

  @override
  String get helpFaqBookmarkBody =>
      'It is kept on this device so you can resume reading locally — it is not uploaded to a server.';

  @override
  String get helpFaqTroubleTitle => 'General troubleshooting';

  @override
  String get helpFaqTroubleBody =>
      'Restart the app, confirm date and time are automatic, update to the latest version, and if an error repeats note the page you were on before contacting us.';

  @override
  String get rateSubtitle =>
      'Your stars lift the team and keep improvements coming.';

  @override
  String get rateHeroTitle => 'Jazakum Allahu khayran';

  @override
  String get rateHeroBody =>
      'If this app helped your Qur\'an or salah, sharing a kind rating spreads benefit to others who are searching.';

  @override
  String get rateStarsCaption =>
      'Five hearts behind five stars — thank you for your trust.';

  @override
  String get rateBtnStore => 'Rate on Play Store';

  @override
  String get rateBtnShare => 'Share the app';

  @override
  String get rateBtnFeedback => 'Send feedback';

  @override
  String get rateSnackStoreFail => 'Could not open the store from this device.';

  @override
  String get rateSnackShareFail => 'Could not open the share sheet.';

  @override
  String get rateSnackMailFail =>
      'Could not open your email app from this device.';

  @override
  String rateShareText(Object url) {
    return 'Try this Qur\'an app: $url';
  }

  @override
  String get rateFeedbackSubject => 'Quran app feedback';

  @override
  String get sourcesSubtitle =>
      'Transparency builds trust — here is how content reaches you.';

  @override
  String get sourcesIntro =>
      'We prefer established hosts, documented APIs, and clearly attributed texts. When in doubt, we stay conservative.';

  @override
  String get sourcesTrustLine => 'Curated pathways — not anonymous scrapers.';

  @override
  String get sourcesVisitWebsite => 'Official site';

  @override
  String get sourcesQuranTitle => 'Qur\'an text (Mushaf)';

  @override
  String get sourcesQuranBody =>
      'Arabic ayat are bundled in-app from a Uthmani-style dataset aligned with widely reviewed Tanzil-class releases for faithful typography.';

  @override
  String get sourcesTafsirTitle => 'Tafsir (Al-Muyassar)';

  @override
  String get sourcesTafsirBody =>
      'Arabic Al-Muyassar commentary is retrieved via Quran.com public APIs with edition identifiers documented by the service.';

  @override
  String get sourcesPrayerTitle => 'Prayer times';

  @override
  String get sourcesPrayerBody =>
      'Coordinates and calculation method are sent to Aladhan (Islamic Network) timings API; results are displayed for your chosen location.';

  @override
  String get sourcesAudioTitle => 'Recitation audio';

  @override
  String get sourcesAudioBody =>
      'Streams and downloads use reputable reciter mirrors such as MP3 Quran and Quranicaudio-style hosts referenced in the surah catalog.';

  @override
  String get sourcesStoriesTitle => 'Prophet stories (narration)';

  @override
  String get sourcesStoriesBody =>
      'YouTube narration is restricted to an allow-listed channel policy; each story prefers a single verified video mapping.';

  @override
  String get sourcesMiraclesTitle => 'Scientific miracles section';

  @override
  String get sourcesMiraclesBody =>
      'Topics are curated with moderate wording and explicit ayah links; they are educational pointers — not a fatwa or creed textbook.';

  @override
  String get sourcesOpenLinkFailed =>
      'Could not open this link on this device.';

  @override
  String get homeQuranicDuas => 'Quranic duas';

  @override
  String get homeKhatmDua => 'Khatm dua';

  @override
  String get quranicDuasTitle => 'Duas from the Qur\'an';

  @override
  String get quranicDuasSearchHint => 'Search text, topic, or surah…';

  @override
  String get quranicDuasSearchOpenTooltip => 'Search duas';

  @override
  String get quranicDuasFilterTooltip => 'Filter by surah and topic';

  @override
  String get quranicDuasFilterTitle => 'Filters';

  @override
  String get quranicDuasAllSurahs => 'All surahs';

  @override
  String get quranicDuasAllTopics => 'All topics';

  @override
  String get quranicDuasApplyFilters => 'Apply';

  @override
  String get quranicDuasClearFilters => 'Clear filters';

  @override
  String get quranicDuasEmpty => 'No duas match your search or filters.';

  @override
  String get quranicDuasLoadError =>
      'Could not load duas. Pull to retry or reopen the page.';

  @override
  String get quranicDuasOpenQuran => 'Open in Qur\'an';

  @override
  String get quranicDuasOpenTafsir => 'Open tafsir';

  @override
  String get quranicDuasCopy => 'Copy';

  @override
  String get quranicDuasShare => 'Share';

  @override
  String get quranicDuasFavoriteOn => 'Saved locally';

  @override
  String get quranicDuasFavoriteOff => 'Save';

  @override
  String get quranicDuasCopied => 'Copied to clipboard.';

  @override
  String get quranicDuasShareSubject => 'Du\'a from the Qur\'an';

  @override
  String get khatmDuaTitle => 'Khatm al-Qur\'an supplication';

  @override
  String get khatmDuaSubtitle => 'A calm reading for completion and gratitude';

  @override
  String get khatmDuaLoadError => 'Could not load this page. Try again.';

  @override
  String get khatmDuaAudioSoon =>
      'Audio recitation will be offered in a future update.';

  @override
  String get khatmDuaFooterNote =>
      'This layout is for reading and reflection; follow wording your scholars or community recommend for khatm.';

  @override
  String get duaTopicMercy => 'Mercy';

  @override
  String get duaTopicForgiveness => 'Forgiveness';

  @override
  String get duaTopicRizq => 'Provision';

  @override
  String get duaTopicPatience => 'Patience';

  @override
  String get duaTopicGuidance => 'Guidance';

  @override
  String get duaTopicProtection => 'Protection';

  @override
  String get duaTopicParents => 'Parents';

  @override
  String get duaTopicSuccess => 'Success';

  @override
  String get duaTopicGratitude => 'Gratitude';

  @override
  String get duaTopicKnowledge => 'Knowledge';

  @override
  String get duaTopicRefuge => 'Trust & refuge';

  @override
  String get duaTopicFamily => 'Family';

  @override
  String get duaTopicTaqwa => 'God-consciousness';

  @override
  String get duaTopicHealing => 'Hardship & healing';

  @override
  String duaRefLine(Object surahName, Object ayahPart) {
    return '$surahName · $ayahPart';
  }
}
