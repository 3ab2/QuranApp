import 'story_youtube_policy.dart';

/// Curated **one story = one video** narration from approved channels only.
///
/// Video IDs were matched from the official channel feed for
/// [kTrustedYoutubeChannelNabilAlAwadi] (الشيخ نبيل العوضي). Titles were checked
/// to avoid multi-prophet compilation videos; known multi-prophet uploads are
/// listed in [kBlockedMultiStoryYoutubeVideoIds] and must never be referenced here.
///
/// Stories without a dedicated single-prophet video on the approved sources
/// intentionally return `null` (graceful UI fallback).
class StoryYoutubeVideoEntry {
  final String videoId;
  final String narratorLabel;
  final String channelNote;

  const StoryYoutubeVideoEntry({
    required this.videoId,
    required this.narratorLabel,
    this.channelNote = 'UCpPZKwayH_pWPF20Ls0hgVw',
  });
}

const Map<String, StoryYoutubeVideoEntry> kStoryYoutubeVideoById = {
  'adam': StoryYoutubeVideoEntry(
    videoId: '4AkyNzYBxxA',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'idris': StoryYoutubeVideoEntry(
    videoId: 'CQu2vEZr2Sg',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'nuh': StoryYoutubeVideoEntry(
    videoId: '7yN8TeU_HoA',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'hud': StoryYoutubeVideoEntry(
    videoId: 'V4WkSi8y3Hw',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'salih': StoryYoutubeVideoEntry(
    videoId: 'vj1iSYKLSaw',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'ibrahim': StoryYoutubeVideoEntry(
    videoId: 'AMK7OFSJ2k4',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'yusuf': StoryYoutubeVideoEntry(
    videoId: '5Ql0mX4obm0',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'ayyub': StoryYoutubeVideoEntry(
    videoId: 'b2tzws24Ogc',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'shuayb': StoryYoutubeVideoEntry(
    videoId: 'BEP6aJ1jRMg',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'musa': StoryYoutubeVideoEntry(
    videoId: 'jYDuvsluQqM',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'yunus': StoryYoutubeVideoEntry(
    videoId: 'eG3pXEC9hDE',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'dawud': StoryYoutubeVideoEntry(
    videoId: 'WHZRHoiGqUI',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
  'sulayman': StoryYoutubeVideoEntry(
    videoId: '5rorrXG8kkk',
    narratorLabel: 'الشيخ نبيل العوضي',
  ),
};

StoryYoutubeVideoEntry? storyYoutubeEntryFor(String storyId) {
  final entry = kStoryYoutubeVideoById[storyId];
  if (entry == null) return null;
  if (kBlockedMultiStoryYoutubeVideoIds.contains(entry.videoId)) return null;
  if (!isYoutubeVideoIdFormatValid(entry.videoId)) return null;
  return entry;
}

bool storyHasYoutubeNarration(String storyId) =>
    storyYoutubeEntryFor(storyId) != null;
