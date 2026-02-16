import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  mockStudents,
  mockClasses,
  mockAttendanceRecords,
  mockStudentProgress,
  mockAssignments,
  mockSubmissions,
} from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Progress } from '@/app/components/ui/progress';
import { Textarea } from '@/app/components/ui/textarea';
import { Label } from '@/app/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/app/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from '@/app/components/ui/dialog';
import {
  ArrowLeft,
  Mail,
  Calendar,
  CheckCircle,
  XCircle,
  Clock,
  AlertTriangle,
  TrendingUp,
  FileText,
  BookOpen,
  Plus,
  UserCheck,
} from 'lucide-react';

export function TeacherStudentDetail() {
  const { studentId } = useParams();
  const navigate = useNavigate();
  const [selectedClass, setSelectedClass] = useState('class1');
  const [isAttendanceDialogOpen, setIsAttendanceDialogOpen] = useState(false);
  const [attendanceData, setAttendanceData] = useState({
    date: new Date().toISOString().split('T')[0],
    status: 'present' as 'present' | 'absent' | 'late' | 'excused',
    notes: '',
  });

  const student = mockStudents.find(s => s.id === studentId);
  const studentClasses = mockClasses.filter(c => c.id === 'class1'); // Filter for Advanced Mathematics only
  const attendanceRecords = mockAttendanceRecords.filter(
    a => a.studentId === studentId && a.classId === selectedClass
  );
  const progressData = mockStudentProgress.find(
    p => p.studentId === studentId && p.classId === selectedClass
  ) || {
    studentId: studentId || '',
    classId: selectedClass,
    overallGrade: student?.grade || 0,
    assignments: { completed: 0, total: 0 },
    attendance: { present: 0, absent: 0, late: 0, total: 0 },
    lastActivity: new Date().toISOString(),
  };

  // Get student submissions for the selected class
  const classAssignments = mockAssignments.filter(a => a.classId === selectedClass);
  const studentSubmissions = mockSubmissions.filter(s => s.studentId === studentId);

  if (!student) {
    return (
      <div className="space-y-4">
        <div className="bg-primary text-primary-foreground p-4 rounded-lg">
          <h1 className="text-xl font-bold">Student Not Found</h1>
        </div>
        <Card className="border-2 border-primary/20">
          <CardContent className="p-12 text-center">
            <p className="text-sm text-muted-foreground">The student you're looking for doesn't exist.</p>
            <Button onClick={() => navigate('/teacher/students')} className="mt-4 bg-primary">
              Back to Students
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  const handleMarkAttendance = () => {
    console.log('Marking attendance:', {
      studentId,
      classId: selectedClass,
      ...attendanceData,
    });
    alert(`Attendance marked as ${attendanceData.status} for ${attendanceData.date}`);
    setIsAttendanceDialogOpen(false);
    setAttendanceData({
      date: new Date().toISOString().split('T')[0],
      status: 'present',
      notes: '',
    });
  };

  const attendancePercentage = progressData.attendance.total > 0
    ? Math.round((progressData.attendance.present / progressData.attendance.total) * 100)
    : 0;

  const assignmentCompletionRate = progressData.assignments.total > 0
    ? Math.round((progressData.assignments.completed / progressData.assignments.total) * 100)
    : 0;

  return (
    <div className="space-y-4 pb-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => navigate('/teacher/students')}
          className="text-white hover:bg-white/20 mb-2 h-8 px-2"
        >
          <ArrowLeft className="w-4 h-4 mr-1" />
          Back to Students
        </Button>
        <div className="flex items-start gap-3">
          <div className="w-14 h-14 rounded-full bg-white/20 flex items-center justify-center flex-shrink-0">
            <span className="text-lg font-bold text-white">
              {student.name.split(' ').map(n => n[0]).join('')}
            </span>
          </div>
          <div className="flex-1">
            <h1 className="text-xl font-bold">{student.name}</h1>
            <div className="flex items-center gap-1.5 text-sm text-white/90 mt-1">
              <Mail className="w-3.5 h-3.5" />
              <span>{student.email}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Class Selector */}
      <Card className="border-2 border-primary/20">
        <CardContent className="p-3">
          <Label className="text-xs font-semibold text-primary mb-2 block">Select Class</Label>
          <Select value={selectedClass} onValueChange={setSelectedClass}>
            <SelectTrigger className="h-9 text-sm border-primary/20">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {studentClasses.map(cls => (
                <SelectItem key={cls.id} value={cls.id} className="text-sm">
                  {cls.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {/* Performance Overview */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="text-base text-foreground flex items-center gap-2">
            <TrendingUp className="w-4 h-4 text-primary" />
            Performance Overview
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-3 space-y-4">
          {/* Overall Grade */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-semibold text-foreground">Overall Grade</span>
              <Badge className="text-xs bg-secondary/20 text-secondary border-secondary/30">
                {progressData.overallGrade}%
              </Badge>
            </div>
            <Progress value={progressData.overallGrade} className="h-2" />
          </div>

          {/* Assignment Completion */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-semibold text-foreground">Assignment Completion</span>
              <span className="text-xs text-muted-foreground">
                {progressData.assignments.completed}/{progressData.assignments.total}
              </span>
            </div>
            <Progress value={assignmentCompletionRate} className="h-2" />
          </div>

          {/* Attendance Rate */}
          <div>
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs font-semibold text-foreground">Attendance Rate</span>
              <span className="text-xs text-muted-foreground">{attendancePercentage}%</span>
            </div>
            <Progress value={attendancePercentage} className="h-2" />
          </div>

          {/* Last Activity */}
          <div className="pt-2 border-t border-primary/10">
            <div className="flex items-center justify-between text-xs">
              <span className="text-muted-foreground">Last Activity</span>
              <span className="font-medium text-foreground">
                {new Date(progressData.lastActivity).toLocaleDateString('en-US', {
                  month: 'short',
                  day: 'numeric',
                  year: 'numeric',
                })}
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Attendance Tracking */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3 bg-primary/5">
          <div className="flex items-center justify-between">
            <CardTitle className="text-base text-foreground flex items-center gap-2">
              <UserCheck className="w-4 h-4 text-primary" />
              Attendance Tracking
            </CardTitle>
            <Dialog open={isAttendanceDialogOpen} onOpenChange={setIsAttendanceDialogOpen}>
              <DialogTrigger asChild>
                <Button size="sm" className="h-7 text-xs bg-primary">
                  <Plus className="w-3 h-3 mr-1" />
                  Mark
                </Button>
              </DialogTrigger>
              <DialogContent className="w-[380px]">
                <DialogHeader>
                  <DialogTitle className="text-base">Mark Attendance</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 py-3">
                  <div className="space-y-2">
                    <Label className="text-xs font-semibold text-primary">Date</Label>
                    <input
                      type="date"
                      value={attendanceData.date}
                      onChange={e => setAttendanceData({ ...attendanceData, date: e.target.value })}
                      className="w-full h-9 px-3 text-sm border-2 border-primary/20 rounded-md"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label className="text-xs font-semibold text-primary">Status</Label>
                    <Select
                      value={attendanceData.status}
                      onValueChange={(value: any) => setAttendanceData({ ...attendanceData, status: value })}
                    >
                      <SelectTrigger className="h-9 text-sm border-primary/20">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="present">Present</SelectItem>
                        <SelectItem value="absent">Absent</SelectItem>
                        <SelectItem value="late">Late</SelectItem>
                        <SelectItem value="excused">Excused</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-xs font-semibold text-primary">Notes (Optional)</Label>
                    <Textarea
                      value={attendanceData.notes}
                      onChange={e => setAttendanceData({ ...attendanceData, notes: e.target.value })}
                      placeholder="Add any notes..."
                      className="h-20 text-sm border-primary/20"
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setIsAttendanceDialogOpen(false)}
                    className="h-9 text-xs"
                  >
                    Cancel
                  </Button>
                  <Button size="sm" onClick={handleMarkAttendance} className="h-9 text-xs bg-primary">
                    Save Attendance
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </CardHeader>
        <CardContent className="pt-3">
          {/* Attendance Summary */}
          <div className="grid grid-cols-4 gap-2 mb-3">
            <div className="bg-secondary/10 p-2 rounded-lg text-center">
              <CheckCircle className="w-4 h-4 text-secondary mx-auto mb-1" />
              <p className="text-lg font-bold text-foreground">{progressData.attendance.present}</p>
              <p className="text-[10px] text-muted-foreground">Present</p>
            </div>
            <div className="bg-destructive/10 p-2 rounded-lg text-center">
              <XCircle className="w-4 h-4 text-destructive mx-auto mb-1" />
              <p className="text-lg font-bold text-foreground">{progressData.attendance.absent}</p>
              <p className="text-[10px] text-muted-foreground">Absent</p>
            </div>
            <div className="bg-accent/20 p-2 rounded-lg text-center">
              <Clock className="w-4 h-4 text-accent mx-auto mb-1" />
              <p className="text-lg font-bold text-foreground">{progressData.attendance.late}</p>
              <p className="text-[10px] text-muted-foreground">Late</p>
            </div>
            <div className="bg-primary/10 p-2 rounded-lg text-center">
              <Calendar className="w-4 h-4 text-primary mx-auto mb-1" />
              <p className="text-lg font-bold text-foreground">{progressData.attendance.total}</p>
              <p className="text-[10px] text-muted-foreground">Total</p>
            </div>
          </div>

          {/* Recent Attendance Records */}
          <div className="space-y-2">
            <h4 className="text-xs font-semibold text-foreground mb-2">Recent Records</h4>
            {attendanceRecords.length === 0 ? (
              <p className="text-xs text-center text-muted-foreground py-4">No attendance records yet</p>
            ) : (
              attendanceRecords.slice(0, 5).map(record => {
                const statusConfig = {
                  present: { icon: CheckCircle, color: 'text-secondary', bg: 'bg-secondary/10' },
                  absent: { icon: XCircle, color: 'text-destructive', bg: 'bg-destructive/10' },
                  late: { icon: Clock, color: 'text-accent', bg: 'bg-accent/20' },
                  excused: { icon: AlertTriangle, color: 'text-primary', bg: 'bg-primary/10' },
                };
                const config = statusConfig[record.status];
                const Icon = config.icon;

                return (
                  <div
                    key={record.id}
                    className="flex items-center gap-2 p-2 rounded-lg border border-primary/10"
                  >
                    <div className={`p-1.5 rounded ${config.bg}`}>
                      <Icon className={`w-3.5 h-3.5 ${config.color}`} />
                    </div>
                    <div className="flex-1">
                      <p className="text-xs font-medium text-foreground capitalize">{record.status}</p>
                      <p className="text-[10px] text-muted-foreground">
                        {new Date(record.date).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric',
                        })}
                      </p>
                    </div>
                    {record.notes && (
                      <p className="text-[10px] text-muted-foreground italic max-w-[150px] truncate">
                        {record.notes}
                      </p>
                    )}
                  </div>
                );
              })
            )}
          </div>
        </CardContent>
      </Card>

      {/* Assignment Progress */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="text-base text-foreground flex items-center gap-2">
            <FileText className="w-4 h-4 text-primary" />
            Assignment Progress
          </CardTitle>
        </CardHeader>
        <CardContent className="pt-3 space-y-2">
          {classAssignments.length === 0 ? (
            <p className="text-xs text-center text-muted-foreground py-4">No assignments for this class</p>
          ) : (
            classAssignments.map(assignment => {
              const submission = studentSubmissions.find(s => s.assignmentId === assignment.id);
              const hasSubmitted = !!submission;
              const isGraded = submission?.status === 'graded';

              return (
                <div
                  key={assignment.id}
                  className="p-3 rounded-lg border-2 border-primary/20 bg-card"
                >
                  <div className="flex items-start justify-between gap-2 mb-2">
                    <h4 className="text-sm font-semibold text-foreground flex-1">{assignment.title}</h4>
                    {isGraded ? (
                      <Badge className="text-[10px] bg-secondary/20 text-secondary border-secondary/30">
                        {submission.grade}/{assignment.points}
                      </Badge>
                    ) : hasSubmitted ? (
                      <Badge className="text-[10px] bg-accent/20 text-accent border-accent/30">
                        Submitted
                      </Badge>
                    ) : (
                      <Badge className="text-[10px] bg-destructive/20 text-destructive border-destructive/30">
                        Pending
                      </Badge>
                    )}
                  </div>
                  <div className="flex items-center gap-2 text-xs text-muted-foreground">
                    <Calendar className="w-3 h-3" />
                    <span>
                      Due: {new Date(assignment.dueDate).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                      })}
                    </span>
                    <span className="mx-1">•</span>
                    <span>{assignment.points} pts</span>
                  </div>
                  {submission?.feedback && (
                    <div className="mt-2 p-2 bg-primary/5 rounded border border-primary/10">
                      <p className="text-[10px] text-muted-foreground">
                        <strong className="text-primary">Feedback:</strong> {submission.feedback}
                      </p>
                    </div>
                  )}
                </div>
              );
            })
          )}
        </CardContent>
      </Card>
    </div>
  );
}