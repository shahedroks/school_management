// Mock Data for the High School Platform - Nouadhibou

export type UserRole = 'student' | 'teacher';

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  avatar?: string;
  grade?: string; // for students
  subject?: string; // for teachers
}

export interface Class {
  id: string;
  name: string;
  subject: string;
  category: string;
  teacher: string;
  teacherId: string;
  students: number;
  color: string;
  schedule: string;
  room: string;
  level: string; // e.g., "10th Grade", "11th Grade"
  schoolYear: string; // e.g., "2024-2025"
}

export interface Lesson {
  id: string;
  classId: string;
  title: string;
  description: string;
  type: 'text' | 'pdf' | 'video';
  content: string; // URL or text content
  date: string;
  duration?: string;
  status: 'draft' | 'published';
  lastUpdated: string;
  module?: string; // Chapter/Module name
}

export interface Assignment {
  id: string;
  classId: string;
  title: string;
  description: string;
  dueDate: string;
  points: number;
  status: 'pending' | 'submitted' | 'graded';
  grade?: number;
  feedback?: string;
  submissions?: Submission[];
}

export interface Submission {
  id: string;
  assignmentId: string;
  studentId: string;
  studentName: string;
  fileUrl?: string;
  file?: string;
  text?: string;
  submittedAt: string;
  status?: 'submitted' | 'graded';
  grade?: number;
  feedback?: string;
}

export interface Student {
  id: string;
  name: string;
  email: string;
  grade: number;
  avatar?: string;
}

export interface TimetableEntry {
  id: string;
  day: string;
  time: string;
  classId: string;
  className: string;
  teacher: string;
  room: string;
}

export interface LiveSession {
  id: string;
  classId: string;
  title: string;
  date: string;
  time: string;
  platform: 'zoom' | 'meet';
  link: string;
  isActive: boolean;
}

export interface SubscriptionPlan {
  id: string;
  name: string;
  price: number;
  duration: string; // e.g., "monthly", "yearly"
  features: string[];
  classIds: string[]; // Classes included in this plan
  maxClasses: number;
  popular?: boolean;
}

export interface StudentSubscription {
  studentId: string;
  planId: string;
  enrolledClassIds: string[];
  startDate: string;
  endDate: string;
  status: 'active' | 'expired' | 'none';
}

export interface AttendanceRecord {
  id: string;
  studentId: string;
  classId: string;
  date: string;
  status: 'present' | 'absent' | 'late' | 'excused';
  notes?: string;
}

export interface StudentProgress {
  studentId: string;
  classId: string;
  overallGrade: number;
  assignments: {
    completed: number;
    total: number;
  };
  attendance: {
    present: number;
    absent: number;
    late: number;
    total: number;
  };
  lastActivity: string;
}

export interface Notification {
  id: string;
  type: 'student' | 'admin' | 'system';
  from: string;
  message: string;
  timestamp: string;
  read: boolean;
}

// Mock Users
export const mockUsers: User[] = [
  {
    id: 'student1',
    name: 'Fatima Ahmed',
    email: 'fatima@school.mr',
    role: 'student',
    grade: '10th Grade',
  },
  {
    id: 'teacher1',
    name: 'Mohammed Ould',
    email: 'mohammed@school.mr',
    role: 'teacher',
    subject: 'Mathematics',
  },
];

// Mock Classes
export const mockClasses: Class[] = [
  {
    id: 'class1',
    name: 'Mathematics',
    subject: 'Mathematics',
    category: 'Core',
    teacher: 'Mohammed Ould',
    teacherId: 'teacher1',
    students: 28,
    color: '#1F3C88', // Royal Blue
    schedule: 'Mon, Wed, Fri 10:00 AM',
    room: 'Room 201',
    level: '4th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class2',
    name: 'Arabic',
    subject: 'Arabic',
    category: 'Language',
    teacher: 'Aisha Mint',
    teacherId: 'teacher2',
    students: 25,
    color: '#2E7D32', // Academic Green
    schedule: 'Tue, Thu 9:00 AM',
    room: 'Room 105',
    level: '5th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class3',
    name: 'Physics',
    subject: 'Physics',
    category: 'Core',
    teacher: 'Omar Salem',
    teacherId: 'teacher3',
    students: 30,
    color: '#7B1FA2', // Deep Purple
    schedule: 'Mon, Wed, Fri 2:00 PM',
    room: 'Lab 3',
    level: '6th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class4',
    name: 'French',
    subject: 'French',
    category: 'Language',
    teacher: 'Marie Diallo',
    teacherId: 'teacher4',
    students: 22,
    color: '#F4B400', // Soft Gold
    schedule: 'Tue, Thu 11:00 AM',
    room: 'Room 302',
    level: '7th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class5',
    name: 'Chemistry',
    subject: 'Chemistry',
    category: 'Core',
    teacher: 'Hassan Brahim',
    teacherId: 'teacher5',
    students: 24,
    color: '#D32F2F', // Red
    schedule: 'Mon, Wed 1:00 PM',
    room: 'Lab 1',
    level: '5th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class6',
    name: 'SVT (Life & Earth Sciences)',
    subject: 'SVT',
    category: 'Core',
    teacher: 'Khadija Sow',
    teacherId: 'teacher6',
    students: 26,
    color: '#388E3C', // Green
    schedule: 'Tue, Thu 2:00 PM',
    room: 'Lab 2',
    level: '6th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class7',
    name: 'English',
    subject: 'English',
    category: 'Language',
    teacher: 'John Smith',
    teacherId: 'teacher7',
    students: 20,
    color: '#0288D1', // Blue
    schedule: 'Mon, Fri 9:00 AM',
    room: 'Room 204',
    level: '4th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class8',
    name: 'Modern Skills: Coding, AI, Entrepreneurship',
    subject: 'Modern Skills',
    category: 'Elective',
    teacher: 'Sarah Johnson',
    teacherId: 'teacher8',
    students: 18,
    color: '#FF6F00', // Orange
    schedule: 'Wed, Fri 3:00 PM',
    room: 'Computer Lab',
    level: '7th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class9',
    name: 'Mathematics',
    subject: 'Mathematics',
    category: 'Core',
    teacher: 'Mohammed Ould',
    teacherId: 'teacher1',
    students: 22,
    color: '#1F3C88', // Royal Blue
    schedule: 'Tue, Thu 10:00 AM',
    room: 'Room 203',
    level: '5th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class10',
    name: 'Mathematics',
    subject: 'Mathematics',
    category: 'Core',
    teacher: 'Mohammed Ould',
    teacherId: 'teacher1',
    students: 25,
    color: '#1F3C88', // Royal Blue
    schedule: 'Mon, Wed, Fri 11:00 AM',
    room: 'Room 202',
    level: '6th Grade',
    schoolYear: '2024-2025',
  },
  {
    id: 'class11',
    name: 'Mathematics',
    subject: 'Mathematics',
    category: 'Core',
    teacher: 'Mohammed Ould',
    teacherId: 'teacher1',
    students: 20,
    color: '#1F3C88', // Royal Blue
    schedule: 'Tue, Thu 1:00 PM',
    room: 'Room 106',
    level: '7th Grade',
    schoolYear: '2024-2025',
  },
];

// Mock Lessons
export const mockLessons: Lesson[] = [
  {
    id: 'lesson1',
    classId: 'class1',
    title: 'Quadratic Equations',
    description: 'Introduction to quadratic equations and their applications',
    type: 'video',
    content: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    date: '2026-01-20',
    duration: '45 min',
    status: 'published',
    lastUpdated: '2026-01-19',
    module: 'Chapter 3: Equations',
  },
  {
    id: 'lesson2',
    classId: 'class1',
    title: 'Solving Systems of Equations',
    description: 'Methods for solving systems of linear equations',
    type: 'pdf',
    content: '/files/systems-equations.pdf',
    date: '2026-01-22',
    status: 'published',
    lastUpdated: '2026-01-21',
    module: 'Chapter 4: Systems',
  },
  {
    id: 'lesson5',
    classId: 'class1',
    title: 'Introduction to Functions',
    description: 'Understanding the concept of functions and their notation',
    type: 'text',
    content: 'A function is a relation between a set of inputs and outputs...',
    date: '2026-02-01',
    status: 'draft',
    lastUpdated: '2026-01-29',
    module: 'Chapter 5: Functions',
  },
  {
    id: 'lesson6',
    classId: 'class1',
    title: 'Graphing Linear Functions',
    description: 'Learn how to graph linear functions on the coordinate plane',
    type: 'video',
    content: 'https://www.youtube.com/watch?v=sample',
    date: '2026-02-03',
    duration: '40 min',
    status: 'draft',
    lastUpdated: '2026-01-28',
    module: 'Chapter 5: Functions',
  },
  {
    id: 'lesson7',
    classId: 'class1',
    title: 'Polynomials and Factoring',
    description: 'Introduction to polynomial expressions and factoring techniques',
    type: 'pdf',
    content: '/files/polynomials.pdf',
    date: '2026-01-15',
    status: 'published',
    lastUpdated: '2026-01-14',
    module: 'Chapter 2: Polynomials',
  },
  {
    id: 'lesson3',
    classId: 'class2',
    title: 'Classical Arabic Poetry',
    description: 'Study of pre-Islamic poetry and its characteristics',
    type: 'text',
    content: 'Classical Arabic poetry, also known as Jahiliyyah poetry, represents one of the most important literary traditions in Arab culture. The poems often explored themes of honor, bravery, and desert life.',
    date: '2026-01-21',
    status: 'published',
    lastUpdated: '2026-01-20',
    module: 'Module 2: Classical Era',
  },
  {
    id: 'lesson4',
    classId: 'class3',
    title: 'Newton\'s Laws of Motion',
    description: 'Understanding the three fundamental laws of motion',
    type: 'video',
    content: 'https://www.youtube.com/watch?v=sample',
    date: '2026-01-20',
    duration: '50 min',
    status: 'published',
    lastUpdated: '2026-01-19',
    module: 'Chapter 5: Mechanics',
  },
];

// Mock Assignments
export const mockAssignments: Assignment[] = [
  {
    id: 'assign1',
    classId: 'class1',
    title: 'Quadratic Equations Worksheet',
    description: 'Solve problems 1-20 from the textbook',
    dueDate: '2026-01-27',
    points: 100,
    status: 'pending',
  },
  {
    id: 'assign2',
    classId: 'class1',
    title: 'Systems of Equations Project',
    description: 'Create a real-world application of systems of equations',
    dueDate: '2026-01-30',
    points: 150,
    status: 'submitted',
    grade: 135,
    feedback: 'Great work! Consider exploring more complex systems.',
  },
  {
    id: 'assign3',
    classId: 'class2',
    title: 'Poetry Analysis',
    description: 'Analyze three poems from the classical period',
    dueDate: '2026-01-28',
    points: 100,
    status: 'graded',
    grade: 92,
    feedback: 'Excellent analysis of themes and literary devices.',
  },
  {
    id: 'assign4',
    classId: 'class3',
    title: 'Motion Lab Report',
    description: 'Document your findings from the motion experiment',
    dueDate: '2026-02-01',
    points: 120,
    status: 'pending',
  },
];

// Mock Submissions (for teacher view)
export const mockSubmissions: Submission[] = [
  {
    id: 'sub1',
    assignmentId: 'assign1',
    studentId: 'student1',
    studentName: 'Fatima Ahmed',
    fileUrl: '/files/fatima-worksheet.pdf',
    file: 'fatima-worksheet.pdf',
    submittedAt: '2026-01-26T14:30:00',
    status: 'submitted',
  },
  {
    id: 'sub2',
    assignmentId: 'assign1',
    studentId: 'student2',
    studentName: 'Ali Hassan',
    fileUrl: '/files/ali-worksheet.pdf',
    file: 'ali-worksheet.pdf',
    submittedAt: '2026-01-26T16:20:00',
    status: 'graded',
    grade: 95,
    feedback: 'Excellent work! All solutions are correct.',
  },
  {
    id: 'sub3',
    assignmentId: 'assign1',
    studentId: 'student3',
    studentName: 'Mariam Ould',
    text: 'Here are my solutions to the worksheet problems...',
    submittedAt: '2026-01-27T09:15:00',
    status: 'submitted',
  },
];

// Mock Students
export const mockStudents: Student[] = [
  {
    id: 'student1',
    name: 'Fatima Ahmed',
    email: 'fatima.ahmed@school.mr',
    grade: 92,
  },
  {
    id: 'student2',
    name: 'Ali Hassan',
    email: 'ali.hassan@school.mr',
    grade: 88,
  },
  {
    id: 'student3',
    name: 'Mariam Ould',
    email: 'mariam.ould@school.mr',
    grade: 95,
  },
  {
    id: 'student4',
    name: 'Omar Abdallah',
    email: 'omar.abdallah@school.mr',
    grade: 85,
  },
  {
    id: 'student5',
    name: 'Aisha Salem',
    email: 'aisha.salem@school.mr',
    grade: 90,
  },
  {
    id: 'student6',
    name: 'Mohammed Mint',
    email: 'mohammed.mint@school.mr',
    grade: 87,
  },
  {
    id: 'student7',
    name: 'Khadija Diallo',
    email: 'khadija.diallo@school.mr',
    grade: 93,
  },
  {
    id: 'student8',
    name: 'Ibrahim Ould',
    email: 'ibrahim.ould@school.mr',
    grade: 89,
  },
  {
    id: 'student9',
    name: 'Zahra Ahmed',
    email: 'zahra.ahmed@school.mr',
    grade: 91,
  },
  {
    id: 'student10',
    name: 'Youssef Hassan',
    email: 'youssef.hassan@school.mr',
    grade: 86,
  },
  {
    id: 'student11',
    name: 'Amina Salem',
    email: 'amina.salem@school.mr',
    grade: 94,
  },
  {
    id: 'student12',
    name: 'Hassan Mint',
    email: 'hassan.mint@school.mr',
    grade: 88,
  },
  {
    id: 'student13',
    name: 'Salma Diallo',
    email: 'salma.diallo@school.mr',
    grade: 90,
  },
  {
    id: 'student14',
    name: 'Ahmed Ould',
    email: 'ahmed.ould@school.mr',
    grade: 92,
  },
  {
    id: 'student15',
    name: 'Nour Ahmed',
    email: 'nour.ahmed@school.mr',
    grade: 87,
  },
  {
    id: 'student16',
    name: 'Karim Hassan',
    email: 'karim.hassan@school.mr',
    grade: 85,
  },
  {
    id: 'student17',
    name: 'Leila Salem',
    email: 'leila.salem@school.mr',
    grade: 93,
  },
  {
    id: 'student18',
    name: 'Bilal Mint',
    email: 'bilal.mint@school.mr',
    grade: 89,
  },
  {
    id: 'student19',
    name: 'Hiba Diallo',
    email: 'hiba.diallo@school.mr',
    grade: 91,
  },
  {
    id: 'student20',
    name: 'Mustafa Ould',
    email: 'mustafa.ould@school.mr',
    grade: 86,
  },
];

// Mock Timetable
export const mockTimetable: TimetableEntry[] = [
  // Monday
  {
    id: 'tt1',
    day: 'Monday',
    time: '10:00 - 11:00',
    classId: 'class1',
    className: 'Mathematics - 4th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 201',
  },
  {
    id: 'tt2',
    day: 'Monday',
    time: '11:00 - 12:00',
    classId: 'class10',
    className: 'Mathematics - 6th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 202',
  },
  {
    id: 'tt3',
    day: 'Monday',
    time: '13:00 - 14:00',
    classId: 'class5',
    className: 'Chemistry',
    teacher: 'Hassan Brahim',
    room: 'Lab 1',
  },
  {
    id: 'tt4',
    day: 'Monday',
    time: '14:00 - 15:00',
    classId: 'class3',
    className: 'Physics',
    teacher: 'Omar Salem',
    room: 'Lab 3',
  },
  // Tuesday
  {
    id: 'tt5',
    day: 'Tuesday',
    time: '9:00 - 10:00',
    classId: 'class2',
    className: 'Arabic',
    teacher: 'Aisha Mint',
    room: 'Room 105',
  },
  {
    id: 'tt6',
    day: 'Tuesday',
    time: '10:00 - 11:00',
    classId: 'class9',
    className: 'Mathematics - 5th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 203',
  },
  {
    id: 'tt7',
    day: 'Tuesday',
    time: '11:00 - 12:00',
    classId: 'class4',
    className: 'French',
    teacher: 'Marie Diallo',
    room: 'Room 302',
  },
  {
    id: 'tt8',
    day: 'Tuesday',
    time: '13:00 - 14:00',
    classId: 'class11',
    className: 'Mathematics - 7th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 106',
  },
  {
    id: 'tt9',
    day: 'Tuesday',
    time: '14:00 - 15:00',
    classId: 'class6',
    className: 'SVT (Life & Earth Sciences)',
    teacher: 'Khadija Sow',
    room: 'Lab 2',
  },
  // Wednesday
  {
    id: 'tt10',
    day: 'Wednesday',
    time: '9:00 - 10:00',
    classId: 'class7',
    className: 'English',
    teacher: 'John Smith',
    room: 'Room 204',
  },
  {
    id: 'tt11',
    day: 'Wednesday',
    time: '10:00 - 11:00',
    classId: 'class1',
    className: 'Mathematics - 4th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 201',
  },
  {
    id: 'tt12',
    day: 'Wednesday',
    time: '11:00 - 12:00',
    classId: 'class10',
    className: 'Mathematics - 6th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 202',
  },
  {
    id: 'tt13',
    day: 'Wednesday',
    time: '14:00 - 15:00',
    classId: 'class3',
    className: 'Physics',
    teacher: 'Omar Salem',
    room: 'Lab 3',
  },
  {
    id: 'tt14',
    day: 'Wednesday',
    time: '15:00 - 16:00',
    classId: 'class8',
    className: 'Modern Skills: Coding, AI, Entrepreneurship',
    teacher: 'Sarah Johnson',
    room: 'Computer Lab',
  },
  // Thursday
  {
    id: 'tt15',
    day: 'Thursday',
    time: '9:00 - 10:00',
    classId: 'class2',
    className: 'Arabic',
    teacher: 'Aisha Mint',
    room: 'Room 105',
  },
  {
    id: 'tt16',
    day: 'Thursday',
    time: '10:00 - 11:00',
    classId: 'class9',
    className: 'Mathematics - 5th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 203',
  },
  {
    id: 'tt17',
    day: 'Thursday',
    time: '11:00 - 12:00',
    classId: 'class4',
    className: 'French',
    teacher: 'Marie Diallo',
    room: 'Room 302',
  },
  {
    id: 'tt18',
    day: 'Thursday',
    time: '13:00 - 14:00',
    classId: 'class11',
    className: 'Mathematics - 7th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 106',
  },
  {
    id: 'tt19',
    day: 'Thursday',
    time: '14:00 - 15:00',
    classId: 'class6',
    className: 'SVT (Life & Earth Sciences)',
    teacher: 'Khadija Sow',
    room: 'Lab 2',
  },
  // Friday
  {
    id: 'tt20',
    day: 'Friday',
    time: '9:00 - 10:00',
    classId: 'class7',
    className: 'English',
    teacher: 'John Smith',
    room: 'Room 204',
  },
  {
    id: 'tt21',
    day: 'Friday',
    time: '10:00 - 11:00',
    classId: 'class1',
    className: 'Mathematics - 4th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 201',
  },
  {
    id: 'tt22',
    day: 'Friday',
    time: '11:00 - 12:00',
    classId: 'class10',
    className: 'Mathematics - 6th Grade',
    teacher: 'Mohammed Ould',
    room: 'Room 202',
  },
  {
    id: 'tt23',
    day: 'Friday',
    time: '14:00 - 15:00',
    classId: 'class3',
    className: 'Physics',
    teacher: 'Omar Salem',
    room: 'Lab 3',
  },
  {
    id: 'tt24',
    day: 'Friday',
    time: '15:00 - 16:00',
    classId: 'class8',
    className: 'Modern Skills: Coding, AI, Entrepreneurship',
    teacher: 'Sarah Johnson',
    room: 'Computer Lab',
  },
];

// Mock Live Sessions
export const mockLiveSessions: LiveSession[] = [
  {
    id: 'live1',
    classId: 'class1',
    title: 'Advanced Mathematics - Live Q&A',
    date: '2026-01-25',
    time: '10:00 AM',
    platform: 'zoom',
    link: 'https://zoom.us/j/1234567890',
    isActive: true,
  },
  {
    id: 'live2',
    classId: 'class3',
    title: 'Physics Lab Session',
    date: '2026-01-25',
    time: '2:00 PM',
    platform: 'meet',
    link: 'https://meet.google.com/abc-defg-hij',
    isActive: true,
  },
  {
    id: 'live3',
    classId: 'class2',
    title: 'Arabic Poetry Discussion',
    date: '2026-01-26',
    time: '9:00 AM',
    platform: 'zoom',
    link: 'https://zoom.us/j/9876543210',
    isActive: false,
  },
];

// Mock Subscription Plans
export const mockSubscriptionPlans: SubscriptionPlan[] = [
  {
    id: 'plan1',
    name: 'Basic Plan',
    price: 19.99,
    duration: 'monthly',
    features: [
      'Access to 3 core subjects',
      'Weekly live sessions',
      'Basic assignments & quizzes',
      'Standard support',
      'Progress tracking',
    ],
    classIds: ['class1', 'class2', 'class3'],
    maxClasses: 3,
  },
  {
    id: 'plan2',
    name: 'Standard Plan',
    price: 34.99,
    duration: 'monthly',
    features: [
      'Access to 5 subjects',
      'Unlimited live sessions',
      'All assignments & assessments',
      'Priority support',
      'Advanced progress analytics',
      'Downloadable resources',
    ],
    classIds: ['class1', 'class2', 'class3', 'class4', 'class5'],
    maxClasses: 5,
    popular: true,
  },
  {
    id: 'plan3',
    name: 'Premium Plan',
    price: 49.99,
    duration: 'monthly',
    features: [
      'Access to ALL subjects',
      'Unlimited live sessions',
      'All assignments & assessments',
      '24/7 Premium support',
      'Advanced analytics & reports',
      'Downloadable resources',
      'One-on-one tutoring sessions',
      'Exam preparation materials',
    ],
    classIds: ['class1', 'class2', 'class3', 'class4', 'class5', 'class6', 'class7', 'class8'],
    maxClasses: 8,
  },
];

// Mock Student Subscriptions
export const mockStudentSubscriptions: StudentSubscription[] = [
  {
    studentId: 'student1',
    planId: 'plan2',
    enrolledClassIds: ['class1', 'class2', 'class3', 'class4', 'class5'],
    startDate: '2026-01-01',
    endDate: '2026-02-01',
    status: 'active',
  },
  {
    studentId: 'student2',
    planId: 'plan3',
    enrolledClassIds: ['class1', 'class2', 'class3', 'class4', 'class5', 'class6', 'class7'],
    startDate: '2026-01-01',
    endDate: '2026-02-01',
    status: 'active',
  },
  {
    studentId: 'student3',
    planId: 'plan1',
    enrolledClassIds: ['class1', 'class2', 'class3'],
    startDate: '2026-01-01',
    endDate: '2026-02-01',
    status: 'active',
  },
];

// Mock Attendance Records
export const mockAttendanceRecords: AttendanceRecord[] = [
  {
    id: 'att1',
    studentId: 'student1',
    classId: 'class1',
    date: '2026-01-20',
    status: 'present',
  },
  {
    id: 'att2',
    studentId: 'student1',
    classId: 'class1',
    date: '2026-01-22',
    status: 'present',
  },
  {
    id: 'att3',
    studentId: 'student1',
    classId: 'class1',
    date: '2026-01-24',
    status: 'late',
    notes: 'Arrived 10 minutes late',
  },
  {
    id: 'att4',
    studentId: 'student1',
    classId: 'class1',
    date: '2026-01-27',
    status: 'absent',
    notes: 'Sick leave',
  },
  {
    id: 'att5',
    studentId: 'student1',
    classId: 'class1',
    date: '2026-01-29',
    status: 'present',
  },
  {
    id: 'att6',
    studentId: 'student2',
    classId: 'class1',
    date: '2026-01-20',
    status: 'present',
  },
  {
    id: 'att7',
    studentId: 'student2',
    classId: 'class1',
    date: '2026-01-22',
    status: 'absent',
  },
  {
    id: 'att8',
    studentId: 'student2',
    classId: 'class1',
    date: '2026-01-24',
    status: 'late',
  },
  {
    id: 'att9',
    studentId: 'student2',
    classId: 'class1',
    date: '2026-01-27',
    status: 'present',
  },
  {
    id: 'att10',
    studentId: 'student2',
    classId: 'class1',
    date: '2026-01-29',
    status: 'absent',
  },
  {
    id: 'att11',
    studentId: 'student3',
    classId: 'class1',
    date: '2026-01-20',
    status: 'present',
  },
  {
    id: 'att12',
    studentId: 'student3',
    classId: 'class1',
    date: '2026-01-22',
    status: 'present',
  },
  {
    id: 'att13',
    studentId: 'student3',
    classId: 'class1',
    date: '2026-01-24',
    status: 'present',
  },
  {
    id: 'att14',
    studentId: 'student3',
    classId: 'class1',
    date: '2026-01-27',
    status: 'late',
    notes: 'Bus delay',
  },
  {
    id: 'att15',
    studentId: 'student3',
    classId: 'class1',
    date: '2026-01-29',
    status: 'present',
  },
  {
    id: 'att16',
    studentId: 'student4',
    classId: 'class1',
    date: '2026-01-20',
    status: 'absent',
  },
  {
    id: 'att17',
    studentId: 'student4',
    classId: 'class1',
    date: '2026-01-22',
    status: 'present',
  },
  {
    id: 'att18',
    studentId: 'student4',
    classId: 'class1',
    date: '2026-01-24',
    status: 'absent',
  },
  {
    id: 'att19',
    studentId: 'student4',
    classId: 'class1',
    date: '2026-01-27',
    status: 'absent',
  },
  {
    id: 'att20',
    studentId: 'student4',
    classId: 'class1',
    date: '2026-01-29',
    status: 'present',
  },
  {
    id: 'att21',
    studentId: 'student5',
    classId: 'class1',
    date: '2026-01-20',
    status: 'present',
  },
  {
    id: 'att22',
    studentId: 'student5',
    classId: 'class1',
    date: '2026-01-22',
    status: 'late',
  },
  {
    id: 'att23',
    studentId: 'student5',
    classId: 'class1',
    date: '2026-01-24',
    status: 'present',
  },
  {
    id: 'att24',
    studentId: 'student5',
    classId: 'class1',
    date: '2026-01-27',
    status: 'late',
  },
  {
    id: 'att25',
    studentId: 'student5',
    classId: 'class1',
    date: '2026-01-29',
    status: 'absent',
  },
];

// Mock Student Progress
export const mockStudentProgress: StudentProgress[] = [
  {
    studentId: 'student1',
    classId: 'class1',
    overallGrade: 92,
    assignments: {
      completed: 3,
      total: 4,
    },
    attendance: {
      present: 3,
      absent: 1,
      late: 1,
      total: 5,
    },
    lastActivity: '2026-01-26T14:30:00',
  },
  {
    studentId: 'student2',
    classId: 'class1',
    overallGrade: 88,
    assignments: {
      completed: 2,
      total: 4,
    },
    attendance: {
      present: 2,
      absent: 2,
      late: 1,
      total: 5,
    },
    lastActivity: '2026-01-27T16:20:00',
  },
  {
    studentId: 'student3',
    classId: 'class1',
    overallGrade: 95,
    assignments: {
      completed: 4,
      total: 4,
    },
    attendance: {
      present: 4,
      absent: 0,
      late: 1,
      total: 5,
    },
    lastActivity: '2026-01-29T09:15:00',
  },
  {
    studentId: 'student4',
    classId: 'class1',
    overallGrade: 65,
    assignments: {
      completed: 1,
      total: 4,
    },
    attendance: {
      present: 2,
      absent: 3,
      late: 0,
      total: 5,
    },
    lastActivity: '2026-01-25T10:00:00',
  },
  {
    studentId: 'student5',
    classId: 'class1',
    overallGrade: 78,
    assignments: {
      completed: 2,
      total: 4,
    },
    attendance: {
      present: 2,
      absent: 1,
      late: 2,
      total: 5,
    },
    lastActivity: '2026-01-26T11:00:00',
  },
];

// Mock Notifications
export const mockNotifications: Notification[] = [
  {
    id: 'not1',
    type: 'student',
    from: 'Fatima Ahmed',
    message: 'Submitted assignment: Quadratic Equations Worksheet',
    timestamp: '2026-01-29T14:30:00',
    read: false,
  },
  {
    id: 'not2',
    type: 'student',
    from: 'Ali Hassan',
    message: 'Question about Systems of Equations lesson',
    timestamp: '2026-01-29T10:15:00',
    read: false,
  },
  {
    id: 'not3',
    type: 'admin',
    from: 'Administration',
    message: 'Reminder: Submit mid-term grades by February 5th',
    timestamp: '2026-01-28T09:00:00',
    read: true,
  },
  {
    id: 'not4',
    type: 'system',
    from: 'System',
    message: 'New lesson material uploaded successfully',
    timestamp: '2026-01-27T16:45:00',
    read: true,
  },
  {
    id: 'not5',
    type: 'student',
    from: 'Mariam Ould',
    message: 'Request for assignment deadline extension',
    timestamp: '2026-01-26T11:20:00',
    read: false,
  },
];