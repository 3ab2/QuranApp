import 'package:flutter/material.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

/// Keep in sync with `pubspec.yaml` version field (user-facing label only).
const String _kAppVersionDisplay = '1.0.0';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    Widget section(String title, String body) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSectionTitle(text: title),
            AppCard(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(body, style: AppTypography.body(cs, opacity: 0.92)),
            ),
          ],
        );

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(
                title: l10n.topBarAbout,
                subtitle: l10n.aboutSubtitle,
              ),
              const SizedBox(height: AppSpacing.afterHeader),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageH,
                    0,
                    AppSpacing.pageH,
                    AppSpacing.listBottom,
                  ),
                  children: [
                    AppCard(
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
                                  color: cs.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.mosque_rounded,
                                    color: cs.primary,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  l10n.aboutHeroMission,
                                  style: AppTypography.listTitle(cs),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    section(
                      l10n.aboutSectionMissionTitle,
                      l10n.aboutSectionMissionBody,
                    ),
                    Row(
                      children: [
                        _AboutGlyph(
                          icon: Icons.menu_book_rounded,
                          label: l10n.homeQuran,
                          cs: cs,
                        ),
                        _AboutGlyph(
                          icon: Icons.library_books_rounded,
                          label: l10n.homeTafsir,
                          cs: cs,
                        ),
                        _AboutGlyph(
                          icon: Icons.record_voice_over_rounded,
                          label: l10n.homeAudio,
                          cs: cs,
                        ),
                        _AboutGlyph(
                          icon: Icons.auto_stories_rounded,
                          label: l10n.homeStories,
                          cs: cs,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        l10n.aboutIllustrationCaption,
                        textAlign: TextAlign.center,
                        style: AppTypography.caption(cs),
                      ),
                    ),
                    section(l10n.aboutSectionVisionTitle, l10n.aboutSectionVisionBody),
                    section(l10n.aboutSectionWhyTitle, l10n.aboutSectionWhyBody),
                    AppSectionTitle(text: l10n.aboutSectionPillarsTitle),
                    AppCard(
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PillarLine(icon: Icons.menu_book_outlined, text: l10n.aboutPillarQuran, cs: cs),
                          const Divider(height: AppSpacing.lg),
                          _PillarLine(icon: Icons.library_books_outlined, text: l10n.aboutPillarTafsir, cs: cs),
                          const Divider(height: AppSpacing.lg),
                          _PillarLine(icon: Icons.headphones_rounded, text: l10n.aboutPillarTilawat, cs: cs),
                          const Divider(height: AppSpacing.lg),
                          _PillarLine(icon: Icons.auto_stories_outlined, text: l10n.aboutPillarStories, cs: cs),
                        ],
                      ),
                    ),
                    section(l10n.aboutSectionPrivacyTitle, l10n.aboutSectionPrivacyBody),
                    section(l10n.aboutSectionOfflineTitle, l10n.aboutSectionOfflineBody),
                    section(l10n.aboutSectionLangTitle, l10n.aboutSectionLangBody),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          child: Text(
                            l10n.aboutAppVersion(_kAppVersionDisplay),
                            style: AppTypography.caption(cs, opacity: 0.85),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.aboutCreditsLine,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption(cs, opacity: 0.55),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutGlyph extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme cs;

  const _AboutGlyph({
    required this.icon,
    required this.label,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: cs.primary.withValues(alpha: 0.85), size: 26),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption(cs, opacity: 0.75),
          ),
        ],
      ),
    );
  }
}

class _PillarLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme cs;

  const _PillarLine({
    required this.icon,
    required this.text,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppIconSizes.md, color: cs.primary.withValues(alpha: 0.85)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTypography.body(cs, opacity: 0.9))),
      ],
    );
  }
}
