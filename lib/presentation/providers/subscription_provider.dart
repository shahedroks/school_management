import 'package:flutter/foundation.dart';
import 'package:high_school/domain/entities/subscription_entity.dart';
import 'package:high_school/domain/repositories/subscription_repository.dart';

class SubscriptionProvider with ChangeNotifier {
  SubscriptionProvider(this._repo);

  final SubscriptionRepository _repo;

  StudentSubscriptionEntity? _subscription;
  List<SubscriptionPlanEntity> _plans = [];

  StudentSubscriptionEntity? get subscription => _subscription;
  List<SubscriptionPlanEntity> get plans => _plans;

  Future<void> load(String? studentId) async {
    if (studentId == null) {
      _subscription = null;
      _plans = await _repo.getPlans();
      notifyListeners();
      return;
    }
    _subscription = await _repo.getSubscriptionForStudent(studentId);
    _plans = await _repo.getPlans();
    notifyListeners();
  }

  Future<void> subscribe(String studentId, String planId, List<String> classIds) async {
    await _repo.subscribe(studentId, planId, classIds);
    await load(studentId);
  }

  Future<void> cancelSubscription(String studentId) async {
    await _repo.cancelSubscription(studentId);
    await load(studentId);
  }
}
