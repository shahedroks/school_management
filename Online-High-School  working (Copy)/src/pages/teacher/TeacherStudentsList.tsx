import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { mockStudents, mockClasses } from '@/data/mockData';
import { Card, CardContent } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Input } from '@/app/components/ui/input';
import { Users, Search, Mail, BookOpen, ChevronRight, TrendingUp } from 'lucide-react';

export function TeacherStudentsList() {
  const [searchQuery, setSearchQuery] = useState('');

  const filteredStudents = mockStudents.filter(student =>
    student.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    student.email.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <h1 className="text-xl font-bold">Students</h1>
        <p className="text-sm text-white/90 mt-0.5">
          View all enrolled students and their progress
        </p>
      </div>

      {/* Search */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
        <Input
          type="text"
          placeholder="Search students by name or email..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="pl-9 h-10 border-2 border-primary/20"
        />
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-2">
        <Card className="border-2 border-primary/20">
          <CardContent className="p-3 text-center">
            <Users className="w-5 h-5 text-primary mx-auto mb-1" />
            <p className="text-lg font-bold text-foreground">{mockStudents.length}</p>
            <p className="text-[10px] text-muted-foreground">Total Students</p>
          </CardContent>
        </Card>
        <Card className="border-2 border-secondary/20">
          <CardContent className="p-3 text-center">
            <BookOpen className="w-5 h-5 text-secondary mx-auto mb-1" />
            <p className="text-lg font-bold text-foreground">{mockClasses.length}</p>
            <p className="text-[10px] text-muted-foreground">Classes</p>
          </CardContent>
        </Card>
        <Card className="border-2 border-accent/20">
          <CardContent className="p-3 text-center">
            <Users className="w-5 h-5 text-accent mx-auto mb-1" />
            <p className="text-lg font-bold text-foreground">
              {Math.round(mockStudents.reduce((sum, s) => sum + s.grade, 0) / mockStudents.length)}%
            </p>
            <p className="text-[10px] text-muted-foreground">Avg Grade</p>
          </CardContent>
        </Card>
      </div>

      {/* Students List */}
      <div className="space-y-2">
        {filteredStudents.length === 0 ? (
          <Card className="border-2 border-primary/20">
            <CardContent className="p-12 text-center">
              <Users className="w-12 h-12 text-muted-foreground mx-auto mb-3" />
              <p className="text-sm text-muted-foreground">
                {searchQuery ? 'No students found matching your search' : 'No students enrolled'}
              </p>
            </CardContent>
          </Card>
        ) : (
          filteredStudents.map((student) => {
            // Assign random classes to each student
            const studentClasses = mockClasses.slice(0, Math.floor(Math.random() * 3) + 3);

            return (
              <Card key={student.id} className="border-2 border-primary/20 hover:shadow-md transition-shadow">
                <CardContent className="p-3">
                  <div className="flex items-start gap-3">
                    {/* Avatar */}
                    <div className="w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                      <span className="text-sm font-bold text-primary">
                        {student.name.split(' ').map(n => n[0]).join('')}
                      </span>
                    </div>

                    {/* Student Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2 mb-1">
                        <h3 className="text-sm font-semibold text-foreground">{student.name}</h3>
                        <Badge className="text-[10px] bg-secondary/20 text-secondary border-secondary/30 flex-shrink-0">
                          {student.grade}%
                        </Badge>
                      </div>

                      <div className="flex items-center gap-1.5 text-xs text-muted-foreground mb-2">
                        <Mail className="w-3.5 h-3.5 text-primary" />
                        <span className="truncate">{student.email}</span>
                      </div>

                      {/* Enrolled Classes */}
                      <div className="flex flex-wrap gap-1 mb-2">
                        {studentClasses.map((cls, index) => (
                          <Badge key={index} className="text-[10px] bg-primary/10 text-primary border-primary/20">
                            {cls.name}
                          </Badge>
                        ))}
                      </div>

                      {/* View Details Button */}
                      <Link to={`/teacher/students/${student.id}`}>
                        <Button variant="outline" size="sm" className="w-full h-8 text-xs border-primary/20 text-primary hover:bg-primary/5">
                          <TrendingUp className="w-3 h-3 mr-1" />
                          View Progress & Attendance
                          <ChevronRight className="w-3 h-3 ml-auto" />
                        </Button>
                      </Link>
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })
        )}
      </div>

      {/* Results Count */}
      {searchQuery && (
        <p className="text-xs text-center text-muted-foreground">
          Showing {filteredStudents.length} of {mockStudents.length} students
        </p>
      )}
    </div>
  );
}