'use client';

import {
    createCollection,
    deleteCollection,
    getCollection,
    getCollections,
    updateCollection,
} from '@/lib/firebase/admin';
import { CollectionModel, CollectionType } from '@/types';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

interface CollectionsFilters {
    type?: CollectionType;
    isCurated?: boolean;
    isFeatured?: boolean;
}

export function useCollections(filters?: CollectionsFilters) {
    return useQuery({
        queryKey: ['collections', filters],
        queryFn: () => getCollections(filters),
    });
}

export function useCollection(collectionId: string | null) {
    return useQuery({
        queryKey: ['collection', collectionId],
        queryFn: () => (collectionId ? getCollection(collectionId) : null),
        enabled: !!collectionId,
    });
}

export function useCreateCollection() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: (data: Omit<CollectionModel, 'id' | 'createdAt' | 'updatedAt'>) =>
            createCollection(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['collections'] });
        },
    });
}

export function useUpdateCollection() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: ({
            collectionId,
            data,
        }: {
            collectionId: string;
            data: Partial<Omit<CollectionModel, 'id' | 'createdAt' | 'updatedAt'>>;
        }) => updateCollection(collectionId, data),
        onSuccess: (_, variables) => {
            queryClient.invalidateQueries({ queryKey: ['collections'] });
            queryClient.invalidateQueries({ queryKey: ['collection', variables.collectionId] });
        },
    });
}

export function useDeleteCollection() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: (collectionId: string) => deleteCollection(collectionId),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['collections'] });
        },
    });
}
