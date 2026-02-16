import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherAnalyticsScreen extends StatelessWidget {
  const TeacherAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lang.t('analytics.analytics'), style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.t('analytics.overview'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(lang.t('analytics.classPerformance')),
                Text(lang.t('analytics.attendanceRate')),
                Text(lang.t('analytics.averageScore')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
