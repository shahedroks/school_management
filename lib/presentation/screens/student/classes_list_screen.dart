import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/providers/subscription_provider.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';

class ClassesListScreen extends StatelessWidget {
  const ClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final subscription = context.watch<SubscriptionProvider>();

    return FutureBuilder(
      future: Future.wait([
        context.read<ClassesRepository>().getClasses(),
        auth.user != null ? subscription.load(auth.user!.id) : Future.value(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final classes = snapshot.data![0] as List<ClassEntity>;
        final enrolledIds = subscription.subscription?.enrolledClassIds ?? [];
        final list = enrolledIds.isEmpty ? classes : classes.where((c) => enrolledIds.contains(c.id)).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final c = list[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: _colorFromHex(c.color), child: Text(c.name[0], style: const TextStyle(color: Colors.white))),
                title: Text(c.name),
                subtitle: Text('${c.teacher} · ${c.schedule}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/student/classes/${c.id}'),
              ),
            );
          },
        );
      },
    );
  }
}

Color _colorFromHex(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}
