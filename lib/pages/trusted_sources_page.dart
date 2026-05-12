import 'package:flutter/material.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

class TrustedSourcesPage extends StatelessWidget {
  const TrustedSourcesPage({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        AppFeedback.showInfo(context, l10n.sourcesOpenLinkFailed);
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedback.showInfo(context, l10n.sourcesOpenLinkFailed);
      }
    }
  }

  Widget _linkButton(BuildContext context, AppLocalizations l10n, Uri uri) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: () => _open(context, uri),
        icon: Icon(
          Icons.open_in_new_rounded,
          size: AppIconSizes.sm,
          color: cs.primary,
        ),
        label: Text(
          l10n.sourcesVisitWebsite,
          style: AppTypography.caption(cs).copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
                title: l10n.topBarSources,
                subtitle: l10n.sourcesSubtitle,
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
                              Icon(
                                Icons.verified_user_outlined,
                                color: cs.primary,
                                size: AppIconSizes.lg,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  l10n.sourcesIntro,
                                  style: AppTypography.body(cs, opacity: 0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: cs.primaryContainer.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.fact_check_outlined,
                                    size: AppIconSizes.md,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      l10n.sourcesTrustLine,
                                      style: AppTypography.caption(cs, opacity: 0.88),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSupportHintCard(
                      icon: Icons.menu_book_rounded,
                      title: l10n.sourcesQuranTitle,
                      body: l10n.sourcesQuranBody,
                      footer: _linkButton(context, l10n, Uri.parse('https://tanzil.net')),
                    ),
                    AppSupportHintCard(
                      icon: Icons.library_books_rounded,
                      title: l10n.sourcesTafsirTitle,
                      body: l10n.sourcesTafsirBody,
                      footer: _linkButton(context, l10n, Uri.parse('https://quran.com')),
                    ),
                    AppSupportHintCard(
                      icon: Icons.schedule_rounded,
                      title: l10n.sourcesPrayerTitle,
                      body: l10n.sourcesPrayerBody,
                      footer: _linkButton(context, l10n, Uri.parse('https://aladhan.com')),
                    ),
                    AppSupportHintCard(
                      icon: Icons.headphones_rounded,
                      title: l10n.sourcesAudioTitle,
                      body: l10n.sourcesAudioBody,
                      footer: _linkButton(context, l10n, Uri.parse('https://mp3quran.net')),
                    ),
                    AppSupportHintCard(
                      icon: Icons.record_voice_over_rounded,
                      title: l10n.sourcesStoriesTitle,
                      body: l10n.sourcesStoriesBody,
                    ),
                    AppSupportHintCard(
                      icon: Icons.science_outlined,
                      title: l10n.sourcesMiraclesTitle,
                      body: l10n.sourcesMiraclesBody,
                      footer: _linkButton(context, l10n, Uri.parse('https://quran.com')),
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
