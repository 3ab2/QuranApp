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
}
