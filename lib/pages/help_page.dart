import 'package:flutter/material.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
                title: l10n.topBarHelp,
                subtitle: l10n.helpSubtitle,
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.support_agent_rounded,
                            color: cs.primary,
                            size: AppIconSizes.lg,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              l10n.helpCardIntro,
                              style: AppTypography.body(cs, opacity: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSectionTitle(text: l10n.helpSectionGuides),
                    AppSupportHintCard(
                      icon: Icons.menu_book_rounded,
                      title: l10n.helpGuideQuranTitle,
                      body: l10n.helpGuideQuranBody,
                    ),
                    AppSupportHintCard(
                      icon: Icons.graphic_eq_rounded,
                      title: l10n.helpGuideTilawatTitle,
                      body: l10n.helpGuideTilawatBody,
                    ),
                    AppSupportHintCard(
                      icon: Icons.download_for_offline_rounded,
                      title: l10n.helpGuideDownloadTitle,
                      body: l10n.helpGuideDownloadBody,
                    ),
                    AppSupportHintCard(
                      icon: Icons.notifications_active_outlined,
                      title: l10n.helpGuidePrayerNotifyTitle,
                      body: l10n.helpGuidePrayerNotifyBody,
                    ),
                    AppSupportHintCard(
                      icon: Icons.headset_mic_outlined,
                      title: l10n.helpGuideBackgroundAudioTitle,
                      body: l10n.helpGuideBackgroundAudioBody,
                    ),
                    AppSupportHintCard(
                      icon: Icons.bookmark_added_outlined,
                      title: l10n.helpGuideBookmarkTitle,
                      body: l10n.helpGuideBookmarkBody,
                    ),
                    AppSectionTitle(text: l10n.helpSectionFaq),
                    AppExpandableInfoCard(
                      title: l10n.helpFaqQuranTitle,
                      body: l10n.helpFaqQuranBody,
                    ),
                    AppExpandableInfoCard(
                      title: l10n.helpFaqTilawatTitle,
                      body: l10n.helpFaqTilawatBody,
                    ),
                    AppExpandableInfoCard(
                      title: l10n.helpFaqDownloadTitle,
                      body: l10n.helpFaqDownloadBody,
                    ),
                    AppExpandableInfoCard(
                      title: l10n.helpFaqNotifyTitle,
                      body: l10n.helpFaqNotifyBody,
                    ),
                    AppExpandableInfoCard(
                      title: l10n.helpFaqBgAudioTitle,
                      body: l10n.helpFaqBgAudioBody,
                    ),
                    AppExpandableInfoCard(
                      title: l10n.helpFaqBookmarkTitle,
                      body: l10n.helpFaqBookmarkBody,
                    ),
                    AppExpandableInfoCard(
                      title: l10n.helpFaqTroubleTitle,
                      body: l10n.helpFaqTroubleBody,
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
