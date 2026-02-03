'use client';

import { useState } from 'react';
import Link from 'next/link';
import { PlusCircle, Map, Loader2 } from 'lucide-react';
import { CreatorPageWrapper } from '@/components/layout/creator-page-wrapper';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { TourCard } from '@/components/creator/tour-card';
import {
  useCreatorTours,
  useDeleteTour,
  useDuplicateTour,
  useWithdrawTour,
} from '@/hooks/use-creator-tours';
import { useToast } from '@/hooks/use-toast';
import { TourStatus, statusDisplayNames } from '@/types';

const statusFilters: { value: TourStatus | 'all'; label: string }[] = [
  { value: 'all', label: 'All Tours' },
  { value: 'draft', label: 'Drafts' },
  { value: 'pending_review', label: 'Pending' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
];

export default function MyToursPage() {
  const [statusFilter, setStatusFilter] = useState<TourStatus | 'all'>('all');
  const { toast } = useToast();

  const { data: tours, isLoading, error } = useCreatorTours(
    statusFilter === 'all' ? undefined : statusFilter
  );

  const deleteTour = useDeleteTour();
  const duplicateTour = useDuplicateTour();
  const withdrawTour = useWithdrawTour();

  const handleDuplicate = async (tourId: string) => {
    try {
      await duplicateTour.mutateAsync(tourId);
      toast({
        title: 'Tour duplicated',
        description: 'A copy of the tour has been created.',
      });
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to duplicate tour',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  };

  const handleDelete = async (tourId: string) => {
    try {
      await deleteTour.mutateAsync(tourId);
      toast({
        title: 'Tour deleted',
        description: 'The tour has been permanently deleted.',
      });
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to delete tour',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  };

  const handleWithdraw = async (tourId: string) => {
    try {
      await withdrawTour.mutateAsync(tourId);
      toast({
        title: 'Submission withdrawn',
        description: 'Your tour has been moved back to draft. You can now edit it.',
      });
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to withdraw submission',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  };

  // Count tours by status for the tabs
  const tourCounts = tours?.reduce(
    (acc, { tour }) => {
      acc[tour.status] = (acc[tour.status] || 0) + 1;
      acc.all = (acc.all || 0) + 1;
      return acc;
    },
    {} as Record<string, number>
  ) || {};

  return (
    <CreatorPageWrapper title="My Tours">
      <div className="space-y-6">
        {/* Header actions */}
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="text-2xl font-bold tracking-tight">Your Tours</h2>
            <p className="text-muted-foreground">
              Create and manage your walking and driving tours
            </p>
          </div>
          <Button asChild>
            <Link href="/tour/new">
              <PlusCircle className="mr-2 h-4 w-4" />
              Create Tour
            </Link>
          </Button>
        </div>

        {/* Status Filters */}
        <Tabs
          value={statusFilter}
          onValueChange={(value) => setStatusFilter(value as TourStatus | 'all')}
        >
          <TabsList className="grid w-full grid-cols-5 lg:w-auto lg:inline-grid">
            {statusFilters.map((filter) => (
              <TabsTrigger key={filter.value} value={filter.value}>
                {filter.label}
                {tourCounts[filter.value] !== undefined && statusFilter === 'all' && (
                  <span className="ml-1.5 text-xs text-muted-foreground">
                    ({tourCounts[filter.value]})
                  </span>
                )}
              </TabsTrigger>
            ))}
          </TabsList>
        </Tabs>

        {/* Loading state */}
        {isLoading && (
          <div className="flex items-center justify-center py-12">
            <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
          </div>
        )}

        {/* Error state */}
        {error && (
          <Card className="border-destructive">
            <CardContent className="pt-6">
              <p className="text-destructive">
                Failed to load tours: {error instanceof Error ? error.message : 'Unknown error'}
              </p>
            </CardContent>
          </Card>
        )}

        {/* Empty state */}
        {!isLoading && !error && tours?.length === 0 && (
          <Card className="flex flex-col items-center justify-center py-16">
            <CardHeader className="text-center">
              <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-muted">
                <Map className="h-8 w-8 text-muted-foreground" />
              </div>
              <CardTitle>
                {statusFilter === 'all' ? 'No tours yet' : `No ${statusDisplayNames[statusFilter as TourStatus].toLowerCase()} tours`}
              </CardTitle>
              <CardDescription className="max-w-sm">
                {statusFilter === 'all'
                  ? 'Get started by creating your first tour. Share your knowledge and guide others through amazing places.'
                  : `You don't have any tours with ${statusDisplayNames[statusFilter as TourStatus].toLowerCase()} status.`}
              </CardDescription>
            </CardHeader>
            {statusFilter === 'all' && (
              <CardContent>
                <Button asChild>
                  <Link href="/tour/new">
                    <PlusCircle className="mr-2 h-4 w-4" />
                    Create Your First Tour
                  </Link>
                </Button>
              </CardContent>
            )}
          </Card>
        )}

        {/* Tours grid */}
        {!isLoading && !error && tours && tours.length > 0 && (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {tours.map(({ tour, version }) => (
              <TourCard
                key={tour.id}
                tour={tour}
                version={version}
                onDuplicate={handleDuplicate}
                onDelete={handleDelete}
                onWithdraw={handleWithdraw}
                isDuplicating={duplicateTour.isPending}
                isDeleting={deleteTour.isPending}
                isWithdrawing={withdrawTour.isPending}
              />
            ))}
          </div>
        )}
      </div>
    </CreatorPageWrapper>
  );
}
