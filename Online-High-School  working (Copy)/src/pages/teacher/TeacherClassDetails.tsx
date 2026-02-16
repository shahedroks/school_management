import React, { useState, useEffect } from 'react';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { mockClasses, mockAssignments, mockStudents, mockLiveSessions } from '@/data/mockData';
import { useLessons } from '@/contexts/LessonsContext';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Textarea } from '@/app/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/app/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from '@/app/components/ui/dialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/app/components/ui/tabs';
import { Popover, PopoverContent, PopoverTrigger } from '@/app/components/ui/popover';
import { Calendar as CalendarComponent } from '@/app/components/ui/calendar';
import { format } from 'date-fns';
import { ArrowLeft, BookOpen, FileText, Users, Calendar, Clock, Plus, Video, File, Type, Upload, BarChart3, ExternalLink, TrendingUp, TrendingDown, Award, MoreVertical, Copy, Edit, Eye, EyeOff, FolderTree, CalendarIcon, X, Trash2 } from 'lucide-react';

// Live Sessions Tab Component
function TeacherLiveSessionsTab({ classId, className }: { classId: string; className: string }) {
  const classSessions = mockLiveSessions.filter(s => s.classId === classId);

  return (
    <>
      <div className="flex justify-between items-center">
        <p className="text-xs text-muted-foreground">{classSessions.length} session{classSessions.length !== 1 ? 's' : ''}</p>
      </div>

      {classSessions.length === 0 ? (
        <Card className="border-2 border-primary/20">
          <CardContent className="p-8 text-center">
            <Video className="w-10 h-10 text-muted-foreground mx-auto mb-2" />
            <p className="text-sm text-muted-foreground">No live sessions scheduled</p>
            <p className="text-xs text-muted-foreground mt-1">Schedule video calls with your students</p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {classSessions.map(session => (
            <Card key={session.id} className="border-2 border-primary/20 hover:shadow-md transition-shadow">
              <CardContent className="p-3">
                <div className="flex items-start justify-between gap-2 mb-2">
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1 flex-wrap">
                      <h3 className="text-sm font-semibold text-foreground truncate">
                        {session.title}
                      </h3>
                      {session.isActive && (
                        <Badge className="text-[10px] bg-red-500 text-white border-red-500 animate-pulse flex items-center gap-1">
                          <span className="w-1.5 h-1.5 rounded-full bg-green-500 animate-none"></span>
                          Live Now
                        </Badge>
                      )}
                    </div>
                    <div className="flex items-center gap-3 text-xs text-muted-foreground">
                      <div className="flex items-center gap-1">
                        <Calendar className="w-3.5 h-3.5 text-primary" />
                        {new Date(session.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                      </div>
                      <div className="flex items-center gap-1">
                        <Clock className="w-3.5 h-3.5 text-primary" />
                        {session.time}
                      </div>
                    </div>
                  </div>
                  <Badge className={`text-[10px] capitalize ${
                    session.platform === 'zoom' 
                      ? 'bg-blue-500/10 text-blue-600 border-blue-500/20' 
                      : 'bg-green-500/10 text-green-600 border-green-500/20'
                  }`}>
                    {session.platform}
                  </Badge>
                </div>
                <a 
                  href={session.link} 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="block mt-3"
                >
                  <Button 
                    variant="outline" 
                    size="sm" 
                    className="w-full h-8 text-xs border-primary/20 text-primary hover:bg-primary/5"
                  >
                    <ExternalLink className="w-3.5 h-3.5 mr-1.5" />
                    Join Session
                  </Button>
                </a>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </>
  );
}

// Analytics Tab Component  
function TeacherAnalyticsTab({ classId, className }: { classId: string; className: string }) {
  const classData = mockClasses.find(c => c.id === classId);
  const lessons = useLessons(classId);
  const assignments = mockAssignments.filter(a => a.classId === classId);

  // Calculate stats
  const totalStudents = classData?.students || 0;
  const averageGrade = 87;
  const completionRate = 92;
  const attendanceRate = 95;

  return (
    <>
      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-3">
        <Card className="border-2 border-primary/20">
          <CardContent className="p-3">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-xs text-muted-foreground">Avg. Grade</p>
                <p className="text-2xl font-bold text-foreground mt-1">{averageGrade}%</p>
              </div>
              <div className="w-8 h-8 rounded-full bg-secondary/10 flex items-center justify-center">
                <TrendingUp className="w-4 h-4 text-secondary" />
              </div>
            </div>
            <div className="flex items-center gap-1 mt-2">
              <TrendingUp className="w-3 h-3 text-secondary" />
              <span className="text-[10px] text-secondary">+3% from last month</span>
            </div>
          </CardContent>
        </Card>

        <Card className="border-2 border-primary/20">
          <CardContent className="p-3">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-xs text-muted-foreground">Attendance</p>
                <p className="text-2xl font-bold text-foreground mt-1">{attendanceRate}%</p>
              </div>
              <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                <Users className="w-4 h-4 text-primary" />
              </div>
            </div>
            <div className="flex items-center gap-1 mt-2">
              <TrendingUp className="w-3 h-3 text-secondary" />
              <span className="text-[10px] text-secondary">+2% from last month</span>
            </div>
          </CardContent>
        </Card>

        <Card className="border-2 border-primary/20">
          <CardContent className="p-3">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-xs text-muted-foreground">Completion</p>
                <p className="text-2xl font-bold text-foreground mt-1">{completionRate}%</p>
              </div>
              <div className="w-8 h-8 rounded-full bg-accent/10 flex items-center justify-center">
                <FileText className="w-4 h-4 text-accent" />
              </div>
            </div>
            <div className="flex items-center gap-1 mt-2">
              <TrendingUp className="w-3 h-3 text-secondary" />
              <span className="text-[10px] text-secondary">+5% from last month</span>
            </div>
          </CardContent>
        </Card>

        <Card className="border-2 border-primary/20">
          <CardContent className="p-3">
            <div className="flex items-start justify-between">
              <div>
                <p className="text-xs text-muted-foreground">Students</p>
                <p className="text-2xl font-bold text-foreground mt-1">{totalStudents}</p>
              </div>
              <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                <Award className="w-4 h-4 text-primary" />
              </div>
            </div>
            <div className="flex items-center gap-1 mt-2">
              <span className="text-[10px] text-muted-foreground">Enrolled this semester</span>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Content Overview */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="p-3 pb-2">
          <CardTitle className="text-sm font-semibold">Content Overview</CardTitle>
        </CardHeader>
        <CardContent className="p-3 pt-0 space-y-2">
          <div className="flex items-center justify-between p-2 rounded-lg bg-primary/5">
            <div className="flex items-center gap-2">
              <BookOpen className="w-4 h-4 text-primary" />
              <span className="text-sm font-medium">Lessons</span>
            </div>
            <Badge className="text-[10px] bg-primary/10 text-primary border-primary/20">
              {lessons.length}
            </Badge>
          </div>
          <div className="flex items-center justify-between p-2 rounded-lg bg-primary/5">
            <div className="flex items-center gap-2">
              <FileText className="w-4 h-4 text-primary" />
              <span className="text-sm font-medium">Assignments</span>
            </div>
            <Badge className="text-[10px] bg-primary/10 text-primary border-primary/20">
              {assignments.length}
            </Badge>
          </div>
          <div className="flex items-center justify-between p-2 rounded-lg bg-primary/5">
            <div className="flex items-center gap-2">
              <Video className="w-4 h-4 text-primary" />
              <span className="text-sm font-medium">Live Sessions</span>
            </div>
            <Badge className="text-[10px] bg-primary/10 text-primary border-primary/20">
              {mockLiveSessions.filter(s => s.classId === classId).length}
            </Badge>
          </div>
        </CardContent>
      </Card>

      {/* Performance Insight */}
      <Card className="border-2 border-primary/20 bg-primary/5">
        <CardContent className="p-3">
          <div className="flex items-start gap-2">
            <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
              <BarChart3 className="w-4 h-4 text-primary" />
            </div>
            <div>
              <h4 className="text-sm font-semibold text-foreground">Performance Insight</h4>
              <p className="text-xs text-muted-foreground mt-1">
                Your class is performing {averageGrade >= 85 ? 'excellently' : 'well'} with an average grade of {averageGrade}%. 
                Keep up the great work!
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </>
  );
}

export function TeacherClassDetails() {
  const { classId } = useParams<{ classId: string }>();
  const [searchParams, setSearchParams] = useSearchParams();
  const classData = mockClasses.find(c => c.id === classId);
  const { lessons, addLesson, updateLesson, deleteLesson } = useLessons(classId);
  
  // State to manage assignments list with localStorage persistence
  const [assignments, setAssignments] = useState(() => {
    // Try to load from localStorage first
    const savedAssignments = localStorage.getItem('teacherAssignments');
    if (savedAssignments) {
      try {
        const allAssignments = JSON.parse(savedAssignments);
        return allAssignments.filter((a: any) => a.classId === classId);
      } catch (e) {
        console.error('Error loading saved assignments:', e);
      }
    }
    // Initialize with mock assignments for this class
    return mockAssignments.filter(a => a.classId === classId);
  });

  // Save assignments to localStorage whenever they change
  React.useEffect(() => {
    const savedAssignments = localStorage.getItem('teacherAssignments');
    let allAssignments = [];
    
    if (savedAssignments) {
      try {
        allAssignments = JSON.parse(savedAssignments);
        // Remove old assignments for this class
        allAssignments = allAssignments.filter((a: any) => a.classId !== classId);
      } catch (e) {
        console.error('Error loading saved assignments:', e);
      }
    }
    
    // Add current assignments for this class
    const updatedAssignments = [...allAssignments, ...assignments];
    localStorage.setItem('teacherAssignments', JSON.stringify(updatedAssignments));
  }, [assignments, classId]);
  
  const students = mockStudents.slice(0, classData?.students || 20);

  const [isCreateLessonDialogOpen, setIsCreateLessonDialogOpen] = useState(
    searchParams.get('create') === 'lesson'
  );
  const [isEditingLesson, setIsEditingLesson] = useState(false);
  const [editingLessonId, setEditingLessonId] = useState<string | null>(null);
  const [deletingLessonId, setDeletingLessonId] = useState<string | null>(null);
  
  const [isCreateAssignmentDialogOpen, setIsCreateAssignmentDialogOpen] = useState(false);
  const [isEditingAssignment, setIsEditingAssignment] = useState(false);
  const [editingAssignmentId, setEditingAssignmentId] = useState<string | null>(null);
  const [assignmentFormData, setAssignmentFormData] = useState({
    title: '',
    description: '',
    dueDate: '',
    dueTime: '',
    points: '',
  });
  const [assignmentFiles, setAssignmentFiles] = useState<File[]>([]);
  
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  
  // Get today's date in YYYY-MM-DD format for the date input
  const getTodayDate = () => {
    const today = new Date();
    const year = today.getFullYear();
    const month = String(today.getMonth() + 1).padStart(2, '0');
    const day = String(today.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  };
  
  const [lessonFormData, setLessonFormData] = useState({
    title: '',
    description: '',
    type: 'text' as 'text' | 'video',
    chapter: '',
    date: getTodayDate(),
    grade: '',
    subject: 'Mathematics',
  });

  if (!classData) {
    return (
      <div className="p-4">
        <Card className="border-2 border-primary/20">
          <CardContent className="p-12 text-center">
            <p className="text-sm text-muted-foreground">Class not found</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const handleCreateLesson = (status: 'draft' | 'published') => {
    if (isEditingLesson && editingLessonId) {
      // Update existing lesson
      updateLesson(editingLessonId, {
        title: lessonFormData.title,
        description: lessonFormData.description,
        type: lessonFormData.type,
        module: lessonFormData.chapter,
        date: lessonFormData.date,
        grade: lessonFormData.grade,
        subject: lessonFormData.subject,
        status,
        attachedFile: selectedFile?.name,
      });
      setIsEditingLesson(false);
      setEditingLessonId(null);
    } else {
      // Create new lesson
      addLesson({
        classId: classId!,
        title: lessonFormData.title,
        description: lessonFormData.description,
        type: lessonFormData.type,
        chapter: lessonFormData.chapter,
        date: lessonFormData.date,
        grade: lessonFormData.grade,
        subject: lessonFormData.subject,
        status,
        content: '',
        module: lessonFormData.chapter,
        attachedFile: selectedFile?.name,
      });
    }
    
    setIsCreateLessonDialogOpen(false);
    setLessonFormData({
      title: '',
      description: '',
      type: 'text',
      chapter: '',
      date: getTodayDate(),
      grade: '',
      subject: 'Mathematics',
    });
    setSelectedFile(null);
  };

  const handleEditLesson = (lesson: any) => {
    setIsEditingLesson(true);
    setEditingLessonId(lesson.id);
    setLessonFormData({
      title: lesson.title,
      description: lesson.description,
      type: lesson.type,
      chapter: lesson.module || lesson.chapter || '',
      date: lesson.date,
      grade: lesson.grade || '',
      subject: lesson.subject || 'Mathematics',
    });
    // Don't try to recreate the File object, just set to null
    // The file name will be preserved in the lesson object
    setSelectedFile(null);
    setIsCreateLessonDialogOpen(true);
  };

  const handleDeleteLesson = (lessonId: string) => {
    deleteLesson(lessonId);
    setDeletingLessonId(null);
  };

  const handleViewFile = (fileName: string) => {
    // Create a mock file URL - in production, this would be an actual file URL from storage
    const fileUrl = `#/files/${fileName}`;
    // For demo purposes, show an alert. In production, this would open/download the file
    alert(`Opening file: ${fileName}\n\nIn a production environment, this would open or download the file.`);
    // In production, you might do:
    // window.open(fileUrl, '_blank');
  };

  const handleCreateAssignment = () => {
    const newAssignment = {
      id: `assignment-${Date.now()}`,
      classId: classId!,
      title: assignmentFormData.title,
      description: assignmentFormData.description,
      dueDate: assignmentFormData.dueDate,
      dueTime: assignmentFormData.dueTime,
      points: parseInt(assignmentFormData.points, 10),
      files: assignmentFiles.map(file => file.name),
    };
    setAssignments([...assignments, newAssignment]);
    setIsCreateAssignmentDialogOpen(false);
    setAssignmentFormData({
      title: '',
      description: '',
      dueDate: '',
      dueTime: '',
      points: '',
    });
    setAssignmentFiles([]);
  };

  const handleEditAssignment = (assignment: any) => {
    setIsEditingAssignment(true);
    setEditingAssignmentId(assignment.id);
    setAssignmentFormData({
      title: assignment.title,
      description: assignment.description || '',
      dueDate: assignment.dueDate,
      dueTime: assignment.dueTime || '',
      points: assignment.points.toString(),
    });
    setAssignmentFiles([]);
    setIsCreateAssignmentDialogOpen(true);
  };

  const handleUpdateAssignment = () => {
    const updatedAssignments = assignments.map(a =>
      a.id === editingAssignmentId
        ? {
            ...a,
            title: assignmentFormData.title,
            description: assignmentFormData.description,
            dueDate: assignmentFormData.dueDate,
            dueTime: assignmentFormData.dueTime,
            points: parseInt(assignmentFormData.points, 10),
            files: assignmentFiles.length > 0 ? assignmentFiles.map(file => file.name) : a.files,
          }
        : a
    );
    setAssignments(updatedAssignments);
    setIsCreateAssignmentDialogOpen(false);
    setIsEditingAssignment(false);
    setEditingAssignmentId(null);
    setAssignmentFormData({
      title: '',
      description: '',
      dueDate: '',
      dueTime: '',
      points: '',
    });
    setAssignmentFiles([]);
  };

  const handleDeleteAssignment = (assignmentId: string) => {
    if (window.confirm('Are you sure you want to delete this assignment?')) {
      const updatedAssignments = assignments.filter(a => a.id !== assignmentId);
      setAssignments(updatedAssignments);
    }
  };

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm space-y-3">
        <Link to="/teacher/classes">
          <Button variant="ghost" size="sm" className="h-8 text-white hover:bg-white/20 mb-2 -ml-2">
            <ArrowLeft className="w-4 h-4 mr-1.5" />
            Back to Classes
          </Button>
        </Link>

        <div>
          <h1 className="text-xl font-bold">{classData.name}</h1>
          <p className="text-sm text-white/90 mt-1">Manage lessons, assignments, and students</p>
        </div>

        {/* Class Info */}
        <div className="space-y-1.5 pt-2 border-t border-white/20">
          <div className="flex items-center gap-2 text-xs text-white/90">
            <Calendar className="w-3.5 h-3.5" />
            <span>{classData.schedule}</span>
          </div>
          <div className="flex items-center gap-2 text-xs text-white/90">
            <Users className="w-3.5 h-3.5" />
            <span>{classData.students} students enrolled</span>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="lessons" className="space-y-3">
        <TabsList className="!w-full h-auto p-0.5 bg-white border border-border/50 gap-0.5 !flex rounded-lg shadow-sm">
          <TabsTrigger value="lessons" className="flex-1 flex-col items-center justify-center text-[11px] px-1.5 py-2 rounded-md data-[state=active]:bg-primary data-[state=active]:text-white data-[state=active]:shadow-sm">
            <BookOpen className="w-4 h-4 mb-0.5" />
            <span className="font-medium">Lessons</span>
          </TabsTrigger>
          <TabsTrigger value="assignments" className="flex-1 flex-col items-center justify-center text-[11px] px-1.5 py-2 rounded-md data-[state=active]:bg-primary data-[state=active]:text-white data-[state=active]:shadow-sm">
            <FileText className="w-4 h-4 mb-0.5" />
            <span className="font-medium">Assignment</span>
          </TabsTrigger>
          <TabsTrigger value="students" className="flex-1 flex-col items-center justify-center text-[11px] px-1.5 py-2 rounded-md data-[state=active]:bg-primary data-[state=active]:text-white data-[state=active]:shadow-sm">
            <Users className="w-4 h-4 mb-0.5" />
            <span className="font-medium">Students</span>
          </TabsTrigger>
          <TabsTrigger value="live" className="flex-1 flex-col items-center justify-center text-[11px] px-1.5 py-2 rounded-md data-[state=active]:bg-primary data-[state=active]:text-white data-[state=active]:shadow-sm">
            <Video className="w-4 h-4 mb-0.5" />
            <span className="font-medium">Live</span>
          </TabsTrigger>
          <TabsTrigger value="analytics" className="flex-1 flex-col items-center justify-center text-[11px] px-1.5 py-2 rounded-md data-[state=active]:bg-primary data-[state=active]:text-white data-[state=active]:shadow-sm">
            <BarChart3 className="w-4 h-4 mb-0.5" />
            <span className="font-medium">Analytics</span>
          </TabsTrigger>
        </TabsList>

        {/* Lessons Tab */}
        <TabsContent value="lessons" className="space-y-3 mt-3">
          <div className="flex justify-between items-center">
            <p className="text-xs text-muted-foreground">{lessons.length} lessons</p>
            <Dialog open={isCreateLessonDialogOpen} onOpenChange={setIsCreateLessonDialogOpen}>
              <DialogTrigger asChild>
                <Button size="sm" className="h-8 text-xs bg-primary">
                  <Plus className="w-3.5 h-3.5 mr-1" />
                  Add Lesson
                </Button>
              </DialogTrigger>
              <DialogContent className="w-[380px] max-h-[800px] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle className="text-base">
                    {isEditingLesson ? 'Edit Lesson' : 'Create New Lesson'}
                  </DialogTitle>
                </DialogHeader>
                <div className="space-y-4 py-3">
                  {/* Lesson Title */}
                  <div className="space-y-2">
                    <Label htmlFor="lesson-title" className="text-xs font-medium">
                      Lesson Title *
                    </Label>
                    <Input
                      id="lesson-title"
                      placeholder="e.g., Introduction to Algebra"
                      value={lessonFormData.title}
                      onChange={(e) => setLessonFormData({ ...lessonFormData, title: e.target.value })}
                      className="h-9 text-sm border-primary/20"
                    />
                  </div>

                  {/* Description */}
                  <div className="space-y-2">
                    <Label htmlFor="lesson-description" className="text-xs font-medium">
                      Description
                    </Label>
                    <Textarea
                      id="lesson-description"
                      placeholder="Describe the lesson content..."
                      value={lessonFormData.description}
                      onChange={(e) => setLessonFormData({ ...lessonFormData, description: e.target.value })}
                      className="min-h-[80px] text-sm border-primary/20"
                    />
                  </div>

                  {/* Content Type */}
                  <div className="space-y-2">
                    <Label htmlFor="lesson-type" className="text-xs font-medium">
                      Content Type *
                    </Label>
                    <Select
                      value={lessonFormData.type}
                      onValueChange={(value) => setLessonFormData({ ...lessonFormData, type: value })}
                    >
                      <SelectTrigger className="h-9 text-sm border-primary/20">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="text" className="text-sm">Text / PDF</SelectItem>
                        <SelectItem value="video" className="text-sm">Video</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  {/* Chapter */}
                  <div className="space-y-2">
                    <Label htmlFor="lesson-chapter" className="text-xs font-medium">
                      Chapter *
                    </Label>
                    <Input
                      id="lesson-chapter"
                      placeholder="e.g., Chapter 3: Equations"
                      value={lessonFormData.chapter}
                      onChange={(e) => setLessonFormData({ ...lessonFormData, chapter: e.target.value })}
                      className="h-9 text-sm border-primary/20"
                    />
                  </div>

                  {/* Grade and Subject in Grid */}
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-2">
                      <Label htmlFor="lesson-grade" className="text-xs font-medium">
                        Grade *
                      </Label>
                      <Select
                        value={lessonFormData.grade}
                        onValueChange={(value) => setLessonFormData({ ...lessonFormData, grade: value })}
                      >
                        <SelectTrigger className="h-9 text-sm border-primary/20">
                          <SelectValue placeholder="Select grade" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="4th" className="text-sm">4th Grade</SelectItem>
                          <SelectItem value="5th" className="text-sm">5th Grade</SelectItem>
                          <SelectItem value="6th" className="text-sm">6th Grade</SelectItem>
                          <SelectItem value="7th" className="text-sm">7th Grade</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="lesson-subject" className="text-xs font-medium">
                        Subject *
                      </Label>
                      <Select
                        value={lessonFormData.subject}
                        onValueChange={(value) => setLessonFormData({ ...lessonFormData, subject: value })}
                      >
                        <SelectTrigger className="h-9 text-sm border-primary/20">
                          <SelectValue placeholder="Subject" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="Mathematics" className="text-sm">Mathematics</SelectItem>
                          <SelectItem value="Physics" className="text-sm">Physics</SelectItem>
                          <SelectItem value="Chemistry" className="text-sm">Chemistry</SelectItem>
                          <SelectItem value="SVT" className="text-sm">SVT</SelectItem>
                          <SelectItem value="French" className="text-sm">French</SelectItem>
                          <SelectItem value="Arabic" className="text-sm">Arabic</SelectItem>
                          <SelectItem value="English" className="text-sm">English</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  {/* Date with Date Picker */}
                  <div className="space-y-2">
                    <Label className="text-xs font-medium">
                      Date *
                    </Label>
                    <Popover>
                      <PopoverTrigger asChild>
                        <Button
                          variant="outline"
                          className={`w-full h-9 justify-start text-left text-sm font-normal border-primary/20 ${
                            !lessonFormData.date && "text-muted-foreground"
                          }`}
                        >
                          <CalendarIcon className="mr-2 h-4 w-4" />
                          {lessonFormData.date ? format(new Date(lessonFormData.date), "PPP") : <span>Pick a date</span>}
                        </Button>
                      </PopoverTrigger>
                      <PopoverContent className="w-auto p-0" align="start">
                        <CalendarComponent
                          mode="single"
                          selected={lessonFormData.date ? new Date(lessonFormData.date) : undefined}
                          onSelect={(date) => {
                            if (date) {
                              setLessonFormData({ ...lessonFormData, date: format(date, "yyyy-MM-dd") });
                            }
                          }}
                          initialFocus
                        />
                      </PopoverContent>
                    </Popover>
                  </div>

                  {/* Attach Files */}
                  <div className="space-y-2">
                    <Label htmlFor="file" className="text-xs font-medium">
                      Attach Files
                    </Label>
                    <input
                      id="lesson-file-upload"
                      type="file"
                      accept=".pdf,.doc,.docx,.ppt,.pptx"
                      onChange={(e) => {
                        if (e.target.files && e.target.files[0]) {
                          setSelectedFile(e.target.files[0]);
                        }
                      }}
                      className="hidden"
                    />
                    <label
                      htmlFor="lesson-file-upload"
                      className="block border-2 border-dashed border-primary/20 rounded-lg p-4 text-center hover:border-primary/40 transition-colors cursor-pointer"
                    >
                      <Upload className="w-8 h-8 text-primary mx-auto mb-2" />
                      {selectedFile ? (
                        <p className="text-xs text-primary font-medium">{selectedFile.name}</p>
                      ) : (
                        <p className="text-xs text-muted-foreground">
                          Click to upload PDF or documents
                        </p>
                      )}
                    </label>
                  </div>
                </div>
                <DialogFooter className="gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      setIsCreateLessonDialogOpen(false);
                      if (isEditingLesson) {
                        setIsEditingLesson(false);
                        setEditingLessonId(null);
                        setLessonFormData({
                          title: '',
                          description: '',
                          type: 'text',
                          chapter: '',
                          date: getTodayDate(),
                          grade: '',
                          subject: 'Mathematics',
                        });
                        setSelectedFile(null);
                      }
                    }}
                    className="h-9 text-xs"
                  >
                    Cancel
                  </Button>
                  <Button
                    size="sm"
                    onClick={() => handleCreateLesson('draft')}
                    disabled={!lessonFormData.title || !lessonFormData.chapter || !lessonFormData.date || !lessonFormData.grade || !lessonFormData.subject}
                    className="h-9 text-xs bg-muted text-foreground hover:bg-muted/90"
                  >
                    Save as Draft
                  </Button>
                  <Button
                    size="sm"
                    onClick={() => handleCreateLesson('published')}
                    disabled={!lessonFormData.title || !lessonFormData.chapter || !lessonFormData.date || !lessonFormData.grade || !lessonFormData.subject}
                    className="h-9 text-xs bg-primary"
                  >
                    {isEditingLesson ? 'Update Lesson' : 'Create Lesson'}
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>

          {lessons.length === 0 ? (
            <Card className="border-2 border-primary/20">
              <CardContent className="p-8 text-center">
                <BookOpen className="w-10 h-10 text-muted-foreground mx-auto mb-2" />
                <p className="text-sm text-muted-foreground">No lessons created yet</p>
              </CardContent>
            </Card>
          ) : (
            <>
              {/* Group lessons by grade */}
              {['4th', '5th', '6th', '7th'].map(grade => {
                const gradeLessons = lessons.filter(lesson => lesson.grade === grade);
                if (gradeLessons.length === 0) return null;
                
                return (
                  <div key={grade} className="space-y-3">
                    {/* Grade Header */}
                    <div className="flex items-center gap-2">
                      <div className="h-px bg-border flex-1" />
                      <h3 className="text-xs font-semibold text-primary">{grade} Grade</h3>
                      <div className="h-px bg-border flex-1" />
                    </div>
                    
                    {/* Lessons for this grade */}
                    <div className="space-y-3">
                      {gradeLessons.map(lesson => (
                        <Card key={lesson.id} className="hover:shadow-md transition-shadow border-2 border-primary/20">
                          <CardContent className="p-3">
                            <div className="flex items-start justify-between gap-2 mb-2">
                              <div className="flex-1 min-w-0">
                                <div className="flex items-center gap-2 mb-1 flex-wrap">
                                  <h3 className="text-sm font-semibold text-foreground truncate">
                                    {lesson.title}
                                  </h3>
                                  <Badge className={`text-[10px] capitalize flex items-center gap-0.5 ${
                                    lesson.status === 'published'
                                      ? 'bg-secondary/10 text-secondary border-secondary/20'
                                      : 'bg-amber-500/10 text-amber-600 border-amber-500/20'
                                  }`}>
                                    {lesson.status === 'published' ? (
                                      <><Eye className="w-3 h-3" /> Published</>
                                    ) : (
                                      <><EyeOff className="w-3 h-3" /> Draft</>
                                    )}
                                  </Badge>
                                  <Badge className="text-[10px] bg-primary/10 text-primary border-primary/20 capitalize">
                                    {lesson.type}
                                  </Badge>
                                  {lesson.subject && (
                                    <Badge className="text-[10px] bg-accent/10 text-accent border-accent/20">
                                      {lesson.subject}
                                    </Badge>
                                  )}
                                </div>
                                <p className="text-xs text-muted-foreground line-clamp-1 mt-0.5">
                                  {lesson.description}
                                </p>
                                {lesson.module && (
                                  <div className="flex items-center gap-1 mt-1">
                                    <FolderTree className="w-3 h-3 text-primary" />
                                    <span className="text-[10px] text-primary font-medium">{lesson.module}</span>
                                  </div>
                                )}
                                {lesson.attachedFile && (
                                  <button
                                    onClick={() => handleViewFile(lesson.attachedFile)}
                                    className="flex items-center gap-1 mt-1 hover:bg-muted/50 rounded px-1 py-0.5 -ml-1 transition-colors group"
                                  >
                                    <File className="w-3 h-3 text-muted-foreground group-hover:text-foreground transition-colors" />
                                    <span className="text-[10px] text-muted-foreground group-hover:text-foreground font-medium transition-colors underline decoration-dotted">
                                      {lesson.attachedFile}
                                    </span>
                                  </button>
                                )}
                              </div>
                            </div>
                            <div className="flex items-center justify-between gap-2 mt-2 pt-2 border-t border-border">
                              <div className="flex items-center gap-3 text-xs text-muted-foreground">
                                <div className="flex items-center gap-1">
                                  <Calendar className="w-3.5 h-3.5 text-primary" />
                                  {new Date(lesson.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                                </div>
                                <div className="flex items-center gap-1">
                                  <Clock className="w-3 h-3 text-muted-foreground" />
                                  <span className="text-[10px]">Updated {new Date(lesson.lastUpdated).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</span>
                                </div>
                              </div>
                              <div className="flex items-center gap-1">
                                <Button
                                  size="sm"
                                  variant="ghost"
                                  className="h-7 px-2 text-xs"
                                  onClick={(e) => {
                                    e.preventDefault();
                                    updateLesson(lesson.id, {
                                      status: lesson.status === 'published' ? 'draft' : 'published'
                                    });
                                  }}
                                >
                                  {lesson.status === 'published' ? (
                                    <EyeOff className="w-3.5 h-3.5" />
                                  ) : (
                                    <Eye className="w-3.5 h-3.5" />
                                  )}
                                </Button>
                                <Button
                                  size="sm"
                                  variant="ghost"
                                  className="h-7 px-2 text-xs"
                                  onClick={(e) => {
                                    e.preventDefault();
                                    handleEditLesson(lesson);
                                  }}
                                >
                                  <Edit className="w-3.5 h-3.5" />
                                </Button>
                                <Dialog open={deletingLessonId === lesson.id} onOpenChange={(open) => !open && setDeletingLessonId(null)}>
                                  <DialogTrigger asChild>
                                    <Button
                                      size="sm"
                                      variant="ghost"
                                      className="h-7 px-2 text-xs text-red-500 hover:text-red-600 hover:bg-red-50"
                                      onClick={(e) => {
                                        e.preventDefault();
                                        setDeletingLessonId(lesson.id);
                                      }}
                                    >
                                      <Trash2 className="w-3.5 h-3.5" />
                                    </Button>
                                  </DialogTrigger>
                                  <DialogContent className="w-[360px]">
                                    <DialogHeader>
                                      <DialogTitle className="text-base">Delete Lesson</DialogTitle>
                                    </DialogHeader>
                                    <div className="py-3">
                                      <p className="text-sm text-muted-foreground">
                                        Are you sure you want to delete "{lesson.title}"? This action cannot be undone.
                                      </p>
                                    </div>
                                    <DialogFooter className="gap-2">
                                      <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => setDeletingLessonId(null)}
                                        className="h-9 text-xs"
                                      >
                                        Cancel
                                      </Button>
                                      <Button
                                        size="sm"
                                        className="h-9 text-xs bg-red-500 hover:bg-red-600"
                                        onClick={() => handleDeleteLesson(lesson.id)}
                                      >
                                        Delete
                                      </Button>
                                    </DialogFooter>
                                  </DialogContent>
                                </Dialog>
                              </div>
                            </div>
                          </CardContent>
                        </Card>
                      ))}
                    </div>
                  </div>
                );
              })}
            </>
          )}
        </TabsContent>

        {/* Assignments Tab */}
        <TabsContent value="assignments" className="space-y-3 mt-3">
          <div className="flex justify-between items-center">
            <p className="text-xs text-muted-foreground">{assignments.length} assignments</p>
            <Dialog open={isCreateAssignmentDialogOpen} onOpenChange={setIsCreateAssignmentDialogOpen}>
              <DialogTrigger asChild>
                <Button size="sm" className="h-8 text-xs bg-primary">
                  <Plus className="w-3.5 h-3.5 mr-1" />
                  Create Assignment
                </Button>
              </DialogTrigger>
              <DialogContent className="w-[380px] max-h-[800px] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle className="text-base">Create New Assignment</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 py-3">
                  {/* Assignment Title */}
                  <div className="space-y-2">
                    <Label htmlFor="assignment-title" className="text-xs font-medium">
                      Assignment Title *
                    </Label>
                    <Input
                      id="assignment-title"
                      placeholder="e.g., Math Homework"
                      value={assignmentFormData.title}
                      onChange={(e) => setAssignmentFormData({ ...assignmentFormData, title: e.target.value })}
                      className="h-9 text-sm border-primary/20"
                    />
                  </div>

                  {/* Description */}
                  <div className="space-y-2">
                    <Label htmlFor="assignment-description" className="text-xs font-medium">
                      Description
                    </Label>
                    <Textarea
                      id="assignment-description"
                      placeholder="Describe the assignment content..."
                      value={assignmentFormData.description}
                      onChange={(e) => setAssignmentFormData({ ...assignmentFormData, description: e.target.value })}
                      className="min-h-[80px] text-sm border-primary/20"
                    />
                  </div>

                  {/* Due Date with Date Picker */}
                  <div className="space-y-2">
                    <Label className="text-xs font-medium">
                      Due Date *
                    </Label>
                    <Popover>
                      <PopoverTrigger asChild>
                        <Button
                          variant="outline"
                          className={`w-full h-9 justify-start text-left text-sm font-normal border-primary/20 ${
                            !assignmentFormData.dueDate && "text-muted-foreground"
                          }`}
                        >
                          <CalendarIcon className="mr-2 h-4 w-4" />
                          {assignmentFormData.dueDate ? format(new Date(assignmentFormData.dueDate), "PPP") : <span>Pick a date</span>}
                        </Button>
                      </PopoverTrigger>
                      <PopoverContent className="w-auto p-0" align="start">
                        <CalendarComponent
                          mode="single"
                          selected={assignmentFormData.dueDate ? new Date(assignmentFormData.dueDate) : undefined}
                          onSelect={(date) => {
                            if (date) {
                              setAssignmentFormData({ ...assignmentFormData, dueDate: format(date, "yyyy-MM-dd") });
                            }
                          }}
                          initialFocus
                        />
                      </PopoverContent>
                    </Popover>
                  </div>

                  {/* Due Time */}
                  <div className="space-y-2">
                    <Label htmlFor="assignment-due-time" className="text-xs font-medium">
                      Due Time
                    </Label>
                    <Input
                      id="assignment-due-time"
                      type="time"
                      value={assignmentFormData.dueTime}
                      onChange={(e) => setAssignmentFormData({ ...assignmentFormData, dueTime: e.target.value })}
                      className="h-9 text-sm border-primary/20"
                    />
                  </div>

                  {/* Points */}
                  <div className="space-y-2">
                    <Label htmlFor="assignment-points" className="text-xs font-medium">
                      Points *
                    </Label>
                    <Input
                      id="assignment-points"
                      placeholder="e.g., 100"
                      value={assignmentFormData.points}
                      onChange={(e) => setAssignmentFormData({ ...assignmentFormData, points: e.target.value })}
                      className="h-9 text-sm border-primary/20"
                    />
                  </div>

                  {/* Attach Files */}
                  <div className="space-y-2">
                    <Label htmlFor="file" className="text-xs font-medium">
                      Attach Files
                    </Label>
                    <input
                      id="assignment-file-upload"
                      type="file"
                      accept=".pdf,.doc,.docx,.ppt,.pptx"
                      onChange={(e) => {
                        if (e.target.files) {
                          setAssignmentFiles(Array.from(e.target.files));
                        }
                      }}
                      className="hidden"
                      multiple
                    />
                    <label
                      htmlFor="assignment-file-upload"
                      className="block border-2 border-dashed border-primary/20 rounded-lg p-4 text-center hover:border-primary/40 transition-colors cursor-pointer"
                    >
                      <Upload className="w-8 h-8 text-primary mx-auto mb-2" />
                      {assignmentFiles.length > 0 ? (
                        <p className="text-xs text-primary font-medium">
                          {assignmentFiles.map(file => file.name).join(', ')}
                        </p>
                      ) : (
                        <p className="text-xs text-muted-foreground">
                          Click to upload PDF or documents
                        </p>
                      )}
                    </label>
                  </div>
                </div>
                <DialogFooter className="gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setIsCreateAssignmentDialogOpen(false)}
                    className="h-9 text-xs"
                  >
                    Cancel
                  </Button>
                  {isEditingAssignment ? (
                    <Button
                      size="sm"
                      onClick={handleUpdateAssignment}
                      disabled={!assignmentFormData.title || !assignmentFormData.dueDate || !assignmentFormData.points}
                      className="h-9 text-xs bg-primary"
                    >
                      Update Assignment
                    </Button>
                  ) : (
                    <Button
                      size="sm"
                      onClick={handleCreateAssignment}
                      disabled={!assignmentFormData.title || !assignmentFormData.dueDate || !assignmentFormData.points}
                      className="h-9 text-xs bg-primary"
                    >
                      Create Assignment
                    </Button>
                  )}
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>

          {assignments.length === 0 ? (
            <Card className="border-2 border-primary/20">
              <CardContent className="p-8 text-center">
                <FileText className="w-10 h-10 text-muted-foreground mx-auto mb-2" />
                <p className="text-sm text-muted-foreground">No assignments created yet</p>
              </CardContent>
            </Card>
          ) : (
            <div className="space-y-3">
              {assignments.map(assignment => (
                <Card key={assignment.id} className="hover:shadow-md transition-shadow border-2 border-primary/20">
                  <CardContent className="p-3">
                    <div className="flex items-start justify-between gap-2 mb-2">
                      <div className="flex-1 min-w-0">
                        <h3 className="text-sm font-semibold text-foreground truncate">
                          {assignment.title}
                        </h3>
                        <p className="text-xs text-muted-foreground line-clamp-2 mt-0.5">
                          {assignment.description}
                        </p>
                      </div>
                      <Badge className="text-[10px] bg-primary/10 text-primary border-primary/20">
                        {assignment.points} pts
                      </Badge>
                    </div>
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <Calendar className="w-3.5 h-3.5 text-primary" />
                      <span>
                        Due: {new Date(assignment.dueDate).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                        })}
                        {assignment.dueTime && ` at ${assignment.dueTime}`}
                      </span>
                    </div>
                    {assignment.files && assignment.files.length > 0 && (
                      <div className="flex items-center gap-2 text-xs text-muted-foreground mt-2">
                        <File className="w-3.5 h-3.5 text-primary" />
                        <span className="truncate">
                          {assignment.files.length === 1 
                            ? assignment.files[0] 
                            : `${assignment.files.length} files attached`}
                        </span>
                      </div>
                    )}
                    <div className="flex items-center justify-between gap-2 mt-3 pt-2 border-t border-border">
                      <Link to={`/teacher/assignments/${assignment.id}`} className="flex-1">
                        <Button
                          variant="outline"
                          size="sm"
                          className="w-full h-8 text-xs border-primary/20 text-primary hover:bg-primary/5"
                        >
                          View Submissions
                        </Button>
                      </Link>
                      <div className="flex items-center gap-1">
                        <Button
                          size="sm"
                          variant="ghost"
                          className="h-7 px-2 text-xs"
                          onClick={() => handleEditAssignment(assignment)}
                        >
                          <Edit className="w-3.5 h-3.5" />
                        </Button>
                        <Button
                          size="sm"
                          variant="ghost"
                          className="h-7 px-2 text-xs text-destructive hover:text-destructive"
                          onClick={() => handleDeleteAssignment(assignment.id)}
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </Button>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </TabsContent>

        {/* Students Tab */}
        <TabsContent value="students" className="space-y-3 mt-3">
          <div className="flex justify-between items-center">
            <p className="text-xs text-muted-foreground">{students.length} students enrolled</p>
          </div>

          <div className="space-y-2 max-h-[500px] overflow-y-auto">
            {students.map((student, index) => (
              <Card key={student.id} className="border-2 border-primary/20">
                <CardContent className="p-3">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                        <span className="text-sm font-semibold text-primary">
                          {student.name.split(' ').map(n => n[0]).join('')}
                        </span>
                      </div>
                      <div className="min-w-0">
                        <p className="text-sm font-medium text-foreground truncate">{student.name}</p>
                        <p className="text-xs text-muted-foreground truncate">{student.email}</p>
                      </div>
                    </div>
                    <Badge className="text-[10px] bg-secondary/10 text-secondary border-secondary/20 flex-shrink-0">
                      {85 + index}%
                    </Badge>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </TabsContent>

        {/* Live Sessions Tab */}
        <TabsContent value="live" className="space-y-3 mt-3">
          <TeacherLiveSessionsTab classId={classId!} className={classData.name} />
        </TabsContent>

        {/* Analytics Tab */}
        <TabsContent value="analytics" className="space-y-3 mt-3">
          <TeacherAnalyticsTab classId={classId!} className={classData.name} />
        </TabsContent>
      </Tabs>
    </div>
  );
}