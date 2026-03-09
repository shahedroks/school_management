import 'package:high_school/data/datasources/student_dashboard_remote_datasource.dart';
import 'package:high_school/domain/entities/student_dashboard_entity.dart';
import 'package:high_school/domain/repositories/student_dashboard_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentDashboardRepositoryImpl implements StudentDashboardRepository {
  StudentDashboardRepositoryImpl(SharedPreferences prefs)
      : _remote = StudentDashboardRemoteDatasource(prefs);

  final StudentDashboardRemoteDatasource _remote;

  @override
  Future<StudentDashboardEntity?> getDashboard() => _remote.getDashboard();
}
