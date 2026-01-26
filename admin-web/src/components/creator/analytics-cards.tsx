'use client';

import {
  Play,
  Download,
  Star,
  DollarSign,
  TrendingUp,
  TrendingDown,
  Minus,
  Map,
  FileCheck,
  FilePen,
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';
import { CreatorAnalyticsSummary } from '@/hooks/use-creator-analytics';

interface AnalyticsCardsProps {
  data: CreatorAnalyticsSummary | null | undefined;
  isLoading?: boolean;
  className?: string;
}

interface StatCardProps {
  title: string;
  value: string | number;
  description?: string;
  icon: React.ElementType;
  trend?: 'up' | 'down' | 'neutral';
  trendValue?: string;
  iconColor?: string;
}

function StatCard({
  title,
  value,
  description,
  icon: Icon,
  trend,
  trendValue,
  iconColor = 'text-primary',
}: StatCardProps) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        <Icon className={cn('h-4 w-4', iconColor)} />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        {(description || trendValue) && (
          <div className="flex items-center gap-1 mt-1">
            {trend && trendValue && (
              <span
                className={cn(
                  'flex items-center text-xs font-medium',
                  trend === 'up' && 'text-green-600',
                  trend === 'down' && 'text-red-600',
                  trend === 'neutral' && 'text-muted-foreground'
                )}
              >
                {trend === 'up' && <TrendingUp className="h-3 w-3 mr-0.5" />}
                {trend === 'down' && <TrendingDown className="h-3 w-3 mr-0.5" />}
                {trend === 'neutral' && <Minus className="h-3 w-3 mr-0.5" />}
                {trendValue}
              </span>
            )}
            {description && (
              <p className="text-xs text-muted-foreground">{description}</p>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
}

function StatCardSkeleton() {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <Skeleton className="h-4 w-24" />
        <Skeleton className="h-4 w-4 rounded" />
      </CardHeader>
      <CardContent>
        <Skeleton className="h-8 w-16" />
        <Skeleton className="h-3 w-32 mt-2" />
      </CardContent>
    </Card>
  );
}

export function AnalyticsCards({ data, isLoading, className }: AnalyticsCardsProps) {
  if (isLoading) {
    return (
      <div className={cn('grid gap-4 md:grid-cols-2 lg:grid-cols-4', className)}>
        {Array.from({ length: 4 }).map((_, i) => (
          <StatCardSkeleton key={i} />
        ))}
      </div>
    );
  }

  const formatNumber = (num: number): string => {
    if (num >= 1000000) {
      return `${(num / 1000000).toFixed(1)}M`;
    }
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}K`;
    }
    return num.toLocaleString();
  };

  const formatCurrency = (amount: number): string => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    }).format(amount);
  };

  const formatRating = (rating: number): string => {
    return rating > 0 ? rating.toFixed(1) : '—';
  };

  return (
    <div className={cn('grid gap-4 md:grid-cols-2 lg:grid-cols-4', className)}>
      <StatCard
        title="Total Plays"
        value={formatNumber(data?.totalPlays || 0)}
        description="All-time tour plays"
        icon={Play}
        iconColor="text-blue-600"
      />
      <StatCard
        title="Downloads"
        value={formatNumber(data?.totalDownloads || 0)}
        description="Offline downloads"
        icon={Download}
        iconColor="text-green-600"
      />
      <StatCard
        title="Average Rating"
        value={formatRating(data?.averageRating || 0)}
        description={`${data?.totalRatings || 0} reviews`}
        icon={Star}
        iconColor="text-yellow-500"
      />
      <StatCard
        title="Total Revenue"
        value={formatCurrency(data?.totalRevenue || 0)}
        description="Lifetime earnings"
        icon={DollarSign}
        iconColor="text-emerald-600"
      />
    </div>
  );
}

// Secondary stats row showing tour counts
interface TourCountCardsProps {
  data: CreatorAnalyticsSummary | null | undefined;
  isLoading?: boolean;
  className?: string;
}

export function TourCountCards({ data, isLoading, className }: TourCountCardsProps) {
  if (isLoading) {
    return (
      <div className={cn('grid gap-4 md:grid-cols-3', className)}>
        {Array.from({ length: 3 }).map((_, i) => (
          <StatCardSkeleton key={i} />
        ))}
      </div>
    );
  }

  return (
    <div className={cn('grid gap-4 md:grid-cols-3', className)}>
      <StatCard
        title="Total Tours"
        value={data?.totalTours || 0}
        description="All tours created"
        icon={Map}
        iconColor="text-purple-600"
      />
      <StatCard
        title="Live Tours"
        value={data?.liveTours || 0}
        description="Currently published"
        icon={FileCheck}
        iconColor="text-green-600"
      />
      <StatCard
        title="Drafts"
        value={data?.draftTours || 0}
        description="Work in progress"
        icon={FilePen}
        iconColor="text-gray-500"
      />
    </div>
  );
}
