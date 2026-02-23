import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/timetable_entity.dart';
import 'package:high_school/domain/repositories/timetable_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  static const List<String> _dayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
  ];

  static const List<String> _englishDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder<List<TimetableEntryEntity>>(
      future: context.read<TimetableRepository>().getTimetable(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allEntries = snapshot.data!;
        final now = DateTime.now();
        final todayEnglish = _englishDays[now.weekday - 1]; // 1=Monday, 7=Sunday

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner – match React
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang.t('timetable.mySchedule'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.t('timetable.weeklySchedule'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Day cards (Monday .. Friday)
            ...List.generate(_dayKeys.length, (i) {
              final dayKey = _dayKeys[i];
              final englishDay = _englishDays[i];
              final dayLabel = lang.t('timetable.$dayKey');
              final entries = allEntries
                  .where((e) => e.day == englishDay)
                  .toList()
                ..sort((a, b) => a.time.compareTo(b.time));
              final isToday = englishDay == todayEnglish;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isToday
                        ? AppTheme.secondary
                        : AppTheme.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                elevation: isToday ? 2 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day header – bg primary/5
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.06),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dayLabel,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (isToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                lang.t('timetable.today'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: entries.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  lang.t('timetable.noClassesToday'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: entries.map((entry) => _TimetableEntryTile(entry: entry)).toList(),
                            ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _TimetableEntryTile extends StatelessWidget {
  final TimetableEntryEntity entry;

  const _TimetableEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/student/classes/${entry.classId}'),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.className,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.time,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 12, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.teacher,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
