import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Resolves a direct HTTPS stream URL for YouTube audio-only playback via [just_audio].
///
/// On **web**, YouTube HTTP access is blocked by CORS — returns `null` (use a native build).
class StoryYoutubeAudioStream {
  StoryYoutubeAudioStream._();

  /// Browser-like UA often required for `googlevideo` URLs with [just_audio].
  static const String streamUserAgent =
      'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

  static Map<String, String> headersForUrl(String url) {
    final u = url.toLowerCase();
    if (u.contains('googlevideo.') ||
        u.contains('youtube.com') ||
        u.contains('ytimg.com')) {
      return {
        'User-Agent': streamUserAgent,
        'Accept': '*/*',
      };
    }
    return const {};
  }

  static bool needsStreamHeaders(String url) =>
      headersForUrl(url).isNotEmpty;

  /// [just_audio] needs a browser-like [User-Agent] for many YouTube CDN URLs.
  static Future<void> setPlayerSourceForUrl(AudioPlayer player, String url) async {
    final h = headersForUrl(url);
    if (h.isNotEmpty) {
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(url), headers: h),
      );
    } else {
      await player.setUrl(url);
    }
  }

  /// Best-effort audio-only stream; `null` if unavailable or on web.
  static Future<String?> resolveDirectAudioUrl(String rawVideoId) async {
    if (kIsWeb) return null;
    final id = rawVideoId.trim();
    if (id.isEmpty) return null;

    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(VideoId(id));
      if (manifest.audioOnly.isNotEmpty) {
        return manifest.audioOnly.withHighestBitrate().url.toString();
      }
      if (manifest.audio.isNotEmpty) {
        return manifest.audio.withHighestBitrate().url.toString();
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      yt.close();
    }
  }
}
