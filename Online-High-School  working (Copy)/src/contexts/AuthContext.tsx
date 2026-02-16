import React, { createContext, useContext, useState, ReactNode } from 'react';
import { User, mockUsers } from '@/data/mockData';

interface AuthContextType {
  user: User | null;
  login: (emailOrPhone: string, password: string) => boolean;
  logout: () => void;
  isAuthenticated: boolean;
  register: (userData: any) => boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const login = (emailOrPhone: string, password: string): boolean => {
    // Demo accounts with phone numbers and 4-digit PINs
    const demoAccounts = [
      {
        id: 'demo_student',
        name: 'Fatima Al-Hassan',
        email: 'fatima@school.mr',
        phone: '12345678',
        password: '1234',
        role: 'student' as const,
        grade: '10th Grade',
      },
      {
        id: 'demo_teacher',
        name: 'Mohammed El-Amin',
        email: 'mohammed@school.mr',
        phone: '98765432',
        password: '5678',
        role: 'teacher' as const,
        subject: 'Mathematics',
      },
    ];

    // Check demo accounts first
    const demoUser = demoAccounts.find(u => 
      (u.phone === emailOrPhone || u.email === emailOrPhone) && u.password === password
    );
    
    if (demoUser) {
      setUser(demoUser);
      return true;
    }

    // Check registered users in localStorage
    const registeredUsers = JSON.parse(localStorage.getItem('registeredUsers') || '[]');
    const registeredUser = registeredUsers.find((u: any) => 
      (u.email === emailOrPhone || u.phone === emailOrPhone) && u.password === password
    );
    
    if (registeredUser) {
      // Check if teacher account is approved
      if (registeredUser.role === 'teacher' && registeredUser.status === 'pending') {
        return false; // Don't allow login for pending teachers
      }
      
      setUser({
        id: registeredUser.id,
        name: registeredUser.name,
        email: registeredUser.email,
        role: registeredUser.role,
        grade: registeredUser.grade,
        subject: registeredUser.subject,
      });
      return true;
    }
    
    // Fall back to mock users for demo accounts (old email-only accounts)
    const foundUser = mockUsers.find(u => u.email === emailOrPhone);
    if (foundUser) {
      setUser(foundUser);
      return true;
    }
    return false;
  };

  const logout = () => {
    setUser(null);
  };

  const register = (userData: any): boolean => {
    // Simple mock registration
    const newUser: User = {
      id: mockUsers.length + 1,
      name: userData.name,
      email: userData.email,
      password: userData.password,
    };
    mockUsers.push(newUser);
    setUser(newUser);
    return true;
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        login,
        logout,
        isAuthenticated: !!user,
        register,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}