class ProphetStory {
  final String id;
  final String prophetName;
  final String title;
  final String fullContent;
  final List<StorySection> timeline;
  final List<StorySection> lessons;
  final List<StorySection> events;
  final String? audioUrl;

  const ProphetStory({
    required this.id,
    required this.prophetName,
    required this.title,
    required this.fullContent,
    this.timeline = const [],
    this.lessons = const [],
    this.events = const [],
    this.audioUrl,
  });

  bool get hasAudio => audioUrl != null && audioUrl!.trim().isNotEmpty;

  ProphetStory copyWith({
    String? id,
    String? prophetName,
    String? title,
    String? fullContent,
    List<StorySection>? timeline,
    List<StorySection>? lessons,
    List<StorySection>? events,
    String? audioUrl,
    bool clearAudioUrl = false,
  }) {
    return ProphetStory(
      id: id ?? this.id,
      prophetName: prophetName ?? this.prophetName,
      title: title ?? this.title,
      fullContent: fullContent ?? this.fullContent,
      timeline: timeline ?? this.timeline,
      lessons: lessons ?? this.lessons,
      events: events ?? this.events,
      audioUrl: clearAudioUrl ? null : audioUrl ?? this.audioUrl,
    );
  }

  factory ProphetStory.fromJson(Map<String, dynamic> json) {
    final sections = json['sections'];
    final sectionMap =
        sections is Map<String, dynamic> ? sections : const <String, dynamic>{};

    return ProphetStory(
      id: _requiredString(json, 'id'),
      prophetName:
          _requiredString(json, 'prophet_name', fallbackKey: 'prophetName'),
      title: _requiredString(json, 'title'),
      fullContent:
          _requiredString(json, 'full_content', fallbackKey: 'fullContent'),
      timeline:
          StorySection.listFromJson(json['timeline'] ?? sectionMap['timeline']),
      lessons:
          StorySection.listFromJson(json['lessons'] ?? sectionMap['lessons']),
      events: StorySection.listFromJson(json['events'] ?? sectionMap['events']),
      audioUrl: _nullableString(json['audio_url'] ?? json['audioUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prophet_name': prophetName,
      'title': title,
      'full_content': fullContent,
      'sections': {
        'timeline': timeline.map((section) => section.toJson()).toList(),
        'lessons': lessons.map((section) => section.toJson()).toList(),
        'events': events.map((section) => section.toJson()).toList(),
      },
      'audio_url': audioUrl,
    };
  }

  static String _requiredString(
    Map<String, dynamic> json,
    String key, {
    String? fallbackKey,
  }) {
    final value = json[key] ?? (fallbackKey == null ? null : json[fallbackKey]);
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      throw FormatException('ProphetStory.$key is required');
    }
    return text;
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class StorySection {
  final String title;
  final String content;
  final int? order;

  const StorySection({
    required this.title,
    required this.content,
    this.order,
  });

  factory StorySection.fromJson(Map<String, dynamic> json) {
    return StorySection(
      title: json['title']?.toString().trim() ?? '',
      content: ProphetStory._requiredString(json, 'content'),
      order: json['order'] is int
          ? json['order'] as int
          : int.tryParse('${json['order'] ?? ''}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (order != null) 'order': order,
    };
  }

  static List<StorySection> listFromJson(Object? value) {
    if (value == null) return const [];
    if (value is String && value.trim().isNotEmpty) {
      return [StorySection(title: '', content: value.trim())];
    }
    if (value is! List) return const [];

    return value
        .map((item) {
          if (item is Map<String, dynamic>) {
            return StorySection.fromJson(item);
          }
          if (item is Map) {
            return StorySection.fromJson(Map<String, dynamic>.from(item));
          }
          return StorySection(title: '', content: item.toString().trim());
        })
        .where((section) => section.content.isNotEmpty)
        .toList(growable: false);
  }
}
