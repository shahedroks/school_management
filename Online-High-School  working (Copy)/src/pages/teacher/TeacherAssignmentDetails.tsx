import React, { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { mockAssignments, mockClasses, mockSubmissions, mockStudents } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Textarea } from '@/app/components/ui/textarea';
import { Input } from '@/app/components/ui/input';
import { ArrowLeft, FileText, Calendar, User, Download, CheckCircle, Clock, AlertCircle } from 'lucide-react';

export function TeacherAssignmentDetails() {
  const { assignmentId } = useParams<{ assignmentId: string }>();
  const navigate = useNavigate();
  
  // State for assignment data
  const [assignment, setAssignment] = useState<any>(null);
  const [classData, setClassData] = useState<any>(null);
  
  // Load assignment from localStorage or mockData
  useEffect(() => {
    const savedAssignments = localStorage.getItem('teacherAssignments');
    let foundAssignment = null;
    
    if (savedAssignments) {
      try {
        const allAssignments = JSON.parse(savedAssignments);
        foundAssignment = allAssignments.find((a: any) => a.id === assignmentId);
      } catch (e) {
        console.error('Error loading saved assignments:', e);
      }
    }
    
    // Fallback to mock assignments
    if (!foundAssignment) {
      foundAssignment = mockAssignments.find(a => a.id === assignmentId);
    }
    
    if (foundAssignment) {
      setAssignment(foundAssignment);
      const cls = mockClasses.find(c => c.id === foundAssignment.classId);
      setClassData(cls);
    }
  }, [assignmentId]);
  
  const submissions = mockSubmissions.filter(s => s.assignmentId === assignmentId);
  
  const [selectedSubmission, setSelectedSubmission] = useState<string | null>(null);
  const [grade, setGrade] = useState<string>('');
  const [feedback, setFeedback] = useState<string>('');

  // Assignment not found state
  if (assignment === null) {
    return (
      <div className="p-4">
        <Card className="border-2 border-primary/20">
          <CardContent className="p-12 text-center">
            <p className="text-sm text-muted-foreground">Assignment not found</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (!assignment || !classData) {
    return (
      <div className="p-4">
        <Card className="border-2 border-primary/20">
          <CardContent className="p-12 text-center">
            <p className="text-sm text-muted-foreground">Assignment not found</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const totalStudents = classData.students || 28;
  const submissionsCount = submissions.length;
  const gradedCount = submissions.filter(s => s.status === 'graded').length;
  const pendingCount = submissionsCount - gradedCount;

  const handleGradeSubmission = (submissionId: string) => {
    // Mock grading functionality
    console.log('Grading submission:', submissionId, { grade, feedback });
    alert(`Graded successfully!\nGrade: ${grade}/${assignment.points}\nFeedback: ${feedback}`);
    setSelectedSubmission(null);
    setGrade('');
    setFeedback('');
  };

  return (
    <div className="space-y-4 pb-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm space-y-3">
        <Link to={`/teacher/classes/${assignment.classId}`}>
          <Button 
            variant="ghost" 
            size="sm" 
            className="h-8 text-white hover:bg-white/20 mb-2 -ml-2"
          >
            <ArrowLeft className="w-4 h-4 mr-1.5" />
            Back to Class
          </Button>
        </Link>

        <div>
          <div className="flex items-start justify-between gap-2 mb-1">
            <h1 className="text-lg font-bold flex-1">{assignment.title}</h1>
            <Badge className="bg-white/20 text-white border-white/30 text-[10px] px-2 py-0.5">
              {assignment.points} pts
            </Badge>
          </div>
          <p className="text-sm text-white/90">{classData.name || 'Mathematics'}</p>
        </div>

        <div className="flex items-center gap-2 text-xs text-white/90 pt-2 border-t border-white/20">
          <Calendar className="w-3.5 h-3.5" />
          <span>
            Due: {new Date(assignment.dueDate).toLocaleDateString('en-US', {
              month: 'long',
              day: 'numeric',
              year: 'numeric',
            })}
          </span>
        </div>
      </div>

      {/* Statistics */}
      <div className="grid grid-cols-3 gap-3 px-4">
        <Card className="border-2 border-primary/20">
          <CardContent className="p-4 text-center">
            <FileText className="w-6 h-6 text-primary mx-auto mb-2" />
            <p className="text-xl font-bold text-foreground">{submissionsCount}/{totalStudents}</p>
            <p className="text-xs text-muted-foreground mt-1">Submitted</p>
          </CardContent>
        </Card>
        <Card className="border-2 border-secondary/20">
          <CardContent className="p-4 text-center">
            <CheckCircle className="w-6 h-6 text-secondary mx-auto mb-2" />
            <p className="text-xl font-bold text-foreground">{gradedCount}</p>
            <p className="text-xs text-muted-foreground mt-1">Graded</p>
          </CardContent>
        </Card>
        <Card className="border-2 border-accent/20">
          <CardContent className="p-4 text-center">
            <Clock className="w-6 h-6 text-accent mx-auto mb-2" />
            <p className="text-xl font-bold text-foreground">{pendingCount}</p>
            <p className="text-xs text-muted-foreground mt-1">Pending</p>
          </CardContent>
        </Card>
      </div>

      {/* Assignment Description */}
      <div className="px-4">
        <Card className="border-2 border-primary/20">
          <CardHeader className="pb-2 pt-3 px-4">
            <CardTitle className="text-sm flex items-center gap-2 font-semibold">
              <FileText className="w-4 h-4 text-primary" />
              Assignment Description
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-2 px-4 pb-4">
            <p className="text-sm text-muted-foreground leading-relaxed">
              {assignment.description || 'Create a real-world application of systems of equations'}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Submissions List */}
      <div className="px-4">
        <Card className="border-2 border-primary/20">
          <CardHeader className="pb-2 pt-3 px-4">
            <CardTitle className="text-sm flex items-center gap-2 font-semibold">
              <User className="w-4 h-4 text-primary" />
              Student Submissions ({submissionsCount})
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-3 px-4 pb-4">
            {submissions.length === 0 ? (
              <div className="py-12 text-center">
                <FileText className="w-16 h-16 text-muted-foreground mx-auto mb-3 opacity-40" />
                <p className="text-sm text-muted-foreground font-medium">No submissions yet</p>
              </div>
            ) : (
              <div className="space-y-3">
                {submissions.map(submission => {
                  const student = mockStudents.find(s => s.id === submission.studentId);
                  const isSelected = selectedSubmission === submission.id;

                  return (
                    <div key={submission.id}>
                      <Card className={`border-2 ${isSelected ? 'border-primary' : 'border-primary/20'}`}>
                        <CardContent className="p-3">
                          <div className="flex items-start justify-between gap-2 mb-2">
                            <div className="flex items-center gap-2">
                              <div className="w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                                <span className="text-xs font-semibold text-primary">
                                  {student?.name.split(' ').map(n => n[0]).join('') || 'ST'}
                                </span>
                              </div>
                              <div>
                                <p className="text-sm font-semibold text-foreground">{student?.name || 'Unknown Student'}</p>
                                <p className="text-xs text-muted-foreground">
                                  Submitted: {new Date(submission.submittedAt).toLocaleDateString('en-US', {
                                    month: 'short',
                                    day: 'numeric',
                                  })}
                                </p>
                              </div>
                            </div>
                            {submission.status === 'graded' && submission.grade !== undefined ? (
                              <Badge className="text-[10px] bg-secondary/10 text-secondary border-secondary/20">
                                {submission.grade}/{assignment.points}
                              </Badge>
                            ) : (
                              <Badge className="text-[10px] bg-accent/10 text-accent border-accent/20 flex items-center gap-1">
                                <Clock className="w-3 h-3" />
                                Pending
                              </Badge>
                            )}
                          </div>

                          {submission.file && (
                            <div className="flex items-center gap-2 mb-2 p-2 bg-muted rounded text-xs">
                              <FileText className="w-3.5 h-3.5 text-primary" />
                              <span className="flex-1 truncate text-muted-foreground">{submission.file}</span>
                              <Download className="w-3.5 h-3.5 text-primary" />
                            </div>
                          )}

                          {submission.status === 'graded' && submission.feedback && (
                            <div className="p-2 bg-secondary/5 rounded border border-secondary/20 mb-2">
                              <p className="text-xs font-medium text-secondary mb-1">Feedback:</p>
                              <p className="text-xs text-muted-foreground">{submission.feedback}</p>
                            </div>
                          )}

                          {submission.status !== 'graded' && (
                            <Button
                              size="sm"
                              className="w-full h-8 text-xs bg-primary mt-2"
                              onClick={() => {
                                setSelectedSubmission(isSelected ? null : submission.id);
                                setGrade(submission.grade?.toString() || '');
                                setFeedback(submission.feedback || '');
                              }}
                            >
                              {isSelected ? 'Cancel Grading' : 'Grade Submission'}
                            </Button>
                          )}

                          {/* Grading Form */}
                          {isSelected && (
                            <div className="mt-3 space-y-3 pt-3 border-t border-primary/20">
                              <div>
                                <label className="text-xs font-medium text-foreground mb-1.5 block">
                                  Grade (out of {assignment.points})
                                </label>
                                <Input
                                  type="number"
                                  min="0"
                                  max={assignment.points}
                                  placeholder="Enter grade"
                                  value={grade}
                                  onChange={(e) => setGrade(e.target.value)}
                                  className="h-9 text-sm border-primary/20"
                                />
                              </div>
                              <div>
                                <label className="text-xs font-medium text-foreground mb-1.5 block">
                                  Feedback
                                </label>
                                <Textarea
                                  placeholder="Provide feedback to the student..."
                                  value={feedback}
                                  onChange={(e) => setFeedback(e.target.value)}
                                  className="min-h-[80px] text-sm border-primary/20"
                                />
                              </div>
                              <Button
                                size="sm"
                                className="w-full h-9 text-xs bg-secondary"
                                onClick={() => handleGradeSubmission(submission.id)}
                                disabled={!grade}
                              >
                                <CheckCircle className="w-3.5 h-3.5 mr-1.5" />
                                Submit Grade
                              </Button>
                            </div>
                          )}
                        </CardContent>
                      </Card>
                    </div>
                  );
                })}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}