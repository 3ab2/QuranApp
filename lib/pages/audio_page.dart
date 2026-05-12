import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran_app/l10n/app_localizations.dart';

import '../providers/download_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/tilawat_audio_controller.dart';
import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/top_bar.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  String? _loadError;
  bool _handledRouteArgs = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchOpen = false;

  static const List<String> _reciters = [
    'ماهر المعيقلي',
    'عبد الباسط عبد الصمد',
    'مشاري العفاسي',
    'سعد الغامدي',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _bootstrap();
      if (!mounted) return;
      _tryResumeFromArguments();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final tilawat = context.read<TilawatAudioController>();
    try {
      await tilawat.ensureSurahsLoaded();
      if (!mounted) return;
      setState(() => _loadError = null);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'load_failed');
    }
  }

  void _tryResumeFromArguments() {
    if (_handledRouteArgs) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['resume'] == true) {
      _handledRouteArgs = true;
      context.read<TilawatAudioController>().resumeFromSavedProgress();
    }
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
  }

  void _openReciterSheet() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final settings = context.read<SettingsProvider>();

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageH,
                AppSpacing.sm,
                AppSpacing.pageH,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.settingsSelectReciter,
                    style: AppTypography.sectionTitle(cs),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ..._reciters.map(
                    (r) => ListTile(
                      title: Text(r, style: AppTypography.listTitle(cs), textDirection: TextDirection.rtl),
                      trailing: settings.selectedReciter == r
                          ? Icon(Icons.check_rounded, color: cs.primary)
                          : null,
                      onTap: () {
                        settings.setSelectedReciter(r);
                        Navigator.pop(ctx);
                      },
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

  List<Map<String, dynamic>> _filteredSurahs(List<dynamic> surahs, String q) {
    final t = q.trim().toLowerCase();
    if (t.isEmpty) {
      return surahs.cast<Map<String, dynamic>>();
    }
    return surahs
        .cast<Map<String, dynamic>>()
        .where((s) {
          final name = (s['name'] ?? '').toString().toLowerCase();
          final num = (s['number'] ?? '').toString();
          return name.contains(t) || num.contains(t);
        })
        .toList();
  }

  Future<void> _play(
    TilawatAudioController tilawat,
    int indexInFullList,
    List<Map<String, dynamic>> displayList, {
    Duration? position,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final surah = displayList[indexInFullList];
    final num = surah['number'] as int;
    final full = tilawat.surahs.cast<Map<String, dynamic>>();
    final idx = full.indexWhere((e) => e['number'] == num);
    if (idx < 0) return;
    try {
      await tilawat.playSurahAt(idx, position: position);
    } catch (_) {
      if (!mounted) return;
      AppFeedback.showError(context, l10n.audioPlayError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final settings = context.watch<SettingsProvider>();
    final tilawat = context.watch<TilawatAudioController>();

    final surahs = tilawat.surahs;
    final filtered = _filteredSurahs(surahs, _searchController.text);

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
                    Expanded(
                      child: Text(
                        l10n.audioPageTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.pageTitle(cs),
                      ),
                    ),
                    Material(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: tilawat.surahsLoaded ? _openReciterSheet : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.record_voice_over_outlined, size: 18, color: cs.primary),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 100),
                                child: Text(
                                  settings.selectedReciter,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                  style: AppTypography.caption(cs, opacity: 0.9).copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: cs.onSurface.withValues(alpha: 0.5)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: _searchOpen ? l10n.quranSearchClose : l10n.quranSearchOpen,
                      onPressed: tilawat.surahsLoaded ? _toggleSearch : null,
                      icon: Icon(_searchOpen ? Icons.close : Icons.search, color: cs.primary),
                    ),
                  ],
                ),
              ),
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
                          hintText: l10n.quranSurahPickerHint,
                          textDirection: TextDirection.rtl,
                          onChanged: (_) => setState(() {}),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  child: _loadError != null
                      ? AppErrorView(
                          message: l10n.audioLoadError,
                          onRetry: _bootstrap,
                        )
                      : !tilawat.surahsLoaded
                          ? AppLoadingView(label: l10n.audioPageTitle)
                          : surahs.isEmpty
                              ? AppErrorView(
                                  message: l10n.audioLoadError,
                                  onRetry: _bootstrap,
                                )
                              : ListView.builder(
                                  key: ValueKey<String>(_searchController.text),
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.pageH,
                                    AppSpacing.xs,
                                    AppSpacing.pageH,
                                    AppSpacing.listBottom,
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final surah = filtered[index];
                                    final num = surah['number'] as int;
                                    return Selector<TilawatAudioController, (int?, bool)>(
                                      selector: (_, c) {
                                        final full = c.surahs.cast<Map<String, dynamic>>();
                                        final i = full.indexWhere((e) => e['number'] == num);
                                        return (
                                          c.currentSurahIndex,
                                          i >= 0 &&
                                              c.currentSurahIndex == i &&
                                              c.isPlaying,
                                        );
                                      },
                                      builder: (context, tuple, _) {
                                        final currentIdx = tuple.$1;
                                        final playing = tuple.$2;
                                        final full = tilawat.surahs.cast<Map<String, dynamic>>();
                                        final fullIdx =
                                            full.indexWhere((e) => e['number'] == num);
                                        return AppCard(
                                          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.md,
                                              vertical: AppSpacing.xs,
                                            ),
                                            title: Text(
                                              surah['name']?.toString() ?? '',
                                              textDirection: TextDirection.rtl,
                                              style: AppTypography.listTitle(cs),
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor: cs.primary.withValues(alpha: 0.15),
                                              child: Text(
                                                '$num',
                                                style: TextStyle(
                                                  color: cs.primary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _SurahDownloadAction(
                                                  surahNumber: num,
                                                  surah: surah,
                                                  reciter: settings.selectedReciter,
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    playing
                                                        ? Icons.pause_rounded
                                                        : Icons.play_arrow_rounded,
                                                    color: cs.onSurface,
                                                  ),
                                                  onPressed: () async {
                                                    if (playing) {
                                                      await tilawat.pause();
                                                    } else {
                                                      await _play(
                                                        tilawat,
                                                        index,
                                                        filtered,
                                                        position: (currentIdx == fullIdx && fullIdx >= 0)
                                                            ? tilawat.player.position
                                                            : null,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            onTap: () => _play(
                                              tilawat,
                                              index,
                                              filtered,
                                              position: (currentIdx == fullIdx && fullIdx >= 0)
                                                  ? tilawat.player.position
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurahDownloadAction extends StatelessWidget {
  const _SurahDownloadAction({
    required this.surahNumber,
    required this.surah,
    required this.reciter,
  });

  final int surahNumber;
  final Map<String, dynamic> surah;
  final String reciter;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Consumer<DownloadProvider>(
      builder: (context, dl, _) {
        final done = dl.isDownloaded(surahNumber, reciter);
        final loading = dl.isDownloading(surahNumber, reciter);
        final p = dl.downloadProgress(surahNumber, reciter);
        if (loading) {
          return SizedBox(
            width: 40,
            height: 40,
            child: p != null
                ? CircularProgressIndicator(
                    value: p,
                    strokeWidth: 2,
                    color: cs.primary,
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.primary,
                  ),
          );
        }
        if (done) {
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Icon(Icons.offline_pin_rounded, color: cs.primary, size: 22),
          );
        }
        return IconButton(
          icon: Icon(Icons.download_rounded, color: cs.onSurface),
          tooltip: l10n.tilawatDownloadForOffline,
          onPressed: () async {
            final ok = await dl.downloadSurah(
              surahNumber: surahNumber,
              surah: surah,
              reciter: reciter,
            );
            if (!context.mounted) return;
            if (ok) {
              AppFeedback.showInfo(context, l10n.tilawatDownloadComplete);
            } else {
              AppFeedback.showError(context, l10n.tilawatDownloadFailed);
            }
          },
        );
      },
    );
  }
}
