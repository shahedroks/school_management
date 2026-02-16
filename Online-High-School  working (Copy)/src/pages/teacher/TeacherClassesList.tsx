import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useLanguage } from '@/contexts/LanguageContext';
import { mockClasses } from '@/data/mockData';
import { Card, CardContent } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/app/components/ui/select';
import { BookOpen, Users, Calendar, SlidersHorizontal, GraduationCap } from 'lucide-react';

export function TeacherClassesList() {
  const { t } = useLanguage();
  const [gradeFilter, setGradeFilter] = useState<string>('all');
  const [showFilters, setShowFilters] = useState<boolean>(false);

  // Filter to show only classes taught by Mohammed Ould (teacher1)
  const myClasses = mockClasses.filter(cls => cls.teacherId === 'teacher1');

  // Get unique values for filter options
  const grades = Array.from(new Set(myClasses.map(c => c.level))).sort();

  // Apply filters
  const filteredClasses = myClasses.filter(cls => {
    if (gradeFilter !== 'all' && cls.level !== gradeFilter) return false;
    return true;
  });

  const handleResetFilters = () => {
    setGradeFilter('all');
  };

  const hasActiveFilters = gradeFilter !== 'all';

  return (
    <div className="space-y-4 pb-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <div className="flex items-start justify-between">
          <div className="flex-1">
            <h1 className="text-xl font-bold">My Classes</h1>
            <p className="text-sm text-white/90 mt-0.5">
              {filteredClasses.length} {filteredClasses.length === 1 ? 'class' : 'classes'} assigned to you
            </p>
          </div>
          <Button
            onClick={() => setShowFilters(!showFilters)}
            variant="ghost"
            size="sm"
            className="h-9 w-9 p-0 text-white hover:bg-white/20 relative"
          >
            <SlidersHorizontal className="w-6 h-6" />
          </Button>
        </div>
      </div>

      {/* Filters Panel */}
      {showFilters && (
        <Card className="border-2 border-primary/20 shadow-sm bg-white">
          <CardContent className="p-3 space-y-3">
            {hasActiveFilters && (
              <div className="flex justify-end">
                <Button
                  onClick={handleResetFilters}
                  variant="ghost"
                  size="sm"
                  className="h-6 text-xs text-primary hover:text-primary/80 hover:bg-primary/5"
                >
                  Reset All
                </Button>
              </div>
            )}

            {/* Grade Filter */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-foreground flex items-center gap-1.5">
                <GraduationCap className="w-3.5 h-3.5 text-primary" />
                Grade
              </label>
              <Select value={gradeFilter} onValueChange={setGradeFilter}>
                <SelectTrigger className="h-9 text-xs border-2 border-primary/20">
                  <SelectValue placeholder="All Grades" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Grades</SelectItem>
                  {grades.map(grade => (
                    <SelectItem key={grade} value={grade}>
                      {grade}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Results Count */}
      <div className="flex items-center justify-between px-1">
        <p className="text-xs text-muted-foreground">
          {filteredClasses.length === 0
            ? 'No classes found'
            : `Showing ${filteredClasses.length} ${
                filteredClasses.length === 1 ? 'class' : 'classes'
              }`}
        </p>
      </div>

      {/* Classes List */}
      <div className="space-y-3 px-1">
        {filteredClasses.length === 0 ? (
          <Card className="border-2 border-primary/20 bg-white">
            <CardContent className="p-8 text-center">
              <BookOpen className="w-12 h-12 mx-auto text-muted-foreground/50 mb-3" />
              <p className="text-sm text-muted-foreground">
                No classes match your filters
              </p>
              {hasActiveFilters && (
                <Button
                  onClick={handleResetFilters}
                  variant="outline"
                  size="sm"
                  className="mt-3 h-8 text-xs border-primary text-primary hover:bg-primary/5"
                >
                  Clear Filters
                </Button>
              )}
            </CardContent>
          </Card>
        ) : (
          filteredClasses.map(cls => (
            <Link key={cls.id} to={`/teacher/classes/${cls.id}`}>
              <Card className="overflow-hidden hover:shadow-md transition-shadow border-2 border-primary/20 bg-white">
                <CardContent className="p-4 space-y-3">
                  {/* Class Header */}
                  <div className="flex items-center justify-between">
                    <h2 className="text-base font-bold text-foreground">
                      {cls.subject}
                    </h2>
                    <Badge 
                      variant="secondary" 
                      className="text-xs bg-secondary/10 text-secondary border-secondary/20"
                    >
                      {cls.level}
                    </Badge>
                  </div>

                  {/* Schedule */}
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Calendar className="w-4 h-4 text-primary" />
                    <span>{cls.schedule}</span>
                  </div>

                  {/* Students Count */}
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Users className="w-4 h-4 text-primary" />
                    <span className="font-semibold text-foreground">
                      {cls.students}
                    </span>
                    <span>students enrolled</span>
                  </div>
                </CardContent>
              </Card>
            </Link>
          ))
        )}
      </div>
    </div>
  );
}