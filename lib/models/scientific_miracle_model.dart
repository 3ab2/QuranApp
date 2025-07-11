class ScientificMiracle {
  final int id;
  final String verse;
  final String surah;
  final int ayah;
  final String explanation;
  final String audio;
  final String category;

  ScientificMiracle({
    required this.id,
    required this.verse,
    required this.surah,
    required this.ayah,
    required this.explanation,
    required this.audio,
    required this.category,
  });

  factory ScientificMiracle.fromJson(Map<String, dynamic> json) {
    return ScientificMiracle(
      id: json['id'],
      verse: json['verse'],
      surah: json['surah'],
      ayah: json['ayah'],
      explanation: json['explanation'],
      audio: json['audio'],
      category: json['category'],
    );
  }
} 