import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/data/datasources/student_live_sessions_remote_datasource.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveSessionsRepositoryImpl implements LiveSessionsRepository {
  LiveSessionsRepositoryImpl(SharedPreferences prefs)
      : _studentSessions = StudentLiveSessionsRemoteDatasource(prefs);

  final StudentLiveSessionsRemoteDatasource _studentSessions;

  @override
  Future<List<LiveSessionEntity>> getLiveSessions() async =>
      MockData.liveSessions;

  @override
  Future<List<LiveSessionEntity>> getStudentLiveSessions({String? status}) async {
    if (_studentSessions.isConfigured) {
      return _studentSessions.getSessions(status: status);
    }
    return getLiveSessions();
  }

  @override
  Future<void> addLiveSession(LiveSessionEntity session) async {
    MockData.liveSessions.add(session);
  }
}
