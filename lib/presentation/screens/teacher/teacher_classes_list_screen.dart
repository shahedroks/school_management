import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/repositories/teacher_classes_repository.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

class TeacherClassesListScreen extends StatefulWidget {
  const TeacherClassesListScreen({super.key});

  @override
  State<TeacherClassesListScreen> createState() =>
      _TeacherClassesListScreenState();
}

class _TeacherClassesListScreenState extends State<TeacherClassesListScreen> {
  String _gradeFilter = 'all';
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lang = context.watch<LanguageProvider>();
    final teacherId = auth.user?.id == 'demo_teacher'
        ? 'teacher1'
        : (auth.user?.id ?? 'teacher1');

    return FutureBuilder<List<ClassEntity>>(
      future: context.read<TeacherClassesRepository>().getMyClasses(teacherId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final myClasses = snapshot.data!;
        final grades = myClasses.map((c) => c.level).toSet().toList()..sort();
        final filteredClasses = _gradeFilter == 'all'
            ? myClasses
            : myClasses.where((c) => c.level == _gradeFilter).toList();
        final hasActiveFilters = _gradeFilter != 'all';

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, lang, filteredClasses.length),
              const SizedBox(height: 16),
              if (_showFilters) ...[
                _buildFiltersPanel(context, lang, grades, hasActiveFilters),
                const SizedBox(height: 16),
              ],
              _buildResultsCount(context, lang, filteredClasses.length),
              const SizedBox(height: 12),
              filteredClasses.isEmpty
                  ? _buildEmptyState(context, lang, hasActiveFilters)
                  : _buildClassesList(context, lang, filteredClasses),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider lang, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.t('classes.myClasses'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  count == 1
                      ? '1 ${lang.t('classes.assignedToYou')}'
                      : '$count ${lang.t('classes.assignedToYouPlural')}',
                  style: const TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(_showFilters ? Icons.tune : Icons.tune_outlined,
                color: Colors.white, size: 24),
            style: IconButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel(BuildContext context, LanguageProvider lang,
      List<String> grades, bool hasActiveFilters) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasActiveFilters)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _gradeFilter = 'all'),
                  child: Text(lang.t('classes.resetAll'),
                      style: const TextStyle(
                          color: AppTheme.primary, fontSize: 12)),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.school, size: 18, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(lang.t('classes.grade'),
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _gradeFilter,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: AppTheme.primary.withValues(alpha: 0.2))),
              ),
              items: [
                DropdownMenuItem(
                    value: 'all', child: Text(lang.t('classes.allGrades'))),
                ...grades
                    .map((g) => DropdownMenuItem(value: g, child: Text(g))),
              ],
              onChanged: (v) => setState(() => _gradeFilter = v ?? 'all'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCount(
      BuildContext context, LanguageProvider lang, int count) {
    final text = count == 0
        ? lang.t('classes.noClassesFound')
        : count == 1
            ? lang.t('classes.showingClass')
            : lang.t('classes.showingClasses').replaceAll('{count}', '$count');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade600)),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, LanguageProvider lang, bool hasActiveFilters) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: AppTheme.primary.withValues(alpha: 0.2), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.menu_book, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(lang.t('classes.noClassesMatchFilters'),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center),
            if (hasActiveFilters) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => setState(() => _gradeFilter = 'all'),
                style:
                    OutlinedButton.styleFrom(foregroundColor: AppTheme.primary),
                child: Text(lang.t('classes.clearFilters')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildClassesList(
      BuildContext context, LanguageProvider lang, List<ClassEntity> classes) {
    return Column(
      children: classes
          .map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.go('/teacher/classes/${c.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                            width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(c.subject,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(c.level,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.accent)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(c.schedule,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.people_outline,
                                    size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600),
                                    children: [
                                      TextSpan(
                                          text: '${c.students} ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color)),
                                      TextSpan(
                                          text: lang
                                              .t('classes.studentsEnrolled')),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
