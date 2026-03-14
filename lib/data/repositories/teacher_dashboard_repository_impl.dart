import 'package:high_school/data/datasources/teacher_dashboard_remote_datasource.dart';
import 'package:high_school/domain/entities/teacher_dashboard_entity.dart';
import 'package:high_school/domain/repositories/teacher_dashboard_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherDashboardRepositoryImpl implements TeacherDashboardRepository {
  TeacherDashboardRepositoryImpl(SharedPreferences prefs)
      : _remote = TeacherDashboardRemoteDatasource(prefs);

  final TeacherDashboardRemoteDatasource _remote;

  @override
  Future<TeacherDashboardEntity?> getDashboard() => _remote.getDashboard();
}
