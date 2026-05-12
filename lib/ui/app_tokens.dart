import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global spacing rhythm — prefer these over raw literals in UI code.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Standard horizontal inset for page content (headers, lists, search).
  static const double pageH = 16;

  /// Extra bottom space for scroll views (safe area / mini-player breathing room).
  static const double listBottom = 28;

  /// Vertical gap under [AppPageHeader] before main content.
  static const double afterHeader = 12;
}

/// Corner radii — one family across cards, fields, sheets.
class AppRadius {
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  /// Large pill (secondary controls bar, chips).
  static const double pill = 28;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius button = BorderRadius.all(Radius.circular(md));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(xl));
}

/// Icon hit targets for list rows and headers.
class AppIconSizes {
  static const double sm = 18;
  static const double md = 22;
  static const double lg = 24;
  static const double tile = 20;
}

/// Soft elevation — calm, premium, not “gaming card”.
class AppShadows {
  static List<BoxShadow> card(BuildContext context) {
    final theme = Theme.of(context);
    return [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Slightly stronger (home tiles, floating emphasis).
  static List<BoxShadow> cardElevated(BuildContext context) {
    final theme = Theme.of(context);
    return [
      BoxShadow(
        color: theme.shadowColor.withValues(alpha: 0.07),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

class AppMotion {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 480);
}

/// Typography using Amiri — hierarchy stays consistent app-wide.
class AppTypography {
  static TextStyle pageTitle(ColorScheme cs) => GoogleFonts.amiri(
        color: cs.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle sectionTitle(ColorScheme cs) => GoogleFonts.amiri(
        color: cs.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle listTitle(ColorScheme cs) => GoogleFonts.amiri(
        color: cs.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle body(ColorScheme cs, {double opacity = 1}) => GoogleFonts.amiri(
        color: cs.onSurface.withValues(alpha: opacity),
        fontSize: 16,
        height: 1.45,
      );

  static TextStyle caption(ColorScheme cs, {double opacity = 0.62}) =>
      GoogleFonts.amiri(
        color: cs.onSurface.withValues(alpha: opacity),
        fontSize: 12,
        height: 1.3,
      );

  static TextStyle captionDense(ColorScheme cs, {double opacity = 0.55}) =>
      GoogleFonts.amiri(
        color: cs.onSurface.withValues(alpha: opacity),
        fontSize: 11,
        height: 1.2,
      );
}

/// Shared [InputDecoration] for search / compact fields (visual only).
class AppInputDecorations {
  static InputDecoration searchField(
    BuildContext context, {
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    bool isDense = true,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.22)),
    );
    return InputDecoration(
      hintText: hintText,
      isDense: isDense,
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.38),
      contentPadding: contentPadding,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: cs.primary.withValues(alpha: 0.55),
          width: 1.4,
        ),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  /// Dense outlined field (dropdowns, numeric jump).
  static InputDecoration compactOutline(
    BuildContext context, {
    String? labelText,
    String? hintText,
    EdgeInsetsGeometry contentPadding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.22)),
    );
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      isDense: true,
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: contentPadding,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(
          color: cs.primary.withValues(alpha: 0.55),
          width: 1.4,
        ),
      ),
    );
  }
}
