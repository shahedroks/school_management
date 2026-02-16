import React, { createContext, useContext, useState, ReactNode } from 'react';
import { mockLessons as initialLessons } from '@/data/mockData';

export interface Lesson {
  id: string;
  classId: string;
  title: string;
  description: string;
  type: 'text' | 'pdf' | 'video';
  content: string;
  date: string;
  duration?: string;
  status: 'draft' | 'published';
  lastUpdated: string;
  module?: string; // Chapter/Module name
  attachedFile?: string; // File name
  grade?: string; // Grade level: 4th, 5th, 6th, 7th
  subject?: string; // Subject name
}

interface LessonsContextType {
  lessons: Lesson[];
  addLesson: (lesson: Omit<Lesson, 'id' | 'lastUpdated'>) => void;
  updateLesson: (id: string, updates: Partial<Lesson>) => void;
  deleteLesson: (id: string) => void;
}

const LessonsContext = createContext<LessonsContextType | undefined>(undefined);

export function LessonsProvider({ children }: { children: ReactNode }) {
  const [lessons, setLessons] = useState<Lesson[]>(initialLessons);

  const addLesson = (lesson: Omit<Lesson, 'id' | 'lastUpdated'>) => {
    const newLesson: Lesson = {
      ...lesson,
      id: `lesson-${Date.now()}`,
      lastUpdated: new Date().toISOString(),
    };
    setLessons(prev => [newLesson, ...prev]);
  };

  const updateLesson = (id: string, updates: Partial<Lesson>) => {
    setLessons(prev =>
      prev.map(lesson =>
        lesson.id === id
          ? { ...lesson, ...updates, lastUpdated: new Date().toISOString() }
          : lesson
      )
    );
  };

  const deleteLesson = (id: string) => {
    setLessons(prev => prev.filter(lesson => lesson.id !== id));
  };

  return (
    <LessonsContext.Provider value={{ lessons, addLesson, updateLesson, deleteLesson }}>
      {children}
    </LessonsContext.Provider>
  );
}

export function useLessons(classId?: string) {
  const context = useContext(LessonsContext);
  if (!context) {
    throw new Error('useLessons must be used within a LessonsProvider');
  }
  
  if (classId) {
    return {
      ...context,
      lessons: context.lessons.filter(lesson => lesson.classId === classId),
    };
  }
  
  return context;
}