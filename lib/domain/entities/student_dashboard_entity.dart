/// Response shape for GET /students/dashboard.
/// data: { cards, activeLiveSessions, upcomingAssignments, progressOverview }
class StudentDashboardEntity {
  const StudentDashboardEntity({
    required this.cards,
    required this.activeLiveSessions,
    required this.upcomingAssignments,
    required this.progressOverview,
  });

  final StudentDashboardCards cards;
  final List<StudentDashboardActiveSession> activeLiveSessions;
  final List<StudentDashboardUpcomingAssignment> upcomingAssignments;
  final List<StudentDashboardProgressItem> progressOverview;

  factory StudentDashboardEntity.fromJson(Map<String, dynamic> json) {
    final cardsMap = json['cards'];
    final cards = cardsMap is Map<String, dynamic>
        ? StudentDashboardCards.fromJson(
            Map<String, dynamic>.from(cardsMap))
        : const StudentDashboardCards(
            enrolledClasses: 0,
            pendingAssignments: 0,
            completed: 0,
            liveSessions: 0,
          );

    final sessionsRaw = json['activeLiveSessions'];
    final activeLiveSessions = sessionsRaw is List
        ? (sessionsRaw)
            .map((e) => StudentDashboardActiveSession.fromJson(
                e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
            .toList()
        : <StudentDashboardActiveSession>[];

    final assignmentsRaw = json['upcomingAssignments'];
    final upcomingAssignments = assignmentsRaw is List
        ? (assignmentsRaw)
            .map((e) => StudentDashboardUpcomingAssignment.fromJson(
                e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
            .toList()
        : <StudentDashboardUpcomingAssignment>[];

    final progressRaw = json['progressOverview'];
    final progressOverview = progressRaw is List
        ? (progressRaw)
            .map((e) => StudentDashboardProgressItem.fromJson(
                e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
            .toList()
        : <StudentDashboardProgressItem>[];

    return StudentDashboardEntity(
      cards: cards,
      activeLiveSessions: activeLiveSessions,
      upcomingAssignments: upcomingAssignments,
      progressOverview: progressOverview,
    );
  }
}

class StudentDashboardCards {
  const StudentDashboardCards({
    required this.enrolledClasses,
    required this.pendingAssignments,
    required this.completed,
    required this.liveSessions,
  });

  final int enrolledClasses;
  final int pendingAssignments;
  final int completed;
  final int liveSessions;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory StudentDashboardCards.fromJson(Map<String, dynamic> json) {
    return StudentDashboardCards(
      enrolledClasses: _toInt(json['enrolledClasses']),
      pendingAssignments: _toInt(json['pendingAssignments']),
      completed: _toInt(json['completed']),
      liveSessions: _toInt(json['liveSessions']),
    );
  }
}

class StudentDashboardActiveSession {
  const StudentDashboardActiveSession({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.time,
    required this.status,
    required this.zoomLink,
  });

  final String id;
  final String title;
  final String subject;
  final String date;
  final String time;
  final String status;
  final String zoomLink;

  factory StudentDashboardActiveSession.fromJson(Map<String, dynamic> json) {
    return StudentDashboardActiveSession(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      zoomLink: json['zoomLink']?.toString() ?? '',
    );
  }
}

class StudentDashboardUpcomingAssignment {
  const StudentDashboardUpcomingAssignment({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.points,
    required this.myStatus,
  });

  final String id;
  final String title;
  final String dueAt;
  final int points;
  final String myStatus;

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory StudentDashboardUpcomingAssignment.fromJson(Map<String, dynamic> json) {
    return StudentDashboardUpcomingAssignment(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      dueAt: json['dueAt']?.toString() ?? json['dueDate']?.toString() ?? '',
      points: _toInt(json['points']),
      myStatus: json['myStatus']?.toString() ?? 'pending',
    );
  }
}

class StudentDashboardProgressItem {
  const StudentDashboardProgressItem({
    required this.subject,
    required this.percentage,
  });

  final String subject;
  final double percentage;

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory StudentDashboardProgressItem.fromJson(Map<String, dynamic> json) {
    return StudentDashboardProgressItem(
      subject: json['subject']?.toString() ?? '',
      percentage: _toDouble(json['percentage']),
    );
  }
}
