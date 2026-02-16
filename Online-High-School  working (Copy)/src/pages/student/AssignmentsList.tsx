import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useLanguage } from '@/contexts/LanguageContext';
import { mockAssignments, mockClasses } from '@/data/mockData';
import { Card, CardContent } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { FileText, Clock, CheckCircle, AlertCircle, Calendar } from 'lucide-react';

export function AssignmentsList() {
  const { t } = useLanguage();
  const [filter, setFilter] = useState<'all' | 'pending' | 'submitted' | 'graded'>('all');

  const filteredAssignments = mockAssignments.filter(assignment => {
    if (filter === 'all') return true;
    return assignment.status === filter;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending':
        return 'bg-accent/20 text-accent-foreground border-accent/30';
      case 'submitted':
        return 'bg-primary/20 text-primary border-primary/30';
      case 'graded':
        return 'bg-secondary/20 text-secondary border-secondary/30';
      default:
        return 'bg-muted text-muted-foreground';
    }
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'pending':
        return <Clock className="w-3.5 h-3.5" />;
      case 'submitted':
        return <FileText className="w-3.5 h-3.5" />;
      case 'graded':
        return <CheckCircle className="w-3.5 h-3.5" />;
      default:
        return null;
    }
  };

  return (
    <div className="space-y-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <h1 className="text-xl font-bold">My Tasks</h1>
        <p className="text-sm text-white/90 mt-0.5">
          View and manage your assignments
        </p>
      </div>

      {/* Filter Buttons */}
      <div className="flex gap-2 overflow-x-auto pb-1">
        <Button
          variant={filter === 'all' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setFilter('all')}
          className={filter === 'all' ? 'bg-primary' : 'border-primary/20 text-foreground'}
        >
          All ({mockAssignments.length})
        </Button>
        <Button
          variant={filter === 'pending' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setFilter('pending')}
          className={filter === 'pending' ? 'bg-accent' : 'border-primary/20 text-foreground'}
        >
          Pending ({mockAssignments.filter(a => a.status === 'pending').length})
        </Button>
        <Button
          variant={filter === 'submitted' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setFilter('submitted')}
          className={filter === 'submitted' ? 'bg-primary' : 'border-primary/20 text-foreground'}
        >
          Submitted ({mockAssignments.filter(a => a.status === 'submitted').length})
        </Button>
        <Button
          variant={filter === 'graded' ? 'default' : 'outline'}
          size="sm"
          onClick={() => setFilter('graded')}
          className={filter === 'graded' ? 'bg-secondary' : 'border-primary/20 text-foreground'}
        >
          Graded ({mockAssignments.filter(a => a.status === 'graded').length})
        </Button>
      </div>

      {/* Assignments List */}
      <div className="space-y-3">
        {filteredAssignments.length === 0 ? (
          <Card className="border-2 border-primary/20">
            <CardContent className="p-12 text-center">
              <FileText className="w-12 h-12 text-muted-foreground mx-auto mb-3" />
              <p className="text-sm text-muted-foreground">No assignments found</p>
            </CardContent>
          </Card>
        ) : (
          filteredAssignments.map(assignment => {
            const classData = mockClasses.find(c => c.id === assignment.classId);
            const daysUntilDue = Math.ceil(
              (new Date(assignment.dueDate).getTime() - new Date().getTime()) /
                (1000 * 60 * 60 * 24)
            );
            const isUrgent = daysUntilDue <= 2 && assignment.status === 'pending';

            return (
              <Link
                key={assignment.id}
                to={`/student/assignments/${assignment.id}`}
              >
                <Card className="overflow-hidden hover:shadow-md transition-shadow border-2 border-primary/20">
                  {/* Class Header Bar */}
                  <div
                    className="h-12 relative flex items-center px-3"
                    style={{
                      background: `linear-gradient(135deg, #1F3C88, #1F3C88dd)`,
                    }}
                  >
                    <div className="flex items-center gap-2">
                      <FileText className="w-4 h-4 text-white" />
                      <span className="text-sm font-semibold text-white">
                        {classData?.name || 'Unknown Class'}
                      </span>
                    </div>
                  </div>

                  <CardContent className="p-3 space-y-3">
                    {/* Assignment Title & Description */}
                    <div>
                      <div className="flex items-start justify-between gap-2 mb-1">
                        <h3 className="text-sm font-semibold text-foreground">
                          {assignment.title}
                        </h3>
                        {isUrgent && <AlertCircle className="w-4 h-4 text-destructive flex-shrink-0" />}
                      </div>
                      <p className="text-xs text-muted-foreground line-clamp-2">
                        {assignment.description}
                      </p>
                    </div>

                    {/* Assignment Info */}
                    <div className="space-y-2">
                      <div className="flex items-center gap-2 text-xs text-muted-foreground">
                        <Calendar className="w-3.5 h-3.5 text-primary" />
                        <span>
                          Due: {new Date(assignment.dueDate).toLocaleDateString('en-US', {
                            month: 'short',
                            day: 'numeric',
                            year: 'numeric',
                          })}
                        </span>
                        {assignment.status === 'pending' && (
                          <span
                            className={`ml-2 font-medium ${
                              isUrgent ? 'text-destructive' : 'text-muted-foreground'
                            }`}
                          >
                            ({daysUntilDue}d left)
                          </span>
                        )}
                      </div>
                    </div>

                    {/* Status & Points */}
                    <div className="flex items-center justify-between gap-2">
                      <div className="flex items-center gap-2">
                        <Badge variant="secondary" className={`text-[10px] flex items-center gap-1 ${getStatusColor(assignment.status)}`}>
                          {getStatusIcon(assignment.status)}
                          {assignment.status.charAt(0).toUpperCase() + assignment.status.slice(1)}
                        </Badge>
                        {assignment.status === 'graded' && assignment.grade !== undefined && (
                          <Badge className="text-[10px] bg-secondary/20 text-secondary border-secondary/30">
                            {assignment.grade}/{assignment.points} pts
                          </Badge>
                        )}
                        {assignment.status !== 'graded' && (
                          <Badge className="text-[10px] bg-primary/10 text-primary border-primary/20">
                            {assignment.points} pts
                          </Badge>
                        )}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </Link>
            );
          })
        )}
      </div>
    </div>
  );
}