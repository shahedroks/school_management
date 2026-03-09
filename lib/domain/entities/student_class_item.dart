import 'package:high_school/domain/entities/class_entity.dart';

/// One item from GET /students/student/classes or GET /classes/student/my.
/// data: Array of { classId, subject, gradeLevel, teacher: { id, name }, studentsCount, maxStudents, status }
class StudentClassItem {
  const StudentClassItem({
    required this.classId,
    required this.subject,
    required this.gradeLevel,
    required this.teacherId,
    required this.teacherName,
    required this.studentsCount,
    required this.maxStudents,
    required this.status,
  });

  final String classId;
  final String subject;
  final String gradeLevel;
  final String teacherId;
  final String teacherName;
  final int studentsCount;
  final int maxStudents;
  final String status;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory StudentClassItem.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'];
    String tid = '';
    String tname = '';
    if (teacher is Map<String, dynamic>) {
      tid = teacher['id']?.toString() ?? teacher['_id']?.toString() ?? '';
      tname = teacher['name']?.toString() ?? '';
    }
    return StudentClassItem(
      classId: json['classId']?.toString() ?? json['_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      gradeLevel: json['gradeLevel']?.toString() ?? '',
      teacherId: tid,
      teacherName: tname,
      studentsCount: _toInt(json['studentsCount'] ?? json['students']),
      maxStudents: _toInt(json['maxStudents']),
      status: json['status']?.toString() ?? 'active',
    );
  }

  /// Map to ClassEntity for use with existing classes list UI.
  ClassEntity toClassEntity() {
    return ClassEntity(
      id: classId,
      name: subject,
      subject: subject,
      category: 'Core',
      teacher: teacherName,
      teacherId: teacherId,
      students: studentsCount,
      color: '#1F3C88',
      schedule: '',
      room: '',
      level: gradeLevel,
      schoolYear: '',
    );
  }
}
