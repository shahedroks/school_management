import 'dart:convert';
import 'package:high_school/core/constants/app_constants.dart';
import 'package:high_school/domain/entities/user_entity.dart';
import 'package:high_school/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  UserEntity? _currentUser;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<void> restoreSession() async {
    final id = _prefs.getString(AppConstants.sessionUserIdKey);
    if (id == null) return;
    if (id == _demoStudent.id) {
      _currentUser = _demoStudent;
      return;
    }
    if (id == _demoTeacher.id) {
      _currentUser = _demoTeacher;
      return;
    }
    final raw = _prefs.getString(AppConstants.registeredUsersKey);
    final list = raw != null ? (jsonDecode(raw) as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
    for (final u in list) {
      if (u['id'] == id) {
        if (u['role'] == 'teacher' && u['status'] == 'pending') return;
        _currentUser = UserEntity(
          id: u['id'] as String,
          name: u['name'] as String,
          email: u['email'] as String? ?? '${u['phone']}@school.mr',
          role: u['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
          grade: u['grade'] as String?,
          subject: u['subject'] as String?,
        );
        return;
      }
    }
  }

  static const _demoStudent = UserEntity(
    id: 'demo_student',
    name: 'Fatima Al-Hassan',
    email: 'fatima@school.mr',
    role: UserRole.student,
    grade: '10th Grade',
  );
  static const _demoTeacher = UserEntity(
    id: 'demo_teacher',
    name: 'Mohammed El-Amin',
    email: 'mohammed@school.mr',
    role: UserRole.teacher,
    subject: 'Mathematics',
  );

  @override
  Future<bool> login(String emailOrPhone, String password) async {
    if ((emailOrPhone == AppConstants.demoStudentPhone && password == AppConstants.demoStudentPin)) {
      _currentUser = _demoStudent;
      await _prefs.setString(AppConstants.sessionUserIdKey, _demoStudent.id);
      return true;
    }
    if ((emailOrPhone == AppConstants.demoTeacherPhone && password == AppConstants.demoTeacherPin)) {
      _currentUser = _demoTeacher;
      await _prefs.setString(AppConstants.sessionUserIdKey, _demoTeacher.id);
      return true;
    }
    final raw = _prefs.getString(AppConstants.registeredUsersKey);
    final list = raw != null ? (jsonDecode(raw) as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
    for (final u in list) {
      if ((u['phone'] == emailOrPhone || u['email'] == emailOrPhone) && u['password'] == password) {
        if (u['role'] == 'teacher' && u['status'] == 'pending') return false;
        _currentUser = UserEntity(
          id: u['id'] as String,
          name: u['name'] as String,
          email: u['email'] as String? ?? '${u['phone']}@school.mr',
          role: u['role'] == 'teacher' ? UserRole.teacher : UserRole.student,
          grade: u['grade'] as String?,
          subject: u['subject'] as String?,
        );
        await _prefs.setString(AppConstants.sessionUserIdKey, _currentUser!.id);
        return true;
      }
    }
    return false;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove(AppConstants.sessionUserIdKey);
  }

  @override
  Future<bool> register({
    required String name,
    required String phone,
    required String pin,
    required String role,
    String? grade,
    String? subject,
  }) async {
    final raw = _prefs.getString(AppConstants.registeredUsersKey);
    final list = raw != null ? (jsonDecode(raw) as List).cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
    if (list.any((u) => u['phone'] == phone)) return false;
    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'email': '$phone@school.mr',
      'phone': phone,
      'password': pin,
      'role': role,
      'grade': grade,
      'subject': subject,
      'status': role == 'teacher' ? 'pending' : 'approved',
      'createdAt': DateTime.now().toIso8601String(),
    };
    list.add(newUser);
    await _prefs.setString(AppConstants.registeredUsersKey, jsonEncode(list));
    if (role == 'student') {
      _currentUser = UserEntity(
        id: newUser['id'] as String,
        name: name,
        email: newUser['email'] as String,
        role: UserRole.student,
        grade: grade,
      );
    }
    return true;
  }
}
