class TimetableEntryEntity {
  final String id;
  final String day;
  final String time;
  final String classId;
  final String className;
  final String teacher;
  final String room;

  const TimetableEntryEntity({
    required this.id,
    required this.day,
    required this.time,
    required this.classId,
    required this.className,
    required this.teacher,
    required this.room,
  });
}
