import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { mockNotifications } from '@/data/mockData';
import { Button } from '@/app/components/ui/button';
import { Badge } from '@/app/components/ui/badge';
import { ArrowLeft } from 'lucide-react';

export function Notifications() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [notifications, setNotifications] = useState(mockNotifications);

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase();
  };

  const getAvatarColor = (type: string) => {
    switch (type) {
      case 'student':
        return 'bg-pink-500';
      case 'admin':
        return 'bg-accent';
      case 'system':
        return 'bg-secondary';
      default:
        return 'bg-primary';
    }
  };

  const formatDate = (timestamp: string) => {
    const date = new Date(timestamp);
    return date.toLocaleDateString('en-US', { 
      month: 'short', 
      day: 'numeric', 
      year: 'numeric' 
    });
  };

  const unreadNotifications = notifications.filter(n => !n.read);
  const readNotifications = notifications.filter(n => n.read);

  return (
    <div className="h-full flex flex-col bg-background">
      {/* Main Content */}
      <main className="flex-1 overflow-auto">
        <div className="p-4 space-y-4">
          {/* Page Heading */}
          <h1 className="text-xl font-semibold text-foreground mb-2">
            Notifications
          </h1>

          {/* All Notifications */}
          {notifications.length > 0 ? (
            <div className="space-y-3">
              {notifications.map(notification => (
                <div
                  key={notification.id}
                  className="bg-card border-2 border-primary/10 rounded-lg p-3 hover:border-primary/20 transition-colors"
                >
                  <div className="flex items-start gap-3">
                    {/* Avatar */}
                    <div className={`w-10 h-10 rounded-full ${getAvatarColor(notification.type)} flex items-center justify-center flex-shrink-0`}>
                      <span className="text-white text-sm font-semibold">
                        {getInitials(notification.from)}
                      </span>
                    </div>

                    {/* Content */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2 mb-1">
                        <h3 className="text-sm font-semibold text-foreground">
                          {notification.from}
                        </h3>
                        <div className="flex items-center gap-2 flex-shrink-0">
                          <span className="text-xs text-muted-foreground">
                            {formatDate(notification.timestamp)}
                          </span>
                          {!notification.read && (
                            <div className="w-2 h-2 rounded-full bg-primary"></div>
                          )}
                        </div>
                      </div>
                      <p className="text-xs text-muted-foreground leading-relaxed">
                        {notification.message}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <p className="text-sm text-muted-foreground mb-2">No notifications</p>
              <p className="text-xs text-muted-foreground">You're all caught up!</p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}