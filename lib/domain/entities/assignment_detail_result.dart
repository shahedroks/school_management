import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/domain/entities/class_entity.dart';

/// Result of GET /assignments/:assignmentId (student).
/// Holds assignment, optional class info, and current student's submission if any.
class AssignmentDetailResult {
  const AssignmentDetailResult({
    required this.assignment,
    this.classInfo,
    required this.hasSubmission,
    this.submittedAt,
    this.submissionFileUrl,
    this.submissionFileName,
    this.submissionType,
  });

  final AssignmentEntity assignment;
  final ClassEntity? classInfo;
  final bool hasSubmission;
  final String? submittedAt;
  final String? submissionFileUrl;
  final String? submissionFileName;
  /// e.g. 'file' or 'text'
  final String? submissionType;
}
