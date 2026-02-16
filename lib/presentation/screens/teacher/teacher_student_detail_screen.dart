import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/students_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherStudentDetailScreen extends StatelessWidget {
  const TeacherStudentDetailScreen({super.key, required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<StudentsRepository>().getStudentById(studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final s = snapshot.data;
        if (s == null) return const Text('Student not found');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                title: Text(s.name),
                subtitle: Text(s.email),
                trailing: Text('${lang.t('profile.averageGrade')}: ${s.grade}'),
              ),
            ),
          ],
        );
      },
    );
  }
}
