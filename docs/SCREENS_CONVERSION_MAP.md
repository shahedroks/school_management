# Screen Conversion Map: React (Online-High-School) → Flutter (high_school)

This document maps each **React** screen from `Online-High-School  working (Copy)` to its **Flutter** equivalent in `lib/`, including route and file location.

---

## Quick reference

| React (Online-High-School) | Flutter (lib) | Route |
|---------------------------|---------------|--------|
| **File path** | **File path** | **URL path** |

---

## Auth & public

| React screen | React file | Flutter screen | Flutter file | Route |
|--------------|------------|----------------|--------------|--------|
| Language Selection | `src/pages/LanguageSelection.tsx` | LanguageSelectionScreen | `lib/presentation/screens/auth/language_selection_screen.dart` | `/language` |
| Login | `src/pages/Login.tsx` | LoginScreen | `lib/presentation/screens/auth/login_screen.dart` | `/login` |
| Register | `src/pages/Register.tsx` | RegisterScreen | `lib/presentation/screens/auth/register_screen.dart` | `/register` |
| Sitemap | `src/pages/Sitemap.tsx` | SitemapScreen | `lib/presentation/screens/sitemap_screen.dart` | `/sitemap` |
| Notifications | `src/pages/Notifications.tsx` | NotificationsScreen | `lib/presentation/screens/notifications_screen.dart` | `/notifications` |

**Conversion check (Notifications):** Flutter `notifications_screen.dart` now matches React: page heading “Notifications”, cards with **border primary/10**, **avatar** with initials and type-based color (student=pink, admin=accent, system=secondary), **from** name, **timestamp**, **unread dot** (primary), **message**; tap to mark as read. Empty state: “No notifications” + “You're all caught up!”. Mark all read button retained.

---

## Student screens

| React screen | React file | Flutter screen | Flutter file | Route |
|--------------|------------|----------------|--------------|--------|
| Student Dashboard | `src/pages/student/StudentDashboard.tsx` | StudentDashboardScreen | `lib/presentation/screens/student/student_dashboard_screen.dart` | `/student/dashboard` |
| Classes List | `src/pages/student/ClassesList.tsx` | ClassesListScreen | `lib/presentation/screens/student/classes_list_screen.dart` | `/student/classes` |
| Class Details | `src/pages/student/ClassDetails.tsx` | ClassDetailsScreen | `lib/presentation/screens/student/class_details_screen.dart` | `/student/classes/:classId` |
| Lesson Details | `src/pages/student/LessonDetails.tsx` | LessonDetailsScreen | `lib/presentation/screens/student/lesson_details_screen.dart` | `/student/lessons/:lessonId` |
| Assignments List | `src/pages/student/AssignmentsList.tsx` | AssignmentsListScreen | `lib/presentation/screens/student/assignments_list_screen.dart` | `/student/assignments` |
| Assignment Details | `src/pages/student/AssignmentDetails.tsx` | AssignmentDetailsScreen | `lib/presentation/screens/student/assignment_details_screen.dart` | `/student/assignments/:assignmentId` |
| Timetable | `src/pages/student/Timetable.tsx` | TimetableScreen | `lib/presentation/screens/student/timetable_screen.dart` | `/student/timetable` |
| Live Sessions | `src/pages/student/LiveSessions.tsx` | LiveSessionsScreen | `lib/presentation/screens/student/live_sessions_screen.dart` | `/student/live-sessions` |
| Student Profile | `src/pages/student/StudentProfile.tsx` | StudentProfileScreen | `lib/presentation/screens/student/student_profile_screen.dart` | `/student/profile` |
| Subscription | `src/pages/student/Subscription.tsx` | SubscriptionScreen | `lib/presentation/screens/student/subscription_screen.dart` | `/student/subscription` |

**Conversion check (Student Profile):** Flutter `student_profile_screen.dart` now matches React: header banner (My Profile / Manage personal info), **profile card** (avatar with initials, name, grade badge, Edit button, contact: email, phone, address), **Edit dialog** (personal info + parent/guardian, Cancel/Save), **Academic Overview** (4 stat boxes: Enrolled Classes, Assignments, Average Grade, Attendance), **Parent/Guardian Contact** card, **Current Classes** list with teacher badge, **Language Preference**, **Recent Achievements** card.

**Conversion check (Classes List):** Flutter `classes_list_screen.dart` now matches React: header banner (My Classes / Enrolled Classes), empty state with lock icon and “View Subscription Plans” button, classes **grouped by subject**, and per-subject cards with gradient header, teacher, student count, grade badges, and “View Class” button.

**Conversion check (Class Details):** Flutter `class_details_screen.dart` now matches React: class header with gradient (class color), class name, teacher, schedule + student count; tabs Lessons | Assignments; Lessons tab – empty state or cards (type icon, title, description, date, duration, type badge, tap to lesson); Assignments tab – empty state or cards (title, description, due date, pts badge, status badge, grade if graded, tap to assignment).

**Conversion check (Timetable):** Flutter `timetable_screen.dart` now matches React: header banner (My Schedule / Weekly Schedule), day cards Monday–Friday, **Today** badge on current day, per-day empty state or entry list with clock, class name, time, teacher; tap to class details.

**Conversion check (Live Sessions):** Flutter `live_sessions_screen.dart` now matches React: header banner (Live Sessions / Upcoming Sessions), **Active Now** section with red dot + cards (title, time • platform, green Join button), **Upcoming Sessions** section with count, empty state card or cards with blue header (class name), gray body (title, date, time, platform badge). Join navigates to session detail (detail route can be added separately).

---

## Teacher screens

| React screen | React file | Flutter screen | Flutter file | Route |
|--------------|------------|----------------|--------------|--------|
| Teacher Dashboard | `src/pages/teacher/TeacherDashboard.tsx` | TeacherDashboardScreen | `lib/presentation/screens/teacher/teacher_dashboard_screen.dart` | `/teacher/dashboard` |
| Teacher Classes List | `src/pages/teacher/TeacherClassesList.tsx` | TeacherClassesListScreen | `lib/presentation/screens/teacher/teacher_classes_list_screen.dart` | `/teacher/classes` |
| Teacher Class Details | `src/pages/teacher/TeacherClassDetails.tsx` | TeacherClassDetailsScreen | `lib/presentation/screens/teacher/teacher_class_details_screen.dart` | `/teacher/classes/:classId` |
| Teacher Assignment Details | `src/pages/teacher/TeacherAssignmentDetails.tsx` | TeacherAssignmentDetailsScreen | `lib/presentation/screens/teacher/teacher_assignment_details_screen.dart` | `/teacher/assignments/:assignmentId` |
| Teacher Students List | `src/pages/teacher/TeacherStudentsList.tsx` | TeacherStudentsListScreen | `lib/presentation/screens/teacher/teacher_students_list_screen.dart` | `/teacher/students` |
| Teacher Student Detail | `src/pages/teacher/TeacherStudentDetail.tsx` | TeacherStudentDetailScreen | `lib/presentation/screens/teacher/teacher_student_detail_screen.dart` | `/teacher/students/:studentId` |
| Teacher Timetable | `src/pages/teacher/` (uses Timetable) | TimetableScreen | `lib/presentation/screens/student/timetable_screen.dart` | `/teacher/timetable` |
| Teacher Live Sessions | `src/pages/teacher/TeacherLiveSessions.tsx` | TeacherLiveSessionsScreen | `lib/presentation/screens/teacher/teacher_live_sessions_screen.dart` | `/teacher/live-sessions` |
| Teacher Analytics | `src/pages/teacher/TeacherAnalytics.tsx` | TeacherAnalyticsScreen | `lib/presentation/screens/teacher/teacher_analytics_screen.dart` | `/teacher/analytics` |
| Teacher Profile | `src/pages/teacher/TeacherProfile.tsx` | TeacherProfileScreen | `lib/presentation/screens/teacher/teacher_profile_screen.dart` | `/teacher/profile` |

---

## Flutter folder structure (screens)

```
lib/
└── presentation/
    └── screens/
        ├── auth/
        │   ├── language_selection_screen.dart   → /language
        │   ├── login_screen.dart                 → /login
        │   └── register_screen.dart              → /register
        ├── student/
        │   ├── student_dashboard_screen.dart     → /student/dashboard
        │   ├── classes_list_screen.dart          → /student/classes
        │   ├── class_details_screen.dart         → /student/classes/:classId
        │   ├── lesson_details_screen.dart        → /student/lessons/:lessonId
        │   ├── assignments_list_screen.dart      → /student/assignments
        │   ├── assignment_details_screen.dart    → /student/assignments/:assignmentId
        │   ├── timetable_screen.dart             → /student/timetable
        │   ├── live_sessions_screen.dart         → /student/live-sessions
        │   ├── student_profile_screen.dart      → /student/profile
        │   └── subscription_screen.dart          → /student/subscription
        ├── teacher/
        │   ├── teacher_dashboard_screen.dart     → /teacher/dashboard
        │   ├── teacher_classes_list_screen.dart  → /teacher/classes
        │   ├── teacher_class_details_screen.dart → /teacher/classes/:classId
        │   ├── teacher_assignment_details_screen.dart → /teacher/assignments/:assignmentId
        │   ├── teacher_students_list_screen.dart → /teacher/students
        │   ├── teacher_student_detail_screen.dart → /teacher/students/:studentId
        │   ├── teacher_live_sessions_screen.dart → /teacher/live-sessions
        │   ├── teacher_analytics_screen.dart     → /teacher/analytics
        │   └── teacher_profile_screen.dart       → /teacher/profile
        ├── notifications_screen.dart             → /notifications
        └── sitemap_screen.dart                   → /sitemap
```

**Note:** Teacher timetable reuses `timetable_screen.dart` (same file as student timetable). Router: `lib/core/router/app_router.dart`.

---

## React folder structure (pages – reference)

```
Online-High-School  working (Copy)/src/
└── pages/
    ├── LanguageSelection.tsx
    ├── Login.tsx
    ├── Register.tsx
    ├── Sitemap.tsx
    ├── Notifications.tsx
    ├── student/
    │   ├── StudentDashboard.tsx
    │   ├── ClassesList.tsx
    │   ├── ClassDetails.tsx
    │   ├── LessonDetails.tsx
    │   ├── AssignmentsList.tsx
    │   ├── AssignmentDetails.tsx
    │   ├── Timetable.tsx
    │   ├── LiveSessions.tsx
    │   ├── StudentProfile.tsx
    │   └── Subscription.tsx
    └── teacher/
        ├── TeacherDashboard.tsx
        ├── TeacherClassesList.tsx
        ├── TeacherClassDetails.tsx
        ├── TeacherAssignmentDetails.tsx
        ├── TeacherAssignmentsList.tsx   ← no direct Flutter route (teacher goes to assignment details)
        ├── TeacherStudentsList.tsx
        ├── TeacherStudentDetail.tsx
        ├── TeacherLiveSessions.tsx
        ├── TeacherAnalytics.tsx
        └── TeacherProfile.tsx
```

---

## Summary

- **Total React pages (screens):** 24 (including Language, Login, Register, Sitemap, Notifications + 10 student + 10 teacher; Timetable shared).
- **Total Flutter screens:** 24 screen files; routes defined in `lib/core/router/app_router.dart`.
- **Naming:** Flutter uses `snake_case` for files (e.g. `student_dashboard_screen.dart`) and `PascalCase` for class names (e.g. `StudentDashboardScreen`).
