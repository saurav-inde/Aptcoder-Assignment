class CourseModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final List<String> tags;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.tags,
  });

  factory CourseModel.fromMap(String id, Map<String, dynamic> data) {
    return CourseModel(
      id: id,
      title: data['title'] as String,
      description: data['description'] as String,
      thumbnail: data['thumbnail'] as String,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }
}
