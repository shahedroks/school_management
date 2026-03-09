import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/domain/entities/class_entity.dart';
import 'package:high_school/domain/entities/live_session_entity.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/presentation/providers/language_provider.dart';

// Reference colors from design: dark blue header, green for live cards, red for LIVE/delete
const Color _liveGreen = Color(0xFF4CAF50);
const Color _liveGreenMuted = Color(0xFF66BB6A);
const Color _liveRed = Color(0xFFE53935);
const Color _liveRedLight = Color(0xFFFFCDD2);
const Color _zoomBlueBg = Color(0xFFE3F2FD);
const Color _zoomBlueText = Color(0xFF2196F3);

class TeacherLiveSessionsScreen extends StatefulWidget {
  const TeacherLiveSessionsScreen({super.key});

  @override
  State<TeacherLiveSessionsScreen> createState() => _TeacherLiveSessionsScreenState();
}

class _TeacherLiveSessionsScreenState extends State<TeacherLiveSessionsScreen> {

  static String _formatDate(String dateStr) {
    try {
      final d = DateTime.tryParse(dateStr);
      if (d != null) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[d.month - 1]} ${d.day}, ${d.year}';
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return FutureBuilder(
      future: Future.wait([
        context.read<LiveSessionsRepository>().getLiveSessions(),
        context.read<ClassesRepository>().getClasses(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final sessions = (snapshot.data![0] as List).cast<LiveSessionEntity>();
        final classes = (snapshot.data![1] as List).cast<ClassEntity>();
        final liveSessions = sessions.where((s) => s.isActive).toList();
        final upcomingSessions = sessions.where((s) => !s.isActive).toList();

        ClassEntity? classFor(LiveSessionEntity s) {
          try {
            return classes.firstWhere((c) => c.id == s.classId);
          } catch (_) {
            return null;
          }
        }

        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, lang),
                const SizedBox(height: 16),
                if (liveSessions.isNotEmpty) ...[
                  _buildSectionTitle(context, lang.t('live.activeNow'), liveSessions.length, isLive: true),
                  const SizedBox(height: 8),
                  ...liveSessions.map((s) => _buildSessionCard(context, lang, s, classFor(s), isLive: true)),
                  const SizedBox(height: 20),
                ],
                _buildSectionTitle(context, lang.t('live.upcomingSessions'), upcomingSessions.length, isLive: false),
                const SizedBox(height: 8),
                if (upcomingSessions.isEmpty)
                  _buildEmptyUpcoming(context, lang)
                else
                  ...upcomingSessions.map((s) => _buildSessionCard(context, lang, s, classFor(s), isLive: false)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, LanguageProvider lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang.t('live.liveSessions'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.none), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(lang.t('live.manageVirtualClasses'), style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, decoration: TextDecoration.none), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ElevatedButton.icon(
            onPressed: () => _showCreateSessionDialog(context, lang),
            icon: const Icon(Icons.add, size: 18),
            label: Text(lang.t('live.create')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, int count, {required bool isLive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (isLive) ...[
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: _liveGreen, shape: BoxShape.circle)),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text('$title ($count)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF424242)), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildEmptyUpcoming(BuildContext context, LanguageProvider lang) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.video_call, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(lang.t('live.noUpcomingSessions'), style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, LanguageProvider lang, LiveSessionEntity session, ClassEntity? cls, {required bool isLive}) {
    // Active cards: dark green header; Upcoming: dark blue (primary)
    final headerColor = isLive ? _liveGreen : AppTheme.primary;
    final iconColor = isLive ? _liveGreenMuted : AppTheme.primary;
    final platformStr = session.platform == LiveSessionPlatform.zoom ? 'Zoom' : 'Google Meet';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: headerColor,
            child: Row(
              children: [
                const Icon(Icons.video_call, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(session.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: const BoxDecoration(color: _liveRed, borderRadius: BorderRadius.all(Radius.circular(4))),
                    child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cls != null) ...[
                  Row(
                    children: [
                      Icon(Icons.school, size: 14, color: iconColor),
                      const SizedBox(width: 6),
                      Flexible(child: Text('${cls.level}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Icon(Icons.menu_book, size: 14, color: iconColor),
                      const SizedBox(width: 6),
                      Expanded(child: Text(cls.subject, style: TextStyle(fontSize: 12, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: iconColor),
                      const SizedBox(width: 6),
                      Expanded(child: Text(cls.name, style: TextStyle(fontSize: 12, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: iconColor),
                    const SizedBox(width: 6),
                    Flexible(child: Text(_formatDate(session.date), style: TextStyle(fontSize: 12, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Icon(Icons.schedule, size: 14, color: iconColor),
                    const SizedBox(width: 6),
                    Flexible(child: Text(session.time, style: TextStyle(fontSize: 12, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: _zoomBlueBg, borderRadius: BorderRadius.circular(4), border: Border.all(color: _zoomBlueText.withValues(alpha: 0.3))),
                      child: Text(platformStr, style: const TextStyle(fontSize: 10, color: _zoomBlueText, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (isLive) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchUrl(session.link),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: Text(lang.t('live.startSession')),
                          style: ElevatedButton.styleFrom(backgroundColor: _liveGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 10)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      onPressed: () => _confirmDelete(context, lang, session.title),
                      icon: const Icon(Icons.delete_outline, size: 22, color: _liveRed),
                      style: IconButton.styleFrom(backgroundColor: _liveRedLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _confirmDelete(BuildContext context, LanguageProvider lang, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "$title"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(lang.t('common.cancel'))),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Session "$title" has been deleted.')));
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateSessionDialog(BuildContext context, LanguageProvider lang) {
    const labelColor = Color(0xFF374151);
    const borderColor = Color(0xFFD1D5DB);

    // Use translation with fallback so we never show raw keys (e.g. "live.createLiveSession")
    String tr(String key, String fallback) {
      final s = lang.t(key);
      return (s == key || s.isEmpty) ? fallback : s;
    }

    String sessionTitle = '';
    String grade = '';
    String subject = '';
    String className = '';
    String date = '';
    String time = '';
    String meetingLink = '';

    Widget requiredLabel(String text) {
      return Text.rich(
        TextSpan(
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor),
          children: [TextSpan(text: '$text '), const TextSpan(text: '*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600))],
        ),
      );
    }

    InputDecoration inputDecoration(String hint, {Widget? suffixIcon}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        suffixIcon: suffixIcon,
      );
    }

    const gradeOptions = ['4th', '5th', '6th', '7th'];
    const subjectOptions = ['Math', 'Physics', 'Chemistry', 'SVT', 'French', 'Arabic', 'English', 'Modern Skills'];

    showDialog(
      context: context,
      builder: (ctx) {
        final screenWidth = MediaQuery.sizeOf(ctx).width;
        final dialogWidth = (screenWidth > 420) ? 400.0 : (screenWidth - 24);
        return StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: dialogWidth,
              constraints: BoxConstraints(maxWidth: dialogWidth),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tr('live.createLiveSession', 'Create Live Session'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close, color: AppTheme.primary, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    requiredLabel(tr('live.sessionTitle', 'Session Title')),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: inputDecoration(tr('live.sessionTitlePlaceholder', 'e.g., Mathematics Q&A Session')),
                      onChanged: (v) => sessionTitle = v,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              requiredLabel(tr('live.grade', 'Grade')),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: grade.isEmpty ? null : (gradeOptions.contains(grade) ? grade : null),
                                decoration: InputDecoration(
                                  hintText: tr('live.selectGrade', 'Select grade'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                isExpanded: true,
                                items: gradeOptions.map((g) => DropdownMenuItem(value: g, child: Text('$g Grade', overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (v) => setState(() => grade = v ?? ''),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              requiredLabel(tr('live.subject', 'Subject')),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: subject.isEmpty ? null : (subjectOptions.contains(subject) ? subject : null),
                                decoration: InputDecoration(
                                  hintText: tr('live.selectSubject', 'Select subject'),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderColor)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                isExpanded: true,
                                items: subjectOptions.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                                onChanged: (v) => setState(() => subject = v ?? ''),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    requiredLabel(tr('live.className', 'Class Name')),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: inputDecoration(tr('live.classPlaceholder', 'e.g., Grade 10 - Mathematics A')),
                      onChanged: (v) => className = v,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              requiredLabel(tr('live.date', 'Date')),
                              const SizedBox(height: 4),
                              TextField(
                                decoration: inputDecoration(tr('live.datePlaceholder', 'dd / mm / yyyy'), suffixIcon: Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade500)),
                                onChanged: (v) => date = v,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              requiredLabel(tr('live.time', 'Time')),
                              const SizedBox(height: 4),
                              TextField(
                                decoration: inputDecoration(tr('live.timePlaceholder', '-- : -- --'), suffixIcon: Icon(Icons.schedule, size: 20, color: Colors.grey.shade500)),
                                onChanged: (v) => time = v,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    requiredLabel(tr('live.zoomMeetingLink', 'Zoom Meeting Link')),
                    const SizedBox(height: 4),
                    TextField(
                      decoration: inputDecoration('https://zoom.us/j/...'),
                      onChanged: (v) => meetingLink = v,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: labelColor,
                            side: const BorderSide(color: borderColor),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: Text(tr('common.cancel', 'Cancel')),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FilledButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              final msg = 'Session created: $sessionTitle${className.isNotEmpty ? ' – $className' : ''}${grade.isNotEmpty || subject.isNotEmpty ? ' ($grade $subject)' : ''}. ${date.isNotEmpty ? '$date at $time. ' : ''}${meetingLink.isNotEmpty ? 'Link: $meetingLink' : ''}';
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                            },
                            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            child: Text(tr('live.createSession', 'Create Session'), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      },
    );
  }
}
