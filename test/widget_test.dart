import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran_app/main.dart';
import 'package:quran_app/providers/download_provider.dart';
import 'package:quran_app/providers/settings_provider.dart';
import 'package:quran_app/providers/tilawat_audio_controller.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsProvider();
    await settings.loadSettings();
    final download = DownloadProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(value: settings),
          ChangeNotifierProvider<DownloadProvider>.value(value: download),
          ChangeNotifierProvider(
            create: (_) => TilawatAudioController(settings, download),
          ),
        ],
        child: const QuranApp(),
      ),
    );

    expect(find.byType(QuranApp), findsOneWidget);
  });
}
