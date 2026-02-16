import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/providers/subscription_provider.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final subscription = context.watch<SubscriptionProvider>();

    return FutureBuilder(
      future: Future.wait([
        context.read<ClassesRepository>().getClasses(),
        context.read<AssignmentsRepository>().getAssignments(),
        context.read<LiveSessionsRepository>().getLiveSessions(),
        auth.user != null ? subscription.load(auth.user!.id) : Future.value(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final classes = snapshot.data![0] as List;
        final assignments = snapshot.data![1] as List<AssignmentEntity>;
        final sessions = snapshot.data![2] as List;
        final enrolledIds = subscription.subscription?.enrolledClassIds ?? [];
        final enrolledClasses = classes.where((c) => enrolledIds.contains(c.id)).toList();
        final pending = assignments.where((a) => a.status == AssignmentStatus.pending).length;
        final graded = assignments.where((a) => a.status == AssignmentStatus.graded).length;
        final activeSessions = sessions.where((s) => s.isActive).toList();

        final firstName = auth.user?.name.split(' ').first ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${lang.t('dashboard.welcomeBack')}, $firstName!', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(lang.t('dashboard.overview'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _StatCard(title: lang.t('classes.enrolledClasses'), value: '${enrolledClasses.length}', icon: Icons.menu_book),
                _StatCard(title: lang.t('assignments.pending'), value: '$pending', icon: Icons.assignment),
                _StatCard(title: lang.t('lessons.completed'), value: '$graded', icon: Icons.check_circle),
                _StatCard(title: lang.t('live.liveSessions'), value: '${activeSessions.length}', icon: Icons.video_call),
              ],
            ),
            if (activeSessions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(lang.t('live.activeSessions'), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...activeSessions.take(3).map((s) => ListTile(
                title: Text(s.title),
                subtitle: Text('${s.date} ${s.time}'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: Text(lang.t('live.joinSession')),
                ),
              )),
            ],
            const SizedBox(height: 16),
            Text(lang.t('assignments.upcomingAssignments'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...assignments.where((a) => a.status == AssignmentStatus.pending).take(3).map((a) => ListTile(
              title: Text(a.title),
              subtitle: Text('${lang.t('assignments.dueDate')}: ${a.dueDate}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => context.go('/student/assignments/${a.id}'),
            )),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
