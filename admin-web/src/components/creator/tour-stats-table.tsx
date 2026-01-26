'use client';

import { useState, useMemo } from 'react';
import Link from 'next/link';
import {
  ArrowUpDown,
  ArrowUp,
  ArrowDown,
  Play,
  Download,
  Star,
  ExternalLink,
  MoreHorizontal,
  Eye,
  Edit,
  BarChart3,
} from 'lucide-react';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { cn } from '@/lib/utils';
import { TourAnalytics } from '@/hooks/use-creator-analytics';
import { TourStatus, statusDisplayNames } from '@/types';

type SortField = 'title' | 'plays' | 'downloads' | 'rating' | 'createdAt';
type SortDirection = 'asc' | 'desc';

interface TourStatsTableProps {
  data: TourAnalytics[] | null | undefined;
  isLoading?: boolean;
  className?: string;
}

const statusColors: Record<TourStatus, string> = {
  draft: 'bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300',
  pending_review: 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400',
  approved: 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400',
  rejected: 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400',
  hidden: 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400',
};

export function TourStatsTable({ data, isLoading, className }: TourStatsTableProps) {
  const [sortField, setSortField] = useState<SortField>('plays');
  const [sortDirection, setSortDirection] = useState<SortDirection>('desc');

  const sortedData = useMemo(() => {
    if (!data) return [];

    return [...data].sort((a, b) => {
      let comparison = 0;

      switch (sortField) {
        case 'title':
          comparison = a.title.localeCompare(b.title);
          break;
        case 'plays':
          comparison = a.plays - b.plays;
          break;
        case 'downloads':
          comparison = a.downloads - b.downloads;
          break;
        case 'rating':
          comparison = a.averageRating - b.averageRating;
          break;
        case 'createdAt':
          comparison = a.createdAt.getTime() - b.createdAt.getTime();
          break;
      }

      return sortDirection === 'asc' ? comparison : -comparison;
    });
  }, [data, sortField, sortDirection]);

  const handleSort = (field: SortField) => {
    if (sortField === field) {
      setSortDirection((d) => (d === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortField(field);
      setSortDirection('desc');
    }
  };

  const SortIcon = ({ field }: { field: SortField }) => {
    if (sortField !== field) {
      return <ArrowUpDown className="ml-1 h-4 w-4" />;
    }
    return sortDirection === 'asc' ? (
      <ArrowUp className="ml-1 h-4 w-4" />
    ) : (
      <ArrowDown className="ml-1 h-4 w-4" />
    );
  };

  if (isLoading) {
    return (
      <Card className={className}>
        <CardHeader>
          <Skeleton className="h-5 w-40" />
          <Skeleton className="h-4 w-60 mt-1" />
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <Skeleton key={i} className="h-12 w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  const formatNumber = (num: number): string => {
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1)}K`;
    }
    return num.toLocaleString();
  };

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <BarChart3 className="h-5 w-5" />
          Tour Performance
        </CardTitle>
        <CardDescription>
          Detailed stats for each of your tours
        </CardDescription>
      </CardHeader>
      <CardContent>
        {sortedData.length === 0 ? (
          <div className="text-center py-8 text-muted-foreground">
            <p>No tours created yet</p>
            <Button asChild className="mt-4">
              <Link href="/tour/new">Create Your First Tour</Link>
            </Button>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="min-w-[200px]">
                    <Button
                      variant="ghost"
                      size="sm"
                      className="-ml-3 h-8"
                      onClick={() => handleSort('title')}
                    >
                      Tour
                      <SortIcon field="title" />
                    </Button>
                  </TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">
                    <Button
                      variant="ghost"
                      size="sm"
                      className="-mr-3 h-8"
                      onClick={() => handleSort('plays')}
                    >
                      <Play className="h-4 w-4 mr-1" />
                      Plays
                      <SortIcon field="plays" />
                    </Button>
                  </TableHead>
                  <TableHead className="text-right">
                    <Button
                      variant="ghost"
                      size="sm"
                      className="-mr-3 h-8"
                      onClick={() => handleSort('downloads')}
                    >
                      <Download className="h-4 w-4 mr-1" />
                      Downloads
                      <SortIcon field="downloads" />
                    </Button>
                  </TableHead>
                  <TableHead className="text-right">
                    <Button
                      variant="ghost"
                      size="sm"
                      className="-mr-3 h-8"
                      onClick={() => handleSort('rating')}
                    >
                      <Star className="h-4 w-4 mr-1" />
                      Rating
                      <SortIcon field="rating" />
                    </Button>
                  </TableHead>
                  <TableHead className="w-[50px]" />
                </TableRow>
              </TableHeader>
              <TableBody>
                {sortedData.map((tour) => (
                  <TableRow key={tour.tourId}>
                    <TableCell>
                      <div>
                        <Link
                          href={`/tour/${tour.tourId}/edit`}
                          className="font-medium hover:underline line-clamp-1"
                        >
                          {tour.title}
                        </Link>
                        <p className="text-xs text-muted-foreground">
                          Created {tour.createdAt.toLocaleDateString()}
                        </p>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant="secondary"
                        className={cn(
                          'font-normal',
                          statusColors[tour.status as TourStatus]
                        )}
                      >
                        {statusDisplayNames[tour.status as TourStatus] || tour.status}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-right font-medium">
                      {formatNumber(tour.plays)}
                    </TableCell>
                    <TableCell className="text-right font-medium">
                      {formatNumber(tour.downloads)}
                    </TableCell>
                    <TableCell className="text-right">
                      <div className="flex items-center justify-end gap-1">
                        <Star className="h-3.5 w-3.5 text-yellow-500 fill-yellow-500" />
                        <span className="font-medium">
                          {tour.averageRating > 0 ? tour.averageRating.toFixed(1) : '—'}
                        </span>
                        {tour.totalRatings > 0 && (
                          <span className="text-xs text-muted-foreground">
                            ({tour.totalRatings})
                          </span>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon" className="h-8 w-8">
                            <MoreHorizontal className="h-4 w-4" />
                            <span className="sr-only">Actions</span>
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem asChild>
                            <Link href={`/tour/${tour.tourId}/preview`}>
                              <Eye className="h-4 w-4 mr-2" />
                              Preview
                            </Link>
                          </DropdownMenuItem>
                          <DropdownMenuItem asChild>
                            <Link href={`/tour/${tour.tourId}/edit`}>
                              <Edit className="h-4 w-4 mr-2" />
                              Edit
                            </Link>
                          </DropdownMenuItem>
                          <DropdownMenuItem asChild>
                            <Link href={`/tour/${tour.tourId}/stops`}>
                              <ExternalLink className="h-4 w-4 mr-2" />
                              Manage Stops
                            </Link>
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

// Compact version for dashboard widgets
interface TourStatsCompactProps {
  data: TourAnalytics[] | null | undefined;
  limit?: number;
  isLoading?: boolean;
  className?: string;
}

export function TourStatsCompact({
  data,
  limit = 5,
  isLoading,
  className,
}: TourStatsCompactProps) {
  const topTours = useMemo(() => {
    if (!data) return [];
    return [...data].sort((a, b) => b.plays - a.plays).slice(0, limit);
  }, [data, limit]);

  if (isLoading) {
    return (
      <Card className={className}>
        <CardHeader className="pb-2">
          <Skeleton className="h-5 w-24" />
        </CardHeader>
        <CardContent>
          <div className="space-y-3">
            {Array.from({ length: limit }).map((_, i) => (
              <Skeleton key={i} className="h-10 w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader className="pb-2">
        <CardTitle className="text-base">Top Tours</CardTitle>
      </CardHeader>
      <CardContent>
        {topTours.length === 0 ? (
          <p className="text-sm text-muted-foreground text-center py-4">
            No tours yet
          </p>
        ) : (
          <div className="space-y-3">
            {topTours.map((tour, index) => (
              <div key={tour.tourId} className="flex items-center gap-3">
                <span className="text-lg font-bold text-muted-foreground w-5">
                  {index + 1}
                </span>
                <div className="flex-1 min-w-0">
                  <Link
                    href={`/tour/${tour.tourId}/edit`}
                    className="text-sm font-medium hover:underline truncate block"
                  >
                    {tour.title}
                  </Link>
                </div>
                <div className="flex items-center gap-1 text-sm text-muted-foreground">
                  <Play className="h-3.5 w-3.5" />
                  {tour.plays}
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
