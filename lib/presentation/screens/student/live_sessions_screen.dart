import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class LiveSessionsScreen extends StatelessWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    final liveRepo = context.read<LiveSessionsRepository>();
    return FutureBuilder(
      future: Future.wait([
        liveRepo.getStudentLiveSessions(status: 'ongoing'),
        liveRepo.getStudentLiveSessions(status: 'approved'),
        context.read<ClassesRepository>().getClasses(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final activeSessions = (snapshot.data![0] as List).cast<LiveSessionEntity>();
        final upcomingSessions = (snapshot.data![1] as List).cast<LiveSessionEntity>();
        final classes = (snapshot.data![2] as List).cast<ClassEntity>();

        ClassEntity? classFor(LiveSessionEntity s) {
          try {
            return classes.firstWhere((c) => c.id == s.classId);
          } catch (_) {
            return null;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
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
                    lang.t('live.liveSessions'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.t('live.upcomingSessions'),
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
            // Active Now section
            if (activeSessions.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${lang.t('live.activeNow')} (${activeSessions.length})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...activeSessions.map((s) => _ActiveSessionCard(session: s, lang: lang)),
              const SizedBox(height: 20),
            ],
            // Upcoming Sessions section
            Text(
              '${lang.t('live.upcomingSessions')} (${upcomingSessions.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            if (upcomingSessions.isEmpty)
              _EmptyUpcomingCard(lang: lang)
            else
              ...upcomingSessions.map((s) => _UpcomingSessionCard(
                    session: s,
                    className: s.className ?? classFor(s)?.name ?? 'Class',
                    lang: lang,
                  )),
            if (activeSessions.isEmpty && upcomingSessions.isEmpty) ...[
              const SizedBox(height: 16),
              _EmptyAllCard(lang: lang),
            ],
            const SizedBox(height: 24),
          ],
          ),
        );
      },
    );
  }
}

class _ActiveSessionCard extends StatelessWidget {
  final LiveSessionEntity session;
  final LanguageProvider lang;

  const _ActiveSessionCard({required this.session, required this.lang});

  @override
  Widget build(BuildContext context) {
    final platformStr = session.platform == LiveSessionPlatform.zoom ? 'Zoom' : 'Meet';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${session.time} • $platformStr',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => context.go('/student/live-sessions/${session.id}'),
              icon: const Icon(Icons.video_call, size: 16),
              label: Text(lang.t('live.joinSession')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2e7d32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  final LiveSessionEntity session;
  final String className;
  final LanguageProvider lang;

  const _UpcomingSessionCard({
    required this.session,
    required this.className,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final platformStr = session.platform == LiveSessionPlatform.zoom ? 'Zoom' : 'Meet';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.primary,
            child: Row(
              children: [
                const Icon(Icons.video_call, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    className,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(session.date, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 14, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(session.time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    platformStr,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
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

class _EmptyUpcomingCard extends StatelessWidget {
  final LanguageProvider lang;

  const _EmptyUpcomingCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.video_call, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              lang.t('live.noUpcomingSessions'),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAllCard extends StatelessWidget {
  final LanguageProvider lang;

  const _EmptyAllCard({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            Icon(Icons.video_call, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              lang.t('live.noActiveSessions'),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
