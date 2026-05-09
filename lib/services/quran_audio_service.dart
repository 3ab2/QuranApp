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

  const AudioResolutionResult({
    required this.usingLocal,
    required this.usingRemote,
    this.localPath,
    this.remoteUrl,
  });
}

class QuranAudioService {
  static List<dynamic>? _cachedSurahs;
  static const String _fallbackBaseUrl = 'https://server12.mp3quran.net/maher';
  static const Map<String, String> _reciterBaseUrls = {
    'ماهر المعيقلي': 'https://server12.mp3quran.net/maher',
    // Temporary mapping to a known-live Quran endpoint to avoid runtime 404s.
    'عبد الباسط عبد الصمد': 'https://server12.mp3quran.net/maher',
    'مشاري العفاسي': 'https://server8.mp3quran.net/afs',
    'سعد الغامدي': 'https://server7.mp3quran.net/s_gmd',
  };

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

  static String resolveRemoteUrl(Map surah, String reciter) {
    final surahNumber = surah['number'] as int?;
    final rawAudio = surah['audio']?.toString().trim() ?? '';
    final padded = surahNumber?.toString().padLeft(3, '0') ?? '';
    final reciterBase = _reciterBaseUrls[reciter];

    // Domain guard: Quran playback must always resolve through Quran audio datasets.
    if (reciterBase != null && padded.isNotEmpty) {
      return '$reciterBase/$padded.mp3';
    }

    if (rawAudio.contains('{reciter}')) {
      return rawAudio.replaceAll('{reciter}', reciter.toLowerCase().replaceAll(' ', '-'));
    }

    // Keep only known Quran hosts from catalog data; reject unrelated domains.
    final isTrustedQuranHost =
        rawAudio.contains('mp3quran.net') ||
        rawAudio.contains('download.quranicaudio.com') ||
        rawAudio.contains('everyayah.com');

    // Prevent placeholder/demo URLs from breaking runtime playback.
    if (rawAudio.isEmpty ||
        rawAudio.contains('your-api.com') ||
        rawAudio.contains('example.com') ||
        !isTrustedQuranHost) {
      if (padded.isNotEmpty) {
        return '$_fallbackBaseUrl/$padded.mp3';
      }
      return '';
    }
    return rawAudio;
  }

  static Future<AudioResolutionResult> setPlayerSourceWithFallback({
    required AudioPlayer player,
    required int surahNumber,
    required Map surah,
    required String reciter,
    required DownloadProvider downloadProvider,
  }) async {
    final localPath = await downloadProvider.getLocalFilePath(surahNumber);
    final remoteUrl = resolveRemoteUrl(surah, reciter);

    if (localPath != null) {
      try {
        await player.setFilePath(localPath);
        return AudioResolutionResult(
          usingLocal: true,
          usingRemote: false,
          localPath: localPath,
          remoteUrl: remoteUrl,
        );
      } catch (e) {
        debugPrint('Local audio failed for surah $surahNumber: $e');
      }
    }

    if (remoteUrl.isNotEmpty) {
      await player.setUrl(remoteUrl);
      return AudioResolutionResult(
        usingLocal: false,
        usingRemote: true,
        localPath: localPath,
        remoteUrl: remoteUrl,
      );
    }

    throw Exception('No valid local or remote source for surah $surahNumber');
  }

  static Future<bool> isLikelyAccessibleLocalPath(String path) async {
    if (kIsWeb) return path.startsWith('blob:');
    return File(path).exists();
  }
}
