import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_navigator.dart';
import '../l10n/app_localizations.dart';

/// User-visible feedback for tilawat (navigator context via [appNavigatorKey]).
class TilawatPlaybackFeedback {
  TilawatPlaybackFeedback._();

  static void showReciterFallbackIfNeeded({
    required bool usedDefaultReciterFallback,
    required String effectiveReciterName,
  }) {
    if (!usedDefaultReciterFallback) return;
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    final l10n = AppLocalizations.of(ctx);
    if (l10n == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(
          l10n.tilawatReciterFallbackNotice(effectiveReciterName),
          style: GoogleFonts.amiri(),
        ),
      ),
    );
  }
}
