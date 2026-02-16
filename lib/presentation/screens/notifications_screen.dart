import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/repositories/notifications_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: context.read<NotificationsRepository>().getNotifications(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final list = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang.t('notifications.notifications'), style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () => context.read<NotificationsRepository>().markAllAsRead(),
                  child: Text(lang.t('notifications.markAllRead')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              Text(lang.t('notifications.noNotifications'))
            else
              ...list.map((n) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(n.from),
                  subtitle: Text(n.message),
                  trailing: n.read ? null : const Icon(Icons.circle, size: 8, color: Colors.blue),
                  onTap: () => context.read<NotificationsRepository>().markAsRead(n.id),
                ),
              )),
          ],
        );
      },
    );
  }
}
