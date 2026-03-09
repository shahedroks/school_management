import 'dart:convert';
import 'package:high_school/core/constants/app_constants.dart';
import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/domain/entities/subscription_entity.dart';
import 'package:high_school/domain/repositories/subscription_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  SubscriptionRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  List<StudentSubscriptionEntity> _subs = List.from(MockData.studentSubscriptions);

  void _load() {
    final raw = _prefs.getString(AppConstants.studentSubscriptionsKey);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        _subs = list.map((m) => StudentSubscriptionEntity(
          studentId: m['studentId'] as String,
          planId: m['planId'] as String,
          enrolledClassIds: (m['enrolledClassIds'] as List).cast<String>(),
          startDate: m['startDate'] as String,
          endDate: m['endDate'] as String,
          status: m['status'] as String,
        )).toList();
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final list = _subs.map((s) => {
      'studentId': s.studentId,
      'planId': s.planId,
      'enrolledClassIds': s.enrolledClassIds,
      'startDate': s.startDate,
      'endDate': s.endDate,
      'status': s.status,
    }).toList();
    await _prefs.setString(AppConstants.studentSubscriptionsKey, jsonEncode(list));
  }

  @override
  Future<StudentSubscriptionEntity?> getSubscriptionForStudent(String studentId) async {
    _load();
    try {
      return _subs.firstWhere((s) => s.studentId == studentId && s.status == 'active');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> subscribe(String studentId, String planId, List<String> classIds) async {
    _load();
    _subs.removeWhere((s) => s.studentId == studentId && s.status == 'active');
    final now = DateTime.now();
    final end = now.add(const Duration(days: 30));
    _subs.add(StudentSubscriptionEntity(
      studentId: studentId,
      planId: planId,
      enrolledClassIds: classIds,
      startDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      endDate: '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}',
      status: 'active',
    ));
    await _save();
  }

  @override
  Future<void> cancelSubscription(String studentId) async {
    _load();
    _subs = _subs.map((s) => s.studentId == studentId && s.status == 'active'
        ? StudentSubscriptionEntity(studentId: s.studentId, planId: s.planId, enrolledClassIds: s.enrolledClassIds, startDate: s.startDate, endDate: s.endDate, status: 'cancelled')
        : s).toList();
    await _save();
  }
}
