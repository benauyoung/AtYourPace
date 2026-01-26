'use client';

import { useState } from 'react';
import { Wand2, Loader2, AlertCircle, CheckCircle2 } from 'lucide-react';
import { httpsCallable } from 'firebase/functions';
import { functions } from '@/lib/firebase/config';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Progress } from '@/components/ui/progress';
import { VoiceSelector } from './voice-selector';
import { AudioPlayer } from './audio-player';
import { getDefaultVoice } from '@/lib/elevenlabs/voices';
import { cn } from '@/lib/utils';

const MAX_TEXT_LENGTH = 5000;

interface AudioGeneratorProps {
  tourId: string;
  stopId: string;
  initialText?: string;
  onGenerationComplete?: (audioUrl: string) => void;
  className?: string;
}

interface GenerateAudioResponse {
  audioUrl: string;
}

export function AudioGenerator({
  tourId,
  stopId,
  initialText = '',
  onGenerationComplete,
  className,
}: AudioGeneratorProps) {
  const [text, setText] = useState(initialText);
  const [voiceId, setVoiceId] = useState(getDefaultVoice().id);
  const [isGenerating, setIsGenerating] = useState(false);
  const [progress, setProgress] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [generatedAudioUrl, setGeneratedAudioUrl] = useState<string | null>(null);

  const characterCount = text.length;
  const isOverLimit = characterCount > MAX_TEXT_LENGTH;
  const isEmpty = text.trim().length === 0;

  const handleGenerate = async () => {
    if (isEmpty || isOverLimit || isGenerating) return;

    setIsGenerating(true);
    setError(null);
    setProgress(10);

    try {
      // Simulate progress while waiting for API
      const progressInterval = setInterval(() => {
        setProgress((prev) => Math.min(prev + 5, 90));
      }, 500);

      // Call the Cloud Function
      const generateAudio = httpsCallable<
        { text: string; voiceId: string; tourId: string; stopId: string },
        GenerateAudioResponse
      >(functions, 'generateElevenLabsAudio');

      const result = await generateAudio({
        text,
        voiceId,
        tourId,
        stopId,
      });

      clearInterval(progressInterval);
      setProgress(100);

      const { audioUrl } = result.data;
      setGeneratedAudioUrl(audioUrl);
      onGenerationComplete?.(audioUrl);
    } catch (err) {
      setProgress(0);

      // Handle Firebase function errors
      if (err && typeof err === 'object' && 'code' in err) {
        const firebaseError = err as { code: string; message: string };

        switch (firebaseError.code) {
          case 'functions/resource-exhausted':
            setError(
              'Rate limit reached. Please wait 1 minute between audio generation requests.'
            );
            break;
          case 'functions/unauthenticated':
            setError('You must be signed in to generate audio.');
            break;
          case 'functions/permission-denied':
            setError('You do not have permission to generate audio for this tour.');
            break;
          default:
            setError(firebaseError.message || 'Failed to generate audio. Please try again.');
        }
      } else {
        setError('Failed to generate audio. Please try again.');
      }
    } finally {
      setIsGenerating(false);
    }
  };

  const handleUseAudio = () => {
    if (generatedAudioUrl && onGenerationComplete) {
      onGenerationComplete(generatedAudioUrl);
    }
  };

  const handleReset = () => {
    setGeneratedAudioUrl(null);
    setProgress(0);
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

      {generatedAudioUrl ? (
        <div className="space-y-4">
          <Alert>
            <CheckCircle2 className="h-4 w-4 text-green-600" />
            <AlertDescription>
              Audio generated successfully! Preview it below.
            </AlertDescription>
          </Alert>

          <AudioPlayer src={generatedAudioUrl} />

          <div className="flex gap-2">
            <Button variant="outline" onClick={handleReset}>
              Generate New
            </Button>
            {onGenerationComplete && (
              <Button onClick={handleUseAudio}>
                Use This Audio
              </Button>
            )}
          </div>
        </div>
      ) : (
        <>
          {/* Script input */}
          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <Label htmlFor="script">Narration Script</Label>
              <span
                className={cn(
                  'text-xs',
                  isOverLimit ? 'text-destructive' : 'text-muted-foreground'
                )}
              >
                {characterCount.toLocaleString()} / {MAX_TEXT_LENGTH.toLocaleString()}
              </span>
            </div>
            <Textarea
              id="script"
              placeholder="Enter the narration text for this stop. This will be converted to speech using AI..."
              value={text}
              onChange={(e) => setText(e.target.value)}
              className={cn('min-h-[150px]', isOverLimit && 'border-destructive')}
              disabled={isGenerating}
            />
            {isOverLimit && (
              <p className="text-xs text-destructive">
                Text exceeds maximum length. Please shorten your script.
              </p>
            )}
          </div>

          {/* Voice selector */}
          <div className="space-y-2">
            <Label>AI Voice</Label>
            <VoiceSelector
              value={voiceId}
              onValueChange={setVoiceId}
              disabled={isGenerating}
            />
          </div>

          {/* Progress indicator */}
          {isGenerating && (
            <div className="space-y-2">
              <div className="flex items-center justify-between text-sm">
                <span className="text-muted-foreground">Generating audio...</span>
                <span className="font-medium">{Math.round(progress)}%</span>
              </div>
              <Progress value={progress} className="h-2" />
              <p className="text-xs text-muted-foreground">
                This may take up to 30 seconds depending on the length of your script.
              </p>
            </div>
          )}

          {/* Generate button */}
          <Button
            onClick={handleGenerate}
            disabled={isEmpty || isOverLimit || isGenerating}
            className="w-full gap-2"
          >
            {isGenerating ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Generating...
              </>
            ) : (
              <>
                <Wand2 className="h-4 w-4" />
                Generate AI Narration
              </>
            )}
          </Button>

          <p className="text-xs text-center text-muted-foreground">
            AI audio generation is rate-limited to 1 request per minute.
          </p>
        </>
      )}
    </div>
  );
}
