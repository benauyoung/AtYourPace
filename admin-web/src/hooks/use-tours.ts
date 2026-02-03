'use client';

import {
  addReviewComment,
  addSubmissionFeedback,
  approveTour,
  deleteReviewComment,
  deleteTour,
  featureTour,
  getPendingTours,
  getReviewComments,
  // New Publishing Workflow
  getSubmission,
  getTour,
  getTours,
  getTourStats,
  getTourStops,
  getTourVersion,
  hideTour,
  rejectTour,
  resolveReviewComment,
  resolveSubmissionFeedback,
  unhideTour,
  updateSubmissionStatus,
} from '@/lib/firebase/admin';
import { SubmissionStatus, TourCategory, TourStatus } from '@/types';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

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

export function useDeleteTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (tourId: string) => deleteTour(tourId),
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
// ==================== Publishing Submissions ====================

export function useSubmission(submissionId: string | null) {
  return useQuery({
    queryKey: ['submission', submissionId],
    queryFn: () => (submissionId ? getSubmission(submissionId) : null),
    enabled: !!submissionId,
  });
}

export function useUpdateSubmissionStatus() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      submissionId,
      status,
      data,
    }: {
      submissionId: string;
      status: SubmissionStatus;
      data?: {
        reviewerId?: string;
        reviewerName?: string;
        rejectionReason?: string;
      };
    }) => updateSubmissionStatus(submissionId, status, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['submission', variables.submissionId] });
      // Invalidate tour queries as well since approval/rejection updates tour status
      queryClient.invalidateQueries({ queryKey: ['tours'] });
      queryClient.invalidateQueries({ queryKey: ['tour'] });
      queryClient.invalidateQueries({ queryKey: ['tourVersion'] });
    },
  });
}

export function useAddSubmissionFeedback() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      submissionId,
      feedback,
    }: {
      submissionId: string;
      feedback: Omit<import('@/types').ReviewFeedbackModel, 'id' | 'createdAt' | 'submissionId'>;
    }) => addSubmissionFeedback(submissionId, feedback),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['submission', variables.submissionId] });
    },
  });
}

export function useResolveSubmissionFeedback() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      submissionId,
      feedbackId,
      resolvedBy,
      note,
    }: {
      submissionId: string;
      feedbackId: string;
      resolvedBy: string;
      note?: string;
    }) => resolveSubmissionFeedback(submissionId, feedbackId, resolvedBy, note),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['submission', variables.submissionId] });
    },
  });
}
