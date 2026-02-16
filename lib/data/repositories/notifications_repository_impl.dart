import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/domain/entities/notification_entity.dart';
import 'package:high_school/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final List<NotificationEntity> _notifications = List.from(MockData.notifications);

  @override
  Future<List<NotificationEntity>> getNotifications() async => _notifications;

  @override
  Future<void> markAsRead(String id) async {
    final i = _notifications.indexWhere((n) => n.id == id);
    if (i >= 0) {
      _notifications[i] = NotificationEntity(
        id: _notifications[i].id,
        type: _notifications[i].type,
        from: _notifications[i].from,
        message: _notifications[i].message,
        timestamp: _notifications[i].timestamp,
        read: true,
      );
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      _notifications[i] = NotificationEntity(id: n.id, type: n.type, from: n.from, message: n.message, timestamp: n.timestamp, read: true);
    }
  }
}
