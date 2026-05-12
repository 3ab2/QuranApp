/// Domain guard: prophet stories must never play Quran recitation URLs.
bool isAllowedProphetStoryAudioUrl(String? raw) {
  if (raw == null) return false;
  final u = raw.trim().toLowerCase();
  if (u.isEmpty) return false;
  if (!u.startsWith('https://')) return false;
  if (u.contains('example.com') || u.contains('your-api.com')) return false;
  if (u.contains('mp3quran.net')) return false;
  if (u.contains('quranicaudio.com')) return false;
  if (u.contains('verses.quran.com')) return false;
  if (u.contains('everyayah.com')) return false;
  if (u.contains('api.quran.com')) return false;
  if (u.contains('/quran/') && u.contains('.mp3')) return false;
  if (!_isTrustedNarrationHost(u)) return false;
  return _looksLikeNarrationMedia(u);
}

bool _isTrustedNarrationHost(String url) {
  return url.contains('archive.org/download/') ||
      url.contains('archive.org/details/');
}

bool _looksLikeNarrationMedia(String url) {
  return url.contains('.mp3') ||
      url.contains('.ogg') ||
      url.contains('.m4a') ||
      url.contains('.mp4') ||
      url.contains('mime=audio');
}
