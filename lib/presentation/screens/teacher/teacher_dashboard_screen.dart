import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();

    final teacherId = auth.user?.id == 'demo_teacher' ? 'teacher1' : (auth.user?.id ?? 'teacher1');
    return FutureBuilder(
      future: Future.wait([
        context.read<ClassesRepository>().getClassesByTeacher(teacherId),
        context.read<AssignmentsRepository>().getAssignments(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final myClasses = snapshot.data![0] as List;
        final assignments = snapshot.data![1] as List;
        final pendingGrading = MockData.submissions.where((s) => s.grade == null).length;
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
                  Text(lang.t('dashboard.teachingOverview'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
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
                _StatCard(title: lang.t('classes.myClasses'), value: '${myClasses.length}', icon: Icons.menu_book),
                _StatCard(title: lang.t('assignments.pendingGrading'), value: '$pendingGrading', icon: Icons.assignment_turned_in),
              ],
            ),
            const SizedBox(height: 16),
            Text(lang.t('classes.myClasses'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...myClasses.take(5).map((c) => ListTile(
              title: Text(c.name),
              subtitle: Text('${c.students} ${lang.t('classes.students')}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/teacher/classes/${c.id}'),
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
