import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useLanguage } from '@/contexts/LanguageContext';
import { GraduationCap, UserPlus, AlertCircle, CheckCircle } from 'lucide-react';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Alert, AlertDescription } from '@/app/components/ui/alert';
import { RadioGroup, RadioGroupItem } from '@/app/components/ui/radio-group';

export function Register() {
  const { t } = useLanguage();
  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    pin: '',
    confirmPin: '',
    role: 'student' as 'student' | 'teacher',
    grade: '',
    subject: '',
  });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState(false);
  const navigate = useNavigate();

  // Check if language has been selected
  useEffect(() => {
    const languageSelected = localStorage.getItem('languageSelected');
    if (!languageSelected) {
      navigate('/language', { replace: true });
    }
  }, [navigate]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // Validate that phone is provided
    if (!formData.phone) {
      setError('Please provide your phone number');
      return;
    }

    // Validation
    if (formData.pin !== formData.confirmPin) {
      setError('PINs do not match');
      return;
    }

    if (!/^\d{4}$/.test(formData.pin)) {
      setError('PIN must be exactly 4 digits');
      return;
    }

    if (formData.role === 'student' && !formData.grade) {
      setError('Please select your grade');
      return;
    }

    if (formData.role === 'teacher' && !formData.subject) {
      setError('Please enter your subject');
      return;
    }

    // Get existing users from localStorage
    const existingUsers = JSON.parse(localStorage.getItem('registeredUsers') || '[]');

    // Check if phone already exists
    const phoneExists = existingUsers.some((u: any) => u.phone === formData.phone);
    
    if (phoneExists) {
      setError('Phone number already registered');
      return;
    }

    // Create new user
    const newUser = {
      id: `user_${Date.now()}`,
      name: formData.name,
      email: `${formData.phone}@school.mr`, // Generate email from phone
      phone: formData.phone,
      password: formData.pin,
      role: formData.role,
      grade: formData.role === 'student' ? formData.grade : undefined,
      subject: formData.role === 'teacher' ? formData.subject : undefined,
      status: formData.role === 'teacher' ? 'pending' : 'approved',
      createdAt: new Date().toISOString(),
    };

    // Save to localStorage
    existingUsers.push(newUser);
    localStorage.setItem('registeredUsers', JSON.stringify(existingUsers));

    setSuccess(true);

    // Redirect after 3 seconds
    setTimeout(() => {
      navigate('/login');
    }, 3000);
  };

  const handleChange = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  if (success) {
    return (
      <div className="h-full bg-background flex items-center justify-center p-6">
        <Card className="w-full shadow-lg">
          <CardHeader className="space-y-3 text-center pb-4 bg-green-600 text-white rounded-t-lg">
            <div className="flex justify-center">
              <div className="bg-white/20 p-3 rounded-full backdrop-blur-sm">
                <CheckCircle className="w-8 h-8 text-white" />
              </div>
            </div>
            <div>
              <CardTitle className="text-xl text-white">{t('auth.registrationSuccessful')}</CardTitle>
              <CardDescription className="mt-1 text-sm text-white/90">
                {formData.role === 'teacher'
                  ? t('auth.teacherAccountPending')
                  : t('auth.canSignInNow')}
              </CardDescription>
            </div>
          </CardHeader>
          <CardContent className="pt-6 space-y-4">
            {formData.role === 'teacher' ? (
              <Alert className="border-blue-200 bg-blue-50">
                <AlertCircle className="h-4 w-4 text-blue-600" />
                <AlertDescription className="text-sm text-blue-800">
                  <strong>{t('auth.important')}</strong> {t('auth.teacherApprovalMessage')}
                </AlertDescription>
              </Alert>
            ) : (
              <Alert className="border-green-200 bg-green-50">
                <CheckCircle className="h-4 w-4 text-green-600" />
                <AlertDescription className="text-sm text-green-800">
                  {t('auth.studentAccountCreated')}
                </AlertDescription>
              </Alert>
            )}

            <div className="bg-muted p-4 rounded-lg border border-border">
              <p className="text-sm font-medium text-foreground mb-2">{t('auth.accountDetails')}</p>
              <div className="space-y-1 text-xs text-muted-foreground">
                <p><strong>{t('profile.name')}:</strong> {formData.name}</p>
                <p><strong>{t('profile.phone')}:</strong> {formData.phone}</p>
                <p><strong>{t('auth.selectRole')}:</strong> {formData.role === 'student' ? t('auth.student') : t('auth.teacher')}</p>
                {formData.role === 'student' && <p><strong>{t('classes.grade')}:</strong> {formData.grade}</p>}
                {formData.role === 'teacher' && <p><strong>{t('classes.subject')}:</strong> {formData.subject}</p>}
              </div>
            </div>

            <Button onClick={() => navigate('/login')} className="w-full h-11 bg-primary hover:bg-primary/90">
              {t('auth.goToLogin')}
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="h-full bg-background flex items-center justify-center p-6">
      <Card className="w-full shadow-lg">
        <CardHeader className="space-y-1 text-center pb-6 bg-primary text-primary-foreground rounded-t-lg">
          <CardTitle className="text-lg text-white font-normal">{t('auth.createAccountTitle')}</CardTitle>
        </CardHeader>
        <CardContent className="pt-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            {error && (
              <Alert variant="destructive">
                <AlertDescription className="text-xs">{error}</AlertDescription>
              </Alert>
            )}

            {/* Role Selection */}
            <div className="space-y-3">
              <Label className="text-sm font-semibold text-primary">{t('auth.iAmA')}</Label>
              <RadioGroup
                value={formData.role}
                onValueChange={(value) => handleChange('role', value)}
                className="flex gap-6"
              >
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="student" id="student" className="border-primary text-primary" />
                  <Label htmlFor="student" className="text-sm font-normal cursor-pointer text-primary">
                    {t('auth.student')}
                  </Label>
                </div>
                <div className="flex items-center space-x-2">
                  <RadioGroupItem value="teacher" id="teacher" className="border-primary text-primary" />
                  <Label htmlFor="teacher" className="text-sm font-normal cursor-pointer text-primary">
                    {t('auth.teacher')}
                  </Label>
                </div>
              </RadioGroup>
            </div>

            {/* Name */}
            <div className="space-y-2">
              <Label htmlFor="name" className="text-sm font-semibold text-primary">{t('auth.fullName')}</Label>
              <Input
                id="name"
                type="text"
                placeholder={t('auth.enterFullName')}
                value={formData.name}
                onChange={e => handleChange('name', e.target.value)}
                required
                className="h-11 border-border"
              />
            </div>

            {/* Phone */}
            <div className="space-y-2">
              <Label htmlFor="phone" className="text-sm font-semibold text-primary">{t('auth.phoneNumber')}</Label>
              <Input
                id="phone"
                type="tel"
                placeholder={t('auth.enterPhoneNumber')}
                value={formData.phone}
                onChange={e => handleChange('phone', e.target.value)}
                className="h-11 border-border"
              />
            </div>

            {/* Grade (for students) */}
            {formData.role === 'student' && (
              <div className="space-y-2">
                <Label htmlFor="grade" className="text-sm font-semibold text-primary">{t('classes.grade')}</Label>
                <Input
                  id="grade"
                  type="text"
                  placeholder={t('auth.gradeExample')}
                  value={formData.grade}
                  onChange={e => handleChange('grade', e.target.value)}
                  required
                  className="h-11 border-border"
                />
              </div>
            )}

            {/* Subject (for teachers) */}
            {formData.role === 'teacher' && (
              <div className="space-y-2">
                <Label htmlFor="subject" className="text-sm font-semibold text-primary">{t('classes.subject')}</Label>
                <Input
                  id="subject"
                  type="text"
                  placeholder={t('auth.subjectExample')}
                  value={formData.subject}
                  onChange={e => handleChange('subject', e.target.value)}
                  required
                  className="h-11 border-border"
                />
              </div>
            )}

            {/* PIN */}
            <div className="space-y-2">
              <Label htmlFor="pin" className="text-sm font-semibold text-primary">{t('auth.pinLabel')}</Label>
              <Input
                id="pin"
                type="text"
                inputMode="numeric"
                pattern="\d{4}"
                maxLength={4}
                placeholder={t('auth.enterPin')}
                value={formData.pin}
                onChange={e => {
                  const value = e.target.value.replace(/\D/g, '');
                  handleChange('pin', value);
                }}
                required
                className="h-11 border-border"
              />
            </div>

            {/* Confirm PIN */}
            <div className="space-y-2">
              <Label htmlFor="confirmPin" className="text-sm font-semibold text-primary">{t('auth.confirmPin')}</Label>
              <Input
                id="confirmPin"
                type="text"
                inputMode="numeric"
                pattern="\d{4}"
                maxLength={4}
                placeholder={t('auth.reenterPin')}
                value={formData.confirmPin}
                onChange={e => {
                  const value = e.target.value.replace(/\D/g, '');
                  handleChange('confirmPin', value);
                }}
                required
                className="h-11 border-border"
              />
            </div>

            <Button type="submit" className="w-full h-11 bg-primary hover:bg-primary/90">
              <UserPlus className="w-4 h-4 mr-2" />
              {t('auth.createAccount')}
            </Button>
          </form>

          <div className="mt-6 pt-6 border-t border-border text-center">
            <p className="text-xs text-muted-foreground">
              {t('auth.haveAccount')}{' '}
              <Link to="/login" className="text-primary font-medium hover:underline">
                {t('auth.loginButton')}
              </Link>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}