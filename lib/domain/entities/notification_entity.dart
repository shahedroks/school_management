enum NotificationType { student, admin, system }

class NotificationEntity {
  final String id;
  final NotificationType type;
  final String from;
  final String message;
  final String timestamp;
  final bool read;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.from,
    required this.message,
    required this.timestamp,
    required this.read,
  });
}
