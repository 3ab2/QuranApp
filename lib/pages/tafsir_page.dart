import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../data/surah_data.dart';
import '../models/tafsir_entry.dart';
import '../models/tafsir_search_hit.dart';
import '../services/quran_text_service.dart';
import '../services/tafsir/tafsir_repository.dart';
import '../services/tafsir/tafsir_search_service.dart';
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
  final _repo = TafsirRepository();
  late final TafsirSearchService _searchService = TafsirSearchService(repository: _repo);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jumpAyahController = TextEditingController();

  final Map<String, GlobalKey> _itemKeys = {};

  Timer? _debounce;

  /// Dropdown anchor and first surah in the current feed.
  int _anchorSurah = 1;

  List<TafsirEntry> _feed = [];
  int _lastAppendedSurah = 0;

  bool _bootLoading = true;
  bool _tailLoading = false;
  String? _error;

  List<TafsirSearchHit> _searchHits = [];
  bool _searchActive = false;
  bool _searchBusy = false;

  @override
  void initState() {
    super.initState();
    _anchorSurah = widget.surahNumber ?? 1;
    _scrollController.addListener(_onScroll);
    _startBoot();
  }

  Future<void> _startBoot() async {
    await QuranTextService.instance.ensureLoaded();
    await _resetFeedFromSurah(
      _anchorSurah,
      scrollToAyah: widget.ayahNumber,
      forceNetwork: false,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _searchActive || _bootLoading) return;
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
      _searchActive = false;
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
        WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAyahVisible(surah, ay));
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

  void _ensureAyahVisible(int surah, int ayah) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _keyFor(surah, ayah).currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.08,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _onSearchChanged(String raw) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 380), () async {
      final q = raw.trim();
      if (!mounted) return;
      if (q.isEmpty) {
        setState(() {
          _searchActive = false;
          _searchHits = [];
          _searchBusy = false;
        });
        return;
      }
      setState(() => _searchBusy = true);
      final hits = await _searchService.search(
        q,
        surahFilter: null,
        source: TafsirSource.alMuyassar,
        scientificMiracles: null,
      );
      if (!mounted) return;
      setState(() {
        _searchActive = true;
        _searchHits = hits;
        _searchBusy = false;
      });
    });
  }

  void _onSurahDropdown(int? n) {
    if (n == null || _bootLoading) return;
    _jumpAyahController.clear();
    _resetFeedFromSurah(n);
  }

  void _onJumpAyah() {
    final v = int.tryParse(_jumpAyahController.text.trim());
    if (v == null || v < 1) return;
    final max = _verseCount(_anchorSurah);
    if (max > 0 && v > max) return;
    _ensureAyahVisible(_anchorSurah, v);
  }

  Future<void> _openHit(TafsirSearchHit hit) async {
    _searchController.clear();
    setState(() {
      _searchActive = false;
      _searchHits = [];
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final showFooter = !_bootLoading && _error == null && _feed.isNotEmpty && _lastAppendedSurah < 114;

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(title: l10n.tafsirTitle),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.tafsirSourceMuyassarNote,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<int>(
                      value: _anchorSurah,
                      decoration: InputDecoration(
                        labelText: l10n.tafsirSelectSurah,
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      isExpanded: true,
                      items: surahs
                          .map(
                            (s) => DropdownMenuItem<int>(
                              value: s['number'] as int,
                              child: Text(
                                '${s['number']}. ${s['name']}',
                                style: GoogleFonts.amiri(),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _bootLoading ? null : _onSurahDropdown,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _jumpAyahController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.tafsirAyahNumber,
                              filled: true,
                              fillColor: theme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: _bootLoading ? null : _onJumpAyah,
                          child: Text(l10n.tafsirGo),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.tafsirSearchHint,
                        prefixIcon: _searchBusy
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.tafsirSearchCacheHint,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                          : _searchActive
                              ? _buildSearchResults(cs)
                              : _buildFeed(cs, showFooter),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ColorScheme cs) {
    final l10n = AppLocalizations.of(context)!;
    if (_searchHits.isEmpty) {
      return Center(
        key: const ValueKey('empty-search'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.tafsirSearchEmpty,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(fontSize: 16, color: cs.onSurface),
          ),
        ),
      );
    }
    return ListView.builder(
      key: const ValueKey('search'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: _searchHits.length,
      itemBuilder: (context, i) {
        final h = _searchHits[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: InkWell(
              onTap: () => _openHit(h),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${h.surahName} ﴿${h.ayahNumber}﴾',
                          style: GoogleFonts.amiri(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: cs.onSurface,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Icon(Icons.touch_app, size: 18, color: cs.primary),
                    ],
                  ),
                  if (h.ayahText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      h.ayahText,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 15,
                        color: cs.primary,
                      ),
                    ),
                  ],
                  if (h.tafsirSnippet != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      h.tafsirSnippet!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.amiri(
                        fontSize: 13,
                        color: cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
        return Padding(
          key: _keyFor(e.surahNumber, e.ayahNumber),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${e.surahName} · ﴿${e.ayahNumber}﴾',
                  style: GoogleFonts.amiri(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: cs.onSurface,
                  ),
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
        );
      },
    );
  }
}
