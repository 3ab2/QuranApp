import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:quran_app/services/tilawat_audio_handler.dart';
import 'app_navigator.dart';
import 'navigation/tilawat_navigator_observer.dart' show tilawatNavigatorObserver;
import 'navigation/web_view_focus_guard.dart';
import 'providers/settings_provider.dart';
import 'providers/download_provider.dart';
import 'providers/tilawat_audio_controller.dart';
import 'ui/app_scroll.dart';
import 'widgets/tilawat_mini_player_bar.dart';
import 'pages/home_page.dart';
import 'pages/quran_page.dart';
import 'pages/adhan_page.dart';
import 'pages/tafsir_page.dart';
import 'pages/audio_page.dart';
import 'pages/stories_page.dart';
import 'pages/settings_page.dart';
import 'pages/story_detail_page.dart';
import 'pages/surah_detail_page.dart';
import 'data/surah_data.dart';
import 'pages/scientific_miracles_page.dart';
import 'pages/quranic_duas_page.dart';
import 'pages/khatm_quran_dua_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  webViewFocusGuard.register();
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();
  final downloadProvider = DownloadProvider();

  TilawatAudioHandler? tilawatBackgroundHandler;
  if (tilawatUseBackgroundAudioHandler()) {
    tilawatBackgroundHandler = await AudioService.init<TilawatAudioHandler>(
      builder: () => TilawatAudioHandler(
        settings: settingsProvider,
        download: downloadProvider,
      ),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.quran_app.channel.tilawat',
        androidNotificationChannelName: 'Tilawat',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );
  }

  Widget app = MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
      ChangeNotifierProvider<DownloadProvider>.value(value: downloadProvider),
      ChangeNotifierProvider(
        create: (context) {
          final c = TilawatAudioController(
            context.read<SettingsProvider>(),
            context.read<DownloadProvider>(),
            backgroundHandler: tilawatBackgroundHandler,
          );
          c.init();
          return c;
        },
      ),
    ],
    child: const QuranApp(),
  );
  // Avoid ReadingOrder rect sorts for in-app groups (View still uses reading order).
  if (kIsWeb) {
    app = FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: app,
    );
  }
  runApp(app);
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          scrollBehavior: const AppScrollBehavior(),
          navigatorKey: appNavigatorKey,
          navigatorObservers: [tilawatNavigatorObserver],
          builder: (context, child) =>
              TilawatAppShell(child: child ?? const SizedBox.shrink()),
          onGenerateTitle: (context) =>
              AppLocalizations.of(context)?.appTitle ?? 'Quran App',
          debugShowCheckedModeBanner: false,
          theme: settings.getLightThemeData(),
          darkTheme: settings.getDarkThemeData(),
          themeMode: settings.themeMode,
          initialRoute: '/',
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
            Locale('fr'),
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('ar');
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return const Locale('ar');
          },
          routes: {
            '/': (context) => const HomePage(),
            '/quran': (context) => const QuranPage(),
            for (var s in surahs)
              '/surah/${s['number']}': (context) => SurahDetailPage(
                  surahNumber: s['number'], surahName: s['name']),
            '/adhan': (context) => const AdhanPage(),
            '/tafsir': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              int? parseInt(dynamic value) {
                if (value is int) return value;
                if (value is String) {
                  return int.tryParse(value.split(':').first);
                }
                return null;
              }

              return TafsirPage(
                surahNumber: parseInt(args?['surahNumber']),
                ayahNumber: parseInt(args?['ayahNumber']),
              );
            },
            '/audio': (context) => const AudioPage(),
            '/stories': (context) => const StoriesPage(),
            '/scientific-miracles': (context) => const ScientificMiraclesPage(),
            '/quranic-duas': (context) => const QuranicDuasPage(),
            '/khatm-dua': (context) => const KhatmQuranDuaPage(),
            '/settings': (context) => const SettingsPage(),
          },
          onGenerateRoute: (settings) {
            final name = settings.name;
            if (name != null && name.startsWith('/story/')) {
              final id = Uri.decodeComponent(name.substring('/story/'.length));
              if (id.isNotEmpty) {
                return MaterialPageRoute<void>(
                  builder: (context) => StoryDetailPage(id: id),
                  settings: settings,
                  fullscreenDialog: false,
                );
              }
            }
            return null;
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      },
    );
  }
}
