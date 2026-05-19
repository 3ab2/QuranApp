import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_model.dart';
import '../prayer/prayer_live_clock.dart';
import '../prayer/prayer_widget_data.dart';
import '../services/prayer_service.dart';
import '../ui/app_scroll.dart';
import '../ui/app_tokens.dart';
import '../widgets/common_ui.dart';
import '../widgets/prayer_location_picker_sheet.dart';
import '../widgets/prayer_hero_dashboard.dart';
import '../widgets/top_bar.dart';
import 'adhan_immersive_page.dart';

class AdhanPage extends StatefulWidget {
  const AdhanPage({super.key});

  @override
  State<AdhanPage> createState() => _AdhanPageState();
}

class _AdhanPageState extends State<AdhanPage> {
  final PrayerService _prayerService = PrayerService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PrayerLiveClock _liveClock = PrayerLiveClock();

  PrayerTimes? _prayerTimes;
  AdhanSettings? _settings;
  bool _isLoading = true;
  String? _currentlyPlayingPrayer;
  String _highlightSignature = '';
  bool _heroExpanded = true;

  @override
  void initState() {
    super.initState();
    _liveClock.addListener(_onLiveClock);
    _initializePage();
  }

  void _onLiveClock() {
    if (!mounted) return;
    final s = _liveClock.snapshot;
    if (s != null) {
      final k = '${s.currentPeriod.nameAr}|${s.nextPrayer.nameAr}';
      if (k != _highlightSignature) {
        setState(() => _highlightSignature = k);
      }
    }
  }

  Future<void> _applyLocationSettings(AdhanSettings s) async {
    await _prayerService.saveSettings(s);
    if (!mounted) return;
    setState(() => _settings = s);
    await _loadPrayerTimes();
  }

  Future<void> _openLocationPicker() async {
    final s = _settings;
    if (s == null) return;
    await showPrayerLocationPickerSheet(
      context: context,
      currentSettings: s,
      onApply: _applyLocationSettings,
    );
  }

  Future<void> _initializePage() async {
    await _prayerService.initialize();
    await _loadPrayerTimes();
    if (!mounted) return;
    setState(() {
      _settings = _prayerService.settings;
      _isLoading = false;
    });
    _syncLiveClock();
  }

  void _syncLiveClock() {
    final t = _prayerTimes;
    if (t == null) {
      _liveClock.stop();
      return;
    }
    _liveClock.configure(
      times: t,
      preAlertMinutes: _settings?.notificationBeforeMinutes ?? 5,
    );
    _liveClock.start();
    Future<void>.microtask(() => _persistWidgetSnapshot());
  }

  Future<void> _persistWidgetSnapshot() async {
    final snap = _liveClock.snapshot;
    if (snap == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = PrayerWidgetData.build(
        snapshot: snap,
        cityLine: _prayerService.locationDisplayName,
        now: DateTime.now(),
      );
      if (payload != null) {
        await prefs.setString(
          'prayer_widget_payload',
          json.encode(payload.toJson()),
        );
      }
    } catch (_) {}
  }

  String _prayerEnglishName(String prayerNameAr) {
    switch (prayerNameAr) {
      case 'الفجر':
        return 'Fajr';
      case 'الشروق':
        return 'Sunrise';
      case 'الظهر':
        return 'Dhuhr';
      case 'العصر':
        return 'Asr';
      case 'المغرب':
        return 'Maghrib';
      case 'العشاء':
        return 'Isha';
      default:
        return prayerNameAr;
    }
  }

  Future<void> _loadPrayerTimes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // Essayer d'obtenir la localisation automatique
      final prayerTimes = await _prayerService.getPrayerTimes();

      if (prayerTimes != null) {
        if (!mounted) return;
        setState(() {
          _prayerTimes = prayerTimes;
          _isLoading = false;
        });
        _syncLiveClock();
      } else {
        // Si la localisation automatique échoue, montrer les options
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _openLocationPicker();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _openLocationPicker();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Amiri')),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _playAdhan(String prayerName) async {
    if (_audioPlayer.playing) {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        _currentlyPlayingPrayer = null;
      });
    } else {
      try {
        final audioSource =
            await _prayerService.resolveAdhanAudioSource(prayerName);
        if (audioSource == null) {
          if (!mounted) return;
          _showErrorSnackBar('ملفات الأذان غير متوفرة حاليًا');
          return;
        }
        if (audioSource.isAsset) {
          await _audioPlayer.setAsset(audioSource.uri);
        } else {
          await _audioPlayer.setUrl(audioSource.uri);
        }
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play();
        if (!mounted) return;
        setState(() {
          _currentlyPlayingPrayer = prayerName;
        });
        if (!mounted) return;
        await Navigator.of(context).push<void>(
          PageRouteBuilder<void>(
            fullscreenDialog: true,
            opaque: true,
            barrierDismissible: false,
            pageBuilder: (ctx, _, __) => AdhanImmersivePage(
              prayerNameAr: prayerName,
              prayerNameEn: _prayerEnglishName(prayerName),
              player: _audioPlayer,
              prayerService: _prayerService,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('خطأ في تشغيل الأذان');
      }
    }
  }

  Future<void> _showSettingsDialog() async {
    final currentSettings = _prayerService.settings;
    if (currentSettings == null) return;
    final l10n = AppLocalizations.of(context)!;

    bool adhanEnabled = currentSettings.adhanEnabled;
    bool reminderEnabled = currentSettings.reminderEnabled;
    int notificationMinutes =
        currentSettings.notificationBeforeMinutes.clamp(1, 120);
    final minutesController =
        TextEditingController(text: notificationMinutes.toString());

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'إعدادات الأذان',
            style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  title: Text(l10n.settingsPrayerReminder,
                      style: GoogleFonts.amiri(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    l10n.prayerReminderEnabledHelp,
                    style: GoogleFonts.amiri(fontSize: 12),
                  ),
                  value: reminderEnabled,
                  onChanged: (value) {
                    setDialogState(() => reminderEnabled = value);
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.settingsAdhanEnabled,
                      style: GoogleFonts.amiri(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    l10n.prayerAdhanEnabledHelp,
                    style: GoogleFonts.amiri(fontSize: 12),
                  ),
                  value: adhanEnabled,
                  onChanged: (value) {
                    setDialogState(() => adhanEnabled = value);
                  },
                ),
                if (reminderEnabled) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.prayerSettingsReminder,
                    style: GoogleFonts.amiri(fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.prayerReminderPreset5),
                      selected: notificationMinutes == 5,
                      onSelected: (_) {
                        setDialogState(() {
                          notificationMinutes = 5;
                          minutesController.text = '5';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text(l10n.prayerReminderPreset10),
                      selected: notificationMinutes == 10,
                      onSelected: (_) {
                        setDialogState(() {
                          notificationMinutes = 10;
                          minutesController.text = '10';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: Text(l10n.prayerReminderPreset15),
                      selected: notificationMinutes == 15,
                      onSelected: (_) {
                        setDialogState(() {
                          notificationMinutes = 15;
                          minutesController.text = '15';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.prayerReminderCustomHint,
                    labelStyle: GoogleFonts.amiri(fontSize: 13),
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v.trim());
                    if (n != null) {
                      setDialogState(() {
                        notificationMinutes = n.clamp(1, 120);
                      });
                    }
                  },
                ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('إلغاء', style: GoogleFonts.amiri()),
            ),
            ElevatedButton(
              onPressed: () async {
                final parsed =
                    int.tryParse(minutesController.text.trim()) ??
                        notificationMinutes;
                final newSettings = AdhanSettings(
                  adhanEnabled: adhanEnabled,
                  reminderEnabled: reminderEnabled,
                  notificationBeforeMinutes: parsed.clamp(1, 120),
                  autoLocation: currentSettings.autoLocation,
                  volume: currentSettings.volume,
                  muezzinVoiceId: currentSettings.muezzinVoiceId,
                  mosqueModeEnabled: false,
                  manualPrayerLocation:
                      currentSettings.manualPrayerLocation,
                );

                await _prayerService.saveSettings(newSettings);
                if (!dialogContext.mounted) return;
                setState(() {
                  _settings = newSettings;
                });
                _syncLiveClock();
                await _persistWidgetSnapshot();
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: Text('حفظ', style: GoogleFonts.amiri()),
            ),
          ],
        ),
      ),
    );

    minutesController.dispose();
  }

  Widget _buildPrayerCard(
    String prayerName,
    String time,
    IconData icon,
    Color color, {
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final card = AppCard(
        margin: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            prayerName,
            style: GoogleFonts.amiri(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: cs.onSurface,
            ),
          ),
          subtitle: Text(
            time,
            style: GoogleFonts.amiri(
              fontSize: 16,
              color: cs.onSurface.withValues(alpha: 0.7),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_settings?.adhanEnabled == true)
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final isPlaying = playerState?.playing ?? false;

                    final isCurrentSource =
                        _currentlyPlayingPrayer == prayerName;

                    return IconButton(
                      icon: Icon(
                        isPlaying && isCurrentSource
                            ? Icons.stop
                            : Icons.play_arrow,
                        color: isPlaying && isCurrentSource
                            ? theme.colorScheme.error
                            : cs.onSurface,
                      ),
                      onPressed: () => _playAdhan(prayerName),
                    );
                  },
                ),
              IconButton(
                icon: Icon(Icons.info_outline, color: cs.onSurface),
                onPressed: () => _showPrayerInfo(prayerName),
              ),
            ],
          ),
        ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: highlight
          ? BoxDecoration(
              borderRadius: AppRadius.card,
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.9),
                width: 2,
              ),
            )
          : null,
      child: card,
    );
  }

  void _showAfterSalahSheet(AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.prayerAfterAdhkar,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.prayerAfterAdhkarBody,
              style: GoogleFonts.amiri(fontSize: 15, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  bool _prayerRowHighlight(String prayerNameAr) {
    final s = _liveClock.snapshot;
    if (s == null) return false;
    return s.currentPeriod.nameAr == prayerNameAr ||
        s.nextPrayer.nameAr == prayerNameAr;
  }

  void _showPrayerInfo(String prayerName) {
    final prayerInfo = {
      'الفجر': 'صلاة الفجر هي أول صلاة في اليوم، وتصلى عند طلوع الفجر الصادق.',
      'الشروق': 'وقت شروق الشمس، وهو الوقت الذي تظهر فيه الشمس في الأفق.',
      'الظهر': 'صلاة الظهر تصلى عندما تكون الشمس في وسط السماء.',
      'العصر': 'صلاة العصر تصلى عندما يصبح ظل الشيء مثله.',
      'المغرب': 'صلاة المغرب تصلى عند غروب الشمس.',
      'العشاء': 'صلاة العشاء تصلى عند اختفاء الشفق الأحمر.',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('معلومات عن $prayerName',
            style: const TextStyle(fontFamily: 'Amiri')),
        content: Text(
          prayerInfo[prayerName] ?? 'لا توجد معلومات متاحة',
          style: const TextStyle(fontFamily: 'Amiri'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Amiri')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: Directionality.of(context),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
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
                      color: theme.colorScheme.primary,
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: _prayerTimes != null ? _openLocationPicker : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.adhanPageTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.pageTitle(theme.colorScheme),
                              ),
                              if (_prayerTimes != null)
                                Text(
                                  _prayerService.locationDisplayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.captionDense(
                                    theme.colorScheme,
                                    opacity: 0.75,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.storyRetry,
                      onPressed: _loadPrayerTimes,
                      icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
                    ),
                    PopupMenuButton<String>(
                      tooltip: l10n.settingsTitle,
                      icon: Icon(Icons.more_vert, color: theme.colorScheme.primary),
                      onSelected: (v) {
                        if (v == 'settings') {
                          _showSettingsDialog();
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'settings',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.settings_outlined),
                            title: Text(l10n.settingsTitle, style: GoogleFonts.amiri()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(
                child: _isLoading
                    ? AppLoadingView(label: l10n.adhanLoadingPrayerTimes)
                    : _prayerTimes == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_off,
                                      size: 56,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.55)),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    l10n.adhanLocationNotDetected,
                                    style: GoogleFonts.amiri(
                                      fontSize: 18,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    l10n.adhanLocationPrompt,
                                    style: GoogleFonts.amiri(
                                        color: theme.colorScheme.onSurface),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  FilledButton.icon(
                                    onPressed: _openLocationPicker,
                                    icon: const Icon(Icons.location_on_outlined),
                                    label: Text(
                                      l10n.adhanLocationSettings,
                                      style: GoogleFonts.amiri(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : RepaintBoundary(
                            child: CustomScrollView(
                              physics: AppScrollPhysics.list(context),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: ListenableBuilder(
                                    listenable: _liveClock,
                                    builder: (context, _) {
                                      final snap = _liveClock.snapshot;
                                      if (snap == null) {
                                        return const SizedBox.shrink();
                                      }
                                      final cs = Theme.of(context).colorScheme;
                                      if (!_heroExpanded) {
                                        return AppCard(
                                          margin: const EdgeInsets.fromLTRB(
                                            AppSpacing.pageH,
                                            0,
                                            AppSpacing.pageH,
                                            AppSpacing.sm,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.sm,
                                          ),
                                          child: InkWell(
                                            borderRadius: AppRadius.card,
                                            onTap: () => setState(() => _heroExpanded = true),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule_rounded,
                                                  color: cs.primary,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: AppSpacing.sm),
                                                Expanded(
                                                  child: Text(
                                                    '${snap.nextPrayer.nameAr} · ${formatPrayerCountdownHms(snap.remaining)}',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    textDirection: TextDirection.rtl,
                                                    style: AppTypography.listTitle(cs),
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.expand_more_rounded,
                                                  color: cs.primary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Align(
                                            alignment: AlignmentDirectional.centerEnd,
                                            child: IconButton(
                                              visualDensity: VisualDensity.compact,
                                              tooltip: l10n.quranSearchClose,
                                              onPressed: () =>
                                                  setState(() => _heroExpanded = false),
                                              icon: Icon(
                                                Icons.expand_less_rounded,
                                                color: cs.primary,
                                              ),
                                            ),
                                          ),
                                          PrayerHeroCompact(
                                            snapshot: snap,
                                            locationLine:
                                                '${_prayerService.locationDisplayName} · ${_prayerService.resolvedTimeZone}',
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.xs,
                                    ),
                                    child: Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: TextButton(
                                        onPressed: () =>
                                            _showAfterSalahSheet(l10n),
                                        child: Text(
                                          l10n.prayerAfterAdhkar,
                                          style: GoogleFonts.amiri(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.lg,
                                  ),
                                  sliver: SliverList(
                                    delegate: SliverChildListDelegate([
                                      _buildPrayerCard(
                                        'الفجر',
                                        _prayerTimes!.fajr,
                                        Icons.wb_sunny,
                                        Colors.orange,
                                        highlight: _prayerRowHighlight('الفجر'),
                                      ),
                                      _buildPrayerCard(
                                        'الشروق',
                                        _prayerTimes!.sunrise,
                                        Icons.wb_sunny_outlined,
                                        Colors.yellow,
                                      ),
                                      _buildPrayerCard(
                                        'الظهر',
                                        _prayerTimes!.dhuhr,
                                        Icons.wb_sunny,
                                        Colors.orange,
                                        highlight:
                                            _prayerRowHighlight('الظهر'),
                                      ),
                                      _buildPrayerCard(
                                        'العصر',
                                        _prayerTimes!.asr,
                                        Icons.wb_sunny,
                                        Colors.orange,
                                        highlight: _prayerRowHighlight('العصر'),
                                      ),
                                      _buildPrayerCard(
                                        'المغرب',
                                        _prayerTimes!.maghrib,
                                        Icons.nightlight,
                                        Colors.purple,
                                        highlight:
                                            _prayerRowHighlight('المغرب'),
                                      ),
                                      _buildPrayerCard(
                                        'العشاء',
                                        _prayerTimes!.isha,
                                        Icons.nightlight_round,
                                        Colors.indigo,
                                        highlight: _prayerRowHighlight('العشاء'),
                                      ),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _liveClock.removeListener(_onLiveClock);
    _liveClock.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
