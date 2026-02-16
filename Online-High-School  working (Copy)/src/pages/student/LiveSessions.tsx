import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { useLanguage } from '@/contexts/LanguageContext';
import { mockLiveSessions, mockClasses } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle } from '@/app/components/ui/card';
import { Badge } from '@/app/components/ui/badge';
import { Button } from '@/app/components/ui/button';
import { Video, Calendar, Clock, ExternalLink, Users } from 'lucide-react';

export function LiveSessions() {
  const { t } = useLanguage();
  const { sessionId } = useParams<{ sessionId?: string }>();

  // If sessionId is provided, show session details
  if (sessionId) {
    const session = mockLiveSessions.find(s => s.id === sessionId);
    const classData = session
      ? mockClasses.find(c => c.id === session.classId)
      : null;

    if (!session || !classData) {
      return <div className="text-sm text-gray-600">Session not found</div>;
    }

    return (
      <div className="space-y-4">
        <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
          <h1 className="text-xl font-bold">{t('live.liveSessions')}</h1>
          <p className="text-sm text-white/90 mt-0.5">{session.title}</p>
        </div>

        <Card className="border-2 border-secondary shadow-md">
          <CardHeader className="pb-3 bg-secondary/5">
            <CardTitle className="text-base text-foreground">{session.title}</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4 pt-0">
            <div className="space-y-2">
              <div className="bg-secondary/5 p-3 rounded-lg border border-secondary/20">
                <p className="text-[10px] text-secondary uppercase tracking-wide mb-0.5">
                  {t('classes.classDetails')}
                </p>
                <p className="text-sm font-semibold text-foreground">{classData.name}</p>
              </div>
              <div className="bg-secondary/5 p-3 rounded-lg border border-secondary/20">
                <p className="text-[10px] text-secondary uppercase tracking-wide mb-0.5">
                  {t('live.sessionDate')} & {t('live.sessionTime')}
                </p>
                <p className="text-sm font-semibold text-foreground">
                  {new Date(session.date).toLocaleDateString()}
                </p>
                <p className="text-xs text-muted-foreground">{session.time}</p>
              </div>
              <div className="bg-secondary/5 p-3 rounded-lg border border-secondary/20">
                <p className="text-[10px] text-secondary uppercase tracking-wide mb-0.5">
                  {t('live.platform')}
                </p>
                <p className="text-sm font-semibold text-foreground capitalize">
                  {session.platform === 'zoom' ? 'Zoom' : 'Google Meet'}
                </p>
              </div>
            </div>

            <div className="bg-gradient-to-br from-secondary to-secondary/80 text-white p-6 rounded-lg text-center shadow-md">
              <Video className="w-12 h-12 mx-auto mb-3" />
              <h3 className="text-lg font-bold mb-1">Ready to Join?</h3>
              <p className="text-xs mb-4 opacity-90">
                Click the button below to join the live session
              </p>
              <Button
                className="bg-white text-secondary hover:bg-white/90 w-full h-11"
                onClick={() => window.open(session.link, '_blank')}
              >
                <ExternalLink className="w-4 h-4 mr-2" />
                {t('live.joinSession')}
              </Button>
            </div>

            <div className="bg-muted p-3 rounded-lg border border-border">
              <h4 className="text-sm font-semibold text-foreground mb-2">Session Guidelines</h4>
              <ul className="space-y-1 text-xs text-muted-foreground">
                <li>• Join 5 minutes before the session starts</li>
                <li>• Keep your microphone muted when not speaking</li>
                <li>• Use the chat for questions</li>
                <li>• Have your notebook ready</li>
              </ul>
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Otherwise show list of sessions
  const activeSessions = mockLiveSessions.filter(s => s.isActive);
  const upcomingSessions = mockLiveSessions.filter(s => !s.isActive);

  return (
    <div className="space-y-4 pb-4">
      {/* Header */}
      <div className="bg-primary text-primary-foreground p-4 rounded-lg shadow-sm">
        <h1 className="text-xl font-bold">{t('live.liveSessions')}</h1>
        <p className="text-sm text-white/90 mt-0.5">{t('live.upcomingSessions')}</p>
      </div>

      {/* Active Now Section */}
      {activeSessions.length > 0 && (
        <div className="space-y-3">
          <div className="flex items-center gap-1.5 px-1">
            <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse" />
            <h2 className="text-sm font-semibold text-foreground">
              Active Now ({activeSessions.length})
            </h2>
          </div>

          <div className="space-y-3">
            {activeSessions.map(session => {
              const classData = mockClasses.find(c => c.id === session.classId);
              return (
                <Card key={session.id} className="border border-border shadow-sm">
                  <CardContent className="p-4 bg-white flex items-center justify-between gap-4">
                    <div className="flex-1 min-w-0">
                      <h3 className="text-sm font-semibold text-primary truncate">
                        {session.title}
                      </h3>
                      <p className="text-xs text-muted-foreground mt-1">
                        {session.time} • {session.platform === 'zoom' ? 'Zoom' : 'Meet'}
                      </p>
                    </div>
                    <Link to={`/student/live-sessions/${session.id}`}>
                      <Button
                        size="sm"
                        className="h-9 text-xs bg-secondary hover:bg-secondary/90 text-white font-medium px-4 shadow-sm flex-shrink-0"
                      >
                        <Video className="w-3.5 h-3.5 mr-1.5" />
                        {t('live.joinSession')}
                      </Button>
                    </Link>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </div>
      )}

      {/* Upcoming Sessions Section */}
      <div className="space-y-3">
        <h2 className="text-sm font-semibold text-foreground px-1">
          Upcoming Sessions ({upcomingSessions.length})
        </h2>

        {upcomingSessions.length === 0 ? (
          <Card className="border-2 border-primary/20 bg-white">
            <CardContent className="p-8 text-center">
              <Video className="w-10 h-10 mx-auto text-muted-foreground/50 mb-2" />
              <p className="text-sm text-muted-foreground">
                No upcoming sessions scheduled
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-3">
            {upcomingSessions.map(session => {
              const classData = mockClasses.find(c => c.id === session.classId);
              return (
                <Card key={session.id} className="border-2 border-primary/20 overflow-hidden shadow-sm">
                  {/* Blue Header */}
                  <div className="bg-primary px-4 py-2.5 flex items-center gap-2 text-white">
                    <Video className="w-4 h-4" />
                    <span className="font-semibold text-sm">{classData?.name || 'Class'}</span>
                  </div>

                  {/* Light Content Section */}
                  <CardContent className="p-4 bg-gray-50 space-y-3">
                    <h3 className="text-sm font-semibold text-foreground">
                      {session.title}
                    </h3>

                    <div className="flex items-center gap-3 flex-wrap">
                      <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                        <Calendar className="w-3.5 h-3.5 text-primary" />
                        <span>{new Date(session.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                        <Clock className="w-3.5 h-3.5 text-primary" />
                        <span>{session.time}</span>
                      </div>
                    </div>

                    <div className="flex items-center gap-2">
                      <Badge className="text-[10px] bg-blue-500/10 text-blue-600 border border-blue-500/20 font-medium capitalize">
                        {session.platform}
                      </Badge>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        )}
      </div>

      {activeSessions.length === 0 && upcomingSessions.length === 0 && (
        <Card className="border-2 border-primary/20 bg-white">
          <CardContent className="p-12 text-center">
            <Video className="w-10 h-10 text-muted-foreground/50 mx-auto mb-2" />
            <p className="text-sm text-muted-foreground">No live sessions scheduled</p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}