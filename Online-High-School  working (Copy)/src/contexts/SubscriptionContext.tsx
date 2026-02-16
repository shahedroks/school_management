import React, { createContext, useContext, useState, ReactNode, useEffect } from 'react';
import { useAuth } from './AuthContext';
import { mockStudentSubscriptions } from '@/data/mockData';

interface StudentSubscription {
  studentId: string;
  planId: string;
  enrolledClassIds: string[];
  startDate: string;
  endDate: string;
  status: 'active' | 'expired' | 'cancelled';
}

interface SubscriptionContextType {
  subscription: StudentSubscription | undefined;
  subscribeUser: (planId: string, enrolledClassIds: string[]) => void;
  cancelSubscription: () => void;
}

const SubscriptionContext = createContext<SubscriptionContextType | undefined>(undefined);

export function SubscriptionProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  
  // Initialize with mock data and load from localStorage
  const [subscriptions, setSubscriptions] = useState<StudentSubscription[]>(() => {
    const savedSubscriptions = localStorage.getItem('studentSubscriptions');
    if (savedSubscriptions) {
      try {
        return JSON.parse(savedSubscriptions);
      } catch (error) {
        console.error('Error parsing saved subscriptions:', error);
        return mockStudentSubscriptions;
      }
    }
    return mockStudentSubscriptions;
  });

  // Save to localStorage whenever subscriptions change
  useEffect(() => {
    localStorage.setItem('studentSubscriptions', JSON.stringify(subscriptions));
  }, [subscriptions]);

  // Get current user's subscription
  const subscription = user 
    ? subscriptions.find(sub => sub.studentId === user.id && sub.status === 'active')
    : undefined;

  const subscribeUser = (planId: string, enrolledClassIds: string[]) => {
    if (!user) return;
    
    // Calculate dates
    const startDate = new Date().toISOString().split('T')[0];
    const endDate = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]; // 30 days from now

    // Remove any existing active subscriptions for this user
    const updatedSubscriptions = subscriptions.filter(
      sub => !(sub.studentId === user.id && sub.status === 'active')
    );

    // Add new subscription
    const newSubscription: StudentSubscription = {
      studentId: user.id,
      planId,
      enrolledClassIds,
      startDate,
      endDate,
      status: 'active',
    };

    setSubscriptions([...updatedSubscriptions, newSubscription]);
  };

  const cancelSubscription = () => {
    if (!user) return;
    
    setSubscriptions(subscriptions.map(sub =>
      sub.studentId === user.id && sub.status === 'active'
        ? { ...sub, status: 'cancelled' as const }
        : sub
    ));
  };

  return (
    <SubscriptionContext.Provider
      value={{
        subscription,
        subscribeUser,
        cancelSubscription,
      }}
    >
      {children}
    </SubscriptionContext.Provider>
  );
}

export function useSubscription() {
  const context = useContext(SubscriptionContext);
  if (context === undefined) {
    throw new Error('useSubscription must be used within a SubscriptionProvider');
  }
  return context;
}