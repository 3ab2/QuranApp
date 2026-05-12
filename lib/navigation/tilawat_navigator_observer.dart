import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../app_navigator.dart'
    show storyNarrationFullPlayerRouteName, tilawatFullPlayerRouteName;

/// Single instance — do not recreate on every [MaterialApp] rebuild.
final tilawatNavigatorObserver = TilawatNavigatorObserver._();

/// Clears primary focus after closing the tilawat full-screen route so the web
/// engine does not traverse stale [Focus] nodes on tab focus changes.
class TilawatNavigatorObserver extends NavigatorObserver {
  TilawatNavigatorObserver._();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        // Any route pop can leave primary focus on a deactivated subtree on web.
        FocusManager.instance.primaryFocus?.unfocus(
          disposition: UnfocusDisposition.previouslyFocusedChild,
        );
        return;
      }
      if (route.settings.name == tilawatFullPlayerRouteName ||
          route.settings.name == storyNarrationFullPlayerRouteName) {
        FocusManager.instance.primaryFocus?.unfocus(
          disposition: UnfocusDisposition.previouslyFocusedChild,
        );
      }
    });
  }
}
