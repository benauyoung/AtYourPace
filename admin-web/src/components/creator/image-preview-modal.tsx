'use client';

import { useEffect, useCallback } from 'react';
import { X, ChevronLeft, ChevronRight, Download } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import { StopImage } from '@/types';

interface ImagePreviewModalProps {
  images: StopImage[];
  currentIndex: number;
  isOpen: boolean;
  onClose: () => void;
  onIndexChange: (index: number) => void;
}

export function ImagePreviewModal({
  images,
  currentIndex,
  isOpen,
  onClose,
  onIndexChange,
}: ImagePreviewModalProps) {
  const sortedImages = [...images].sort((a, b) => a.order - b.order);
  const currentImage = sortedImages[currentIndex];
  const canGoPrev = currentIndex > 0;
  const canGoNext = currentIndex < sortedImages.length - 1;

  const goToPrev = useCallback(() => {
    if (canGoPrev) {
      onIndexChange(currentIndex - 1);
    }
  }, [canGoPrev, currentIndex, onIndexChange]);

  const goToNext = useCallback(() => {
    if (canGoNext) {
      onIndexChange(currentIndex + 1);
    }
  }, [canGoNext, currentIndex, onIndexChange]);

  // Keyboard navigation
  useEffect(() => {
    if (!isOpen) return;

    const handleKeyDown = (e: KeyboardEvent) => {
      switch (e.key) {
        case 'Escape':
          onClose();
          break;
        case 'ArrowLeft':
          goToPrev();
          break;
        case 'ArrowRight':
          goToNext();
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose, goToPrev, goToNext]);

  // Prevent body scroll when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  const handleDownload = () => {
    if (!currentImage) return;

    const link = document.createElement('a');
    link.href = currentImage.url;
    link.download = `image-${currentIndex + 1}.jpg`;
    link.target = '_blank';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  if (!isOpen || !currentImage) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/95">
      {/* Header */}
      <div className="absolute top-0 left-0 right-0 z-10 flex items-center justify-between p-4 bg-gradient-to-b from-black/50 to-transparent">
        <div className="text-white">
          <span className="font-medium">
            {currentIndex + 1} / {sortedImages.length}
          </span>
          {currentImage.caption && (
            <p className="text-sm text-white/70 mt-1">{currentImage.caption}</p>
          )}
        </div>
        <div className="flex items-center gap-2">
          <Button
            size="icon"
            variant="ghost"
            className="text-white hover:bg-white/20"
            onClick={handleDownload}
          >
            <Download className="h-5 w-5" />
          </Button>
          <Button
            size="icon"
            variant="ghost"
            className="text-white hover:bg-white/20"
            onClick={onClose}
          >
            <X className="h-5 w-5" />
          </Button>
        </div>
      </div>

      {/* Main image */}
      <div
        className="absolute inset-0 flex items-center justify-center p-16"
        onClick={onClose}
      >
        <img
          src={currentImage.url}
          alt={currentImage.caption || `Image ${currentIndex + 1}`}
          className="max-w-full max-h-full object-contain"
          onClick={(e) => e.stopPropagation()}
        />
      </div>

      {/* Navigation arrows */}
      {canGoPrev && (
        <button
          className="absolute left-4 top-1/2 -translate-y-1/2 p-3 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
          onClick={goToPrev}
        >
          <ChevronLeft className="h-8 w-8" />
        </button>
      )}

      {canGoNext && (
        <button
          className="absolute right-4 top-1/2 -translate-y-1/2 p-3 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
          onClick={goToNext}
        >
          <ChevronRight className="h-8 w-8" />
        </button>
      )}

      {/* Thumbnail strip */}
      {sortedImages.length > 1 && (
        <div className="absolute bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-black/50 to-transparent">
          <div className="flex items-center justify-center gap-2 overflow-x-auto pb-2">
            {sortedImages.map((image, index) => (
              <button
                key={image.url}
                onClick={() => onIndexChange(index)}
                className={cn(
                  'flex-shrink-0 w-16 h-16 rounded-lg overflow-hidden border-2 transition-all',
                  index === currentIndex
                    ? 'border-white scale-110'
                    : 'border-transparent opacity-60 hover:opacity-100'
                )}
              >
                <img
                  src={image.url}
                  alt={`Thumbnail ${index + 1}`}
                  className="w-full h-full object-cover"
                />
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
