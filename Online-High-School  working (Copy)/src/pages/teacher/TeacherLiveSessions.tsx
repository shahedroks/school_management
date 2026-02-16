import React, { useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { Card, CardContent } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from '@/app/components/ui/dialog';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/app/components/ui/select';
import { Video, Calendar, Clock, Users, ExternalLink, Plus, Trash2, BookOpen, GraduationCap } from 'lucide-react';

interface LiveSession {
  id: string;
  title: string;
  classId: string;
  className: string;
  subject: string;
  grade: string;
  date: string;
  time: string;
  platform: 'Zoom';
  meetingLink: string;
  participants: number;
  status: 'upcoming' | 'live';
}

const mockSessions: LiveSession[] = [
  {
    id: 'session1',
    title: 'Algebra Fundamentals Q&A',
    classId: 'class1',
    className: '4th Grade - Math',
    subject: 'Math',
    grade: '4th',
    date: '2026-02-12',
    time: '10:00 AM',
    platform: 'Zoom',
    meetingLink: 'https://zoom.us/j/1234567890',
    participants: 28,
    status: 'live'
  },
  {
    id: 'session2',
    title: 'Physics Lab - Motion and Forces',
    classId: 'class2',
    className: '5th Grade - Physics',
    subject: 'Physics',
    grade: '5th',
    date: '2026-02-12',
    time: '2:00 PM',
    platform: 'Zoom',
    meetingLink: 'https://zoom.us/j/9876543210',
    participants: 25,
    status: 'live'
  },
  {
    id: 'session3',
    title: 'French Grammar Review',
    classId: 'class3',
    className: '6th Grade - French',
    subject: 'French',
    grade: '6th',
    date: '2026-02-13',
    time: '9:00 AM',
    platform: 'Zoom',
    meetingLink: 'https://zoom.us/j/5555666777',
    participants: 22,
    status: 'upcoming'
  },
  {
    id: 'session4',
    title: 'AI Basics & ChatGPT Workshop',
    classId: 'class4',
    className: '7th Grade - Modern Skills',
    subject: 'Modern Skills',
    grade: '7th',
    date: '2026-02-14',
    time: '11:00 AM',
    platform: 'Zoom',
    meetingLink: 'https://zoom.us/j/1111222333',
    participants: 30,
    status: 'upcoming'
  },
  {
    id: 'session5',
    title: 'Chemistry - Periodic Table',
    classId: 'class5',
    className: '6th Grade - Chemistry',
    subject: 'Chemistry',
    grade: '6th',
    date: '2026-02-15',
    time: '1:00 PM',
    platform: 'Zoom',
    meetingLink: 'https://zoom.us/j/4444555666',
    participants: 24,
    status: 'upcoming'
  },
];

export function TeacherLiveSessions() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(
    searchParams.get('create') === 'session'
  );
  
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

  const liveSessions = mockSessions.filter(s => s.status === 'live');
  const upcomingSessions = mockSessions.filter(s => s.status === 'upcoming');

  const handleCreateSession = () => {
    console.log('Creating session:', sessionForm);
    alert(`Session created successfully!\n\n${sessionForm.title}\nClass: ${sessionForm.className}\nDate: ${sessionForm.date} at ${sessionForm.time}\nPlatform: ${sessionForm.platform}`);
    setIsCreateDialogOpen(false);
    setSessionForm({
      title: '',
      className: '',
      subject: '',
      grade: '',
      date: '',
      time: '',
      platform: 'Zoom',
      meetingLink: '',
    });
  };

  const handleDeleteSession = (sessionId: string, sessionTitle: string) => {
    if (confirm(`Are you sure you want to delete "${sessionTitle}"?`)) {
      alert(`Session "${sessionTitle}" has been deleted.`);
    }
  };

  return (
    <div className="space-y-4 pb-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <div className="flex items-center justify-between">
          <div className="flex-1">
            <h1 className="text-xl font-bold">Live Sessions</h1>
            <p className="text-sm text-white/90 mt-0.5">
              Manage your virtual classes
            </p>
          </div>
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button
                size="sm"
                className="h-9 bg-white text-primary hover:bg-white/90 font-medium"
              >
                <Plus className="w-4 h-4 mr-1.5" />
                Create
              </Button>
            </DialogTrigger>
            <DialogContent className="w-[380px]">
              <DialogHeader>
                <DialogTitle className="text-base">Create Live Session</DialogTitle>
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

                {/* Grade and Subject Selection */}
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
                    placeholder="e.g., Grade 10 - Mathematics A"
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
                  onClick={() => setIsCreateDialogOpen(false)}
                  className="h-9 text-xs"
                >
                  Cancel
                </Button>
                <Button
                  size="sm"
                  onClick={handleCreateSession}
                  disabled={!sessionForm.title || !sessionForm.className || !sessionForm.date || !sessionForm.time || !sessionForm.meetingLink}
                  className="h-9 text-xs bg-primary"
                >
                  Create Session
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      {/* Active Now Section */}
      {liveSessions.length > 0 && (
        <div className="space-y-3">
          <div className="flex items-center gap-1.5 px-1">
            <div className="w-2 h-2 bg-green-500 rounded-full" />
            <h2 className="text-sm font-semibold text-foreground">
              Active Now ({liveSessions.length})
            </h2>
          </div>

          <div className="space-y-3">
            {liveSessions.map(session => (
              <Card key={session.id} className="border-2 border-primary/20 overflow-hidden shadow-sm">
                {/* Green Header */}
                <div className="bg-secondary px-4 py-2.5 flex items-center justify-between">
                  <div className="flex items-center gap-2 text-white">
                    <Video className="w-4 h-4" />
                    <span className="font-semibold text-sm">{session.title}</span>
                  </div>
                  <Badge className="bg-red-500/90 text-white text-[10px] font-bold border-0 px-2 animate-live-pulse">
                    LIVE
                  </Badge>
                </div>

                {/* Light Content Section */}
                <CardContent className="p-4 bg-gray-50 space-y-3">
                  <div className="flex items-center gap-2 flex-wrap">
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                      <GraduationCap className="w-3.5 h-3.5 text-secondary" />
                      <span>{session.grade} Grade</span>
                    </div>
                    <span className="text-muted-foreground">•</span>
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                      <BookOpen className="w-3.5 h-3.5 text-secondary" />
                      <span>{session.subject}</span>
                    </div>
                  </div>

                  <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <Calendar className="w-3.5 h-3.5 text-secondary" />
                    <span>{session.className}</span>
                  </div>

                  <div className="flex items-center gap-3 flex-wrap">
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                      <Calendar className="w-3.5 h-3.5 text-secondary" />
                      <span>{new Date(session.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                      <Clock className="w-3.5 h-3.5 text-secondary" />
                      <span>{session.time}</span>
                    </div>
                    <Badge className="text-[10px] bg-blue-500/10 text-blue-600 border border-blue-500/20 font-medium">
                      {session.platform}
                    </Badge>
                  </div>

                  <div className="flex items-center gap-2">
                    <Button
                      size="sm"
                      className="flex-1 h-9 text-xs bg-secondary hover:bg-secondary/90 text-white font-medium"
                      onClick={() => window.open(session.meetingLink, '_blank')}
                    >
                      <ExternalLink className="w-3.5 h-3.5 mr-1.5" />
                      Start Session
                    </Button>
                    <Button
                      size="sm"
                      variant="outline"
                      className="h-9 w-9 p-0 border-red-200 text-red-500 hover:bg-red-50 hover:text-red-600"
                      onClick={() => handleDeleteSession(session.id, session.title)}
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}

      {/* Upcoming Sessions Section */}
      <div className="space-y-3">
        <h2 className="text-sm font-semibold text-foreground px-1">
          Upcoming Sessions ({upcomingSessions.length})
        </h2>

        {upcomingSessions.length === 0 ? (
          <Card className="border-2 border-primary/20 bg-white">
            <CardContent className="p-8 text-center">
              <Video className="w-10 h-10 mx-auto text-muted-foreground/50 mb-2" />
              <p className="text-sm text-muted-foreground">
                No upcoming sessions scheduled
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-3">
            {upcomingSessions.map(session => (
              <Card key={session.id} className="border-2 border-primary/20 overflow-hidden shadow-sm">
                {/* Blue Header */}
                <div className="bg-primary px-4 py-2.5 flex items-center gap-2 text-white">
                  <Video className="w-4 h-4" />
                  <span className="font-semibold text-sm">{session.title}</span>
                </div>

                {/* Light Content Section */}
                <CardContent className="p-4 bg-gray-50 space-y-3">
                  <div className="flex items-center gap-2 flex-wrap">
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                      <GraduationCap className="w-3.5 h-3.5 text-primary" />
                      <span>{session.grade} Grade</span>
                    </div>
                    <span className="text-muted-foreground">•</span>
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                      <BookOpen className="w-3.5 h-3.5 text-primary" />
                      <span>{session.subject}</span>
                    </div>
                  </div>

                  <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                    <Calendar className="w-3.5 h-3.5 text-primary" />
                    <span>{session.className}</span>
                  </div>

                  <div className="flex items-center gap-3 flex-wrap">
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                      <Calendar className="w-3.5 h-3.5 text-primary" />
                      <span>{new Date(session.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                    </div>
                    <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                      <Clock className="w-3.5 h-3.5 text-primary" />
                      <span>{session.time}</span>
                    </div>
                    <Badge className="text-[10px] bg-blue-500/10 text-blue-600 border border-blue-500/20 font-medium">
                      {session.platform}
                    </Badge>
                  </div>

                  <div className="flex items-center gap-2">
                    <Button
                      size="sm"
                      variant="outline"
                      className="h-9 w-9 p-0 border-red-200 text-red-500 hover:bg-red-50 hover:text-red-600"
                      onClick={() => handleDeleteSession(session.id, session.title)}
                    >
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}