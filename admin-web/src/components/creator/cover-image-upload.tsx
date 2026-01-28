'use client';

import { useState, useCallback, useRef } from 'react';
import Image from 'next/image';
import { useDropzone } from 'react-dropzone';
import ReactCrop, { Crop, PixelCrop, centerCrop, makeAspectCrop } from 'react-image-crop';
import 'react-image-crop/dist/ReactCrop.css';
import { Upload, Loader2, ImageIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';

interface CoverImageUploadProps {
  imageUrl?: string;
  onUpload: (file: File) => Promise<void>;
  isUploading?: boolean;
  disabled?: boolean;
}

const ASPECT_RATIO = 16 / 9;
const MIN_WIDTH = 800;

function centerAspectCrop(
  mediaWidth: number,
  mediaHeight: number,
  aspect: number
): Crop {
  return centerCrop(
    makeAspectCrop(
      {
        unit: '%',
        width: 90,
      },
      aspect,
      mediaWidth,
      mediaHeight
    ),
    mediaWidth,
    mediaHeight
  );
}

export function CoverImageUpload({
  imageUrl,
  onUpload,
  isUploading,
  disabled,
}: CoverImageUploadProps) {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [crop, setCrop] = useState<Crop>();
  const [completedCrop, setCompletedCrop] = useState<PixelCrop>();
  const [showCropDialog, setShowCropDialog] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);

  const onDrop = useCallback((acceptedFiles: File[]) => {
    const file = acceptedFiles[0];
    if (file) {
      setSelectedFile(file);
      const url = URL.createObjectURL(file);
      setPreviewUrl(url);
      setShowCropDialog(true);
    }
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/jpeg': ['.jpg', '.jpeg'],
      'image/png': ['.png'],
      'image/webp': ['.webp'],
    },
    maxFiles: 1,
    disabled: disabled || isUploading,
  });

  const onImageLoad = useCallback((e: React.SyntheticEvent<HTMLImageElement>) => {
    const { width, height } = e.currentTarget;
    setCrop(centerAspectCrop(width, height, ASPECT_RATIO));
  }, []);

  const handleCropComplete = async () => {
    if (!imgRef.current || !completedCrop || !selectedFile) return;

    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    const scaleX = imgRef.current.naturalWidth / imgRef.current.width;
    const scaleY = imgRef.current.naturalHeight / imgRef.current.height;

    const cropX = completedCrop.x * scaleX;
    const cropY = completedCrop.y * scaleY;
    const cropWidth = completedCrop.width * scaleX;
    const cropHeight = completedCrop.height * scaleY;

    // Calculate output dimensions (maintain 16:9 with minimum width)
    const outputWidth = Math.max(MIN_WIDTH, cropWidth);
    const outputHeight = outputWidth / ASPECT_RATIO;

    canvas.width = outputWidth;
    canvas.height = outputHeight;

    ctx.drawImage(
      imgRef.current,
      cropX,
      cropY,
      cropWidth,
      cropHeight,
      0,
      0,
      outputWidth,
      outputHeight
    );

    // Convert to blob
    canvas.toBlob(
      async (blob) => {
        if (!blob) return;

        const croppedFile = new File([blob], selectedFile.name, {
          type: 'image/jpeg',
        });

        setShowCropDialog(false);
        setPreviewUrl(null);
        setSelectedFile(null);

        await onUpload(croppedFile);
      },
      'image/jpeg',
      0.9
    );
  };

  const handleCancel = () => {
    setShowCropDialog(false);
    if (previewUrl) {
      URL.revokeObjectURL(previewUrl);
    }
    setPreviewUrl(null);
    setSelectedFile(null);
    setCrop(undefined);
    setCompletedCrop(undefined);
  };

  return (
    <>
      <div
        {...getRootProps()}
        className={`
          relative aspect-video rounded-lg border-2 border-dashed overflow-hidden
          transition-colors cursor-pointer
          ${isDragActive ? 'border-primary bg-primary/5' : 'border-muted-foreground/25 hover:border-primary/50'}
          ${disabled || isUploading ? 'opacity-50 cursor-not-allowed' : ''}
        `}
      >
        <input {...getInputProps()} />

        {imageUrl && imageUrl.length > 0 ? (
          <>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={imageUrl}
              alt="Tour cover"
              className="absolute inset-0 w-full h-full object-cover"
            />
            <div className="absolute inset-0 bg-black/40 opacity-0 hover:opacity-100 transition-opacity flex items-center justify-center">
              <div className="text-white text-center">
                <Upload className="h-8 w-8 mx-auto mb-2" />
                <p className="font-medium">Click or drag to replace</p>
              </div>
            </div>
          </>
        ) : (
          <div className="absolute inset-0 flex flex-col items-center justify-center text-muted-foreground">
            {isUploading ? (
              <>
                <Loader2 className="h-10 w-10 animate-spin mb-2" />
                <p className="font-medium">Uploading...</p>
              </>
            ) : (
              <>
                <ImageIcon className="h-10 w-10 mb-2" />
                <p className="font-medium">
                  {isDragActive ? 'Drop image here' : 'Click or drag image to upload'}
                </p>
                <p className="text-sm mt-1">
                  Recommended: 1920x1080 (16:9 ratio)
                </p>
              </>
            )}
          </div>
        )}
      </div>

      {/* Crop Dialog */}
      <Dialog open={showCropDialog} onOpenChange={setShowCropDialog}>
        <DialogContent className="max-w-3xl">
          <DialogHeader>
            <DialogTitle>Crop Image</DialogTitle>
            <DialogDescription>
              Adjust the crop area to fit a 16:9 aspect ratio for the cover image.
            </DialogDescription>
          </DialogHeader>

          {previewUrl && (
            <div className="max-h-[60vh] overflow-auto">
              <ReactCrop
                crop={crop}
                onChange={(_, percentCrop) => setCrop(percentCrop)}
                onComplete={(c) => setCompletedCrop(c)}
                aspect={ASPECT_RATIO}
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  ref={imgRef}
                  alt="Crop preview"
                  src={previewUrl}
                  onLoad={onImageLoad}
                  className="max-w-full"
                />
              </ReactCrop>
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={handleCancel}>
              Cancel
            </Button>
            <Button onClick={handleCropComplete} disabled={!completedCrop}>
              Apply Crop
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
