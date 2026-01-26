'use client';

import { useState } from 'react';
import { Mic, Upload, Wand2, Trash2, Volume2 } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
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
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { AudioRecorder } from './audio-recorder';
import { AudioUploader } from './audio-uploader';
import { AudioGenerator } from './audio-generator';
import { AudioPlayer } from './audio-player';
import { cn } from '@/lib/utils';
import { AudioSource } from '@/types';

interface StopAudioPanelProps {
  tourId: string;
  stopId: string;
  stopName: string;
  currentAudioUrl?: string | null;
  currentAudioSource?: AudioSource;
  onAudioSave: (audioBlob: Blob | null, source: AudioSource) => Promise<void>;
  onAudioUrlSave?: (audioUrl: string, source: AudioSource) => Promise<void>;
  isOpen: boolean;
  onClose: () => void;
  isSaving?: boolean;
}

export function StopAudioPanel({
  tourId,
  stopId,
  stopName,
  currentAudioUrl,
  currentAudioSource,
  onAudioSave,
  onAudioUrlSave,
  isOpen,
  onClose,
  isSaving = false,
}: StopAudioPanelProps) {
  const [activeTab, setActiveTab] = useState<string>('record');
  const [pendingAudio, setPendingAudio] = useState<{
    blob?: Blob;
    url: string;
    source: AudioSource;
  } | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  const hasExistingAudio = !!currentAudioUrl;
  const hasPendingAudio = !!pendingAudio;

  // Handle recording complete
  const handleRecordingComplete = (blob: Blob, url: string) => {
    setPendingAudio({ blob, url, source: 'recorded' });
  };

  // Handle file upload complete
  const handleUploadComplete = (file: File, url: string) => {
    // Convert File to Blob (File extends Blob)
    setPendingAudio({ blob: file, url, source: 'uploaded' });
  };

  // Handle AI generation complete
  const handleGenerationComplete = (audioUrl: string) => {
    setPendingAudio({ url: audioUrl, source: 'elevenlabs' });
  };

  // Save the pending audio
  const handleSave = async () => {
    if (!pendingAudio) return;

    if (pendingAudio.blob) {
      await onAudioSave(pendingAudio.blob, pendingAudio.source);
    } else if (pendingAudio.url && onAudioUrlSave) {
      // For AI-generated audio, the URL is already a Firebase Storage URL
      await onAudioUrlSave(pendingAudio.url, pendingAudio.source);
    }

    setPendingAudio(null);
    onClose();
  };

  // Delete existing audio
  const handleDeleteAudio = async () => {
    await onAudioSave(null, 'recorded');
    setShowDeleteConfirm(false);
  };

  // Cancel and close
  const handleCancel = () => {
    setPendingAudio(null);
    onClose();
  };

  return (
    <>
      <Dialog open={isOpen} onOpenChange={(open) => !open && handleCancel()}>
        <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Volume2 className="h-5 w-5" />
              Audio for &quot;{stopName}&quot;
            </DialogTitle>
            <DialogDescription>
              Record, upload, or generate AI narration for this stop.
            </DialogDescription>
          </DialogHeader>

          {/* Current audio preview */}
          {hasExistingAudio && !hasPendingAudio && (
            <div className="rounded-lg border bg-muted/30 p-4">
              <div className="mb-2 flex items-center justify-between">
                <span className="text-sm font-medium">Current Audio</span>
                <span className="text-xs text-muted-foreground capitalize">
                  Source: {currentAudioSource || 'Unknown'}
                </span>
              </div>
              <AudioPlayer src={currentAudioUrl} compact />
              <Button
                variant="ghost"
                size="sm"
                className="mt-2 text-destructive hover:text-destructive"
                onClick={() => setShowDeleteConfirm(true)}
              >
                <Trash2 className="mr-2 h-4 w-4" />
                Remove Audio
              </Button>
            </div>
          )}

          {/* Pending audio preview */}
          {hasPendingAudio && (
            <div className="rounded-lg border border-primary bg-primary/5 p-4">
              <div className="mb-2 flex items-center justify-between">
                <span className="text-sm font-medium text-primary">New Audio (Unsaved)</span>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setPendingAudio(null)}
                >
                  Clear
                </Button>
              </div>
              <AudioPlayer src={pendingAudio.url} compact />
            </div>
          )}

          {/* Audio input tabs */}
          <Tabs value={activeTab} onValueChange={setActiveTab} className="mt-4">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="record" className="gap-2">
                <Mic className="h-4 w-4" />
                <span className="hidden sm:inline">Record</span>
              </TabsTrigger>
              <TabsTrigger value="upload" className="gap-2">
                <Upload className="h-4 w-4" />
                <span className="hidden sm:inline">Upload</span>
              </TabsTrigger>
              <TabsTrigger value="ai" className="gap-2">
                <Wand2 className="h-4 w-4" />
                <span className="hidden sm:inline">AI Generate</span>
              </TabsTrigger>
            </TabsList>

            <TabsContent value="record" className="mt-4">
              <AudioRecorder
                maxDuration={300}
                onRecordingComplete={handleRecordingComplete}
              />
            </TabsContent>

            <TabsContent value="upload" className="mt-4">
              <AudioUploader onUploadComplete={handleUploadComplete} />
            </TabsContent>

            <TabsContent value="ai" className="mt-4">
              <AudioGenerator
                tourId={tourId}
                stopId={stopId}
                onGenerationComplete={handleGenerationComplete}
              />
            </TabsContent>
          </Tabs>

          <DialogFooter className="mt-6">
            <Button variant="outline" onClick={handleCancel} disabled={isSaving}>
              Cancel
            </Button>
            <Button
              onClick={handleSave}
              disabled={!hasPendingAudio || isSaving}
            >
              {isSaving ? 'Saving...' : 'Save Audio'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete confirmation */}
      <AlertDialog open={showDeleteConfirm} onOpenChange={setShowDeleteConfirm}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Remove Audio</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to remove the audio for &quot;{stopName}&quot;?
              This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleDeleteAudio}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Remove
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}

// Compact version for inline use
interface StopAudioInlineProps {
  audioUrl?: string | null;
  audioSource?: AudioSource;
  onEditClick: () => void;
  className?: string;
}

export function StopAudioInline({
  audioUrl,
  audioSource,
  onEditClick,
  className,
}: StopAudioInlineProps) {
  const hasAudio = !!audioUrl;

  return (
    <div className={cn('rounded-lg border p-3', className)}>
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm font-medium flex items-center gap-2">
          <Volume2 className="h-4 w-4" />
          Audio
        </span>
        <Button size="sm" variant="outline" onClick={onEditClick}>
          {hasAudio ? 'Edit' : 'Add Audio'}
        </Button>
      </div>

      {hasAudio ? (
        <>
          <AudioPlayer src={audioUrl} compact />
          <p className="mt-2 text-xs text-muted-foreground capitalize">
            Source: {audioSource || 'Unknown'}
          </p>
        </>
      ) : (
        <p className="text-sm text-muted-foreground">
          No audio added yet. Click &quot;Add Audio&quot; to record, upload, or generate narration.
        </p>
      )}
    </div>
  );
}
