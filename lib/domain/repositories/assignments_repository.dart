import '../entities/assignment_entity.dart';

abstract class AssignmentsRepository {
  Future<List<AssignmentEntity>> getAssignments({String? classId});
  Future<AssignmentEntity?> getAssignmentById(String id);
  Future<void> addAssignment(AssignmentEntity assignment);
}
