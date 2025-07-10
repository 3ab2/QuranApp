class ProphetStory {
  final String name;
  final String date;
  final String lessons;
  final String text;
  final String? imageUrl;
  final String? videoUrl;

  ProphetStory({
    required this.name,
    required this.date,
    required this.lessons,
    required this.text,
    this.imageUrl,
    this.videoUrl,
  });
} 