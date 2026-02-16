class SubscriptionPlanEntity {
  final String id;
  final String name;
  final double price;
  final String duration;
  final List<String> features;
  final List<String> classIds;
  final int maxClasses;
  final bool popular;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    required this.classIds,
    required this.maxClasses,
    this.popular = false,
  });
}

class StudentSubscriptionEntity {
  final String studentId;
  final String planId;
  final List<String> enrolledClassIds;
  final String startDate;
  final String endDate;
  final String status; // active, expired, none, cancelled

  const StudentSubscriptionEntity({
    required this.studentId,
    required this.planId,
    required this.enrolledClassIds,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}
