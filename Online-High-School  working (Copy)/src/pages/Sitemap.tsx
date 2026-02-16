import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import {
  GraduationCap,
  LogIn,
  Home,
  BookOpen,
  FileText,
  Calendar,
  Video,
  Users,
  ArrowRight,
} from 'lucide-react';

export function Sitemap() {
  const sections = [
    {
      title: 'Authentication',
      color: 'bg-gray-100',
      screens: [{ name: 'Login', path: '/login', icon: LogIn, roles: ['All'] }],
    },
    {
      title: 'Student Screens',
      color: 'bg-blue-100',
      screens: [
        { name: 'Student Dashboard', path: '/student/dashboard', icon: Home },
        { name: 'Classes List', path: '/student/classes', icon: BookOpen },
        { name: 'Class Details', path: '/student/classes/:id', icon: BookOpen },
        { name: 'Lesson Details', path: '/student/lessons/:id', icon: FileText },
        { name: 'Assignments List', path: '/student/assignments', icon: FileText },
        {
          name: 'Assignment Details & Submission',
          path: '/student/assignments/:id',
          icon: FileText,
        },
        { name: 'Timetable', path: '/student/timetable', icon: Calendar },
        { name: 'Live Sessions', path: '/student/live-sessions', icon: Video },
        {
          name: 'Live Session Detail',
          path: '/student/live-sessions/:id',
          icon: Video,
        },
      ],
    },
    {
      title: 'Teacher Screens',
      color: 'bg-green-100',
      screens: [
        { name: 'Teacher Dashboard', path: '/teacher/dashboard', icon: Home },
        { name: 'Classes List', path: '/teacher/classes', icon: BookOpen },
        { name: 'Class Details', path: '/teacher/classes/:id', icon: BookOpen },
        {
          name: 'Assignments & Grading',
          path: '/teacher/assignments',
          icon: FileText,
        },
        { name: 'Students Overview', path: '/teacher/students', icon: Users },
        { name: 'Timetable', path: '/teacher/timetable', icon: Calendar },
        { name: 'Live Sessions', path: '/teacher/live-sessions', icon: Video },
      ],
    },
    {
      title: 'Shared/Utility',
      color: 'bg-purple-100',
      screens: [
        { name: 'Sitemap (This Page)', path: '/sitemap', icon: GraduationCap },
      ],
    },
  ];

  const userFlows = [
    {
      role: 'Student',
      color: 'bg-blue-50 border-blue-200',
      flows: [
        {
          name: 'View and Submit Assignment',
          steps: [
            'Login',
            'Dashboard',
            'Classes List',
            'Class Details',
            'Assignment Details',
            'Submit',
          ],
        },
        {
          name: 'Access Lesson Content',
          steps: [
            'Login',
            'Dashboard',
            'Classes List',
            'Class Details',
            'Lesson Details',
            'View Content',
          ],
        },
        {
          name: 'Join Live Session',
          steps: ['Login', 'Dashboard', 'Live Sessions', 'Session Details', 'Join'],
        },
      ],
    },
    {
      role: 'Teacher',
      color: 'bg-green-50 border-green-200',
      flows: [
        {
          name: 'Grade Assignment',
          steps: [
            'Login',
            'Dashboard',
            'Assignments',
            'View Submission',
            'Provide Grade & Feedback',
          ],
        },
        {
          name: 'Manage Class Content',
          steps: [
            'Login',
            'Dashboard',
            'Classes List',
            'Class Details',
            'Add/Edit Lessons',
          ],
        },
        {
          name: 'Host Live Session',
          steps: [
            'Login',
            'Dashboard',
            'Live Sessions',
            'Start Session',
            'Share Link',
          ],
        },
      ],
    },
  ];

  return (
    <div className="space-y-4 pb-4">
      <div>
        <h1 className="text-xl font-bold text-gray-900">
          Platform Sitemap
        </h1>
        <p className="text-sm text-gray-600 mt-0.5">Mobile App (430x932)</p>
      </div>

      {/* Sitemap */}
      <div className="space-y-3">
        <h2 className="text-base font-semibold text-gray-900">App Screens</h2>
        <div className="space-y-3">
          {sections.map((section, idx) => (
            <Card key={idx}>
              <CardHeader className={`${section.color} py-2.5`}>
                <CardTitle className="text-sm">{section.title}</CardTitle>
              </CardHeader>
              <CardContent className="p-2">
                <div className="space-y-1.5">
                  {section.screens.map((screen, screenIdx) => {
                    const Icon = screen.icon;
                    return (
                      <div
                        key={screenIdx}
                        className="flex items-center gap-2 p-2 bg-gray-50 rounded-lg"
                      >
                        <Icon className="w-3.5 h-3.5 text-gray-600 flex-shrink-0" />
                        <div className="flex-1 min-w-0">
                          <p className="text-xs font-medium text-gray-900 truncate">{screen.name}</p>
                          <p className="text-[10px] text-gray-500 font-mono truncate">{screen.path}</p>
                        </div>
                        {screen.roles && (
                          <Badge variant="outline" className="text-[10px] px-1.5 py-0 flex-shrink-0">{screen.roles[0]}</Badge>
                        )}
                      </div>
                    );
                  })}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* User Flows */}
      <div className="space-y-3">
        <h2 className="text-base font-semibold text-gray-900">User Flows</h2>
        <div className="space-y-3">
          {userFlows.map((userFlow, idx) => (
            <Card key={idx}>
              <CardHeader className="py-2.5">
                <CardTitle className="flex items-center gap-2 text-sm">
                  <Users className="w-4 h-4" />
                  {userFlow.role} Flows
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 p-2 pt-0">
                {userFlow.flows.map((flow, flowIdx) => (
                  <div
                    key={flowIdx}
                    className={`p-2.5 rounded-lg border ${userFlow.color}`}
                  >
                    <h3 className="text-xs font-semibold text-gray-900 mb-2">{flow.name}</h3>
                    <div className="flex flex-wrap items-center gap-1.5">
                      {flow.steps.map((step, stepIdx) => (
                        <React.Fragment key={stepIdx}>
                          <Badge variant="secondary" className="text-[10px] px-1.5 py-0">{step}</Badge>
                          {stepIdx < flow.steps.length - 1 && (
                            <ArrowRight className="w-3 h-3 text-gray-400" />
                          )}
                        </React.Fragment>
                      ))}
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Component System */}
      <Card>
        <CardHeader className="py-2.5">
          <CardTitle className="text-sm">Component System</CardTitle>
        </CardHeader>
        <CardContent className="p-2 pt-0">
          <div className="grid grid-cols-2 gap-2">
            {[
              'Buttons',
              'Cards',
              'Badges',
              'Inputs',
              'Textarea',
              'Tabs',
              'Alerts',
              'Avatars',
              'Progress',
              'Dropdowns',
            ].map((component, idx) => (
              <div key={idx} className="p-2 bg-gray-50 rounded-lg text-[11px]">
                {component}
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Features Summary */}
      <Card>
        <CardHeader className="py-2.5">
          <CardTitle className="text-sm">Platform Features</CardTitle>
        </CardHeader>
        <CardContent className="p-2 pt-0 space-y-3">
          <div>
            <h3 className="text-xs font-semibold text-gray-900 mb-1.5">Student Features</h3>
            <ul className="space-y-1 text-[11px] text-gray-700">
              <li>✓ View classes & schedules</li>
              <li>✓ Access lessons (text/PDF/video)</li>
              <li>✓ Submit assignments</li>
              <li>✓ View grades & feedback</li>
              <li>✓ Join live sessions</li>
              <li>✓ Check timetable</li>
            </ul>
          </div>
          <div>
            <h3 className="text-xs font-semibold text-gray-900 mb-1.5">Teacher Features</h3>
            <ul className="space-y-1 text-[11px] text-gray-700">
              <li>✓ Manage classes</li>
              <li>✓ Create lessons</li>
              <li>✓ Create assignments</li>
              <li>✓ Grade submissions</li>
              <li>✓ Provide feedback</li>
              <li>✓ Host live sessions</li>
            </ul>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}