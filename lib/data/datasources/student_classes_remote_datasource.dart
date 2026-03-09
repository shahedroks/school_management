import 'dart:convert';
import 'package:high_school/core/constants/app_constants.dart';
import 'package:high_school/domain/entities/student_class_item.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// GET /students/student/classes or GET /classes/student/my (Auth)
class StudentClassesRemoteDatasource {
  StudentClassesRemoteDatasource(this._prefs) : _baseUrl = AppConstants.apiBaseUrl;

  final SharedPreferences _prefs;
  final String _baseUrl;

  String get _apiBase =>
      _baseUrl.endsWith('/') ? '${_baseUrl}api/v1' : '${_baseUrl}/api/v1';

  bool get isConfigured => _baseUrl.isNotEmpty;

  /// GET /students/student/classes — data: array of student class items
  Future<List<StudentClassItem>> getStudentClasses() async {
    if (!isConfigured) return [];
    final token = _prefs.getString(AppConstants.sessionTokenKey);
    if (token == null || token.isEmpty) return [];
    final uri = Uri.parse('$_apiBase/students/student/classes');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) return [];
    return _parseList(response.body);
  }

  List<StudentClassItem> _parseList(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>?;
      if (decoded == null) return [];
      final data = decoded['data'];
      if (data == null) return [];
      final list = data is List ? data : (data is Map ? [data] : null);
      if (list == null) return [];
      return list
          .map((e) => StudentClassItem.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .where((s) => s.classId.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}
