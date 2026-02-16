import '../entities/class_entity.dart';

abstract class ClassesRepository {
  Future<List<ClassEntity>> getClasses();
  Future<ClassEntity?> getClassById(String id);
  Future<List<ClassEntity>> getClassesByTeacher(String teacherId);
}
