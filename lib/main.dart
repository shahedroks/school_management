import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:high_school/core/theme/app_theme.dart';
import 'package:high_school/core/router/app_router.dart';
import 'package:high_school/domain/repositories/auth_repository.dart';
import 'package:high_school/domain/repositories/classes_repository.dart';
import 'package:high_school/domain/repositories/lessons_repository.dart';
import 'package:high_school/domain/repositories/assignments_repository.dart';
import 'package:high_school/domain/repositories/students_repository.dart';
import 'package:high_school/domain/repositories/timetable_repository.dart';
import 'package:high_school/domain/repositories/live_sessions_repository.dart';
import 'package:high_school/domain/repositories/notifications_repository.dart';
import 'package:high_school/domain/repositories/subscription_repository.dart';
import 'package:high_school/data/repositories/auth_repository_impl.dart';
import 'package:high_school/data/repositories/classes_repository_impl.dart';
import 'package:high_school/data/repositories/lessons_repository_impl.dart';
import 'package:high_school/data/repositories/assignments_repository_impl.dart';
import 'package:high_school/data/repositories/students_repository_impl.dart';
import 'package:high_school/data/repositories/timetable_repository_impl.dart';
import 'package:high_school/data/repositories/live_sessions_repository_impl.dart';
import 'package:high_school/data/repositories/notifications_repository_impl.dart';
import 'package:high_school/data/repositories/subscription_repository_impl.dart';
import 'package:high_school/presentation/providers/auth_provider.dart';
import 'package:high_school/presentation/providers/language_provider.dart';
import 'package:high_school/presentation/providers/subscription_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Repositories
  final AuthRepository authRepo = AuthRepositoryImpl(prefs);
  final ClassesRepository classesRepo = ClassesRepositoryImpl();
  final LessonsRepository lessonsRepo = LessonsRepositoryImpl();
  final AssignmentsRepository assignmentsRepo = AssignmentsRepositoryImpl();
  final StudentsRepository studentsRepo = StudentsRepositoryImpl();
  final TimetableRepository timetableRepo = TimetableRepositoryImpl();
  final LiveSessionsRepository liveSessionsRepo = LiveSessionsRepositoryImpl();
  final NotificationsRepository notificationsRepo = NotificationsRepositoryImpl();
  final SubscriptionRepository subscriptionRepo = SubscriptionRepositoryImpl(prefs);

  // Providers
  final authProvider = AuthProvider(authRepo);
  final languageProvider = LanguageProvider(prefs);
  final subscriptionProvider = SubscriptionProvider(subscriptionRepo);

  final router = await AppRouter.createRouter();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<LanguageProvider>.value(value: languageProvider),
        ChangeNotifierProvider<SubscriptionProvider>.value(value: subscriptionProvider),
        Provider<ClassesRepository>.value(value: classesRepo),
        Provider<LessonsRepository>.value(value: lessonsRepo),
        Provider<AssignmentsRepository>.value(value: assignmentsRepo),
        Provider<StudentsRepository>.value(value: studentsRepo),
        Provider<TimetableRepository>.value(value: timetableRepo),
        Provider<LiveSessionsRepository>.value(value: liveSessionsRepo),
        Provider<NotificationsRepository>.value(value: notificationsRepo),
        Provider<SubscriptionRepository>.value(value: subscriptionRepo),
      ],
      child: MaterialApp.router(
        title: 'Nouadhibou High School',
        theme: AppTheme.light,
        routerConfig: router,
      ),
    ),
  );
}
