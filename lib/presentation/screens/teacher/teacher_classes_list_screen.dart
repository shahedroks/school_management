import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherClassesListScreen extends StatelessWidget {
  const TeacherClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<ClassesRepository>().getClassesByTeacher(auth.user?.id == 'demo_teacher' ? 'teacher1' : (auth.user?.id ?? 'teacher1')),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data! as List<ClassEntity>;

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
                subtitle: Text('${c.students} ${lang.t('classes.students')} · ${c.schedule}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/teacher/classes/${c.id}'),
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
