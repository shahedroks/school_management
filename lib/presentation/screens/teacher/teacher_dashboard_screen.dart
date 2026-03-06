import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
import 'package:high_school/domain/entities/timetable_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/timetable_repository.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  static const List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final teacherId = auth.user?.id == 'demo_teacher' ? 'teacher1' : (auth.user?.id ?? 'teacher1');
    final today = _weekdays[DateTime.now().weekday - 1];

    return FutureBuilder(
      future: Future.wait([
        context.read<ClassesRepository>().getClassesByTeacher(teacherId),
        context.read<TimetableRepository>().getTimetable(),
        context.read<LiveSessionsRepository>().getLiveSessions(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final myClasses = (snapshot.data![0] as List).cast<ClassEntity>();
        final allTimetable = (snapshot.data![1] as List).cast<TimetableEntryEntity>();
        final allSessions = (snapshot.data![2] as List).cast<LiveSessionEntity>();

        final totalStudents = myClasses.fold<int>(0, (sum, c) => sum + c.students);
        final pendingGrading = MockData.submissions.where((s) => s.grade == null).length;
        final gradedCount = MockData.submissions.where((s) => s.grade != null).length;
        final todayClasses = allTimetable.where((e) => e.day == today).toList();
        final now = DateTime.now();
        final twoDaysLater = now.add(const Duration(days: 2));
        final upcomingSessions = allSessions.where((s) {
          final d = DateTime.tryParse(s.date);
          return d != null && !d.isBefore(DateTime(now.year, now.month, now.day)) &&
              (d.isBefore(DateTime(twoDaysLater.year, twoDaysLater.month, twoDaysLater.day)) || d.isAtSameMomentAs(DateTime(twoDaysLater.year, twoDaysLater.month, twoDaysLater.day)));
        }).toList();

        final firstName = auth.user?.name.split(' ').first ?? '';

        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeBanner(lang, firstName),
                const SizedBox(height: 16),
                _buildStatsGrid(context, lang, myClasses.length, totalStudents, pendingGrading, gradedCount),
                const SizedBox(height: 16),
                _buildQuickActions(context, lang),
                const SizedBox(height: 16),
                _buildTodaysClasses(context, lang, todayClasses, myClasses, today),
                const SizedBox(height: 16),
                _buildUpcomingSessions(context, lang, upcomingSessions),
                const SizedBox(height: 16),
                _buildRecentSubmissions(context, lang),
                const SizedBox(height: 16),
                _buildMyClassesCard(context, lang, myClasses),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeBanner(LanguageProvider lang, String firstName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${lang.t('dashboard.welcomeBack')}, $firstName!', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
          const SizedBox(height: 4),
          Text(lang.t('dashboard.teachingOverview'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, decoration: TextDecoration.none)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, LanguageProvider lang, int classesCount, int totalStudents, int pendingGrading, int gradedCount) {
    final stats = [
      (lang.t('classes.myClasses'), '$classesCount', Icons.menu_book, AppTheme.primary),
      (lang.t('classes.totalStudents'), '$totalStudents', Icons.people, AppTheme.secondary),
      (lang.t('assignments.pendingGrading'), '$pendingGrading', Icons.schedule, Colors.amber.shade700),
      (lang.t('assignments.graded'), '$gradedCount', Icons.check_circle, AppTheme.accent),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: stats.map((s) => _StatCard(title: s.$1, value: s.$2, icon: s.$3, color: s.$4)).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context, LanguageProvider lang) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Text(lang.t('actions.quickActions'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.t('actions.createLesson')))),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(lang.t('actions.createLesson')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.t('actions.createAssignment')))),
                    icon: const Icon(Icons.assignment, size: 18),
                    label: Text(lang.t('actions.createAssignment')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.t('actions.scheduleSession')))),
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(lang.t('actions.scheduleSession')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysClasses(BuildContext context, LanguageProvider lang, List<TimetableEntryEntity> todayClasses, List<ClassEntity> myClasses, String today) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text('${lang.t('today.todayClasses')} - $today', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: todayClasses.isEmpty
                ? Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text(lang.t('today.noClasses'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600))))
                : Column(
                    children: todayClasses.map((entry) {
                      ClassEntity? cls;
                      try {
                        cls = myClasses.firstWhere((c) => c.id == entry.classId);
                      } catch (_) {}
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => context.go('/teacher/classes/${entry.classId}'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(cls?.subject ?? entry.className, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3))),
                                      child: Text(cls?.level ?? '', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.secondary)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(children: [Icon(Icons.schedule, size: 14, color: Colors.grey.shade600), const SizedBox(width: 6), Text(entry.time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                                const SizedBox(height: 4),
                                Row(children: [Icon(Icons.people, size: 14, color: Colors.grey.shade600), const SizedBox(width: 6), Text('${cls?.students ?? 0} ${lang.t('classes.students')}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessions(BuildContext context, LanguageProvider lang, List<LiveSessionEntity> upcomingSessions) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                Icon(Icons.video_call, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(lang.t('live.upcomingSessions'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: upcomingSessions.isEmpty
                ? Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('No upcoming live sessions', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...upcomingSessions.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text('${s.date} • ${s.time}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                          )),
                      OutlinedButton(
                        onPressed: () => context.go('/teacher/live-sessions'),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                        child: Text(lang.t('common.viewAll')),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSubmissions(BuildContext context, LanguageProvider lang) {
    final pending = MockData.submissions.where((s) => s.grade == null).toList();
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                Expanded(child: Text(lang.t('recent.recentSubmissions'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
                  child: Text('${pending.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...pending.take(3).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.studentName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(_formatSubmittedDate(s.submittedAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    )),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/teacher/classes'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                    child: Text(lang.t('actions.viewSubmissions')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyClassesCard(BuildContext context, LanguageProvider lang, List<ClassEntity> myClasses) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                Expanded(child: Text(lang.t('classes.myClasses'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text('${myClasses.length}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...myClasses.take(2).map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => context.go('/teacher/classes/${c.id}'),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(c.subject, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3))),
                                    child: Text(c.level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.secondary)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600), const SizedBox(width: 6), Expanded(child: Text(c.schedule, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)))]),
                              const SizedBox(height: 4),
                              Row(children: [Icon(Icons.people, size: 14, color: Colors.grey.shade600), const SizedBox(width: 6), Text('${c.students} ${lang.t('classes.students')}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                            ],
                          ),
                        ),
                      ),
                    )),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/teacher/classes'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                    child: Text(lang.t('common.viewAll')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSubmittedDate(String iso) {
    try {
      final d = DateTime.tryParse(iso);
      if (d != null) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return 'Submitted ${months[d.month - 1]} ${d.day}';
      }
    } catch (_) {}
    return 'Submitted';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
