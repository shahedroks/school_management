import 'package:high_school/domain/entities/assignment_detail_result.dart';

abstract class StudentAssignmentDetailsRepository {
  /// Fetches assignment detail (and current student's submission if any) from API.
  /// Returns null if API is not configured or request fails.
  Future<AssignmentDetailResult?> getAssignmentDetail(String assignmentId);
}
