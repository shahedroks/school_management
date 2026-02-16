import React, { useState, useEffect } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { useLanguage } from '@/contexts/LanguageContext';
import { mockAssignments, mockClasses, mockSubmissions } from '@/data/mockData';
import { Card, CardContent } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Textarea } from '@/app/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/app/components/ui/select';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from '@/app/components/ui/dialog';
import { FileText, Calendar, Plus, CheckCircle, Clock, Upload, BookOpen, X } from 'lucide-react';

export function TeacherAssignmentsList() {
  const { t } = useLanguage();
  const [searchParams, setSearchParams] = useSearchParams();
  const [filter, setFilter] = useState<'all' | 'active' | 'graded'>('all');
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(
    searchParams.get('create') === 'true'
  );
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    classId: '',
    dueDate: '',
    dueTime: '',
    points: '',
  });
  const [attachedFiles, setAttachedFiles] = useState<File[]>([]);

  // State to manage assignments list with localStorage persistence
  const [assignments, setAssignments] = useState(() => {
    // Try to load from localStorage first
    const savedAssignments = localStorage.getItem('teacherAssignments');
    if (savedAssignments) {
      try {
        return JSON.parse(savedAssignments);
      } catch (e) {
        console.error('Error loading saved assignments:', e);
      }
    }
    // Initialize with mock assignments for Advanced Mathematics (class1)
    return mockAssignments.filter(assignment => assignment.classId === 'class1');
  });

  // Save assignments to localStorage whenever they change
  useEffect(() => {
    localStorage.setItem('teacherAssignments', JSON.stringify(assignments));
  }, [assignments]);

  // Filter assignments to only show those for Advanced Mathematics (class1)
  const myClassAssignments = assignments;
  
  const filteredAssignments = myClassAssignments.filter(assignment => {
    if (filter === 'all') return true;
    if (filter === 'active') {
      return new Date(assignment.dueDate) >= new Date();
    }
    if (filter === 'graded') {
      return new Date(assignment.dueDate) < new Date();
    }
    return true;
  });

  const handleCreateAssignment = () => {
    // Create new assignment object
    const newAssignment = {
      id: `assignment${Date.now()}`, // Generate unique ID
      title: formData.title,
      description: formData.description,
      classId: formData.classId,
      dueDate: formData.dueDate,
      points: parseInt(formData.points),
      teacherId: 'teacher1', // Mohammed Ould
      createdAt: new Date().toISOString(),
      attachments: attachedFiles.map(file => ({
        name: file.name,
        size: file.size,
        type: file.type,
      })),
    };

    // Add new assignment to the list (at the beginning)
    setAssignments(prev => [newAssignment, ...prev]);

    const classData = mockClasses.find(c => c.id === formData.classId);
    
    // Close dialog and reset form
    setIsCreateDialogOpen(false);
    setFormData({
      title: '',
      description: '',
      classId: '',
      dueDate: '',
      dueTime: '',
      points: '',
    });
    setAttachedFiles([]);

    // Show success message
    alert(`Assignment created successfully!\n\nTitle: ${formData.title}\nClass: ${classData?.name}\nDue: ${new Date(formData.dueDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}\nPoints: ${formData.points}`);
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files) return;

    const newFiles = Array.from(files);
    const validFiles = newFiles.filter(file => {
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (file.size > maxSize) {
        alert(`${file.name} is too large. Max file size is 10MB.`);
        return false;
      }
      return true;
    });

    setAttachedFiles(prev => [...prev, ...validFiles]);
  };

  const handleRemoveFile = (index: number) => {
    setAttachedFiles(prev => prev.filter((_, i) => i !== index));
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  };

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <div className="flex justify-between items-start mb-2">
          <div>
            <h1 className="text-xl font-bold">Assignments</h1>
            <p className="text-sm text-white/90 mt-0.5">
              Manage and grade student submissions
            </p>
          </div>
          <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="h-8 text-xs bg-white text-primary hover:bg-white/90">
                <Plus className="w-3.5 h-3.5 mr-1" />
                Create
              </Button>
            </DialogTrigger>
            <DialogContent className="w-[380px] max-h-[800px] overflow-y-auto">
              <DialogHeader>
                <DialogTitle className="text-base">Create New Assignment</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 py-3">
                {/* Assignment Title */}
                <div className="space-y-2">
                  <Label htmlFor="title" className="text-xs font-medium">
                    Assignment Title *
                  </Label>
                  <Input
                    id="title"
                    placeholder="e.g., Chapter 5 Homework"
                    value={formData.title}
                    onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                {/* Description */}
                <div className="space-y-2">
                  <Label htmlFor="description" className="text-xs font-medium">
                    Description *
                  </Label>
                  <Textarea
                    id="description"
                    placeholder="Provide clear instructions for the assignment..."
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                    className="min-h-[80px] text-sm border-primary/20"
                  />
                </div>

                {/* Class Selection */}
                <div className="space-y-2">
                  <Label htmlFor="class" className="text-xs font-medium">
                    Select Class *
                  </Label>
                  <Select
                    value={formData.classId}
                    onValueChange={(value) => setFormData({ ...formData, classId: value })}
                  >
                    <SelectTrigger className="h-9 text-sm border-primary/20">
                      <SelectValue placeholder="Choose a class" />
                    </SelectTrigger>
                    <SelectContent>
                      {mockClasses.map((cls) => (
                        <SelectItem key={cls.id} value={cls.id} className="text-sm">
                          {cls.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Due Date */}
                <div className="space-y-2">
                  <Label htmlFor="dueDate" className="text-xs font-medium">
                    Due Date *
                  </Label>
                  <Input
                    id="dueDate"
                    type="date"
                    value={formData.dueDate}
                    onChange={(e) => setFormData({ ...formData, dueDate: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                {/* Due Time */}
                <div className="space-y-2">
                  <Label htmlFor="dueTime" className="text-xs font-medium">
                    Due Time *
                  </Label>
                  <Input
                    id="dueTime"
                    type="time"
                    value={formData.dueTime}
                    onChange={(e) => setFormData({ ...formData, dueTime: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                {/* Points */}
                <div className="space-y-2">
                  <Label htmlFor="points" className="text-xs font-medium">
                    Total Points *
                  </Label>
                  <Input
                    id="points"
                    type="number"
                    min="1"
                    placeholder="100"
                    value={formData.points}
                    onChange={(e) => setFormData({ ...formData, points: e.target.value })}
                    className="h-9 text-sm border-primary/20"
                  />
                </div>

                {/* File Upload (Optional) */}
                <div className="space-y-2">
                  <Label htmlFor="file" className="text-xs font-medium">
                    Attach Files
                  </Label>
                  <input
                    id="file-upload"
                    type="file"
                    multiple
                    accept=".pdf,.doc,.docx,.ppt,.pptx"
                    onChange={handleFileSelect}
                    className="hidden"
                  />
                  <label
                    htmlFor="file-upload"
                    className="border-2 border-dashed border-primary/20 rounded-lg p-4 text-center hover:border-primary/40 transition-colors cursor-pointer block"
                  >
                    <Upload className="w-8 h-8 text-primary mx-auto mb-2" />
                    <p className="text-xs text-muted-foreground">
                      Click to upload assignment files
                    </p>
                    <p className="text-[10px] text-muted-foreground mt-1">
                      PDF, DOC, PPT (Max 10MB)
                    </p>
                  </label>

                  {/* Attached Files List */}
                  {attachedFiles.length > 0 && (
                    <div className="space-y-2 mt-2">
                      {attachedFiles.map((file, index) => (
                        <div
                          key={index}
                          className="flex items-center justify-between p-2 bg-primary/5 rounded-lg border border-primary/20"
                        >
                          <div className="flex items-center gap-2 flex-1 min-w-0">
                            <FileText className="w-4 h-4 text-primary flex-shrink-0" />
                            <div className="flex-1 min-w-0">
                              <p className="text-xs font-medium text-foreground truncate">
                                {file.name}
                              </p>
                              <p className="text-[10px] text-muted-foreground">
                                {formatFileSize(file.size)}
                              </p>
                            </div>
                          </div>
                          <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={() => handleRemoveFile(index)}
                            className="h-7 w-7 p-0 hover:bg-destructive/10 flex-shrink-0"
                          >
                            <X className="w-4 h-4 text-destructive" />
                          </Button>
                        </div>
                      ))}
                    </div>
                  )}
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
                  onClick={handleCreateAssignment}
                  disabled={!formData.title || !formData.description || !formData.classId || !formData.dueDate || !formData.dueTime || !formData.points}
                  className="h-9 text-xs bg-primary"
                >
                  Create Assignment
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      {/* Filter Buttons */}
      <div className="flex gap-2 overflow-x-auto pb-1">
        <Button
          variant={filter === 'all' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setFilter('all')}
          className={filter === 'all' ? 'bg-primary' : 'border-primary/20 text-foreground'}
        >
          All ({myClassAssignments.length})
        </Button>
        <Button
          variant={filter === 'active' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setFilter('active')}
          className={filter === 'active' ? 'bg-primary' : 'border-primary/20 text-foreground'}
        >
          Active ({myClassAssignments.filter(a => new Date(a.dueDate) >= new Date()).length})
        </Button>
        <Button
          variant={filter === 'graded' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setFilter('graded')}
          className={filter === 'graded' ? 'bg-secondary' : 'border-primary/20 text-foreground'}
        >
          Past ({myClassAssignments.filter(a => new Date(a.dueDate) < new Date()).length})
        </Button>
      </div>

      {/* Assignments List */}
      <div className="space-y-3">
        {filteredAssignments.length === 0 ? (
          <Card className="border-2 border-primary/20">
            <CardContent className="p-12 text-center">
              <FileText className="w-12 h-12 text-muted-foreground mx-auto mb-3" />
              <p className="text-sm text-muted-foreground">No assignments found</p>
            </CardContent>
          </Card>
        ) : (
          filteredAssignments.map(assignment => {
            const classData = mockClasses.find(c => c.id === assignment.classId);
            const totalStudents = classData?.students || 25;
            const submissions = mockSubmissions.filter(s => s.assignmentId === assignment.id);
            const submissionsCount = submissions.length;
            const gradedCount = submissions.filter(s => s.status === 'graded').length;
            const pendingCount = submissionsCount - gradedCount;

            return (
              <Link
                key={assignment.id}
                to={`/teacher/assignments/${assignment.id}`}
              >
                <Card className="overflow-hidden hover:shadow-md transition-shadow border-2 border-primary/20">
                  {/* Class Header Bar */}
                  <div
                    className="h-12 relative flex items-center px-3"
                    style={{
                      background: `linear-gradient(135deg, #1F3C88, #1F3C88dd)`,
                    }}
                  >
                    <div className="flex items-center gap-2">
                      <FileText className="w-4 h-4 text-white" />
                      <span className="text-sm font-semibold text-white">
                        {classData?.name || 'Unknown Class'}
                      </span>
                    </div>
                  </div>

                  <CardContent className="p-3 space-y-3">
                    {/* Assignment Title & Description */}
                    <div>
                      <div className="flex items-start justify-between gap-2 mb-1">
                        <h3 className="text-sm font-semibold text-foreground">
                          {assignment.title}
                        </h3>
                        <Badge className="text-[10px] bg-primary/10 text-primary border-primary/20">
                          {assignment.points} pts
                        </Badge>
                      </div>
                      <p className="text-xs text-muted-foreground line-clamp-2">
                        {assignment.description}
                      </p>
                    </div>

                    {/* Assignment Info */}
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <Calendar className="w-3.5 h-3.5 text-primary" />
                      <span>
                        Due: {new Date(assignment.dueDate).toLocaleDateString('en-US', {
                          month: 'short',
                          day: 'numeric',
                          year: 'numeric',
                        })}
                      </span>
                    </div>

                    {/* Submission Stats */}
                    <div className="flex items-center justify-between gap-2 pt-2 border-t border-primary/10">
                      <div className="flex items-center gap-3">
                        <div className="flex items-center gap-1">
                          <FileText className="w-3.5 h-3.5 text-primary" />
                          <span className="text-xs font-medium text-foreground">
                            {submissionsCount}/{totalStudents}
                          </span>
                          <span className="text-xs text-muted-foreground">submitted</span>
                        </div>
                        {pendingCount > 0 && (
                          <Badge className="text-[10px] bg-accent/20 text-accent-foreground border-accent/30 flex items-center gap-1">
                            <Clock className="w-3 h-3" />
                            {pendingCount} to grade
                          </Badge>
                        )}
                        {pendingCount === 0 && submissionsCount > 0 && (
                          <Badge className="text-[10px] bg-secondary/20 text-secondary border-secondary/30 flex items-center gap-1">
                            <CheckCircle className="w-3 h-3" />
                            All graded
                          </Badge>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </Link>
            );
          })
        )}
      </div>
    </div>
  );
}