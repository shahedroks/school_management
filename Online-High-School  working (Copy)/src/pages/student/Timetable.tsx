import React from 'react';
import { Link } from 'react-router-dom';
import { useLanguage } from '@/contexts/LanguageContext';
import { mockTimetable } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Calendar, Clock, User } from 'lucide-react';

export function Timetable() {
  const { t } = useLanguage();
  
  const days = [
    t('timetable.monday'),
    t('timetable.tuesday'),
    t('timetable.wednesday'),
    t('timetable.thursday'),
    t('timetable.friday')
  ];
  
  const dayMap: { [key: string]: string } = {
    [t('timetable.monday')]: 'Monday',
    [t('timetable.tuesday')]: 'Tuesday',
    [t('timetable.wednesday')]: 'Wednesday',
    [t('timetable.thursday')]: 'Thursday',
    [t('timetable.friday')]: 'Friday'
  };

  const getEntriesForDay = (translatedDay: string) => {
    const englishDay = dayMap[translatedDay];
    return mockTimetable
      .filter(entry => entry.day === englishDay)
      .sort((a, b) => a.time.localeCompare(b.time));
  };

  return (
    <div className="space-y-4">
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <h1 className="text-xl font-bold">{t('timetable.mySchedule')}</h1>
        <p className="text-sm text-white/90 mt-0.5">{t('timetable.weeklySchedule')}</p>
      </div>

      <div className="space-y-3">
        {days.map(day => {
          const entries = getEntriesForDay(day);
          const todayEnglish = new Date().toLocaleDateString('en-US', { weekday: 'long' });
          const isToday = dayMap[day] === todayEnglish;

          return (
            <Card
              key={day}
              className={isToday ? 'border-2 border-secondary shadow-md' : 'border-2 border-primary/20'}
            >
              <CardHeader className="pb-2 bg-primary/5">
                <CardTitle className="text-base flex items-center justify-between text-foreground">
                  {day}
                  {isToday && (
                    <Badge className="bg-secondary text-[10px] px-2 py-0">Today</Badge>
                  )}
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2 pt-2">
                {entries.length === 0 ? (
                  <p className="text-xs text-muted-foreground text-center py-6">
                    {t('timetable.noClassesToday')}
                  </p>
                ) : (
                  entries.map(entry => (
                    <Link
                      key={entry.id}
                      to={`/student/classes/${entry.classId}`}
                      className="block p-2.5 rounded-lg border-2 border-primary/20 hover:border-primary hover:shadow-sm transition-all bg-card"
                    >
                      <div className="space-y-1.5">
                        <div className="flex items-start gap-2">
                          <Clock className="w-3.5 h-3.5 text-primary mt-0.5 flex-shrink-0" />
                          <div className="flex-1 min-w-0">
                            <p className="text-xs font-medium text-foreground truncate">
                              {entry.className}
                            </p>
                            <p className="text-[11px] text-muted-foreground">{entry.time}</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-2 text-[11px] text-muted-foreground">
                          <User className="w-3 h-3" />
                          <span className="truncate">{entry.teacher}</span>
                        </div>
                      </div>
                    </Link>
                  ))
                )}
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}