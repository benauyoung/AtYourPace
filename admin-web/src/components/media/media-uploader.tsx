'use client';

import { useUploadMedia } from '@/hooks/use-media';
import { useToast } from '@/hooks/use-toast';
import { CloudUpload, Loader2 } from 'lucide-react';
import { useCallback } from 'react';
import { useDropzone } from 'react-dropzone';

interface MediaUploaderProps {
    path: string;
}

export function MediaUploader({ path }: MediaUploaderProps) {
    const { toast } = useToast();
    const uploadMutation = useUploadMedia();

    const onDrop = useCallback(
        async (acceptedFiles: File[]) => {
            for (const file of acceptedFiles) {
                try {
                    await uploadMutation.mutateAsync({
                        file,
                        // Append timestamp to prevent conflicts, or just use clean name
                        path: `${path}/${Date.now()}_${file.name}`,
                    });
                    toast({
                        title: 'Uploaded',
                        description: `${file.name} uploaded successfully.`,
                    });
                } catch (error) {
                    toast({
                        variant: 'destructive',
                        title: 'Upload Failed',
                        description: `Failed to upload ${file.name}.`,
                    });
                }
            }
        },
        [path, uploadMutation, toast]
    );

    const { getRootProps, getInputProps, isDragActive } = useDropzone({
        onDrop,
        accept: {
            'image/*': [],
            'audio/*': [],
        },
    });

    return (
        <div
            {...getRootProps()}
            className={`border-2 border-dashed rounded-lg p-8 transition-colors text-center cursor-pointer ${isDragActive
                    ? 'border-primary bg-primary/5'
                    : 'border-muted-foreground/25 hover:border-primary/50'
                }`}
        >
            <input {...getInputProps()} />
            <div className="flex flex-col items-center gap-2">
                {uploadMutation.isPending ? (
                    <Loader2 className="h-8 w-8 text-muted-foreground animate-spin" />
                ) : (
                    <CloudUpload className="h-8 w-8 text-muted-foreground" />
                )}
                <div className="text-sm font-medium">
                    {isDragActive ? 'Drop files here' : 'Drag & drop files here, or click to select'}
                </div>
                <p className="text-xs text-muted-foreground">
                    Supports JPG, PNG, MP3
                </p>
            </div>
        </div>
    );
}
