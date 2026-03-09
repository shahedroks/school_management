import '../entities/student_class_item.dart';

abstract class StudentClassesRepository {
  /// GET /students/student/classes (Auth). Returns list from API or empty when not configured/fails.
  Future<List<StudentClassItem>> getStudentClasses();
}
