'use client';

import { useMediaFiles } from '@/hooks/use-media';
import { StorageFile } from '@/lib/firebase/storage';
import { MediaItem } from './media-item';

interface MediaGridProps {
    path: string;
    onSelect?: (file: StorageFile) => void;
}

export function MediaGrid({ path, onSelect }: MediaGridProps) {
    const { data: files, isLoading } = useMediaFiles(path);

    if (isLoading) {
        return (
            <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                {[1, 2, 3, 4, 5, 6].map((i) => (
                    <div key={i} className="aspect-square bg-muted rounded-lg animate-pulse" />
                ))}
            </div>
        );
    }

    if (!files || files.length === 0) {
        return (
            <div className="flex flex-col items-center justify-center py-12 text-muted-foreground border-2 border-dashed rounded-lg">
                <p>No files found in this folder.</p>
            </div>
        );
    }

    return (
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
            {files.map((file) => (
                <MediaItem key={file.fullPath} file={file} onSelect={onSelect} />
            ))}
        </div>
    );
}
