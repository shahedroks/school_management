import React, { useState } from 'react';
import { Card, CardContent } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { 
  BarChart3, 
  TrendingUp, 
  TrendingDown, 
  Users, 
  BookOpen, 
  FileCheck, 
  Clock,
  Award,
  Calendar
} from 'lucide-react';

interface ClassAnalytics {
  classId: string;
  className: string;
  subject: string;
  avgGrade: number;
  completionRate: number;
  attendance: number;
  assignmentsGraded: number;
  totalAssignments: number;
  trend: 'up' | 'down' | 'stable';
}

const mockAnalytics: ClassAnalytics[] = [
  {
    classId: 'class1',
    className: 'Grade 10 - Mathematics A',
    subject: 'Mathematics',
    avgGrade: 85,
    completionRate: 92,
    attendance: 95,
    assignmentsGraded: 45,
    totalAssignments: 50,
    trend: 'up'
  },
  {
    classId: 'class2',
    className: 'Grade 11 - Physics A',
    subject: 'Physics',
    avgGrade: 78,
    completionRate: 87,
    attendance: 89,
    assignmentsGraded: 38,
    totalAssignments: 42,
    trend: 'up'
  },
  {
    classId: 'class3',
    className: 'Grade 10 - Chemistry A',
    subject: 'Chemistry',
    avgGrade: 82,
    completionRate: 90,
    attendance: 93,
    assignmentsGraded: 40,
    totalAssignments: 45,
    trend: 'stable'
  },
  {
    classId: 'class4',
    className: 'Grade 11 - Biology A',
    subject: 'Biology',
    avgGrade: 88,
    completionRate: 94,
    attendance: 96,
    assignmentsGraded: 42,
    totalAssignments: 44,
    trend: 'up'
  }
];

const overallStats = {
  totalStudents: 112,
  avgAttendance: 93,
  avgGrade: 83,
  totalAssignments: 181,
  gradedAssignments: 165,
  pendingAssignments: 16
};

export function TeacherAnalytics() {
  const [timeRange, setTimeRange] = useState<'week' | 'month' | 'semester'>('month');

  const getGradeColor = (grade: number) => {
    if (grade >= 85) return 'text-green-600';
    if (grade >= 70) return 'text-secondary';
    if (grade >= 60) return 'text-amber-600';
    return 'text-red-600';
  };

  const getTrendIcon = (trend: string) => {
    if (trend === 'up') return <TrendingUp className="w-3.5 h-3.5 text-green-600" />;
    if (trend === 'down') return <TrendingDown className="w-3.5 h-3.5 text-red-600" />;
    return <span className="w-3.5 h-3.5 text-muted-foreground">—</span>;
  };

  return (
    <div className="space-y-4 pb-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <div className="flex items-center justify-between">
          <div className="flex-1">
            <h1 className="text-xl font-bold">Analytics Dashboard</h1>
            <p className="text-sm text-white/90 mt-0.5">
              Track performance and insights
            </p>
          </div>
          <BarChart3 className="w-8 h-8" />
        </div>
      </div>

      {/* Time Range Filter */}
      <div className="flex gap-2 px-1 overflow-x-auto">
        <Button
          onClick={() => setTimeRange('week')}
          variant={timeRange === 'week' ? 'default' : 'outline'}
          size="sm"
          className={`h-8 text-xs whitespace-nowrap ${
            timeRange === 'week' 
              ? 'bg-primary text-white' 
              : 'border-primary/20 text-primary hover:bg-primary/5'
          }`}
        >
          This Week
        </Button>
        <Button
          onClick={() => setTimeRange('month')}
          variant={timeRange === 'month' ? 'default' : 'outline'}
          size="sm"
          className={`h-8 text-xs whitespace-nowrap ${
            timeRange === 'month' 
              ? 'bg-primary text-white' 
              : 'border-primary/20 text-primary hover:bg-primary/5'
          }`}
        >
          This Month
        </Button>
        <Button
          onClick={() => setTimeRange('semester')}
          variant={timeRange === 'semester' ? 'default' : 'outline'}
          size="sm"
          className={`h-8 text-xs whitespace-nowrap ${
            timeRange === 'semester' 
              ? 'bg-primary text-white' 
              : 'border-primary/20 text-primary hover:bg-primary/5'
          }`}
        >
          This Semester
        </Button>
      </div>

      {/* Overall Stats */}
      <div className="px-1">
        <h2 className="text-sm font-semibold text-foreground mb-3">Overall Statistics</h2>
        <div className="grid grid-cols-2 gap-3">
          {/* Total Students */}
          <Card className="border-2 border-primary/20 bg-white">
            <CardContent className="p-3">
              <div className="flex items-center justify-between mb-2">
                <Users className="w-8 h-8 text-primary" />
                <Badge className="text-xs bg-primary/10 text-primary border-primary/20">
                  Students
                </Badge>
              </div>
              <p className="text-2xl font-bold text-foreground">{overallStats.totalStudents}</p>
              <p className="text-xs text-muted-foreground mt-0.5">Total enrolled</p>
            </CardContent>
          </Card>

          {/* Average Grade */}
          <Card className="border-2 border-primary/20 bg-white">
            <CardContent className="p-3">
              <div className="flex items-center justify-between mb-2">
                <Award className="w-8 h-8 text-primary" />
                <Badge className="text-xs bg-primary/10 text-primary border-primary/20">
                  Grade
                </Badge>
              </div>
              <p className={`text-2xl font-bold ${getGradeColor(overallStats.avgGrade)}`}>
                {overallStats.avgGrade}%
              </p>
              <p className="text-xs text-muted-foreground mt-0.5">Average grade</p>
            </CardContent>
          </Card>

          {/* Attendance */}
          <Card className="border-2 border-primary/20 bg-white">
            <CardContent className="p-3">
              <div className="flex items-center justify-between mb-2">
                <Calendar className="w-8 h-8 text-primary" />
                <Badge className="text-xs bg-primary/10 text-primary border-primary/20">
                  Attendance
                </Badge>
              </div>
              <p className="text-2xl font-bold text-green-600">{overallStats.avgAttendance}%</p>
              <p className="text-xs text-muted-foreground mt-0.5">Average rate</p>
            </CardContent>
          </Card>

          {/* Pending Grading */}
          <Card className="border-2 border-primary/20 bg-white">
            <CardContent className="p-3">
              <div className="flex items-center justify-between mb-2">
                <FileCheck className="w-8 h-8 text-primary" />
                <Badge className="text-xs bg-primary/10 text-primary border-primary/20">
                  Pending
                </Badge>
              </div>
              <p className="text-2xl font-bold text-amber-600">{overallStats.pendingAssignments}</p>
              <p className="text-xs text-muted-foreground mt-0.5">To grade</p>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Class Performance */}
      <div className="px-1">
        <h2 className="text-sm font-semibold text-foreground mb-3">Performance by Class</h2>
        <div className="space-y-3">
          {mockAnalytics.map(classData => (
            <Card key={classData.classId} className="border-2 border-primary/20 bg-white">
              <CardContent className="p-4 space-y-3">
                {/* Class Header */}
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <h3 className="text-sm font-semibold text-foreground">
                      {classData.className}
                    </h3>
                    <Badge className="text-[10px] bg-primary/10 text-primary border-primary/20 mt-1">
                      {classData.subject}
                    </Badge>
                  </div>
                  <div className="flex items-center gap-1">
                    {getTrendIcon(classData.trend)}
                  </div>
                </div>

                {/* Metrics Grid */}
                <div className="grid grid-cols-3 gap-2">
                  {/* Average Grade */}
                  <div className="text-center p-2 bg-background rounded-lg">
                    <p className={`text-lg font-bold ${getGradeColor(classData.avgGrade)}`}>
                      {classData.avgGrade}%
                    </p>
                    <p className="text-[10px] text-muted-foreground mt-0.5">Avg Grade</p>
                  </div>

                  {/* Completion Rate */}
                  <div className="text-center p-2 bg-background rounded-lg">
                    <p className="text-lg font-bold text-primary">
                      {classData.completionRate}%
                    </p>
                    <p className="text-[10px] text-muted-foreground mt-0.5">Completion</p>
                  </div>

                  {/* Attendance */}
                  <div className="text-center p-2 bg-background rounded-lg">
                    <p className="text-lg font-bold text-green-600">
                      {classData.attendance}%
                    </p>
                    <p className="text-[10px] text-muted-foreground mt-0.5">Attendance</p>
                  </div>
                </div>

                {/* Assignments Progress */}
                <div className="space-y-1.5">
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-muted-foreground">Assignments Graded</span>
                    <span className="font-semibold text-foreground">
                      {classData.assignmentsGraded}/{classData.totalAssignments}
                    </span>
                  </div>
                  <div className="w-full h-2 bg-muted rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-primary rounded-full transition-all"
                      style={{ 
                        width: `${(classData.assignmentsGraded / classData.totalAssignments) * 100}%` 
                      }}
                    />
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}
