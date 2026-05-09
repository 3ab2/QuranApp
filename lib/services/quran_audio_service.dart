import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import '../providers/download_provider.dart';

class AudioResolutionResult {
  final bool usingLocal;
  final bool usingRemote;
  final String? localPath;
  final String? remoteUrl;
  final String requestedReciter;
  final String effectiveReciter;
  final bool usedDefaultReciterFallback;

  const AudioResolutionResult({
    required this.usingLocal,
    required this.usingRemote,
    this.localPath,
    this.remoteUrl,
    required this.requestedReciter,
    required this.effectiveReciter,
    this.usedDefaultReciterFallback = false,
  });
}

class QuranAudioService {
  static List<dynamic>? _cachedSurahs;

  /// App default when remote for selected reciter is unavailable (after mirrors).
  static const String defaultReciterName = 'ماهر المعيقلي';

  /// Ordered base URL prefixes (no trailing slash). Multiple entries = mirrors for same reciter.
  static const Map<String, List<String>> _reciterBaseUrlLists = {
    defaultReciterName: [
      'https://server12.mp3quran.net/maher',
    ],
    'عبد الباسط عبد الصمد': [
      'https://server7.mp3quran.net/basit',
      'https://server7.mp3quran.net/download/basit',
    ],
    'مشاري العفاسي': [
      'https://server8.mp3quran.net/afs',
    ],
    'سعد الغامدي': [
      'https://server7.mp3quran.net/s_gmd',
    ],
  };

  /// Short ASCII slug for filenames / IndexedDB keys (per-reciter offline storage).
  static String reciterStorageSlug(String reciter) {
    const slugByName = <String, String>{
      'ماهر المعيقلي': 'maher',
      'عبد الباسط عبد الصمد': 'abdulbasit',
      'مشاري العفاسي': 'afasy',
      'سعد الغامدي': 'ghamdi',
    };
    return slugByName[reciter] ?? 'r${reciter.hashCode.abs()}';
  }

  static String tilawatCacheId(int surahNumber, String reciter) =>
      '${surahNumber}_${reciterStorageSlug(reciter)}';

  static Future<List<dynamic>> loadSurahs() async {
    if (_cachedSurahs != null) return _cachedSurahs!;
    final jsonString = await rootBundle.loadString('assets/data/surahs.json');
    final data = json.decode(jsonString);
    if (data is List) {
      _cachedSurahs = data;
      return data;
    }
    throw const FormatException('Invalid surah audio catalog format');
  }

  static String _paddedSurahFileName(Map surah) {
    final surahNumber = surah['number'] as int?;
    return surahNumber?.toString().padLeft(3, '0') ?? '';
  }

  /// Remote MP3 URLs to try in order for [reciter] and this [surah].
  static List<String> remoteUrlCandidatesForSurah(Map surah, String reciter) {
    final padded = _paddedSurahFileName(surah);
    if (padded.isEmpty) return const [];

    final bases = _reciterBaseUrlLists[reciter];
    if (bases != null) {
      return bases.map((b) => '$b/$padded.mp3').toList();
    }

    final rawAudio = surah['audio']?.toString().trim() ?? '';
    if (rawAudio.contains('{reciter}')) {
      final u = rawAudio.replaceAll(
        '{reciter}',
        reciter.toLowerCase().replaceAll(' ', '-'),
      );
      return u.isNotEmpty ? [u] : const [];
    }

    final isTrustedQuranHost = rawAudio.contains('mp3quran.net') ||
        rawAudio.contains('download.quranicaudio.com') ||
        rawAudio.contains('everyayah.com');

    if (rawAudio.isNotEmpty &&
        !rawAudio.contains('your-api.com') &&
        !rawAudio.contains('example.com') &&
        isTrustedQuranHost) {
      return [rawAudio];
    }

    return const [];
  }

  /// First candidate URL (for downloads / display). No silent cross-reciter substitution.
  static String resolveRemoteUrl(Map surah, String reciter) {
    final list = remoteUrlCandidatesForSurah(surah, reciter);
    return list.isNotEmpty ? list.first : '';
  }

  static Future<void> _trySetUrl(AudioPlayer player, String url) async {
    await player.setUrl(url);
  }

  static Future<AudioResolutionResult> setPlayerSourceWithFallback({
    required AudioPlayer player,
    required int surahNumber,
    required Map surah,
    required String reciter,
    required DownloadProvider downloadProvider,
  }) async {
    final requestedReciter = reciter;
    final localPath =
        await downloadProvider.getLocalFilePath(surahNumber, reciter);

    if (localPath != null) {
      try {
        if (kIsWeb && localPath.startsWith('blob:')) {
          await player.setUrl(localPath);
        } else {
          await player.setFilePath(localPath);
        }
        final remoteFirst = resolveRemoteUrl(surah, reciter);
        debugPrint(
          '[Tilawat] surah=$surahNumber local=true requested=$requestedReciter effective=$requestedReciter',
        );
        return AudioResolutionResult(
          usingLocal: true,
          usingRemote: false,
          localPath: localPath,
          remoteUrl: remoteFirst.isEmpty ? null : remoteFirst,
          requestedReciter: requestedReciter,
          effectiveReciter: requestedReciter,
        );
      } catch (e) {
        debugPrint('Local audio failed for surah $surahNumber: $e');
      }
    }

    Future<AudioResolutionResult?> tryUrlsForReciter(
      String tryReciter,
      String effectiveLabel, {
      required bool usedFallback,
    }) async {
      final urls = remoteUrlCandidatesForSurah(surah, tryReciter);
      for (final url in urls) {
        if (url.isEmpty) continue;
        try {
          await _trySetUrl(player, url);
          debugPrint(
            '[Tilawat] surah=$surahNumber local=false url=$url '
            'requested=$requestedReciter effective=$effectiveLabel fallback=$usedFallback',
          );
          return AudioResolutionResult(
            usingLocal: false,
            usingRemote: true,
            remoteUrl: url,
            localPath: localPath,
            requestedReciter: requestedReciter,
            effectiveReciter: effectiveLabel,
            usedDefaultReciterFallback: usedFallback,
          );
        } catch (e) {
          debugPrint('[Tilawat] setUrl failed surah=$surahNumber url=$url err=$e');
        }
      }
      return null;
    }

    final primary = await tryUrlsForReciter(
      requestedReciter,
      requestedReciter,
      usedFallback: false,
    );
    if (primary != null) return primary;

    if (requestedReciter != defaultReciterName) {
      final fb = await tryUrlsForReciter(
        defaultReciterName,
        defaultReciterName,
        usedFallback: true,
      );
      if (fb != null) return fb;
    }

    throw Exception(
      'No valid local or remote source for surah $surahNumber (reciter: $requestedReciter)',
    );
  }

  static Future<bool> isLikelyAccessibleLocalPath(String path) async {
    if (kIsWeb) return path.startsWith('blob:');
    return File(path).exists();
  }
}
