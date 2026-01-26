'use client';

import { useQuery } from '@tanstack/react-query';
import {
  collection,
  query,
  where,
  getDocs,
  orderBy,
  limit,
} from 'firebase/firestore';
import { db } from '@/lib/firebase/config';
import { useAuth } from './use-auth';
import { TourModel, TourStats, timestampToDate } from '@/types';

// Analytics data types
export interface DailyStats {
  date: string;
  plays: number;
  downloads: number;
}

export interface TourAnalytics {
  tourId: string;
  title: string;
  status: string;
  plays: number;
  downloads: number;
  averageRating: number;
  totalRatings: number;
  revenue: number;
  createdAt: Date;
}

export interface CreatorAnalyticsSummary {
  totalPlays: number;
  totalDownloads: number;
  totalRevenue: number;
  averageRating: number;
  totalRatings: number;
  totalTours: number;
  liveTours: number;
  draftTours: number;
}

export interface CreatorAnalyticsData {
  summary: CreatorAnalyticsSummary;
  dailyStats: DailyStats[];
  tourBreakdown: TourAnalytics[];
}

// Date range options
export type DateRange = '7d' | '30d' | '90d' | '1y' | 'all';

function getDateRangeStart(range: DateRange): Date | null {
  const now = new Date();
  switch (range) {
    case '7d':
      return new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    case '30d':
      return new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
    case '90d':
      return new Date(now.getTime() - 90 * 24 * 60 * 60 * 1000);
    case '1y':
      return new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
    case 'all':
      return null;
  }
}

function generateDateRange(startDate: Date, endDate: Date): string[] {
  const dates: string[] = [];
  const current = new Date(startDate);
  current.setHours(0, 0, 0, 0);

  while (current <= endDate) {
    dates.push(current.toISOString().split('T')[0]);
    current.setDate(current.getDate() + 1);
  }

  return dates;
}

async function fetchCreatorAnalytics(
  creatorId: string,
  dateRange: DateRange
): Promise<CreatorAnalyticsData> {
  // Fetch all tours for this creator
  const toursRef = collection(db, 'tours');
  const toursQuery = query(
    toursRef,
    where('creatorId', '==', creatorId),
    orderBy('createdAt', 'desc')
  );

  const toursSnapshot = await getDocs(toursQuery);
  const tours: (TourModel & { versionTitle?: string })[] = [];

  for (const doc of toursSnapshot.docs) {
    const data = doc.data();
    const tour: TourModel = {
      id: doc.id,
      creatorId: data.creatorId,
      creatorName: data.creatorName,
      slug: data.slug,
      category: data.category,
      tourType: data.tourType,
      status: data.status,
      featured: data.featured || false,
      startLocation: data.startLocation,
      geohash: data.geohash,
      city: data.city,
      region: data.region,
      country: data.country,
      liveVersionId: data.liveVersionId,
      liveVersion: data.liveVersion,
      draftVersionId: data.draftVersionId,
      draftVersion: data.draftVersion,
      stats: data.stats || {
        totalPlays: 0,
        totalDownloads: 0,
        averageRating: 0,
        totalRatings: 0,
        totalRevenue: 0,
      },
      createdAt: timestampToDate(data.createdAt),
      updatedAt: timestampToDate(data.updatedAt),
      publishedAt: data.publishedAt ? timestampToDate(data.publishedAt) : undefined,
    };
    tours.push(tour);
  }

  // Fetch version titles for each tour
  const tourBreakdown: TourAnalytics[] = [];
  for (const tour of tours) {
    // Get the version title (prefer live version, fallback to draft)
    let title = 'Untitled Tour';
    const versionId = tour.liveVersionId || tour.draftVersionId;

    if (versionId) {
      try {
        const versionRef = collection(db, `tours/${tour.id}/versions`);
        const versionQuery = query(versionRef, where('__name__', '==', versionId), limit(1));
        const versionSnapshot = await getDocs(versionQuery);
        if (!versionSnapshot.empty) {
          title = versionSnapshot.docs[0].data().title || 'Untitled Tour';
        }
      } catch {
        // Use default title if version fetch fails
      }
    }

    tourBreakdown.push({
      tourId: tour.id,
      title,
      status: tour.status,
      plays: tour.stats.totalPlays,
      downloads: tour.stats.totalDownloads,
      averageRating: tour.stats.averageRating,
      totalRatings: tour.stats.totalRatings,
      revenue: tour.stats.totalRevenue,
      createdAt: tour.createdAt,
    });
  }

  // Calculate summary stats
  const summary: CreatorAnalyticsSummary = {
    totalPlays: tours.reduce((sum, t) => sum + (t.stats?.totalPlays || 0), 0),
    totalDownloads: tours.reduce((sum, t) => sum + (t.stats?.totalDownloads || 0), 0),
    totalRevenue: tours.reduce((sum, t) => sum + (t.stats?.totalRevenue || 0), 0),
    averageRating: 0,
    totalRatings: tours.reduce((sum, t) => sum + (t.stats?.totalRatings || 0), 0),
    totalTours: tours.length,
    liveTours: tours.filter((t) => t.status === 'approved').length,
    draftTours: tours.filter((t) => t.status === 'draft').length,
  };

  // Calculate weighted average rating
  if (summary.totalRatings > 0) {
    const weightedSum = tours.reduce(
      (sum, t) => sum + (t.stats?.averageRating || 0) * (t.stats?.totalRatings || 0),
      0
    );
    summary.averageRating = weightedSum / summary.totalRatings;
  }

  // Generate daily stats (simulated for now - would come from analytics collection)
  const rangeStart = getDateRangeStart(dateRange);
  const endDate = new Date();
  const startDate = rangeStart || new Date(endDate.getTime() - 30 * 24 * 60 * 60 * 1000);

  const dateLabels = generateDateRange(startDate, endDate);
  const dailyStats: DailyStats[] = dateLabels.map((date) => {
    // In production, this would come from an analytics collection
    // For now, we'll distribute total plays/downloads across the date range
    const daysCount = dateLabels.length;
    const avgPlaysPerDay = Math.floor(summary.totalPlays / daysCount);
    const avgDownloadsPerDay = Math.floor(summary.totalDownloads / daysCount);

    // Add some variance
    const variance = 0.3;
    const playVariance = Math.floor(avgPlaysPerDay * variance * (Math.random() * 2 - 1));
    const downloadVariance = Math.floor(avgDownloadsPerDay * variance * (Math.random() * 2 - 1));

    return {
      date,
      plays: Math.max(0, avgPlaysPerDay + playVariance),
      downloads: Math.max(0, avgDownloadsPerDay + downloadVariance),
    };
  });

  return {
    summary,
    dailyStats,
    tourBreakdown,
  };
}

export function useCreatorAnalytics(dateRange: DateRange = '30d') {
  const { user } = useAuth();

  return useQuery({
    queryKey: ['creatorAnalytics', user?.uid, dateRange],
    queryFn: () => (user?.uid ? fetchCreatorAnalytics(user.uid, dateRange) : null),
    enabled: !!user?.uid,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

// Hook for individual tour analytics
export function useTourAnalytics(tourId: string | null) {
  return useQuery({
    queryKey: ['tourAnalytics', tourId],
    queryFn: async () => {
      if (!tourId) return null;

      // Fetch tour stats
      const toursRef = collection(db, 'tours');
      const tourQuery = query(toursRef, where('__name__', '==', tourId), limit(1));
      const tourSnapshot = await getDocs(tourQuery);

      if (tourSnapshot.empty) return null;

      const data = tourSnapshot.docs[0].data();
      const stats: TourStats = data.stats || {
        totalPlays: 0,
        totalDownloads: 0,
        averageRating: 0,
        totalRatings: 0,
        totalRevenue: 0,
      };

      return stats;
    },
    enabled: !!tourId,
    staleTime: 5 * 60 * 1000,
  });
}
