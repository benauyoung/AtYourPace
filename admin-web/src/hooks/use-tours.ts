'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  getTours,
  getTour,
  getTourVersion,
  getTourStops,
  getPendingTours,
  approveTour,
  rejectTour,
  hideTour,
  unhideTour,
  featureTour,
  getTourStats,
  getReviewComments,
  addReviewComment,
  deleteReviewComment,
  resolveReviewComment,
} from '@/lib/firebase/admin';
import { TourStatus, TourCategory } from '@/types';

interface ToursFilters {
  status?: TourStatus;
  category?: TourCategory;
  featured?: boolean;
  searchQuery?: string;
}

export function useTours(filters?: ToursFilters) {
  return useQuery({
    queryKey: ['tours', filters],
    queryFn: () => getTours(filters),
  });
}

export function useTour(tourId: string | null) {
  return useQuery({
    queryKey: ['tour', tourId],
    queryFn: () => (tourId ? getTour(tourId) : null),
    enabled: !!tourId,
  });
}

export function useTourVersion(tourId: string | null, versionId: string | null) {
  return useQuery({
    queryKey: ['tourVersion', tourId, versionId],
    queryFn: () => (tourId && versionId ? getTourVersion(tourId, versionId) : null),
    enabled: !!tourId && !!versionId,
  });
}

export function useTourStops(tourId: string | null, versionId: string | null) {
  return useQuery({
    queryKey: ['tourStops', tourId, versionId],
    queryFn: () => (tourId && versionId ? getTourStops(tourId, versionId) : []),
    enabled: !!tourId && !!versionId,
  });
}

export function usePendingTours() {
  return useQuery({
    queryKey: ['pendingTours'],
    queryFn: getPendingTours,
    refetchInterval: 30000, // Refetch every 30 seconds
  });
}

export function useTourStats() {
  return useQuery({
    queryKey: ['tourStats'],
    queryFn: getTourStats,
  });
}

export function useApproveTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ tourId, notes }: { tourId: string; notes?: string }) =>
      approveTour(tourId, notes),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tours'] });
      queryClient.invalidateQueries({ queryKey: ['pendingTours'] });
      queryClient.invalidateQueries({ queryKey: ['tourStats'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}

export function useRejectTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      tourId,
      reason,
      includeComments,
    }: {
      tourId: string;
      reason: string;
      includeComments?: boolean;
    }) => rejectTour(tourId, reason, includeComments),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tours'] });
      queryClient.invalidateQueries({ queryKey: ['pendingTours'] });
      queryClient.invalidateQueries({ queryKey: ['tourStats'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}

export function useHideTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ tourId, reason }: { tourId: string; reason?: string }) =>
      hideTour(tourId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tours'] });
      queryClient.invalidateQueries({ queryKey: ['tourStats'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}

export function useUnhideTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (tourId: string) => unhideTour(tourId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tours'] });
      queryClient.invalidateQueries({ queryKey: ['tourStats'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}

export function useFeatureTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ tourId, featured }: { tourId: string; featured: boolean }) =>
      featureTour(tourId, featured),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tours'] });
      queryClient.invalidateQueries({ queryKey: ['tourStats'] });
      queryClient.invalidateQueries({ queryKey: ['auditLogs'] });
    },
  });
}

// ==================== Review Comments ====================

export function useReviewComments(tourId: string | null, versionId: string | null) {
  return useQuery({
    queryKey: ['reviewComments', tourId, versionId],
    queryFn: () => (tourId && versionId ? getReviewComments(tourId, versionId) : []),
    enabled: !!tourId && !!versionId,
  });
}

export function useAddReviewComment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      tourId,
      versionId,
      stopId,
      content,
    }: {
      tourId: string;
      versionId: string;
      stopId: string;
      content: string;
    }) => addReviewComment(tourId, versionId, stopId, content),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: ['reviewComments', variables.tourId, variables.versionId],
      });
    },
  });
}

export function useDeleteReviewComment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      commentId,
      tourId,
      versionId,
    }: {
      commentId: string;
      tourId: string;
      versionId: string;
    }) => deleteReviewComment(commentId),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: ['reviewComments', variables.tourId, variables.versionId],
      });
    },
  });
}

export function useResolveReviewComment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      commentId,
      tourId,
      versionId,
    }: {
      commentId: string;
      tourId: string;
      versionId: string;
    }) => resolveReviewComment(commentId),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({
        queryKey: ['reviewComments', variables.tourId, variables.versionId],
      });
    },
  });
}
