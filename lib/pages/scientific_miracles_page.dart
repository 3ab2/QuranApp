import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../data/surah_data.dart';
import '../models/scientific_miracle_model.dart';
import '../models/tafsir_entry.dart';
import '../services/miracle_service.dart';
import '../services/tafsir/tafsir_repository.dart';
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
  String search = '';
  String? selectedCategory;
  bool _loading = true;

  String _normalize(String value) {
    var t = value.trim().toLowerCase();
    t = t.replaceAll('\u0640', '');
    return t;
  }

  double _score(ScientificMiracle m, String q) {
    if (q.isEmpty) return 1;
    final hay = _normalize(
      '${m.title} ${m.verse} ${m.surahName} ${m.scientificExplanation} ${m.categoryDisplay} ${m.topicTags.join(' ')}',
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
    loadData();
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
    final query = _normalize(search);
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

  void _onSearchChanged(String val) {
    search = val;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 320), _applyFilter);
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
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(ctx).bottom + 16,
            top: 8,
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
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      Text(
                        l10n.miraclesTafsirPreview,
                        style: GoogleFonts.amiri(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$name ﴿${entry.ayahNumber}﴾',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: 14,
                          color: cs.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        displayTafsir,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: 17,
                          height: 1.5,
                          color: cs.onSurface.withValues(alpha: 0.92),
                        ),
                      ),
                      const SizedBox(height: 20),
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
    _searchController.dispose();
    super.dispose();
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
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              const AppPageHeader(title: 'الإعجاز العلمي في القرآن'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  l10n.miraclesModerateNote,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 12,
                    color: cs.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: _loading
                    ? AppLoadingView(label: l10n.miraclesLoading)
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'ابحث عن آية أو موضوع أو وصف علمي…',
                                prefixIcon: const Icon(Icons.search),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(18)),
                                ),
                                filled: true,
                                fillColor: theme.cardColor,
                              ),
                              onChanged: _onSearchChanged,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 48,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      'الكل',
                                      style: GoogleFonts.amiri(color: cs.onSurface),
                                    ),
                                    selected: selectedCategory == null,
                                    selectedColor: cs.primary,
                                    backgroundColor: theme.cardColor,
                                    onSelected: (_) {
                                      setState(() => selectedCategory = null);
                                      _applyFilter();
                                    },
                                  ),
                                ),
                                ...categories.map(
                                  (cat) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: ChoiceChip(
                                      label: Text(
                                        cat,
                                        style: GoogleFonts.amiri(
                                          color: selectedCategory == cat
                                              ? cs.onPrimary
                                              : cs.onSurface,
                                        ),
                                      ),
                                      selected: selectedCategory == cat,
                                      selectedColor: cs.primary,
                                      backgroundColor: theme.cardColor,
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
                          const SizedBox(height: 8),
                          Expanded(
                            child: filtered.isEmpty
                                ? Center(
                                    child: Text(
                                      'لا توجد نتائج',
                                      style: GoogleFonts.amiri(
                                        fontSize: 18,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final miracle = filtered[index];
                                      final surahNum = miracle.resolvedSurahNumber;
                                      final showDistinctTitle = miracle.title
                                              .trim()
                                              .isNotEmpty &&
                                          _normalize(miracle.title) !=
                                              _normalize(miracle.verse);
                                      return AppCard(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              if (showDistinctTitle) ...[
                                                Text(
                                                  miracle.title,
                                                  style: GoogleFonts.amiri(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: cs.onSurface,
                                                  ),
                                                  textDirection: TextDirection.rtl,
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                              Text(
                                                'سورة ${_surahNameAr(surahNum)} - آية ${miracle.primaryAyah}',
                                                textDirection: TextDirection.rtl,
                                                style: GoogleFonts.amiri(
                                                  color: cs.onSurface
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                              if (miracle.verse.trim().isNotEmpty) ...[
                                                const SizedBox(height: 6),
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
                                              const SizedBox(height: 8),
                                              Text(
                                                miracle.scientificExplanation,
                                                style: GoogleFonts.amiri(
                                                  fontSize: 15,
                                                  color: cs.onSurface
                                                      .withValues(alpha: 0.85),
                                                ),
                                                textDirection: TextDirection.rtl,
                                              ),
                                              const SizedBox(height: 10),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                alignment: WrapAlignment.end,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: cs.primary
                                                          .withValues(alpha: 0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(12),
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
                                                    onPressed: () =>
                                                        _previewTafsir(miracle),
                                                    icon: Icon(
                                                      Icons.article_outlined,
                                                      color: cs.primary,
                                                      size: 20,
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
                                        ),
                                      );
                                    },
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
