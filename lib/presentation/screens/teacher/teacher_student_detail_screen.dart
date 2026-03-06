import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/entities/student_entity.dart';
import 'package:high_school/domain/repositories/students_repository.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/data/datasources/mock_data.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherStudentDetailScreen extends StatefulWidget {
  const TeacherStudentDetailScreen({super.key, required this.studentId});

  final String studentId;

  @override
  State<TeacherStudentDetailScreen> createState() => _TeacherStudentDetailScreenState();
}

class _TeacherStudentDetailScreenState extends State<TeacherStudentDetailScreen> {
  String _selectedClassId = 'class1';
  String _attendanceDate = '';
  String _attendanceStatus = 'present';
  final _attendanceNotes = TextEditingController();

  @override
  void initState() {
    super.initState();
    _attendanceDate = _formatDateForInput(DateTime.now());
  }

  @override
  void dispose() {
    _attendanceNotes.dispose();
    super.dispose();
  }

  String _formatDateForInput(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: Future.wait([
        context.read<StudentsRepository>().getStudentById(widget.studentId),
        context.read<ClassesRepository>().getClasses(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final student = (snapshot.data![0] as StudentEntity?);
        final allClasses = (snapshot.data![1] as List<ClassEntity>);
        if (student == null) {
          return _buildNotFound(context, lang);
        }
        final studentClassIds = MockData.studentSubscriptions
            .where((s) => s.studentId == widget.studentId)
            .map((s) => s.enrolledClassIds)
            .expand((e) => e)
            .toSet()
            .toList();
        if (studentClassIds.isEmpty) studentClassIds.addAll(['class1', 'class2']);
        final studentClasses = allClasses.where((c) => studentClassIds.contains(c.id)).toList();
        if (studentClasses.isNotEmpty && !studentClassIds.contains(_selectedClassId)) {
          _selectedClassId = studentClasses.first.id;
        }
        final attendanceRecords = MockData.attendanceRecords
            .where((a) => a.studentId == widget.studentId && a.classId == _selectedClassId)
            .toList();
        StudentProgressData? progressData;
        try {
          progressData = MockData.studentProgressList.firstWhere((p) => p.studentId == widget.studentId && p.classId == _selectedClassId);
        } catch (_) {}
        if (progressData == null) {
          progressData = StudentProgressData(
            studentId: widget.studentId,
            classId: _selectedClassId,
            overallGrade: student.grade,
            assignmentsCompleted: 0,
            assignmentsTotal: 0,
            present: 0,
            absent: 0,
            late: 0,
            total: 0,
            lastActivity: DateTime.now().toIso8601String(),
          );
        }
        final classAssignments = MockData.assignments.where((a) => a.classId == _selectedClassId).toList();
        final studentSubmissionsList = MockData.submissions.where((s) => s.studentId == widget.studentId).toList();

        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, lang, student),
                const SizedBox(height: 16),
                _buildClassSelector(context, lang, studentClasses),
                const SizedBox(height: 16),
                _buildPerformanceOverview(context, lang, progressData),
                const SizedBox(height: 16),
                _buildAttendanceTracking(context, lang, progressData, attendanceRecords),
                const SizedBox(height: 16),
                _buildAssignmentProgress(context, lang, classAssignments, studentSubmissionsList),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotFound(BuildContext context, LanguageProvider lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
            child: Text(lang.t('students.studentNotFound'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Text(lang.t('students.studentNotFoundMessage'), style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/teacher/students'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                    child: Text(lang.t('students.backToStudents')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider lang, StudentEntity student) {
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
            onPressed: () => context.go('/teacher/students'),
            icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
            label: Text(lang.t('students.backToStudents'), style: const TextStyle(color: Colors.white, fontSize: 14)),
            style: TextButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.2), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  student.name.split(' ').map((s) => s.isNotEmpty ? s[0] : '').join('').toUpperCase(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                        const SizedBox(width: 6),
                        Expanded(child: Text(student.email, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector(BuildContext context, LanguageProvider lang, List<ClassEntity> studentClasses) {
    if (studentClasses.isEmpty) return const SizedBox.shrink();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('students.selectClass'), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedClassId,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
              ),
              items: studentClasses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedClassId = v ?? _selectedClassId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverview(BuildContext context, LanguageProvider lang, StudentProgressData progress) {
    final attendancePct = progress.total > 0 ? ((progress.present / progress.total) * 100).round() : 0;
    final assignmentPct = progress.assignmentsTotal > 0 ? ((progress.assignmentsCompleted / progress.assignmentsTotal) * 100).round() : 0;
    String lastActivityStr = progress.lastActivity;
    try {
      final d = DateTime.parse(progress.lastActivity);
      lastActivityStr = '${_monthShort(d.month)} ${d.day}, ${d.year}';
    } catch (_) {}
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang.t('students.performanceOverview'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _progressRow(context, lang.t('students.overallGrade'), '${progress.overallGrade}%', progress.overallGrade / 100),
                const SizedBox(height: 16),
                _progressRow(context, lang.t('students.assignmentCompletion'), '${progress.assignmentsCompleted}/${progress.assignmentsTotal}', assignmentPct / 100),
                const SizedBox(height: 16),
                _progressRow(context, lang.t('analytics.attendanceRate'), '$attendancePct%', attendancePct / 100),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(lang.t('students.lastActivity'), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(lastActivityStr, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthShort(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  Widget _progressRow(BuildContext context, String label, String trailing, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, maxLines: 1)),
            const SizedBox(width: 8),
            if (label.contains('Grade')) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.secondary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3))),
              child: Text(trailing, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.secondary)),
            ) else Text(trailing, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: value.clamp(0.0, 1.0), backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary)),
      ],
    );
  }

  Widget _buildAttendanceTracking(BuildContext context, LanguageProvider lang, StudentProgressData progress, List<AttendanceRecord> records) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                Icon(Icons.how_to_reg, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang.t('students.attendanceTracking'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _showMarkAttendanceDialog(context),
                  style: TextButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 14),
                      const SizedBox(width: 4),
                      Text(lang.t('students.mark'), style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _attendanceChip(context, Icons.check_circle, '${progress.present}', lang.t('students.present'), AppTheme.accent)),
                    const SizedBox(width: 4),
                    Expanded(child: _attendanceChip(context, Icons.cancel, '${progress.absent}', lang.t('students.absent'), Colors.red)),
                    const SizedBox(width: 4),
                    Expanded(child: _attendanceChip(context, Icons.schedule, '${progress.late}', lang.t('students.late'), Colors.amber)),
                    const SizedBox(width: 4),
                    Expanded(child: _attendanceChip(context, Icons.calendar_today, '${progress.total}', 'Total', AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(lang.t('students.recentRecords'), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (records.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: Text(lang.t('students.noAttendanceRecords'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                  )
                else
                  ...records.take(5).map((r) => _attendanceRecordTile(context, r)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceChip(BuildContext context, IconData icon, String value, String label, Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 2),
              Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600, fontSize: 9), overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }

  Widget _attendanceRecordTile(BuildContext context, AttendanceRecord r) {
    IconData icon = Icons.check_circle;
    Color color = AppTheme.accent;
    if (r.status == 'absent') { icon = Icons.cancel; color = Colors.red; }
    else if (r.status == 'late') { icon = Icons.schedule; color = Colors.amber; }
    else if (r.status == 'excused') { icon = Icons.warning_amber; color = AppTheme.primary; }
    String dateStr = r.date;
    try {
      final d = DateTime.parse(r.date);
      dateStr = '${_monthShort(d.month)} ${d.day}, ${d.year}';
    } catch (_) {}
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.status[0].toUpperCase() + r.status.substring(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(dateStr, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (r.notes != null && r.notes!.isNotEmpty)
              Expanded(child: Text(r.notes!, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentProgress(BuildContext context, LanguageProvider lang, List<AssignmentEntity> classAssignments, List<SubmissionEntity> studentSubmissions) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            child: Row(
              children: [
                Icon(Icons.assignment, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(lang.t('students.assignmentProgress'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: classAssignments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(lang.t('students.noAssignmentsForClass'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                  )
                : Column(
                    children: classAssignments.map<Widget>((a) {
                      SubmissionEntity? sub;
                      try {
                        sub = studentSubmissions.firstWhere((s) => s.assignmentId == a.id);
                      } catch (_) {}
                      final hasSubmitted = sub != null;
                      final isGraded = sub != null && sub.status == 'graded';
                      String badgeText;
                      Color badgeColor;
                      if (isGraded) {
                        badgeText = '${sub.grade ?? 0}/${a.points}';
                        badgeColor = AppTheme.secondary;
                      } else if (hasSubmitted) {
                        badgeText = lang.t('students.submitted');
                        badgeColor = AppTheme.accent;
                      } else {
                        badgeText = lang.t('students.pending');
                        badgeColor = Colors.red;
                      }
                      String dueStr = a.dueDate;
                      try {
                        final d = DateTime.parse(a.dueDate);
                        dueStr = '${_monthShort(d.month)} ${d.day}';
                      } catch (_) {}
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)), borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(a.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6), border: Border.all(color: badgeColor.withValues(alpha: 0.3))),
                                    child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: badgeColor)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text('${lang.t('students.due')}: $dueStr', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  const SizedBox(width: 8),
                                  Text('${a.points} ${lang.t('students.pts')}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                ],
                              ),
                              if (sub?.feedback != null && sub!.feedback!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1))),
                                  child: Text.rich(
                                    TextSpan(
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                      children: [
                                        TextSpan(text: '${lang.t('students.feedback')}: ', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                                        TextSpan(text: sub.feedback ?? ''),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
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

  void _showMarkAttendanceDialog(BuildContext context) {
    final lang = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(lang.t('students.markAttendance')),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: _attendanceDate,
                    onChanged: (v) => _attendanceDate = v,
                    decoration: const InputDecoration(hintText: 'YYYY-MM-DD'),
                  ),
                  const SizedBox(height: 12),
                  Text('Status', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _attendanceStatus,
                    items: [
                      DropdownMenuItem(value: 'present', child: Text(lang.t('students.present'))),
                      DropdownMenuItem(value: 'absent', child: Text(lang.t('students.absent'))),
                      DropdownMenuItem(value: 'late', child: Text(lang.t('students.late'))),
                      DropdownMenuItem(value: 'excused', child: Text(lang.t('students.excused'))),
                    ],
                    onChanged: (v) => setDialogState(() => _attendanceStatus = v ?? _attendanceStatus),
                  ),
                  const SizedBox(height: 12),
                  Text(lang.t('students.notesOptional'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _attendanceNotes,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Add any notes...'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(lang.t('common.cancel')),
              ),
              FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attendance marked as $_attendanceStatus for $_attendanceDate')));
                  Navigator.of(ctx).pop();
                },
                child: Text(lang.t('students.saveAttendance')),
              ),
            ],
          );
        },
      ),
    );
  }
}

