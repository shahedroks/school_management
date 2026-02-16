import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherAssignmentDetailsScreen extends StatelessWidget {
  const TeacherAssignmentDetailsScreen({super.key, required this.assignmentId});

  final String assignmentId;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<AssignmentsRepository>().getAssignmentById(assignmentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final a = snapshot.data;
        if (a == null) return const Text('Assignment not found');

        final submissions = a.submissions ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(a.description),
            const SizedBox(height: 16),
            Text('${lang.t('assignments.dueDate')}: ${a.dueDate} · ${lang.t('assignments.totalPoints')}: ${a.points}'),
            const SizedBox(height: 24),
            Text(lang.t('recent.recentSubmissions'), style: Theme.of(context).textTheme.titleMedium),
            ...submissions.map((s) => ListTile(
              title: Text(s.studentName),
              subtitle: Text('${lang.t('assignments.submittedOn')}: ${s.submittedAt}'),
              trailing: s.grade != null ? Text('${s.grade}') : ElevatedButton(
                onPressed: () {},
                child: Text(lang.t('assignments.enterGrade')),
              ),
            )),
          ],
        );
      },
    );
  }
}
