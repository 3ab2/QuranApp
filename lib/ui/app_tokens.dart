import 'package:flutter/material.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
}

class AppRadius {
  static const BorderRadius card = BorderRadius.all(Radius.circular(12));
  static const BorderRadius button = BorderRadius.all(Radius.circular(12));
}

class AppShadows {
  static List<BoxShadow> card(BuildContext context) {
    final theme = Theme.of(context);
    return [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: 0.08),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

class AppMotion {
  static const Duration fast = Duration(milliseconds: 200);
}
