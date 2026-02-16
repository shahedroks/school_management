import '../entities/live_session_entity.dart';

abstract class LiveSessionsRepository {
  Future<List<LiveSessionEntity>> getLiveSessions();
}
