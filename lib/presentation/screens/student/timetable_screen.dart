import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/timetable_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<TimetableRepository>().getTimetable(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('timetable.weeklySchedule'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...list.map((e) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(e.className),
                subtitle: Text('${e.day} ${e.time} · ${e.room}'),
                trailing: Text(e.teacher, style: Theme.of(context).textTheme.bodySmall),
              ),
            )),
          ],
        );
      },
    );
  }
}
