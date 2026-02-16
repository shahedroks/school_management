import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class AssignmentDetailsScreen extends StatelessWidget {
  const AssignmentDetailsScreen({super.key, required this.assignmentId});

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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${lang.t('assignments.dueDate')}: ${a.dueDate}'),
            Text('${lang.t('assignments.points')}: ${a.points}'),
            const SizedBox(height: 16),
            Text(lang.t('assignments.instructions'), style: Theme.of(context).textTheme.titleSmall),
            Text(a.description),
            if (a.status == AssignmentStatus.graded && a.feedback != null) ...[
              const SizedBox(height: 16),
              Text('${lang.t('assignments.score')}: ${a.grade}/${a.points}'),
              Text('${lang.t('assignments.feedback')}: ${a.feedback}'),
            ],
            if (a.status == AssignmentStatus.pending) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: Text(lang.t('assignments.submitAssignment')),
              ),
            ],
          ],
        );
      },
    );
  }
}
