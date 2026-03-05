import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/entities/user_entity.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/providers/subscription_provider.dart';
import 'package:high_school/presentation/widgets/language_selector_widget.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String? _displayName;
  String? _displayEmail;
  String _phone = '+222 45 67 89 01';
  String _address = 'Nouadhibou, Mauritania';
  String _parentName = 'Ahmed Hassan';
  String _parentPhone = '+222 45 67 89 02';
  String _parentEmail = 'ahmed.hassan@email.mr';

  static String _initials(String name) {
    return name.trim().split(RegExp(r'\s+')).map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox();

    return FutureBuilder(
      future: Future.wait([
        context.read<SubscriptionProvider>().load(user.id),
        context.read<ClassesRepository>().getClasses(),
        context.read<AssignmentsRepository>().getAssignments(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final subscription = context.read<SubscriptionProvider>().subscription;
        final enrolledIds = subscription?.enrolledClassIds ?? [];
        final classes = (snapshot.data![1] as List).cast<ClassEntity>();
        final assignments = (snapshot.data![2] as List).cast<AssignmentEntity>();
        final enrolledClasses = classes.where((c) => enrolledIds.contains(c.id)).toList();
        final completedCount = assignments.where((a) => a.status == AssignmentStatus.graded || a.status == AssignmentStatus.submitted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            _buildHeader(lang),
            const SizedBox(height: 16),
            _buildProfileCard(context, user, lang),
            const SizedBox(height: 16),
            _buildAcademicCard(context, lang, enrolledClasses.length, completedCount, assignments.length),
            const SizedBox(height: 16),
            _buildParentCard(context, lang),
            const SizedBox(height: 16),
            _buildCurrentClassesCard(context, lang, enrolledClasses),
        const SizedBox(height: 16),
        Text(lang.t('profile.languagePreference'), style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        const LanguageSelectorWidget(),
            const SizedBox(height: 16),
            _buildAchievementsCard(context, lang),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildHeader(LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('profile.myProfile'), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, decoration: TextDecoration.none)),
          const SizedBox(height: 6),
          Text(lang.t('profile.managePersonalInfo'), style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: 15, decoration: TextDecoration.none)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserEntity user, LanguageProvider lang) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 40, backgroundColor: AppTheme.primary.withValues(alpha: 0.2), child: Text(_initials(_displayName ?? user.name), style: const TextStyle(color: AppTheme.primary, fontSize: 28, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            Text(_displayName ?? user.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            if (user.grade != null && user.grade!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))), child: Text(user.grade!, style: const TextStyle(color: AppTheme.primary, fontSize: 12))),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showEditDialog(context, user, lang),
              icon: const Icon(Icons.edit, size: 18),
              label: Text(lang.t('profile.editProfile')),
              style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
            const Divider(height: 24),
            Row(children: [Icon(Icons.email, size: 18, color: AppTheme.primary), const SizedBox(width: 12), Expanded(child: Text(_displayEmail ?? user.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)))]),
            const SizedBox(height: 8),
            Row(children: [Icon(Icons.phone, size: 18, color: AppTheme.primary), const SizedBox(width: 12), Text(_phone, style: TextStyle(fontSize: 14, color: Colors.grey.shade600))]),
            const SizedBox(height: 8),
            Row(children: [Icon(Icons.location_on, size: 18, color: AppTheme.primary), const SizedBox(width: 12), Expanded(child: Text(_address, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)))]),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserEntity user, LanguageProvider lang) {
    final nameCtrl = TextEditingController(text: _displayName ?? user.name);
    final emailCtrl = TextEditingController(text: _displayEmail ?? user.email);
    final phoneCtrl = TextEditingController(text: _phone);
    final addressCtrl = TextEditingController(text: _address);
    final parentNameCtrl = TextEditingController(text: _parentName);
    final parentPhoneCtrl = TextEditingController(text: _parentPhone);
    final parentEmailCtrl = TextEditingController(text: _parentEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(lang.t('profile.editProfile')),
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(lang.t('profile.personalInfo'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              _editField(context, lang.t('profile.fullName'), nameCtrl),
              _editField(context, lang.t('profile.email'), emailCtrl),
              _editField(context, lang.t('profile.phone'), phoneCtrl),
              _editField(context, lang.t('profile.address'), addressCtrl),
              const Divider(height: 24),
              Text(lang.t('profile.parentInfo'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              _editField(context, lang.t('profile.parentName'), parentNameCtrl),
              _editField(context, lang.t('profile.parentPhone'), parentPhoneCtrl),
              _editField(context, lang.t('profile.parentEmail'), parentEmailCtrl),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.t('common.cancel'))),
          FilledButton(
            onPressed: () {
              setState(() {
                _displayName = nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim();
                _displayEmail = emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim();
                _phone = phoneCtrl.text;
                _address = addressCtrl.text;
                _parentName = parentNameCtrl.text;
                _parentPhone = parentPhoneCtrl.text;
                _parentEmail = parentEmailCtrl.text;
              });
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.t('common.profileUpdated'))));
              }
            },
            child: Text(lang.t('common.saveChanges')),
          ),
        ],
      ),
    );
  }

  Widget _editField(BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
          ),
        ),
      ]),
    );
  }

  Widget _buildAcademicCard(BuildContext context, LanguageProvider lang, int enrolledCount, int completedAssignments, int totalAssignments) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.emoji_events, size: 20, color: AppTheme.primary), const SizedBox(width: 8), Text(lang.t('profile.academicOverview'), style: Theme.of(context).textTheme.titleMedium)]),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _StatBox(icon: Icons.menu_book, label: lang.t('classes.enrolledClasses'), value: '$enrolledCount', color: AppTheme.primary),
                _StatBox(icon: Icons.assignment, label: lang.t('profile.assignments'), value: '$completedAssignments/$totalAssignments', color: AppTheme.secondary),
                _StatBox(icon: Icons.emoji_events, label: lang.t('profile.averageGrade'), value: '87%', color: AppTheme.accent),
                _StatBox(icon: Icons.calendar_today, label: lang.t('profile.attendance'), value: '94%', color: AppTheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentCard(BuildContext context, LanguageProvider lang) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.people, size: 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(lang.t('profile.parentGuardianContact'), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primary)),
            ]),
            const SizedBox(height: 12),
            _infoRow(context, '${lang.t('profile.name')}:', _parentName),
            _infoRow(context, '${lang.t('profile.phone')}:', _parentPhone),
            _infoRow(context, '${lang.t('profile.email')}:', _parentEmail),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        Flexible(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.primary), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _buildCurrentClassesCard(BuildContext context, LanguageProvider lang, List<ClassEntity> enrolledClasses) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.menu_book, size: 20, color: AppTheme.primary), const SizedBox(width: 8), Text(lang.t('profile.currentClasses'), style: Theme.of(context).textTheme.titleMedium)]),
            const SizedBox(height: 12),
            ...enrolledClasses.take(6).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1))),
                    child: Row(children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))), child: Text(c.teacher, style: const TextStyle(fontSize: 10))),
                    ]),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsCard(BuildContext context, LanguageProvider lang) {
    // Colors matching design: bg, icon, title for each achievement
    const Color greenBg = Color(0xFFE8F8E8);
    const Color greenIcon = Color(0xFF66BB6A);
    const Color greenTitle = Color(0xFF388E3C);
    const Color goldBg = Color(0xFFFFFBEB);
    const Color goldIcon = Color(0xFFFFC107);
    const Color goldTitle = Color(0xFFFFA000);
    const Color blueBg = Color(0xFFEBF0FA);
    const Color blueIcon = Color(0xFF42A5F5);
    const Color blueTitle = Color(0xFF1976D2);
    const Color subtitleGrey = Color(0xFF616161);
    const Color headerGreen = Color(0xFF4CAF50);
    const Color headerText = Color(0xFF333333);

    final achievements = [
      ('Perfect Attendance', 'December 2025', greenBg, greenIcon, greenTitle),
      ('Top Grade in Mathematics', 'Final Exam - 95%', goldBg, goldIcon, goldTitle),
      ('Outstanding Project', 'Science Fair Winner', blueBg, blueIcon, blueTitle),
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2), width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.check_circle, size: 20, color: headerGreen), const SizedBox(width: 8), Text(lang.t('profile.recentAchievements'), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: headerText))]),
            const SizedBox(height: 12),
            ...achievements.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: a.$3, borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Icon(Icons.emoji_events, size: 22, color: a.$4),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.$1, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: a.$5)), Text(a.$2, style: const TextStyle(fontSize: 12, color: subtitleGrey))])),
                    ]),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 4), Expanded(child: Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis))]),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}
