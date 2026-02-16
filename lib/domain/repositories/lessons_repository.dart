import '../entities/lesson_entity.dart';

abstract class LessonsRepository {
  Future<List<LessonEntity>> getLessons({String? classId});
  Future<LessonEntity?> getLessonById(String id);
  Future<void> addLesson(LessonEntity lesson);
  Future<void> updateLesson(String id, LessonEntity lesson);
  Future<void> deleteLesson(String id);
}
