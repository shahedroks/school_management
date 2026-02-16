import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from '@/contexts/AuthContext';
import { LanguageProvider } from '@/contexts/LanguageContext';
import { SubscriptionProvider } from '@/contexts/SubscriptionContext';
import { LessonsProvider } from '@/contexts/LessonsContext';
import { Layout } from '@/components/Layout';
import { LanguageSelection } from '@/pages/LanguageSelection';
import { Login } from '@/pages/Login';
import { Register } from '@/pages/Register';
import { StudentDashboard } from '@/pages/student/StudentDashboard';
import { ClassesList } from '@/pages/student/ClassesList';
import { ClassDetails } from '@/pages/student/ClassDetails';
import { LessonDetails } from '@/pages/student/LessonDetails';
import { AssignmentsList } from '@/pages/student/AssignmentsList';
import { AssignmentDetails } from '@/pages/student/AssignmentDetails';
import { Timetable } from '@/pages/student/Timetable';
import { LiveSessions } from '@/pages/student/LiveSessions';
import { StudentProfile } from '@/pages/student/StudentProfile';
import { Subscription } from '@/pages/student/Subscription';
import { TeacherDashboard } from '@/pages/teacher/TeacherDashboard';
import { TeacherClassesList } from '@/pages/teacher/TeacherClassesList';
import { TeacherClassDetails } from '@/pages/teacher/TeacherClassDetails';
import { TeacherAssignmentDetails } from '@/pages/teacher/TeacherAssignmentDetails';
import { TeacherStudentsList } from '@/pages/teacher/TeacherStudentsList';
import { TeacherStudentDetail } from '@/pages/teacher/TeacherStudentDetail';
import { TeacherLiveSessions } from '@/pages/teacher/TeacherLiveSessions';
import { TeacherAnalytics } from '@/pages/teacher/TeacherAnalytics';
import { TeacherProfile } from '@/pages/teacher/TeacherProfile';
import { Sitemap } from '@/pages/Sitemap';
import { Notifications } from '@/pages/Notifications';

// Protected Route Component (moved inside AuthProvider scope)
function ProtectedRoute({ children, allowedRole }: { children: React.ReactNode; allowedRole?: 'student' | 'teacher' }) {
  const { isAuthenticated, user } = useAuth();

  // Check if user has selected language first
  const languageSelected = localStorage.getItem('languageSelected');
  
  if (!languageSelected) {
    return <Navigate to="/language" replace />;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRole && user?.role !== allowedRole) {
    return <Navigate to="/" replace />;
  }

  return <>{children}</>;
}

// Root redirect based on role (moved inside AuthProvider scope)
function RootRedirect() {
  const { user, isAuthenticated } = useAuth();

  // Check if user has selected language
  const languageSelected = localStorage.getItem('languageSelected');
  
  if (!languageSelected) {
    return <Navigate to="/language" replace />;
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (user?.role === 'student') {
    return <Navigate to="/student/dashboard" replace />;
  }

  if (user?.role === 'teacher') {
    return <Navigate to="/teacher/dashboard" replace />;
  }

  return <Navigate to="/login" replace />;
}

function AppRoutes() {
  return (
    <Routes>
      {/* Language Selection - First time user experience */}
      <Route path="/language" element={<LanguageSelection />} />

      {/* Public Routes */}
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/sitemap" element={<Layout><Sitemap /></Layout>} />
      <Route path="/notifications" element={<Layout><Notifications /></Layout>} />

      {/* Root */}
      <Route path="/" element={<RootRedirect />} />

      {/* Student Routes */}
      <Route
        path="/student/dashboard"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <StudentDashboard />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/classes"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <ClassesList />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/classes/:classId"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <ClassDetails />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/lessons/:lessonId"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <LessonDetails />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/assignments"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <AssignmentsList />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/assignments/:assignmentId"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <AssignmentDetails />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/timetable"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <Timetable />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/live-sessions"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <LiveSessions />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/live-sessions/:sessionId"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <LiveSessions />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/profile"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <StudentProfile />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/student/subscription"
        element={
          <ProtectedRoute allowedRole="student">
            <Layout>
              <Subscription />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Teacher Routes */}
      <Route
        path="/teacher/dashboard"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherDashboard />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/classes"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherClassesList />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/classes/:classId"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherClassDetails />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/assignments/:assignmentId"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherAssignmentDetails />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/students"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherStudentsList />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/students/:studentId"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherStudentDetail />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/timetable"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <Timetable />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/live-sessions"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherLiveSessions />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/analytics"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherAnalytics />
            </Layout>
          </ProtectedRoute>
        }
      />
      <Route
        path="/teacher/profile"
        element={
          <ProtectedRoute allowedRole="teacher">
            <Layout>
              <TeacherProfile />
            </Layout>
          </ProtectedRoute>
        }
      />

      {/* Fallback */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <div className="flex justify-center items-center min-h-screen bg-gray-100">
          {/* Mobile Container - 430x932px */}
          <div className="w-[430px] h-[932px] bg-white overflow-hidden relative shadow-2xl">
            <LanguageProvider>
              <SubscriptionProvider>
                <LessonsProvider>
                  <AppRoutes />
                </LessonsProvider>
              </SubscriptionProvider>
            </LanguageProvider>
          </div>
        </div>
      </AuthProvider>
    </BrowserRouter>
  );
}