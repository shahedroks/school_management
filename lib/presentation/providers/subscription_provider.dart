import 'package:flutter/foundation.dart';
import 'package:high_school/domain/entities/subscription_entity.dart';
import 'package:high_school/domain/repositories/subscription_repository.dart';

class SubscriptionProvider with ChangeNotifier {
  SubscriptionProvider(this._repo);

  final SubscriptionRepository _repo;

  StudentSubscriptionEntity? _subscription;

  StudentSubscriptionEntity? get subscription => _subscription;

  Future<void> load(String? studentId) async {
    if (studentId == null) {
      _subscription = null;
      notifyListeners();
      return;
    }
    _subscription = await _repo.getSubscriptionForStudent(studentId);
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
