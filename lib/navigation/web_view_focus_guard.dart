import 'dart:ui' show ViewFocusEvent, ViewFocusState;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Web: when the browser view regains focus, Flutter may run reading-order focus
/// traversal on the view scope; stale [Focus] nodes can reference deactivated elements.
/// Parking focus at the root scope first avoids measuring those nodes.
///
/// Register via [register] before [runApp] so this observer runs early in the list.
final webViewFocusGuard = WebViewFocusGuard._();

class WebViewFocusGuard extends WidgetsBindingObserver {
  WebViewFocusGuard._();

  void register() {
    if (!kIsWeb) return;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeViewFocus(ViewFocusEvent event) {
    if (!kIsWeb) return;
    if (event.state != ViewFocusState.focused) return;
    FocusManager.instance.rootScope.requestScopeFocus();
  }
}
