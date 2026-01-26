'use client';

import Link from 'next/link';
import {
  ClipboardList,
  Map,
  Users,
  Star,
  Play,
  Ban,
} from 'lucide-react';
import { AdminLayout } from '@/components/layout/admin-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { useTourStats, usePendingTours } from '@/hooks/use-tours';
import { useUserStats } from '@/hooks/use-users';

function StatCard({
  title,
  value,
  icon: Icon,
  description,
}: {
  title: string;
  value: number | string;
  icon: React.ElementType;
  description?: string;
}) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        {description && (
          <p className="text-xs text-muted-foreground">{description}</p>
        )}
      </CardContent>
    </Card>
  );
}

export default function DashboardPage() {
  const { data: tourStats, isLoading: toursLoading } = useTourStats();
  const { data: userStats, isLoading: usersLoading } = useUserStats();
  const { data: pendingTours } = usePendingTours();

  const isLoading = toursLoading || usersLoading;

  return (
    <AdminLayout title="Dashboard">
      {isLoading ? (
        <div className="flex items-center justify-center py-8">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>
      ) : (
        <div className="space-y-6">
          {/* Quick Actions */}
          {pendingTours && pendingTours.length > 0 && (
            <Card className="border-orange-200 bg-orange-50 dark:border-orange-900 dark:bg-orange-950">
              <CardContent className="flex items-center justify-between py-4">
                <div className="flex items-center gap-3">
                  <ClipboardList className="h-5 w-5 text-orange-600" />
                  <span className="font-medium">
                    {pendingTours.length} tour{pendingTours.length !== 1 ? 's' : ''} pending review
                  </span>
                </div>
                <Link href="/review-queue">
                  <Button size="sm">Review Now</Button>
                </Link>
              </CardContent>
            </Card>
          )}

          {/* Tour Stats */}
          <div>
            <h3 className="mb-4 text-lg font-semibold">Tour Statistics</h3>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
              <StatCard
                title="Total Tours"
                value={tourStats?.totalTours ?? 0}
                icon={Map}
              />
              <StatCard
                title="Pending Review"
                value={tourStats?.pendingTours ?? 0}
                icon={ClipboardList}
                description="Awaiting admin review"
              />
              <StatCard
                title="Live Tours"
                value={tourStats?.liveTours ?? 0}
                icon={Play}
                description="Published and active"
              />
              <StatCard
                title="Featured"
                value={tourStats?.featuredTours ?? 0}
                icon={Star}
                description="Highlighted tours"
              />
            </div>
          </div>

          {/* User Stats */}
          <div>
            <h3 className="mb-4 text-lg font-semibold">User Statistics</h3>
            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
              <StatCard
                title="Total Users"
                value={userStats?.totalUsers ?? 0}
                icon={Users}
              />
              <StatCard
                title="Creators"
                value={userStats?.creators ?? 0}
                icon={Map}
                description="Tour creators"
              />
              <StatCard
                title="Admins"
                value={userStats?.admins ?? 0}
                icon={Users}
              />
              <StatCard
                title="Banned"
                value={userStats?.bannedUsers ?? 0}
                icon={Ban}
                description="Banned accounts"
              />
            </div>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="mb-4 text-lg font-semibold">Quick Actions</h3>
            <div className="grid gap-4 md:grid-cols-3">
              <Link href="/review-queue">
                <Card className="cursor-pointer transition-colors hover:bg-muted">
                  <CardContent className="flex items-center gap-3 py-4">
                    <ClipboardList className="h-5 w-5" />
                    <span>Review Queue</span>
                  </CardContent>
                </Card>
              </Link>
              <Link href="/tours">
                <Card className="cursor-pointer transition-colors hover:bg-muted">
                  <CardContent className="flex items-center gap-3 py-4">
                    <Map className="h-5 w-5" />
                    <span>Manage Tours</span>
                  </CardContent>
                </Card>
              </Link>
              <Link href="/users">
                <Card className="cursor-pointer transition-colors hover:bg-muted">
                  <CardContent className="flex items-center gap-3 py-4">
                    <Users className="h-5 w-5" />
                    <span>Manage Users</span>
                  </CardContent>
                </Card>
              </Link>
            </div>
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
