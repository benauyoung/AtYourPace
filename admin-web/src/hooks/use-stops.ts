'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  getTourStops,
  getStop,
  createStop,
  updateStop,
  deleteStop,
  reorderStops,
  uploadStopAudio,
  uploadStopImage,
  deleteStopImage,
  CreateStopInput,
  UpdateStopInput,
} from '@/lib/firebase/creator-stops';
import { AudioSource } from '@/types';

export function useTourStops(tourId: string | null) {
  return useQuery({
    queryKey: ['tourStops', tourId],
    queryFn: () => (tourId ? getTourStops(tourId) : []),
    enabled: !!tourId,
  });
}

export function useStop(tourId: string | null, stopId: string | null) {
  return useQuery({
    queryKey: ['stop', tourId, stopId],
    queryFn: () => (tourId && stopId ? getStop(tourId, stopId) : null),
    enabled: !!tourId && !!stopId,
  });
}

export function useCreateStop() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ tourId, input }: { tourId: string; input: CreateStopInput }) =>
      createStop(tourId, input),
    onSuccess: (_, { tourId }) => {
      queryClient.invalidateQueries({ queryKey: ['tourStops', tourId] });
      queryClient.invalidateQueries({ queryKey: ['creatorTour', tourId] });
    },
  });
}

export function useUpdateStop() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      tourId,
      stopId,
      input,
    }: {
      tourId: string;
      stopId: string;
      input: UpdateStopInput;
    }) => updateStop(tourId, stopId, input),
    onSuccess: (_, { tourId, stopId }) => {
      queryClient.invalidateQueries({ queryKey: ['tourStops', tourId] });
      queryClient.invalidateQueries({ queryKey: ['stop', tourId, stopId] });
    },
  });
}

export function useDeleteStop() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ tourId, stopId }: { tourId: string; stopId: string }) =>
      deleteStop(tourId, stopId),
    onSuccess: (_, { tourId }) => {
      queryClient.invalidateQueries({ queryKey: ['tourStops', tourId] });
    },
  });
}

export function useReorderStops() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ tourId, stopIds }: { tourId: string; stopIds: string[] }) =>
      reorderStops(tourId, stopIds),
    onSuccess: (_, { tourId }) => {
      queryClient.invalidateQueries({ queryKey: ['tourStops', tourId] });
    },
  });
}

export function useUploadStopAudio() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      tourId,
      stopId,
      file,
      source,
    }: {
      tourId: string;
      stopId: string;
      file: File;
      source?: AudioSource;
    }) => uploadStopAudio(tourId, stopId, file, source),
    onSuccess: (_, { tourId, stopId }) => {
      queryClient.invalidateQueries({ queryKey: ['tourStops', tourId] });
      queryClient.invalidateQueries({ queryKey: ['stop', tourId, stopId] });
    },
  });
}

export function useUploadStopImage() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      tourId,
      stopId,
      file,
      order,
    }: {
      tourId: string;
      stopId: string;
      file: File;
      order: number;
    }) => uploadStopImage(tourId, stopId, file, order),
    onSuccess: (_, { tourId, stopId }) => {
      queryClient.invalidateQueries({ queryKey: ['tourStops', tourId] });
      queryClient.invalidateQueries({ queryKey: ['stop', tourId, stopId] });
    },
  });
}

export function useDeleteStopImage() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      tourId,
      stopId,
      imageUrl,
    }: {
      tourId: string;
      stopId: string;
      imageUrl: string;
    }) => deleteStopImage(tourId, stopId, imageUrl),
    onSuccess: (_, { tourId, stopId }) => {
      queryClient.invalidateQueries({ queryKey: ['tourStops', tourId] });
      queryClient.invalidateQueries({ queryKey: ['stop', tourId, stopId] });
    },
  });
}
