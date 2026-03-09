class SubjectEntity {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final String? color;

  const SubjectEntity({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.color,
  });

  factory SubjectEntity.fromJson(Map<String, dynamic> json) {
    return SubjectEntity(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      description: json['description']?.toString(),
      color: json['color']?.toString(),
    );
  }
}
