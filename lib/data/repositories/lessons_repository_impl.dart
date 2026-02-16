import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/domain/entities/lesson_entity.dart';
import 'package:high_school/domain/repositories/lessons_repository.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  final List<LessonEntity> _lessons = List.from(MockData.lessons);

  @override
  Future<List<LessonEntity>> getLessons({String? classId}) async {
    if (classId != null) return _lessons.where((l) => l.classId == classId).toList();
    return _lessons;
  }

  @override
  Future<LessonEntity?> getLessonById(String id) async {
    try {
      return _lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addLesson(LessonEntity lesson) async {
    _lessons.insert(0, lesson);
  }

  @override
  Future<void> updateLesson(String id, LessonEntity lesson) async {
    final i = _lessons.indexWhere((l) => l.id == id);
    if (i >= 0) _lessons[i] = lesson;
  }

  @override
  Future<void> deleteLesson(String id) async {
    _lessons.removeWhere((l) => l.id == id);
  }
}
