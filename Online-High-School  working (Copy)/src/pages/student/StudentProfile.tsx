import React, { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { useLanguage } from '@/contexts/LanguageContext';
import { mockClasses, mockAssignments } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
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
  Calendar,
  Edit2,
  Phone,
  MapPin,
  CheckCircle,
} from 'lucide-react';

export function StudentProfile() {
  const { user } = useAuth();
  const { t } = useLanguage();
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [formData, setFormData] = useState({
    name: user?.name || '',
    email: user?.email || '',
    phone: '+222 45 67 89 01',
    address: 'Nouadhibou, Mauritania',
    parentName: 'Ahmed Hassan',
    parentPhone: '+222 45 67 89 02',
    parentEmail: 'ahmed.hassan@email.mr',
  });

  const enrolledClasses = mockClasses.slice(0, 4);
  const studentAssignments = mockAssignments;
  const completedAssignments = studentAssignments.filter(a => a.status === 'graded' || a.status === 'submitted').length;
  const averageGrade = 87; // Mock average

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
        <h1 className="text-xl font-bold">{t('profile.myProfile')}</h1>
        <p className="text-sm text-white/90 mt-0.5">
          {t('profile.managePersonalInfo')}
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
              {user?.grade}
            </Badge>
          </div>

          <div className="flex justify-center mb-4">
            <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
              <DialogTrigger asChild>
                <Button size="sm" className="h-9 text-xs bg-primary">
                  <Edit2 className="w-3.5 h-3.5 mr-1.5" />
                  {t('common.editProfile')}
                </Button>
              </DialogTrigger>
              <DialogContent className="w-[380px] max-h-[800px] overflow-y-auto">
                <DialogHeader>
                  <DialogTitle className="text-base">{t('common.editProfile')}</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 py-3">
                  {/* Personal Information */}
                  <div className="space-y-3">
                    <h3 className="text-sm font-semibold text-foreground">{t('profile.personalInfo')}</h3>
                    
                    <div className="space-y-2">
                      <Label htmlFor="name" className="text-xs font-medium">{t('profile.fullName')}</Label>
                      <Input
                        id="name"
                        value={formData.name}
                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="email" className="text-xs font-medium">{t('profile.email')}</Label>
                      <Input
                        id="email"
                        type="email"
                        value={formData.email}
                        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="phone" className="text-xs font-medium">{t('profile.phone')}</Label>
                      <Input
                        id="phone"
                        value={formData.phone}
                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="address" className="text-xs font-medium">{t('profile.address')}</Label>
                      <Input
                        id="address"
                        value={formData.address}
                        onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>
                  </div>

                  {/* Parent/Guardian Information */}
                  <div className="space-y-3 pt-3 border-t border-primary/10">
                    <h3 className="text-sm font-semibold text-foreground">{t('profile.parentInfo')}</h3>
                    
                    <div className="space-y-2">
                      <Label htmlFor="parentName" className="text-xs font-medium">{t('profile.parentName')}</Label>
                      <Input
                        id="parentName"
                        value={formData.parentName}
                        onChange={(e) => setFormData({ ...formData, parentName: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="parentPhone" className="text-xs font-medium">{t('profile.parentPhone')}</Label>
                      <Input
                        id="parentPhone"
                        value={formData.parentPhone}
                        onChange={(e) => setFormData({ ...formData, parentPhone: e.target.value })}
                        className="h-9 text-sm border-primary/20"
                      />
                    </div>

                    <div className="space-y-2">
                      <Label htmlFor="parentEmail" className="text-xs font-medium">{t('profile.parentEmail')}</Label>
                      <Input
                        id="parentEmail"
                        type="email"
                        value={formData.parentEmail}
                        onChange={(e) => setFormData({ ...formData, parentEmail: e.target.value })}
                        className="h-9 text-sm border-primary/20"
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
                    {t('common.cancel')}
                  </Button>
                  <Button
                    size="sm"
                    onClick={handleSaveProfile}
                    className="h-9 text-xs bg-primary"
                  >
                    {t('common.saveChanges')}
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
          </div>
        </CardContent>
      </Card>

      {/* Academic Statistics */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <Award className="w-4 h-4 text-primary" />
            Academic Overview
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-primary/5 p-3 rounded-lg border border-primary/20">
              <div className="flex items-center gap-2 mb-1">
                <BookOpen className="w-4 h-4 text-primary" />
                <span className="text-xs text-muted-foreground">Enrolled Classes</span>
              </div>
              <p className="text-2xl font-bold text-foreground">{enrolledClasses.length}</p>
            </div>

            <div className="bg-secondary/5 p-3 rounded-lg border border-secondary/20">
              <div className="flex items-center gap-2 mb-1">
                <FileText className="w-4 h-4 text-secondary" />
                <span className="text-xs text-muted-foreground">Assignments</span>
              </div>
              <p className="text-2xl font-bold text-foreground">{completedAssignments}/{studentAssignments.length}</p>
            </div>

            <div className="bg-accent/5 p-3 rounded-lg border border-accent/20">
              <div className="flex items-center gap-2 mb-1">
                <Award className="w-4 h-4 text-accent" />
                <span className="text-xs text-muted-foreground">Average Grade</span>
              </div>
              <p className="text-2xl font-bold text-foreground">{averageGrade}%</p>
            </div>

            <div className="bg-primary/5 p-3 rounded-lg border border-primary/20">
              <div className="flex items-center gap-2 mb-1">
                <Calendar className="w-4 h-4 text-primary" />
                <span className="text-xs text-muted-foreground">Attendance</span>
              </div>
              <p className="text-2xl font-bold text-foreground">94%</p>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Parent/Guardian Contact */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <User className="w-4 h-4 text-primary" />
            Parent/Guardian Contact
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-sm text-muted-foreground">Name:</span>
            <span className="text-sm font-medium text-foreground">{formData.parentName}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-muted-foreground">Phone:</span>
            <span className="text-sm font-medium text-foreground">{formData.parentPhone}</span>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-sm text-muted-foreground">Email:</span>
            <span className="text-sm font-medium text-foreground truncate ml-2">{formData.parentEmail}</span>
          </div>
        </CardContent>
      </Card>

      {/* Current Classes */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <BookOpen className="w-4 h-4 text-primary" />
            Current Classes
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          {enrolledClasses.map((cls) => (
            <div
              key={cls.id}
              className="flex items-center justify-between p-2 rounded-lg bg-primary/5 border border-primary/10"
            >
              <div className="flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-primary" />
                <span className="text-sm font-medium text-foreground">{cls.name}</span>
              </div>
              <Badge className="text-[10px] bg-white text-primary border-primary/20">
                {cls.teacher}
              </Badge>
            </div>
          ))}
        </CardContent>
      </Card>

      {/* Language Preference */}
      <LanguageSelectorDropdown />

      {/* Recent Achievements */}
      <Card className="border-2 border-primary/20">
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-secondary" />
            Recent Achievements
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-2">
          <div className="flex items-start gap-3 p-2 rounded-lg bg-secondary/5 border border-secondary/10">
            <Award className="w-5 h-5 text-secondary mt-0.5" />
            <div>
              <p className="text-sm font-medium text-foreground">Perfect Attendance</p>
              <p className="text-xs text-muted-foreground">December 2025</p>
            </div>
          </div>
          <div className="flex items-start gap-3 p-2 rounded-lg bg-accent/5 border border-accent/10">
            <Award className="w-5 h-5 text-accent mt-0.5" />
            <div>
              <p className="text-sm font-medium text-foreground">Top Grade in Mathematics</p>
              <p className="text-xs text-muted-foreground">Final Exam - 95%</p>
            </div>
          </div>
          <div className="flex items-start gap-3 p-2 rounded-lg bg-primary/5 border border-primary/10">
            <Award className="w-5 h-5 text-primary mt-0.5" />
            <div>
              <p className="text-sm font-medium text-foreground">Outstanding Project</p>
              <p className="text-xs text-muted-foreground">Science Fair Winner</p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}