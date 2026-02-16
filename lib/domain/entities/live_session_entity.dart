enum LiveSessionPlatform { zoom, meet }

class LiveSessionEntity {
  final String id;
  final String classId;
  final String title;
  final String date;
  final String time;
  final LiveSessionPlatform platform;
  final String link;
  final bool isActive;

  const LiveSessionEntity({
    required this.id,
    required this.classId,
    required this.title,
    required this.date,
    required this.time,
    required this.platform,
    required this.link,
    required this.isActive,
  });
}
