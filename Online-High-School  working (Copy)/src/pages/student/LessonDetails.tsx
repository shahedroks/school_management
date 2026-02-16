import React from 'react';
import { useParams } from 'react-router-dom';
import { mockLessons, mockClasses } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import {
  Video,
  FileText,
  File,
  Calendar,
  Clock,
  ChevronLeft,
  Download,
  ExternalLink,
} from 'lucide-react';

export function LessonDetails() {
  const { lessonId } = useParams<{ lessonId: string }>();
  const lesson = mockLessons.find(l => l.id === lessonId);
  const classData = lesson ? mockClasses.find(c => c.id === lesson.classId) : null;

  if (!lesson || !classData) {
    return <div>Lesson not found</div>;
  }

  const getIcon = (type: string) => {
    switch (type) {
      case 'video':
        return Video;
      case 'pdf':
        return File;
      default:
        return FileText;
    }
  };

  const Icon = getIcon(lesson.type);

  const renderContent = () => {
    switch (lesson.type) {
      case 'video':
        return (
          <div className="aspect-video bg-gray-900 rounded-lg overflow-hidden">
            <div className="w-full h-full flex items-center justify-center text-white">
              <div className="text-center p-4">
                <Video className="w-12 h-12 mx-auto mb-3 opacity-50" />
                <p className="mb-3 text-sm">Video Player Placeholder</p>
                <Button
                  size="sm"
                  variant="outline"
                  className="bg-white text-gray-900 hover:bg-gray-100 h-9 text-xs"
                  onClick={() => window.open(lesson.content, '_blank')}
                >
                  <ExternalLink className="w-3.5 h-3.5 mr-1.5" />
                  Open Video Link
                </Button>
              </div>
            </div>
          </div>
        );

      case 'pdf':
        return (
          <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
            <File className="w-12 h-12 text-gray-400 mx-auto mb-3" />
            <h3 className="text-sm font-semibold text-gray-900 mb-1">PDF Document</h3>
            <p className="text-xs text-gray-600 mb-4">Click to download or view the PDF</p>
            <div className="flex flex-col gap-2">
              <Button variant="outline" className="h-9 text-xs">
                <Download className="w-3.5 h-3.5 mr-1.5" />
                Download PDF
              </Button>
              <Button className="h-9 text-xs">
                <ExternalLink className="w-3.5 h-3.5 mr-1.5" />
                View PDF
              </Button>
            </div>
          </div>
        );

      case 'text':
      default:
        return (
          <div className="bg-white rounded-lg p-4 border border-gray-200">
            <p className="text-xs text-gray-700 leading-relaxed whitespace-pre-wrap">
              {lesson.content}
            </p>
          </div>
        );
    }
  };

  return (
    <div className="space-y-4">
      {/* Lesson Header */}
      <Card>
        <CardHeader className="pb-3">
          <div className="flex items-start gap-3 mb-2">
            <div className="p-2 bg-blue-100 rounded-lg text-blue-600 flex-shrink-0">
              <Icon className="w-4 h-4" />
            </div>
            <Badge variant="secondary" className="capitalize text-[10px] px-2 py-0.5">
              {lesson.type}
            </Badge>
          </div>
          <CardTitle className="text-base leading-tight">{lesson.title}</CardTitle>
          <p className="text-xs text-gray-600 mt-1.5 leading-relaxed">{lesson.description}</p>
          <div className="flex items-center gap-3 mt-3 text-xs text-gray-600">
            <div className="flex items-center gap-1.5">
              <Calendar className="w-3.5 h-3.5" />
              {new Date(lesson.date).toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                year: 'numeric',
              })}
            </div>
            {lesson.duration && (
              <div className="flex items-center gap-1.5">
                <Clock className="w-3.5 h-3.5" />
                {lesson.duration}
              </div>
            )}
          </div>
        </CardHeader>
      </Card>

      {/* Lesson Content */}
      <Card>
        <CardContent className="p-3">{renderContent()}</CardContent>
      </Card>
    </div>
  );
}