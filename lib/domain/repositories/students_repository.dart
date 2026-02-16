import '../entities/student_entity.dart';

abstract class StudentsRepository {
  Future<List<StudentEntity>> getStudents({String? classId});
  Future<StudentEntity?> getStudentById(String id);
}
