import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { mockClasses, mockLessons, mockAssignments } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/app/components/ui/tabs';
import {
  BookOpen,
  Calendar,
  Users,
  FileText,
  Video,
  File,
  Clock,
  Award,
  ChevronRight,
  Link as LinkIcon,
  Download,
  ArrowLeft,
} from 'lucide-react';

export function ClassDetails() {
  const { classId } = useParams<{ classId: string }>();
  const classData = mockClasses.find(c => c.id === classId);
  const lessons = mockLessons.filter(l => l.classId === classId);
  const assignments = mockAssignments.filter(a => a.classId === classId);

  if (!classData) {
    return <div>Class not found</div>;
  }

  const getIcon = (type: string) => {
    switch (type) {
      case 'video':
        return <Video className="w-4 h-4" />;
      case 'pdf':
        return <File className="w-4 h-4" />;
      default:
        return <FileText className="w-4 h-4" />;
    }
  };

  return (
    <div className="space-y-4">
      {/* Class Header */}
      <div
        className="rounded-lg p-4 text-white relative overflow-hidden"
        style={{
          background: `linear-gradient(135deg, ${classData.color}, ${classData.color}dd)`,
        }}
      >
        <div className="absolute inset-0 bg-primary/10" />
        <div className="relative">
          <h1 className="text-lg font-bold">{classData.name}</h1>
          <p className="mt-1 text-sm text-white/90">{classData.teacher}</p>
          <div className="flex flex-wrap gap-3 mt-3 text-xs">
            <div className="flex items-center gap-1.5">
              <Calendar className="w-3.5 h-3.5" />
              <span>{classData.schedule}</span>
            </div>
            <div className="flex items-center gap-1.5">
              <Users className="w-3.5 h-3.5" />
              <span>{classData.students} students</span>
            </div>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="lessons" className="space-y-3">
        <TabsList className="w-full">
          <TabsTrigger value="lessons" className="flex-1 text-xs">
            <BookOpen className="w-3.5 h-3.5 mr-1.5" />
            Lessons
          </TabsTrigger>
          <TabsTrigger value="assignments" className="flex-1 text-xs">
            <FileText className="w-3.5 h-3.5 mr-1.5" />
            Assignments
          </TabsTrigger>
        </TabsList>

        <TabsContent value="lessons" className="space-y-3 mt-3">
          {lessons.length === 0 ? (
            <Card>
              <CardContent className="p-8 text-center">
                <BookOpen className="w-10 h-10 text-blue-200 mx-auto mb-2" />
                <p className="text-sm text-muted-foreground">No lessons available yet</p>
              </CardContent>
            </Card>
          ) : (
            <div className="space-y-6">
              {lessons.map(lesson => (
                <Link key={lesson.id} to={`/student/lessons/${lesson.id}`}>
                  <Card className="hover:shadow-md transition-shadow border-blue-100">
                    <CardContent className="p-3">
                      <div className="flex items-start gap-3">
                        <div className="p-2 bg-blue-100 rounded-lg text-blue-600 flex-shrink-0">
                          {getIcon(lesson.type)}
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className="text-sm font-semibold text-primary truncate">
                            {lesson.title}
                          </h3>
                          <p className="text-xs text-card-foreground mt-0.5 line-clamp-2">
                            {lesson.description}
                          </p>
                          <div className="flex items-center gap-2 mt-2 flex-wrap">
                            <div className="flex items-center gap-1 text-[11px] text-muted-foreground">
                              <Calendar className="w-3 h-3" />
                              {new Date(lesson.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                            </div>
                            {lesson.duration && (
                              <div className="flex items-center gap-1 text-[11px] text-muted-foreground">
                                <Clock className="w-3 h-3" />
                                {lesson.duration}
                              </div>
                            )}
                            <Badge variant="secondary" className="capitalize text-[10px] px-1.5 py-0">
                              {lesson.type}
                            </Badge>
                          </div>
                        </div>
                        <ChevronRight className="w-4 h-4 text-blue-400 flex-shrink-0 mt-1" />
                      </div>
                    </CardContent>
                  </Card>
                </Link>
              ))}
            </div>
          )}
        </TabsContent>

        <TabsContent value="assignments" className="space-y-3 mt-3">
          {assignments.length === 0 ? (
            <Card>
              <CardContent className="p-8 text-center">
                <FileText className="w-10 h-10 text-blue-200 mx-auto mb-2" />
                <p className="text-sm text-muted-foreground">No assignments available yet</p>
              </CardContent>
            </Card>
          ) : (
            <div className="space-y-6">
              {assignments.map(assignment => {
                const daysUntilDue = Math.ceil(
                  (new Date(assignment.dueDate).getTime() - new Date().getTime()) /
                    (1000 * 60 * 60 * 24)
                );

                return (
                  <Link
                    key={assignment.id}
                    to={`/student/assignments/${assignment.id}`}
                  >
                    <Card className="hover:shadow-md transition-shadow border-blue-100">
                      <CardContent className="p-3">
                        <div className="flex items-start justify-between gap-2">
                          <div className="flex-1 min-w-0">
                            <h3 className="text-sm font-semibold text-primary">
                              {assignment.title}
                            </h3>
                            <p className="text-xs text-card-foreground mt-0.5 line-clamp-2">
                              {assignment.description}
                            </p>
                            <div className="flex items-center gap-2 mt-2 flex-wrap">
                              <div className="flex items-center gap-1 text-[11px] text-muted-foreground">
                                <Calendar className="w-3 h-3" />
                                Due {new Date(assignment.dueDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                              </div>
                              <Badge variant="secondary" className="text-[10px] px-1.5 py-0">{assignment.points} pts</Badge>
                              <Badge
                                className="text-[10px] px-1.5 py-0"
                                variant={
                                  assignment.status === 'graded'
                                    ? 'default'
                                    : assignment.status === 'submitted'
                                    ? 'secondary'
                                    : 'destructive'
                                }
                              >
                                {assignment.status}
                              </Badge>
                            </div>
                            {assignment.grade && (
                              <div className="mt-1.5 text-xs font-medium text-green-600">
                                Grade: {assignment.grade}/{assignment.points}
                              </div>
                            )}
                          </div>
                          <ChevronRight className="w-4 h-4 text-blue-400 flex-shrink-0 mt-1" />
                        </div>
                      </CardContent>
                    </Card>
                  </Link>
                );
              })}
            </div>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}