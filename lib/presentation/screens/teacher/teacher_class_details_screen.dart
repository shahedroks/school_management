import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/entities/lesson_entity.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
import 'package:high_school/domain/entities/student_entity.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/domain/repositories/teacher_classes_repository.dart';
import 'package:high_school/domain/repositories/lessons_repository.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/domain/repositories/students_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherClassDetailsScreen extends StatefulWidget {
  const TeacherClassDetailsScreen({super.key, required this.classId});

  final String classId;

  @override
  State<TeacherClassDetailsScreen> createState() => _TeacherClassDetailsScreenState();
}

class _TeacherClassDetailsScreenState extends State<TeacherClassDetailsScreen> {
  int _tabIndex = 0;
  int _refreshKey = 0;
  List<AssignmentEntity> _localAssignments = [];

  Future<Map<String, dynamic>> _loadData() async {
    final teacherClassesRepo = context.read<TeacherClassesRepository>();
    final lessonsRepo = context.read<LessonsRepository>();
    final assignmentsRepo = context.read<AssignmentsRepository>();
    final studentsRepo = context.read<StudentsRepository>();
    final liveRepo = context.read<LiveSessionsRepository>();

    final results = await Future.wait([
      teacherClassesRepo.getClassById(widget.classId),
      lessonsRepo.getLessons(classId: widget.classId),
      assignmentsRepo.getAssignments(classId: widget.classId),
      studentsRepo.getStudents(classId: widget.classId),
      liveRepo.getLiveSessions(),
    ]);

    final cls = results[0] as ClassEntity?;
    final lessons = (results[1] as List).cast<LessonEntity>();
    final assignments = (results[2] as List).cast<AssignmentEntity>();
    final students = (results[3] as List).cast<StudentEntity>();
    final allSessions = (results[4] as List).cast<LiveSessionEntity>();
    final liveSessions = allSessions.where((s) => s.classId == widget.classId).toList();

    return {
      'class': cls,
      'lessons': lessons,
      'assignments': assignments,
      'students': students,
      'liveSessions': liveSessions,
    };
  }

  static String _formatDate(String dateStr) {
    try {
      final d = DateTime.tryParse(dateStr);
      if (d != null) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[d.month - 1]} ${d.day}';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder<Map<String, dynamic>>(
      key: ValueKey(_refreshKey),
      future: _loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        final cls = data['class'] as ClassEntity?;
        final lessons = data['lessons'] as List<LessonEntity>;
        final students = data['students'] as List<StudentEntity>;
        final liveSessions = data['liveSessions'] as List<LiveSessionEntity>;

        if (cls == null) {
          return Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(lang.t('classes.classNotFound')),
              ),
            ),
          );
        }

        // One-time init of local assignments from repo
        final repoAssignments = data['assignments'] as List<AssignmentEntity>;
        if (_localAssignments.isEmpty && repoAssignments.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _localAssignments = List.from(repoAssignments));
          });
        }
        final assignmentsToShow = _localAssignments.isNotEmpty ? _localAssignments : repoAssignments;

        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, lang, cls),
                const SizedBox(height: 16),
                _buildTabs(context, lang),
                const SizedBox(height: 12),
                IndexedStack(
                  index: _tabIndex,
                  children: [
                    _buildLessonsTab(context, lang, cls, lessons),
                    _buildAssignmentsTab(context, lang, cls, assignmentsToShow),
                    _buildStudentsTab(context, lang, students),
                    _buildLiveTab(context, lang, liveSessions),
                    _buildAnalyticsTab(context, lang, cls, lessons, assignmentsToShow, liveSessions),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider lang, ClassEntity cls) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/teacher/classes'),
            icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
            label: Text(tr(lang, 'classes.backToClasses', 'Back to Classes'), style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          const SizedBox(height: 8),
          Text(cls.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(tr(lang, 'teacherClassDetails.manageSubtitle', 'Manage lessons, assignments, and students'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14)),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.3)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 8),
              Text(cls.schedule, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.people, size: 14, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 8),
              Text('${cls.students} ${tr(lang, 'teacherClassDetails.studentsEnrolled', 'students enrolled')}', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  String tr(LanguageProvider lang, String key, String fallback) {
    final s = lang.t(key);
    return (s == key || s.isEmpty) ? fallback : s;
  }

  Widget _buildTabs(BuildContext context, LanguageProvider lang) {
    final tabs = [
      (Icons.menu_book, tr(lang, 'lessons.lessons', 'Lessons')),
      (Icons.assignment, 'Assignments'),
      (Icons.people, tr(lang, 'classes.students', 'Students')),
      (Icons.video_call, 'Live'),
      (Icons.bar_chart, 'Analytics'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent,
                      border: Border.all(color: selected ? AppTheme.primary : Colors.transparent, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(tabs[i].$1, size: 20, color: selected ? AppTheme.primary : Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      tabs[i].$2,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: selected ? AppTheme.primary : Colors.grey.shade700),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLessonsTab(BuildContext context, LanguageProvider lang, ClassEntity cls, List<LessonEntity> lessons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${lessons.length} ${tr(lang, 'lessons.lessons', 'Lessons')}', style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
            ElevatedButton.icon(
              onPressed: () => _showCreateLessonDialog(context, lang, cls, null),
              icon: const Icon(Icons.add, size: 18),
              label: Text(tr(lang, 'teacherClassDetails.addLesson', 'Add Lesson')),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (lessons.isEmpty)
          _emptyCard(
            icon: Icons.menu_book,
            message: tr(lang, 'teacherClassDetails.noLessonsYet', 'No lessons created yet'),
          )
        else
          ...lessons.map((l) => _lessonCard(context, lang, l)),
      ],
    );
  }

  Widget _lessonCard(BuildContext context, LanguageProvider lang, LessonEntity lesson) {
    final typeStr = lesson.type == LessonType.video ? 'video' : (lesson.type == LessonType.pdf ? 'pdf' : 'text');
    // Image 2: title bold, tags (Published = light purple pill, video = light blue pill) to the right, description below, folder + Chapter below
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    lesson.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: [
                    _pillBadge(lesson.status == LessonStatus.published ? tr(lang, 'teacherClassDetails.published', 'Published') : tr(lang, 'teacherClassDetails.draft', 'Draft'), AppTheme.secondary),
                    _pillBadge(typeStr, const Color(0xFF2196F3)),
                  ],
                ),
              ],
            ),
            if (lesson.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(lesson.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            if (lesson.module != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.folder_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(lesson.module!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(_formatDate(lesson.date), style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(width: 12),
                Icon(Icons.update, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text('${tr(lang, 'common.update', 'Updated')} ${_formatDate(lesson.lastUpdated)}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  iconSize: 22,
                  onPressed: () {
                    context.read<LessonsRepository>().updateLesson(lesson.id, LessonEntity(
                      id: lesson.id,
                      classId: lesson.classId,
                      title: lesson.title,
                      description: lesson.description,
                      type: lesson.type,
                      content: lesson.content,
                      date: lesson.date,
                      duration: lesson.duration,
                      status: lesson.status == LessonStatus.published ? LessonStatus.draft : LessonStatus.published,
                      lastUpdated: DateTime.now().toIso8601String().split('T').first,
                      module: lesson.module,
                    ));
                    setState(() => _refreshKey++);
                  },
                  icon: Icon(lesson.status == LessonStatus.published ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.grey.shade700),
                ),
                IconButton(
                  iconSize: 22,
                  onPressed: () => _showCreateLessonDialog(context, lang, null, lesson),
                  icon: Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade700),
                ),
                IconButton(
                  iconSize: 22,
                  onPressed: () => _confirmDeleteLesson(context, lang, lesson),
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.red.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Text(text, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }

  void _confirmDeleteLesson(BuildContext context, LanguageProvider lang, LessonEntity lesson) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(lang, 'teacherClassDetails.deleteLesson', 'Delete Lesson')),
        content: Text('${tr(lang, 'common.confirm', 'Are you sure you want to delete')} "${lesson.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.t('common.cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<LessonsRepository>().deleteLesson(lesson.id);
              setState(() => _refreshKey++);
              Navigator.pop(ctx);
            },
            child: Text(tr(lang, 'common.delete', 'Delete')),
          ),
        ],
      ),
    );
  }

  void _showCreateLessonDialog(BuildContext context, LanguageProvider lang, ClassEntity? cls, LessonEntity? editing) {
    const labelColor = Color(0xFF1F3C88);
    const borderColor = Color(0xFFD1D5DB);

    String title = editing?.title ?? '';
    String description = editing?.description ?? '';
    String type = editing != null ? (editing.type == LessonType.video ? 'video' : (editing.type == LessonType.pdf ? 'pdf' : 'text')) : 'text';
    String module = editing?.module ?? '';
    String grade = '';
    String subject = 'Mathematics';
    String date = editing?.date ?? DateTime.now().toIso8601String().split('T').first;
    String? attachedFileName;

    Widget dialogLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor)),
    );

    InputDecoration inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );

    const gradeOptions = ['4th', '5th', '6th', '7th'];
    const subjectOptions = ['Mathematics', 'Physics', 'Chemistry', 'SVT', 'French', 'Arabic', 'English'];

    void submitLesson(LessonStatus status) {
      if (cls == null && editing == null) return;
      final lessonType = type == 'video' ? LessonType.video : (type == 'pdf' ? LessonType.pdf : LessonType.text);
      final now = DateTime.now().toIso8601String().split('T').first;
      if (editing != null) {
        context.read<LessonsRepository>().updateLesson(editing.id, LessonEntity(
          id: editing.id,
          classId: editing.classId,
          title: title,
          description: description,
          type: lessonType,
          content: editing.content,
          date: date,
          duration: editing.duration,
          status: status,
          lastUpdated: now,
          module: module.isEmpty ? null : module,
        ));
      } else {
        context.read<LessonsRepository>().addLesson(LessonEntity(
          id: 'lesson-${DateTime.now().millisecondsSinceEpoch}',
          classId: cls!.id,
          title: title,
          description: description,
          type: lessonType,
          content: '',
          date: date,
          status: status,
          lastUpdated: now,
          module: module.isEmpty ? null : module,
        ));
      }
      setState(() => _refreshKey++);
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: MediaQuery.of(ctx).size.height * 0.85),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          editing != null ? tr(lang, 'teacherClassDetails.editLesson', 'Edit Lesson') : tr(lang, 'teacherClassDetails.createLesson', 'Create New Lesson'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: labelColor),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: labelColor, size: 24),
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
                          dialogLabel(tr(lang, 'teacherClassDetails.lessonTitle', 'Lesson Title') + ' *'),
                          TextField(decoration: inputDecoration('e.g., Introduction to Algebra'), onChanged: (v) => title = v, controller: TextEditingController(text: title)),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'lessons.description', 'Description')),
                          TextField(decoration: inputDecoration('Describe the lesson content...'), maxLines: 3, onChanged: (v) => description = v, controller: TextEditingController(text: description)),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'teacherClassDetails.contentType', 'Content Type') + ' *'),
                          DropdownButtonFormField<String>(
                            value: type,
                            decoration: inputDecoration('').copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            items: ['text', 'pdf', 'video'].map((e) => DropdownMenuItem(value: e, child: Text(e == 'text' ? 'Text / PDF' : e))).toList(),
                            onChanged: (v) => setDialogState(() => type = v ?? 'text'),
                          ),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'teacherClassDetails.chapter', 'Chapter') + ' *'),
                          TextField(decoration: inputDecoration('e.g., Chapter 3: Equations'), onChanged: (v) => module = v, controller: TextEditingController(text: module)),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  dialogLabel(tr(lang, 'live.grade', 'Grade') + ' *'),
                                  DropdownButtonFormField<String>(
                                    value: grade.isEmpty ? null : (gradeOptions.contains(grade) ? grade : null),
                                    decoration: inputDecoration('Select grade').copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                                    isExpanded: true,
                                    items: gradeOptions.map((g) => DropdownMenuItem(value: g, child: Text('$g Grade'))).toList(),
                                    onChanged: (v) => setDialogState(() => grade = v ?? ''),
                                  ),
                                ]),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  dialogLabel(tr(lang, 'live.subject', 'Subject') + ' *'),
                                  DropdownButtonFormField<String>(
                                    value: subject,
                                    decoration: inputDecoration('').copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                                    isExpanded: true,
                                    items: subjectOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: (v) => setDialogState(() => subject = v ?? 'Mathematics'),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'live.date', 'Date') + ' *'),
                          TextField(
                            decoration: inputDecoration('YYYY-MM-DD').copyWith(prefixIcon: Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600)),
                            onChanged: (v) => date = v,
                            controller: TextEditingController(text: date),
                          ),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'teacherClassDetails.attachFiles', 'Attach Files')),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                border: Border.all(color: borderColor, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.upload_file, size: 36, color: labelColor),
                                  const SizedBox(height: 8),
                                  Text(
                                    attachedFileName ?? 'Click to upload PDF or documents',
                                    style: TextStyle(fontSize: 13, color: (attachedFileName ?? '').isEmpty ? Colors.grey.shade600 : labelColor),
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
                        style: OutlinedButton.styleFrom(foregroundColor: labelColor, side: const BorderSide(color: Color(0xFF90CAF9)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        child: Text(tr(lang, 'common.cancel', 'Cancel'), style: const TextStyle(fontSize: 13)),
                      ),
                      if (editing != null)
                        FilledButton(
                          onPressed: () => submitLesson(editing.status),
                          style: FilledButton.styleFrom(backgroundColor: labelColor, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                          child: Text(tr(lang, 'teacherClassDetails.updateLesson', 'Update Lesson'), style: const TextStyle(fontSize: 13)),
                        )
                      else ...[
                        OutlinedButton(
                          onPressed: () => submitLesson(LessonStatus.draft),
                          style: OutlinedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.grey.shade700, side: BorderSide(color: Colors.grey.shade400), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                          child: Text(tr(lang, 'teacherClassDetails.saveAsDraft', 'Save as Draft'), style: const TextStyle(fontSize: 12)),
                        ),
                        FilledButton(
                          onPressed: () => submitLesson(LessonStatus.published),
                          style: FilledButton.styleFrom(backgroundColor: labelColor, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                          child: Text(tr(lang, 'teacherClassDetails.createLesson', 'Create Lesson'), style: const TextStyle(fontSize: 13)),
                        ),
                      ],
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

  Widget _buildAssignmentsTab(BuildContext context, LanguageProvider lang, ClassEntity cls, List<AssignmentEntity> assignments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${assignments.length} ${tr(lang, 'assignments.assignments', 'assignments')}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ElevatedButton.icon(
              onPressed: () => _showCreateAssignmentDialog(context, lang, cls),
              icon: const Icon(Icons.add, size: 16),
              label: Text(tr(lang, 'teacherClassDetails.createAssignment', 'Create Assignment')),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), backgroundColor: AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (assignments.isEmpty)
          _emptyCard(
            icon: Icons.assignment,
            message: tr(lang, 'teacherClassDetails.noAssignmentsYet', 'No assignments created yet'),
          )
        else
          ...assignments.map((a) => _assignmentCard(context, lang, a)),
      ],
    );
  }

  Widget _assignmentCard(BuildContext context, LanguageProvider lang, AssignmentEntity a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      if (a.description.isNotEmpty) const SizedBox(height: 4),
                      if (a.description.isNotEmpty) Text(a.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                _badge('${a.points} pts', AppTheme.primary),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [Icon(Icons.calendar_today, size: 12, color: AppTheme.primary), const SizedBox(width: 4), Text('${tr(lang, 'assignments.dueDate', 'Due')}: ${_formatDate(a.dueDate)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/teacher/assignments/${a.id}'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                    child: Text(tr(lang, 'teacherClassDetails.viewSubmissions', 'View Submissions')),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(iconSize: 20, onPressed: () => _showCreateAssignmentDialog(context, lang, null, a), icon: const Icon(Icons.edit, size: 18)),
                IconButton(iconSize: 20, onPressed: () => _deleteAssignment(a), icon: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAssignment(AssignmentEntity a) {
    setState(() {
      _localAssignments.removeWhere((x) => x.id == a.id);
    });
  }

  void _showCreateAssignmentDialog(BuildContext context, LanguageProvider lang, ClassEntity? cls, [AssignmentEntity? editing]) {
    const labelColor = Color(0xFF1F3C88);
    const borderColor = Color(0xFFD1D5DB);

    String title = editing?.title ?? '';
    String description = editing?.description ?? '';
    String dueDate = editing?.dueDate ?? '';
    String dueTime = '';
    String points = editing?.points.toString() ?? '';
    String? attachedFileName;
    final parentSetState = setState;

    Widget dialogLabel(String text, {bool required = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor),
          children: [
            TextSpan(text: text),
            if (required) const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );

    InputDecoration inputDecoration(String hint, {Widget? prefixIcon, Widget? suffixIcon}) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );

    void submit() {
      final pts = int.tryParse(points) ?? 0;
      if (editing != null) {
        parentSetState(() {
          final i = _localAssignments.indexWhere((x) => x.id == editing.id);
          if (i >= 0) _localAssignments[i] = AssignmentEntity(id: editing.id, classId: editing.classId, title: title, description: description, dueDate: dueDate, points: pts, status: editing.status, grade: editing.grade, feedback: editing.feedback);
        });
      } else if (cls != null) {
        parentSetState(() {
          _localAssignments.add(AssignmentEntity(id: 'assign-${DateTime.now().millisecondsSinceEpoch}', classId: cls.id, title: title, description: description, dueDate: dueDate, points: pts, status: AssignmentStatus.pending));
        });
      }
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(maxWidth: dialogWidth, maxHeight: MediaQuery.of(ctx).size.height * 0.85),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          editing != null ? tr(lang, 'teacherClassDetails.editAssignment', 'Edit Assignment') : tr(lang, 'teacherClassDetails.createAssignment', 'Create New Assignment'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: labelColor),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: labelColor, size: 24),
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
                          dialogLabel(tr(lang, 'teacherClassDetails.assignmentTitle', 'Assignment Title'), required: true),
                          TextField(decoration: inputDecoration('e.g., Math Homework'), onChanged: (v) => title = v, controller: TextEditingController(text: title)),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'lessons.description', 'Description')),
                          TextField(decoration: inputDecoration('Describe the assignment content...'), maxLines: 3, onChanged: (v) => description = v, controller: TextEditingController(text: description)),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'assignments.dueDate', 'Due Date'), required: true),
                          TextField(
                            decoration: inputDecoration('Pick a date', prefixIcon: Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600)),
                            onChanged: (v) => dueDate = v,
                            controller: TextEditingController(text: dueDate),
                          ),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'teacherClassDetails.dueTime', 'Due Time')),
                          TextField(
                            decoration: inputDecoration('--:-- --', suffixIcon: Icon(Icons.schedule, size: 20, color: Colors.grey.shade600)),
                            onChanged: (v) => dueTime = v,
                            controller: TextEditingController(text: dueTime),
                          ),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'assignments.points', 'Points'), required: true),
                          TextField(decoration: inputDecoration('e.g., 100'), keyboardType: TextInputType.number, onChanged: (v) => points = v, controller: TextEditingController(text: points)),
                          const SizedBox(height: 12),
                          dialogLabel(tr(lang, 'teacherClassDetails.attachFiles', 'Attach Files')),
                          DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(8),
                            dashPattern: const [6, 4],
                            color: borderColor,
                            strokeWidth: 2,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Column(
                                  children: [
                                    Icon(Icons.upload_file, size: 36, color: labelColor),
                                    const SizedBox(height: 8),
                                    Text(
                                      attachedFileName ?? 'Click to upload PDF or documents',
                                      style: TextStyle(fontSize: 13, color: (attachedFileName ?? '').isEmpty ? Colors.grey.shade600 : labelColor),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
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
                        style: OutlinedButton.styleFrom(foregroundColor: labelColor, backgroundColor: Colors.grey.shade100, side: BorderSide(color: borderColor), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                        child: Text(tr(lang, 'common.cancel', 'Cancel'), style: const TextStyle(fontSize: 13)),
                      ),
                      FilledButton(
                        onPressed: submit,
                        style: FilledButton.styleFrom(backgroundColor: labelColor, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                        child: Text(editing != null ? tr(lang, 'common.update', 'Update') : tr(lang, 'teacherClassDetails.createAssignment', 'Create Assignment'), style: const TextStyle(fontSize: 13)),
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

  Widget _buildStudentsTab(BuildContext context, LanguageProvider lang, List<StudentEntity> students) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${students.length} ${tr(lang, 'teacherClassDetails.studentsEnrolled', 'students enrolled')}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        ...students.asMap().entries.map((e) {
          final s = e.value;
          final grade = 85 + (e.key % 15);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppTheme.primary.withValues(alpha: 0.15), child: Text((s.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()).toUpperCase(), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600))),
              title: Text(s.name),
              subtitle: Text(s.email, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              trailing: _badge('$grade%', AppTheme.secondary),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLiveTab(BuildContext context, LanguageProvider lang, List<LiveSessionEntity> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${sessions.length} session${sessions.length != 1 ? 's' : ''}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          _emptyCard(
            icon: Icons.video_call,
            message: tr(lang, 'live.noUpcomingSessions', 'No live sessions scheduled'),
            subtitle: 'Schedule video calls with your students',
          )
        else
          ...sessions.map((s) {
            final platformStr = s.platform == LiveSessionPlatform.zoom ? 'Zoom' : 'Meet';
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(s.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                        if (s.isActive) _badge('Live Now', Colors.red),
                        _badge(platformStr, Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(children: [Icon(Icons.calendar_today, size: 12, color: AppTheme.primary), const SizedBox(width: 4), Text(_formatDate(s.date), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)), const SizedBox(width: 8), Icon(Icons.schedule, size: 12, color: AppTheme.primary), const SizedBox(width: 4), Text(s.time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async { try { await launchUrl(Uri.parse(s.link), mode: LaunchMode.externalApplication); } catch (_) {} },
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: Text(tr(lang, 'live.joinSession', 'Join Session')),
                        style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, LanguageProvider lang, ClassEntity cls, List<LessonEntity> lessons, List<AssignmentEntity> assignments, List<LiveSessionEntity> liveSessions) {
    const avgGrade = 87;
    const attendanceRate = 95;
    const completionRate = 92;
    final totalStudents = cls.students;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _statCard('Avg. Grade', '$avgGrade%', Icons.trending_up, AppTheme.secondary, '+3% from last month'),
            _statCard('Attendance', '$attendanceRate%', Icons.people, AppTheme.primary, '+2% from last month'),
            _statCard('Completion', '$completionRate%', Icons.assignment, AppTheme.accent, '+5% from last month'),
            _statCard('Students', '$totalStudents', Icons.emoji_events, AppTheme.primary, 'Enrolled this semester'),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(lang, 'teacherClassDetails.contentOverview', 'Content Overview'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _overviewRow(Icons.menu_book, tr(lang, 'lessons.lessons', 'Lessons'), lessons.length),
                _overviewRow(Icons.assignment, tr(lang, 'assignments.assignments', 'Assignments'), assignments.length),
                _overviewRow(Icons.video_call, 'Live Sessions', liveSessions.length),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.primary.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 20, backgroundColor: AppTheme.primary.withValues(alpha: 0.15), child: Icon(Icons.bar_chart, color: AppTheme.primary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(lang, 'teacherClassDetails.performanceInsight', 'Performance Insight'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Your class is performing ${avgGrade >= 85 ? 'excellently' : 'well'} with an average grade of $avgGrade%. Keep up the great work!', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                CircleAvatar(radius: 16, backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, size: 18, color: color)),
              ],
            ),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(children: [Icon(Icons.trending_up, size: 12, color: AppTheme.secondary), const SizedBox(width: 4), Expanded(child: Text(subtitle, style: TextStyle(fontSize: 10, color: AppTheme.secondary), overflow: TextOverflow.ellipsis))]),
          ],
        ),
      ),
    );
  }

  Widget _overviewRow(IconData icon, String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, size: 18, color: AppTheme.primary), const SizedBox(width: 8), Text(label, style: const TextStyle(fontSize: 14))]),
          _badge('$count', AppTheme.primary),
        ],
      ),
    );
  }

  Widget _emptyCard({required IconData icon, required String message, String? subtitle}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
            if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), textAlign: TextAlign.center)],
          ],
        ),
      ),
    );
  }
}
