import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { useLanguage } from '@/contexts/LanguageContext';
import { mockClasses, mockAssignments, mockLiveSessions } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/app/components/ui/card';
import { Button } from '@/app/components/ui/button';
import { Badge } from '@/app/components/ui/badge';
import { Progress } from '@/app/components/ui/progress';
import {
  BookOpen,
  FileText,
  Video,
  Clock,
  CheckCircle,
  AlertCircle,
  Calendar,
  TrendingUp,
} from 'lucide-react';

export function StudentDashboard() {
  const { user } = useAuth();
  const { t } = useLanguage();

  const upcomingAssignments = mockAssignments
    .filter(a => a.status === 'pending')
    .slice(0, 3);

  const activeSessions = mockLiveSessions.filter(s => s.isActive);

  // Filter classes based on user's enrolled classes
  const enrolledClasses = mockClasses.filter(cls => user?.enrolledClassIds?.includes(cls.id) || false);

  // Group classes by subject
  const groupedClasses = enrolledClasses.reduce((acc, cls) => {
    if (!acc[cls.subject]) {
      acc[cls.subject] = [];
    }
    acc[cls.subject].push(cls);
    return acc;
  }, {} as Record<string, typeof mockClasses>);

  const stats = [
    {
      label: t('classes.enrolledClasses'),
      value: Object.keys(groupedClasses).length,
      icon: BookOpen,
      color: 'text-primary',
      bgColor: 'bg-primary/10',
    },
    {
      label: t('assignments.pending'),
      value: mockAssignments.filter(a => a.status === 'pending').length,
      icon: FileText,
      color: 'text-accent',
      bgColor: 'bg-accent/20',
    },
    {
      label: t('lessons.completed'),
      value: mockAssignments.filter(a => a.status === 'graded').length,
      icon: CheckCircle,
      color: 'text-secondary',
      bgColor: 'bg-secondary/10',
    },
    {
      label: t('live.liveSessions'),
      value: activeSessions.length,
      icon: Video,
      color: 'text-primary',
      bgColor: 'bg-primary/10',
    },
  ];

  return (
    <div className="space-y-4 pb-4">
      {/* Welcome Header */}
      <div className="bg-gradient-to-r from-primary to-primary/80 text-white p-4 rounded-lg shadow-md">
        <h1 className="text-xl font-bold">
          {t('dashboard.welcomeBack')}, {user?.name?.split(' ')[0]}!
        </h1>
        <p className="text-sm text-white/90 mt-0.5">
          {t('dashboard.overview')}
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-2 gap-3">
        {stats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <Card key={index} className="shadow-sm border-2 border-primary/20">
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

      {/* Active Live Sessions */}
      {activeSessions.length > 0 && (
        <Card className="border-2 border-primary/20 shadow-sm">
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center gap-2 text-primary text-base">
              <Video className="w-4 h-4" />
              {t('live.activeSessions')}
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3 pt-3">
            {activeSessions.map(session => (
              <div
                key={session.id}
                className="bg-white p-4 rounded-lg border border-border shadow-sm flex items-center justify-between gap-3"
              >
                <div className="flex-1 min-w-0">
                  <h3 className="font-semibold text-sm text-primary truncate">{session.title}</h3>
                  <p className="text-xs text-muted-foreground mt-1">
                    {session.time} • {session.platform === 'zoom' ? 'Zoom' : 'Meet'}
                  </p>
                </div>
                <Link to={`/student/live-sessions/${session.id}`}>
                  <Button size="sm" className="bg-secondary hover:bg-secondary/90 h-9 text-xs px-4 shadow-sm">
                    <Video className="w-3.5 h-3.5 mr-1.5" />
                    {t('live.joinSession')}
                  </Button>
                </Link>
              </div>
            ))}
          </CardContent>
        </Card>
      )}

      {/* Upcoming Assignments */}
      <Card className="shadow-sm border-2 border-primary/20">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="flex items-center justify-between text-base text-foreground">
            <span className="flex items-center gap-2">
              <FileText className="w-4 h-4 text-primary" />
              {t('assignments.upcomingAssignments')}
            </span>
            <Link to="/student/assignments">
              <Button variant="ghost" size="sm" className="h-7 text-xs hover:text-primary">
                {t('common.viewAll')}
              </Button>
            </Link>
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2 pt-3">
          {upcomingAssignments.map(assignment => {
            const daysUntilDue = Math.ceil(
              (new Date(assignment.dueDate).getTime() - new Date().getTime()) /
                (1000 * 60 * 60 * 24)
            );
            const isUrgent = daysUntilDue <= 2;

            return (
              <Link
                key={assignment.id}
                to={`/student/assignments/${assignment.id}`}
                className="block p-3 rounded-lg border-2 border-primary/20 hover:border-primary hover:shadow-sm transition-all bg-card"
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="flex-1 min-w-0">
                    <h3 className="font-semibold text-sm text-foreground truncate">
                      {assignment.title}
                    </h3>
                    <p className="text-xs text-muted-foreground mt-0.5 line-clamp-1">
                      {assignment.description}
                    </p>
                    <div className="flex items-center gap-2 mt-1">
                      <div className="flex items-center gap-1">
                        <Clock className="w-3 h-3 text-muted-foreground" />
                        <span
                          className={`text-[10px] ${
                            isUrgent ? 'text-destructive font-medium' : 'text-muted-foreground'
                          }`}
                        >
                          {daysUntilDue}d left
                        </span>
                      </div>
                      <Badge variant="secondary" className="text-[10px] px-1.5 py-0 bg-accent/20 text-accent-foreground border-accent/30">
                        {assignment.points} pts
                      </Badge>
                    </div>
                  </div>
                  {isUrgent && (
                    <AlertCircle className="w-4 h-4 text-destructive flex-shrink-0" />
                  )}
                </div>
              </Link>
            );
          })}
        </CardContent>
      </Card>

      {/* Progress Overview */}
      <Card className="shadow-sm border-2 border-primary/20">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="flex items-center gap-2 text-base text-foreground">
            <TrendingUp className="w-4 h-4 text-secondary" />
            {t('progress.progressOverview')}
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3 pt-3">
          {mockClasses.slice(0, 4).map((cls, index) => {
            const progress = 65 + index * 10; // Mock progress
            return (
              <div key={cls.id}>
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-xs font-medium text-foreground truncate">{cls.name}</span>
                  <span className="text-xs text-muted-foreground ml-2">{progress}%</span>
                </div>
                <Progress value={progress} className="h-1.5" />
              </div>
            );
          })}
        </CardContent>
      </Card>
    </div>
  );
}