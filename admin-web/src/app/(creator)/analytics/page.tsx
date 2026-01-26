'use client';

import { useState } from 'react';
import { BarChart3, Calendar, RefreshCw, Loader2 } from 'lucide-react';
import { CreatorPageWrapper } from '@/components/layout/creator-page-wrapper';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { AnalyticsCards, TourCountCards } from '@/components/creator/analytics-cards';
import { PlaysChart, RatingDistributionChart } from '@/components/creator/analytics-chart';
import { TourStatsTable } from '@/components/creator/tour-stats-table';
import { useCreatorAnalytics, DateRange } from '@/hooks/use-creator-analytics';
import { useQueryClient } from '@tanstack/react-query';
import { useAuth } from '@/hooks/use-auth';

const dateRangeOptions: { value: DateRange; label: string }[] = [
  { value: '7d', label: 'Last 7 days' },
  { value: '30d', label: 'Last 30 days' },
  { value: '90d', label: 'Last 90 days' },
  { value: '1y', label: 'Last year' },
  { value: 'all', label: 'All time' },
];

export default function AnalyticsPage() {
  const [dateRange, setDateRange] = useState<DateRange>('30d');
  const { user } = useAuth();
  const queryClient = useQueryClient();
  const { data, isLoading, isFetching } = useCreatorAnalytics(dateRange);

  const handleRefresh = () => {
    queryClient.invalidateQueries({ queryKey: ['creatorAnalytics', user?.uid] });
  };

  return (
    <CreatorPageWrapper title="Analytics">
      <div className="mx-auto max-w-7xl space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <h2 className="text-2xl font-bold tracking-tight flex items-center gap-2">
              <BarChart3 className="h-6 w-6" />
              Analytics
            </h2>
            <p className="text-muted-foreground">
              Track your tour performance and engagement
            </p>
          </div>

          <div className="flex items-center gap-3">
            <Select
              value={dateRange}
              onValueChange={(value) => setDateRange(value as DateRange)}
            >
              <SelectTrigger className="w-[160px]">
                <Calendar className="h-4 w-4 mr-2" />
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {dateRangeOptions.map((option) => (
                  <SelectItem key={option.value} value={option.value}>
                    {option.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <Button
              variant="outline"
              size="icon"
              onClick={handleRefresh}
              disabled={isFetching}
            >
              {isFetching ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <RefreshCw className="h-4 w-4" />
              )}
              <span className="sr-only">Refresh analytics</span>
            </Button>
          </div>
        </div>

        {/* Main stats cards */}
        <AnalyticsCards data={data?.summary} isLoading={isLoading} />

        {/* Charts row */}
        <div className="grid gap-6 lg:grid-cols-3">
          <PlaysChart
            data={data?.dailyStats}
            isLoading={isLoading}
            className="lg:col-span-2"
          />
          <RatingDistributionChart isLoading={isLoading} />
        </div>

        {/* Tour counts */}
        <TourCountCards data={data?.summary} isLoading={isLoading} />

        {/* Tour breakdown table */}
        <TourStatsTable data={data?.tourBreakdown} isLoading={isLoading} />
      </div>
    </CreatorPageWrapper>
  );
}
