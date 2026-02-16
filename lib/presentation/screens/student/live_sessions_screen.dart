import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class LiveSessionsScreen extends StatelessWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<LiveSessionsRepository>().getLiveSessions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;
        final active = list.where((s) => s.isActive).toList();
        final upcoming = list.where((s) => !s.isActive).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('live.activeSessions'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (active.isEmpty) Text(lang.t('live.noActiveSessions')) else ...active.map((s) => Card(
              child: ListTile(
                title: Text(s.title),
                subtitle: Text('${s.date} ${s.time} · ${s.platform.name}'),
                trailing: ElevatedButton(child: Text(lang.t('live.joinSession')), onPressed: () {}),
              ),
            )),
            const SizedBox(height: 24),
            Text(lang.t('live.upcomingSessions'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (upcoming.isEmpty) Text(lang.t('live.noUpcomingSessions')) else ...upcoming.map((s) => Card(
              child: ListTile(title: Text(s.title), subtitle: Text('${s.date} ${s.time}')),
            )),
          ],
        );
      },
    );
  }
}
