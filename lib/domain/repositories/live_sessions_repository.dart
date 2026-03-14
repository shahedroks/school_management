import '../entities/live_session_entity.dart';

abstract class LiveSessionsRepository {
  Future<List<LiveSessionEntity>> getLiveSessions();
  /// Student: GET /sessions/student?status=approved (or status=ongoing). Returns API data when configured.
  Future<List<LiveSessionEntity>> getStudentLiveSessions({String? status});
  Future<void> addLiveSession(LiveSessionEntity session);
}
