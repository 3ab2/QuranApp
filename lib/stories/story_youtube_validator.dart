import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'story_youtube_policy.dart';

/// Runtime validation that a [videoId] belongs to an approved channel (oEmbed).
///
/// On **Web**, cross-origin restrictions may block this probe; callers should
/// treat `null` as "unknown" and rely on the curated registry instead.
Future<bool?> verifyYoutubeVideoTrustedChannel(String videoId) async {
  if (!isYoutubeVideoIdFormatValid(videoId)) return false;
  if (kBlockedMultiStoryYoutubeVideoIds.contains(videoId)) return false;

  if (kIsWeb) {
    // oEmbed from the browser is often blocked by CORS; curated registry is authoritative.
    return null;
  }

  final uri = Uri.parse(
    'https://www.youtube.com/oembed?format=json&url='
    'https://www.youtube.com/watch?v=${Uri.encodeComponent(videoId)}',
  );
  try {
    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode < 200 || res.statusCode >= 300) return false;
    final map = jsonDecode(res.body);
    if (map is! Map<String, dynamic>) return false;
    final authorUrl = map['author_url']?.toString();
    return isYoutubeAuthorUrlTrusted(authorUrl);
  } catch (_) {
    return false;
  }
}
