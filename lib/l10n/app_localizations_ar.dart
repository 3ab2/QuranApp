// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق القرآن';

  @override
  String get homeQuran => 'القرآن';

  @override
  String get homeTafsir => 'التفسير';

  @override
  String get homeAudio => 'التلاوات';

  @override
  String get homeStories => 'قصص الأنبياء';

  @override
  String get homeAdhan => 'الأذان';

  @override
  String get homeMiracles => 'المعجزات';

  @override
  String get homeSettings => 'الإعدادات';

  @override
  String get topBarAbout => 'حول التطبيق';

  @override
  String get topBarHelp => 'المساعدة';

  @override
  String get topBarRate => 'قيمنا';

  @override
  String get topBarSources => 'المصادر الموثوقة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsAdhanEnabled => 'تفعيل الأذان';

  @override
  String get settingsDarkMode => 'الوضع الليلي';

  @override
  String get settingsPrayerReminder => 'تذكير بالصلاة';

  @override
  String get settingsSelectReciter => 'اختيار القارئ';

  @override
  String get settingsSelectLanguage => 'اختيار اللغة';

  @override
  String get settingsVolume => 'مستوى الصوت';

  @override
  String get settingsClearTempData => 'حذف البيانات المؤقتة';

  @override
  String get settingsTempDataDeleted => 'تم حذف البيانات المؤقتة';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get audioPageTitle => 'الاستماع للتلاوة';

  @override
  String get audioLoadError => 'تعذر تحميل قائمة السور الصوتية.';

  @override
  String get audioLocalPlayback => 'يتم التشغيل من الملف المحلي المحمّل';

  @override
  String get audioPlayError =>
      'تعذر تشغيل التلاوة. لا يوجد ملف محلي صالح ولا مصدر إنترنت متاح.';

  @override
  String get adhanPageTitle => 'الأذان وأوقات الصلاة';

  @override
  String get adhanLoadingPrayerTimes => 'جاري تحميل أوقات الصلاة...';

  @override
  String get adhanLocationNotDetected => 'لم يتم تحديد موقعك';

  @override
  String get adhanLocationPrompt => 'اضغط على زر الإعدادات لاختيار الموقع';

  @override
  String get adhanLocationSettings => 'إعدادات الموقع';

  @override
  String get tafsirTitle => 'التفسير الميسر';

  @override
  String get tafsirLoading => 'جاري تحميل التفسير...';

  @override
  String get tafsirRetry => 'إعادة المحاولة';

  @override
  String get tafsirFetchError => 'تعذر جلب التفسير. الرجاء المحاولة لاحقًا.';

  @override
  String get tafsirNetworkError =>
      'حدث خطأ أثناء الاتصال بالخادم. تأكد من اتصال الإنترنت وحاول مجددًا.';

  @override
  String tafsirContextTitle(Object surah, Object ayah) {
    return 'التفسير - سورة $surah آية $ayah';
  }

  @override
  String get storyPlay => 'تشغيل القصة';

  @override
  String get storyPauseAudio => 'إيقاف مؤقت';

  @override
  String get playbackSpeedSheetTitle => 'سرعة التشغيل';

  @override
  String get storyYoutubeStreamUnavailable =>
      'تعذّر بدء بث السرد. تحقّق من الاتصال ثم أعد المحاولة.';

  @override
  String get storyYoutubeWebAudioUnavailable =>
      'التشغيل الكامل للقصص في الخلفية غير متاح في متصفّح الويب. استخدم التطبيق على الهاتف أو الجهاز اللوحي.';

  @override
  String get storyStop => 'إيقاف الصوت';

  @override
  String get storyAudioError => 'تعذر تشغيل صوت القصة.';

  @override
  String get storyNoAudio => 'لا تتوفر رواية صوتية لهذه القصة';

  @override
  String get storyLoadError => 'القصص غير متاحة حاليًا.';

  @override
  String get storyRetry => 'إعادة المحاولة';

  @override
  String get storyReadDone => 'تمت القراءة';

  @override
  String get prophetStoriesSearchHint => 'ابحث عن نبي أو قصة…';

  @override
  String get prophetStoriesSearchEmpty =>
      'لا توجد قصص مطابقة. جرّب كلمات أخرى.';

  @override
  String get prophetStoriesSearchOpenTooltip => 'البحث في القصص';

  @override
  String get surahSearchHint => 'ابحث في الآيات...';

  @override
  String get surahIncreaseFont => 'تكبير الخط';

  @override
  String get surahDecreaseFont => 'تصغير الخط';

  @override
  String get surahOpenTafsir => 'فتح التفسير';

  @override
  String get tafsirUnavailableForAyah => 'لا يتوفر تفسير لهذا السياق.';

  @override
  String get surahOpenTafsirCurrentAyah => 'فتح التفسير للآية المحددة';

  @override
  String get tafsirSourceMuyassarNote =>
      'المصدر الأساسي: التفسير الميسر (عربي) عبر Quran.com. تفاسير إضافية لاحقًا.';

  @override
  String get tafsirSelectSurah => 'السورة';

  @override
  String get tafsirBrowseSurahs => 'السور';

  @override
  String get tafsirAyahNumber => 'الآية';

  @override
  String get tafsirGo => 'انتقال';

  @override
  String get tafsirSearchHint => 'آية، تفسير، سورة، أو موضوع علمي…';

  @override
  String get tafsirSearchCacheHint =>
      'يشمل الصفحة والسور المحفوظة ومواضيع الإعجاز.';

  @override
  String get tafsirSearchEmpty =>
      'لا نتائج. جرّب كلمات أخرى أو افتح سورة لتحميل تفسيرها.';

  @override
  String get tafsirJumpInvalidAyah => 'أدخل رقم آية صالح لهذه السورة.';

  @override
  String get tafsirJumpNotInFeed =>
      'هذه الآية غير موجودة في القائمة. قد لا تتوفر في المصدر لهذه السورة.';

  @override
  String get miraclesOpenTafsir => 'فتح التفسير الميسر';

  @override
  String get miraclesContinueInTafsirPage => 'متابعة القراءة في صفحة التفسير';

  @override
  String get miraclesLoading => 'جاري التحميل…';

  @override
  String get miraclesTafsirPreview => 'معاينة التفسير';

  @override
  String get miraclesModerateNote =>
      'ملاحظات تعليمية موجزة؛ راجع أهل العلم للعقيدة والفقه.';

  @override
  String get miraclesPageTitle => 'الإعجاز العلمي في القرآن';

  @override
  String get miraclesSearchHint => 'ابحث عن آية أو موضوع أو وصف علمي…';

  @override
  String get miraclesEmptyResults => 'لا توجد نتائج';

  @override
  String get miraclesFilterAll => 'الكل';

  @override
  String get quranContinueReading => 'متابعة';

  @override
  String get quranBookmarkSaved => 'تم حفظ موضع القراءة.';

  @override
  String get quranSurahPickerHint => 'ابحث عن سورة…';

  @override
  String get quranSurahNumberLabel => 'سورة';

  @override
  String get quranMadaniShort => 'مدنية';

  @override
  String get quranMakkiShort => 'مكية';

  @override
  String get quranSearchClose => 'إغلاق البحث';

  @override
  String get quranSearchOpen => 'بحث في القرآن';

  @override
  String get quranSaveBookmark => 'حفظ موضع القراءة';

  @override
  String get quranLineSpacingIncrease => 'زيادة تباعد الأسطر';

  @override
  String get quranLineSpacingDecrease => 'تقليل تباعد الأسطر';

  @override
  String get quranMushafModeToggle => 'عرض المصحف (قريبًا)';

  @override
  String get quranReaderSearchHint => 'نص الآية أو اسم السورة أو الرقم…';

  @override
  String get quranSearchEmpty => 'لا نتائج. جرّب كلمات أخرى أو رقم السورة.';

  @override
  String get quranBackToHome => 'الرئيسية';

  @override
  String get tilawatDownloadComplete => 'تم حفظ السورة للاستماع دون اتصال.';

  @override
  String get tilawatDownloadFailed => 'فشل التحميل. تحقق من الاتصال.';

  @override
  String get tilawatDownloaded => 'تم التحميل';

  @override
  String get tilawatDownloadForOffline => 'تحميل للاستماع دون اتصال';

  @override
  String get tilawatAutoPlayNext => 'تشغيل السورة التالية تلقائيًا';

  @override
  String get tilawatSleepTimer => 'مؤقت النوم';

  @override
  String get tilawatSleepOff => 'إيقاف';

  @override
  String tilawatSleepMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String tilawatSleepEndsAt(String time) {
    return 'يتوقف التشغيل حوالي $time';
  }

  @override
  String get tilawatContinueListening => 'متابعة الاستماع';

  @override
  String get tilawatTooltipSleepTimer => 'مؤقت النوم — اختر وقت إيقاف التشغيل';

  @override
  String get tilawatTooltipDownload => 'تحميل للاستماع دون اتصال';

  @override
  String get tilawatTooltipAutoNext => 'تشغيل السورة التالية تلقائيًا';

  @override
  String get tilawatTooltipRepeatOne => 'تكرار هذه السورة';

  @override
  String tilawatReciterFallbackNotice(String name) {
    return 'تعذر تحميل صوت القارئ المختار. سيتم التشغيل بالقارئ الافتراضي ($name).';
  }

  @override
  String get tilawatSleepChooseDuration => 'اختر المدة';

  @override
  String get tilawatSleepOneHour => 'ساعة';

  @override
  String get tilawatSleepOneHourThirty => 'ساعة ونصف';

  @override
  String get tilawatSleepTwoHours => 'ساعتان';

  @override
  String tilawatSleepActiveRemaining(int minutes) {
    return 'متبقي $minutes د';
  }

  @override
  String get storyYoutubePlayerTitle => 'سرد القصة';

  @override
  String get storyYoutubeUnavailable =>
      'لا يوجد ربط حالي بسرد موثّق على يوتيوب لهذه القصة.';

  @override
  String get storyYoutubeInvalidChannel => 'هذا الفيديو ليس من قناة معتمدة.';

  @override
  String get storyYoutubeLoadError =>
      'تعذّر تحميل مشغّل يوتيوب. تحقّق من الاتصال وحاول مرة أخرى.';

  @override
  String get storyYoutubeNarrator => 'المُرَوّي';

  @override
  String get storyYoutubePrevious => 'القصة السابقة';

  @override
  String get storyYoutubeNext => 'القصة التالية';

  @override
  String get storyYoutubeBackgroundHint =>
      'يعتمد التشغيل في الخلفية على الجهاز؛ أبقِ التطبيق في التطبيقات الأخيرة لأفضل نتيجة.';

  @override
  String get storyYoutubeOpenPlayer => 'الاستماع للقصة';

  @override
  String get storyYoutubeNoNarration => 'لا يتوفر سرد صوتي/مرئي لهذه القصة.';

  @override
  String get storyYoutubeSleepTimer => 'مؤقت النوم';

  @override
  String get storyYoutubeSleepOff => 'إيقاف';

  @override
  String storyYoutubeSleepMinutes(int minutes) {
    return 'إيقاف بعد $minutes د';
  }

  @override
  String get storyYoutubeSleepEnded => 'أوقف مؤقت النوم التشغيل.';

  @override
  String storyYoutubePlaybackSpeedLabel(String speed) {
    return '${speed}x';
  }

  @override
  String get storyYoutubeCopyLink => 'نسخ رابط الفيديو';

  @override
  String get storyYoutubeLinkCopied => 'تم نسخ رابط يوتيوب.';

  @override
  String get storyYoutubeFullscreen => 'ملء الشاشة';

  @override
  String get storyYoutubeDownloadHint =>
      'استخدم أيقونة الرابط لنسخ عنوان المشاهدة. تنزيل فيديو يوتيوب للعمل دون اتصال غير متاح في هذا التطبيق.';

  @override
  String get prayerPhaseCalm => 'الصلاة القادمة';

  @override
  String get prayerPhaseApproaching => 'اقترب وقت الصلاة';

  @override
  String get prayerPhaseAtAdhan => 'حان وقت الصلاة';

  @override
  String get prayerPhaseGrace => 'خذ نفسًا هادئًا';

  @override
  String prayerCountdownRemaining(String hms) {
    return 'المتبقي: $hms';
  }

  @override
  String prayerCurrentPeriod(String name) {
    return 'الفترة الحالية: $name';
  }

  @override
  String get prayerAtAdhanMoment => 'وقت الأذان — ليّن القلب نحو الله';

  @override
  String get prayerOpenQibla => 'القبلة';

  @override
  String get prayerAdhanStop => 'إيقاف';

  @override
  String get prayerAdhanSnooze => 'تأجيل';

  @override
  String get prayerAdhanMute => 'كتم';

  @override
  String get prayerAdhanUnmute => 'صوت';

  @override
  String get prayerImmersiveHint => 'حركة خفيفة فقط — لأجواء روحانية هادئة';

  @override
  String get prayerQiblaTitle => 'القبلة';

  @override
  String get prayerQiblaWebUnavailable =>
      'بوصلة القبلة المباشرة تحتاج حساسات الجهاز وتتوفر في تطبيق الهاتف.';

  @override
  String get prayerQiblaLocationDisabled =>
      'فعّل الموقع والأذونات لاستخدام بوصلة القبلة.';

  @override
  String get prayerQiblaError => 'تعذّر قراءة البوصلة على هذا الجهاز.';

  @override
  String get prayerQiblaEmulatorUnavailable =>
      'حساسات البوصلة غير متوفرة على هذا الجهاز أو المحاكي. استخدم دليل القبلة الثابت أدناه.';

  @override
  String prayerQiblaDistanceKm(String km) {
    return 'نحو $km كم إلى الكعبة';
  }

  @override
  String get prayerQiblaAlignedHint => 'أنت باتجاه القبلة — تقبّل الله صلاتك';

  @override
  String get prayerQiblaRotateHint =>
      'درّب الجهاز برفق حتى تستقر الإشارة نحو الكعبة';

  @override
  String get prayerQiblaFallbackSubtitle => 'اتجاه القبلة من موقعك';

  @override
  String get prayerQiblaFallbackExplanation =>
      'البوصلة المباشرة تحتاج إلى حساسات الهاتف مثل المغناطيسية والاتجاه، وهي تعمل بشكل كامل داخل تطبيق الهاتف.';

  @override
  String get prayerQiblaFallbackBrowserNote =>
      'متصفحات الويب وأجهزة الحاسوب قد لا تتيح الحساسات اللازمة للبوصلة الحية.';

  @override
  String get prayerQiblaFallbackStaticHint =>
      'اتجاه القبلة التقريبي من موقعك المحفوظ';

  @override
  String prayerQiblaFallbackAngle(String angle) {
    return 'زاوية القبلة: $angle من الشمال';
  }

  @override
  String get prayerQiblaFallbackLocationTitle => 'موقعك';

  @override
  String get prayerQiblaFallbackLocationUnknown => 'لم يُحدَّد الموقع بعد';

  @override
  String get prayerQiblaFallbackLocationHint =>
      'اختر مدينتك في صفحة الصلاة لمعرفة زاوية القبلة عندك.';

  @override
  String get prayerQiblaFallbackKaabaTitle => 'نحو الكعبة';

  @override
  String get prayerQiblaFallbackMobileTitle => 'بوصلة حية على الهاتف';

  @override
  String get prayerQiblaFallbackMobileBody =>
      'افتح التطبيق على هاتفك لبوصلة تتبع حركتك نحو القبلة لحظة بلحظة.';

  @override
  String get prayerQiblaFallbackDragHint =>
      'اسحب برفق للاستكشاف — اترك لإعادة المحاذاة مع القبلة';

  @override
  String get prayerQiblaFallbackInfoTitle => 'القبلة في لمحة';

  @override
  String get prayerQiblaFallbackAngleLabel => 'زاوية القبلة';

  @override
  String get prayerQiblaFallbackDistanceLabel => 'إلى الكعبة';

  @override
  String get prayerQiblaFallbackHeadingLabel => 'وضع البوصلة';

  @override
  String get prayerQiblaFallbackHeadingValue => 'دليل ثابت';

  @override
  String get prayerSettingsReminder => 'تذكير قبل الصلاة';

  @override
  String get prayerReminderEnabledHelp =>
      'إشعار بسيط قبل كل صلاة ببضع دقائائق للاستعداد.';

  @override
  String get prayerAdhanEnabledHelp =>
      'إشعار عند وقت الصلاة بالضبط وتشغيل الأذان يدوياً من قائمة الصلوات.';

  @override
  String get prayerReminderPreset5 => '5 دقائق';

  @override
  String get prayerReminderPreset10 => '10 دقائق';

  @override
  String get prayerReminderPreset15 => '15 دقيقة';

  @override
  String get prayerReminderCustomHint => 'مخصص (1–120 دقيقة)';

  @override
  String get prayerMuezzinVoice => 'صوت المؤذّن / الأذان';

  @override
  String get prayerPreviewVoice => 'استمع';

  @override
  String get prayerMosqueMode => 'وضع المسجد (تجريبي)';

  @override
  String get prayerMosqueModeHelp =>
      'عند التفعيل يُستدعى خطاف محجوز عند الاقتراب من الصلاة. الوضع الصامت الكامل يحتاج تكاملاً لاحقاً مع النظام.';

  @override
  String get prayerAfterAdhkar => 'بعد الصلاة — أذكار قصيرة';

  @override
  String get prayerAfterAdhkarBody =>
      'سبح الله (33)، والحمد لله (33)، والله أكبر (33) — أو اقرأ آية الكرسي بوقار.';

  @override
  String get prayerSpiritualTip0 => 'ادعُ الله برفق — وهو قريب.';

  @override
  String get prayerSpiritualTip1 => 'ركعتان من الضحى تنيران اليوم.';

  @override
  String get prayerSpiritualTip2 => 'توقّف قبل الصلاة — السكون عبادة.';

  @override
  String get prayerSpiritualTip3 => 'ليصل القلب قبل أن يقوم الجسد.';

  @override
  String get prayerLocationSheetTitle => 'موقع الصلاة';

  @override
  String get prayerLocationAutoGps => 'تلقائي (GPS)';

  @override
  String get prayerLocationAutoGpsSubtitle =>
      'استخدام موقعك الحالي لأوقات الصلاة.';

  @override
  String get prayerLocationUseGpsNow => 'استخدام الموقع الحالي';

  @override
  String get prayerLocationSearchCountry => 'بحث عن دولة';

  @override
  String get prayerLocationSearchCity => 'بحث عن مدينة';

  @override
  String get prayerLocationGpsDenied => 'يلزم إذن الموقع للوضع التلقائي.';

  @override
  String get prayerLocationGpsFailed =>
      'تعذّر قراءة موقعك. جرّب الاختيار اليدوي.';

  @override
  String get aboutSubtitle => 'وضوح، ووقار، وإيقاع يومي هادئ مع كتاب الله.';

  @override
  String get aboutHeroMission => 'رفيق هادئ للقراءة والاستماع والفهم والذكر.';

  @override
  String get aboutSectionMissionTitle => 'الرسالة';

  @override
  String get aboutSectionMissionBody =>
      'تقريب القرآن والتفسير الموثوق والاستماع الطيب من يومك — بلا ضجيج ولا فوضى.';

  @override
  String get aboutSectionVisionTitle => 'الرؤية';

  @override
  String get aboutSectionVisionBody =>
      'تجربة متوازنة روحياً: خط جميل، مصادر محترمة، وأدوات تخدم التركيز لا التشتت.';

  @override
  String get aboutSectionWhyTitle => 'لماذا هذا التطبيق';

  @override
  String get aboutSectionWhyBody =>
      'كثيرون يريدون مكاناً واحداً موثوقاً لمصحف التلاوة، وسياق التفسير، والتلاوات، والصلاة، والقصص بلطف — مبني على الأدب والوضوح.';

  @override
  String get aboutSectionPillarsTitle => 'ماذا ستجد هنا';

  @override
  String get aboutPillarQuran => 'قارئ قرآن مع بحث وعلامات وخط عربي مريح.';

  @override
  String get aboutPillarTafsir => 'تفسير الميسّر بجانب الآيات لسياق أوضح.';

  @override
  String get aboutPillarTilawat => 'تلاوات مع تنزيل للسفر وضعف الشبكة.';

  @override
  String get aboutPillarStories =>
      'قصص الأنبياء بسياسة سرد محكمة ومراجع مختارة.';

  @override
  String get aboutSectionPrivacyTitle => 'الخصوصية والاحترام';

  @override
  String get aboutSectionPrivacyBody =>
      'نفضّل العمل محلياً حيث أمكن، وتجربة بلا مفاجآت، وخيارات محتوى تحترم حرمة النص وحدود أهل العلم.';

  @override
  String get aboutSectionOfflineTitle => 'التصميم بروح «أوفلاين أولاً»';

  @override
  String get aboutSectionOfflineBody =>
      'النص الأساسي والتنزيلات مخصصة لتعمل عند انقطاع الشبكة — ليبقى الذكر في المتناول.';

  @override
  String get aboutSectionLangTitle => 'تعدد اللغات';

  @override
  String get aboutSectionLangBody =>
      'واجهة بالعربية والإنجليزية والفرنسية لتسهيل التنقل على العائلات والطلاب.';

  @override
  String get aboutIllustrationCaption => 'بارك الله فيكم لمشاركتنا هذا الطريق.';

  @override
  String aboutAppVersion(Object version) {
    return 'الإصدار $version';
  }

  @override
  String get aboutCreditsLine =>
      'صُنع بعناية للأمة. كل خير من الله، وما كان من خطأ فمنا.';

  @override
  String get helpSubtitle =>
      'إجابات مختصرة وتنسيق هادئ — لتقضي وقتاً أقل في البحث وأكثر في النفع.';

  @override
  String get helpCardIntro =>
      'استخدم الأقسام أدناه للتوجيه السريع، ثم افتح الأسئلة الشائعة للتفاصيل.';

  @override
  String get helpSectionGuides => 'أدلة سريعة';

  @override
  String get helpGuideQuranTitle => 'صفحة القرآن';

  @override
  String get helpGuideQuranBody =>
      'افتح سورة، عدّل الخط والتباعد، ابحث في الآيات، وانتقل للتفسير من أدوات القارئ.';

  @override
  String get helpGuideTilawatTitle => 'التلاوات';

  @override
  String get helpGuideTilawatBody =>
      'اختر القارئ من الإعدادات، شغّل من صفحة الصوت، وسّع الشريط المصغّر، واستخدم المشغّل الكامل للسرعة والتكرار.';

  @override
  String get helpGuideDownloadTitle => 'تنزيل السور';

  @override
  String get helpGuideDownloadBody =>
      'استخدم تنزيل التلاوة حيث يتوفر؛ تُخزَّن الملفات للتشغيل دون اتصال عندما يسمح المضيف.';

  @override
  String get helpGuidePrayerNotifyTitle => 'تنبيهات الصلاة';

  @override
  String get helpGuidePrayerNotifyBody =>
      'فعّل التذكير من الإعدادات، وحدّد الموقع في الأذان، واسمح بالإشعارات لتصل التنبيهات بهدوء.';

  @override
  String get helpGuideBackgroundAudioTitle => 'الصوت في الخلفية';

  @override
  String get helpGuideBackgroundAudioBody =>
      'يمكن أن تستمر التلاوة أثناء التصفح؛ سرد القصص قد يكون محدوداً على المتصفح — استخدم التطبيق على الهاتف للاستماع الكامل.';

  @override
  String get helpGuideBookmarkTitle => 'العلامات والموضع';

  @override
  String get helpGuideBookmarkBody =>
      'احفظ موضع القراءة من صفحة السورة عند توفر الخيار؛ عُد لاحقاً من نقاط «متابعة القراءة» في صفحة القرآن.';

  @override
  String get helpSectionFaq => 'الأسئلة الشائعة';

  @override
  String get helpFaqQuranTitle => 'كيف أبحث داخل السورة؟';

  @override
  String get helpFaqQuranBody =>
      'افتح السورة، فعّل البحث من شريط الأدوات، اكتب عبارة أو رقم سورة، ثم المس النتيجة للانتقال.';

  @override
  String get helpFaqTilawatTitle => 'لماذا يتوقف الصوت عند مغادرة الصفحة؟';

  @override
  String get helpFaqTilawatBody =>
      'إذا اختفى الشريط المصغّر أعد التشغيل من التلاوات؛ قد يوقف المتصفح الصوت ما لم تكن جلسة المشغّل نشطة.';

  @override
  String get helpFaqDownloadTitle => 'لماذا فشل التنزيل؟';

  @override
  String get helpFaqDownloadBody =>
      'تحقق من الاتصال والمساحة؛ قد يتعطل المضيف مؤقتاً — أعد المحاولة بعد دقائق.';

  @override
  String get helpFaqNotifyTitle => 'لا تصلني تنبيهات الصلاة';

  @override
  String get helpFaqNotifyBody =>
      'تأكد من إذن الإشعارات وتقييدات البطارية لدى بعض الشركات، وتحقق من الموقع أو المدينة اليدوية لصحة المواقيت.';

  @override
  String get helpFaqBgAudioTitle =>
      'هل أستطيع سماع القصص في الخلفية على الويب؟';

  @override
  String get helpFaqBgAudioBody =>
      'المتصفحات تحدّ الوسائط في الخلفية؛ ثبّت نسخة أندرويد للاستماع مع إطفاء الشاشة.';

  @override
  String get helpFaqBookmarkTitle => 'أين تُحفظ علامتي؟';

  @override
  String get helpFaqBookmarkBody =>
      'تُحفظ على هذا الجهاز لاستئناف القراءة محلياً — لا تُرفع إلى خادم.';

  @override
  String get helpFaqTroubleTitle => 'إصلاح أعطال عام';

  @override
  String get helpFaqTroubleBody =>
      'أعد تشغيل التطبيق، وتأكد أن التاريخ والوقت تلقائيان، حدّث الإصدار، وإذا تكرر الخطأ لاحظ الصفحة التي كنت عليها قبل مراسلتنا.';

  @override
  String get rateSubtitle => 'نجومكم ترفع الفريق وتدعم التحسين المستمر.';

  @override
  String get rateHeroTitle => 'جزاكم الله خيراً';

  @override
  String get rateHeroBody =>
      'إن نفعكم القرآن أو الصلاة، فتقييم لطيف ينشر النفع لمن يبحث.';

  @override
  String get rateStarsCaption => 'خمس قلوب خلف خمس نجوم — شكراً لثقتكم.';

  @override
  String get rateBtnStore => 'قيّم على متجر Play';

  @override
  String get rateBtnShare => 'شارك التطبيق';

  @override
  String get rateBtnFeedback => 'أرسل ملاحظة';

  @override
  String get rateSnackStoreFail => 'تعذّر فتح المتجر من هذا الجهاز.';

  @override
  String get rateSnackShareFail => 'تعذّر فتح نافذة المشاركة.';

  @override
  String get rateSnackMailFail => 'تعذّر فتح تطبيق البريد على هذا الجهاز.';

  @override
  String rateShareText(Object url) {
    return 'جرّب تطبيق القرآن: $url';
  }

  @override
  String get rateFeedbackSubject => 'ملاحظات تطبيق القرآن';

  @override
  String get sourcesSubtitle => 'الشفافية تبني الثقة — هكذا يصلك المحتوى.';

  @override
  String get sourcesIntro =>
      'نفضّل مضيفين معروفين وواجهات برمجية موثقة ونصوص موضّحة المصدر. عند الشك نكون محافظين.';

  @override
  String get sourcesTrustLine => 'مسارات مختارة — لا تجريف مجهول.';

  @override
  String get sourcesVisitWebsite => 'الموقع الرسمي';

  @override
  String get sourcesQuranTitle => 'نص القرآن (المصحف)';

  @override
  String get sourcesQuranBody =>
      'الآيات العربية مضمّنة في التطبيق من مجموعة بخط عثماني يتماشى مع إصدارات Tanzil المعتمدة بشكل واسع.';

  @override
  String get sourcesTafsirTitle => 'التفسير (الميسّر)';

  @override
  String get sourcesTafsirBody =>
      'يُجلب تفسير الميسّر العربي عبر واجهات Quran.com العامة مع معرفات الطبعات الموثقة لدى الخدمة.';

  @override
  String get sourcesPrayerTitle => 'أوقات الصلاة';

  @override
  String get sourcesPrayerBody =>
      'تُرسل الإحداثيات وطريقة الحساب إلى واجهة Aladhan (الشبكة الإسلامية) لعرض المواقيت حسب موقعك.';

  @override
  String get sourcesAudioTitle => 'صوت التلاوة';

  @override
  String get sourcesAudioBody =>
      'البث والتنزيل يستخدمان مرايا قارئ موثوقة مثل MP3 Quran ومصادر مشابهة لـ Quranicaudio في فهرس السور.';

  @override
  String get sourcesStoriesTitle => 'قصص الأنبياء (السرد)';

  @override
  String get sourcesStoriesBody =>
      'سرد يوتيوب مقيّد بسياسة قنوات مسموحة؛ كل قصة تفضّل ربط فيديو واحد موثّق.';

  @override
  String get sourcesMiraclesTitle => 'قسم المعجزات العلمية';

  @override
  String get sourcesMiraclesBody =>
      'مواضيع مختارة بصياغة معتدلة وروابط آيات صريحة؛ تلميحات تعليمية — وليست فتوى أو كتاب عقيدة.';

  @override
  String get sourcesOpenLinkFailed => 'تعذّر فتح هذا الرابط على هذا الجهاز.';

  @override
  String get homeQuranicDuas => 'أدعية من القرآن';

  @override
  String get homeKhatmDua => 'دعاء ختم القرآن';

  @override
  String get quranicDuasTitle => 'أدعية من القرآن الكريم';

  @override
  String get quranicDuasSearchHint => 'ابحث في النص أو الموضوع أو السورة…';

  @override
  String get quranicDuasSearchOpenTooltip => 'البحث في الأدعية';

  @override
  String get quranicDuasFilterTooltip => 'تصفية حسب السورة والموضوع';

  @override
  String get quranicDuasFilterTitle => 'التصفية';

  @override
  String get quranicDuasAllSurahs => 'كل السور';

  @override
  String get quranicDuasAllTopics => 'كل المواضيع';

  @override
  String get quranicDuasApplyFilters => 'تطبيق';

  @override
  String get quranicDuasClearFilters => 'مسح التصفية';

  @override
  String get quranicDuasEmpty => 'لا توجد أدعية مطابقة لبحثك أو تصفيتك.';

  @override
  String get quranicDuasLoadError =>
      'تعذّر تحميل الأدعية. أعد المحاولة أو أعد فتح الصفحة.';

  @override
  String get quranicDuasOpenQuran => 'فتح في المصحف';

  @override
  String get quranicDuasOpenTafsir => 'فتح التفسير';

  @override
  String get quranicDuasCopy => 'نسخ';

  @override
  String get quranicDuasShare => 'مشاركة';

  @override
  String get quranicDuasFavoriteOn => 'محفوظ محليًا';

  @override
  String get quranicDuasFavoriteOff => 'حفظ';

  @override
  String get quranicDuasCopied => 'تم النسخ إلى الحافظة.';

  @override
  String get quranicDuasShareSubject => 'دعاء من القرآن';

  @override
  String get khatmDuaTitle => 'دعاء ختم القرآن الكريم';

  @override
  String get khatmDuaSubtitle => 'قراءة هادئة للختم والشكر';

  @override
  String get khatmDuaLoadError => 'تعذّر تحميل الصفحة. حاول مرة أخرى.';

  @override
  String get khatmDuaAudioSoon => 'ستُتاح تلاوة صوتية في تحديث قادم.';

  @override
  String get khatmDuaFooterNote =>
      'هذا التنسيق للقراءة والتدبر؛ راجع صيغًا مأثورة مع عالم مؤهل أو عادات مجتمعك لختم القرآن.';

  @override
  String get duaTopicMercy => 'رحمة';

  @override
  String get duaTopicForgiveness => 'مغفرة';

  @override
  String get duaTopicRizq => 'رزق';

  @override
  String get duaTopicPatience => 'صبر';

  @override
  String get duaTopicGuidance => 'هدى';

  @override
  String get duaTopicProtection => 'حفظ وعناية';

  @override
  String get duaTopicParents => 'الوالدان';

  @override
  String get duaTopicSuccess => 'توفيق';

  @override
  String get duaTopicGratitude => 'شكر وبر';

  @override
  String get duaTopicKnowledge => 'علم';

  @override
  String get duaTopicRefuge => 'توكل وملجأ';

  @override
  String get duaTopicFamily => 'أسرة وذرية';

  @override
  String get duaTopicTaqwa => 'تقوى';

  @override
  String get duaTopicHealing => 'بلاء وشفاء';

  @override
  String duaRefLine(Object surahName, Object ayahPart) {
    return '$surahName · $ayahPart';
  }
}
