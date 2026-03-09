import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';

class LiveSessionsRepositoryImpl implements LiveSessionsRepository {
  @override
  Future<List<LiveSessionEntity>> getLiveSessions() async => MockData.liveSessions;

  @override
  Future<void> addLiveSession(LiveSessionEntity session) async {
    MockData.liveSessions.add(session);
  }
}
