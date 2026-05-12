/// Trusted YouTube sources for **Prophet Stories narration only** (isolated domain).
///
/// Allowed channels (mandatory):
/// - `https://youtube.com/@dar-al-haqq.?…` (handle: dar-al-haqq)
/// - `https://youtube.com/channel/UCpPZKwayH_pWPF20Ls0hgVw?…` (الشيخ نبيل العوضي)
const String kTrustedYoutubeChannelNabilAlAwadi = 'UCpPZKwayH_pWPF20Ls0hgVw';

const Set<String> kBlockedMultiStoryYoutubeVideoIds = {
  // Explicitly rejected: one video covering multiple prophets (user rule).
  'fnw8EAtNSkQ',
};

bool isYoutubeAuthorUrlTrusted(String? authorUrl) {
  if (authorUrl == null) return false;
  final u = authorUrl.toLowerCase();
  return u.contains(kTrustedYoutubeChannelNabilAlAwadi.toLowerCase()) ||
      u.contains('dar-al-haqq') ||
      u.contains('daralhaqq');
}

bool isYoutubeVideoIdFormatValid(String id) {
  final t = id.trim();
  return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(t);
}
