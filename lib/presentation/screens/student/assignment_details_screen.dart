import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/assignment_entity.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class AssignmentDetailsScreen extends StatefulWidget {
  const AssignmentDetailsScreen({
    super.key,
    required this.assignmentId,
    this.passedAssignment,
  });

  final String assignmentId;
  /// When provided (e.g. from dashboard API), use this instead of fetching by id.
  final AssignmentEntity? passedAssignment;

  @override
  State<AssignmentDetailsScreen> createState() => _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState extends State<AssignmentDetailsScreen> {
  String _submissionText = '';
  String? _selectedFileName;
  bool _submitted = false;

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

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final m = int.tryParse(parts[1]);
        final d = parts[2].length > 2 ? parts[2].substring(0, 2) : parts[2];
        if (m != null && m >= 1 && m <= 12) return '${months[m - 1]} $d';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    if (widget.passedAssignment != null) {
      final a = widget.passedAssignment!;
      return FutureBuilder<List<ClassEntity>>(
        future: context.read<ClassesRepository>().getClasses(),
        builder: (context, snapshot) {
          ClassEntity? classData;
          if (snapshot.hasData) {
            try {
              classData = snapshot.data!.firstWhere((c) => c.id == a.classId);
            } catch (_) {}
          }
          return _buildContent(context, lang: lang, a: a, classData: classData);
        },
      );
    }

    return FutureBuilder(
      future: Future.wait([
        context.read<AssignmentsRepository>().getAssignmentById(widget.assignmentId),
        context.read<ClassesRepository>().getClasses(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final a = snapshot.data![0] as AssignmentEntity?;
        final classes = snapshot.data![1] as List<ClassEntity>;
        if (a == null) return Center(child: Text(lang.t('classes.classNotFound')));

        ClassEntity? classData;
        try {
          classData = classes.firstWhere((c) => c.id == a.classId);
        } catch (_) {}

        return _buildContent(context, lang: lang, a: a, classData: classData);
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required LanguageProvider lang,
    required AssignmentEntity a,
    ClassEntity? classData,
  }) {
    final daysUntilDue = _daysUntilDue(a.dueDate);
    final isOverdue = daysUntilDue < 0;
    final isUrgent = daysUntilDue <= 2 && daysUntilDue >= 0;
    final currentStatus = _submitted ? AssignmentStatus.submitted : a.status;
    final isPending = currentStatus == AssignmentStatus.pending;

    return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              if (isOverdue && isPending) _buildAlert(context, lang, isOverdue: true, assignment: a),
              if (isUrgent && isPending) _buildDueSoonAlert(context, lang, daysUntilDue),
              if (_submitted && a.status != AssignmentStatus.graded) _buildSubmittedAlert(context, lang),
              const SizedBox(height: 12),
              _buildDetailsCard(context, lang, a, classData, currentStatus, isOverdue),
              if (a.status == AssignmentStatus.graded && a.grade != null) ...[
                const SizedBox(height: 16),
                _buildGradeCard(context, lang, a),
              ],
              if (!_submitted && isPending) ...[
                const SizedBox(height: 16),
                _buildSubmissionCard(context, lang),
              ],
              if (_submitted && a.status != AssignmentStatus.graded) ...[
                const SizedBox(height: 16),
                _buildYourSubmissionCard(context, lang),
              ],
              const SizedBox(height: 24),
            ],
          ),
    );
  }

  Widget _buildAlert(BuildContext context, LanguageProvider lang, {required bool isOverdue, required AssignmentEntity assignment}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 18, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.t('assignments.overdue'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red.shade800)),
                const SizedBox(height: 2),
                Text(
                  '${lang.t('assignments.dueDate')} ${_formatDate(assignment.dueDate)}. ${lang.t('assignments.lateSubmissionsNote')}',
                  style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueSoonAlert(BuildContext context, LanguageProvider lang, int daysUntilDue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Colors.amber.shade800),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.t('assignments.dueSoon'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber.shade900)),
                const SizedBox(height: 2),
                Text(
                  '${lang.t('assignments.dueDate')} $daysUntilDue ${daysUntilDue == 1 ? 'day' : 'days'}.',
                  style: TextStyle(fontSize: 11, color: Colors.amber.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedAlert(BuildContext context, LanguageProvider lang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 18, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.t('assignments.submitted'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade900)),
                const SizedBox(height: 2),
                Text(lang.t('assignments.submittedReceived'), style: TextStyle(fontSize: 11, color: Colors.green.shade800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, LanguageProvider lang, AssignmentEntity a, ClassEntity? classData, AssignmentStatus currentStatus, bool isOverdue) {
    Color statusColor = Colors.orange;
    if (currentStatus == AssignmentStatus.graded) statusColor = AppTheme.accent;
    if (currentStatus == AssignmentStatus.submitted) statusColor = AppTheme.primary;
    if (isOverdue && currentStatus == AssignmentStatus.pending) statusColor = Colors.red;

    String statusText = currentStatus.name;
    if (statusText == 'pending') statusText = lang.t('assignments.pending').split(' ').first;
    if (statusText == 'submitted') statusText = lang.t('assignments.submitted');
    if (statusText == 'graded') statusText = lang.t('assignments.graded');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.description, size: 20, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(statusText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(a.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(a.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.t('assignments.classLabel'), style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(classData?.name ?? '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang.t('assignments.dueDate'), style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(_formatDate(a.dueDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('assignments.points'), style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('${a.points}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lang.t('assignments.statusLabel'), style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(statusText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, LanguageProvider lang, AssignmentEntity a) {
    final grade = a.grade ?? 0;
    final pct = a.points > 0 ? (grade / a.points) * 100 : 0.0;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.green.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, size: 20, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(lang.t('assignments.gradeAndFeedback'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  children: [
                    Text('$grade', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    Text('of ${a.points}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct / 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('${pct.toStringAsFixed(1)}% ${lang.t('assignments.score')}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            if (a.feedback != null && a.feedback!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.t('assignments.teachersFeedback'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                    const SizedBox(height: 6),
                    Text(a.feedback!, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, LanguageProvider lang) {
    final canSubmit = _submissionText.trim().isNotEmpty || _selectedFileName != null;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3), width: 2)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.85)], begin: Alignment.centerLeft, end: Alignment.centerRight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.upload, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(lang.t('assignments.submitAssignment'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Upload your work or write your response below', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(lang.t('assignments.uploadFile'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    setState(() => _selectedFileName = _selectedFileName == null ? 'document.pdf' : null);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.primary.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, size: 24, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(_selectedFileName != null ? lang.t('assignments.changeFile') : lang.t('assignments.chooseFile'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                      ],
                    ),
                  ),
                ),
                if (_selectedFileName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file, size: 20, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_selectedFileName!, style: TextStyle(fontSize: 12, color: Colors.blue.shade900), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.blue.shade700),
                          onPressed: () => setState(() => _selectedFileName = null),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Center(child: Text('OR', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w500))),
                const SizedBox(height: 16),
                Text(lang.t('assignments.writtenSubmission'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 6,
                  onChanged: (v) => setState(() => _submissionText = v),
                  decoration: InputDecoration(
                    hintText: 'Type your assignment response here...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: Text('${_submissionText.length} characters', style: TextStyle(fontSize: 10, color: Colors.grey.shade400))),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: canSubmit
                        ? () {
                            setState(() => _submitted = true);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lang.t('assignments.submitted'))));
                          }
                        : null,
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(lang.t('assignments.submitAssignment')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                  ),
                ),
                if (!canSubmit) ...[
                  const SizedBox(height: 8),
                  Center(child: Text(lang.t('assignments.pleaseAddFileOrResponse'), style: TextStyle(fontSize: 10, color: Colors.grey.shade500))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourSubmissionCard(BuildContext context, LanguageProvider lang) {
    final now = DateTime.now();
    final dateStr = '${now.month}/${now.day}/${now.year}';
    final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.t('assignments.mySubmission'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text('${lang.t('assignments.submittedOn')} $dateStr at $timeStr', style: TextStyle(fontSize: 12, color: Colors.blue.shade900)),
            ),
            const SizedBox(height: 12),
            Text('Your Response:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(_submissionText.isEmpty ? 'File submission only' : _submissionText, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ),
          ],
        ),
      ),
    );
  }
}
