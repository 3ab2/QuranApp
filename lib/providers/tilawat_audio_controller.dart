import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/quran_audio_service.dart';
import '../services/story_youtube_audio_stream.dart';
import '../services/tilawat_audio_handler.dart';
import '../stories/prophet_story_service.dart';
import '../stories/story_narration_registry.dart';
import '../stories/story_youtube_video_registry.dart';
import '../services/tilawat_playback_feedback.dart';
import '../services/tilawat_playback_keys.dart';
import 'download_provider.dart';
import 'settings_provider.dart';

/// Global tilawat playback: one [AudioPlayer], consistent UI, offline-first via [DownloadProvider].
/// On Android / iOS the player lives in [TilawatAudioHandler] so playback survives background / lock screen.
class TilawatAudioController extends ChangeNotifier {
  TilawatAudioController(
    this._settings,
    this._download, {
    TilawatAudioHandler? backgroundHandler,
  }) : _handler = backgroundHandler;

  final SettingsProvider _settings;
  final DownloadProvider _download;
  final TilawatAudioHandler? _handler;

  late final AudioPlayer _player = _handler?.player ?? AudioPlayer();

  /// Web-only surah list; on mobile the handler owns the list.
  List<dynamic> _webSurahs = [];
  bool _webSurahsLoaded = false;

  int? _currentIndex;
  String? _playbackEffectiveReciter;
  String _trackedSettingsReciter = '';
  bool _playing = false;
  bool _autoPlayNext = false;
  bool _repeatCurrentSurah = false;
  bool _fullScreenSession = false;
  bool _disposed = false;

  DateTime? _sleepTimerEndsAt;
  Timer? _sleepTicker;
  Timer? _savePositionDebounce;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<ProcessingState>? _processingSub;

  /// Web / fallback: archive story narration when no [TilawatAudioHandler].
  bool _webStorySessionActive = false;
  String? _webStoryId;
  String? _webStoryUrl;
  String? _webStoryTitle;
  String? _webStoryNarrator;

  /// Prophet order with archive narration (for skip / mini bar).
  List<String> _archiveNarrationStoryOrder = const [];

  AudioPlayer get player => _player;
  List<dynamic> get surahs => _handler?.surahs ?? _webSurahs;
  bool get surahsLoaded =>
      _handler?.surahsLoaded ?? _webSurahsLoaded;
  int? get currentSurahIndex =>
      _handler?.currentSurahIndex ?? _currentIndex;
  bool get isPlaying => _playing;
  bool get autoPlayNext => _autoPlayNext;
  bool get repeatCurrentSurah => _repeatCurrentSurah;
  DateTime? get sleepTimerEndsAt => _sleepTimerEndsAt;

  bool get isStoryNarrationSession =>
      _handler?.isStoryNarrationSession ?? _webStorySessionActive;

  String? get activeStoryId => _handler?.activeStoryId ?? _webStoryId;

  String? get activeStoryTitle =>
      _handler?.activeStoryTitle ?? _webStoryTitle;

  String? get activeStoryNarratorLabel =>
      _handler?.activeStoryNarratorLabel ?? _webStoryNarrator;

  bool get storySkipHasPrevious {
    if (!isStoryNarrationSession) return false;
    final id = activeStoryId;
    if (id == null || _archiveNarrationStoryOrder.isEmpty) return false;
    final i = _archiveNarrationStoryOrder.indexOf(id);
    return i > 0;
  }

  bool get storySkipHasNext {
    if (!isStoryNarrationSession) return false;
    final id = activeStoryId;
    if (id == null || _archiveNarrationStoryOrder.isEmpty) return false;
    final i = _archiveNarrationStoryOrder.indexOf(id);
    return i >= 0 && i < _archiveNarrationStoryOrder.length - 1;
  }

  bool get showMiniPlayer =>
      !_fullScreenSession &&
      (isStoryNarrationSession ||
          (currentSurahIndex != null &&
              surahsLoaded &&
              surahs.isNotEmpty));

  void beginFullScreenSession() {
    _fullScreenSession = true;
    notifyListeners();
  }

  void endFullScreenSession() {
    _fullScreenSession = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      notifyListeners();
    });
  }

  Map<String, dynamic>? get currentSurahMap {
    final idx = currentSurahIndex;
    final list = surahs;
    if (idx == null || list.isEmpty) return null;
    return Map<String, dynamic>.from(list[idx] as Map);
  }

  /// Label for the voice actually playing (may differ after announced fallback).
  String get currentReciterLabel {
    if (_handler != null) {
      return _handler!.playbackEffectiveReciter ?? _settings.selectedReciter;
    }
    return _playbackEffectiveReciter ?? _settings.selectedReciter;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _autoPlayNext =
        prefs.getBool(TilawatPlaybackKeys.autoPlayNext) ?? false;
    _repeatCurrentSurah =
        prefs.getBool(TilawatPlaybackKeys.repeatCurrentSurah) ?? false;

    _playerStateSub = _player.playerStateStream.listen((s) {
      final next = s.playing;
      if (_playing != next) {
        _playing = next;
        notifyListeners();
      }
    });

    if (_handler == null) {
      ProcessingState? lastProc;
      _processingSub = _player.processingStateStream.listen((state) {
        if (lastProc != ProcessingState.completed &&
            state == ProcessingState.completed) {
          unawaited(_onTrackCompleted());
        }
        lastProc = state;
      });
    }

    await _player.setVolume(_settings.volume);
    _trackedSettingsReciter = _settings.selectedReciter;
    _settings.addListener(_onSettingsChanged);
    await _restoreSleepTimerFromPrefs();
    unawaited(ensureSurahsLoaded());
  }

  Future<void> _restoreSleepTimerFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final endMs = prefs.getInt(TilawatPlaybackKeys.sleepEndsAtEpochMs);
    if (endMs == null || endMs <= 0) return;
    final endAt = DateTime.fromMillisecondsSinceEpoch(endMs);
    if (!DateTime.now().isBefore(endAt)) {
      await prefs.remove(TilawatPlaybackKeys.sleepEndsAtEpochMs);
      return;
    }
    _sleepTimerEndsAt = endAt;
    _sleepTicker?.cancel();
    _sleepTicker =
        Timer.periodic(const Duration(seconds: 5), (_) => unawaited(_tickSleepFromPrefs()));
    notifyListeners();
  }

  /// SharedPreferences are the source of truth so background [TilawatAudioHandler] and UI stay aligned.
  Future<void> _tickSleepFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final endMs = prefs.getInt(TilawatPlaybackKeys.sleepEndsAtEpochMs);
    if (endMs == null || endMs <= 0) {
      if (_sleepTimerEndsAt != null) {
        _sleepTimerEndsAt = null;
        notifyListeners();
      }
      return;
    }
    final endAt = DateTime.fromMillisecondsSinceEpoch(endMs);
    if (_sleepTimerEndsAt?.millisecondsSinceEpoch != endMs) {
      _sleepTimerEndsAt = endAt;
      notifyListeners();
    }
    if (!DateTime.now().isBefore(endAt)) {
      await pause();
      clearSleepTimer();
    }
  }

  void _onSettingsChanged() {
    unawaited(_player.setVolume(_settings.volume));
    if (_settings.selectedReciter != _trackedSettingsReciter) {
      _trackedSettingsReciter = _settings.selectedReciter;
      _playbackEffectiveReciter = null;
      _handler?.clearPlaybackReciterOverride();
      notifyListeners();
    }
  }

  Future<void> _onTrackCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final endMs = prefs.getInt(TilawatPlaybackKeys.sleepEndsAtEpochMs);
    if (endMs != null &&
        endMs > 0 &&
        !DateTime.now().isBefore(DateTime.fromMillisecondsSinceEpoch(endMs))) {
      await pause();
      clearSleepTimer();
      return;
    }
    if (_webStorySessionActive) return;
    if (_repeatCurrentSurah && _currentIndex != null) {
      await playSurahAt(_currentIndex!, position: Duration.zero);
      return;
    }
    if (_autoPlayNext &&
        _currentIndex != null &&
        _currentIndex! < _webSurahs.length - 1) {
      await playSurahAt(_currentIndex! + 1);
    }
  }

  Future<void> ensureSurahsLoaded() async {
    if (_handler != null) {
      await _handler!.ensureSurahsLoaded();
      notifyListeners();
      return;
    }
    if (_webSurahsLoaded) return;
    try {
      _webSurahs = await QuranAudioService.loadSurahs();
      _webSurahsLoaded = true;
    } catch (_) {
      _webSurahs = [];
      _webSurahsLoaded = true;
    }
    notifyListeners();
  }

  void _clearWebStorySession() {
    _webStorySessionActive = false;
    _webStoryId = null;
    _webStoryUrl = null;
    _webStoryTitle = null;
    _webStoryNarrator = null;
  }

  Future<void> _persistStoryPositionWeb(String id, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'stories.audio.position.$id',
      position.inMilliseconds,
    );
  }

  Future<void> _refreshArchiveStoryOrder() async {
    try {
      final stories = await prophetStoryService.getStories();
      _archiveNarrationStoryOrder = stories
          .where(
            (s) =>
                s.hasNarration ||
                kTrustedStoryNarrationRegistry.containsKey(s.id) ||
                storyHasYoutubeNarration(s.id),
          )
          .map((s) => s.id)
          .toList(growable: false);
    } catch (_) {
      _archiveNarrationStoryOrder = const [];
    }
    if (!_disposed) notifyListeners();
  }

  Future<void> skipAdjacentArchiveStory(int delta) async {
    if (!isStoryNarrationSession || delta == 0) return;
    if (_handler != null) {
      await _handler!.skipAdjacentStoryNarration(delta);
      notifyListeners();
      return;
    }
    final id = activeStoryId;
    if (id == null) return;
    if (_archiveNarrationStoryOrder.isEmpty) {
      await _refreshArchiveStoryOrder();
    }
    final ids = _archiveNarrationStoryOrder;
    final i = ids.indexOf(id);
    if (i < 0) return;
    final j = i + delta;
    if (j < 0 || j >= ids.length) return;
    final nextId = ids[j];
    final narration =
        await prophetStoryService.resolveNarrationForStory(nextId);
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt('stories.audio.position.$nextId') ?? 0;
    final spd = _player.speed.clamp(0.75, 2.0);
    if (narration != null) {
      final story = await prophetStoryService.getStoryById(nextId);
      await playStoryNarration(
        storyId: nextId,
        url: narration.url,
        title: story.prophetName,
        narrator: narration.narratorName ?? story.narratorName,
        position: Duration(milliseconds: ms),
        speed: spd,
      );
      return;
    }
    if (!storyHasYoutubeNarration(nextId)) return;
    final entry = storyYoutubeEntryFor(nextId);
    if (entry == null) return;
    final story = await prophetStoryService.getStoryById(nextId);
    try {
      await playYoutubeStoryNarration(
        storyId: nextId,
        videoId: entry.videoId,
        title: story.prophetName,
        narrator: entry.narratorLabel,
        position: Duration(milliseconds: ms),
        speed: spd,
      );
    } catch (_) {
      return;
    }
  }

  /// YouTube-backed story: resolves a direct audio stream, then uses [playStoryNarration].
  /// On web, resolution is unavailable (CORS) — throws [StateError].
  Future<void> playYoutubeStoryNarration({
    required String storyId,
    required String videoId,
    required String title,
    String? narrator,
    Duration? position,
    double speed = 1.0,
  }) async {
    if (kIsWeb) {
      throw StateError('youtube_audio_web');
    }
    final url = await StoryYoutubeAudioStream.resolveDirectAudioUrl(videoId);
    if (url == null || url.isEmpty) {
      throw StateError('youtube_audio_resolve');
    }

    await playStoryNarration(
      storyId: storyId,
      url: url,
      title: title,
      narrator: narrator,
      position: position,
      speed: speed,
    );
  }

  /// Prophet story archive (MP3) — same player as Tilawat; survives navigation on mobile.
  Future<void> playStoryNarration({
    required String storyId,
    required String url,
    required String title,
    String? narrator,
    Duration? position,
    double speed = 1.0,
  }) async {
    if (_handler != null) {
      await _handler!.playStoryNarration(
        storyId: storyId,
        url: url,
        title: title,
        narrator: narrator,
        position: position,
        speed: speed,
      );
      notifyListeners();
      unawaited(_refreshArchiveStoryOrder());
      return;
    }

    _webStorySessionActive = true;
    _webStoryId = storyId;
    _webStoryUrl = url;
    _webStoryTitle = title;
    _webStoryNarrator = narrator;
    _currentIndex = null;
    notifyListeners();

    try {
      await _player.stop();
      await StoryYoutubeAudioStream.setPlayerSourceForUrl(_player, url);
      await _player.setSpeed(speed);
      final pos = position ?? Duration.zero;
      if (pos > Duration.zero) {
        await _player.seek(pos);
      }
      await _player.play();
      notifyListeners();
      unawaited(_refreshArchiveStoryOrder());
    } catch (_) {
      _clearWebStorySession();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> playSurahAt(int index, {Duration? position}) async {
    if (_handler != null) {
      final r = await _handler!.playSurahAt(index, position: position);
      if (r != null) {
        TilawatPlaybackFeedback.showReciterFallbackIfNeeded(
          usedDefaultReciterFallback: r.usedDefaultReciterFallback,
          effectiveReciterName: r.effectiveReciter,
        );
      }
      notifyListeners();
      return;
    }

    await ensureSurahsLoaded();
    if (_webSurahs.isEmpty || index < 0 || index >= _webSurahs.length) {
      return;
    }

    _clearWebStorySession();

    final int? previousIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();

    final surah = Map<String, dynamic>.from(_webSurahs[index] as Map);
    final reciter = _settings.selectedReciter;
    final pos = position ?? Duration.zero;

    try {
      await _player.stop();
      final result = await QuranAudioService.setPlayerSourceWithFallback(
        player: _player,
        surahNumber: surah['number'] as int,
        surah: surah,
        reciter: reciter,
        downloadProvider: _download,
      );
      _playbackEffectiveReciter = result.effectiveReciter;
      TilawatPlaybackFeedback.showReciterFallbackIfNeeded(
        usedDefaultReciterFallback: result.usedDefaultReciterFallback,
        effectiveReciterName: result.effectiveReciter,
      );
      if (pos > Duration.zero) {
        await _player.seek(pos);
      }
      await _player.play();
      notifyListeners();
      await _persistLast(index, pos);
    } catch (_) {
      _currentIndex = previousIndex;
      _playbackEffectiveReciter = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pause() async {
    if (_handler != null) {
      await _handler!.pause();
    } else {
      await _player.pause();
      if (_webStorySessionActive && _webStoryId != null) {
        await _persistStoryPositionWeb(_webStoryId!, _player.position);
      } else if (_currentIndex != null) {
        await _persistLast(_currentIndex!, _player.position);
      }
    }
    notifyListeners();
  }

  Future<void> resume() async {
    if (_handler != null) {
      await _handler!.play();
      notifyListeners();
      return;
    }
    if (_webStorySessionActive) {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      if (_player.audioSource == null &&
          _webStoryId != null &&
          (_webStoryUrl ?? '').isNotEmpty) {
        await playStoryNarration(
          storyId: _webStoryId!,
          url: _webStoryUrl!,
          title: _webStoryTitle ?? '',
          narrator: _webStoryNarrator,
          position: Duration.zero,
          speed: _player.speed,
        );
        return;
      }
      await _player.play();
      notifyListeners();
      return;
    }
    if (_currentIndex == null) return;
    if (_player.audioSource == null) {
      await playSurahAt(_currentIndex!, position: _player.position);
      return;
    }
    if (_player.processingState == ProcessingState.completed) {
      await playSurahAt(_currentIndex!, position: Duration.zero);
      return;
    }
    await _player.play();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration d) async {
    if (_handler != null) {
      await _handler!.seek(d);
    } else {
      await _player.seek(d);
      if (_webStorySessionActive && _webStoryId != null) {
        await _persistStoryPositionWeb(_webStoryId!, d);
      } else if (_currentIndex != null) {
        await _persistLast(_currentIndex!, d);
      }
    }
    notifyListeners();
  }

  Future<void> skipNext() async {
    if (isStoryNarrationSession) {
      await skipAdjacentArchiveStory(1);
      return;
    }
    if (_handler != null) {
      await _handler!.skipToNext();
      notifyListeners();
      return;
    }
    if (_currentIndex == null || _currentIndex! >= _webSurahs.length - 1) {
      return;
    }
    await playSurahAt(_currentIndex! + 1);
  }

  Future<void> skipPrevious() async {
    if (isStoryNarrationSession) {
      await skipAdjacentArchiveStory(-1);
      return;
    }
    if (_handler != null) {
      await _handler!.skipToPrevious();
      notifyListeners();
      return;
    }
    if (_currentIndex == null || _currentIndex! <= 0) return;
    await playSurahAt(_currentIndex! - 1);
  }

  Future<void> setAutoPlayNext(bool v) async {
    _autoPlayNext = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TilawatPlaybackKeys.autoPlayNext, v);
    notifyListeners();
  }

  Future<void> setRepeatCurrentSurah(bool v) async {
    _repeatCurrentSurah = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(TilawatPlaybackKeys.repeatCurrentSurah, v);
    notifyListeners();
  }

  Future<void> _persistSleepEnd(DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      TilawatPlaybackKeys.sleepEndsAtEpochMs,
      end.millisecondsSinceEpoch,
    );
  }

  Future<void> _clearSleepPrefsOnly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TilawatPlaybackKeys.sleepEndsAtEpochMs);
  }

  void setSleepTimerMinutes(int? minutes) {
    _sleepTicker?.cancel();
    if (minutes == null || minutes <= 0) {
      _sleepTimerEndsAt = null;
      unawaited(_clearSleepPrefsOnly());
      notifyListeners();
      return;
    }
    _sleepTimerEndsAt = DateTime.now().add(Duration(minutes: minutes));
    unawaited(_persistSleepEnd(_sleepTimerEndsAt!));
    _sleepTicker =
        Timer.periodic(const Duration(seconds: 5), (_) => unawaited(_tickSleepFromPrefs()));
    notifyListeners();
  }

  void clearSleepTimer() {
    _sleepTicker?.cancel();
    _sleepTimerEndsAt = null;
    unawaited(_clearSleepPrefsOnly());
    notifyListeners();
  }

  Future<void> persistProgressDebounced() async {
    _savePositionDebounce?.cancel();
    _savePositionDebounce = Timer(const Duration(seconds: 2), () async {
      if (!_player.playing) return;
      if (_handler != null) {
        await _handler!.persistProgressDebounced();
        return;
      }
      if (_webStorySessionActive && _webStoryId != null) {
        await _persistStoryPositionWeb(_webStoryId!, _player.position);
        return;
      }
      if (currentSurahIndex != null) {
        await _persistLast(currentSurahIndex!, _player.position);
      }
    });
  }

  Future<void> _persistLast(int index, Duration position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(TilawatPlaybackKeys.lastSurahIndex, index);
    await prefs.setInt(
      TilawatPlaybackKeys.lastPositionMs,
      position.inMilliseconds,
    );
  }

  Future<void> resumeFromSavedProgress() async {
    if (_handler != null) {
      await _handler!.resumeFromSavedProgress();
      notifyListeners();
      return;
    }
    await ensureSurahsLoaded();
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(TilawatPlaybackKeys.lastSurahIndex);
    final ms = prefs.getInt(TilawatPlaybackKeys.lastPositionMs);
    if (idx == null || idx < 0 || idx >= _webSurahs.length) return;
    await playSurahAt(idx, position: Duration(milliseconds: ms ?? 0));
  }

  static Future<bool> hasSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(TilawatPlaybackKeys.lastSurahIndex);
    return idx != null;
  }

  @override
  void dispose() {
    _disposed = true;
    _settings.removeListener(_onSettingsChanged);
    _playerStateSub?.cancel();
    _processingSub?.cancel();
    _sleepTicker?.cancel();
    _savePositionDebounce?.cancel();
    if (_handler == null) {
      _player.dispose();
    }
    super.dispose();
  }
}
