import 'package:high_school/domain/entities/class_entity.dart';

/// One item from GET /classes/student/my.
/// Supports: _id, className, subject, gradeLevel, teacher (id), teacherName, students (array), totalStudents, schedule (array), status.
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
    this.className = '',
    this.scheduleDisplay = '',
  });

  final String classId;
  final String subject;
  final String gradeLevel;
  final String teacherId;
  final String teacherName;
  final int studentsCount;
  final int maxStudents;
  final String status;
  /// Display name from API (e.g. "English - 5th"); empty when not provided.
  final String className;
  /// Formatted schedule string (e.g. "Sat 9:00 AM - 10:00 AM").
  final String scheduleDisplay;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory StudentClassItem.fromJson(Map<String, dynamic> json) {
    final classId = json['classId']?.toString() ?? json['_id']?.toString() ?? '';
    final subject = json['subject']?.toString() ?? '';
    final gradeLevel = json['gradeLevel']?.toString() ?? '';
    String teacherId = '';
    String teacherName = '';
    final teacher = json['teacher'];
    if (teacher is Map<String, dynamic>) {
      teacherId = teacher['id']?.toString() ?? teacher['_id']?.toString() ?? '';
      teacherName = teacher['name']?.toString() ?? '';
    } else if (teacher != null) {
      teacherId = teacher.toString();
    }
    teacherName = teacherName.isNotEmpty ? teacherName : (json['teacherName']?.toString() ?? '');
    int studentsCount = _toInt(json['totalStudents']);
    if (studentsCount == 0 && json['students'] != null && json['students'] is List) {
      studentsCount = (json['students'] as List).length;
    }
    final className = json['className']?.toString() ?? '';
    final scheduleDisplay = _formatSchedule(json['schedule']);
    return StudentClassItem(
      classId: classId,
      subject: subject,
      gradeLevel: gradeLevel,
      teacherId: teacherId,
      teacherName: teacherName,
      studentsCount: studentsCount,
      maxStudents: _toInt(json['maxStudents']),
      status: json['status']?.toString() ?? 'active',
      className: className,
      scheduleDisplay: scheduleDisplay,
    );
  }

  static String _formatSchedule(dynamic schedule) {
    if (schedule == null) return '';
    if (schedule is String) return schedule;
    if (schedule is! List || schedule.isEmpty) return '';
    const dayNames = {'sun': 'Sun', 'mon': 'Mon', 'tue': 'Tue', 'wed': 'Wed', 'thu': 'Thu', 'fri': 'Fri', 'sat': 'Sat'};
    final parts = <String>[];
    for (final e in schedule) {
      final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
      final day = (map['day']?.toString() ?? '').toLowerCase();
      final startMin = map['startMin'] is int ? map['startMin'] as int : int.tryParse(map['startMin']?.toString() ?? '') ?? 0;
      final endMin = map['endMin'] is int ? map['endMin'] as int : int.tryParse(map['endMin']?.toString() ?? '') ?? 0;
      final startTime = _minToTimeStr(startMin);
      final endTime = _minToTimeStr(endMin);
      final dayLabel = dayNames[day] ?? day;
      parts.add('$dayLabel $startTime - $endTime');
    }
    return parts.join(', ');
  }

  static String _minToTimeStr(int minFromMidnight) {
    final h = minFromMidnight ~/ 60;
    final m = minFromMidnight % 60;
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final ampm = h >= 12 ? 'PM' : 'AM';
    return '$hour:${m.toString().padLeft(2, '0')} $ampm';
  }

  /// Map to ClassEntity for use with existing classes list UI.
  ClassEntity toClassEntity() {
    final name = className.isNotEmpty ? className : (subject.isNotEmpty ? subject : 'Class');
    return ClassEntity(
      id: classId,
      name: name,
      subject: subject,
      category: 'Core',
      teacher: teacherName,
      teacherId: teacherId,
      students: studentsCount,
      color: '#1F3C88',
      schedule: scheduleDisplay,
      room: '',
      level: gradeLevel,
      schoolYear: '',
    );
  }
}
