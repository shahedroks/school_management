import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/domain/entities/timetable_entity.dart';
import 'package:high_school/domain/repositories/timetable_repository.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  @override
  Future<List<TimetableEntryEntity>> getTimetable() async => MockData.timetable;
}
