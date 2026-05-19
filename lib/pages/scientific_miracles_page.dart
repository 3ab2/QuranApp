import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../data/surah_data.dart';
import '../models/scientific_miracle_model.dart';
import '../models/tafsir_entry.dart';
import '../services/miracle_service.dart';
import '../services/tafsir/tafsir_repository.dart';
import '../ui/app_scroll.dart';
import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

/// Scientific themes only — one optional tafsir preview; full study on [TafsirPage].
class ScientificMiraclesPage extends StatefulWidget {
  const ScientificMiraclesPage({super.key});

  @override
  ScientificMiraclesPageState createState() => ScientificMiraclesPageState();
}

class ScientificMiraclesPageState extends State<ScientificMiraclesPage> {
  final TafsirRepository _tafsirRepo = TafsirRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ScientificMiracle> miracles = [];
  List<ScientificMiracle> filtered = [];
  Timer? _debounce;
  String? selectedCategory;
  bool _loading = true;

  String _normalize(String value) {
    var t = value.trim().toLowerCase();
    t = t.replaceAll('\u0640', '');
    // Improve Arabic matching when user types without full vocalization.
    t = t.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');
    return t;
  }

  double _score(ScientificMiracle m, String q) {
    if (q.isEmpty) return 1;
    final hay = _normalize(
      '${m.title} ${m.verse} ${m.surahName} ${m.scientificExplanation} '
      '${m.tafsirSummary} ${m.categoryDisplay} ${m.topicTags.join(' ')}',
    );
    if (hay == q) return 120;
    if (hay.startsWith(q)) return 95;
    if (hay.contains(q)) return 70;
    for (final w in q.split(RegExp(r'\s+')).where((x) => x.length > 1)) {
      if (hay.contains(w)) return 55;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchControllerTick);
    loadData();
  }

  void _onSearchControllerTick() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      _applyFilter();
    });
  }

  Future<void> loadData() async {
    setState(() => _loading = true);
    try {
      final data = await MiracleService.loadMiracles();
      if (!mounted) return;
      setState(() {
        miracles = data;
        filtered = data;
        _loading = false;
      });
      _applyFilter();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        miracles = [];
        filtered = [];
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    if (!mounted) return;
    final query = _normalize(_searchController.text);
    var list = miracles.where((m) {
      final matchesCat =
          selectedCategory == null || m.categoryDisplay == selectedCategory;
      if (!matchesCat) return false;
      if (query.isEmpty) return true;
      return _score(m, query) > 0;
    }).toList();
    if (query.isNotEmpty) {
      list.sort((a, b) => _score(b, query).compareTo(_score(a, query)));
    }
    setState(() => filtered = list);
  }

  List<String> get categories =>
      miracles.map((m) => m.categoryDisplay).toSet().toList()..sort();

  String _surahNameAr(int n) {
    final row = surahs.firstWhere(
      (s) => s['number'] == n,
      orElse: () => {'name': ''},
    );
    return row['name'] as String;
  }

  void _openTafsirStudyPage(ScientificMiracle m) {
    final surah = m.resolvedSurahNumber;
    debugPrint(
      '[ScientificMiracles] navigate to TafsirPage surah=$surah ayah=${m.primaryAyah}',
    );
    Navigator.pushNamed(
      context,
      '/tafsir',
      arguments: {
        'surahNumber': surah,
        'ayahNumber': m.primaryAyah,
      },
    );
  }

  Future<void> _previewTafsir(ScientificMiracle m) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final surah = m.resolvedSurahNumber;
    final name = _surahNameAr(surah);
    debugPrint(
      '[ScientificMiracles] tafsir preview surah=$surah ayah=${m.primaryAyah}',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.pageH,
            right: AppSpacing.pageH,
            bottom: MediaQuery.paddingOf(ctx).bottom + AppSpacing.md,
            top: AppSpacing.sm,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55,
            minChildSize: 0.35,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return FutureBuilder<TafsirEntry?>(
                future: _tafsirRepo.loadAyah(
                  source: TafsirSource.alMuyassar,
                  surahNumber: surah,
                  ayahNumber: m.primaryAyah,
                  surahName: name,
                ),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return Center(child: AppLoadingView(label: l10n.tafsirLoading));
                  }
                  if (snap.hasError) {
                    debugPrint('[ScientificMiracles] tafsir preview error ${snap.error}');
                    return AppErrorView(
                      message: '${l10n.tafsirNetworkError}\n(${snap.error})',
                      retryLabel: l10n.tafsirRetry,
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final entry = snap.data;
                  if (entry == null) {
                    debugPrint(
                      '[ScientificMiracles] tafsir preview NULL surah=$surah ayah=${m.primaryAyah}',
                    );
                    return AppErrorView(
                      message: l10n.tafsirUnavailableForAyah,
                      retryLabel: l10n.tafsirRetry,
                      onRetry: () => Navigator.pop(ctx),
                    );
                  }
                  final excerpt = entry.tafsirText.trim();
                  final displayTafsir = excerpt.length > 12000
                      ? '${excerpt.substring(0, 12000)}…'
                      : excerpt;
                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: AppSpacing.listBottom),
                    children: [
                      Text(
                        l10n.miraclesTafsirPreview,
                        style: AppTypography.sectionTitle(cs),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '$name ﴿${entry.ayahNumber}﴾',
                        textDirection: TextDirection.rtl,
                        style: AppTypography.caption(cs, opacity: 0.68),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SelectableText(
                        displayTafsir,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: 17,
                          height: 1.5,
                          color: cs.onSurface.withValues(alpha: 0.92),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openTafsirStudyPage(m);
                          },
                          child: Text(
                            l10n.miraclesContinueInTafsirPage,
                            style: GoogleFonts.amiri(
                              fontSize: 15,
                              color: cs.primary,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchControllerTick);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomPad = bottomInset + AppSpacing.listBottom;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(
                title: l10n.miraclesPageTitle,
                subtitle: l10n.miraclesModerateNote,
              ),
              const SizedBox(height: AppSpacing.afterHeader),
              Expanded(
                child: _loading
                    ? AppLoadingView(label: l10n.miraclesLoading)
                    : CustomScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: AppScrollPhysics.list(context),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageH,
                              0,
                              AppSpacing.pageH,
                              AppSpacing.sm,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: AppSearchTextField(
                                controller: _searchController,
                                hintText: l10n.miraclesSearchHint,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 44,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                    ),
                                    child: AppFilterChoiceChip(
                                      label: l10n.miraclesFilterAll,
                                      selected: selectedCategory == null,
                                      colorScheme: cs,
                                      onSelected: (_) {
                                        setState(() => selectedCategory = null);
                                        _applyFilter();
                                      },
                                    ),
                                  ),
                                  ...categories.map(
                                    (cat) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs,
                                      ),
                                      child: AppFilterChoiceChip(
                                        label: cat,
                                        selected: selectedCategory == cat,
                                        colorScheme: cs,
                                        onSelected: (_) {
                                          setState(() => selectedCategory = cat);
                                          _applyFilter();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (filtered.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: bottomPad),
                                child: Center(
                                  child: Text(
                                    l10n.miraclesEmptyResults,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: AppTypography.listTitle(cs),
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.only(bottom: bottomPad),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final miracle = filtered[index];
                                    final surahNum = miracle.resolvedSurahNumber;
                                    final showDistinctTitle = miracle.title
                                            .trim()
                                            .isNotEmpty &&
                                        _normalize(miracle.title) !=
                                            _normalize(miracle.verse);
                                    return AppCard(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (showDistinctTitle) ...[
                                            Text(
                                              miracle.title,
                                              style: AppTypography.listTitle(cs),
                                              textDirection: TextDirection.rtl,
                                            ),
                                            const SizedBox(height: AppSpacing.sm),
                                          ],
                                          Text(
                                            'سورة ${_surahNameAr(surahNum)} - آية ${miracle.primaryAyah}',
                                            textDirection: TextDirection.rtl,
                                            style: AppTypography.caption(cs, opacity: 0.72),
                                          ),
                                          if (miracle.verse.trim().isNotEmpty) ...[
                                            const SizedBox(height: AppSpacing.xs + 2),
                                            Text(
                                              miracle.verse,
                                              style: GoogleFonts.amiri(
                                                fontSize: 16,
                                                color: cs.primary,
                                                fontWeight: showDistinctTitle
                                                    ? FontWeight.w600
                                                    : FontWeight.bold,
                                              ),
                                              textDirection: TextDirection.rtl,
                                            ),
                                          ],
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            miracle.scientificExplanation,
                                            style: GoogleFonts.amiri(
                                              fontSize: 15,
                                              height: 1.45,
                                              color: cs.onSurface.withValues(alpha: 0.85),
                                            ),
                                            textDirection: TextDirection.rtl,
                                          ),
                                          const SizedBox(height: AppSpacing.sm + 2),
                                          Wrap(
                                            spacing: AppSpacing.sm,
                                            runSpacing: AppSpacing.sm,
                                            alignment: WrapAlignment.end,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: AppSpacing.sm + 2,
                                                  vertical: AppSpacing.xs,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: cs.primary.withValues(alpha: 0.14),
                                                  borderRadius: AppRadius.chip,
                                                ),
                                                child: Text(
                                                  miracle.categoryDisplay,
                                                  style: GoogleFonts.amiri(
                                                    fontSize: 13,
                                                    color: cs.onSurface,
                                                  ),
                                                ),
                                              ),
                                              TextButton.icon(
                                                onPressed: () => _previewTafsir(miracle),
                                                icon: Icon(
                                                  Icons.article_outlined,
                                                  color: cs.primary,
                                                  size: AppIconSizes.tile,
                                                ),
                                                label: Text(
                                                  l10n.miraclesTafsirPreview,
                                                  style: GoogleFonts.amiri(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: filtered.length,
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
