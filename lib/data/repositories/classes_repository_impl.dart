import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';

class ClassesRepositoryImpl implements ClassesRepository {
  @override
  Future<List<ClassEntity>> getClasses() async => MockData.classes;

  @override
  Future<ClassEntity?> getClassById(String id) async {
    try {
      return MockData.classes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ClassEntity>> getClassesByTeacher(String teacherId) async {
    return MockData.classes.where((c) => c.teacherId == teacherId).toList();
  }
}
