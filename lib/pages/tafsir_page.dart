import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../data/surah_data.dart';
import '../models/scientific_miracle_model.dart';
import '../models/tafsir_entry.dart';
import '../models/tafsir_search_hit.dart';
import '../services/miracle_service.dart';
import '../services/quran_text_service.dart';
import '../services/tafsir/tafsir_repository.dart';
import '../services/tafsir/tafsir_search_service.dart';
import '../ui/app_scroll.dart';
import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

/// Continuous Al-Muyassar reader: starts at Al-Fatiha (or deep link), appends
/// surahs lazily while scrolling. No coupling to other modules.
class TafsirPage extends StatefulWidget {
  final int? surahNumber;
  final int? ayahNumber;

  const TafsirPage({super.key, this.surahNumber, this.ayahNumber});

  @override
  State<TafsirPage> createState() => _TafsirPageState();
}

class _TafsirPageState extends State<TafsirPage> {
  static const double _kEstimatedCardHeight = 285;

  final _repo = TafsirRepository();
  late final TafsirSearchService _searchService = TafsirSearchService(repository: _repo);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jumpAyahController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final Map<String, GlobalKey> _itemKeys = {};

  Timer? _debounce;
  int _searchGeneration = 0;

  /// Current surah at top of feed (picker + jump target).
  int _anchorSurah = 1;

  List<TafsirEntry> _feed = [];
  List<ScientificMiracle> _miracles = [];
  int _lastAppendedSurah = 0;

  bool _bootLoading = true;
  bool _tailLoading = false;
  String? _error;

  List<TafsirSearchHit> _searchHits = [];
  bool _searchBusy = false;
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _anchorSurah = widget.surahNumber ?? 1;
    _scrollController.addListener(_onScroll);
    _startBoot();
  }

  Future<void> _startBoot() async {
    final miraclesFuture = MiracleService.loadMiracles();
    await QuranTextService.instance.ensureLoaded();
    final miracles = await miraclesFuture;
    if (!mounted) return;
    setState(() => _miracles = miracles);
    await _resetFeedFromSurah(
      _anchorSurah,
      scrollToAyah: widget.ayahNumber,
      forceNetwork: false,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _bootLoading) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 800) {
      _appendNextSurahIfNeeded();
    }
  }

  String _surahName(int n) {
    final m = surahs.firstWhere(
      (s) => s['number'] == n,
      orElse: () => {'name': ''},
    );
    return m['name'] as String;
  }

  int _verseCount(int surah) {
    final ch = QuranTextService.instance.chaptersOrNull?[surah];
    return ch?.length ?? 0;
  }

  GlobalKey _keyFor(int surah, int ayah) {
    final id = '$surah:$ayah';
    return _itemKeys.putIfAbsent(id, GlobalKey.new);
  }

  Future<void> _resetFeedFromSurah(
    int surah, {
    int? scrollToAyah,
    bool forceNetwork = false,
  }) async {
    if (!mounted) return;
    setState(() {
      _bootLoading = true;
      _error = null;
      _searchHits = [];
      _feed = [];
      _lastAppendedSurah = 0;
      _anchorSurah = surah;
    });

    final name = _surahName(surah);
    try {
      final rows = await _repo.loadChapter(
        source: TafsirSource.alMuyassar,
        surahNumber: surah,
        surahName: name,
        forceNetwork: forceNetwork,
      );
      if (!mounted) return;
      setState(() {
        _feed = rows;
        _lastAppendedSurah = surah;
        _bootLoading = false;
        if (rows.isEmpty) {
          _error = AppLocalizations.of(context)!.tafsirUnavailableForAyah;
        }
      });
      final ay = scrollToAyah;
      if (ay != null && ay >= 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          unawaited(_scrollToAyahInFeed(surah, ay, showErrorSnack: false));
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _bootLoading = false;
        _error = AppLocalizations.of(context)!.tafsirNetworkError;
      });
    }
  }

  Future<void> _appendNextSurahIfNeeded() async {
    if (_tailLoading || _bootLoading || _lastAppendedSurah >= 114) return;
    _tailLoading = true;
    final next = _lastAppendedSurah + 1;
    final name = _surahName(next);
    try {
      final rows = await _repo.loadChapter(
        source: TafsirSource.alMuyassar,
        surahNumber: next,
        surahName: name,
      );
      if (!mounted) return;
      setState(() {
        if (rows.isNotEmpty) {
          _feed = [..._feed, ...rows];
        }
        _lastAppendedSurah = next;
        _tailLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _tailLoading = false);
    }
  }

  /// [ListView.builder] does not build off-screen children, so [GlobalKey.currentContext]
  /// is often null until we scroll near the target. Nudge scroll offset iteratively, then
  /// [Scrollable.ensureVisible].
  Future<void> _scrollToAyahInFeed(int surah, int ayah, {required bool showErrorSnack}) async {
    if (_bootLoading || _feed.isEmpty) {
      debugPrint('[TafsirPage] jump skipped (loading or empty feed)');
      return;
    }

    final idx = _feed.indexWhere((e) => e.surahNumber == surah && e.ayahNumber == ayah);
    if (idx < 0) {
      debugPrint('[TafsirPage] jump MISS surah=$surah ayah=$ayah feedLen=${_feed.length}');
      if (showErrorSnack && mounted) {
        final m = ScaffoldMessenger.maybeOf(context);
        if (m != null) {
          m.showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.tafsirJumpNotInFeed)),
          );
        }
      }
      return;
    }

    final sc = _scrollController;

    for (var attempt = 0; attempt < 36; attempt++) {
      if (!mounted) return;
      if (!sc.hasClients) {
        await Future<void>.delayed(const Duration(milliseconds: 16));
        continue;
      }

      final maxScroll = sc.position.maxScrollExtent;
      final wave = attempt * 0.2;
      var offset = idx * _kEstimatedCardHeight;
      if (attempt > 0) {
        final dir = attempt.isEven ? 1.0 : -1.0;
        offset += dir * _kEstimatedCardHeight * 0.5 * (1 + wave);
      }
      offset = offset.clamp(0.0, maxScroll);
      sc.jumpTo(offset);

      await Future<void>.delayed(const Duration(milliseconds: 12));
      await Future<void>.delayed(Duration.zero);

      final ctx = _keyFor(surah, ayah).currentContext;
      if (ctx != null && ctx.mounted) {
        try {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.06,
            duration: const Duration(milliseconds: 340),
            curve: Curves.easeOutCubic,
          );
        } catch (e, st) {
          debugPrint('[TafsirPage] ensureVisible error $e\n$st');
        }
        debugPrint('[TafsirPage] jump OK surah=$surah ayah=$ayah idx=$idx attempts=$attempt');
        return;
      }
      if (attempt % 8 == 7) {
        debugPrint('[TafsirPage] jump retry attempt=$attempt offset=$offset maxScroll=$maxScroll');
      }
    }

    debugPrint('[TafsirPage] jump FAILED surah=$surah ayah=$ayah idx=$idx');
    if (showErrorSnack && mounted) {
      final m = ScaffoldMessenger.maybeOf(context);
      if (m != null) {
        m.showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.tafsirJumpNotInFeed)),
        );
      }
    }
  }

  void _onSearchChanged(String raw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), () async {
      final gen = ++_searchGeneration;
      final q = raw.trim();
      if (!mounted) return;
      if (q.isEmpty) {
        setState(() {
          _searchHits = [];
          _searchBusy = false;
        });
        return;
      }
      setState(() {
        _searchBusy = true;
        _searchHits = [];
      });

      final feedSnapshot = List<TafsirEntry>.from(_feed);
      final miraclesSnapshot = _miracles;

      final hits = await _searchService.search(
        q,
        surahFilter: null,
        source: TafsirSource.alMuyassar,
        scientificMiracles: miraclesSnapshot.isEmpty ? null : miraclesSnapshot,
        feedEntries: feedSnapshot,
      );

      if (!mounted || gen != _searchGeneration) return;
      setState(() {
        _searchHits = hits;
        _searchBusy = false;
      });
    });
  }

  void _onSurahDropdown(int? n) {
    if (n == null || _bootLoading) return;
    _jumpAyahController.clear();
    unawaited(_resetFeedFromSurah(n));
  }

  void _openSurahPickerSheet() {
    if (_bootLoading) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    var filter = '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final filtered = surahs.where((s) {
              if (filter.isEmpty) return true;
              final name = s['name'] as String;
              final n = s['number'].toString();
              return name.contains(filter) || n.contains(filter);
            }).toList();

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
              child: SizedBox(
                height: MediaQuery.sizeOf(ctx).height * 0.55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageH,
                        0,
                        AppSpacing.pageH,
                        AppSpacing.sm,
                      ),
                      child: Text(
                        l10n.tafsirBrowseSurahs,
                        style: AppTypography.sectionTitle(cs),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageH,
                        0,
                        AppSpacing.pageH,
                        AppSpacing.sm,
                      ),
                      child: TextField(
                        decoration: AppInputDecorations.compactOutline(
                          ctx,
                          hintText: l10n.quranSurahPickerHint,
                        ),
                        textDirection: TextDirection.rtl,
                        onChanged: (v) => setModal(() => filter = v),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final s = filtered[i];
                          final num = s['number'] as int;
                          final name = s['name'] as String;
                          return ListTile(
                            title: Text(
                              '$num. $name',
                              style: GoogleFonts.amiri(fontSize: 17, color: cs.onSurface),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _onSurahDropdown(num);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openJumpAyahSheet() {
    if (_bootLoading) return;
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    _jumpAyahController.clear();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.pageH,
            right: AppSpacing.pageH,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.md,
            top: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${l10n.tafsirSelectSurah}: ${_surahName(_anchorSurah)}',
                textDirection: TextDirection.rtl,
                style: AppTypography.listTitle(cs),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _jumpAyahController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.go,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: GoogleFonts.amiri(fontSize: 18, color: cs.onSurface),
                decoration: AppInputDecorations.compactOutline(
                  ctx,
                  labelText: l10n.tafsirAyahNumber,
                  hintText: l10n.tafsirAyahNumber,
                ),
                onSubmitted: (_) {
                  Navigator.pop(ctx);
                  _onJumpAyah();
                },
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _onJumpAyah();
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                ),
                child: Text(l10n.tafsirGo, style: GoogleFonts.amiri(fontWeight: FontWeight.w600)),
              ),
              SizedBox(height: MediaQuery.paddingOf(ctx).bottom),
            ],
          ),
        );
      },
    );
  }

  void _onJumpAyah() {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    final parsed = int.tryParse(_jumpAyahController.text.trim());
    if (parsed == null || parsed < 1) {
      debugPrint('[TafsirPage] Go: invalid or empty ayah');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tafsirJumpInvalidAyah)),
      );
      return;
    }
    final maxV = _verseCount(_anchorSurah);
    if (maxV > 0 && parsed > maxV) {
      debugPrint('[TafsirPage] Go: ayah $parsed > max $maxV for surah $_anchorSurah');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tafsirJumpInvalidAyah)),
      );
      return;
    }
    debugPrint('[TafsirPage] Go: surah=$_anchorSurah ayah=$parsed');
    unawaited(_scrollToAyahInFeed(_anchorSurah, parsed, showErrorSnack: true));
  }

  void _toggleSearchPanel() {
    if (_searchExpanded) {
      _debounce?.cancel();
      _searchController.clear();
      _searchFocusNode.unfocus();
      setState(() {
        _searchExpanded = false;
        _searchHits = [];
        _searchBusy = false;
      });
    } else {
      setState(() => _searchExpanded = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  Future<void> _openHit(TafsirSearchHit hit) async {
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() {
      _searchExpanded = false;
      _searchHits = [];
      _searchBusy = false;
    });
    await _resetFeedFromSurah(hit.surahNumber, scrollToAyah: hit.ayahNumber);
  }

  Future<void> _retryBoot() async {
    await _resetFeedFromSurah(_anchorSurah, forceNetwork: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _jumpAyahController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildInlineSearchHits(ColorScheme cs) {
    final l10n = AppLocalizations.of(context)!;
    final q = _searchController.text.trim();

    if (_searchBusy && _searchHits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageH, vertical: AppSpacing.sm),
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
          ),
        ),
      );
    }

    if (q.isNotEmpty && !_searchBusy && _searchHits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          AppSpacing.xs,
          AppSpacing.pageH,
          AppSpacing.sm,
        ),
        child: Text(
          l10n.tafsirSearchEmpty,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: AppTypography.body(cs, opacity: 0.72),
        ),
      );
    }

    if (_searchHits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageH,
          0,
          AppSpacing.pageH,
          AppSpacing.xs,
        ),
        child: Text(
          l10n.tafsirSearchCacheHint,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.captionDense(cs),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.pageH, 0, AppSpacing.pageH, AppSpacing.sm),
      child: Material(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: cs.outline.withValues(alpha: 0.18)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchBusy)
              LinearProgressIndicator(
                minHeight: 2,
                color: cs.primary,
                backgroundColor: cs.primary.withValues(alpha: 0.1),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                itemCount: _searchHits.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: cs.outline.withValues(alpha: 0.12)),
                itemBuilder: (context, i) {
                  final h = _searchHits[i];
                  return ListTile(
                    dense: true,
                    isThreeLine: h.tafsirSnippet != null && h.tafsirSnippet!.trim().isNotEmpty,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    title: Text(
                      '${h.surahName} ﴿${h.ayahNumber}﴾',
                      style: GoogleFonts.amiri(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: cs.onSurface,
                      ),
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: (h.ayahText.isEmpty &&
                            (h.tafsirSnippet == null || h.tafsirSnippet!.trim().isEmpty))
                        ? null
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (h.ayahText.isNotEmpty)
                                Text(
                                  h.ayahText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                  style: GoogleFonts.amiri(
                                    fontSize: 13,
                                    color: cs.primary.withValues(alpha: 0.9),
                                  ),
                                ),
                              if (h.tafsirSnippet != null && h.tafsirSnippet!.trim().isNotEmpty) ...[
                                if (h.ayahText.isNotEmpty) const SizedBox(height: 2),
                                Text(
                                  h.tafsirSnippet!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                  style: AppTypography.caption(cs, opacity: 0.72),
                                ),
                              ],
                            ],
                          ),
                    trailing: Icon(Icons.touch_app_outlined, size: 18, color: cs.primary),
                    onTap: () => _openHit(h),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final showFooter =
        !_bootLoading && _error == null && _feed.isNotEmpty && _lastAppendedSurah < 114;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: cs.surface,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBar(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageH,
                  AppSpacing.xs,
                  AppSpacing.pageH,
                  0,
                ),
                child: Text(
                  l10n.tafsirSourceMuyassarNote,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.captionDense(cs, opacity: 0.75),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, AppSpacing.sm, AppSpacing.pageH, AppSpacing.xs),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.quranBackToHome,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () {
                        final nav = Navigator.of(context);
                        if (nav.canPop()) {
                          nav.pop();
                        } else {
                          nav.pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                      icon: const BackButtonIcon(),
                      color: cs.primary,
                    ),
                    Material(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: _bootLoading ? null : _openSurahPickerSheet,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.library_books_outlined, size: 20, color: cs.primary),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 132),
                                child: Text(
                                  _bootLoading ? '…' : '$_anchorSurah. ${_surahName(_anchorSurah)}',
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                  style: GoogleFonts.amiri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: cs.onSurface.withValues(alpha: 0.55),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: l10n.tafsirAyahNumber,
                      onPressed: _bootLoading ? null : _openJumpAyahSheet,
                      icon: Icon(Icons.vertical_align_center_rounded, color: cs.primary),
                    ),
                    IconButton(
                      tooltip: _searchExpanded ? l10n.quranSearchClose : l10n.quranSearchOpen,
                      onPressed: _bootLoading ? null : _toggleSearchPanel,
                      icon: Icon(
                        _searchExpanded ? Icons.close : Icons.search,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: AppMotion.medium,
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _searchExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.pageH,
                              0,
                              AppSpacing.pageH,
                              AppSpacing.xs,
                            ),
                            child: AppSearchTextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              hintText: l10n.tafsirSearchHint,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.amiri(fontSize: 15, color: cs.onSurface),
                              prefixIcon: _searchBusy
                                  ? const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                              onChanged: _onSearchChanged,
                            ),
                          ),
                          _buildInlineSearchHits(cs),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  child: _bootLoading
                      ? AppLoadingView(label: l10n.tafsirLoading)
                      : _error != null && _feed.isEmpty
                          ? AppErrorView(
                              message: _error!,
                              retryLabel: l10n.tafsirRetry,
                              onRetry: () => _retryBoot(),
                            )
                          : _buildFeed(cs, showFooter),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeed(ColorScheme cs, bool showFooter) {
    final l10n = AppLocalizations.of(context)!;
    if (_feed.isEmpty) {
      return AppErrorView(
        key: const ValueKey('empty-feed'),
        message: l10n.tafsirUnavailableForAyah,
        retryLabel: l10n.tafsirRetry,
        onRetry: () => _retryBoot(),
      );
    }

    return ListView.builder(
      key: const ValueKey('tafsir-feed'),
      controller: _scrollController,
      physics: AppScrollPhysics.list(context),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      cacheExtent: 4000,
      padding: AppMotion.listPadding().copyWith(
        left: AppSpacing.pageH,
        right: AppSpacing.pageH,
      ),
      itemCount: _feed.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _feed.length) {
          if (_tailLoading) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: cs.primary)),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _appendNextSurahIfNeeded();
          });
          return const SizedBox(height: 80);
        }

        final e = _feed[index];
        return RepaintBoundary(
          key: _keyFor(e.surahNumber, e.ayahNumber),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${e.surahName} · ﴿${e.ayahNumber}﴾',
                    style: AppTypography.listTitle(cs),
                    textDirection: TextDirection.rtl,
                  ),
                  if (e.ayahText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      e.ayahText,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 17,
                        height: 1.5,
                        color: cs.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SelectableText(
                    e.tafsirText,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      height: 1.55,
                      color: cs.onSurface.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
