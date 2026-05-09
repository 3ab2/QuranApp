import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/download_provider.dart';
import '../providers/settings_provider.dart';
import 'quran_audio_service.dart';
import 'tilawat_playback_keys.dart';

bool tilawatUseBackgroundAudioHandler() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

/// [AudioHandler] for tilawat: foreground service (Android), lock screen / control center (iOS),
/// media notification actions. Owns the single [AudioPlayer] on mobile.
class TilawatAudioHandler extends BaseAudioHandler with SeekHandler {
  TilawatAudioHandler({
    required SettingsProvider settings,
    required DownloadProvider download,
  })  : _settings = settings,
        _download = download {
    _init();
  }

  final SettingsProvider _settings;
  final DownloadProvider _download;

  final AudioPlayer _player = AudioPlayer();

  List<dynamic> _surahs = [];
  bool _surahsLoaded = false;
  int? _currentIndex;
  String? _playbackEffectiveReciter;
  String _trackedSettingsReciter = '';

  AudioPlayer get player => _player;

  /// Matches the voice actually loaded (after optional default-reciter fallback).
  String? get playbackEffectiveReciter => _playbackEffectiveReciter;

  void clearPlaybackReciterOverride() {
    _playbackEffectiveReciter = null;
  }

  List<dynamic> get surahs => _surahs;
  bool get surahsLoaded => _surahsLoaded;
  int? get currentSurahIndex => _currentIndex;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    _trackedSettingsReciter = _settings.selectedReciter;
    _settings.addListener(_onSettingsChanged);
    await _player.setVolume(_settings.volume);

    _player.playbackEventStream.listen(_broadcastPlaybackState);
    _player.playerStateStream.listen((_) {
      _broadcastPlaybackState(_player.playbackEvent);
    });

    ProcessingState? lastProc;
    _player.processingStateStream.listen((state) {
      if (lastProc != ProcessingState.completed &&
          state == ProcessingState.completed) {
        unawaited(_onTrackCompleted());
      }
      lastProc = state;
    });

    _player.durationStream.listen((d) {
      final item = mediaItem.value;
      if (d != null && item != null) {
        mediaItem.add(item.copyWith(duration: d));
      }
    });

    Timer.periodic(const Duration(seconds: 5), (_) {
      unawaited(_tickSleepTimer());
    });
  }

  void _onSettingsChanged() {
    unawaited(_player.setVolume(_settings.volume));
    if (_settings.selectedReciter != _trackedSettingsReciter) {
      _trackedSettingsReciter = _settings.selectedReciter;
      _playbackEffectiveReciter = null;
    }
  }

  Future<void> ensureSurahsLoaded() async {
    if (_surahsLoaded) return;
    try {
      _surahs = await QuranAudioService.loadSurahs();
      _surahsLoaded = true;
    } catch (_) {
      _surahs = [];
      _surahsLoaded = true;
    }
  }

  MediaItem _mediaItemForSurah(
    Map<String, dynamic> surah,
    String playbackId,
    String artistLabel,
  ) {
    final name = surah['name']?.toString() ?? '';
    final num = surah['number'];
    return MediaItem(
      id: playbackId,
      title: name,
      artist: artistLabel,
      album: 'Tilawat',
      displaySubtitle: num != null ? 'Surah $num' : null,
    );
  }

  Future<AudioResolutionResult?> playSurahAt(int index,
      {Duration? position}) async {
    await ensureSurahsLoaded();
    if (_surahs.isEmpty || index < 0 || index >= _surahs.length) return null;

    final int? previousIndex = _currentIndex;
    _currentIndex = index;

    final surah = Map<String, dynamic>.from(_surahs[index] as Map);
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
      final playbackId = result.usingLocal && result.localPath != null
          ? result.localPath!
          : (result.remoteUrl ?? '${surah['number']}_$reciter');
      mediaItem.add(
        _mediaItemForSurah(surah, playbackId, result.effectiveReciter),
      );

      if (pos > Duration.zero) {
        await _player.seek(pos);
      }
      await _player.play();
      await _persistLast(index, pos);
      _broadcastPlaybackState(_player.playbackEvent);
      return result;
    } catch (_) {
      _currentIndex = previousIndex;
      _playbackEffectiveReciter = null;
      rethrow;
    }
  }

  Future<void> _onTrackCompleted() async {
    if (await _sleepShouldStop()) {
      await pause();
      await _clearSleepPrefs();
      return;
    }
    final repeat = await _readRepeatFlag();
    if (repeat && _currentIndex != null) {
      await playSurahAt(_currentIndex!, position: Duration.zero);
      return;
    }
    final autoNext = await _readAutoNextFlag();
    if (autoNext &&
        _currentIndex != null &&
        _currentIndex! < _surahs.length - 1) {
      await playSurahAt(_currentIndex! + 1);
    }
  }

  Future<bool> _sleepShouldStop() async {
    final prefs = await SharedPreferences.getInstance();
    final end = prefs.getInt(TilawatPlaybackKeys.sleepEndsAtEpochMs);
    if (end == null || end <= 0) return false;
    return !DateTime.now().isBefore(
      DateTime.fromMillisecondsSinceEpoch(end),
    );
  }

  Future<void> _tickSleepTimer() async {
    if (!await _sleepShouldStop()) return;
    await pause();
    await _clearSleepPrefs();
  }

  Future<void> _clearSleepPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TilawatPlaybackKeys.sleepEndsAtEpochMs);
  }

  Future<bool> _readAutoNextFlag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(TilawatPlaybackKeys.autoPlayNext) ?? false;
  }

  Future<bool> _readRepeatFlag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(TilawatPlaybackKeys.repeatCurrentSurah) ?? false;
  }

  @override
  Future<void> play() async {
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
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    if (_currentIndex != null) {
      await _persistLast(_currentIndex!, _player.position);
    }
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    if (_currentIndex != null) {
      await _persistLast(_currentIndex!, position);
    }
    _broadcastPlaybackState(_player.playbackEvent);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _broadcastPlaybackState(_player.playbackEvent);
    await playbackState.firstWhere(
      (state) => state.processingState == AudioProcessingState.idle,
    );
  }

  @override
  Future<void> skipToNext() async {
    if (_currentIndex == null || _currentIndex! >= _surahs.length - 1) {
      return;
    }
    await playSurahAt(_currentIndex! + 1);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentIndex == null || _currentIndex! <= 0) return;
    await playSurahAt(_currentIndex! - 1);
  }

  Future<void> persistProgressDebounced() async {
    if (_currentIndex == null || !_player.playing) return;
    await _persistLast(_currentIndex!, _player.position);
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
    await ensureSurahsLoaded();
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(TilawatPlaybackKeys.lastSurahIndex);
    final ms = prefs.getInt(TilawatPlaybackKeys.lastPositionMs);
    if (idx == null || idx < 0 || idx >= _surahs.length) return;
    await playSurahAt(idx, position: Duration(milliseconds: ms ?? 0));
  }

  void _broadcastPlaybackState(PlaybackEvent _) {
    final playing = _player.playing;
    final idx = _currentIndex;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: idx,
    ));
  }
}
