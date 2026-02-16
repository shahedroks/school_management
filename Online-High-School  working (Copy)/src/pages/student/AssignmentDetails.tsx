import React, { useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { mockAssignments, mockClasses } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Textarea } from '@/app/components/ui/textarea';
import { Label } from '@/app/components/ui/label';
import { Input } from '@/app/components/ui/input';
import {
  FileText,
  Calendar,
  AlertCircle,
  Upload,
  CheckCircle,
  ChevronLeft,
  Star,
  Paperclip,
  File,
  X,
} from 'lucide-react';
import { Alert, AlertDescription, AlertTitle } from '@/app/components/ui/alert';

export function AssignmentDetails() {
  const { assignmentId } = useParams<{ assignmentId: string }>();
  const assignment = mockAssignments.find(a => a.id === assignmentId);
  const classData = assignment
    ? mockClasses.find(c => c.id === assignment.classId)
    : null;

  const [submissionText, setSubmissionText] = useState('');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [submitted, setSubmitted] = useState(assignment?.status !== 'pending');
  const [currentStatus, setCurrentStatus] = useState(assignment?.status || 'pending');

  if (!assignment || !classData) {
    return <div>Assignment not found</div>;
  }

  const daysUntilDue = Math.ceil(
    (new Date(assignment.dueDate).getTime() - new Date().getTime()) /
      (1000 * 60 * 60 * 24)
  );

  const isOverdue = daysUntilDue < 0;
  const isUrgent = daysUntilDue <= 2 && daysUntilDue >= 0;

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setSelectedFile(e.target.files[0]);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Mock submission
    setSubmitted(true);
    setCurrentStatus('submitted');
  };

  return (
    <div className="space-y-4">
      {/* Status Alerts */}
      {isOverdue && currentStatus === 'pending' && (
        <Alert variant="destructive" className="py-2.5">
          <AlertCircle className="h-3.5 w-3.5" />
          <AlertTitle className="text-xs">Overdue</AlertTitle>
          <AlertDescription className="text-xs">
            Due {new Date(assignment.dueDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}. Late submissions may receive reduced points.
          </AlertDescription>
        </Alert>
      )}

      {isUrgent && currentStatus === 'pending' && (
        <Alert className="py-2.5">
          <AlertCircle className="h-3.5 w-3.5" />
          <AlertTitle className="text-xs">Due Soon</AlertTitle>
          <AlertDescription className="text-xs">
            Due in {daysUntilDue} day{daysUntilDue !== 1 ? 's' : ''}.
          </AlertDescription>
        </Alert>
      )}

      {submitted && (
        <Alert className="border-green-200 bg-green-50 py-2.5">
          <CheckCircle className="h-3.5 w-3.5 text-green-600" />
          <AlertTitle className="text-green-900 text-xs">Submitted</AlertTitle>
          <AlertDescription className="text-green-800 text-xs">
            Your submission has been received. You'll be notified when it's graded.
          </AlertDescription>
        </Alert>
      )}

      {/* Assignment Details */}
      <Card>
        <CardHeader className="pb-3">
          <div className="flex items-start gap-3 mb-2">
            <div className="p-2 bg-blue-100 rounded-lg text-blue-600 flex-shrink-0">
              <FileText className="w-4 h-4" />
            </div>
            <Badge
              className="text-[10px] px-2 py-0.5"
              variant={
                currentStatus === 'graded'
                  ? 'default'
                  : currentStatus === 'submitted'
                  ? 'secondary'
                  : isOverdue
                  ? 'destructive'
                  : 'outline'
              }
            >
              {currentStatus}
            </Badge>
          </div>
          <CardTitle className="text-base leading-tight">{assignment.title}</CardTitle>
          <p className="text-xs text-gray-600 mt-1.5 leading-relaxed">{assignment.description}</p>
        </CardHeader>
        <CardContent className="pt-0">
          <div className="grid grid-cols-2 gap-2 p-3 bg-gray-50 rounded-lg">
            <div>
              <p className="text-[10px] text-gray-600 uppercase tracking-wide">Class</p>
              <p className="text-xs font-semibold text-gray-900 mt-0.5 truncate">{classData.name}</p>
            </div>
            <div>
              <p className="text-[10px] text-gray-600 uppercase tracking-wide">Due Date</p>
              <p className="text-xs font-semibold text-gray-900 mt-0.5">
                {new Date(assignment.dueDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
              </p>
            </div>
            <div>
              <p className="text-[10px] text-gray-600 uppercase tracking-wide">Points</p>
              <p className="text-xs font-semibold text-gray-900 mt-0.5">{assignment.points}</p>
            </div>
            <div>
              <p className="text-[10px] text-gray-600 uppercase tracking-wide">Status</p>
              <p
                className={`text-xs font-semibold mt-0.5 capitalize ${
                  currentStatus === 'graded'
                    ? 'text-green-600'
                    : currentStatus === 'submitted'
                    ? 'text-blue-600'
                    : isOverdue
                    ? 'text-red-600'
                    : 'text-orange-600'
                }`}
              >
                {currentStatus}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Grade and Feedback (if graded) */}
      {assignment.status === 'graded' && assignment.grade !== undefined && (
        <Card className="border-green-200">
          <CardHeader className="pb-3">
            <CardTitle className="flex items-center gap-2 text-green-900 text-base">
              <Star className="w-4 h-4 fill-green-600 text-green-600" />
              Grade and Feedback
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-3 pt-0">
            <div className="flex items-center gap-4">
              <div className="text-center">
                <div className="text-3xl font-bold text-green-600">
                  {assignment.grade}
                </div>
                <div className="text-xs text-gray-600">of {assignment.points}</div>
              </div>
              <div className="flex-1">
                <div className="bg-gray-200 rounded-full h-1.5">
                  <div
                    className="bg-green-600 h-1.5 rounded-full"
                    style={{
                      width: `${(assignment.grade / assignment.points) * 100}%`,
                    }}
                  />
                </div>
                <p className="text-xs text-gray-600 mt-1">
                  {((assignment.grade / assignment.points) * 100).toFixed(1)}% Score
                </p>
              </div>
            </div>
            {assignment.feedback && (
              <div className="bg-green-50 p-3 rounded-lg">
                <p className="text-xs font-medium text-gray-700 mb-1.5">
                  Teacher's Feedback:
                </p>
                <p className="text-xs text-gray-700">{assignment.feedback}</p>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Submission Form (if not submitted) */}
      {!submitted && (
        <Card className="overflow-hidden border-2 border-primary/20">
          <div className="bg-gradient-to-r from-primary to-primary/90 p-4">
            <CardTitle className="text-base text-white flex items-center gap-2">
              <Upload className="w-4 h-4" />
              Submit Assignment
            </CardTitle>
            <p className="text-xs text-white/80 mt-1">
              Upload your work or write your response below
            </p>
          </div>
          <CardContent className="pt-4">
            <form onSubmit={handleSubmit} className="space-y-5">
              {/* File Upload Section */}
              <div className="space-y-2">
                <Label htmlFor="file" className="text-xs font-semibold text-gray-700 flex items-center gap-1.5">
                  <Paperclip className="w-3.5 h-3.5 text-primary" />
                  Upload File
                </Label>
                <div className="relative">
                  <Input
                    id="file"
                    type="file"
                    onChange={handleFileChange}
                    accept=".pdf,.doc,.docx,.txt"
                    className="hidden"
                  />
                  <label
                    htmlFor="file"
                    className="flex items-center justify-center gap-2 p-4 border-2 border-dashed border-primary/30 rounded-lg bg-primary/5 hover:bg-primary/10 transition-colors cursor-pointer group"
                  >
                    <div className="flex flex-col items-center gap-1.5">
                      <div className="p-2 bg-primary/10 rounded-full group-hover:bg-primary/20 transition-colors">
                        <Upload className="w-5 h-5 text-primary" />
                      </div>
                      <div className="text-center">
                        <p className="text-xs font-semibold text-primary">
                          {selectedFile ? 'Change File' : 'Choose File'}
                        </p>
                        <p className="text-[10px] text-gray-500 mt-0.5">
                          PDF, DOC, DOCX, or TXT
                        </p>
                      </div>
                    </div>
                  </label>
                </div>
                {selectedFile && (
                  <div className="flex items-center gap-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <div className="p-1.5 bg-blue-100 rounded">
                      <File className="w-3.5 h-3.5 text-blue-600" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-xs font-medium text-blue-900 truncate">
                        {selectedFile.name}
                      </p>
                      <p className="text-[10px] text-blue-600">
                        {(selectedFile.size / 1024).toFixed(1)} KB
                      </p>
                    </div>
                    <button
                      type="button"
                      onClick={() => setSelectedFile(null)}
                      className="p-1 hover:bg-blue-100 rounded transition-colors"
                    >
                      <X className="w-3.5 h-3.5 text-blue-600" />
                    </button>
                  </div>
                )}
              </div>

              {/* Divider */}
              <div className="relative">
                <div className="absolute inset-0 flex items-center">
                  <div className="w-full border-t border-gray-200"></div>
                </div>
                <div className="relative flex justify-center text-[10px] uppercase">
                  <span className="bg-white px-2 text-gray-500 tracking-wide">Or</span>
                </div>
              </div>

              {/* Written Submission Section */}
              <div className="space-y-2">
                <Label htmlFor="text" className="text-xs font-semibold text-gray-700 flex items-center gap-1.5">
                  <FileText className="w-3.5 h-3.5 text-primary" />
                  Written Submission
                </Label>
                <div className="relative">
                  <Textarea
                    id="text"
                    placeholder="Type your assignment response here..."
                    value={submissionText}
                    onChange={e => setSubmissionText(e.target.value)}
                    rows={6}
                    className="text-xs border-2 border-gray-200 focus:border-primary/50 bg-gray-50 focus:bg-white transition-colors"
                  />
                  <div className="absolute bottom-2 right-2 text-[10px] text-gray-400">
                    {submissionText.length} characters
                  </div>
                </div>
              </div>

              {/* Submit Button */}
              <div className="pt-2">
                <Button
                  type="submit"
                  className="w-full h-12 text-sm font-semibold bg-gradient-to-r from-primary to-primary/90 hover:from-primary/90 hover:to-primary shadow-md hover:shadow-lg transition-all"
                  disabled={!submissionText && !selectedFile}
                >
                  <Upload className="w-4 h-4 mr-2" />
                  Submit Assignment
                </Button>
                {!submissionText && !selectedFile && (
                  <p className="text-[10px] text-gray-500 text-center mt-2">
                    Please add a file or write your response to submit
                  </p>
                )}
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Submission View (if submitted) */}
      {submitted && currentStatus !== 'graded' && (
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base">Your Submission</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3 pt-0">
            <div className="bg-blue-50 p-3 rounded-lg">
              <p className="text-xs text-blue-900">
                Submitted on {new Date().toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} at{' '}
                {new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })}
              </p>
            </div>
            <div className="text-gray-700">
              <p className="text-xs font-medium mb-2">Your Response:</p>
              <p className="bg-gray-50 p-3 rounded-lg text-xs">
                {submissionText || 'File submission only'}
              </p>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}