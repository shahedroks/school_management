import React, { ReactNode } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { useLanguage } from '@/contexts/LanguageContext';
import {
  BookOpen,
  Calendar,
  FileText,
  Home,
  LogOut,
  Video,
  Users,
  GraduationCap,
  ChevronLeft,
  MoreVertical,
  UserCircle,
  Bell,
} from 'lucide-react';
import { Button } from '@/app/components/ui/button';
import { Avatar, AvatarFallback } from '@/app/components/ui/avatar';
import { Badge } from '@/app/components/ui/badge';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/app/components/ui/dropdown-menu';
import { mockNotifications } from '@/data/mockData';

interface LayoutProps {
  children: ReactNode;
}

export function Layout({ children }: LayoutProps) {
  const { user, logout, isAuthenticated } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();
  const location = useLocation();

  if (!isAuthenticated) {
    return <div className="h-full overflow-auto">{children}</div>;
  }

  const unreadCount = mockNotifications.filter(n => !n.read).length;

  const handleMarkAsRead = (notificationId: string) => {
    const updatedNotifications = mockNotifications.map(n => 
      n.id === notificationId ? { ...n, read: true } : n
    );
    // Update the mock data or use a state to manage notifications
    // For simplicity, we are not updating the mock data here
  };

  const handleMarkAllAsRead = () => {
    const updatedNotifications = mockNotifications.map(n => ({ ...n, read: true }));
    // Update the mock data or use a state to manage notifications
    // For simplicity, we are not updating the mock data here
  };

  const handleDeleteNotification = (notificationId: string) => {
    const updatedNotifications = mockNotifications.filter(n => n.id !== notificationId);
    // Update the mock data or use a state to manage notifications
    // For simplicity, we are not updating the mock data here
  };

  const getNotificationIcon = (type: string) => {
    switch (type) {
      case 'student':
        return '👤';
      case 'admin':
        return '📢';
      case 'system':
        return '⚙️';
      default:
        return '📩';
    }
  };

  const formatTimestamp = (timestamp: string) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  const navigationItems = user?.role === 'student'
    ? [
        { path: '/student/dashboard', label: t('nav.home'), icon: Home },
        { path: '/student/classes', label: t('nav.classes'), icon: BookOpen },
        { path: '/student/timetable', label: t('timetable.timetable'), icon: Calendar },
        { path: '/student/live-sessions', label: t('live.liveSessions'), icon: Video },
      ]
    : [
        { path: '/teacher/dashboard', label: t('nav.home'), icon: Home },
        { path: '/teacher/classes', label: t('nav.classes'), icon: BookOpen },
        { path: '/teacher/students', label: t('nav.students'), icon: Users },
        { path: '/teacher/live-sessions', label: t('live.liveSessions'), icon: Video },
      ];

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase();
  };

  const canGoBack = location.pathname !== '/student/dashboard' && location.pathname !== '/teacher/dashboard';

  return (
    <div className="h-full flex flex-col bg-background">
      {/* Mobile Header */}
      <header className="bg-card border-b border-border px-4 py-3 flex-shrink-0 shadow-sm">
        <div className="flex items-center justify-between">
          {canGoBack ? (
            <Button
              variant="ghost"
              size="icon"
              onClick={() => navigate(-1)}
              className="h-9 w-9 hover:bg-primary/10"
            >
              <ChevronLeft className="w-5 h-5 text-primary" />
            </Button>
          ) : (
            <div className="flex items-center gap-2">
              <GraduationCap className="w-6 h-6 text-primary" />
              <div>
                <h1 className="text-sm font-semibold text-foreground">
                  Nouadhibou HS
                </h1>
              </div>
            </div>
          )}

          <div className="flex items-center gap-2">
            {/* Notification Icon */}
            <Button 
              variant="ghost" 
              size="icon" 
              className="h-9 w-9 hover:bg-primary/10 relative"
              onClick={() => navigate('/notifications')}
            >
              <Bell className="w-5 h-5 text-foreground" />
              {unreadCount > 0 && (
                <Badge className="absolute -top-1 -right-1 h-5 min-w-5 flex items-center justify-center bg-red-500 text-white text-[10px] px-1 border-2 border-white">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </Badge>
              )}
            </Button>

            <Avatar className="h-8 w-8">
              <AvatarFallback className="bg-primary text-primary-foreground text-xs">
                {user ? getInitials(user.name) : 'U'}
              </AvatarFallback>
            </Avatar>
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon" className="h-9 w-9 hover:bg-primary/10">
                  <MoreVertical className="w-5 h-5 text-foreground" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end" className="w-56">
                <DropdownMenuLabel>
                  <div>
                    <p className="text-sm font-medium text-foreground">{user?.name}</p>
                    <p className="text-xs text-muted-foreground capitalize">{user?.role}</p>
                  </div>
                </DropdownMenuLabel>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={() => navigate(user?.role === 'student' ? '/student/profile' : '/teacher/profile')}>
                  <UserCircle className="mr-2 h-4 w-4" />
                  <span>{t('profile.myProfile')}</span>
                </DropdownMenuItem>
                <DropdownMenuItem onClick={handleLogout}>
                  <LogOut className="mr-2 h-4 w-4" />
                  <span>{t('common.logout')}</span>
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </header>

      {/* Main Content - Scrollable */}
      <main className="flex-1 overflow-auto">
        <div className="p-4">
          {children}
        </div>
      </main>

      {/* Bottom Navigation */}
      <nav className="bg-card border-t border-border flex-shrink-0 safe-area-bottom shadow-[0_-2px_8px_rgba(0,0,0,0.06)]">
        <div className="flex justify-around items-center px-2 py-2">
          {navigationItems.map(item => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path || 
                           location.pathname.startsWith(item.path + '/');
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`flex flex-col items-center justify-center gap-1 px-3 py-2 rounded-lg transition-colors min-w-[60px] ${
                  isActive
                    ? 'text-primary bg-primary/5'
                    : 'text-muted-foreground'
                }`}
              >
                <Icon className={`w-5 h-5 ${isActive ? 'fill-primary/10' : ''}`} />
                <span className="text-[10px] font-medium">{item.label}</span>
              </Link>
            );
          })}
        </div>
      </nav>
    </div>
  );
}