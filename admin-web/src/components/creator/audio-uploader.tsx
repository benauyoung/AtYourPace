'use client';

import { useState, useCallback } from 'react';
import { useDropzone } from 'react-dropzone';
import { Upload, Music, AlertCircle, X, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { AudioPlayer } from './audio-player';
import { cn } from '@/lib/utils';

const ACCEPTED_AUDIO_TYPES = {
  'audio/mpeg': ['.mp3'],
  'audio/wav': ['.wav'],
  'audio/x-m4a': ['.m4a'],
  'audio/mp4': ['.m4a'],
  'audio/webm': ['.webm'],
  'audio/ogg': ['.ogg'],
};

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50MB
const MAX_DURATION = 300; // 5 minutes in seconds

interface AudioUploaderProps {
  onUploadComplete?: (file: File, url: string) => void;
  onFileSelect?: (file: File) => void;
  uploadProgress?: number;
  isUploading?: boolean;
  className?: string;
}

export function AudioUploader({
  onUploadComplete,
  onFileSelect,
  uploadProgress = 0,
  isUploading = false,
  className,
}: AudioUploaderProps) {
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [audioDuration, setAudioDuration] = useState<number | null>(null);
  const [isValidating, setIsValidating] = useState(false);

  const validateAudioDuration = useCallback((file: File): Promise<number> => {
    return new Promise((resolve, reject) => {
      const audio = new Audio();
      audio.onloadedmetadata = () => {
        URL.revokeObjectURL(audio.src);
        resolve(audio.duration);
      };
      audio.onerror = () => {
        URL.revokeObjectURL(audio.src);
        reject(new Error('Failed to load audio file'));
      };
      audio.src = URL.createObjectURL(file);
    });
  }, []);

  const onDrop = useCallback(
    async (acceptedFiles: File[]) => {
      setError(null);

      const file = acceptedFiles[0];
      if (!file) return;

      // Validate file size
      if (file.size > MAX_FILE_SIZE) {
        setError(`File too large. Maximum size is ${MAX_FILE_SIZE / 1024 / 1024}MB.`);
        return;
      }

      setIsValidating(true);

      try {
        // Validate audio duration
        const duration = await validateAudioDuration(file);

        if (duration > MAX_DURATION) {
          setError(
            `Audio too long. Maximum duration is ${Math.floor(MAX_DURATION / 60)} minutes. Your file is ${Math.floor(duration / 60)}:${Math.floor(duration % 60).toString().padStart(2, '0')}.`
          );
          setIsValidating(false);
          return;
        }

        setAudioDuration(duration);

        // Clean up previous preview
        if (previewUrl) {
          URL.revokeObjectURL(previewUrl);
        }

        // Create preview URL
        const url = URL.createObjectURL(file);
        setPreviewUrl(url);
        setSelectedFile(file);

        // Notify parent
        onFileSelect?.(file);
      } catch {
        setError('Failed to process audio file. Please try a different file.');
      } finally {
        setIsValidating(false);
      }
    },
    [previewUrl, onFileSelect, validateAudioDuration]
  );

  const { getRootProps, getInputProps, isDragActive, open } = useDropzone({
    onDrop,
    accept: ACCEPTED_AUDIO_TYPES,
    maxFiles: 1,
    disabled: isUploading || isValidating,
    noClick: !!selectedFile,
    noKeyboard: !!selectedFile,
  });

  const clearSelection = useCallback(() => {
    if (previewUrl) {
      URL.revokeObjectURL(previewUrl);
    }
    setSelectedFile(null);
    setPreviewUrl(null);
    setAudioDuration(null);
    setError(null);
  }, [previewUrl]);

  const handleUpload = useCallback(() => {
    if (selectedFile && previewUrl && onUploadComplete) {
      onUploadComplete(selectedFile, previewUrl);
    }
  }, [selectedFile, previewUrl, onUploadComplete]);

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
          !selectedFile && !isUploading && 'hover:border-primary/50 cursor-pointer',
          (isUploading || isValidating) && 'opacity-50 pointer-events-none'
        )}
      >
        <input {...getInputProps()} />

        {selectedFile && previewUrl ? (
          <div className="p-4">
            {/* File info header */}
            <div className="mb-3 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Music className="h-5 w-5 text-primary" />
                <div>
                  <p className="font-medium truncate max-w-[200px]">
                    {selectedFile.name}
                  </p>
                  <p className="text-xs text-muted-foreground">
                    {(selectedFile.size / 1024 / 1024).toFixed(2)} MB
                    {audioDuration && (
                      <> &bull; {Math.floor(audioDuration / 60)}:{Math.floor(audioDuration % 60).toString().padStart(2, '0')}</>
                    )}
                  </p>
                </div>
              </div>

              {!isUploading && (
                <Button
                  size="icon"
                  variant="ghost"
                  className="h-8 w-8"
                  onClick={(e) => {
                    e.stopPropagation();
                    clearSelection();
                  }}
                >
                  <X className="h-4 w-4" />
                </Button>
              )}
            </div>

            {/* Audio preview */}
            <AudioPlayer src={previewUrl} compact className="mb-3" />

            {/* Upload progress or button */}
            {isUploading ? (
              <div className="space-y-2">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-muted-foreground">Uploading...</span>
                  <span className="font-medium">{Math.round(uploadProgress)}%</span>
                </div>
                <Progress value={uploadProgress} className="h-2" />
              </div>
            ) : (
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={(e) => {
                    e.stopPropagation();
                    open();
                  }}
                >
                  Choose Different
                </Button>
                {onUploadComplete && (
                  <Button size="sm" onClick={handleUpload}>
                    Use This Audio
                  </Button>
                )}
              </div>
            )}
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center p-8 text-center">
            {isValidating ? (
              <>
                <Loader2 className="mb-4 h-10 w-10 animate-spin text-muted-foreground" />
                <p className="text-muted-foreground">Validating audio file...</p>
              </>
            ) : (
              <>
                <Upload className="mb-4 h-10 w-10 text-muted-foreground" />
                <p className="font-medium">
                  {isDragActive ? 'Drop audio file here' : 'Drag & drop audio file'}
                </p>
                <p className="mt-1 text-sm text-muted-foreground">
                  or click to browse
                </p>
                <p className="mt-3 text-xs text-muted-foreground">
                  Supports MP3, WAV, M4A (max 5 min, 50MB)
                </p>
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
