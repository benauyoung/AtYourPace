'use client';

import { deleteFile, listFiles, uploadFile } from '@/lib/firebase/storage';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

export function useMediaFiles(path: string) {
    return useQuery({
        queryKey: ['media', path],
        queryFn: () => listFiles(path),
    });
}

export function useUploadMedia() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: ({ file, path }: { file: File; path: string }) =>
            uploadFile(file, path),
        onSuccess: (_, variables) => {
            // Invalidate the query for the folder where the file was uploaded
            // We assume the path includes the filename, so we strip it to get the folder
            const folderPath = variables.path.substring(0, variables.path.lastIndexOf('/'));
            queryClient.invalidateQueries({ queryKey: ['media', folderPath] });
        },
    });
}

export function useDeleteMedia() {
    const queryClient = useQueryClient();

    return useMutation({
        mutationFn: (path: string) => deleteFile(path),
        onSuccess: (_, path) => {
            const folderPath = path.substring(0, path.lastIndexOf('/'));
            queryClient.invalidateQueries({ queryKey: ['media', folderPath] });
        },
    });
}
