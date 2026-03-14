import '../entities/teacher_dashboard_entity.dart';

abstract class TeacherDashboardRepository {
  /// GET /teachers/dashboard (Auth). Returns null when API not configured or request fails.
  Future<TeacherDashboardEntity?> getDashboard();
}
