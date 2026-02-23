import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
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
        final classes = snapshot.data![0] as List<dynamic>;
        final classList = classes.whereType<ClassEntity>().toList();
        final assignments = snapshot.data![1] as List<AssignmentEntity>;
        final sessions = snapshot.data![2] as List<dynamic>;
        final sessionList = sessions.whereType<LiveSessionEntity>().toList();
        final enrolledIds = subscription.subscription?.enrolledClassIds ?? [];
        final enrolledClasses = classList.where((c) => enrolledIds.contains(c.id)).toList();
        final pending = assignments.where((a) => a.status == AssignmentStatus.pending).length;
        final graded = assignments.where((a) => a.status == AssignmentStatus.graded).length;
        final activeSessions = sessionList.where((s) => s.isActive).toList();
        final upcomingAssignments = assignments.where((a) => a.status == AssignmentStatus.pending).take(3).toList();

        final firstName = auth.user?.name.split(' ').first ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner – Image 1: dark blue, subtle gradient, white + light grey text, no underlines
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2A4A9E),
                    const Color(0xFF2F52B4),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${lang.t('dashboard.welcomeBack')}, $firstName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.t('dashboard.overview'),
                    style: TextStyle(
                      color: const Color(0xFFD3D3D3),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Stats grid – white cards, icon + value + label
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _StatCard(title: lang.t('classes.enrolledClasses'), value: enrolledClasses.length, icon: Icons.menu_book, iconColor: AppTheme.primary),
                _StatCard(title: lang.t('assignments.pending'), value: pending, icon: Icons.assignment, iconColor: const Color(0xFFE65100)),
                _StatCard(title: lang.t('lessons.completed'), value: graded, icon: Icons.check_circle, iconColor: AppTheme.accent),
                _StatCard(title: lang.t('live.liveSessions'), value: activeSessions.length, icon: Icons.video_call, iconColor: AppTheme.primary),
              ],
            ),
            // Active Live Sessions – white card, time • Zoom/Meet, green Join button with icon
            if (activeSessions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 1,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.video_call, size: 20, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            lang.t('live.activeSessions'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...activeSessions.take(3).map((s) {
                        final platformStr = s.platform == LiveSessionPlatform.zoom ? 'Zoom' : 'Meet';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Text('${s.time} • $platformStr', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.video_call, size: 16),
                                label: Text(lang.t('live.joinSession')),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
            // Upcoming Assignments – document icon, View All, cards with title, description, days left (red), pts badge (yellow), warning icon
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assignment, size: 20, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            lang.t('assignments.upcomingAssignments'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/student/assignments'),
                          child: Text(lang.t('common.viewAll'), style: const TextStyle(color: AppTheme.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...upcomingAssignments.map((a) => _AssignmentCard(assignment: a, lang: lang)),
                  ],
                ),
              ),
            ),
            // Progress Overview – trending up icon, progress bars per subject
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 20, color: AppTheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          lang.t('progress.progressOverview'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...(classList.take(4).toList().asMap().entries.map((e) {
                      final progress = 65 + e.key * 10;
                      final cls = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cls.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                Text('$progress%', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

int _daysUntilDue(String dueDateStr) {
  try {
    final d = DateTime.tryParse(dueDateStr);
    if (d == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(d.year, d.month, d.day);
    return due.difference(today).inDays;
  } catch (_) {
    return 0;
  }
}

class _AssignmentCard extends StatelessWidget {
  final AssignmentEntity assignment;
  final LanguageProvider lang;

  const _AssignmentCard({required this.assignment, required this.lang});

  @override
  Widget build(BuildContext context) {
    final daysLeft = _daysUntilDue(assignment.dueDate);
    final isUrgent = daysLeft <= 2;
    final daysText = daysLeft >= 0 ? '${daysLeft}d left' : '${-daysLeft}d left';

    return InkWell(
      onTap: () => context.go('/student/assignments/${assignment.id}'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  assignment.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      daysText,
                      style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: isUrgent ? FontWeight.w500 : null),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.3)),
                      ),
                      child: Text('${assignment.points} pts', style: const TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
            if (isUrgent)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.warning_amber_rounded, size: 20, color: Colors.red.shade700),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.value,
    this.iconColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                height: 1.2,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
