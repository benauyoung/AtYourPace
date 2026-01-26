'use client';

import { useState, useCallback } from 'react';
import { useDropzone, FileRejection } from 'react-dropzone';
import { Upload, X, AlertCircle, Loader2, ImageIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { cn } from '@/lib/utils';

const ACCEPTED_IMAGE_TYPES = {
  'image/jpeg': ['.jpg', '.jpeg'],
  'image/png': ['.png'],
  'image/webp': ['.webp'],
};

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
const MAX_IMAGES = 10;

export interface PendingImage {
  id: string;
  file: File;
  preview: string;
  progress: number;
  error?: string;
}

interface ImageUploadZoneProps {
  existingCount?: number;
  maxImages?: number;
  onImagesSelected: (files: File[]) => void;
  isUploading?: boolean;
  uploadProgress?: number;
  className?: string;
}

export function ImageUploadZone({
  existingCount = 0,
  maxImages = MAX_IMAGES,
  onImagesSelected,
  isUploading = false,
  uploadProgress = 0,
  className,
}: ImageUploadZoneProps) {
  const [pendingImages, setPendingImages] = useState<PendingImage[]>([]);
  const [error, setError] = useState<string | null>(null);

  const remainingSlots = maxImages - existingCount - pendingImages.length;

  const onDrop = useCallback(
    (acceptedFiles: File[], fileRejections: FileRejection[]) => {
      setError(null);

      // Handle rejected files
      if (fileRejections.length > 0) {
        const errors = fileRejections.map((f) => f.errors[0]?.message).filter(Boolean);
        setError(errors[0] || 'Some files could not be added');
        return;
      }

      // Check remaining slots
      if (acceptedFiles.length > remainingSlots) {
        setError(`You can only add ${remainingSlots} more image${remainingSlots !== 1 ? 's' : ''}`);
        return;
      }

      // Create pending images with previews
      const newPending: PendingImage[] = acceptedFiles.map((file) => ({
        id: `${file.name}-${Date.now()}-${Math.random()}`,
        file,
        preview: URL.createObjectURL(file),
        progress: 0,
      }));

      setPendingImages((prev) => [...prev, ...newPending]);
    },
    [remainingSlots]
  );

  const { getRootProps, getInputProps, isDragActive, open } = useDropzone({
    onDrop,
    accept: ACCEPTED_IMAGE_TYPES,
    maxSize: MAX_FILE_SIZE,
    maxFiles: remainingSlots,
    disabled: isUploading || remainingSlots <= 0,
    noClick: pendingImages.length > 0,
    noKeyboard: pendingImages.length > 0,
  });

  const removePendingImage = (id: string) => {
    setPendingImages((prev) => {
      const image = prev.find((img) => img.id === id);
      if (image) {
        URL.revokeObjectURL(image.preview);
      }
      return prev.filter((img) => img.id !== id);
    });
  };

  const handleUpload = () => {
    if (pendingImages.length === 0) return;
    onImagesSelected(pendingImages.map((img) => img.file));
  };

  const clearAll = () => {
    pendingImages.forEach((img) => URL.revokeObjectURL(img.preview));
    setPendingImages([]);
    setError(null);
  };

  return (
    <div className={cn('space-y-4', className)}>
      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      <div
        {...getRootProps()}
        className={cn(
          'relative rounded-lg border-2 border-dashed transition-colors',
          isDragActive && 'border-primary bg-primary/5',
          remainingSlots > 0 && !isUploading && 'hover:border-primary/50 cursor-pointer',
          (isUploading || remainingSlots <= 0) && 'opacity-50 pointer-events-none'
        )}
      >
        <input {...getInputProps()} />

        {pendingImages.length > 0 ? (
          <div className="p-4">
            {/* Pending images grid */}
            <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 gap-2 mb-4">
              {pendingImages.map((image) => (
                <div
                  key={image.id}
                  className="relative aspect-square rounded-lg overflow-hidden bg-muted"
                >
                  <img
                    src={image.preview}
                    alt="Preview"
                    className="w-full h-full object-cover"
                  />
                  {!isUploading && (
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        removePendingImage(image.id);
                      }}
                      className="absolute top-1 right-1 p-1 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
                    >
                      <X className="h-3 w-3" />
                    </button>
                  )}
                </div>
              ))}

              {/* Add more button */}
              {remainingSlots > 0 && !isUploading && (
                <button
                  type="button"
                  onClick={(e) => {
                    e.stopPropagation();
                    open();
                  }}
                  className="aspect-square rounded-lg border-2 border-dashed border-muted-foreground/30 flex items-center justify-center hover:border-primary/50 hover:bg-muted/50 transition-colors"
                >
                  <Upload className="h-6 w-6 text-muted-foreground" />
                </button>
              )}
            </div>

            {/* Upload progress or actions */}
            {isUploading ? (
              <div className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-muted-foreground flex items-center gap-2">
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Uploading images...
                  </span>
                  <span className="font-medium">{Math.round(uploadProgress)}%</span>
                </div>
                <Progress value={uploadProgress} className="h-2" />
              </div>
            ) : (
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">
                  {pendingImages.length} image{pendingImages.length !== 1 ? 's' : ''} selected
                </span>
                <div className="flex gap-2">
                  <Button variant="outline" size="sm" onClick={clearAll}>
                    Clear All
                  </Button>
                  <Button size="sm" onClick={handleUpload}>
                    Upload Images
                  </Button>
                </div>
              </div>
            )}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center p-8 text-center">
            <ImageIcon className="mb-4 h-10 w-10 text-muted-foreground" />
            <p className="font-medium">
              {isDragActive ? 'Drop images here' : 'Drag & drop images'}
            </p>
            <p className="mt-1 text-sm text-muted-foreground">
              or click to browse
            </p>
            <p className="mt-3 text-xs text-muted-foreground">
              JPG, PNG, WebP (max {MAX_FILE_SIZE / 1024 / 1024}MB each, up to {maxImages} images)
            </p>
            {existingCount > 0 && (
              <p className="mt-1 text-xs text-muted-foreground">
                {existingCount} of {maxImages} slots used
              </p>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
