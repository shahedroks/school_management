enum UserRole { student, teacher }

class UserEntity {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatar;
  final String? grade;
  final String? subject;
  final List<String>? enrolledClassIds;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.grade,
    this.subject,
    this.enrolledClassIds,
  });
}
