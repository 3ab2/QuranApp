import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../duas/khatm_dua_repository.dart';
import '../models/khatm_dua_content.dart';
import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

/// Immersive reading page for the khatm supplication (Arabic body from local JSON).
/// Audio hooks: reserved via disabled control + [KhatmDuaRepository] expansion later.
class KhatmQuranDuaPage extends StatefulWidget {
  const KhatmQuranDuaPage({super.key});

  @override
  State<KhatmQuranDuaPage> createState() => _KhatmQuranDuaPageState();
}

class _KhatmQuranDuaPageState extends State<KhatmQuranDuaPage> {
  final KhatmDuaRepository _repo = KhatmDuaRepository();
  late Future<KhatmDuaContent> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.load();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBar(),
              AppPageHeader(
                title: l10n.khatmDuaTitle,
                subtitle: l10n.khatmDuaSubtitle,
                trailing: [
                  IconButton(
                    tooltip: l10n.khatmDuaAudioSoon,
                    onPressed: null,
                    icon: Icon(Icons.headphones_outlined, color: cs.onSurface.withValues(alpha: 0.35)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.afterHeader),
              Expanded(
                child: FutureBuilder<KhatmDuaContent>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return AppLoadingView(label: l10n.khatmDuaTitle);
                    }
                    if (snap.hasError || !snap.hasData) {
                      return AppErrorView(
                        message: l10n.khatmDuaLoadError,
                        onRetry: _reload,
                        retryLabel: l10n.storyRetry,
                      );
                    }
                    final c = snap.data!;
                    if (c.introAr.isEmpty && c.sections.isEmpty) {
                      return AppErrorView(
                        message: l10n.khatmDuaLoadError,
                        onRetry: _reload,
                        retryLabel: l10n.storyRetry,
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageH,
                        AppSpacing.sm,
                        AppSpacing.pageH,
                        AppSpacing.listBottom,
                      ),
                      children: [
                        if (c.introAr.isNotEmpty)
                          AppCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Text(
                              c.introAr,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amiri(
                                fontSize: 20,
                                height: 1.85,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        for (var i = 0; i < c.sections.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.md),
                          AppCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  c.sections[i].titleAr,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.sectionTitle(cs),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Divider(height: 1, color: cs.outline.withValues(alpha: 0.12)),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  c.sections[i].bodyAr,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.amiri(
                                    fontSize: 20,
                                    height: 1.9,
                                    color: cs.onSurface.withValues(alpha: 0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Text(
                            l10n.khatmDuaFooterNote,
                            textAlign: TextAlign.center,
                            style: AppTypography.caption(cs, opacity: 0.72),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
