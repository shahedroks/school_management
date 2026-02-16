import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '@/contexts/LanguageContext';
import { Globe, GraduationCap, ArrowRight, Check } from 'lucide-react';
import { Card, CardContent } from '@/app/components/ui/card';

export function LanguageSelection() {
  const { language, setLanguage } = useLanguage();
  const navigate = useNavigate();

  const languages = [
    { 
      code: 'en' as const, 
      name: 'English', 
      nativeName: 'English',
      flag: '🇬🇧'
    },
    { 
      code: 'fr' as const, 
      name: 'French', 
      nativeName: 'Français',
      flag: '🇫🇷'
    },
    { 
      code: 'ar' as const, 
      name: 'Arabic', 
      nativeName: 'العربية',
      flag: '🇸🇦'
    },
  ];

  const handleLanguageSelect = (langCode: 'en' | 'fr' | 'ar') => {
    setLanguage(langCode);
    // Store that user has completed language selection
    localStorage.setItem('languageSelected', 'true');
    // Redirect to login after a brief delay
    setTimeout(() => {
      navigate('/login');
    }, 300);
  };

  return (
    <div className="h-full bg-gradient-to-br from-primary/5 via-background to-secondary/5 flex flex-col items-center justify-center p-6">
      <div className="w-full max-w-md space-y-6">
        {/* Logo and Welcome */}
        <div className="text-center space-y-4 mb-8">
          <div className="flex justify-center">
            <div className="bg-primary p-5 rounded-full shadow-lg">
              <GraduationCap className="w-12 h-12 text-white" />
            </div>
          </div>
          <div>
            <h1 className="text-2xl font-bold text-foreground mb-2">
              Nouadhibou High School
            </h1>
            <p className="text-sm text-muted-foreground">
              Online Learning Platform
            </p>
          </div>
        </div>

        {/* Language Selection Card */}
        <Card className="shadow-xl border-2 border-primary/20">
          <CardContent className="p-6">
            <div className="flex items-center justify-center gap-3 mb-6">
              <div className="bg-primary/10 p-2.5 rounded-lg">
                <Globe className="w-6 h-6 text-primary" />
              </div>
              <h2 className="text-lg font-bold text-foreground">
                Choose Your Language
              </h2>
            </div>

            <p className="text-sm text-muted-foreground text-center mb-6">
              Select your preferred language to continue
            </p>

            <div className="space-y-3">
              {languages.map((lang) => (
                <button
                  key={lang.code}
                  onClick={() => handleLanguageSelect(lang.code)}
                  className={`w-full flex items-center justify-between p-4 rounded-xl border-2 transition-all duration-200 ${
                    language === lang.code
                      ? 'border-primary bg-primary/10 shadow-md scale-[1.02]'
                      : 'border-gray-200 hover:border-primary/50 hover:bg-primary/5 hover:shadow-sm'
                  }`}
                >
                  <div className="flex items-center gap-4">
                    <span className="text-3xl">{lang.flag}</span>
                    <div className="text-left">
                      <div className="text-base font-semibold text-foreground">
                        {lang.name}
                      </div>
                      <div className="text-sm text-muted-foreground">
                        {lang.nativeName}
                      </div>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {language === lang.code && (
                      <Check className="w-5 h-5 text-primary" />
                    )}
                    <ArrowRight className="w-5 h-5 text-primary" />
                  </div>
                </button>
              ))}
            </div>

            <div className="mt-6 pt-6 border-t border-gray-200">
              <p className="text-xs text-muted-foreground text-center">
                You can change your language preference anytime from your profile
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Footer */}
        <div className="text-center">
          <p className="text-xs text-muted-foreground">
            © 2026 Nouadhibou High School. All rights reserved.
          </p>
        </div>
      </div>
    </div>
  );
}
