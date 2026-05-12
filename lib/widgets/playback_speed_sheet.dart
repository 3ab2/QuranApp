import 'package:flutter/material.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import 'media_full_player_chrome.dart';

/// Compact bottom sheet to pick playback speed (Tilawat / Stories visual style).
Future<double?> showPlaybackSpeedSheet(
  BuildContext context, {
  required List<double> speeds,
  required double current,
  String? title,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final l10n = AppLocalizations.of(context)!;
  final heading = title ?? l10n.playbackSpeedSheetTitle;

  return showModalBottomSheet<double>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (ctx) {
      final viewInsets = MediaQuery.viewInsetsOf(ctx);
      final bottomPad =
          MediaQuery.viewPaddingOf(ctx).bottom.clamp(8, 24).toDouble();
      return AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: viewInsets.bottom),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                heading,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              for (final s in speeds) ...[
                MediaSleepSheetTile(
                  icon: Icons.speed_rounded,
                  label: _formatSpeedLabel(s),
                  colorScheme: cs,
                  onTap: () => Navigator.pop(ctx, s),
                ),
                const SizedBox(height: 6),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String _formatSpeedLabel(double s) {
  final t = s.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  return '${t}x';
}
