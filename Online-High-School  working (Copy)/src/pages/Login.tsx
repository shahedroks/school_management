import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { useLanguage } from '@/contexts/LanguageContext';
import { LanguageSelectorDropdown } from '@/components/LanguageSelectorDropdown';
import { GraduationCap, LogIn } from 'lucide-react';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Label } from '@/app/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Alert, AlertDescription } from '@/app/components/ui/alert';

export function Login() {
  const [phone, setPhone] = useState('');
  const [pin, setPin] = useState('');
  const [error, setError] = useState('');
  const { login } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();

  // Check if language has been selected
  React.useEffect(() => {
    const languageSelected = localStorage.getItem('languageSelected');
    if (!languageSelected) {
      navigate('/language', { replace: true });
    }
  }, [navigate]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // Validate that phone is provided
    if (!phone) {
      setError(t('Please provide a phone number'));
      return;
    }

    // Check if it's a pending teacher account
    const registeredUsers = JSON.parse(localStorage.getItem('registeredUsers') || '[]');
    const user = registeredUsers.find((u: any) => u.phone === phone);
    
    if (user && user.role === 'teacher' && user.status === 'pending') {
      setError(t('Your teacher account is pending admin approval. Please wait for confirmation.'));
      return;
    }

    const success = login(phone, pin);
    if (success) {
      // Redirect based on user role (will be handled by the router)
      navigate('/');
    } else {
      setError(t('Invalid credentials or account not approved yet.'));
    }
  };

  return (
    <div className="h-full bg-background flex items-center justify-center p-6">
      <Card className="w-full shadow-lg">
        <CardHeader className="space-y-3 text-center pb-4 bg-primary text-primary-foreground rounded-t-lg">
          <div className="flex justify-center">
            <div className="bg-white/20 p-3 rounded-full backdrop-blur-sm">
              <GraduationCap className="w-8 h-8 text-white" />
            </div>
          </div>
          <div>
            <CardTitle className="text-xl text-white">Nouadhibou High School</CardTitle>
            <CardDescription className="mt-1 text-sm text-white/90">
              {t('auth.loginSubtitle')}
            </CardDescription>
          </div>
        </CardHeader>
        <CardContent className="pt-6">
          <form onSubmit={handleSubmit} className="space-y-4">
            {error && (
              <Alert variant="destructive">
                <AlertDescription className="text-xs">{error}</AlertDescription>
              </Alert>
            )}

            {/* Language Selector */}
            <div className="space-y-2">
              <Label className="text-sm text-foreground">{t('auth.selectLanguage')}</Label>
              <LanguageSelectorDropdown />
            </div>

            <div className="space-y-2">
              <Label htmlFor="phone" className="text-sm text-foreground">{t('auth.phoneNumber')}</Label>
              <Input
                id="phone"
                type="tel"
                placeholder="XX XX XX XX"
                value={phone}
                onChange={e => setPhone(e.target.value)}
                className="h-11 border-border"
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="pin" className="text-sm text-foreground">{t('auth.pin')}</Label>
              <Input
                id="pin"
                type="password"
                placeholder={t('auth.pin')}
                value={pin}
                onChange={e => setPin(e.target.value)}
                required
                className="h-11 border-border"
              />
            </div>

            <Button type="submit" className="w-full h-11 bg-primary hover:bg-primary/90">
              <LogIn className="w-4 h-4 mr-2" />
              {t('auth.loginButton')}
            </Button>
          </form>

          <div className="mt-4 text-center">
            <p className="text-xs text-muted-foreground">
              {t('auth.noAccount')}{' '}
              <Link to="/register" className="text-primary font-medium hover:underline">
                {t('auth.register')}
              </Link>
            </p>
          </div>

          <div className="mt-6 pt-6 border-t border-border">
            <p className="text-xs text-muted-foreground text-center mb-3">Demo Accounts:</p>
            <div className="space-y-2">
              <div className="bg-muted p-2.5 rounded-lg border border-border">
                <p className="text-xs font-medium text-foreground">{t('auth.student')} Account</p>
                <p className="text-[11px] text-muted-foreground">Phone: 12345678</p>
                <p className="text-[11px] text-muted-foreground">PIN: 1234</p>
              </div>
              <div className="bg-muted p-2.5 rounded-lg border border-border">
                <p className="text-xs font-medium text-foreground">{t('auth.teacher')} Account</p>
                <p className="text-[11px] text-muted-foreground">Phone: 98765432</p>
                <p className="text-[11px] text-muted-foreground">PIN: 5678</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}