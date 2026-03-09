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

/// Result of getTimetable(): entries plus optional API "today" day code (e.g. "mon").
class TimetableResult {
  const TimetableResult({
    required this.entries,
    this.todayDayCode,
  });

  final List<TimetableEntryEntity> entries;
  /// From API data.today; null when using mock.
  final String? todayDayCode;
}
