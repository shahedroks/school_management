import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/providers/subscription_provider.dart';

class ClassesListScreen extends StatelessWidget {
  const ClassesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final auth = context.watch<AuthProvider>();
    final subscription = context.watch<SubscriptionProvider>();

    return FutureBuilder(
      future: Future.wait([
        context.read<ClassesRepository>().getClasses(),
        auth.user != null ? subscription.load(auth.user!.id) : Future.value(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final classes = snapshot.data![0] as List<ClassEntity>;
        final enrolledIds = subscription.subscription?.enrolledClassIds ?? [];
        final enrolledClasses = enrolledIds.isEmpty
            ? <ClassEntity>[]
            : classes.where((c) => enrolledIds.contains(c.id)).toList();

        // Group by subject (match React)
        final grouped = <String, List<ClassEntity>>{};
        for (final c in enrolledClasses) {
          grouped.putIfAbsent(c.subject, () => []).add(c);
        }

        final hasSubscription = subscription.subscription != null;
        final isEmpty = !hasSubscription || enrolledClasses.isEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header banner – dark blue, notably rounded corners, subtle bottom shadow
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
                    lang.t('classes.myClasses'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.t('classes.enrolledClasses'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (isEmpty)
              _EmptyState(lang: lang)
            else
              ...grouped.entries.map((e) => _SubjectCard(
                    subject: e.key,
                    classes: e.value,
                    lang: lang,
                  )),
            const SizedBox(height: 24),
          ],
          ),
        );
      },
    );
  }
}

// Empty state colors to match design: light yellow border/circle, bright yellow button
const Color _emptyStateYellow = Color(0xFFFFC107);
const Color _emptyStateYellowLight = Color(0xFFFFF59D);

class _EmptyState extends StatelessWidget {
  final LanguageProvider lang;

  const _EmptyState({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _emptyStateYellowLight, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _emptyStateYellowLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, size: 36, color: _emptyStateYellow),
            ),
            const SizedBox(height: 20),
            Text(
              lang.t('classes.noClassesEnrolled'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              lang.t('classes.subscribeToAccess'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/student/subscription'),
              icon: const Icon(Icons.workspace_premium, size: 20, color: Colors.white),
              label: Text(
                lang.t('classes.viewSubscriptionPlans'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _emptyStateYellow,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject;
  final List<ClassEntity> classes;
  final LanguageProvider lang;

  const _SubjectCard({
    required this.subject,
    required this.classes,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final first = classes.first;
    final allGrades = classes.map((c) => c.level).toSet().toList();
    final totalStudents = classes.fold<int>(0, (sum, c) => sum + c.students);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient header with subject name (match React)
          Container(
            width: double.infinity,
            height: 80,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.85),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(first.teacher, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      '$totalStudents ${lang.t('classes.students')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: allGrades.map((level) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(level, style: const TextStyle(fontSize: 10)),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/student/classes/${first.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(lang.t('classes.viewClass')),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
