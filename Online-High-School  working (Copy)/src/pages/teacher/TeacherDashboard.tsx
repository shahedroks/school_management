import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { useLanguage } from '@/contexts/LanguageContext';
import { mockClasses, mockSubmissions, mockTimetable, mockLiveSessions } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Button } from '@/app/components/ui/button';
import { Badge } from '@/app/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from '@/app/components/ui/dialog';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Textarea } from '@/app/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/app/components/ui/select';
import { Popover, PopoverContent, PopoverTrigger } from '@/app/components/ui/popover';
import { Calendar as CalendarComponent } from '@/app/components/ui/calendar';
import { format } from 'date-fns';
import { 
  BookOpen, 
  Users, 
  CheckCircle, 
  Clock,
  Calendar,
  Video,
  Plus,
  FileText,
  CalendarPlus,
  Upload,
  CalendarIcon
} from 'lucide-react';

export function TeacherDashboard() {
  const { user } = useAuth();
  const { t } = useLanguage();
  
  const [isCreateLessonOpen, setIsCreateLessonOpen] = useState(false);
  const [isCreateAssignmentOpen, setIsCreateAssignmentOpen] = useState(false);
  const [isScheduleSessionOpen, setIsScheduleSessionOpen] = useState(false);
  
  const [lessonForm, setLessonForm] = useState({
    title: '',
    description: '',
    type: 'text',
    date: '',
    chapter: '',
    grade: '',
    subject: 'Mathematics',
    className: '',
    status: 'draft',
  });

  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  
  const [assignmentForm, setAssignmentForm] = useState({
    title: '',
    description: '',
    dueDate: '',
    dueTime: '',
    points: '',
  });

  const [sessionForm, setSessionForm] = useState({
    title: '',
    className: '',
    subject: '',
    grade: '',
    date: '',
    time: '',
    platform: 'Zoom',
    meetingLink: '',
  });

  // Filter classes for this teacher (Mohammed Ould - teacher1)
  const myClasses = mockClasses.filter(cls => cls.teacherId === 'teacher1');
  
  const pendingGrading = mockSubmissions.filter(s => !s.grade);
  
  // Get today's day name
  const today = new Date().toLocaleDateString('en-US', { weekday: 'long' });
  // Filter today's classes to only show classes taught by this teacher
  const todayClasses = mockTimetable.filter(entry => {
    const entryClass = mockClasses.find(cls => cls.id === entry.classId);
    return entry.day === today && entryClass?.teacherId === 'teacher1';
  });
  
  // Get upcoming live sessions (next 2 days)
  const upcomingSessions = mockLiveSessions.filter(session => {
    const sessionDate = new Date(session.date);
    const now = new Date();
    const twoDaysFromNow = new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000);
    return sessionDate >= now && sessionDate <= twoDaysFromNow;
  });

  const stats = [
    {
      label: t('classes.myClasses'),
      value: myClasses.length,
      icon: BookOpen,
      color: 'text-primary',
      bgColor: 'bg-primary/10',
    },
    {
      label: t('classes.totalStudents'),
      value: myClasses.reduce((sum, c) => sum + c.students, 0),
      icon: Users,
      color: 'text-secondary',
      bgColor: 'bg-secondary/10',
    },
    {
      label: t('assignments.pendingGrading'),
      value: pendingGrading.length,
      icon: Clock,
      color: 'text-accent',
      bgColor: 'bg-accent/20',
    },
    {
      label: t('assignments.graded'),
      value: mockSubmissions.filter(s => s.grade).length,
      icon: CheckCircle,
      color: 'text-secondary',
      bgColor: 'bg-secondary/10',
    },
  ];

  return (
    <div className="space-y-4 pb-4">
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <h1 className="text-xl font-bold">
          {t('dashboard.welcomeBack')}, {user?.name?.split(' ')[0]}!
        </h1>
        <p className="text-sm text-white/90 mt-0.5">{t('dashboard.teachingOverview')}</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-3">
        {stats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <Card key={index} className="border-border shadow-sm">
              <CardContent className="p-3">
                <div className="flex flex-col gap-2">
                  <div className={`p-2 rounded-lg ${stat.bgColor} self-start`}>
                    <Icon className={`w-4 h-4 ${stat.color}`} />
                  </div>
                  <div>
                    <p className="text-lg font-bold text-foreground">{stat.value}</p>
                    <p className="text-[10px] text-muted-foreground leading-tight">{stat.label}</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Quick Actions */}
      <Card className="border-2 border-primary/20 shadow-sm">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="text-base text-foreground">{t('actions.quickActions')}</CardTitle>
        </CardHeader>
        <CardContent className="pt-3 space-y-3">
          {/* Create New Lesson Dialog */}
          <Dialog open={isCreateLessonOpen} onOpenChange={setIsCreateLessonOpen}>
            <DialogTrigger asChild>
              <Button className="w-full h-9 text-xs bg-primary hover:bg-primary/90">
                <Plus className="w-3.5 h-3.5 mr-1.5" />
                Create New Lesson
              </Button>
            </DialogTrigger>
            <DialogContent className="w-[380px]">
              <DialogHeader>
                <DialogTitle className="text-base">Create New Lesson</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 py-3">
                <div className="space-y-2">
                  <Label htmlFor="lesson-title" className="text-xs font-medium">
                    Lesson Title *
                  </Label>
                  <Input
                    id="lesson-title"
                    placeholder="e.g., Introduction to Algebra"
                    value={lessonForm.title}
                    onChange={(e) => setLessonForm({ ...lessonForm, title: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="lesson-type" className="text-xs font-medium">
                    Content Type *
                  </Label>
                  <Select
                    value={lessonForm.type}
                    onValueChange={(value) => setLessonForm({ ...lessonForm, type: value })}
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

                <div className="space-y-2">
                  <Label htmlFor="lesson-description" className="text-xs font-medium">
                    Description
                  </Label>
                  <Textarea
                    id="lesson-description"
                    placeholder="Describe the lesson content..."
                    value={lessonForm.description}
                    onChange={(e) => setLessonForm({ ...lessonForm, description: e.target.value })}
                    className="min-h-20 text-sm border-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="lesson-chapter" className="text-xs font-medium">
                    Chapter *
                  </Label>
                  <Input
                    id="lesson-chapter"
                    placeholder="e.g., Chapter 3: Equations"
                    value={lessonForm.chapter}
                    onChange={(e) => setLessonForm({ ...lessonForm, chapter: e.target.value })}
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
                      value={lessonForm.grade}
                      onValueChange={(value) => setLessonForm({ ...lessonForm, grade: value })}
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
                      value={lessonForm.subject}
                      onValueChange={(value) => setLessonForm({ ...lessonForm, subject: value })}
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

                {/* Class Name */}
                <div className="space-y-2">
                  <Label htmlFor="lesson-class-name" className="text-xs font-medium">
                    Class Name *
                  </Label>
                  <Input
                    id="lesson-class-name"
                    placeholder="e.g., 4th Grade - Math A"
                    value={lessonForm.className}
                    onChange={(e) => setLessonForm({ ...lessonForm, className: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label className="text-xs font-medium">
                    Date *
                  </Label>
                  <Popover>
                    <PopoverTrigger asChild>
                      <Button
                        variant="outline"
                        className={`w-full h-9 justify-start text-left text-sm font-normal border-primary/20 ${
                          !lessonForm.date && "text-muted-foreground"
                        }`}
                      >
                        <CalendarIcon className="mr-2 h-4 w-4" />
                        {lessonForm.date ? format(new Date(lessonForm.date), "PPP") : <span>Pick a date</span>}
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent className="w-auto p-0" align="start">
                      <CalendarComponent
                        mode="single"
                        selected={lessonForm.date ? new Date(lessonForm.date) : undefined}
                        onSelect={(date) => {
                          if (date) {
                            setLessonForm({ ...lessonForm, date: format(date, "yyyy-MM-dd") });
                          }
                        }}
                        initialFocus
                      />
                    </PopoverContent>
                  </Popover>
                </div>

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
                    setIsCreateLessonOpen(false);
                    setLessonForm({ title: '', description: '', type: 'text', date: '', chapter: '', grade: '', subject: 'Mathematics', className: '', status: 'draft' });
                  }}
                  className="h-9 text-xs"
                >
                  Cancel
                </Button>
                <Button
                  size="sm"
                  onClick={() => {
                    alert(`Lesson saved as draft!\\n\\n${lessonForm.title}\\nType: ${lessonForm.type}\\nChapter: ${lessonForm.chapter}\\nGrade: ${lessonForm.grade}\\nSubject: ${lessonForm.subject}\\nClass: ${lessonForm.className}\\nDate: ${lessonForm.date}\\nStatus: Draft`);
                    setIsCreateLessonOpen(false);
                    setLessonForm({ title: '', description: '', type: 'text', date: '', chapter: '', grade: '', subject: 'Mathematics', className: '', status: 'draft' });
                  }}
                  disabled={!lessonForm.title || !lessonForm.chapter || !lessonForm.date || !lessonForm.grade || !lessonForm.subject || !lessonForm.className}
                  className="h-9 text-xs bg-muted text-foreground hover:bg-muted/90"
                >
                  Save as Draft
                </Button>
                <Button
                  size="sm"
                  onClick={() => {
                    alert(`Lesson created successfully!\\n\\n${lessonForm.title}\\nType: ${lessonForm.type}\\nChapter: ${lessonForm.chapter}\\nGrade: ${lessonForm.grade}\\nSubject: ${lessonForm.subject}\\nClass: ${lessonForm.className}\\nDate: ${lessonForm.date}\\nStatus: Published`);
                    setIsCreateLessonOpen(false);
                    setLessonForm({ title: '', description: '', type: 'text', date: '', chapter: '', grade: '', subject: 'Mathematics', className: '', status: 'draft' });
                  }}
                  disabled={!lessonForm.title || !lessonForm.chapter || !lessonForm.date || !lessonForm.grade || !lessonForm.subject || !lessonForm.className}
                  className="h-9 text-xs bg-primary"
                >
                  Create Lesson
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>

          {/* Create Assignment Dialog */}
          <Dialog open={isCreateAssignmentOpen} onOpenChange={setIsCreateAssignmentOpen}>
            <DialogTrigger asChild>
              <Button className="w-full h-9 text-xs bg-secondary hover:bg-secondary/90">
                <FileText className="w-3.5 h-3.5 mr-1.5" />
                {t('actions.createAssignment')}
              </Button>
            </DialogTrigger>
            <DialogContent className="w-[380px]">
              <DialogHeader>
                <DialogTitle className="text-base">Create New Assignment</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 py-3">
                <div className="space-y-2">
                  <Label htmlFor="assignment-title" className="text-xs font-medium">
                    Assignment Title *
                  </Label>
                  <Input
                    id="assignment-title"
                    placeholder="e.g., Chapter 5 Homework"
                    value={assignmentForm.title}
                    onChange={(e) => setAssignmentForm({ ...assignmentForm, title: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="assignment-description" className="text-xs font-medium">
                    Description
                  </Label>
                  <Textarea
                    id="assignment-description"
                    placeholder="Describe the assignment..."
                    value={assignmentForm.description}
                    onChange={(e) => setAssignmentForm({ ...assignmentForm, description: e.target.value })}
                    className="min-h-20 text-sm border-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="due-date" className="text-xs font-medium">
                    Due Date *
                  </Label>
                  <Input
                    id="due-date"
                    type="date"
                    value={assignmentForm.dueDate}
                    onChange={(e) => setAssignmentForm({ ...assignmentForm, dueDate: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="due-time" className="text-xs font-medium">
                    Due Time *
                  </Label>
                  <Input
                    id="due-time"
                    type="time"
                    value={assignmentForm.dueTime}
                    onChange={(e) => setAssignmentForm({ ...assignmentForm, dueTime: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="total-points" className="text-xs font-medium">
                    Points *
                  </Label>
                  <Input
                    id="total-points"
                    type="number"
                    placeholder="100"
                    value={assignmentForm.points}
                    onChange={(e) => setAssignmentForm({ ...assignmentForm, points: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="file" className="text-xs font-medium">
                    Attach Files
                  </Label>
                  <div className="border-2 border-dashed border-primary/20 rounded-lg p-4 text-center hover:border-primary/40 transition-colors cursor-pointer">
                    <Upload className="w-8 h-8 text-primary mx-auto mb-2" />
                    <p className="text-xs text-muted-foreground">
                      Click to upload assignment files
                    </p>
                  </div>
                </div>
              </div>
              <DialogFooter>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setIsCreateAssignmentOpen(false);
                    setAssignmentForm({ title: '', description: '', dueDate: '', dueTime: '', points: '' });
                  }}
                  className="h-9 text-xs"
                >
                  Cancel
                </Button>
                <Button
                  size="sm"
                  onClick={() => {
                    alert(`Assignment created successfully!\n\n${assignmentForm.title}\nDue: ${assignmentForm.dueDate} at ${assignmentForm.dueTime}\nPoints: ${assignmentForm.points}`);
                    setIsCreateAssignmentOpen(false);
                    setAssignmentForm({ title: '', description: '', dueDate: '', dueTime: '', points: '' });
                  }}
                  disabled={!assignmentForm.title || !assignmentForm.dueDate || !assignmentForm.dueTime || !assignmentForm.points}
                  className="h-9 text-xs bg-secondary"
                >
                  Create Assignment
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>

          {/* Schedule Session Dialog */}
          <Dialog open={isScheduleSessionOpen} onOpenChange={setIsScheduleSessionOpen}>
            <DialogTrigger asChild>
              <Button className="w-full h-9 text-xs bg-primary hover:bg-primary/90">
                <CalendarPlus className="w-3.5 h-3.5 mr-1.5" />
                {t('actions.scheduleSession')}
              </Button>
            </DialogTrigger>
            <DialogContent className="w-[380px]">
              <DialogHeader>
                <DialogTitle className="text-base">Schedule Live Session</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 py-3">
                <div className="space-y-2">
                  <Label htmlFor="session-title" className="text-xs font-medium">
                    Session Title *
                  </Label>
                  <Input
                    id="session-title"
                    placeholder="e.g., Mathematics Q&A Session"
                    value={sessionForm.title}
                    onChange={(e) => setSessionForm({ ...sessionForm, title: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-2">
                    <Label htmlFor="grade" className="text-xs font-medium">
                      Grade *
                    </Label>
                    <Select
                      value={sessionForm.grade}
                      onValueChange={(value) => setSessionForm({ ...sessionForm, grade: value })}
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
                    <Label htmlFor="subject" className="text-xs font-medium">
                      Subject *
                    </Label>
                    <Select
                      value={sessionForm.subject}
                      onValueChange={(value) => setSessionForm({ ...sessionForm, subject: value })}
                    >
                      <SelectTrigger className="h-9 text-sm border-primary/20">
                        <SelectValue placeholder="Select subject" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Math" className="text-sm">Math</SelectItem>
                        <SelectItem value="Physics" className="text-sm">Physics</SelectItem>
                        <SelectItem value="Chemistry" className="text-sm">Chemistry</SelectItem>
                        <SelectItem value="SVT" className="text-sm">SVT</SelectItem>
                        <SelectItem value="French" className="text-sm">French</SelectItem>
                        <SelectItem value="Arabic" className="text-sm">Arabic</SelectItem>
                        <SelectItem value="English" className="text-sm">English</SelectItem>
                        <SelectItem value="Modern Skills" className="text-sm">Modern Skills</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="class-name" className="text-xs font-medium">
                    Class Name *
                  </Label>
                  <Input
                    id="class-name"
                    placeholder="e.g., 4th Grade - Math A"
                    value={sessionForm.className}
                    onChange={(e) => setSessionForm({ ...sessionForm, className: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-2">
                    <Label htmlFor="session-date" className="text-xs font-medium">
                      Date *
                    </Label>
                    <Input
                      id="session-date"
                      type="date"
                      value={sessionForm.date}
                      onChange={(e) => setSessionForm({ ...sessionForm, date: e.target.value })}
                      className="h-9 text-sm border-primary/20"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="session-time" className="text-xs font-medium">
                      Time *
                    </Label>
                    <Input
                      id="session-time"
                      type="time"
                      value={sessionForm.time}
                      onChange={(e) => setSessionForm({ ...sessionForm, time: e.target.value })}
                      className="h-9 text-sm border-primary/20"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="meeting-link" className="text-xs font-medium">
                    Zoom Meeting Link *
                  </Label>
                  <Input
                    id="meeting-link"
                    type="url"
                    placeholder="https://zoom.us/j/..."
                    value={sessionForm.meetingLink}
                    onChange={(e) => setSessionForm({ ...sessionForm, meetingLink: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>
              </div>
              <DialogFooter>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    setIsScheduleSessionOpen(false);
                    setSessionForm({ title: '', className: '', subject: '', grade: '', date: '', time: '', platform: 'Zoom', meetingLink: '' });
                  }}
                  className="h-9 text-xs"
                >
                  Cancel
                </Button>
                <Button
                  size="sm"
                  onClick={() => {
                    alert(`Session scheduled successfully!\n\n${sessionForm.title}\nClass: ${sessionForm.className}\nDate: ${sessionForm.date} at ${sessionForm.time}\nPlatform: ${sessionForm.platform}`);
                    setIsScheduleSessionOpen(false);
                    setSessionForm({ title: '', className: '', subject: '', grade: '', date: '', time: '', platform: 'Zoom', meetingLink: '' });
                  }}
                  disabled={!sessionForm.title || !sessionForm.className || !sessionForm.date || !sessionForm.time || !sessionForm.meetingLink}
                  className="h-9 text-xs bg-primary"
                >
                  Schedule Session
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </CardContent>
      </Card>

      {/* Today's Classes */}
      <Card className="border-2 border-primary/20 shadow-sm">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="text-base text-foreground flex items-center gap-2">
            <Calendar className="w-4 h-4 text-primary" />
            {t('today.todayClasses')} - {today}
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-3 space-y-2">
          {todayClasses.length === 0 ? (
            <p className="text-xs text-center text-muted-foreground py-4">
              {t('today.noClasses')}
            </p>
          ) : (
            todayClasses.map(entry => {
              // Get the full class details
              const classDetails = mockClasses.find(cls => cls.id === entry.classId);
              if (!classDetails) return null;
              
              return (
                <Link
                  key={entry.id}
                  to={`/teacher/classes/${entry.classId}`}
                  className="block p-3 rounded-lg border border-border hover:border-primary hover:shadow-sm transition-all bg-card"
                >
                  <div className="flex items-start justify-between gap-2 mb-2">
                    <h3 className="text-sm font-semibold text-foreground">{classDetails.subject}</h3>
                    <Badge className="text-[10px] bg-secondary/10 text-secondary border-secondary/20">
                      {classDetails.level}
                    </Badge>
                  </div>
                  <div className="space-y-1.5">
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <Calendar className="w-3.5 h-3.5" />
                      <span>{entry.time}</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <Users className="w-3.5 h-3.5" />
                      <span>{classDetails.students} Students</span>
                    </div>
                  </div>
                </Link>
              );
            })
          )}
        </CardContent>
      </Card>

      {/* Upcoming Live Sessions */}
      <Card className="border-2 border-primary/20 shadow-sm">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="text-base text-foreground flex items-center gap-2">
            <Video className="w-4 h-4 text-primary" />
            {t('live.upcomingSessions')}
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-3 space-y-2">
          {upcomingSessions.length === 0 ? (
            <p className="text-xs text-center text-muted-foreground py-4">
              No upcoming live sessions
            </p>
          ) : (
            <>
              {upcomingSessions.map(session => (
                <div
                  key={session.id}
                  className="p-3 rounded-lg border-2 border-primary/20 bg-card"
                >
                  <div className="flex items-start justify-between gap-2 mb-2">
                    <h3 className="text-sm font-semibold text-foreground flex-1">{session.title}</h3>
                    <Badge className="text-[10px] bg-accent/20 text-accent border-accent/30">
                      {session.platform}
                    </Badge>
                  </div>
                  <div className="flex items-center gap-2 text-xs text-muted-foreground mb-2">
                    <Calendar className="w-3 h-3" />
                    <span>
                      {new Date(session.date).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                      })}
                    </span>
                    <span>•</span>
                    <Clock className="w-3 h-3" />
                    <span>{session.time}</span>
                  </div>
                  <Button size="sm" className="w-full h-8 text-xs bg-primary">
                    {t('live.startSession')}
                  </Button>
                </div>
              ))}
              <Link to="/teacher/live-sessions">
                <Button variant="outline" className="w-full h-9 text-xs border-primary text-primary hover:bg-primary/5">
                  {t('common.viewAll')}
                </Button>
              </Link>
            </>
          )}
        </CardContent>
      </Card>

      {/* Pending Submissions */}
      <Card className="border-2 border-primary/20 shadow-sm">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="text-base text-foreground flex items-center justify-between">
            <span>{t('recent.recentSubmissions')}</span>
            <Badge className="text-[10px] bg-accent/20 text-accent border-accent/30">
              {pendingGrading.length}
            </Badge>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2 pt-2">
          {pendingGrading.slice(0, 3).map(submission => (
            <div
              key={submission.id}
              className="p-3 rounded-lg border-2 border-primary/20 bg-card"
            >
              <p className="text-sm font-semibold text-foreground">{submission.studentName}</p>
              <p className="text-xs text-muted-foreground mt-0.5">
                Submitted {new Date(submission.submittedAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
              </p>
            </div>
          ))}
          <Link to="/teacher/assignments">
            <Button variant="outline" className="w-full h-9 text-xs border-primary text-primary hover:bg-primary/5">
              {t('actions.viewSubmissions')}
            </Button>
          </Link>
        </CardContent>
      </Card>

      {/* My Classes */}
      <Card className="border-2 border-primary/20 shadow-sm">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="text-base text-foreground flex items-center justify-between">
            <span>{t('classes.myClasses')}</span>
            <Badge className="text-[10px] bg-accent/20 text-accent">
              {myClasses.length}
            </Badge>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2 pt-2">
          {myClasses.slice(0, 2).map(cls => (
            <Link
              key={cls.id}
              to={`/teacher/classes/${cls.id}`}
              className="block p-3 rounded-lg border-2 border-primary/20 hover:border-primary hover:shadow-sm transition-all bg-card"
            >
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <h3 className="text-sm font-semibold text-foreground">{cls.subject}</h3>
                  <Badge 
                    variant="secondary" 
                    className="text-[10px] bg-secondary/10 text-secondary border-secondary/20"
                  >
                    {cls.level}
                  </Badge>
                </div>
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  <Calendar className="w-3 h-3 text-primary" />
                  <span>{cls.schedule}</span>
                </div>
                <div className="flex items-center gap-2 text-xs text-muted-foreground">
                  <Users className="w-3 h-3 text-primary" />
                  <span>{cls.students} {t('classes.students')}</span>
                </div>
              </div>
            </Link>
          ))}
          <Link to="/teacher/classes">
            <Button variant="outline" className="w-full h-9 text-xs border-primary text-primary hover:bg-primary/5 mt-1">
              {t('common.viewAll')}
            </Button>
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}