import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/entities/subscription_entity.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/providers/subscription_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final subscription = context.watch<SubscriptionProvider>();

    return FutureBuilder(
      future: auth.user != null ? subscription.load(auth.user!.id) : Future.value(),
      builder: (context, _) {
        final sub = subscription.subscription;
        final plans = subscription.plans;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sub != null)
              Card(
                child: ListTile(
                  title: Text('Current plan'),
                  subtitle: Text('Active until ${sub.endDate}'),
                ),
              ),
            const SizedBox(height: 16),
            Text('Plans', style: Theme.of(context).textTheme.titleMedium),
            ...plans.map((p) => Card(
              child: ListTile(
                title: Text(p.name),
                subtitle: Text('\$${p.price}/${p.duration}'),
                trailing: p.popular ? const Chip(label: Text('Popular')) : null,
              ),
            )),
          ],
        );
      },
    );
  }
}
