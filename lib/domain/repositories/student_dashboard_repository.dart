import '../entities/student_dashboard_entity.dart';

abstract class StudentDashboardRepository {
  /// GET /students/dashboard (Auth). Returns null when API not configured or request fails.
  Future<StudentDashboardEntity?> getDashboard();
}
