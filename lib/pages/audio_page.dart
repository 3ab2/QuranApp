import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  Future<void> _play(
    TilawatAudioController tilawat,
    int index, {
    Duration? position,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await tilawat.playSurahAt(index, position: position);
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

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(),
              const SizedBox(height: AppSpacing.lg),
              AppPageHeader(title: l10n.audioPageTitle),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  child: _loadError != null
                      ? AppErrorView(
                          message: l10n.audioLoadError,
                          onRetry: _bootstrap,
                        )
                      : !tilawat.surahsLoaded
                          ? AppLoadingView(label: '${l10n.audioPageTitle}...')
                          : surahs.isEmpty
                              ? AppErrorView(
                                  message: l10n.audioLoadError,
                                  onRetry: _bootstrap,
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  itemCount: surahs.length,
                                  itemBuilder: (context, index) {
                                    final surah =
                                        surahs[index] as Map<String, dynamic>;
                                    final num = surah['number'] as int;
                                    return Selector<TilawatAudioController,
                                        (int?, bool)>(
                                      selector: (_, c) => (
                                        c.currentSurahIndex,
                                        c.currentSurahIndex == index &&
                                            c.isPlaying,
                                      ),
                                      builder: (context, tuple, _) {
                                        final currentIdx = tuple.$1;
                                        final playing = tuple.$2;
                                        return AppCard(
                                          child: ListTile(
                                            title: Text(
                                              surah['name']?.toString() ?? '',
                                              textDirection: TextDirection.rtl,
                                              style: GoogleFonts.amiri(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: cs.onSurface,
                                              ),
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor: cs.primary
                                                  .withValues(alpha: 0.2),
                                              child: Text(
                                                '$num',
                                                style: TextStyle(
                                                    color: cs.onSurface),
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                _SurahDownloadAction(
                                                  surahNumber: num,
                                                  surah: surah,
                                                  reciter:
                                                      settings.selectedReciter,
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    playing
                                                        ? Icons.pause_rounded
                                                        : Icons
                                                            .play_arrow_rounded,
                                                    color: cs.onSurface,
                                                  ),
                                                  onPressed: () async {
                                                    if (playing) {
                                                      await tilawat.pause();
                                                    } else {
                                                      await _play(
                                                        tilawat,
                                                        index,
                                                        position: (currentIdx ==
                                                                index)
                                                            ? tilawat
                                                                .player
                                                                .position
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
                                              position: (currentIdx == index)
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
            child: Icon(Icons.offline_pin_rounded,
                color: cs.primary, size: 22),
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
