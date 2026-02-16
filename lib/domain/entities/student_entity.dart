class StudentEntity {
  final String id;
  final String name;
  final String email;
  final int grade;
  final String? avatar;

  const StudentEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.grade,
    this.avatar,
  });
}
