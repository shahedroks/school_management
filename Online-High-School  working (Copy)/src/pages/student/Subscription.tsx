import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import { useSubscription } from '@/contexts/SubscriptionContext';
import { mockSubscriptionPlans, mockClasses } from '@/data/mockData';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/app/components/ui/card';
import { Button } from '@/app/components/ui/button';
import { Badge } from '@/app/components/ui/badge';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from '@/app/components/ui/dialog';
import { ArrowLeft, Check, Crown, BookOpen, Video, FileText, Headphones } from 'lucide-react';

export function Subscription() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const { subscription, subscribeUser } = useSubscription();
  const [selectedPlan, setSelectedPlan] = useState<string | null>(null);
  const [showConfirmDialog, setShowConfirmDialog] = useState(false);

  // Get user's current subscription
  const userSubscription = subscription;

  const handleSubscribe = (planId: string) => {
    setSelectedPlan(planId);
    setShowConfirmDialog(true);
  };

  const confirmSubscription = () => {
    const plan = mockSubscriptionPlans.find(p => p.id === selectedPlan);
    if (!plan) return;

    // Subscribe user with the plan's class IDs
    subscribeUser(plan.id, plan.classIds);

    // Show success message
    alert(`Successfully subscribed to ${plan.name}!\n\nYou now have access to ${plan.maxClasses} classes.\n\nRedirecting to dashboard...`);
    setShowConfirmDialog(false);
    navigate('/student/dashboard');
  };

  return (
    <div className="space-y-4 pb-4">
      {/* Header */}
      <div className="bg-gradient-to-r from-primary to-primary/80 text-white p-4 rounded-lg shadow-md">
        <div className="flex items-center gap-3 mb-2">
          <button
            onClick={() => navigate(-1)}
            className="p-1 hover:bg-white/10 rounded-lg transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div className="flex-1">
            <h1 className="text-xl font-bold">Subscription Plans</h1>
            <p className="text-sm text-white/90 mt-0.5">
              Choose the perfect plan for your learning journey
            </p>
          </div>
        </div>
      </div>

      {/* Current Subscription Status */}
      {userSubscription && (
        <Card className="border-2 border-secondary/40 bg-gradient-to-r from-secondary/5 to-secondary/10 shadow-sm">
          <CardContent className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2.5 bg-secondary rounded-lg">
                <Crown className="w-5 h-5 text-white" />
              </div>
              <div className="flex-1">
                <h3 className="text-sm font-semibold text-foreground">Active Subscription</h3>
                <p className="text-xs text-muted-foreground">
                  {mockSubscriptionPlans.find(p => p.id === userSubscription.planId)?.name} • 
                  Expires {new Date(userSubscription.endDate).toLocaleDateString()}
                </p>
              </div>
              <Badge className="bg-secondary text-white text-xs">Active</Badge>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Subscription Plans */}
      <div className="space-y-3">
        <h2 className="text-sm font-semibold text-foreground px-1">Available Plans</h2>
        
        {mockSubscriptionPlans.map(plan => {
          const isCurrentPlan = userSubscription?.planId === plan.id;
          const includedClasses = mockClasses.filter(cls => 
            plan.classIds.includes(cls.id)
          );

          return (
            <Card 
              key={plan.id} 
              className={`border-2 shadow-sm overflow-hidden ${
                plan.popular 
                  ? 'border-secondary shadow-secondary/20' 
                  : plan.id === 'plan3'
                  ? 'border-accent shadow-accent/20'
                  : 'border-primary/20'
              }`}
            >
              {/* Header with gradient */}
              <div className={`p-4 ${
                plan.popular 
                  ? 'bg-gradient-to-r from-secondary to-secondary/80' 
                  : plan.id === 'plan3'
                  ? 'bg-gradient-to-r from-accent to-accent/80'
                  : 'bg-primary'
              } text-white`}>
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2">
                    <Crown className="w-4 h-4" />
                    <h3 className="text-base font-bold">{plan.name}</h3>
                  </div>
                  {plan.popular && (
                    <Badge className="bg-white text-secondary text-[10px] font-bold border-0">
                      POPULAR
                    </Badge>
                  )}
                </div>
                <div className="flex items-baseline gap-1">
                  <span className="text-3xl font-bold">${plan.price}</span>
                  <span className="text-sm text-white/80">/{plan.duration}</span>
                </div>
              </div>

              <CardContent className="p-4 space-y-4 bg-gray-50">
                {/* Features */}
                <div className="space-y-2">
                  <h4 className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                    <Check className="w-3.5 h-3.5 text-secondary" />
                    What's Included
                  </h4>
                  <ul className="space-y-1.5">
                    {plan.features.map((feature, index) => (
                      <li key={index} className="flex items-center gap-2 text-xs text-muted-foreground">
                        <div className="w-1.5 h-1.5 rounded-full bg-secondary flex-shrink-0" />
                        {feature}
                      </li>
                    ))}
                  </ul>
                </div>

                {/* Available Classes */}
                <div className="space-y-2">
                  <h4 className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                    <BookOpen className="w-3.5 h-3.5 text-primary" />
                    Available Classes ({includedClasses.length})
                  </h4>
                  <div className="grid grid-cols-2 gap-2">
                    {includedClasses.slice(0, 6).map(cls => (
                      <div
                        key={cls.id}
                        className="flex items-center gap-2 p-2 rounded-lg bg-white border border-primary/10"
                      >
                        <div
                          className="w-2 h-2 rounded-full flex-shrink-0"
                          style={{ backgroundColor: cls.color }}
                        />
                        <span className="text-[10px] text-foreground font-medium truncate">
                          {cls.subject}
                        </span>
                      </div>
                    ))}
                    {includedClasses.length > 6 && (
                      <div className="flex items-center justify-center p-2 rounded-lg bg-primary/5 border border-primary/10">
                        <span className="text-[10px] text-primary font-semibold">
                          +{includedClasses.length - 6} more
                        </span>
                      </div>
                    )}
                  </div>
                </div>

                {/* Action Button */}
                <Button
                  onClick={() => handleSubscribe(plan.id)}
                  disabled={isCurrentPlan}
                  className={`w-full h-10 text-sm font-semibold ${
                    isCurrentPlan
                      ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                      : plan.popular
                      ? 'bg-secondary hover:bg-secondary/90'
                      : plan.id === 'plan3'
                      ? 'bg-accent hover:bg-accent/90'
                      : 'bg-primary hover:bg-primary/90'
                  }`}
                >
                  {isCurrentPlan ? 'Current Plan' : 'Subscribe Now'}
                </Button>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Benefits Section */}
      <Card className="border-2 border-primary/20 shadow-sm">
        <CardHeader className="pb-3 bg-primary/5">
          <CardTitle className="text-base text-foreground">Why Subscribe?</CardTitle>
        </CardHeader>
        <CardContent className="space-y-3 pt-3">
          {[
            {
              icon: BookOpen,
              title: 'Access to Quality Education',
              description: 'Learn from experienced teachers',
              color: 'text-primary',
              bgColor: 'bg-primary/10',
            },
            {
              icon: Video,
              title: 'Live Interactive Sessions',
              description: 'Join real-time virtual classes',
              color: 'text-secondary',
              bgColor: 'bg-secondary/10',
            },
            {
              icon: FileText,
              title: 'Assignments & Assessments',
              description: 'Track your learning progress',
              color: 'text-accent',
              bgColor: 'bg-accent/20',
            },
            {
              icon: Headphones,
              title: 'Dedicated Support',
              description: 'Get help when you need it',
              color: 'text-primary',
              bgColor: 'bg-primary/10',
            },
          ].map((benefit, index) => {
            const Icon = benefit.icon;
            return (
              <div key={index} className="flex items-start gap-3 p-3 rounded-lg bg-white border border-border">
                <div className={`p-2 rounded-lg ${benefit.bgColor}`}>
                  <Icon className={`w-4 h-4 ${benefit.color}`} />
                </div>
                <div className="flex-1">
                  <h4 className="text-sm font-semibold text-foreground">{benefit.title}</h4>
                  <p className="text-xs text-muted-foreground mt-0.5">{benefit.description}</p>
                </div>
              </div>
            );
          })}
        </CardContent>
      </Card>

      {/* Confirmation Dialog */}
      <Dialog open={showConfirmDialog} onOpenChange={setShowConfirmDialog}>
        <DialogContent className="w-[360px]">
          <DialogHeader>
            <DialogTitle className="text-base">Confirm Subscription</DialogTitle>
            <DialogDescription className="text-xs">
              Are you sure you want to subscribe to this plan?
            </DialogDescription>
          </DialogHeader>
          
          {selectedPlan && (
            <div className="py-4">
              <Card className="border-2 border-primary/20">
                <CardContent className="p-3">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-sm font-semibold text-foreground">
                      {mockSubscriptionPlans.find(p => p.id === selectedPlan)?.name}
                    </span>
                    <Badge className="bg-primary/10 text-primary text-xs border-primary/20">
                      {mockSubscriptionPlans.find(p => p.id === selectedPlan)?.duration}
                    </Badge>
                  </div>
                  <div className="flex items-baseline gap-1">
                    <span className="text-2xl font-bold text-primary">
                      ${mockSubscriptionPlans.find(p => p.id === selectedPlan)?.price}
                    </span>
                    <span className="text-xs text-muted-foreground">
                      /{mockSubscriptionPlans.find(p => p.id === selectedPlan)?.duration}
                    </span>
                  </div>
                </CardContent>
              </Card>
            </div>
          )}

          <DialogFooter className="flex gap-2">
            <Button
              variant="outline"
              onClick={() => setShowConfirmDialog(false)}
              className="flex-1 h-9 text-xs"
            >
              Cancel
            </Button>
            <Button
              onClick={confirmSubscription}
              className="flex-1 h-9 text-xs bg-primary"
            >
              Confirm
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}