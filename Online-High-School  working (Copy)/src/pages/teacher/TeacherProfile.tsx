import React, { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { mockClasses, mockAssignments, mockSubmissions } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Textarea } from '@/app/components/ui/textarea';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from '@/app/components/ui/dialog';
import { Avatar, AvatarFallback } from '@/app/components/ui/avatar';
import { LanguageSelectorDropdown } from '@/components/LanguageSelectorDropdown';
import {
  User,
  Mail,
  GraduationCap,
  BookOpen,
  FileText,
  Award,
  Users,
  Edit2,
  Phone,
  MapPin,
  Calendar,
  CheckCircle,
  Clock,
} from 'lucide-react';

export function TeacherProfile() {
  const { user } = useAuth();
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [formData, setFormData] = useState({
    name: user?.name || '',
    email: user?.email || '',
    phone: '+222 45 67 89 10',
    address: 'Nouadhibou, Mauritania',
    department: 'Mathematics Department',
    officeHours: 'Mon-Thu 2:00 PM - 4:00 PM',
    bio: 'Passionate mathematics educator with over 10 years of experience in secondary education. Specialized in algebra, calculus, and mathematical problem-solving.',
    qualifications: 'M.Sc. in Mathematics Education',
  });

  const teacherClasses = mockClasses.filter(c => c.teacherId === user?.id);
  const totalStudents = teacherClasses.reduce((sum, cls) => sum + cls.students, 0);
  const teacherAssignments = mockAssignments.filter(a => 
    teacherClasses.some(cls => cls.id === a.classId)
  );
  const pendingSubmissions = mockSubmissions.filter(s => s.status === 'submitted').length;

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase();
  };

  const handleSaveProfile = () => {
    console.log('Saving profile:', formData);
    alert('Profile updated successfully!');
    setIsEditDialogOpen(false);
  };

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <h1 className="text-xl font-bold">My Profile</h1>
        <p className="text-sm text-white/90 mt-0.5">
          Manage your professional information
        </p>
      </div>

      {/* Profile Card */}
      <Card className="border-2 border-primary/20">
        <CardContent className="p-4">
          <div className="flex flex-col items-center text-center mb-4">
            <Avatar className="h-20 w-20 mb-3 border-4 border-primary/20">
              <AvatarFallback className="bg-primary text-primary-foreground text-2xl">
                {user ? getInitials(user.name) : 'U'}
              </AvatarFallback>
            </Avatar>
            <h2 className="text-lg font-bold text-foreground">{user?.name}</h2>
            <Badge className="mt-1 bg-primary/10 text-primary border-primary/20">
              {user?.subject} Teacher
            </Badge>
            <p className="text-xs text-muted-foreground mt-2">{formData.qualifications}</p>
          </div>

          <div className="flex justify-center mb-4">
            <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
              <DialogTrigger asChild>
                <Button size="sm" className="h-9 text-xs bg-primary">
                  <Edit2 className="w-3.5 h-3.5 mr-1.5" />
                  Edit Profile
                </Button>
              </DialogTrigger>
              <DialogContent className="w-[380px] max-h-[800px] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle className="text-base">Edit Profile</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 py-3">
                  {/* Personal Information */}
                  <div className="space-y-3">
                    <h3 className="text-sm font-semibold text-foreground">Personal Information</h3>
                    
                    <div className="space-y-2">
                      <Label htmlFor="name" className="text-xs font-medium">Full Name</Label>
                      <Input
                        id="name"
                        value={formData.name}
                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="email" className="text-xs font-medium">Email</Label>
                      <Input
                        id="email"
                        type="email"
                        value={formData.email}
                        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="phone" className="text-xs font-medium">Phone</Label>
                      <Input
                        id="phone"
                        value={formData.phone}
                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="address" className="text-xs font-medium">Address</Label>
                      <Input
                        id="address"
                        value={formData.address}
                        onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>
                  </div>

                  {/* Professional Information */}
                  <div className="space-y-3 pt-3 border-t border-primary/10">
                    <h3 className="text-sm font-semibold text-foreground">Professional Information</h3>
                    
                    <div className="space-y-2">
                      <Label htmlFor="department" className="text-xs font-medium">Department</Label>
                      <Input
                        id="department"
                        value={formData.department}
                        onChange={(e) => setFormData({ ...formData, department: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="qualifications" className="text-xs font-medium">Qualifications</Label>
                      <Input
                        id="qualifications"
                        value={formData.qualifications}
                        onChange={(e) => setFormData({ ...formData, qualifications: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="officeHours" className="text-xs font-medium">Office Hours</Label>
                      <Input
                        id="officeHours"
                        value={formData.officeHours}
                        onChange={(e) => setFormData({ ...formData, officeHours: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="bio" className="text-xs font-medium">Bio</Label>
                      <Textarea
                        id="bio"
                        value={formData.bio}
                        onChange={(e) => setFormData({ ...formData, bio: e.target.value })}
                        className="min-h-[80px] text-sm border-primary/20"
                      />
                    </div>
                  </div>
                </div>
                <DialogFooter>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setIsEditDialogOpen(false)}
                    className="h-9 text-xs"
                  >
                    Cancel
                  </Button>
                  <Button
                    size="sm"
                    onClick={handleSaveProfile}
                    className="h-9 text-xs bg-primary"
                  >
                    Save Changes
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>

          {/* Contact Information */}
          <div className="space-y-2 pt-4 border-t border-primary/10">
            <div className="flex items-center gap-3 text-sm">
              <Mail className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">{user?.email}</span>
            </div>
            <div className="flex items-center gap-3 text-sm">
              <Phone className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">{formData.phone}</span>
            </div>
            <div className="flex items-center gap-3 text-sm">
              <MapPin className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">{formData.address}</span>
            </div>
            <div className="flex items-center gap-3 text-sm">
              <Clock className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">{formData.officeHours}</span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Bio */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <User className="w-4 h-4 text-primary" />
            About Me
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground leading-relaxed">
            {formData.bio}
          </p>
        </CardContent>
      </Card>

      {/* Teaching Statistics */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <Award className="w-4 h-4 text-primary" />
            Teaching Overview
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-primary/5 p-3 rounded-lg border border-primary/20">
              <div className="flex items-center gap-2 mb-1">
                <BookOpen className="w-4 h-4 text-primary" />
                <span className="text-xs text-muted-foreground">Classes</span>
              </div>
              <p className="text-2xl font-bold text-foreground">{teacherClasses.length}</p>
            </div>

            <div className="bg-secondary/5 p-3 rounded-lg border border-secondary/20">
              <div className="flex items-center gap-2 mb-1">
                <Users className="w-4 h-4 text-secondary" />
                <span className="text-xs text-muted-foreground">Students</span>
              </div>
              <p className="text-2xl font-bold text-foreground">{totalStudents}</p>
            </div>

            <div className="bg-accent/5 p-3 rounded-lg border border-accent/20">
              <div className="flex items-center gap-2 mb-1">
                <FileText className="w-4 h-4 text-accent" />
                <span className="text-xs text-muted-foreground">Assignments</span>
              </div>
              <p className="text-2xl font-bold text-foreground">{teacherAssignments.length}</p>
            </div>

            <div className="bg-primary/5 p-3 rounded-lg border border-primary/20">
              <div className="flex items-center gap-2 mb-1">
                <Clock className="w-4 h-4 text-primary" />
                <span className="text-xs text-muted-foreground">To Grade</span>
              </div>
              <p className="text-2xl font-bold text-foreground">{pendingSubmissions}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Department Info */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <GraduationCap className="w-4 h-4 text-primary" />
            Department Information
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-sm text-muted-foreground">Department:</span>
            <span className="text-sm font-medium text-foreground">{formData.department}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-muted-foreground">Subject:</span>
            <span className="text-sm font-medium text-foreground">{user?.subject}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-muted-foreground">Office Hours:</span>
            <span className="text-sm font-medium text-foreground">{formData.officeHours}</span>
          </div>
        </CardContent>
      </Card>

      {/* Current Classes */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <BookOpen className="w-4 h-4 text-primary" />
            Teaching Classes
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          {teacherClasses.length === 0 ? (
            <p className="text-sm text-muted-foreground text-center py-4">
              No classes assigned
            </p>
          ) : (
            teacherClasses.map((cls) => (
              <div
                key={cls.id}
                className="flex items-center justify-between p-2 rounded-lg bg-primary/5 border border-primary/10"
              >
                <div className="flex items-center gap-2">
                  <div className="w-2 h-2 rounded-full bg-primary" />
                  <span className="text-sm font-medium text-foreground">{cls.name}</span>
                </div>
                <Badge className="text-[10px] bg-white text-primary border-primary/20">
                  {cls.students} students
                </Badge>
              </div>
            ))
          )}
        </CardContent>
      </Card>

      {/* Language Selector */}
      <LanguageSelectorDropdown />

      {/* Achievements */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-secondary" />
            Achievements & Recognition
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div className="flex items-start gap-3 p-2 rounded-lg bg-secondary/5 border border-secondary/10">
            <Award className="w-5 h-5 text-secondary mt-0.5" />
            <div>
              <p className="text-sm font-medium text-foreground">Excellence in Teaching Award</p>
              <p className="text-xs text-muted-foreground">Academic Year 2024-2025</p>
            </div>
          </div>
          <div className="flex items-start gap-3 p-2 rounded-lg bg-accent/5 border border-accent/10">
            <Award className="w-5 h-5 text-accent mt-0.5" />
            <div>
              <p className="text-sm font-medium text-foreground">Best Department Contributor</p>
              <p className="text-xs text-muted-foreground">Mathematics Department</p>
            </div>
          </div>
          <div className="flex items-start gap-3 p-2 rounded-lg bg-primary/5 border border-primary/10">
            <Award className="w-5 h-5 text-primary mt-0.5" />
            <div>
              <p className="text-sm font-medium text-foreground">10 Years of Service</p>
              <p className="text-xs text-muted-foreground">Nouadhibou High School</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Schedule */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <Calendar className="w-4 h-4 text-primary" />
            Weekly Schedule
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          {teacherClasses.map((cls) => (
            <div
              key={cls.id}
              className="p-2 rounded-lg bg-primary/5 border border-primary/10"
            >
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm font-medium text-foreground">{cls.name}</span>
                <Badge className="text-[10px] bg-white text-primary border-primary/20">
                  {cls.room}
                </Badge>
              </div>
              <p className="text-xs text-muted-foreground">{cls.schedule}</p>
            </div>
          ))}
        </CardContent>
      </Card>
    </div>
  );
}