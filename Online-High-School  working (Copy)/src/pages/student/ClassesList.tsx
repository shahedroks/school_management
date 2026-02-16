import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { useLanguage } from '@/contexts/LanguageContext';
import { useSubscription } from '@/contexts/SubscriptionContext';
import { mockClasses } from '@/data/mockData';
import { Card, CardContent } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { BookOpen, Users, ChevronRight, Crown, Lock } from 'lucide-react';

export function ClassesList() {
  const { user } = useAuth();
  const { t } = useLanguage();
  const { subscription } = useSubscription();
  
  // Get user's subscription
  const userSubscription = subscription;
  
  // Filter classes based on subscription
  const enrolledClasses = userSubscription
    ? mockClasses.filter(cls => userSubscription.enrolledClassIds.includes(cls.id))
    : [];
  
  // Group classes by subject
  const groupedClasses = enrolledClasses.reduce((acc, cls) => {
    if (!acc[cls.subject]) {
      acc[cls.subject] = [];
    }
    acc[cls.subject].push(cls);
    return acc;
  }, {} as Record<string, typeof mockClasses>);
  
  return (
    <div className="space-y-4 pb-4">
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <h1 className="text-xl font-bold">{t('classes.myClasses')}</h1>
        <p className="text-sm text-white/90 mt-0.5">
          {t('classes.enrolledClasses')}
        </p>
      </div>

      {!userSubscription || enrolledClasses.length === 0 ? (
        <Card className="border-2 border-accent/40 shadow-sm">
          <CardContent className="p-8 text-center">
            <div className="w-16 h-16 mx-auto mb-4 bg-accent/10 rounded-full flex items-center justify-center">
              <Lock className="w-8 h-8 text-accent" />
            </div>
            <h3 className="text-base font-semibold text-foreground mb-2">
              No Classes Enrolled
            </h3>
            <p className="text-sm text-muted-foreground mb-4">
              Subscribe to a plan to access classes and start learning
            </p>
            <Link to="/student/subscription">
              <Button className="h-10 text-sm font-semibold bg-accent hover:bg-accent/90">
                <Crown className="w-4 h-4 mr-1.5" />
                View Subscription Plans
              </Button>
            </Link>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {Object.entries(groupedClasses).map(([subject, classes]) => {
            // Get unique info from first class of the subject
            const firstClass = classes[0];
            const allGrades = classes.map(c => c.level);
            const totalStudents = classes.reduce((sum, c) => sum + c.students, 0);
            
            return (
              <Card key={subject} className="overflow-hidden hover:shadow-md transition-shadow border-2 border-primary/20">
                <div
                  className="h-20 bg-gradient-to-br relative"
                  style={{
                    background: `linear-gradient(135deg, #1F3C88, #1F3C88dd)`,
                  }}
                >
                  <div className="relative p-3 h-full flex flex-col justify-end">
                    <h2 className="text-base font-bold text-white">{subject}</h2>
                  </div>
                </div>
                <CardContent className="p-3 space-y-3">
                  <div className="space-y-2">
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <BookOpen className="w-3.5 h-3.5 text-primary" />
                      <span>{firstClass.teacher}</span>
                    </div>
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                      <Users className="w-3.5 h-3.5 text-primary" />
                      <span>{totalStudents} {t('classes.students')}</span>
                    </div>
                  </div>

                  <div className="flex items-center gap-2 flex-wrap">
                    {allGrades.map((grade, index) => (
                      <Badge 
                        key={index} 
                        variant="secondary" 
                        className="text-[10px] bg-primary/10 text-primary border-primary/20"
                      >
                        {grade}
                      </Badge>
                    ))}
                  </div>

                  <Link to={`/student/classes/${firstClass.id}`}>
                    <Button className="w-full h-9 text-xs bg-primary hover:bg-primary/90" variant="default">
                      {t('classes.viewClass')}
                      <ChevronRight className="w-3.5 h-3.5 ml-1" />
                    </Button>
                  </Link>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}