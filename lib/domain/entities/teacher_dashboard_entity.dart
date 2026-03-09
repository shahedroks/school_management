/// Response shape for GET /teachers/dashboard.
/// data: { cards, todaysClasses, upcomingLiveSessions, recentSubmissions, myClassesPreview }
class TeacherDashboardEntity {
  const TeacherDashboardEntity({
    required this.cards,
    required this.todaysClasses,
    required this.upcomingLiveSessions,
    required this.recentSubmissions,
    required this.myClassesPreview,
  });

  final TeacherDashboardCards cards;
  final List<TeacherDashboardTodayClass> todaysClasses;
  final List<TeacherDashboardUpcomingSession> upcomingLiveSessions;
  final List<TeacherDashboardRecentSubmission> recentSubmissions;
  final List<TeacherDashboardClassPreview> myClassesPreview;

  factory TeacherDashboardEntity.fromJson(Map<String, dynamic> json) {
    final cardsMap = json['cards'];
    final cards = cardsMap is Map<String, dynamic>
        ? TeacherDashboardCards.fromJson(
            Map<String, dynamic>.from(cardsMap))
        : const TeacherDashboardCards(
            myClasses: 0,
            totalStudents: 0,
            pendingGrading: 0,
            graded: 0,
          );

    final todaysRaw = json['todaysClasses'];
    final todaysClasses = todaysRaw is List
        ? (todaysRaw)
            .map((e) => TeacherDashboardTodayClass.fromJson(
                e is Map<String, dynamic>
                    ? e
                    : Map<String, dynamic>.from(e as Map)))
            .toList()
        : <TeacherDashboardTodayClass>[];

    final upcomingRaw = json['upcomingLiveSessions'];
    final upcomingLiveSessions = upcomingRaw is List
        ? (upcomingRaw)
            .map((e) => TeacherDashboardUpcomingSession.fromJson(
                e is Map<String, dynamic>
                    ? e
                    : Map<String, dynamic>.from(e as Map)))
            .toList()
        : <TeacherDashboardUpcomingSession>[];

    final recentRaw = json['recentSubmissions'];
    final recentSubmissions = recentRaw is List
        ? (recentRaw)
            .map((e) => TeacherDashboardRecentSubmission.fromJson(
                e is Map<String, dynamic>
                    ? e
                    : Map<String, dynamic>.from(e as Map)))
            .toList()
        : <TeacherDashboardRecentSubmission>[];

    final previewRaw = json['myClassesPreview'];
    final myClassesPreview = previewRaw is List
        ? (previewRaw)
            .map((e) => TeacherDashboardClassPreview.fromJson(
                e is Map<String, dynamic>
                    ? e
                    : Map<String, dynamic>.from(e as Map)))
            .toList()
        : <TeacherDashboardClassPreview>[];

    return TeacherDashboardEntity(
      cards: cards,
      todaysClasses: todaysClasses,
      upcomingLiveSessions: upcomingLiveSessions,
      recentSubmissions: recentSubmissions,
      myClassesPreview: myClassesPreview,
    );
  }
}

class TeacherDashboardCards {
  const TeacherDashboardCards({
    required this.myClasses,
    required this.totalStudents,
    required this.pendingGrading,
    required this.graded,
  });

  final int myClasses;
  final int totalStudents;
  final int pendingGrading;
  final int graded;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory TeacherDashboardCards.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardCards(
      myClasses: _toInt(json['myClasses']),
      totalStudents: _toInt(json['totalStudents']),
      pendingGrading: _toInt(json['pendingGrading']),
      graded: _toInt(json['graded']),
    );
  }
}

/// todaysClasses item: classId, subject, gradeLevel, studentsCount, startMin, endMin
class TeacherDashboardTodayClass {
  const TeacherDashboardTodayClass({
    required this.classId,
    required this.subject,
    required this.gradeLevel,
    required this.studentsCount,
    this.startMin,
    this.endMin,
    this.startTime,
    this.endTime,
  });

  final String classId;
  final String subject;
  final String gradeLevel;
  final int studentsCount;
  final int? startMin;
  final int? endMin;
  final String? startTime;
  final String? endTime;

  /// Formatted time string e.g. "09:00 - 10:00" from startMin/endMin (minutes from midnight) or startTime/endTime.
  String get timeLabel {
    if (startTime != null && startTime!.isNotEmpty && endTime != null && endTime!.isNotEmpty) {
      return '$startTime - $endTime';
    }
    if (startMin != null && endMin != null) {
      final s = startMin!;
      final e = endMin!;
      final sh = s ~/ 60;
      final sm = s % 60;
      final eh = e ~/ 60;
      final em = e % 60;
      return '${sh.toString().padLeft(2, '0')}:${sm.toString().padLeft(2, '0')} - ${eh.toString().padLeft(2, '0')}:${em.toString().padLeft(2, '0')}';
    }
    return '';
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory TeacherDashboardTodayClass.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardTodayClass(
      classId: json['classId']?.toString() ?? json['_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      gradeLevel: json['gradeLevel']?.toString() ?? '',
      studentsCount: _toInt(json['studentsCount']),
      startMin: json['startMin'] is int
          ? json['startMin'] as int
          : int.tryParse(json['startMin']?.toString() ?? ''),
      endMin: json['endMin'] is int
          ? json['endMin'] as int
          : int.tryParse(json['endMin']?.toString() ?? ''),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
    );
  }
}

class TeacherDashboardUpcomingSession {
  const TeacherDashboardUpcomingSession({
    required this.id,
    required this.title,
    this.date,
    this.time,
    this.zoomLink,
  });

  final String id;
  final String title;
  final String? date;
  final String? time;
  final String? zoomLink;

  factory TeacherDashboardUpcomingSession.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardUpcomingSession(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      zoomLink: json['zoomLink']?.toString(),
    );
  }
}

/// recentSubmissions item: assignmentId, student: { id, name }, submittedAt, graded
class TeacherDashboardRecentSubmission {
  const TeacherDashboardRecentSubmission({
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    this.submittedAt,
    this.graded = false,
  });

  final String assignmentId;
  final String studentId;
  final String studentName;
  final String? submittedAt;
  final bool graded;

  factory TeacherDashboardRecentSubmission.fromJson(Map<String, dynamic> json) {
    final student = json['student'];
    String studentId = '';
    String studentName = '';
    if (student is Map<String, dynamic>) {
      studentId = student['id']?.toString() ?? student['_id']?.toString() ?? '';
      studentName = student['name']?.toString() ?? '';
    }
    return TeacherDashboardRecentSubmission(
      assignmentId:
          json['assignmentId']?.toString() ?? json['assignment']?.toString() ?? '',
      studentId: studentId,
      studentName: studentName,
      submittedAt: json['submittedAt']?.toString(),
      graded: json['graded'] == true,
    );
  }
}

/// myClassesPreview item: id, subject, gradeLevel, studentsCount
class TeacherDashboardClassPreview {
  const TeacherDashboardClassPreview({
    required this.id,
    required this.subject,
    required this.gradeLevel,
    required this.studentsCount,
  });

  final String id;
  final String subject;
  final String gradeLevel;
  final int studentsCount;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory TeacherDashboardClassPreview.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardClassPreview(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      gradeLevel: json['gradeLevel']?.toString() ?? '',
      studentsCount: _toInt(json['studentsCount']),
    );
  }
}
