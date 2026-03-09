import 'package:high_school/data/datasources/subjects_remote_datasource.dart';
import 'package:high_school/domain/entities/subject_entity.dart';
import 'package:high_school/domain/repositories/subjects_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectsRepositoryImpl implements SubjectsRepository {
  SubjectsRepositoryImpl(SharedPreferences prefs) : _remote = SubjectsRemoteDatasource(prefs);

  final SubjectsRemoteDatasource _remote;

  static final List<SubjectEntity> _defaultSubjects = [
    SubjectEntity(id: 'math', name: 'Mathematics'),
    SubjectEntity(id: 'physics', name: 'Physics'),
    SubjectEntity(id: 'chemistry', name: 'Chemistry'),
    SubjectEntity(id: 'svt', name: 'SVT'),
    SubjectEntity(id: 'french', name: 'French'),
    SubjectEntity(id: 'arabic', name: 'Arabic'),
    SubjectEntity(id: 'english', name: 'English'),
  ];

  @override
  Future<List<SubjectEntity>> getSubjects() async {
    if (_remote.isConfigured) {
      final list = await _remote.getSubjects();
      if (list.isNotEmpty) return list;
    }
    return _defaultSubjects;
  }
}
