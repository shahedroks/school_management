import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/lessons_repository.dart';
import 'package:high_school/domain/entities/lesson_entity.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class LessonDetailsScreen extends StatelessWidget {
  const LessonDetailsScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<LessonsRepository>().getLessonById(lessonId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final lesson = snapshot.data;
        if (lesson == null) return const Text('Lesson not found');

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              if (lesson.module != null) Text(lesson.module!, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 16),
              Text(lesson.description, style: Theme.of(context).textTheme.bodyMedium),
              if (lesson.duration != null) Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('${lang.t('lessons.duration')}: ${lesson.duration}'),
              ),
              const SizedBox(height: 24),
              if (lesson.type == LessonType.video)
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(lang.t('lessons.watchVideo')),
                  onPressed: () {},
                )
              else if (lesson.type == LessonType.text)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(lesson.content),
                  ),
                )
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: Text(lang.t('lessons.downloadPDF')),
                  onPressed: () {},
                ),
            ],
          ),
        );
      },
    );
  }
}
