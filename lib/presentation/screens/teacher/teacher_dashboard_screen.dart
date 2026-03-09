import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
import 'package:high_school/domain/entities/lesson_entity.dart';
import 'package:high_school/domain/entities/timetable_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/timetable_repository.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/domain/repositories/lessons_repository.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
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
    final teacherId =
        auth.user?.id == 'demo_teacher' ? 'teacher1' : (auth.user?.id ?? 'teacher1');
    final now = DateTime.now();
    final bool isWeekday =
        now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;
    final String today = isWeekday
        ? _weekdays[now.weekday - DateTime.monday]
        : '';

    return FutureBuilder(
      future: Future.wait([
        context.read<ClassesRepository>().getClassesByTeacher(teacherId),
        context.read<TimetableRepository>().getTimetable(),
        context.read<LiveSessionsRepository>().getLiveSessions(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final myClasses = (snapshot.data![0] as List).cast<ClassEntity>();
        final allTimetable =
            (snapshot.data![1] as List).cast<TimetableEntryEntity>();
        final allSessions =
            (snapshot.data![2] as List).cast<LiveSessionEntity>();

        final totalStudents =
            myClasses.fold<int>(0, (sum, c) => sum + c.students);
        final pendingGrading =
            MockData.submissions.where((s) => s.grade == null).length;
        final gradedCount =
            MockData.submissions.where((s) => s.grade != null).length;
        final todayClasses = isWeekday
            ? allTimetable.where((e) => e.day == today).toList()
            : <TimetableEntryEntity>[];
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
                _buildQuickActions(context, lang, myClasses),
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

  Widget _buildStatsGrid(BuildContext context, LanguageProvider lang,
      int classesCount, int totalStudents, int pendingGrading, int gradedCount) {
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

  Widget _buildQuickActions(
      BuildContext context, LanguageProvider lang, List<ClassEntity> myClasses) {
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
                    onPressed: () =>
                        _showCreateLessonDialog(context, lang, myClasses),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(lang.t('actions.createLesson')),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showCreateAssignmentDialog(context, lang, myClasses),
                    icon: const Icon(Icons.assignment, size: 18),
                    label: Text(lang.t('actions.createAssignment')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showScheduleLiveSessionDialog(context, lang, myClasses),
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
                Expanded(
                  child: Text(
                    today.isNotEmpty
                        ? '${lang.t('today.todayClasses')} - $today'
                        : lang.t('today.todayClasses'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
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

  void _showCreateLessonDialog(
      BuildContext context, LanguageProvider lang, List<ClassEntity> myClasses) {
    const labelColor = Color(0xFF1F3C88);
    const borderColor = Color(0xFFD1D5DB);

    String title = '';
    String description = '';
    String type = 'text';
    String module = '';
    String grade = '';
    String subject = 'Mathematics';
    String date = DateTime.now().toIso8601String().split('T').first;
    String? attachedFileName;
    String selectedClassId =
        myClasses.isNotEmpty ? myClasses.first.id : '';

    Widget dialogLabel(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        );

    InputDecoration inputDecoration(String hint) => InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        );

    const gradeOptions = ['4th', '5th', '6th', '7th'];
    const subjectOptions = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'SVT',
      'French',
      'Arabic',
      'English'
    ];

    void submitLesson(LessonStatus status) {
      if (selectedClassId.isEmpty) return;
      final lessonType = type == 'video'
          ? LessonType.video
          : (type == 'pdf' ? LessonType.pdf : LessonType.text);
      final nowStr = DateTime.now().toIso8601String().split('T').first;
      final clsId = selectedClassId;

      context.read<LessonsRepository>().addLesson(LessonEntity(
            id: 'lesson-${DateTime.now().millisecondsSinceEpoch}',
            classId: clsId,
            title: title,
            description: description,
            type: lessonType,
            content: '',
            date: date,
            status: status,
            lastUpdated: nowStr,
            module: module.isEmpty ? null : module,
          ));
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.sizeOf(ctx).width;
        final dialogWidth = (screenWidth > 420) ? 400.0 : (screenWidth - 24);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang.t('teacherClassDetails.createLesson'),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: labelColor),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close,
                              color: labelColor, size: 24),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            dialogLabel(
                                '${lang.t('teacherClassDetails.lessonTitle')} *'),
                            TextField(
                              decoration: inputDecoration(
                                  'e.g., Introduction to Algebra'),
                              onChanged: (v) => title = v,
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(
                                '${lang.t('teacherClassDetails.contentType')} *'),
                            DropdownButtonFormField<String>(
                              value: type,
                              decoration: inputDecoration('').copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10)),
                              items: ['text', 'pdf', 'video']
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e == 'text'
                                            ? 'Text / PDF'
                                            : e),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setDialogState(() => type = v ?? 'text'),
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(lang.t('lessons.description')),
                            TextField(
                              decoration: inputDecoration(
                                  'Describe the lesson content...'),
                              maxLines: 3,
                              onChanged: (v) => description = v,
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(
                                '${lang.t('teacherClassDetails.chapter')} *'),
                            TextField(
                              decoration: inputDecoration(
                                  'e.g., Chapter 3: Equations'),
                              onChanged: (v) => module = v,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      dialogLabel(
                                          '${lang.t('live.grade')} *'),
                                      DropdownButtonFormField<String>(
                                        value: grade.isEmpty
                                            ? null
                                            : (gradeOptions.contains(grade)
                                                ? grade
                                                : null),
                                        decoration: inputDecoration(
                                                'Select grade')
                                            .copyWith(
                                                contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 10)),
                                        isExpanded: true,
                                        items: gradeOptions
                                            .map((g) => DropdownMenuItem(
                                                value: g,
                                                child: Text('$g Grade')))
                                            .toList(),
                                        onChanged: (v) => setDialogState(
                                            () => grade = v ?? ''),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      dialogLabel(
                                          '${lang.t('live.subject')} *'),
                                      DropdownButtonFormField<String>(
                                        value: subject,
                                        decoration: inputDecoration('')
                                            .copyWith(
                                                contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 10)),
                                        isExpanded: true,
                                        items: subjectOptions
                                            .map((s) => DropdownMenuItem(
                                                value: s, child: Text(s)))
                                            .toList(),
                                        onChanged: (v) => setDialogState(
                                            () =>
                                                subject = v ?? 'Mathematics'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(
                                '${lang.t('classes.classDetails')} *'),
                            DropdownButtonFormField<String>(
                              value: selectedClassId.isEmpty
                                  ? null
                                  : selectedClassId,
                              decoration: inputDecoration('Select class')
                                  .copyWith(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10)),
                              isExpanded: true,
                              items: myClasses
                                  .map((c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ))
                                  .toList(),
                              onChanged: (v) => setDialogState(
                                  () => selectedClassId = v ?? ''),
                            ),
                            const SizedBox(height: 12),
                            dialogLabel('${lang.t('live.date')} *'),
                            TextField(
                              decoration: inputDecoration('Pick a date')
                                  .copyWith(
                                      prefixIcon: Icon(Icons.calendar_today,
                                          size: 20,
                                          color: Colors.grey.shade600)),
                              onChanged: (v) => date = v,
                              controller:
                                  TextEditingController(text: date),
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(lang.t(
                                'teacherClassDetails.attachFiles')),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: borderColor, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.upload_file,
                                        size: 36, color: labelColor),
                                    const SizedBox(height: 8),
                                    Text(
                                      attachedFileName ??
                                          'Click to upload PDF or documents',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: (attachedFileName ?? '')
                                                .isEmpty
                                            ? Colors.grey.shade600
                                            : labelColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: labelColor,
                            side: const BorderSide(color: Color(0xFF90CAF9)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          child: Text(
                            lang.t('common.cancel'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () =>
                              submitLesson(LessonStatus.draft),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          child: Text(
                            lang.t('teacherClassDetails.saveAsDraft'),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        FilledButton(
                          onPressed: () =>
                              submitLesson(LessonStatus.published),
                          style: FilledButton.styleFrom(
                            backgroundColor: labelColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          child: Text(
                            lang.t('teacherClassDetails.createLesson'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateAssignmentDialog(BuildContext context, LanguageProvider lang,
      List<ClassEntity> myClasses) {
    const labelColor = Color(0xFF1F3C88);
    const borderColor = Color(0xFFD1D5DB);

    String title = '';
    String description = '';
    String dueDate = '';
    String dueTime = '';
    String points = '100';
    String? attachedFileName;
    String selectedClassId = myClasses.isNotEmpty ? myClasses.first.id : '';

    Widget dialogLabel(String text, {bool required = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: labelColor),
              children: [
                TextSpan(text: text),
                if (required)
                  const TextSpan(
                      text: ' *',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );

    InputDecoration inputDecoration(String hint,
            {Widget? prefixIcon, Widget? suffixIcon}) =>
        InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        );

    void submit() {
      final pts = int.tryParse(points) ?? 100;
      if (selectedClassId.isEmpty || title.isEmpty) return;
      // dueTime kept for UI; could be added to entity later
      final _ = dueTime;
      final dateStr = dueDate.isEmpty
          ? DateTime.now().toIso8601String().split('T').first
          : dueDate;
      final assignment = AssignmentEntity(
        id: 'assign-${DateTime.now().millisecondsSinceEpoch}',
        classId: selectedClassId,
        title: title,
        description: description,
        dueDate: dateStr,
        points: pts,
        status: AssignmentStatus.pending,
      );
      context.read<AssignmentsRepository>().addAssignment(assignment);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(lang.t('actions.createAssignment'))));
        Navigator.pop(context);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.sizeOf(ctx).width;
        final dialogWidth = (screenWidth > 420) ? 400.0 : (screenWidth - 24);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang.t('teacherClassDetails.createAssignment'),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: labelColor),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close,
                              color: labelColor, size: 24),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (myClasses.isNotEmpty) ...[
                              dialogLabel(lang.t('classes.classDetails'),
                                  required: true),
                              DropdownButtonFormField<String>(
                                value: selectedClassId.isEmpty
                                    ? null
                                    : selectedClassId,
                                decoration: inputDecoration(
                                        lang.t('students.selectClass'))
                                    .copyWith(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10)),
                                isExpanded: true,
                                items: myClasses
                                    .map((c) => DropdownMenuItem(
                                        value: c.id, child: Text(c.name)))
                                    .toList(),
                                onChanged: (v) => setDialogState(
                                    () => selectedClassId = v ?? ''),
                              ),
                              const SizedBox(height: 12),
                            ],
                            dialogLabel(
                                lang.t('teacherClassDetails.assignmentTitle'),
                                required: true),
                            TextField(
                              decoration: inputDecoration(
                                  'e.g., Chapter 5 Homework'),
                              onChanged: (v) => title = v,
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(lang.t('lessons.description')),
                            TextField(
                              decoration: inputDecoration(
                                  'Describe the assignment...'),
                              maxLines: 3,
                              onChanged: (v) => description = v,
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(lang.t('assignments.dueDate'),
                                required: true),
                            TextField(
                              decoration: inputDecoration('dd / mm / yyyy',
                                  prefixIcon: Icon(Icons.calendar_today,
                                      size: 20,
                                      color: Colors.grey.shade600)),
                              onChanged: (v) => dueDate = v,
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(
                                lang.t('teacherClassDetails.dueTime'),
                                required: true),
                            TextField(
                              decoration: inputDecoration('--:-- --',
                                  suffixIcon: Icon(Icons.schedule,
                                      size: 20,
                                      color: Colors.grey.shade600)),
                              onChanged: (v) => dueTime = v,
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(lang.t('assignments.points'),
                                required: true),
                            TextField(
                              decoration: inputDecoration('100'),
                              keyboardType: TextInputType.number,
                              onChanged: (v) => points = v,
                              controller: TextEditingController(text: points),
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(
                                lang.t('teacherClassDetails.attachFiles')),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: borderColor, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.upload_file,
                                        size: 36, color: labelColor),
                                    const SizedBox(height: 8),
                                    Text(
                                      attachedFileName ??
                                          'Click to upload assignment files',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: (attachedFileName ?? '')
                                                .isEmpty
                                            ? Colors.grey.shade600
                                            : labelColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            backgroundColor: Colors.grey.shade100,
                            side: BorderSide(color: borderColor),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          child: Text(
                            lang.t('common.cancel'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        FilledButton(
                          onPressed: submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          child: Text(
                            lang.t('teacherClassDetails.createAssignment'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showScheduleLiveSessionDialog(BuildContext context, LanguageProvider lang,
      List<ClassEntity> myClasses) {
    const labelColor = Color(0xFF1F3C88);
    const borderColor = Color(0xFFD1D5DB);

    String title = '';
    String grade = '';
    String subject = '';
    String className = '';
    String date = '';
    String time = '';
    String zoomLink = '';
    String selectedClassId = myClasses.isNotEmpty ? myClasses.first.id : '';

    Widget dialogLabel(String text, {bool required = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: labelColor),
              children: [
                TextSpan(text: text),
                if (required)
                  const TextSpan(
                      text: ' *',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );

    InputDecoration inputDecoration(String hint,
            {Widget? prefixIcon, Widget? suffixIcon}) =>
        InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: borderColor)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        );

    const gradeOptions = ['4th', '5th', '6th', '7th'];
    const subjectOptions = [
      'Mathematics',
      'Physics',
      'Chemistry',
      'SVT',
      'French',
      'Arabic',
      'English'
    ];

    void submit() {
      if (title.isEmpty || selectedClassId.isEmpty || date.isEmpty ||
          time.isEmpty || zoomLink.isEmpty) return;
      final platform = zoomLink.toLowerCase().contains('zoom')
          ? LiveSessionPlatform.zoom
          : LiveSessionPlatform.meet;
      final session = LiveSessionEntity(
        id: 'live-${DateTime.now().millisecondsSinceEpoch}',
        classId: selectedClassId,
        title: title,
        date: date,
        time: time,
        platform: platform,
        link: zoomLink,
        isActive: false,
      );
      context.read<LiveSessionsRepository>().addLiveSession(session);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(className.isEmpty
                ? lang.t('live.createSession')
                : '${lang.t('live.createSession')} — $className')));
        Navigator.pop(context);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.sizeOf(ctx).width;
        final dialogWidth = (screenWidth > 420) ? 400.0 : (screenWidth - 24);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                width: dialogWidth,
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lang.t('live.createLiveSession'),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: labelColor),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close,
                              color: labelColor, size: 24),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            dialogLabel(lang.t('live.sessionTitle'),
                                required: true),
                            TextField(
                              decoration: inputDecoration(
                                  'e.g., Mathematics Q&A Session'),
                              onChanged: (v) => title = v,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      dialogLabel(lang.t('live.grade'),
                                          required: true),
                                      DropdownButtonFormField<String>(
                                        value: grade.isEmpty
                                            ? null
                                            : (gradeOptions.contains(grade)
                                                ? grade
                                                : null),
                                        decoration: inputDecoration(
                                                'Select grade')
                                            .copyWith(
                                                contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 10)),
                                        isExpanded: true,
                                        items: gradeOptions
                                            .map((g) => DropdownMenuItem(
                                                value: g,
                                                child: Text('$g Grade')))
                                            .toList(),
                                        onChanged: (v) =>
                                            setDialogState(() => grade = v ?? ''),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      dialogLabel(lang.t('live.subject'),
                                          required: true),
                                      DropdownButtonFormField<String>(
                                        value: subject.isEmpty
                                            ? null
                                            : (subjectOptions.contains(subject)
                                                ? subject
                                                : null),
                                        decoration: inputDecoration(
                                                'Select subject')
                                            .copyWith(
                                                contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 10)),
                                        isExpanded: true,
                                        items: subjectOptions
                                            .map((s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(s)))
                                            .toList(),
                                        onChanged: (v) => setDialogState(
                                            () => subject = v ?? ''),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(lang.t('live.className'),
                                required: true),
                            if (myClasses.isNotEmpty)
                              DropdownButtonFormField<String>(
                                value: selectedClassId.isEmpty
                                    ? null
                                    : selectedClassId,
                                decoration: inputDecoration(
                                        'e.g., 4th Grade - Math A')
                                    .copyWith(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10)),
                                isExpanded: true,
                                items: myClasses
                                    .map((c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ))
                                    .toList(),
                                onChanged: (v) => setDialogState(
                                    () {
                                      selectedClassId = v ?? '';
                                      if (v != null) {
                                        final c = myClasses
                                            .firstWhere((x) => x.id == v);
                                        className = c.name;
                                      }
                                    }),
                              )
                            else
                              TextField(
                                decoration: inputDecoration(
                                    'e.g., 4th Grade - Math A'),
                                onChanged: (v) {
                                  className = v;
                                  selectedClassId = 'class1';
                                },
                              ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      dialogLabel(lang.t('live.date'),
                                          required: true),
                                      TextField(
                                        decoration: inputDecoration(
                                                'dd / mm / yyyy')
                                            .copyWith(
                                                prefixIcon: Icon(
                                                    Icons.calendar_today,
                                                    size: 20,
                                                    color:
                                                        Colors.grey.shade600)),
                                        onChanged: (v) => date = v,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      dialogLabel(lang.t('live.time'),
                                          required: true),
                                      TextField(
                                        decoration: inputDecoration('--:-- --')
                                            .copyWith(
                                                suffixIcon: Icon(
                                                    Icons.schedule,
                                                    size: 20,
                                                    color:
                                                        Colors.grey.shade600)),
                                        onChanged: (v) => time = v,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            dialogLabel(lang.t('live.zoomMeetingLink'),
                                required: true),
                            TextField(
                              decoration: inputDecoration(
                                  'https://zoom.us/j/...'),
                              onChanged: (v) => zoomLink = v,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: borderColor),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          child: Text(
                            lang.t('common.cancel'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          child: Text(
                            lang.t('live.createSession'),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
