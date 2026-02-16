import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/domain/entities/user_entity.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final isStudent = auth.user?.role == UserRole.student;

    final links = isStudent
        ? [
            _Link('Dashboard', '/student/dashboard'),
            _Link(lang.t('nav.classes'), '/student/classes'),
            _Link(lang.t('timetable.timetable'), '/student/timetable'),
            _Link(lang.t('live.liveSessions'), '/student/live-sessions'),
            _Link(lang.t('nav.profile'), '/student/profile'),
          ]
        : [
            _Link('Dashboard', '/teacher/dashboard'),
            _Link(lang.t('nav.classes'), '/teacher/classes'),
            _Link(lang.t('nav.students'), '/teacher/students'),
            _Link(lang.t('live.liveSessions'), '/teacher/live-sessions'),
            _Link(lang.t('analytics.analytics'), '/teacher/analytics'),
            _Link(lang.t('nav.profile'), '/teacher/profile'),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sitemap', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...links.map((l) => ListTile(
          title: Text(l.title),
          onTap: () => context.go(l.path),
        )),
      ],
    );
  }
}

class _Link {
  final String title;
  final String path;
  _Link(this.title, this.path);
}
