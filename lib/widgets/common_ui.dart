import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ui/app_tokens.dart';
import 'back_button_widget.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      margin: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageH,
            vertical: AppSpacing.xs,
          ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.card(context),
        border: Border.all(color: cs.outline.withValues(alpha: 0.07)),
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? trailing;

  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const BackButtonWidget(),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.pageTitle(cs),
                  textAlign: TextAlign.center,
                ),
              ),
              if (trailing != null && trailing!.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: trailing!,
                ),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTypography.captionDense(cs),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Section label in settings-style lists.
class AppSectionTitle extends StatelessWidget {
  final String text;

  const AppSectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.md, 0, AppSpacing.sm),
      child: Text(text, style: AppTypography.sectionTitle(cs)),
    );
  }
}

/// Unified expandable search field (Quran, Tafsir, miracles, etc.).
class AppSearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextDirection? textDirection;
  final TextStyle? style;
  final Widget? prefixIcon;
  final bool showClearButton;

  const AppSearchTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.focusNode,
    this.textDirection,
    this.style,
    this.prefixIcon,
    this.showClearButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle =
        style ?? GoogleFonts.amiri(fontSize: 15, color: cs.onSurface);

    Widget? suffix;
    if (showClearButton) {
      suffix = ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.text.isEmpty) {
            return const SizedBox(width: 0, height: 0);
          }
          return IconButton(
            icon: Icon(Icons.clear_rounded, size: AppIconSizes.md, color: cs.onSurface.withValues(alpha: 0.55)),
            onPressed: () {
              controller.clear();
              onChanged?.call('');
            },
          );
        },
      );
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      textDirection: textDirection,
      style: textStyle,
      decoration: AppInputDecorations.searchField(
        context,
        hintText: hintText,
        prefixIcon: prefixIcon ??
            Icon(Icons.search_rounded, size: AppIconSizes.md, color: cs.primary.withValues(alpha: 0.85)),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: onChanged,
    );
  }
}

/// Choice chip row item — consistent borders and typography.
class AppFilterChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final ColorScheme colorScheme;

  const AppFilterChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.amiri(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
      ),
      selected: selected,
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
      side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.22)),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      onSelected: onSelected,
    );
  }
}

class AppLoadingView extends StatelessWidget {
  final String label;

  const AppLoadingView({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: cs.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.body(cs, opacity: 0.85)),
        ],
      ),
    );
  }
}

class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 44),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.body(cs),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: AppIconSizes.lg),
                label: Text(retryLabel ?? 'Retry', style: GoogleFonts.amiri(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact “support topic” row inside [AppCard] styling (margin supplied by parent).
class AppSupportHintCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? footer;

  const AppSupportHintCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: cs.primary, size: AppIconSizes.lg),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: AppTypography.listTitle(cs)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(body, style: AppTypography.body(cs, opacity: 0.9)),
                  ],
                ),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.sm),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Calm FAQ row — matches card radius and avoids heavy dividers.
class AppExpandableInfoCard extends StatelessWidget {
  final String title;
  final String body;

  const AppExpandableInfoCard({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(AppRadius.md);
    return AppCard(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            childrenPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: radius),
            collapsedShape: RoundedRectangleBorder(borderRadius: radius),
            iconColor: cs.primary,
            collapsedIconColor: cs.onSurface.withValues(alpha: 0.5),
            title: Text(title, style: AppTypography.listTitle(cs)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    body,
                    style: AppTypography.body(cs, opacity: 0.9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppFeedback {
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: GoogleFonts.amiri())),
    );
  }

  static void showError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.amiri()),
        backgroundColor: cs.error,
      ),
    );
  }
}
