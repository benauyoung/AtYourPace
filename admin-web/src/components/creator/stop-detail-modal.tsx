'use client';

import { useEffect, useState, useRef } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { MapPin, Save, Loader2, Volume2, Mic, Upload, Play, Pause, X, Sparkles, ImageIcon } from 'lucide-react';
import { StopModel, StopImage, AudioSource } from '@/types';
import { uploadStopAudioBlob } from '@/lib/firebase/creator-stops';
import { StopImagesPanel } from './stop-images-panel';
import {
  DEFAULT_TRIGGER_RADIUS,
  MIN_TRIGGER_RADIUS,
  MAX_TRIGGER_RADIUS,
} from '@/lib/mapbox/config';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Slider } from '@/components/ui/slider';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs';
import { ElevenLabsVoice } from '@/lib/elevenlabs';

const stopFormSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100, 'Name must be less than 100 characters'),
  description: z.string().max(1000, 'Description must be less than 1000 characters').optional(),
  triggerRadius: z.number().min(MIN_TRIGGER_RADIUS).max(MAX_TRIGGER_RADIUS),
  audioScript: z.string().max(5000, 'Script must be less than 5000 characters').optional(),
});

type StopFormValues = z.infer<typeof stopFormSchema>;

interface StopDetailModalProps {
  stop: StopModel | null;
  isOpen: boolean;
  onClose: () => void;
  onSave: (stopId: string, data: Partial<StopFormValues> & { audioUrl?: string | null; audioSource?: AudioSource; audioText?: string | null }) => Promise<void>;
  isSaving?: boolean;
  onImageUpload?: (file: File, order: number) => Promise<string>;
  onImageDelete?: (imageUrl: string) => Promise<void>;
  onImagesReorder?: (images: StopImage[]) => Promise<void>;
}

export function StopDetailModal({
  stop,
  isOpen,
  onClose,
  onSave,
  isSaving,
  onImageUpload,
  onImageDelete,
  onImagesReorder,
}: StopDetailModalProps) {
  const [showImagesPanel, setShowImagesPanel] = useState(false);
  const form = useForm<StopFormValues>({
    resolver: zodResolver(stopFormSchema),
    defaultValues: {
      name: '',
      description: '',
      triggerRadius: DEFAULT_TRIGGER_RADIUS,
      audioScript: '',
    },
  });

  // Audio state
  const [voices, setVoices] = useState<ElevenLabsVoice[]>([]);
  const [selectedVoiceId, setSelectedVoiceId] = useState<string>('');
  const [isLoadingVoices, setIsLoadingVoices] = useState(false);
  const [isGenerating, setIsGenerating] = useState(false);
  const [generatedAudioUrl, setGeneratedAudioUrl] = useState<string | null>(null);
  const [existingAudioUrl, setExistingAudioUrl] = useState<string | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [audioError, setAudioError] = useState<string | null>(null);
  const [isRecording, setIsRecording] = useState(false);
  const [recordedAudioUrl, setRecordedAudioUrl] = useState<string | null>(null);
  const [uploadedAudioUrl, setUploadedAudioUrl] = useState<string | null>(null);
  const [activeAudioTab, setActiveAudioTab] = useState<'script' | 'upload' | 'record'>('script');
  const [generatedAudioBlob, setGeneratedAudioBlob] = useState<Blob | null>(null);
  const [recordedAudioBlob, setRecordedAudioBlob] = useState<Blob | null>(null);
  const [uploadedAudioFile, setUploadedAudioFile] = useState<File | null>(null);
  const [isUploadingAudio, setIsUploadingAudio] = useState(false);

  const audioRef = useRef<HTMLAudioElement | null>(null);
  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Fetch voices on mount
  useEffect(() => {
    if (isOpen && voices.length === 0) {
      fetchVoices();
    }
  }, [isOpen, voices.length]);

  // Update form when stop changes
  useEffect(() => {
    if (stop) {
      form.reset({
        name: stop.name,
        description: stop.description || '',
        triggerRadius: stop.triggerRadius,
        audioScript: stop.media?.audioText || '',
      });
      setExistingAudioUrl(stop.media?.audioUrl || null);
      setGeneratedAudioUrl(null);
      setRecordedAudioUrl(null);
      setUploadedAudioUrl(null);
      setGeneratedAudioBlob(null);
      setRecordedAudioBlob(null);
      setUploadedAudioFile(null);
    }
  }, [stop, form]);

  // Cleanup audio URLs on unmount
  useEffect(() => {
    return () => {
      if (generatedAudioUrl?.startsWith('blob:')) {
        URL.revokeObjectURL(generatedAudioUrl);
      }
      if (recordedAudioUrl?.startsWith('blob:')) {
        URL.revokeObjectURL(recordedAudioUrl);
      }
      if (uploadedAudioUrl?.startsWith('blob:')) {
        URL.revokeObjectURL(uploadedAudioUrl);
      }
    };
  }, [generatedAudioUrl, recordedAudioUrl, uploadedAudioUrl]);

  const fetchVoices = async () => {
    setIsLoadingVoices(true);
    setAudioError(null);
    try {
      const response = await fetch('/api/generate-audio');
      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error || 'Failed to fetch voices');
      }
      const data = await response.json();
      setVoices(data.voices || []);
      // Select first voice by default
      if (data.voices?.length > 0 && !selectedVoiceId) {
        setSelectedVoiceId(data.voices[0].voice_id);
      }
    } catch (error) {
      console.error('Error fetching voices:', error);
      setAudioError(error instanceof Error ? error.message : 'Failed to load voices');
    } finally {
      setIsLoadingVoices(false);
    }
  };

  const handleGenerateAudio = async () => {
    const script = form.getValues('audioScript');
    if (!script?.trim()) {
      setAudioError('Please enter a script to generate audio');
      return;
    }
    if (!selectedVoiceId) {
      setAudioError('Please select a voice');
      return;
    }

    setIsGenerating(true);
    setAudioError(null);

    try {
      const response = await fetch('/api/generate-audio', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          text: script,
          voiceId: selectedVoiceId,
        }),
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error || 'Failed to generate audio');
      }

      const data = await response.json();

      // Convert base64 to blob URL for preview
      const binaryString = atob(data.audio);
      const bytes = new Uint8Array(binaryString.length);
      for (let i = 0; i < binaryString.length; i++) {
        bytes[i] = binaryString.charCodeAt(i);
      }
      const blob = new Blob([bytes], { type: data.contentType });
      const url = URL.createObjectURL(blob);

      // Cleanup old URL
      if (generatedAudioUrl?.startsWith('blob:')) {
        URL.revokeObjectURL(generatedAudioUrl);
      }

      setGeneratedAudioBlob(blob);
      setGeneratedAudioUrl(url);
    } catch (error) {
      console.error('Error generating audio:', error);
      setAudioError(error instanceof Error ? error.message : 'Failed to generate audio');
    } finally {
      setIsGenerating(false);
    }
  };

  const getCurrentAudioUrl = () => {
    switch (activeAudioTab) {
      case 'script':
        return generatedAudioUrl || existingAudioUrl;
      case 'upload':
        return uploadedAudioUrl;
      case 'record':
        return recordedAudioUrl;
      default:
        return null;
    }
  };

  const handlePlayPause = () => {
    const url = getCurrentAudioUrl();
    if (!url) return;

    if (!audioRef.current) {
      audioRef.current = new Audio(url);
      audioRef.current.onended = () => setIsPlaying(false);
    } else if (audioRef.current.src !== url) {
      audioRef.current.src = url;
    }

    if (isPlaying) {
      audioRef.current.pause();
      setIsPlaying(false);
    } else {
      audioRef.current.play();
      setIsPlaying(true);
    }
  };

  const handleStartRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const mediaRecorder = new MediaRecorder(stream);
      mediaRecorderRef.current = mediaRecorder;
      chunksRef.current = [];

      mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) {
          chunksRef.current.push(e.data);
        }
      };

      mediaRecorder.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: 'audio/webm' });
        const url = URL.createObjectURL(blob);

        // Cleanup old URL
        if (recordedAudioUrl?.startsWith('blob:')) {
          URL.revokeObjectURL(recordedAudioUrl);
        }

        setRecordedAudioBlob(blob);
        setRecordedAudioUrl(url);
        stream.getTracks().forEach((track) => track.stop());
      };

      mediaRecorder.start();
      setIsRecording(true);
    } catch (error) {
      console.error('Error starting recording:', error);
      setAudioError('Failed to access microphone. Please check permissions.');
    }
  };

  const handleStopRecording = () => {
    if (mediaRecorderRef.current && isRecording) {
      mediaRecorderRef.current.stop();
      setIsRecording(false);
    }
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    // Validate file type
    if (!file.type.startsWith('audio/')) {
      setAudioError('Please select an audio file');
      return;
    }

    // Validate file size (max 10MB)
    if (file.size > 10 * 1024 * 1024) {
      setAudioError('File size must be less than 10MB');
      return;
    }

    const url = URL.createObjectURL(file);

    // Cleanup old URL
    if (uploadedAudioUrl?.startsWith('blob:')) {
      URL.revokeObjectURL(uploadedAudioUrl);
    }

    setUploadedAudioFile(file);
    setUploadedAudioUrl(url);
    setAudioError(null);
  };

  const handleClearAudio = () => {
    switch (activeAudioTab) {
      case 'script':
        if (generatedAudioUrl?.startsWith('blob:')) {
          URL.revokeObjectURL(generatedAudioUrl);
        }
        setGeneratedAudioUrl(null);
        setGeneratedAudioBlob(null);
        break;
      case 'upload':
        if (uploadedAudioUrl?.startsWith('blob:')) {
          URL.revokeObjectURL(uploadedAudioUrl);
        }
        setUploadedAudioUrl(null);
        setUploadedAudioFile(null);
        if (fileInputRef.current) {
          fileInputRef.current.value = '';
        }
        break;
      case 'record':
        if (recordedAudioUrl?.startsWith('blob:')) {
          URL.revokeObjectURL(recordedAudioUrl);
        }
        setRecordedAudioUrl(null);
        setRecordedAudioBlob(null);
        break;
    }
    if (audioRef.current) {
      audioRef.current.pause();
      setIsPlaying(false);
    }
  };

  const handleSubmit = async (data: StopFormValues) => {
    if (!stop) return;

    setIsUploadingAudio(true);
    try {
      let audioUrl: string | null | undefined;
      let audioSource: AudioSource | undefined;

      // Determine which blob to upload based on active tab
      const currentBlob: Blob | null =
        activeAudioTab === 'script' ? generatedAudioBlob
        : activeAudioTab === 'record' ? recordedAudioBlob
        : uploadedAudioFile;
      const currentBlobUrl = getCurrentAudioUrl();

      if (currentBlob) {
        // Upload blob to Firebase Storage
        audioUrl = await uploadStopAudioBlob(
          stop.tourId,
          stop.id,
          currentBlob,
          activeAudioTab === 'script' ? 'elevenlabs'
            : activeAudioTab === 'record' ? 'recorded'
            : 'uploaded'
        );
        audioSource = activeAudioTab === 'script' ? 'elevenlabs'
          : activeAudioTab === 'record' ? 'recorded'
          : 'uploaded';
      } else if (currentBlobUrl && !currentBlobUrl.startsWith('blob:')) {
        // Existing permanent URL — keep it
        audioUrl = currentBlobUrl;
      }

      await onSave(stop.id, {
        ...data,
        audioUrl,
        audioSource,
        audioText: activeAudioTab === 'script' ? (data.audioScript || null) : undefined,
      });
      onClose();
    } catch (error) {
      console.error('Error saving stop:', error);
      setAudioError(error instanceof Error ? error.message : 'Failed to upload audio');
    } finally {
      setIsUploadingAudio(false);
    }
  };

  const triggerRadius = form.watch('triggerRadius');
  const audioScript = form.watch('audioScript');
  const currentAudioUrl = getCurrentAudioUrl();

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-[600px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <MapPin className="h-5 w-5" />
            Edit Stop
          </DialogTitle>
          <DialogDescription>
            Update the stop details and audio narration.
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Stop Name</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g., Golden Gate Bridge Viewpoint" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Description</FormLabel>
                  <FormControl>
                    <Textarea
                      placeholder="Describe what visitors will see or do at this stop..."
                      className="min-h-[80px]"
                      {...field}
                    />
                  </FormControl>
                  <FormDescription>
                    Optional. This will be shown to users when they arrive at this stop.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="triggerRadius"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Trigger Radius: {triggerRadius}m</FormLabel>
                  <FormControl>
                    <Slider
                      min={MIN_TRIGGER_RADIUS}
                      max={MAX_TRIGGER_RADIUS}
                      step={10}
                      value={[field.value]}
                      onValueChange={(v) => field.onChange(v[0])}
                    />
                  </FormControl>
                  <FormDescription>
                    How close users need to be for the audio to play automatically.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            {/* Audio Section */}
            <div className="space-y-3 rounded-lg border p-4">
              <div className="flex items-center gap-2">
                <Volume2 className="h-4 w-4" />
                <span className="font-medium">Audio Narration</span>
              </div>

              <Tabs value={activeAudioTab} onValueChange={(v) => setActiveAudioTab(v as typeof activeAudioTab)}>
                <TabsList className="grid w-full grid-cols-3">
                  <TabsTrigger value="script" className="flex items-center gap-1">
                    <Sparkles className="h-3 w-3" />
                    Generate
                  </TabsTrigger>
                  <TabsTrigger value="upload" className="flex items-center gap-1">
                    <Upload className="h-3 w-3" />
                    Upload
                  </TabsTrigger>
                  <TabsTrigger value="record" className="flex items-center gap-1">
                    <Mic className="h-3 w-3" />
                    Record
                  </TabsTrigger>
                </TabsList>

                <TabsContent value="script" className="space-y-3 mt-3">
                  <FormField
                    control={form.control}
                    name="audioScript"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Script for AI Voice</FormLabel>
                        <FormControl>
                          <Textarea
                            placeholder="Write what the AI narrator should say at this stop..."
                            className="min-h-[100px]"
                            {...field}
                          />
                        </FormControl>
                        <FormDescription>
                          {audioScript?.length || 0}/5000 characters
                        </FormDescription>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <div className="flex gap-2">
                    <Select
                      value={selectedVoiceId}
                      onValueChange={setSelectedVoiceId}
                      disabled={isLoadingVoices}
                    >
                      <SelectTrigger className="flex-1">
                        <SelectValue placeholder={isLoadingVoices ? 'Loading voices...' : 'Select a voice'} />
                      </SelectTrigger>
                      <SelectContent>
                        {voices.map((voice) => (
                          <SelectItem key={voice.voice_id} value={voice.voice_id}>
                            {voice.name}
                            {voice.labels?.accent && ` (${voice.labels.accent})`}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>

                    <Button
                      type="button"
                      onClick={handleGenerateAudio}
                      disabled={isGenerating || !audioScript?.trim() || !selectedVoiceId}
                    >
                      {isGenerating ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                      ) : (
                        <Sparkles className="h-4 w-4" />
                      )}
                      <span className="ml-2">{isGenerating ? 'Generating...' : 'Generate'}</span>
                    </Button>
                  </div>
                </TabsContent>

                <TabsContent value="upload" className="space-y-3 mt-3">
                  <div className="flex flex-col gap-2">
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="audio/*"
                      onChange={handleFileUpload}
                      className="hidden"
                    />
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => fileInputRef.current?.click()}
                      className="w-full"
                    >
                      <Upload className="mr-2 h-4 w-4" />
                      Choose Audio File
                    </Button>
                    <p className="text-xs text-muted-foreground text-center">
                      Supports MP3, WAV, M4A (max 10MB)
                    </p>
                  </div>
                </TabsContent>

                <TabsContent value="record" className="space-y-3 mt-3">
                  <div className="flex flex-col items-center gap-3">
                    {isRecording ? (
                      <Button
                        type="button"
                        variant="destructive"
                        onClick={handleStopRecording}
                        className="w-full"
                      >
                        <div className="mr-2 h-3 w-3 rounded-full bg-white animate-pulse" />
                        Stop Recording
                      </Button>
                    ) : (
                      <Button
                        type="button"
                        variant="outline"
                        onClick={handleStartRecording}
                        className="w-full"
                      >
                        <Mic className="mr-2 h-4 w-4" />
                        Start Recording
                      </Button>
                    )}
                    <p className="text-xs text-muted-foreground text-center">
                      Click to record your own narration
                    </p>
                  </div>
                </TabsContent>
              </Tabs>

              {/* Audio Error */}
              {audioError && (
                <div className="rounded-md bg-destructive/10 p-2 text-sm text-destructive">
                  {audioError}
                </div>
              )}

              {/* Audio Preview */}
              {currentAudioUrl && (
                <div className="flex items-center gap-2 rounded-md bg-muted p-2">
                  <Button
                    type="button"
                    size="icon"
                    variant="ghost"
                    onClick={handlePlayPause}
                  >
                    {isPlaying ? (
                      <Pause className="h-4 w-4" />
                    ) : (
                      <Play className="h-4 w-4" />
                    )}
                  </Button>
                  <div className="flex-1 text-sm text-muted-foreground">
                    {isPlaying ? 'Playing...' : 'Audio ready'}
                  </div>
                  <Button
                    type="button"
                    size="icon"
                    variant="ghost"
                    onClick={handleClearAudio}
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              )}
            </div>

            {/* Images Section */}
            {stop && onImageUpload && onImageDelete && onImagesReorder && (
              <div className="rounded-lg border p-3">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm font-medium flex items-center gap-2">
                    <ImageIcon className="h-4 w-4" />
                    Images ({stop.media?.images?.length || 0})
                  </span>
                  <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    onClick={() => setShowImagesPanel(true)}
                  >
                    {(stop.media?.images?.length || 0) > 0 ? 'Edit Images' : 'Add Images'}
                  </Button>
                </div>
                {(stop.media?.images?.length || 0) > 0 ? (
                  <div className="grid grid-cols-4 gap-1">
                    {stop.media.images.slice(0, 4).map((image, index) => (
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
                    {stop.media.images.length > 4 && (
                      <div className="aspect-square rounded bg-muted flex items-center justify-center">
                        <span className="text-sm text-muted-foreground">
                          +{stop.media.images.length - 4}
                        </span>
                      </div>
                    )}
                  </div>
                ) : (
                  <p className="text-sm text-muted-foreground">
                    No images added yet. Click &quot;Add Images&quot; to upload photos for this stop.
                  </p>
                )}
              </div>
            )}

            {/* Location info (read-only) */}
            {stop && (
              <div className="rounded-lg bg-muted p-3 text-sm">
                <p className="font-medium mb-1">Location</p>
                <p className="text-muted-foreground">
                  {stop.location.latitude.toFixed(6)}, {stop.location.longitude.toFixed(6)}
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  Drag the marker on the map to change the location.
                </p>
              </div>
            )}

            <DialogFooter>
              <Button type="button" variant="outline" onClick={onClose}>
                Cancel
              </Button>
              <Button type="submit" disabled={isSaving || isUploadingAudio}>
                {isUploadingAudio ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Uploading Audio...
                  </>
                ) : isSaving ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <Save className="mr-2 h-4 w-4" />
                    Save Changes
                  </>
                )}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>

      {/* Images Panel Modal */}
      {stop && onImageUpload && onImageDelete && onImagesReorder && (
        <StopImagesPanel
          stopName={stop.name}
          images={stop.media?.images || []}
          onImageUpload={onImageUpload}
          onImageDelete={onImageDelete}
          onImagesReorder={onImagesReorder}
          isOpen={showImagesPanel}
          onClose={() => setShowImagesPanel(false)}
        />
      )}
    </Dialog>
  );
}
