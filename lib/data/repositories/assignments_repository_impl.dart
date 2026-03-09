import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';

class AssignmentsRepositoryImpl implements AssignmentsRepository {
  @override
  Future<List<AssignmentEntity>> getAssignments({String? classId}) async {
    var list = MockData.assignments;
    if (classId != null) list = list.where((a) => a.classId == classId).toList();
    return list;
  }

  @override
  Future<AssignmentEntity?> getAssignmentById(String id) async {
    try {
      final a = MockData.assignments.firstWhere((x) => x.id == id);
      final subs = MockData.submissions.where((s) => s.assignmentId == id).toList();
      return AssignmentEntity(
        id: a.id,
        classId: a.classId,
        title: a.title,
        description: a.description,
        dueDate: a.dueDate,
        points: a.points,
        status: a.status,
        grade: a.grade,
        feedback: a.feedback,
        submissions: subs.isNotEmpty ? subs : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addAssignment(AssignmentEntity assignment) async {
    MockData.assignments.add(assignment);
  }
}
