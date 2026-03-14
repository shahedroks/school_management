import '../entities/timetable_entity.dart';

abstract class TimetableRepository {
  Future<TimetableResult> getTimetable();
}
