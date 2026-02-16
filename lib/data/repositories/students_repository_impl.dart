import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/domain/entities/student_entity.dart';
import 'package:high_school/domain/repositories/students_repository.dart';

class StudentsRepositoryImpl implements StudentsRepository {
  @override
  Future<List<StudentEntity>> getStudents({String? classId}) async => MockData.students;

  @override
  Future<StudentEntity?> getStudentById(String id) async {
    try {
      return MockData.students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
