'use client';

import { useState, useCallback } from 'react';
import { ImageIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { ImageUploadZone } from './image-upload-zone';
import { ImageGallery } from './image-gallery';
import { ImagePreviewModal } from './image-preview-modal';
import { ImageCropperModal } from './image-cropper-modal';
import { useToast } from '@/hooks/use-toast';
import { StopImage } from '@/types';
import { cn } from '@/lib/utils';

const MAX_IMAGES = 10;

interface StopImagesPanelProps {
  stopName: string;
  images: StopImage[];
  onImageUpload: (file: File, order: number) => Promise<string>;
  onImageDelete: (imageUrl: string) => Promise<void>;
  onImagesReorder: (images: StopImage[]) => Promise<void>;
  isOpen: boolean;
  onClose: () => void;
}

export function StopImagesPanel({
  stopName,
  images,
  onImageUpload,
  onImageDelete,
  onImagesReorder,
  isOpen,
  onClose,
}: StopImagesPanelProps) {
  const { toast } = useToast();
  const [isUploading, setIsUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [deletingImage, setDeletingImage] = useState<string | null>(null);
  const [previewIndex, setPreviewIndex] = useState<number | null>(null);
  const [cropImage, setCropImage] = useState<{ file: File; url: string } | null>(null);

  // Handle files selected for upload
  const handleImagesSelected = useCallback(
    async (files: File[]) => {
      if (files.length === 0) return;

      // If single image, show cropper
      if (files.length === 1) {
        const file = files[0];
        const url = URL.createObjectURL(file);
        setCropImage({ file, url });
        return;
      }

      // Multiple images - upload directly
      setIsUploading(true);
      setUploadProgress(0);

      try {
        const startOrder = images.length;

        for (let i = 0; i < files.length; i++) {
          const file = files[i];
          await onImageUpload(file, startOrder + i);
          setUploadProgress(((i + 1) / files.length) * 100);
        }

        toast({
          title: 'Images uploaded',
          description: `${files.length} image${files.length !== 1 ? 's' : ''} added successfully.`,
        });
      } catch {
        toast({
          title: 'Upload failed',
          description: 'Failed to upload some images. Please try again.',
          variant: 'destructive',
        });
      } finally {
        setIsUploading(false);
        setUploadProgress(0);
      }
    },
    [images.length, onImageUpload, toast]
  );

  // Handle cropped image
  const handleCropComplete = useCallback(
    async (croppedBlob: Blob) => {
      if (!cropImage) return;

      setIsUploading(true);

      try {
        // Convert blob to file
        const file = new File([croppedBlob], cropImage.file.name, {
          type: 'image/jpeg',
        });

        await onImageUpload(file, images.length);

        toast({
          title: 'Image uploaded',
          description: 'Image added successfully.',
        });
      } catch {
        toast({
          title: 'Upload failed',
          description: 'Failed to upload image. Please try again.',
          variant: 'destructive',
        });
      } finally {
        setIsUploading(false);
        // Clean up
        URL.revokeObjectURL(cropImage.url);
        setCropImage(null);
      }
    },
    [cropImage, images.length, onImageUpload, toast]
  );

  // Handle image deletion
  const handleImageDelete = useCallback(
    async (imageUrl: string) => {
      setDeletingImage(imageUrl);

      try {
        await onImageDelete(imageUrl);
        toast({
          title: 'Image deleted',
          description: 'Image removed successfully.',
        });
      } catch {
        toast({
          title: 'Delete failed',
          description: 'Failed to delete image. Please try again.',
          variant: 'destructive',
        });
      } finally {
        setDeletingImage(null);
      }
    },
    [onImageDelete, toast]
  );

  // Handle reorder
  const handleReorder = useCallback(
    async (reorderedImages: StopImage[]) => {
      try {
        await onImagesReorder(reorderedImages);
      } catch {
        toast({
          title: 'Reorder failed',
          description: 'Failed to reorder images. Please try again.',
          variant: 'destructive',
        });
      }
    },
    [onImagesReorder, toast]
  );

  // Close crop modal
  const handleCropClose = () => {
    if (cropImage) {
      URL.revokeObjectURL(cropImage.url);
    }
    setCropImage(null);
  };

  return (
    <>
      <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
        <DialogContent className="sm:max-w-[700px] max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <ImageIcon className="h-5 w-5" />
              Images for &quot;{stopName}&quot;
            </DialogTitle>
            <DialogDescription>
              Add up to {MAX_IMAGES} images for this stop. Drag to reorder.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-6 mt-4">
            {/* Upload zone */}
            <ImageUploadZone
              existingCount={images.length}
              maxImages={MAX_IMAGES}
              onImagesSelected={handleImagesSelected}
              isUploading={isUploading}
              uploadProgress={uploadProgress}
            />

            {/* Gallery */}
            {images.length > 0 && (
              <div>
                <h4 className="text-sm font-medium mb-3">
                  Current Images ({images.length}/{MAX_IMAGES})
                </h4>
                <ImageGallery
                  images={images}
                  onReorder={handleReorder}
                  onDelete={handleImageDelete}
                  onPreview={setPreviewIndex}
                  isDeleting={deletingImage}
                />
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>

      {/* Crop modal */}
      <ImageCropperModal
        imageSrc={cropImage?.url || null}
        isOpen={!!cropImage}
        onClose={handleCropClose}
        onCropComplete={handleCropComplete}
        allowAspectChange
        title="Crop Image"
      />

      {/* Preview modal */}
      <ImagePreviewModal
        images={images}
        currentIndex={previewIndex ?? 0}
        isOpen={previewIndex !== null}
        onClose={() => setPreviewIndex(null)}
        onIndexChange={setPreviewIndex}
      />
    </>
  );
}

// Compact version for inline use in stop cards
interface StopImagesInlineProps {
  images: StopImage[];
  onEditClick: () => void;
  className?: string;
}

export function StopImagesInline({
  images,
  onEditClick,
  className,
}: StopImagesInlineProps) {
  const sortedImages = [...images].sort((a, b) => a.order - b.order);
  const displayImages = sortedImages.slice(0, 4);
  const remainingCount = images.length - 4;

  return (
    <div className={cn('rounded-lg border p-3', className)}>
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm font-medium flex items-center gap-2">
          <ImageIcon className="h-4 w-4" />
          Images
        </span>
        <Button size="sm" variant="outline" onClick={onEditClick}>
          {images.length > 0 ? 'Edit' : 'Add Images'}
        </Button>
      </div>

      {images.length > 0 ? (
        <div className="grid grid-cols-4 gap-1">
          {displayImages.map((image, index) => (
            <div
              key={image.url}
              className="relative aspect-square rounded overflow-hidden bg-muted"
            >
              <img
                src={image.url}
                alt={image.caption || `Image ${index + 1}`}
                className="w-full h-full object-cover"
              />
            </div>
          ))}
          {remainingCount > 0 && (
            <div className="aspect-square rounded bg-muted flex items-center justify-center">
              <span className="text-sm text-muted-foreground">
                +{remainingCount}
              </span>
            </div>
          )}
        </div>
      ) : (
        <p className="text-sm text-muted-foreground">
          No images added yet. Click &quot;Add Images&quot; to upload photos.
        </p>
      )}
    </div>
  );
}
