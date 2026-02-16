enum LessonType { text, pdf, video }
enum LessonStatus { draft, published }

class LessonEntity {
  final String id;
  final String classId;
  final String title;
  final String description;
  final LessonType type;
  final String content;
  final String date;
  final String? duration;
  final LessonStatus status;
  final String lastUpdated;
  final String? module;

  const LessonEntity({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.date,
    this.duration,
    required this.status,
    required this.lastUpdated,
    this.module,
  });
}
