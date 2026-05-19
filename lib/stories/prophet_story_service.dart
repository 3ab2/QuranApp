import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../models/prophet_story.dart';

const String kDefaultProphetStoriesAsset = 'assets/data/prophet_stories.json';
const int kMinimumFullStoryLength = 280;

class StoryApiConfig {
  final Uri baseUri;
  final String storiesPath;
  final String storyPathTemplate;
  final Map<String, String> headers;
  final Duration timeout;

  const StoryApiConfig({
    required this.baseUri,
    this.storiesPath = '/stories',
    this.storyPathTemplate = '/stories/{id}',
    this.headers = const {},
    this.timeout = const Duration(seconds: 12),
  });

  Uri storiesUri() => baseUri.resolve(storiesPath);

  Uri storyUri(String id) {
    return baseUri
        .resolve(storyPathTemplate.replaceAll('{id}', Uri.encodeComponent(id)));
  }
}

abstract class ProphetStoryDataSource {
  Future<List<ProphetStory>> fetchStories();

  Future<ProphetStory> fetchStoryById(String id);
}

typedef StoryJsonLoader = Future<String> Function();

class JsonProphetStoryDataSource implements ProphetStoryDataSource {
  final StoryJsonLoader loadJson;

  const JsonProphetStoryDataSource({required this.loadJson});

  @override
  Future<List<ProphetStory>> fetchStories() async {
    final body = jsonDecode(await loadJson());
    final rawStories = _StoryJsonParser.extractStories(body);
    return rawStories.map(ProphetStory.fromJson).toList(growable: false);
  }

  @override
  Future<ProphetStory> fetchStoryById(String id) async {
    final stories = await fetchStories();
    return stories.firstWhere(
      (story) => story.id == id,
      orElse: () => throw StoryDataSourceException(
          'Story "$id" was not found in JSON source'),
    );
  }
}

class AssetProphetStoryDataSource extends JsonProphetStoryDataSource {
  AssetProphetStoryDataSource({required String assetPath})
      : super(loadJson: (() => rootBundle.loadString(assetPath)));
}

class HttpProphetStoryDataSource implements ProphetStoryDataSource {
  final StoryApiConfig config;
  final http.Client _client;

  HttpProphetStoryDataSource({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<List<ProphetStory>> fetchStories() async {
    final body = await _getJson(config.storiesUri());
    final rawStories = _StoryJsonParser.extractStories(body);
    return rawStories.map(ProphetStory.fromJson).toList(growable: false);
  }

  @override
  Future<ProphetStory> fetchStoryById(String id) async {
    final body = await _getJson(config.storyUri(id));
    final rawStory = _StoryJsonParser.extractStory(body);
    return ProphetStory.fromJson(rawStory);
  }

  Future<Object?> _getJson(Uri uri) async {
    final response =
        await _client.get(uri, headers: config.headers).timeout(config.timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StoryDataSourceException(
          'Stories API returned HTTP ${response.statusCode}');
    }
    return jsonDecode(response.body);
  }
}

class _StoryJsonParser {
  const _StoryJsonParser._();

  static List<Map<String, dynamic>> extractStories(Object? body) {
    final rawList = switch (body) {
      List<Object?> list => list,
      {'stories': List<Object?> list} => list,
      {'data': List<Object?> list} => list,
      _ => throw const FormatException(
          'Stories API response must be a list or contain stories/data'),
    };

    return rawList.map((item) {
      if (item is Map<String, dynamic>) return item;
      if (item is Map) return Map<String, dynamic>.from(item);
      throw const FormatException('Each story must be a JSON object');
    }).toList(growable: false);
  }

  static Map<String, dynamic> extractStory(Object? body) {
    if (body is Map<String, dynamic>) {
      final story = body['story'] ?? body['data'] ?? body;
      if (story is Map<String, dynamic>) return story;
      if (story is Map) return Map<String, dynamic>.from(story);
    }
    if (body is Map) {
      return extractStory(Map<String, dynamic>.from(body));
    }
    throw const FormatException('Story API response must be a JSON object');
  }
}

class ProphetStoryService {
  final ProphetStoryDataSource dataSource;
  Future<List<ProphetStory>>? _storiesFuture;
  List<ProphetStory>? _storiesCache;

  ProphetStoryService({required this.dataSource});

  factory ProphetStoryService.asset({
    String assetPath = kDefaultProphetStoriesAsset,
  }) {
    return ProphetStoryService(
      dataSource: AssetProphetStoryDataSource(assetPath: assetPath),
    );
  }

  Future<List<ProphetStory>> getStories() async {
    final cached = _storiesCache;
    if (cached != null) return cached;

    final inFlight = _storiesFuture;
    if (inFlight != null) return inFlight;

    final future = _loadStories();
    _storiesFuture = future;
    try {
      return await future;
    } catch (_) {
      _storiesFuture = null;
      rethrow;
    }
  }

  Future<List<ProphetStory>> _loadStories() async {
    final stories = await dataSource.fetchStories();
    final seenIds = <String>{};
    final seenProphetKeys = <String, String>{};
    final normalizedStories = stories.map((story) {
      final normalized = _enforceStoryContract(story);
      if (!seenIds.add(normalized.id)) {
        _debugDuplicate(
            'Duplicate story id detected: "${normalized.id}" (blocked).');
        throw FormatException('Duplicate story id "${normalized.id}"');
      }
      final prophetKey = _normalizeProphetKey(normalized.prophetName);
      if (prophetKey.isNotEmpty) {
        final existingId = seenProphetKeys[prophetKey];
        if (existingId != null) {
          _debugDuplicate(
              'Duplicate prophet name/slug detected: "${normalized.prophetName}" '
              '(story ids "$existingId" and "${normalized.id}") (blocked).');
          throw FormatException(
              'Duplicate prophet name "${normalized.prophetName}" detected');
        }
        seenProphetKeys[prophetKey] = normalized.id;
      }
      return normalized;
    }).toList(growable: false);
    _storiesCache = normalizedStories;
    _storiesFuture = null;
    return normalizedStories;
  }

  Future<ProphetStory> getStoryById(String id) async {
    final cached = _storiesCache;
    if (cached != null) {
      return cached.firstWhere(
        (story) => story.id == id,
        orElse: () =>
            throw StoryDataSourceException('Story "$id" was not found'),
      );
    }

    if (dataSource is JsonProphetStoryDataSource) {
      final stories = await getStories();
      return stories.firstWhere(
        (story) => story.id == id,
        orElse: () =>
            throw StoryDataSourceException('Story "$id" was not found'),
      );
    }

    return _enforceStoryContract(await dataSource.fetchStoryById(id),
        expectedId: id);
  }

  void clearCache() {
    _storiesFuture = null;
    _storiesCache = null;
  }

  ProphetStory _enforceStoryContract(ProphetStory story, {String? expectedId}) {
    if (expectedId != null && story.id != expectedId) {
      throw FormatException(
          'Story response id "${story.id}" does not match "$expectedId"');
    }
    if (story.fullContent.trim().isEmpty) {
      throw FormatException('Story ${story.id} is missing full_content');
    }
    if (story.fullContent.trim().length < kMinimumFullStoryLength) {
      throw FormatException(
          'Story ${story.id} full_content is too short for production');
    }
    // Stories are text-only in production; strip any legacy narration URLs.
    if (story.narrationUrl != null) {
      return story.copyWith(clearNarrationUrl: true);
    }
    return story;
  }

  String _normalizeProphetKey(String input) {
    final lowered = input.toLowerCase().trim();
    return lowered.replaceAll(RegExp(r'[\s\-_]+'), '');
  }

  void _debugDuplicate(String message) {
    if (kDebugMode) {
      debugPrint('[ProphetStoryService] $message');
    }
  }
}

class StoryDataSourceException implements Exception {
  final String message;

  const StoryDataSourceException(this.message);

  @override
  String toString() => message;
}

ProphetStoryService? _prophetStoryService;

ProphetStoryService get prophetStoryService {
  return _prophetStoryService ??= ProphetStoryService.asset();
}
