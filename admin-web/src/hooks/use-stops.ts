'use client';

import {
  createStop,
  CreateStopInput,
  deleteStop,
  deleteStopImage,
  getStop,
  getTourStops,
  reorderStopImages,
  reorderStops,
  updateStop,
  UpdateStopInput,
  uploadStopAudio,
  uploadStopImage,
} from '@/lib/firebase/creator-stops';
import { AudioSource, StopImage } from '@/types';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

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
    onMutate: async ({ tourId, stopId, input }) => {
      // Cancel any outgoing refetches (so they don't overwrite our optimistic update)
      await queryClient.cancelQueries({ queryKey: ['tourStops', tourId] });
      await queryClient.cancelQueries({ queryKey: ['stop', tourId, stopId] });

      // Snapshot the previous value
      const previousStops = queryClient.getQueryData<any[]>(['tourStops', tourId]);
      const previousStop = queryClient.getQueryData<any>(['stop', tourId, stopId]);

      // Optimistically update to the new value
      if (previousStops) {
        queryClient.setQueryData(['tourStops', tourId], (old: any[]) => {
          return old.map((stop) =>
            stop.id === stopId ? { ...stop, ...input } : stop
          );
        });
      }

      if (previousStop) {
        queryClient.setQueryData(['stop', tourId, stopId], (old: any) => ({
          ...old,
          ...input
        }));
      }

      // Return a context object with the snapshotted value
      return { previousStops, previousStop };
    },
    onError: (err, { tourId, stopId }, context) => {
      // If the mutation fails, use the context returned from onMutate to roll back
      if (context?.previousStops) {
        queryClient.setQueryData(['tourStops', tourId], context.previousStops);
      }
      if (context?.previousStop) {
        queryClient.setQueryData(['stop', tourId, stopId], context.previousStop);
      }
    },
    onSettled: (_, __, { tourId, stopId }) => {
      // Always refetch after error or success:
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
    onMutate: async ({ tourId, stopIds }) => {
      await queryClient.cancelQueries({ queryKey: ['tourStops', tourId] });

      const previousStops = queryClient.getQueryData<any[]>(['tourStops', tourId]);

      if (previousStops) {
        // Create a map for quick lookup
        const stopMap = new Map(previousStops.map(s => [s.id, s]));

        // Reconstruct the array based on the new order of IDs
        // Filter out any IDs that might not exist in the map (safety)
        const newStops = stopIds
          .map(id => stopMap.get(id))
          .filter(Boolean)
          .map((stop, index) => ({
            ...stop,
            order: index // Optimistically update the order field too if your UI relies on it
          }));

        queryClient.setQueryData(['tourStops', tourId], newStops);
      }

      return { previousStops };
    },
    onError: (err, { tourId }, context) => {
      if (context?.previousStops) {
        queryClient.setQueryData(['tourStops', tourId], context.previousStops);
      }
    },
    onSettled: (_, __, { tourId }) => {
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

export function useReorderStopImages() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({
      tourId,
      stopId,
      images,
    }: {
      tourId: string;
      stopId: string;
      images: StopImage[];
    }) => reorderStopImages(tourId, stopId, images),
    onSuccess: (_, { tourId, stopId }) => {
      queryClient.invalidateQueries({ queryKey: ['tourStops', tourId] });
      queryClient.invalidateQueries({ queryKey: ['stop', tourId, stopId] });
    },
  });
}
