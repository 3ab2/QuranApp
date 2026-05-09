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
  String get audioPlayError => 'تعذر تشغيل التلاوة. لا يوجد ملف محلي صالح ولا مصدر إنترنت متاح.';

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
  String get tafsirNetworkError => 'حدث خطأ أثناء الاتصال بالخادم. تأكد من اتصال الإنترنت وحاول مجددًا.';

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
  String get tafsirSearchHint =>
      'ابحث في نص الآية أو اسم السورة أو التفسير المحفوظ…';

  @override
  String get tafsirSearchCacheHint =>
      'بحث التفسير يشمل السور التي فتحتها سابقًا (مخزنة على الجهاز).';

  @override
  String get tafsirSearchEmpty =>
      'لا نتائج. جرّب كلمات أخرى أو افتح سورة مرة لتحميل تفسيرها.';

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
}
