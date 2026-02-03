'use client';

import { DashboardCharts } from '@/components/dashboard/dashboard-charts';
import { RecentActivity } from '@/components/dashboard/recent-activity';
import { AdminLayout } from '@/components/layout/admin-layout';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { usePendingTours, useTourStats } from '@/hooks/use-tours';
import { useUserStats } from '@/hooks/use-users';
import {
  Ban,
  ClipboardList,
  DollarSign,
  Map,
  Play,
  Star,
  TrendingUp,
  Users,
} from 'lucide-react';
import Link from 'next/link';

function StatCard({
  title,
  value,
  icon: Icon,
  description,
  trend,
}: {
  title: string;
  value: number | string;
  icon: React.ElementType;
  description?: string;
  trend?: string;
}) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        {(description || trend) && (
          <div className="flex items-center text-xs text-muted-foreground mt-1">
            {trend && <span className="text-green-500 font-medium mr-2 flex items-center"><TrendingUp className="h-3 w-3 mr-1" />{trend}</span>}
            <span>{description}</span>
          </div>
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
      <div className="flex flex-col space-y-8">

        {/* Quick Actions / Notifications */}
        {pendingTours && pendingTours.length > 0 && (
          <Card className="border-orange-200 bg-orange-50 dark:border-orange-900 dark:bg-orange-950/50">
            <CardContent className="flex items-center justify-between py-4">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-orange-100 dark:bg-orange-900 rounded-full">
                  <ClipboardList className="h-5 w-5 text-orange-600 dark:text-orange-400" />
                </div>
                <div>
                  <h4 className="font-semibold text-orange-900 dark:text-orange-100">Action Required</h4>
                  <p className="text-sm text-orange-700 dark:text-orange-300">
                    {pendingTours.length} tour{pendingTours.length !== 1 ? 's' : ''} awaiting moderation
                  </p>
                </div>
              </div>
              <Link href="/review-queue">
                <Button size="sm" variant="default" className="bg-orange-600 hover:bg-orange-700 text-white">Review Queue</Button>
              </Link>
            </CardContent>
          </Card>
        )}

        {/* Top Stats Row */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <StatCard
            title="Total Revenue"
            value="$12,450"
            icon={DollarSign}
            trend="+12.5%"
            description="from last month"
          />
          <StatCard
            title="Active Users"
            value={userStats?.totalUsers ?? 0}
            icon={Users}
            trend="+4.3%"
            description="from last month"
          />
          <StatCard
            title="Live Tours"
            value={tourStats?.liveTours ?? 0}
            icon={Play}
            description="Published and active"
          />
          <StatCard
            title="Creators"
            value={userStats?.creators ?? 0}
            icon={Map}
            description="Registered creators"
          />
        </div>

        {/* Charts & Activity Section */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-7">
          <div className="col-span-4 lg:col-span-4">
            <DashboardCharts />
          </div>
          <div className="col-span-4 lg:col-span-3">
            <RecentActivity />
          </div>
        </div>

        {/* Detailed Stats Section (Collapsible or Tabbed in future) */}
        <div>
          <h3 className="mb-4 text-lg font-semibold tracking-tight">Content Overview</h3>
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
            <StatCard
              title="Total Tours"
              value={tourStats?.totalTours ?? 0}
              icon={Map}
            />
            <StatCard
              title="Featured"
              value={tourStats?.featuredTours ?? 0}
              icon={Star}
              description="Staff picks"
            />
            <StatCard
              title="Banned Users"
              value={userStats?.bannedUsers ?? 0}
              icon={Ban}
              description="Restricted accounts"
            />
            <StatCard
              title="Admins"
              value={userStats?.admins ?? 0}
              icon={Users}
            />
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
