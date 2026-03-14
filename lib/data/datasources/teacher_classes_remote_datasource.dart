import 'dart:convert';
import 'package:high_school/core/constants/app_constants.dart';
import 'package:high_school/core/network/api_response_helper.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Remote datasource for GET /classes/my (Teacher) and GET /classes/:classId (Teacher, Admin).
class TeacherClassesRemoteDatasource {
  TeacherClassesRemoteDatasource(this._prefs)
      : _baseUrl = AppConstants.apiBaseUrl;

  final SharedPreferences _prefs;
  final String _baseUrl;

  String get _apiBase =>
      _baseUrl.endsWith('/') ? '${_baseUrl}api/v1' : '${_baseUrl}/api/v1';

  bool get isConfigured => _baseUrl.isNotEmpty;

  Future<List<ClassEntity>> getMyClasses() async {
    if (!isConfigured) return [];
    final token = _prefs.getString(AppConstants.sessionTokenKey);
    if (token == null || token.isEmpty) return [];

    final uri = Uri.parse('$_apiBase/classes/my');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) return [];
    try {
      return _parseList(response.body);
    } on UnauthorizedApiException {
      return [];
    }
  }

  Future<ClassEntity?> getClassById(String classId) async {
    if (!isConfigured || classId.isEmpty) return null;
    final token = _prefs.getString(AppConstants.sessionTokenKey);
    if (token == null || token.isEmpty) return null;

    final uri = Uri.parse('$_apiBase/classes/$classId');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) return null;
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      ensureAuthorized(decoded);
      return _parseOne(response.body);
    } on UnauthorizedApiException {
      return null;
    }
  }

  List<ClassEntity> _parseList(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>?;
      ensureAuthorized(decoded);
      if (decoded == null) return [];
      final data = decoded['data'];
      if (data is! List) return [];
      return data
          .map((e) => _itemToEntity(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .whereType<ClassEntity>()
          .toList();
    } on UnauthorizedApiException {
      return [];
    } catch (_) {
      return [];
    }
  }

  ClassEntity? _parseOne(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>?;
      if (decoded == null) return null;
      final data = decoded['data'];
      if (data == null) return null;
      final map = data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data as Map);
      return _itemToEntity(map);
    } catch (_) {
      return null;
    }
  }

  static ClassEntity? _itemToEntity(Map<String, dynamic> m) {
    final id = m['_id']?.toString() ?? m['id']?.toString();
    if (id == null || id.isEmpty) return null;
    final subject = m['subject']?.toString() ?? '';
    final gradeLevel = m['gradeLevel']?.toString() ?? '';
    final className = m['className']?.toString();
    final name = (className != null && className.isNotEmpty)
        ? className
        : '${subject.isNotEmpty ? subject : 'Class'}${gradeLevel.isNotEmpty ? ' - $gradeLevel' : ''}';
    int students = 0;
    if (m['totalStudents'] != null) {
      if (m['totalStudents'] is int) {
        students = m['totalStudents'] as int;
      } else {
        students = int.tryParse(m['totalStudents'].toString()) ?? 0;
      }
    }
    if (students == 0 && m['students'] != null) {
      if (m['students'] is List) {
        students = (m['students'] as List).length;
      } else if (m['students'] is int) {
        students = m['students'] as int;
      } else {
        students = int.tryParse(m['students'].toString()) ?? 0;
      }
    }
    final schedule = _scheduleToString(m['schedule']);
    String teacher = '';
    String teacherId = '';
    final t = m['teacher'];
    if (t is Map<String, dynamic>) {
      teacher = t['name']?.toString() ?? '';
      teacherId = t['_id']?.toString() ?? t['id']?.toString() ?? '';
    } else if (t != null) {
      teacherId = t.toString();
    }
    return ClassEntity(
      id: id,
      name: name,
      subject: subject,
      category: '',
      teacher: teacher,
      teacherId: teacherId,
      students: students,
      color: m['color']?.toString() ?? '',
      schedule: schedule,
      room: m['room']?.toString() ?? '',
      level: gradeLevel,
      schoolYear: m['schoolYear']?.toString() ?? '',
    );
  }

  /// Format schedule from API (array of {day, startMin, endMin}) to readable string.
  static String _scheduleToString(dynamic schedule) {
    if (schedule == null) return '';
    if (schedule is String) return schedule;
    if (schedule is! List || schedule.isEmpty) return '';
    const dayNames = {'sun': 'Sun', 'mon': 'Mon', 'tue': 'Tue', 'wed': 'Wed', 'thu': 'Thu', 'fri': 'Fri', 'sat': 'Sat'};
    final parts = <String>[];
    for (final e in schedule) {
      final map = e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map);
      final day = (map['day']?.toString() ?? '').toLowerCase();
      final startMin = map['startMin'] is int ? map['startMin'] as int : int.tryParse(map['startMin']?.toString() ?? '') ?? 0;
      final endMin = map['endMin'] is int ? map['endMin'] as int : int.tryParse(map['endMin']?.toString() ?? '') ?? 0;
      final startTime = _minToTimeStr(startMin);
      final endTime = _minToTimeStr(endMin);
      final dayLabel = dayNames[day] ?? day;
      parts.add('$dayLabel $startTime - $endTime');
    }
    return parts.join(', ');
  }

  static String _minToTimeStr(int minFromMidnight) {
    final h = minFromMidnight ~/ 60;
    final m = minFromMidnight % 60;
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final ampm = h >= 12 ? 'PM' : 'AM';
    return '$hour:${m.toString().padLeft(2, '0')} $ampm';
  }
}
