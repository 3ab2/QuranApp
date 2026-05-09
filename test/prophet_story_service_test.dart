import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/models/prophet_story.dart';
import 'package:quran_app/stories/prophet_story_service.dart';

const _fullContent =
    'This is a complete chronological story body with enough narrative detail '
    'to pass the production contract. It describes the beginning of the story, '
    'the main events, the central trial, the outcome, and the lessons learned. '
    'It is intentionally longer than a summary so the service can reject short '
    'placeholder content before it reaches the UI.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProphetStory', () {
    test('parses the standardized backend contract', () {
      final story = ProphetStory.fromJson({
        'id': 'adam',
        'prophet_name': 'Adam',
        'title': 'Story of Adam',
        'full_content': _fullContent,
        'sections': {
          'timeline': [
            {'title': 'Creation', 'content': 'Adam was created.', 'order': 1},
          ],
          'lessons': ['Repentance is accepted.'],
          'events': [],
        },
        'audio_url': 'https://stories.example.org/audio/adam.mp3',
      });

      expect(story.id, 'adam');
      expect(story.prophetName, 'Adam');
      expect(story.fullContent, _fullContent);
      expect(story.timeline.single.title, 'Creation');
      expect(story.lessons.single.content, 'Repentance is accepted.');
      expect(story.audioUrl, 'https://stories.example.org/audio/adam.mp3');
    });

    test('requires full content instead of summaries', () {
      expect(
        () => ProphetStory.fromJson({
          'id': 'adam',
          'prophet_name': 'Adam',
          'title': 'Story of Adam',
          'full_content': '',
        }),
        throwsFormatException,
      );
    });
  });

  group('ProphetStoryService', () {
    test('loads stories from modular JSON and preserves valid story audio',
        () async {
      final service = ProphetStoryService(
        dataSource: JsonProphetStoryDataSource(
          loadJson: () async => jsonEncode({
            'data': [
              {
                'id': 'adam',
                'prophet_name': 'Adam',
                'title': 'Story of Adam',
                'full_content': _fullContent,
                'audio_url': 'https://stories.example.org/audio/adam.mp3',
              },
            ],
          }),
        ),
      );

      final stories = await service.getStories();

      expect(stories, hasLength(1));
      expect(stories.single.audioUrl,
          'https://stories.example.org/audio/adam.mp3');
    });

    test('removes Quran recitation audio from stories', () async {
      final service = ProphetStoryService(
        dataSource: JsonProphetStoryDataSource(
          loadJson: () async => jsonEncode([
            {
              'id': 'adam',
              'prophet_name': 'Adam',
              'title': 'Story of Adam',
              'full_content': _fullContent,
              'audio_url':
                  'https://download.quranicaudio.com/quran/example/001.mp3',
            },
          ]),
        ),
      );

      final stories = await service.getStories();

      expect(stories.single.audioUrl, isNull);
      expect(stories.single.hasAudio, isFalse);
    });

    test('rejects duplicate story ids', () async {
      final service = ProphetStoryService(
        dataSource: JsonProphetStoryDataSource(
          loadJson: () async => jsonEncode([
            {
              'id': 'adam',
              'prophet_name': 'Adam',
              'title': 'Story of Adam',
              'full_content': _fullContent,
            },
            {
              'id': 'adam',
              'prophet_name': 'Adam duplicate',
              'title': 'Story of Adam duplicate',
              'full_content': _fullContent,
            },
          ]),
        ),
      );

      expect(service.getStories(), throwsFormatException);
    });

    test('rejects summary-sized story content', () async {
      final service = ProphetStoryService(
        dataSource: JsonProphetStoryDataSource(
          loadJson: () async => jsonEncode([
            {
              'id': 'adam',
              'prophet_name': 'Adam',
              'title': 'Story of Adam',
              'full_content': 'Short summary only.',
            },
          ]),
        ),
      );

      expect(service.getStories(), throwsFormatException);
    });

    test('caches loaded stories and avoids repeated JSON parsing', () async {
      var loadCount = 0;
      final service = ProphetStoryService(
        dataSource: JsonProphetStoryDataSource(
          loadJson: () async {
            loadCount++;
            return jsonEncode([
              {
                'id': 'adam',
                'prophet_name': 'Adam',
                'title': 'Story of Adam',
                'full_content': _fullContent,
              },
            ]);
          },
        ),
      );

      await service.getStories();
      await service.getStoryById('adam');
      await service.getStories();

      expect(loadCount, 1);
    });

    test('production asset contains the complete prophet story set', () async {
      final service = ProphetStoryService.asset();

      final stories = await service.getStories();
      final adam = await service.getStoryById('adam');

      expect(stories, hasLength(25));
      expect(
          stories.every(
              (story) => story.fullContent.length >= kMinimumFullStoryLength),
          isTrue);
      expect(adam.events, isNotEmpty);
      expect(adam.timeline, isNotEmpty);
      expect(adam.lessons, isNotEmpty);
      expect(stories.every((story) => story.audioUrl == null), isTrue);
    });
  });
}
