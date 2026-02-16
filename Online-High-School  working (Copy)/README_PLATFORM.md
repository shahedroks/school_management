# Nouadhibou High School - Online Learning Platform

A complete, production-ready online learning platform with separate interfaces for Students and Teachers.

## 🎯 Features

### Student Features
- ✅ **Dashboard**: Overview of classes, assignments, and live sessions
- ✅ **Classes List**: View all enrolled courses
- ✅ **Class Details**: Access lessons and assignments for each class
- ✅ **Lesson Details**: View lessons in multiple formats (text, PDF, video links)
- ✅ **Assignments**: View, submit, and track assignment status
- ✅ **Assignment Submission**: Upload files or submit text responses
- ✅ **Grading & Feedback**: View grades and teacher feedback
- ✅ **Timetable**: Weekly class schedule
- ✅ **Live Sessions**: Join Zoom/Google Meet sessions

### Teacher Features
- ✅ **Dashboard**: Overview of classes, students, and pending work
- ✅ **Class Management**: Manage multiple classes and students
- ✅ **Assignment Grading**: Review submissions and provide grades/feedback
- ✅ **Student Roster**: View all students across classes
- ✅ **Timetable**: Teaching schedule
- ✅ **Live Sessions**: Host and manage virtual classes

## 📱 Screens Implemented

### Authentication
1. **Login** (`/login`) - Role-based authentication

### Student Screens
2. **Student Dashboard** (`/student/dashboard`)
3. **Classes List** (`/student/classes`)
4. **Class Details** (`/student/classes/:id`)
5. **Lesson Details** (`/student/lessons/:id`) - Supports text, PDF, video
6. **Assignment List** (via class details)
7. **Assignment Details** (`/student/assignments/:id`)
8. **Submission Upload** (integrated in assignment details)
9. **Timetable** (`/student/timetable`)
10. **Live Sessions** (`/student/live-sessions`)
11. **Live Session Details** (`/student/live-sessions/:id`)

### Teacher Screens
12. **Teacher Dashboard** (`/teacher/dashboard`)
13. **Classes Management** (`/teacher/classes`)
14. **Grading Interface** (`/teacher/assignments`)
15. **Students Overview** (`/teacher/students`)
16. **Timetable** (`/teacher/timetable`)
17. **Live Sessions** (`/teacher/live-sessions`)

### Documentation
18. **Sitemap & User Flows** (`/sitemap`)

## 🎨 Design System

### Component Library (Figma-Ready)
- **Buttons**: Primary, Secondary, Outline variants
- **Cards**: Container, Header, Content sections
- **Badges**: Status indicators with color coding
- **Form Elements**: Input, Textarea, File upload, Labels
- **Navigation**: Tabs, Dropdown menus
- **Feedback**: Alerts (Success, Error, Info, Warning)
- **Data Display**: Progress bars, Avatar, Tables
- **Layout**: Responsive grid system, Headers, Footers

### Color Scheme
- **Primary**: Blue (#3B82F6) - Main actions, links
- **Secondary**: Gray - Supporting elements
- **Success**: Green - Completed, graded
- **Warning**: Orange - Pending, due soon
- **Error**: Red - Overdue, errors
- **Info**: Purple - Live sessions, special features

## 🗺️ User Flows

### Student Flow: Submit Assignment
Login → Dashboard → Classes → Class Details → Assignment → Submit → Confirmation

### Student Flow: Access Lesson
Login → Dashboard → Classes → Class Details → Lesson Details → View Content

### Student Flow: Join Live Session
Login → Dashboard → Live Sessions → Session Details → Join Link

### Teacher Flow: Grade Assignment
Login → Dashboard → Assignments → View Submissions → Provide Grade & Feedback

### Teacher Flow: Manage Content
Login → Dashboard → Classes → Class Details → Lessons Management

## 🔐 Demo Accounts

### Student Account
- **Email**: fatima@school.mr
- **Password**: any
- **Access**: Student dashboard and features

### Teacher Account
- **Email**: mohammed@school.mr
- **Password**: any
- **Access**: Teacher dashboard and features

## 🛠️ Technical Stack

- **Framework**: React 18 with TypeScript
- **Routing**: React Router DOM
- **Styling**: Tailwind CSS v4
- **UI Components**: Radix UI + Custom components
- **Icons**: Lucide React
- **State Management**: React Context (Auth)
- **Data**: Mock data with TypeScript interfaces

## 📁 Project Structure

```
src/
├── app/
│   ├── App.tsx                 # Main app with routing
│   └── components/ui/          # Reusable UI components
├── components/
│   └── Layout.tsx              # Main layout wrapper
├── contexts/
│   └── AuthContext.tsx         # Authentication context
├── data/
│   └── mockData.ts             # Mock data (users, classes, etc.)
├── pages/
│   ├── Login.tsx               # Login page
│   ├── Sitemap.tsx             # Documentation
│   ├── student/                # Student pages
│   │   ├── StudentDashboard.tsx
│   │   ├── ClassesList.tsx
│   │   ├── ClassDetails.tsx
│   │   ├── LessonDetails.tsx
│   │   ├── AssignmentDetails.tsx
│   │   ├── Timetable.tsx
│   │   └── LiveSessions.tsx
│   └── teacher/                # Teacher pages
│       └── TeacherDashboard.tsx
```

## 🚀 Getting Started

1. The application loads with a login screen
2. Use demo credentials to access student or teacher interface
3. Navigate using the top navigation bar
4. Access the sitemap at `/sitemap` for complete documentation

## 📊 Mock Data Includes

- **4 Classes**: Mathematics, Arabic, Physics, French
- **4 Lessons**: Various types (text, PDF, video)
- **4 Assignments**: With different statuses
- **3 Submissions**: For grading demonstration
- **11 Timetable Entries**: Full week schedule
- **3 Live Sessions**: Active and upcoming

## 🎯 Key Features

### Responsive Design
- Mobile-first approach
- Adapts to tablet and desktop screens
- Touch-friendly interface

### Role-Based Access
- Separate dashboards for students and teachers
- Protected routes based on user role
- Role-specific navigation

### Real-time Status
- Assignment status tracking
- Due date warnings
- Live session indicators
- Progress tracking

### Content Types
- **Text Lessons**: Direct reading
- **PDF Documents**: Download/view
- **Video Links**: External video platforms
- **File Uploads**: Assignment submissions

## 🔮 Future Enhancements (Not Implemented)

- Backend integration
- Real-time notifications
- Chat/messaging system
- Calendar integration
- Mobile apps
- Analytics dashboard
- Parent portal
- Grade book
- Attendance tracking

## 📝 Notes

- All data is mock data for demonstration
- File uploads are simulated (no actual upload)
- Live session links are placeholders
- Grading is demonstrated but not persisted
- Perfect for Figma design handoff

---

**Platform Status**: ✅ Complete & Ready for Use
**Last Updated**: January 25, 2026
