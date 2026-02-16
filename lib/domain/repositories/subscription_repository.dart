import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<StudentSubscriptionEntity?> getSubscriptionForStudent(String studentId);
  Future<List<SubscriptionPlanEntity>> getPlans();
  Future<void> subscribe(String studentId, String planId, List<String> classIds);
  Future<void> cancelSubscription(String studentId);
}
