import React, { useState } from 'react';
import { useLanguage } from '@/contexts/LanguageContext';
import { Globe, Check } from 'lucide-react';

export function LanguageSelector() {
  const { language, setLanguage, t } = useLanguage();
  const [showSuccess, setShowSuccess] = useState(false);

  const languages = [
    { code: 'en' as const, name: 'English', nativeName: 'English' },
    { code: 'fr' as const, name: 'French', nativeName: 'Français' },
    { code: 'ar' as const, name: 'Arabic', nativeName: 'العربية' },
  ];

  const handleLanguageChange = (langCode: 'en' | 'fr' | 'ar') => {
    setLanguage(langCode);
    setShowSuccess(true);
    setTimeout(() => setShowSuccess(false), 2000);
  };

  return (
    <div className="bg-white rounded-2xl border-2 border-[#1F3C88] p-5 mb-4">
      <div className="flex items-center gap-2 mb-4">
        <Globe className="w-5 h-5 text-[#1F3C88]" />
        <h3 className="font-semibold text-[#1C1C1C]">{t('profile.languagePreference')}</h3>
      </div>
      
      <p className="text-sm text-[#6B7280] mb-4">{t('profile.chooseLanguage')}</p>
      
      <div className="space-y-2 mb-4">
        {languages.map((lang) => (
          <button
            key={lang.code}
            onClick={() => handleLanguageChange(lang.code)}
            className={`w-full flex items-center justify-between p-3 rounded-lg border-2 transition-all ${
              language === lang.code
                ? 'border-[#1F3C88] bg-[#1F3C88]/5'
                : 'border-gray-200 hover:border-[#1F3C88]/50'
            }`}
          >
            <div className="text-left">
              <div className="font-medium text-[#1C1C1C]">{lang.name}</div>
              <div className="text-sm text-[#6B7280]">{lang.nativeName}</div>
            </div>
            {language === lang.code && (
              <Check className="w-5 h-5 text-[#1F3C88]" />
            )}
          </button>
        ))}
      </div>

      {showSuccess && (
        <div className="bg-[#2E7D32] text-white px-4 py-2 rounded-lg text-sm text-center animate-fade-in">
          {t('profile.changesSaved')}
        </div>
      )}
    </div>
  );
}
