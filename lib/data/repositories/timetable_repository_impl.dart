import 'package:high_school/core/constants/app_constants.dart';
import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/data/datasources/student_timetable_remote_datasource.dart';
import 'package:high_school/domain/entities/timetable_entity.dart';
import 'package:high_school/domain/repositories/timetable_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  TimetableRepositoryImpl(SharedPreferences prefs)
      : _remote = StudentTimetableRemoteDatasource(prefs);

  final StudentTimetableRemoteDatasource _remote;

  bool get _useApi => AppConstants.apiBaseUrl.isNotEmpty;

  @override
  Future<TimetableResult> getTimetable() async {
    if (_useApi) {
      final result = await _remote.getTimetableResult();
      // Always use API response (even when empty) so UI shows real data, not mock
      return TimetableResult(
        entries: result.entries,
        todayDayCode: result.todayKey,
      );
    }
    return TimetableResult(entries: MockData.timetable, todayDayCode: null);
  }
}

