import 'package:flutter/material.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

/// Placeholder listing until the production Play Console link is finalized.
const String _kPlayStoreListingUrl =
    'https://play.google.com/store/apps/details?id=com.qurannoor.app';

const String _kFeedbackEmail = '3ab2uelkarch2006@gmail.com';

class RatePage extends StatelessWidget {
  const RatePage({super.key});

  Future<void> _openStore(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(_kPlayStoreListingUrl);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        AppFeedback.showInfo(context, l10n.rateSnackStoreFail);
      }
    } catch (_) {
      if (context.mounted) AppFeedback.showInfo(context, l10n.rateSnackStoreFail);
    }
  }

  Future<void> _share(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final text = l10n.rateShareText(_kPlayStoreListingUrl);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: l10n.appTitle,
        ),
      );
    } catch (_) {
      if (context.mounted) AppFeedback.showInfo(context, l10n.rateSnackShareFail);
    }
  }

  Future<void> _feedback(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri(
      scheme: 'mailto',
      path: _kFeedbackEmail,
      query: 'subject=${Uri.encodeComponent(l10n.rateFeedbackSubject)}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!ok && context.mounted) {
        AppFeedback.showInfo(context, l10n.rateSnackMailFail);
      }
    } catch (_) {
      if (context.mounted) AppFeedback.showInfo(context, l10n.rateSnackMailFail);
    }
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
                title: l10n.topBarRate,
                subtitle: l10n.rateSubtitle,
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
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.rateHeroTitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.sectionTitle(cs),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.rateHeroBody,
                            textAlign: TextAlign.center,
                            style: AppTypography.body(cs, opacity: 0.9),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (i) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 36,
                                  color: cs.primary.withValues(alpha: 0.35 + i * 0.1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.rateStarsCaption,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption(cs),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                          horizontal: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      onPressed: () => _openStore(context),
                      icon: Icon(Icons.store_mall_directory_outlined, color: cs.onPrimary),
                      label: Text(
                        l10n.rateBtnStore,
                        style: AppTypography.listTitle(cs).copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                          horizontal: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        side: BorderSide(color: cs.outline.withValues(alpha: 0.35)),
                      ),
                      onPressed: () => _share(context),
                      icon: Icon(Icons.ios_share_rounded, color: cs.primary),
                      label: Text(l10n.rateBtnShare, style: AppTypography.listTitle(cs)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton.icon(
                      onPressed: () => _feedback(context),
                      icon: Icon(Icons.mail_outline_rounded, color: cs.primary),
                      label: Text(
                        l10n.rateBtnFeedback,
                        style: AppTypography.body(cs).copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ),
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
