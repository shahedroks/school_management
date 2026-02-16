import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/lessons_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherClassDetailsScreen extends StatelessWidget {
  const TeacherClassDetailsScreen({super.key, required this.classId});

  final String classId;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: Future.wait([
        context.read<ClassesRepository>().getClassById(classId),
        context.read<LessonsRepository>().getLessons(classId: classId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final cls = snapshot.data![0] as ClassEntity?;
        final lessons = snapshot.data![1] as List;
        if (cls == null) return const Text('Class not found');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls.name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('${lang.t('classes.students')}: ${cls.students}'),
                    Text('${lang.t('classes.room')}: ${cls.room}'),
                    Text('${lang.t('classes.schedule')}: ${cls.schedule}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(lang.t('lessons.lessons'), style: Theme.of(context).textTheme.titleMedium),
            ...lessons.map((l) => ListTile(
              title: Text(l.title),
              subtitle: Text(l.date),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            )),
          ],
        );
      },
    );
  }
}
