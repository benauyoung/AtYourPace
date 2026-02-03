'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  getCreatorTours,
  getCreatorTour,
  createTour,
  updateTour,
  deleteTour,
  duplicateTour,
  submitTourForReview,
  withdrawTourSubmission,
  uploadCoverImage,
  CreateTourInput,
  UpdateTourInput,
  TourWithVersion,
} from '@/lib/firebase/creator-tours';
import { TourStatus } from '@/types';

export function useCreatorTours(status?: TourStatus) {
  return useQuery({
    queryKey: ['creatorTours', status],
    queryFn: () => getCreatorTours(status),
  });
}

export type { TourWithVersion };

export function useCreatorTour(tourId: string | null) {
  return useQuery({
    queryKey: ['creatorTour', tourId],
    queryFn: () => (tourId ? getCreatorTour(tourId) : null),
    enabled: !!tourId,
  });
}

export function useCreateTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: CreateTourInput) => createTour(input),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['creatorTours'] });
    },
  });
}

export function useUpdateTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ tourId, input }: { tourId: string; input: UpdateTourInput }) =>
      updateTour(tourId, input),
    onSuccess: (_, { tourId }) => {
      queryClient.invalidateQueries({ queryKey: ['creatorTours'] });
      queryClient.invalidateQueries({ queryKey: ['creatorTour', tourId] });
    },
  });
}

export function useDeleteTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (tourId: string) => deleteTour(tourId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['creatorTours'] });
    },
  });
}

export function useDuplicateTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (tourId: string) => duplicateTour(tourId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['creatorTours'] });
    },
  });
}

export function useSubmitTourForReview() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (tourId: string) => submitTourForReview(tourId),
    onSuccess: (_, tourId) => {
      queryClient.invalidateQueries({ queryKey: ['creatorTours'] });
      queryClient.invalidateQueries({ queryKey: ['creatorTour', tourId] });
    },
  });
}

export function useWithdrawTour() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (tourId: string) => withdrawTourSubmission(tourId),
    onSuccess: (_, tourId) => {
      queryClient.invalidateQueries({ queryKey: ['creatorTours'] });
      queryClient.invalidateQueries({ queryKey: ['creatorTour', tourId] });
    },
  });
}

export function useUploadCoverImage() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ tourId, file }: { tourId: string; file: File }) =>
      uploadCoverImage(tourId, file),
    onSuccess: (_, { tourId }) => {
      queryClient.invalidateQueries({ queryKey: ['creatorTour', tourId] });
    },
  });
}
