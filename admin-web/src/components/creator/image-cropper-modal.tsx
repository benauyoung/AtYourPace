'use client';

import { useState, useRef, useCallback } from 'react';
import ReactCrop, { Crop, PixelCrop, centerCrop, makeAspectCrop } from 'react-image-crop';
import 'react-image-crop/dist/ReactCrop.css';
import { Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Label } from '@/components/ui/label';

interface AspectRatioOption {
  label: string;
  value: number | undefined;
}

const ASPECT_RATIOS: AspectRatioOption[] = [
  { label: 'Free', value: undefined },
  { label: '1:1 (Square)', value: 1 },
  { label: '4:3', value: 4 / 3 },
  { label: '16:9', value: 16 / 9 },
  { label: '3:2', value: 3 / 2 },
];

interface ImageCropperModalProps {
  imageSrc: string | null;
  isOpen: boolean;
  onClose: () => void;
  onCropComplete: (croppedBlob: Blob) => void;
  aspectRatio?: number;
  allowAspectChange?: boolean;
  title?: string;
}

export function ImageCropperModal({
  imageSrc,
  isOpen,
  onClose,
  onCropComplete,
  aspectRatio: initialAspectRatio,
  allowAspectChange = true,
  title = 'Crop Image',
}: ImageCropperModalProps) {
  const imgRef = useRef<HTMLImageElement>(null);
  const [crop, setCrop] = useState<Crop>();
  const [completedCrop, setCompletedCrop] = useState<PixelCrop>();
  const [aspectRatio, setAspectRatio] = useState<number | undefined>(initialAspectRatio);
  const [isProcessing, setIsProcessing] = useState(false);

  // Center crop when image loads
  const onImageLoad = useCallback(
    (e: React.SyntheticEvent<HTMLImageElement>) => {
      const { width, height } = e.currentTarget;

      const crop = centerCrop(
        makeAspectCrop(
          {
            unit: '%',
            width: 90,
          },
          aspectRatio || width / height,
          width,
          height
        ),
        width,
        height
      );

      setCrop(crop);
    },
    [aspectRatio]
  );

  // Handle aspect ratio change
  const handleAspectChange = (value: string) => {
    const newAspect = value === 'free' ? undefined : parseFloat(value);
    setAspectRatio(newAspect);

    if (imgRef.current && newAspect) {
      const { width, height } = imgRef.current;
      const newCrop = centerCrop(
        makeAspectCrop(
          {
            unit: '%',
            width: 90,
          },
          newAspect,
          width,
          height
        ),
        width,
        height
      );
      setCrop(newCrop);
    }
  };

  // Create cropped image blob
  const getCroppedImg = useCallback(async (): Promise<Blob> => {
    const image = imgRef.current;
    if (!image || !completedCrop) {
      throw new Error('No image or crop data');
    }

    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    if (!ctx) {
      throw new Error('Could not get canvas context');
    }

    const scaleX = image.naturalWidth / image.width;
    const scaleY = image.naturalHeight / image.height;

    canvas.width = completedCrop.width * scaleX;
    canvas.height = completedCrop.height * scaleY;

    ctx.drawImage(
      image,
      completedCrop.x * scaleX,
      completedCrop.y * scaleY,
      completedCrop.width * scaleX,
      completedCrop.height * scaleY,
      0,
      0,
      canvas.width,
      canvas.height
    );

    return new Promise((resolve, reject) => {
      canvas.toBlob(
        (blob) => {
          if (blob) {
            resolve(blob);
          } else {
            reject(new Error('Failed to create blob'));
          }
        },
        'image/jpeg',
        0.9
      );
    });
  }, [completedCrop]);

  // Handle save
  const handleSave = async () => {
    if (!completedCrop) return;

    setIsProcessing(true);
    try {
      const croppedBlob = await getCroppedImg();
      onCropComplete(croppedBlob);
      onClose();
    } catch (error) {
      console.error('Error cropping image:', error);
    } finally {
      setIsProcessing(false);
    }
  };

  // Reset state when modal closes
  const handleClose = () => {
    setCrop(undefined);
    setCompletedCrop(undefined);
    onClose();
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && handleClose()}>
      <DialogContent className="sm:max-w-[700px] max-h-[90vh] overflow-hidden flex flex-col">
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          <DialogDescription>
            Drag to adjust the crop area. The cropped image will be saved.
          </DialogDescription>
        </DialogHeader>

        {/* Aspect ratio selector */}
        {allowAspectChange && (
          <div className="flex items-center gap-3">
            <Label>Aspect Ratio:</Label>
            <Select
              value={aspectRatio?.toString() || 'free'}
              onValueChange={handleAspectChange}
            >
              <SelectTrigger className="w-[140px]">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {ASPECT_RATIOS.map((ratio) => (
                  <SelectItem
                    key={ratio.label}
                    value={ratio.value?.toString() || 'free'}
                  >
                    {ratio.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        )}

        {/* Crop area */}
        <div className="flex-1 overflow-auto flex items-center justify-center bg-muted/30 rounded-lg p-4 min-h-[300px]">
          {imageSrc && (
            <ReactCrop
              crop={crop}
              onChange={(_, percentCrop) => setCrop(percentCrop)}
              onComplete={(c) => setCompletedCrop(c)}
              aspect={aspectRatio}
              className="max-h-[400px]"
            >
              <img
                ref={imgRef}
                src={imageSrc}
                alt="Crop preview"
                onLoad={onImageLoad}
                className="max-h-[400px] max-w-full"
              />
            </ReactCrop>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={handleClose} disabled={isProcessing}>
            Cancel
          </Button>
          <Button onClick={handleSave} disabled={!completedCrop || isProcessing}>
            {isProcessing ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Processing...
              </>
            ) : (
              'Save Crop'
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
