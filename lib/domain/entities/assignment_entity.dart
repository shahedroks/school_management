enum AssignmentStatus { pending, submitted, graded }

class AssignmentEntity {
  final String id;
  final String classId;
  final String title;
  final String description;
  final String dueDate;
  final int points;
  final AssignmentStatus status;
  final int? grade;
  final String? feedback;
  final List<SubmissionEntity>? submissions;

  const AssignmentEntity({
    required this.id,
    required this.classId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.points,
    required this.status,
    this.grade,
    this.feedback,
    this.submissions,
  });
}

class SubmissionEntity {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final String? fileUrl;
  final String? text;
  final String submittedAt;
  final String? status;
  final int? grade;
  final String? feedback;

  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    this.fileUrl,
    this.text,
    required this.submittedAt,
    this.status,
    this.grade,
    this.feedback,
  });
}
