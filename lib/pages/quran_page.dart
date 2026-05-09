import 'dart:async';
import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/surah_data.dart';
import '../data/surah_revelation.dart';
import '../services/quran_reader_preferences.dart';
import '../services/quran_reader_repository.dart';
import '../services/quran_reading_bookmark_store.dart';
import '../ui/app_tokens.dart';
import '../widgets/top_bar.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final _repo = QuranReaderRepository.instance;
  final _bookmarkStore = QuranReadingBookmarkStore.instance;
  final _readerPrefs = QuranReaderPreferences.instance;

  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener = ItemPositionsListener.create();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final Map<String, GlobalKey> _ayahMarkerKeys = {};

  Timer? _searchDebounce;
  Timer? _scrollUiThrottle;

  bool _loading = true;
  QuranReadingBookmark? _savedBookmark;

  bool _searchOpen = false;
  List<QuranSearchHit> _searchHits = [];

  double _fontSize = 22;
  double _lineHeight = QuranReaderPreferences.defaultLineHeight;
  bool _mushafReady = false;

  double _readProgress = 0;
  int _currentSurah = 1;

  @override
  void initState() {
    super.initState();
    _positionsListener.itemPositions.addListener(_onPositionsChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _repo.ensureBuilt();
    final prefs = await SharedPreferences.getInstance();
    final bm = await _bookmarkStore.load();
    final lh = await _readerPrefs.loadLineHeight();
    final mush = await _readerPrefs.loadMushafModeReady();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _savedBookmark = bm;
      _fontSize = prefs.getDouble('fontSize') ?? 22.0;
      _lineHeight = lh;
      _mushafReady = mush;
    });
  }

  GlobalKey _keyForAyah(String verseKey) =>
      _ayahMarkerKeys.putIfAbsent(verseKey, GlobalKey.new);

  void _onPositionsChanged() {
    _scrollUiThrottle?.cancel();
    _scrollUiThrottle = Timer(const Duration(milliseconds: 90), () {
      if (!mounted || !_repo.isReady) return;
      final positions = _positionsListener.itemPositions.value;
      if (positions.isEmpty) return;
      ItemPosition? top;
      for (final p in positions) {
        if (top == null || p.index < top.index) top = p;
      }
      final idx = top!.index;
      final surah = idx ~/ 2 + 1;
      final maxI = max(1, _repo.rowCount - 1);
      double progress;
      if (idx.isEven) {
        progress = idx / maxI;
      } else {
        final span = top.itemTrailingEdge - top.itemLeadingEdge;
        final frac = span > 0.001 ? (-top.itemLeadingEdge / span).clamp(0.0, 1.0) : 0.0;
        progress = ((idx + frac) / maxI).clamp(0.0, 1.0);
      }
      setState(() {
        _currentSurah = surah;
        _readProgress = progress;
      });
    });
  }

  @override
  void dispose() {
    _scrollUiThrottle?.cancel();
    _searchDebounce?.cancel();
    _positionsListener.itemPositions.removeListener(_onPositionsChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _persistFontSize() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('fontSize', _fontSize);
  }

  Future<void> _persistLineHeight() async {
    await _readerPrefs.saveLineHeight(_lineHeight);
  }

  /// Always reach Home: pop when stacked, otherwise reset route stack to `/`.
  void _goHome() {
    if (!mounted) return;
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      nav.pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _scrollToRow(int index, {double alignment = 0.12}) {
    _itemScrollController.scrollTo(
      index: index.clamp(0, _repo.rowCount - 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: alignment,
    );
  }

  /// Scroll list to surah body, then reveal the ayah marker inside the mushaf block.
  void _scrollToAyah(int surah, int ayah, {double listAlignment = 0.06}) {
    final bodyIdx = _repo.listIndexForSurahBody(surah);
    _itemScrollController.scrollTo(
      index: bodyIdx.clamp(0, _repo.rowCount - 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: listAlignment,
    );
    void reveal() {
      final ctx = _keyForAyah('$surah:$ayah').currentContext;
      if (ctx != null && mounted) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.12,
          duration: const Duration(milliseconds: 340),
          curve: Curves.easeOutCubic,
        );
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => reveal());
    });
  }

  ({int surah, int ayah})? _estimateReadingBookmark() {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return null;
    final sorted = positions.toList()..sort((a, b) => a.index.compareTo(b.index));
    final top = sorted.first;
    final idx = top.index;
    final surah = idx ~/ 2 + 1;
    if (idx.isEven) {
      return (surah: surah, ayah: 1);
    }
    final vc = _repo.verseCount(surah);
    if (vc < 1) return null;
    final span = top.itemTrailingEdge - top.itemLeadingEdge;
    if (span <= 0.001) return (surah: surah, ayah: 1);
    final frac = (-top.itemLeadingEdge / span).clamp(0.0, 1.0);
    final ayah = (1 + frac * (vc - 1)).round().clamp(1, vc);
    return (surah: surah, ayah: ayah);
  }

  Future<void> _saveBookmark() async {
    final pos = _estimateReadingBookmark();
    if (pos == null) return;
    final bm = QuranReadingBookmark(
      surahNumber: pos.surah,
      ayahNumber: pos.ayah,
    );
    await _bookmarkStore.save(bm);
    if (!mounted) return;
    setState(() => _savedBookmark = bm);
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.quranBookmarkSaved)),
    );
  }

  void _continueReading() {
    final b = _savedBookmark;
    if (b == null) return;
    _scrollToAyah(b.surahNumber, b.ayahNumber);
  }

  void _openSurahPicker() {
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: l10n.quranSurahPickerHint,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
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
                              style: GoogleFonts.amiri(fontSize: 18, color: cs.onSurface),
                              textAlign: TextAlign.right,
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              _scrollToRow(_repo.surahHeaderRowIndex(num));
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

  void _onSearchChanged(String raw) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _searchHits = _repo.search(raw);
      });
    });
  }

  void _closeSearch() {
    setState(() {
      _searchOpen = false;
      _searchController.clear();
      _searchHits = [];
    });
    _searchFocus.unfocus();
  }

  Widget _surahSeparator(BuildContext context, int surah) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final name = _repo.surahName(surah);
    final madani = isMadaniSurah(surah);
    final badge = madani ? l10n.quranMadaniShort : l10n.quranMakkiShort;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppRadius.card,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            boxShadow: AppShadows.card(context),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Column(
            children: [
              Text(
                name,
                style: GoogleFonts.amiri(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${l10n.quranSurahNumberLabel} $surah',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.75),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Single flowing mushaf-style block for one surah (ayahs inline, markers only between verses).
  Widget _surahMushafBody(BuildContext context, int surah) {
    final cs = Theme.of(context).colorScheme;
    final gold = cs.secondary;
    final verses = _repo.versesForSurah(surah);

    final baseStyle = GoogleFonts.amiri(
      fontSize: _fontSize,
      color: cs.onSurface,
      height: _lineHeight,
      shadows: [
        Shadow(color: gold.withValues(alpha: 0.2), offset: const Offset(0.5, 0.5), blurRadius: 2),
      ],
    );
    final markerStyle = GoogleFonts.amiri(
      fontSize: _fontSize * 0.88,
      color: cs.primary,
      height: _lineHeight,
      fontWeight: FontWeight.w600,
    );

    final children = <InlineSpan>[];
    for (final v in verses) {
      final ayah = v['verse'] as int;
      final text = v['text'] as String;
      final keyStr = '$surah:$ayah';
      children.add(TextSpan(text: '$text\u2009', style: baseStyle));
      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: KeyedSubtree(
              key: _keyForAyah(keyStr),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/tafsir',
                    arguments: {
                      'surahNumber': surah,
                      'ayahNumber': ayah,
                    },
                  );
                },
                child: Text('\uFD3F$ayah\uFD3E', style: markerStyle),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Text.rich(
          TextSpan(children: children),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              if (!_loading) ...[
                LinearProgressIndicator(
                  value: _readProgress,
                  minHeight: 2,
                  backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  color: cs.primary.withValues(alpha: 0.45),
                ),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: l10n.quranBackToHome,
                      onPressed: _goHome,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      icon: const BackButtonIcon(),
                      color: cs.primary,
                    ),
                    Material(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _loading ? null : _openSurahPicker,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_outlined, size: 20, color: cs.primary),
                              const SizedBox(width: 6),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 124),
                                child: Text(
                                  _loading ? '…' : _repo.surahName(_currentSurah),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.amiri(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: cs.onSurface.withValues(alpha: 0.6)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_savedBookmark != null) ...[
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: _continueReading,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.quranContinueReading,
                          style: TextStyle(fontSize: 12, color: cs.primary),
                        ),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      tooltip: _searchOpen ? l10n.quranSearchClose : l10n.quranSearchOpen,
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _searchOpen = !_searchOpen;
                                if (_searchOpen) {
                                  _searchHits = _repo.search(_searchController.text);
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    _searchFocus.requestFocus();
                                  });
                                } else {
                                  _searchController.clear();
                                  _searchHits = [];
                                  _searchFocus.unfocus();
                                }
                              });
                            },
                      icon: Icon(_searchOpen ? Icons.close : Icons.search, color: cs.primary),
                    ),
                    IconButton(
                      tooltip: l10n.quranSaveBookmark,
                      onPressed: _loading ? null : _saveBookmark,
                      icon: Icon(
                        _savedBookmark != null ? Icons.bookmark : Icons.bookmark_outline,
                        color: cs.primary,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: cs.primary),
                      onSelected: (v) async {
                        if (v == 'inc') {
                          setState(() => _fontSize += 1.5);
                          await _persistFontSize();
                        } else if (v == 'dec') {
                          setState(() => _fontSize = max(14.0, _fontSize - 1.5));
                          await _persistFontSize();
                        } else if (v == 'lh_inc') {
                          setState(() => _lineHeight = (_lineHeight + 0.08).clamp(1.15, 2.0));
                          await _persistLineHeight();
                        } else if (v == 'lh_dec') {
                          setState(() => _lineHeight = (_lineHeight - 0.08).clamp(1.15, 2.0));
                          await _persistLineHeight();
                        } else if (v == 'mushaf') {
                          setState(() => _mushafReady = !_mushafReady);
                          await _readerPrefs.saveMushafModeReady(_mushafReady);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(value: 'inc', child: Text(l10n.surahIncreaseFont)),
                        PopupMenuItem(value: 'dec', child: Text(l10n.surahDecreaseFont)),
                        PopupMenuItem(value: 'lh_inc', child: Text(l10n.quranLineSpacingIncrease)),
                        PopupMenuItem(value: 'lh_dec', child: Text(l10n.quranLineSpacingDecrease)),
                        CheckedPopupMenuItem(
                          value: 'mushaf',
                          checked: _mushafReady,
                          child: Text(l10n.quranMushafModeToggle),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_searchOpen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: l10n.quranReaderSearchHint,
                          filled: true,
                          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                      if (_searchHits.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 220),
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: AppRadius.card,
                            border: Border.all(color: theme.dividerColor),
                            boxShadow: AppShadows.card(context),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: _searchHits.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
                            itemBuilder: (ctx, i) {
                              final h = _searchHits[i];
                              return ListTile(
                                dense: true,
                                title: Text(
                                  h.primaryLabel,
                                  style: GoogleFonts.amiri(fontSize: 16, color: cs.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: h.secondaryLabel == null
                                    ? null
                                    : Text(
                                        h.secondaryLabel!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.65)),
                                      ),
                                onTap: () {
                                  _closeSearch();
                                  if (h.kind == QuranSearchHitKind.ayah && h.ayah != null) {
                                    _scrollToAyah(h.surah, h.ayah!);
                                  } else {
                                    _scrollToRow(h.rowIndex);
                                  }
                                },
                              );
                            },
                          ),
                        )
                      else if (_searchController.text.trim().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            l10n.quranSearchEmpty,
                            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: cs.primary))
                    : ScrollablePositionedList.builder(
                        itemCount: _repo.rowCount,
                        itemScrollController: _itemScrollController,
                        itemPositionsListener: _positionsListener,
                        minCacheExtent: 480,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                        itemBuilder: (context, index) {
                          final row = _repo.rowAt(index);
                          if (row.isSurahHeader) {
                            return _surahSeparator(context, row.surah);
                          }
                          if (row.isSurahBody) {
                            return _surahMushafBody(context, row.surah);
                          }
                          return const SizedBox.shrink();
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
