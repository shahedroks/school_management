import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class AssignmentsListScreen extends StatelessWidget {
  const AssignmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<AssignmentsRepository>().getAssignments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data! as List<AssignmentEntity>;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 24),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final a = list[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(a.title),
                subtitle: Text('${lang.t('assignments.dueDate')}: ${a.dueDate} · ${a.status.name}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/student/assignments/${a.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
