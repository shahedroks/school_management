import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherLiveSessionsScreen extends StatelessWidget {
  const TeacherLiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<LiveSessionsRepository>().getLiveSessions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('live.liveSessions'), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...list.map((s) => Card(
              child: ListTile(
                title: Text(s.title),
                subtitle: Text('${s.date} ${s.time}'),
                trailing: ElevatedButton(child: Text(lang.t('live.startSession')), onPressed: () {}),
              ),
            )),
          ],
        );
      },
    );
  }
}
