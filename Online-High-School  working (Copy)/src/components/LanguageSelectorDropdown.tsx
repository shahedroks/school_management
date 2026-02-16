import React, { useState, useRef, useEffect } from 'react';
import { useLanguage } from '@/contexts/LanguageContext';
import { Globe, Check, ChevronDown } from 'lucide-react';

export function LanguageSelectorDropdown() {
  const { language, setLanguage } = useLanguage();
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const languages = [
    { code: 'en' as const, name: 'English', nativeName: 'English' },
    { code: 'fr' as const, name: 'French', nativeName: 'Français' },
    { code: 'ar' as const, name: 'Arabic', nativeName: 'العربية' },
  ];

  const currentLanguage = languages.find((lang) => lang.code === language);

  const handleLanguageChange = (langCode: 'en' | 'fr' | 'ar') => {
    setLanguage(langCode);
    setIsOpen(false);
  };

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div ref={dropdownRef} className="relative w-full">
      {/* Dropdown Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between p-3.5 rounded-xl border-2 border-primary/20 bg-white hover:border-primary/40 transition-all shadow-sm hover:shadow-md"
      >
        <div className="flex items-center gap-3">
          <div className="bg-primary/10 p-2 rounded-lg">
            <Globe className="w-4 h-4 text-primary" />
          </div>
          <div className="text-left">
            <div className="text-sm font-semibold text-foreground">
              {currentLanguage?.name}
            </div>
            <div className="text-xs text-muted-foreground">
              {currentLanguage?.nativeName}
            </div>
          </div>
        </div>
        <ChevronDown
          className={`w-5 h-5 text-primary transition-transform duration-200 ${
            isOpen ? 'rotate-180' : ''
          }`}
        />
      </button>

      {/* Dropdown Menu */}
      {isOpen && (
        <div className="absolute top-full left-0 right-0 mt-2 bg-white border-2 border-primary/20 rounded-xl shadow-lg overflow-hidden z-50 animate-in fade-in slide-in-from-top-2 duration-200">
          {languages.map((lang, index) => (
            <button
              key={lang.code}
              onClick={() => handleLanguageChange(lang.code)}
              className={`w-full flex items-center justify-between p-3.5 transition-all ${
                language === lang.code
                  ? 'bg-primary/10 border-l-4 border-l-primary'
                  : 'hover:bg-primary/5 border-l-4 border-l-transparent'
              } ${index !== 0 ? 'border-t border-gray-100' : ''}`}
            >
              <div className="text-left">
                <div className="text-sm font-medium text-foreground">
                  {lang.name}
                </div>
                <div className="text-xs text-muted-foreground">
                  {lang.nativeName}
                </div>
              </div>
              {language === lang.code && (
                <Check className="w-5 h-5 text-primary" />
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
