import '../entities/subject_entity.dart';

abstract class SubjectsRepository {
  /// GET /subjects (Auth). Returns list from API when configured and token available; otherwise empty or fallback list.
  Future<List<SubjectEntity>> getSubjects();
}
