import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/user_entity.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class LayoutWidget extends StatelessWidget {
  const LayoutWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();

    if (!auth.isAuthenticated) {
      return SizedBox(height: double.infinity, child: child);
    }

    final user = auth.user!;
    final isStudent = user.role == UserRole.student;
    final navItems = isStudent
        ? [
            _NavItem(path: '/student/dashboard', label: lang.t('nav.home'), icon: Icons.home),
            _NavItem(path: '/student/classes', label: lang.t('nav.classes'), icon: Icons.menu_book),
            _NavItem(path: '/student/timetable', label: lang.t('timetable.timetable'), icon: Icons.calendar_today),
            _NavItem(path: '/student/live-sessions', label: lang.t('live.liveSessions'), icon: Icons.video_call),
          ]
        : [
            _NavItem(path: '/teacher/dashboard', label: lang.t('nav.home'), icon: Icons.home),
            _NavItem(path: '/teacher/classes', label: lang.t('nav.classes'), icon: Icons.menu_book),
            _NavItem(path: '/teacher/students', label: lang.t('nav.students'), icon: Icons.people),
            _NavItem(path: '/teacher/live-sessions', label: lang.t('live.liveSessions'), icon: Icons.video_call),
          ];

    final location = GoRouterState.of(context).uri.path;
    final canGoBack = !location.contains('dashboard');

    return Column(
      children: [
        Material(
          color: Colors.white,
          elevation: 2,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (canGoBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppTheme.primary),
                      onPressed: () => context.pop(),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school, color: AppTheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text('Nouadhibou HS', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ],
                    ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppTheme.primary),
                        onPressed: () => context.go('/notifications'),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text('3', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary,
                      child: Text(
                        _initials(user.name),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppTheme.primary),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(user.name),
                                subtitle: Text(user.role.name),
                              ),
                              ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(lang.t('profile.myProfile')),
                                onTap: () {
                                  Navigator.pop(ctx);
                                  context.go(isStudent ? '/student/profile' : '/teacher/profile');
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: Text(lang.t('common.logout')),
                                onTap: () async {
                                  await auth.logout();
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (context.mounted) context.go('/login');
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          ),
        ),
        Material(
          color: Colors.white,
          elevation: 8,
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems.map((item) {
                final isActive = location == item.path || location.startsWith('${item.path}/');
                return Expanded(
                  child: InkWell(
                    onTap: () => context.go(item.path),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 24, color: isActive ? AppTheme.primary : Colors.grey),
                          const SizedBox(height: 4),
                          Text(item.label, style: TextStyle(fontSize: 10, color: isActive ? AppTheme.primary : Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0].length >= 2 ? parts[0].substring(0, 2).toUpperCase() : parts[0].toUpperCase();
  return '${parts[0].isNotEmpty ? parts[0][0] : ''}${parts[1].isNotEmpty ? parts[1][0] : ''}'.toUpperCase();
}

class _NavItem {
  final String path;
  final String label;
  final IconData icon;
  _NavItem({required this.path, required this.label, required this.icon});
}
