import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/surah_data.dart';
import '../duas/quranic_dua_repository.dart';
import '../models/quranic_dua.dart';
import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

class QuranicDuasPage extends StatefulWidget {
  const QuranicDuasPage({super.key});

  @override
  State<QuranicDuasPage> createState() => _QuranicDuasPageState();
}

class _QuranicDuasPageState extends State<QuranicDuasPage> {
  final QuranicDuaRepository _repo = QuranicDuaRepository();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  List<QuranicDua> _all = [];
  List<QuranicDua> _filtered = [];
  bool _loading = true;
  String? _loadError;
  bool _searchOpen = false;
  int? _filterSurah;
  String? _filterCategory;
  Set<String> _favorites = {};

  static const _favKey = 'quranic_dua_favorites_v1';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTick);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadDuas();
    try {
      await _loadFavorites();
    } catch (e, st) {
      assert(() {
        debugPrint('[QuranicDuasPage] favorites load skipped: $e\n$st');
        return true;
      }());
    }
  }

  Future<void> _loadFavorites() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_favKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = (json.decode(raw) as List<dynamic>).cast<String>();
      if (mounted) setState(() => _favorites = list.toSet());
    } catch (_) {}
  }

  Future<void> _persistFavorites() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_favKey, json.encode(_favorites.toList()));
  }

  Future<void> _loadDuas() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final list = await _repo.load();
      if (!mounted) return;
      setState(() {
        _all = list;
        _loading = false;
      });
      _applyFilter();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _all = [];
        _filtered = [];
        _loading = false;
        _loadError = 'err';
      });
    }
  }

  void _onSearchTick() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      if (mounted) _applyFilter();
    });
  }

  String _normalize(String value) {
    var t = value.trim().toLowerCase();
    t = t.replaceAll('\u0640', '');
    t = t.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');
    return t;
  }

  double _score(QuranicDua d, String q, String lang) {
    if (q.isEmpty) return 1;
    final topics = d.categories.map((c) => _topicLabelKey(c, lang)).join(' ');
    final surahName = _surahNameAr(d.surahNumber);
    final hay = _normalize(
      '${d.arabicText} ${d.meaningEn} ${d.meaningFr} ${d.meaningAr} '
      '${d.searchKeywords.join(' ')} ${d.categories.join(' ')} $topics $surahName',
    );
    if (hay == q) return 120;
    if (hay.startsWith(q)) return 95;
    if (hay.contains(q)) return 70;
    for (final w in q.split(RegExp(r'\s+')).where((x) => x.length > 1)) {
      if (hay.contains(w)) return 55;
    }
    return 0;
  }

  /// Rough topic label for search matching in non-default locales.
  String _topicLabelKey(String category, String lang) {
    // English keys already in JSON; include common translations for search.
    const map = <String, Map<String, String>>{
      'mercy': {'en': 'mercy', 'fr': 'miséricorde', 'ar': 'رحمة'},
      'forgiveness': {'en': 'forgiveness', 'fr': 'pardon', 'ar': 'مغفرة'},
      'rizq': {'en': 'provision', 'fr': 'provision', 'ar': 'رزق'},
      'patience': {'en': 'patience', 'fr': 'patience', 'ar': 'صبر'},
      'guidance': {'en': 'guidance', 'fr': 'guidance', 'ar': 'هدى'},
      'protection': {'en': 'protection', 'fr': 'protection', 'ar': 'حماية'},
      'parents': {'en': 'parents', 'fr': 'parents', 'ar': 'والدين'},
      'success': {'en': 'success', 'fr': 'réussite', 'ar': 'توفيق'},
      'gratitude': {'en': 'gratitude', 'fr': 'reconnaissance', 'ar': 'شكر'},
      'knowledge': {'en': 'knowledge', 'fr': 'savoir', 'ar': 'علم'},
      'refuge': {'en': 'refuge', 'fr': 'refuge', 'ar': 'توكل'},
      'family': {'en': 'family', 'fr': 'famille', 'ar': 'أسرة'},
      'taqwa': {'en': 'taqwa', 'fr': 'piété', 'ar': 'تقوى'},
      'healing': {'en': 'healing', 'fr': 'guérison', 'ar': 'شفاء'},
    };
    return map[category]?[lang] ?? category;
  }

  void _applyFilter() {
    if (!mounted) return;
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final q = _normalize(_searchController.text);
      var list = _all.where((d) {
        if (_filterSurah != null && d.surahNumber != _filterSurah) return false;
        if (_filterCategory != null && !d.categories.contains(_filterCategory)) {
          return false;
        }
        if (q.isEmpty) return true;
        return _score(d, q, lang) > 0;
      }).toList();
      if (q.isNotEmpty) {
        list.sort((a, b) => _score(b, q, lang).compareTo(_score(a, q, lang)));
      }
      setState(() => _filtered = list);
    } catch (e, st) {
      assert(() {
        debugPrint('[QuranicDuasPage] _applyFilter: $e\n$st');
        return true;
      }());
      if (!mounted) return;
      setState(() => _filtered = List<QuranicDua>.from(_all));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchController.clear();
        _searchFocusNode.unfocus();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _searchFocusNode.requestFocus();
        });
      }
    });
    _applyFilter();
  }

  String _surahNameAr(int n) {
    for (final s in surahs) {
      if (s['number'] == n) return s['name'] as String;
    }
    return '';
  }

  String _ayahPart(QuranicDua d) {
    final e = d.ayahEnd;
    if (e == null || e == d.ayahStart) return '${d.ayahStart}';
    return '${d.ayahStart}–$e';
  }

  String _topicLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'mercy':
        return l10n.duaTopicMercy;
      case 'forgiveness':
        return l10n.duaTopicForgiveness;
      case 'rizq':
        return l10n.duaTopicRizq;
      case 'patience':
        return l10n.duaTopicPatience;
      case 'guidance':
        return l10n.duaTopicGuidance;
      case 'protection':
        return l10n.duaTopicProtection;
      case 'parents':
        return l10n.duaTopicParents;
      case 'success':
        return l10n.duaTopicSuccess;
      case 'gratitude':
        return l10n.duaTopicGratitude;
      case 'knowledge':
        return l10n.duaTopicKnowledge;
      case 'refuge':
        return l10n.duaTopicRefuge;
      case 'family':
        return l10n.duaTopicFamily;
      case 'taqwa':
        return l10n.duaTopicTaqwa;
      case 'healing':
        return l10n.duaTopicHealing;
      default:
        return key;
    }
  }

  Future<void> _openFilterSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final surahSet = _all.map((e) => e.surahNumber).toSet().toList()..sort();
    final catSet = _all.expand((e) => e.categories).toSet().toList()..sort();

    var localSurah = _filterSurah;
    var localCat = _filterCategory;

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageH,
                    AppSpacing.sm,
                    AppSpacing.pageH,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.quranicDuasFilterTitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.sectionTitle(cs),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.quranicDuasAllSurahs,
                        style: AppTypography.caption(cs),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          FilterChip(
                            label: Text(l10n.quranicDuasAllSurahs),
                            selected: localSurah == null,
                            onSelected: (_) => setModal(() => localSurah = null),
                          ),
                          for (final n in surahSet)
                            FilterChip(
                              label: Text(_surahNameAr(n), textDirection: TextDirection.rtl),
                              selected: localSurah == n,
                              onSelected: (_) => setModal(() => localSurah = n),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.quranicDuasAllTopics,
                        style: AppTypography.caption(cs),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          FilterChip(
                            label: Text(l10n.quranicDuasAllTopics),
                            selected: localCat == null,
                            onSelected: (_) => setModal(() => localCat = null),
                          ),
                          for (final c in catSet)
                            FilterChip(
                              label: Text(_topicLabel(l10n, c)),
                              selected: localCat == c,
                              onSelected: (_) => setModal(() => localCat = c),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, <String, dynamic>{
                          'surah': localSurah,
                          'cat': localCat,
                        }),
                        child: Text(l10n.quranicDuasApplyFilters),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, <String, dynamic>{
                          'surah': null,
                          'cat': null,
                        }),
                        child: Text(l10n.quranicDuasClearFilters),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _filterSurah = result['surah'] as int?;
        _filterCategory = result['cat'] as String?;
      });
      _applyFilter();
    }
  }

  Future<void> _toggleFavorite(String id) async {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
    await _persistFavorites();
  }

  String _shareBody(QuranicDua d, AppLocalizations l10n) {
    final lang = Localizations.localeOf(context).languageCode;
    final ref = l10n.duaRefLine(_surahNameAr(d.surahNumber), _ayahPart(d));
    final meaning = d.meaningForLocale(lang);
    return '${d.arabicText}\n\n$ref\n$meaning';
  }

  Future<void> _copyDua(QuranicDua d, AppLocalizations l10n) async {
    await Clipboard.setData(ClipboardData(text: _shareBody(d, l10n)));
    if (mounted) AppFeedback.showInfo(context, l10n.quranicDuasCopied);
  }

  Future<void> _shareDua(QuranicDua d, AppLocalizations l10n) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: _shareBody(d, l10n),
          subject: l10n.quranicDuasShareSubject,
        ),
      );
    } catch (_) {
      if (mounted) AppFeedback.showError(context, l10n.rateSnackShareFail);
    }
  }

  void _openQuran(QuranicDua d) {
    Navigator.pushNamed(context, '/surah/${d.surahNumber}');
  }

  void _openTafsir(QuranicDua d) {
    Navigator.pushNamed(
      context,
      '/tafsir',
      arguments: {
        'surahNumber': d.surahNumber,
        'ayahNumber': d.ayahStart,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    final filterActive = _filterSurah != null || _filterCategory != null;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBar(),
              AppPageHeader(
                title: l10n.quranicDuasTitle,
                trailing: [
                  IconButton(
                    tooltip: l10n.quranicDuasFilterTooltip,
                    onPressed: _loading || _loadError != null ? null : _openFilterSheet,
                    icon: Icon(
                      Icons.filter_list_rounded,
                      color: filterActive ? cs.primary : cs.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  IconButton(
                    tooltip: _searchOpen ? l10n.quranSearchClose : l10n.quranicDuasSearchOpenTooltip,
                    onPressed: _toggleSearch,
                    icon: Icon(_searchOpen ? Icons.close : Icons.search, color: cs.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.afterHeader),
              AnimatedSize(
                duration: AppMotion.medium,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _searchOpen
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageH,
                          0,
                          AppSpacing.pageH,
                          AppSpacing.sm,
                        ),
                        child: AppSearchTextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          hintText: l10n.quranicDuasSearchHint,
                          textDirection: TextDirection.rtl,
                          onChanged: (_) => _applyFilter(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: _loading
                    ? AppLoadingView(label: l10n.quranicDuasTitle)
                    : _loadError != null
                        ? AppErrorView(
                            message: l10n.quranicDuasLoadError,
                            onRetry: _loadDuas,
                            retryLabel: l10n.storyRetry,
                          )
                        : _filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  child: Text(
                                    l10n.quranicDuasEmpty,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.body(cs, opacity: 0.85),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  AppSpacing.xs,
                                  0,
                                  AppSpacing.listBottom,
                                ),
                                itemCount: _filtered.length,
                                itemBuilder: (context, i) {
                                  final d = _filtered[i];
                                  final refLine = l10n.duaRefLine(
                                    _surahNameAr(d.surahNumber),
                                    _ayahPart(d),
                                  );
                                  final meaning = d.meaningForLocale(lang);
                                  final fav = _favorites.contains(d.id);
                                  return AppCard(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.pageH,
                                      vertical: AppSpacing.xs,
                                    ),
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          d.arabicText,
                                          textDirection: TextDirection.rtl,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.amiri(
                                            fontSize: 22,
                                            height: 1.75,
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          refLine,
                                          textAlign: TextAlign.center,
                                          style: AppTypography.caption(cs, opacity: 0.75),
                                        ),
                                        if (meaning.isNotEmpty) ...[
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            meaning,
                                            textAlign: TextAlign.start,
                                            style: AppTypography.body(cs, opacity: 0.88),
                                          ),
                                        ],
                                        const SizedBox(height: AppSpacing.sm),
                                        Wrap(
                                          spacing: AppSpacing.xs,
                                          runSpacing: AppSpacing.xs,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            for (final c in d.categories)
                                              Chip(
                                                label: Text(
                                                  _topicLabel(l10n, c),
                                                  style: AppTypography.caption(cs, opacity: 0.9),
                                                ),
                                                visualDensity: VisualDensity.compact,
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                padding: EdgeInsets.zero,
                                                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.sm),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              tooltip: l10n.quranicDuasCopy,
                                              onPressed: () => _copyDua(d, l10n),
                                              icon: const Icon(Icons.copy_rounded),
                                            ),
                                            IconButton(
                                              tooltip: l10n.quranicDuasShare,
                                              onPressed: () => _shareDua(d, l10n),
                                              icon: const Icon(Icons.share_rounded),
                                            ),
                                            IconButton(
                                              tooltip: fav ? l10n.quranicDuasFavoriteOn : l10n.quranicDuasFavoriteOff,
                                              onPressed: () => _toggleFavorite(d.id),
                                              icon: Icon(fav ? Icons.star_rounded : Icons.star_border_rounded),
                                              color: fav ? cs.primary : null,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () => _openQuran(d),
                                              child: Text(l10n.quranicDuasOpenQuran),
                                            ),
                                            TextButton(
                                              onPressed: () => _openTafsir(d),
                                              child: Text(l10n.quranicDuasOpenTafsir),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
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
