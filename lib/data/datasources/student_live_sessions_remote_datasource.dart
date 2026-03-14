import 'dart:convert';
import 'package:high_school/core/constants/app_constants.dart';
import 'package:high_school/core/network/api_response_helper.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// GET /sessions/student?status=approved (or status=ongoing) — student live sessions.
class StudentLiveSessionsRemoteDatasource {
  StudentLiveSessionsRemoteDatasource(this._prefs)
      : _baseUrl = AppConstants.apiBaseUrl;

  final SharedPreferences _prefs;
  final String _baseUrl;

  String get _apiBase =>
      _baseUrl.endsWith('/') ? '${_baseUrl}api/v1' : '$_baseUrl/api/v1';

  bool get isConfigured => _baseUrl.isNotEmpty;

  /// [status] e.g. 'approved' or 'ongoing'. Omit for all.
  Future<List<LiveSessionEntity>> getSessions({String? status}) async {
    if (!isConfigured) return [];
    final token = _prefs.getString(AppConstants.sessionTokenKey);
    if (token == null || token.isEmpty) return [];
    var path = '$_apiBase/sessions/student';
    if (status != null && status.isNotEmpty) {
      path += '?status=$status';
    }
    final uri = Uri.parse(path);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) return [];
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>?;
      ensureAuthorized(decoded);
      return _parseList(response.body);
    } on UnauthorizedApiException {
      return [];
    } catch (_) {
      return [];
    }
  }

  List<LiveSessionEntity> _parseList(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>?;
      if (decoded == null) return [];
      final data = decoded['data'];
      if (data is! List) return [];
      return data
          .map((e) => _itemToEntity(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .whereType<LiveSessionEntity>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  static LiveSessionEntity? _itemToEntity(Map<String, dynamic> m) {
    final id = m['_id']?.toString() ?? m['id']?.toString();
    if (id == null || id.isEmpty) return null;
    final title = m['title']?.toString() ?? '';
    final dateRaw = m['date']?.toString();
    String dateStr = '';
    if (dateRaw != null && dateRaw.isNotEmpty) {
      try {
        final d = DateTime.parse(dateRaw);
        dateStr = '${d.month}/${d.day}/${d.year}';
      } catch (_) {
        dateStr = dateRaw;
      }
    }
    final time = m['time']?.toString() ?? '';
    final zoomLink = m['zoomLink']?.toString() ?? m['meetingLink']?.toString() ?? '';
    final isZoom = zoomLink.toLowerCase().contains('zoom');
    final classId = m['classId']?.toString() ?? '';
    final status = m['status']?.toString() ?? '';
    final isActive = status == 'ongoing' || status == 'active';
    final className = m['className']?.toString();
    return LiveSessionEntity(
      id: id,
      classId: classId,
      title: title,
      date: dateStr,
      time: time,
      platform: isZoom ? LiveSessionPlatform.zoom : LiveSessionPlatform.meet,
      link: zoomLink,
      isActive: isActive,
      className: (className != null && className.isNotEmpty) ? className : null,
    );
  }
}
