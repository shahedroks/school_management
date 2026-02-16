import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/students_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherStudentsListScreen extends StatelessWidget {
  const TeacherStudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<StudentsRepository>().getStudents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('students.allStudents'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...list.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(s.name),
                subtitle: Text(s.email),
                trailing: Text('Grade: ${s.grade}'),
                onTap: () => context.go('/teacher/students/${s.id}'),
              ),
            )),
          ],
        );
      },
    );
  }
}
