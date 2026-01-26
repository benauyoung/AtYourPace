'use client';

import { Mic, Square, Pause, Play, RotateCcw, AlertCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Progress } from '@/components/ui/progress';
import { WaveformVisualizer } from './waveform-visualizer';
import {
  useAudioRecording,
  formatDuration,
  getRemainingTime,
} from '@/hooks/use-audio-recording';
import { cn } from '@/lib/utils';

interface AudioRecorderProps {
  maxDuration?: number; // seconds
  onRecordingComplete?: (blob: Blob, url: string) => void;
  className?: string;
}

export function AudioRecorder({
  maxDuration = 300, // 5 minutes
  onRecordingComplete,
  className,
}: AudioRecorderProps) {
  const {
    isRecording,
    isPaused,
    duration,
    audioBlob,
    audioUrl,
    error,
    startRecording,
    stopRecording,
    pauseRecording,
    resumeRecording,
    resetRecording,
    analyserNode,
    isSupported,
  } = useAudioRecording({
    maxDuration,
    onMaxDurationReached: () => {
      // Will automatically stop and trigger onRecordingComplete
    },
  });

  // Notify parent when recording is complete
  const handleStopRecording = () => {
    stopRecording();
  };

  // Handle using the recorded audio
  const handleUseRecording = () => {
    if (audioBlob && audioUrl && onRecordingComplete) {
      onRecordingComplete(audioBlob, audioUrl);
    }
  };

  const progressPercent = (duration / maxDuration) * 100;

  if (!isSupported) {
    return (
      <Alert variant="destructive" className={className}>
        <AlertCircle className="h-4 w-4" />
        <AlertDescription>
          Audio recording is not supported in this browser. Please use a modern
          browser like Chrome, Firefox, or Safari.
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <div className={cn('space-y-4', className)}>
      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {/* Waveform / Recording Area */}
      <div className="relative rounded-lg border bg-muted/30 p-4">
        {isRecording ? (
          <>
            {/* Live waveform */}
            <WaveformVisualizer
              analyser={analyserNode}
              isActive={isRecording && !isPaused}
              className="h-20 rounded"
            />

            {/* Duration and remaining time */}
            <div className="mt-3 flex items-center justify-between text-sm">
              <span className="font-mono text-lg font-semibold">
                {formatDuration(duration)}
              </span>
              <span className="text-muted-foreground">
                {getRemainingTime(duration, maxDuration)} remaining
              </span>
            </div>

            {/* Progress bar */}
            <Progress value={progressPercent} className="mt-2 h-1" />
          </>
        ) : audioUrl ? (
          <>
            {/* Recorded audio preview */}
            <div className="flex flex-col items-center justify-center py-4">
              <div className="mb-2 text-2xl font-semibold">
                {formatDuration(duration)}
              </div>
              <audio src={audioUrl} controls className="w-full max-w-md" />
            </div>
          </>
        ) : (
          /* Initial state */
          <div className="flex flex-col items-center justify-center py-8 text-center">
            <div className="mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
              <Mic className="h-8 w-8 text-primary" />
            </div>
            <p className="font-medium">Ready to record</p>
            <p className="mt-1 text-sm text-muted-foreground">
              Maximum duration: {formatDuration(maxDuration)}
            </p>
          </div>
        )}
      </div>

      {/* Controls */}
      <div className="flex items-center justify-center gap-3">
        {!isRecording && !audioUrl && (
          <Button
            size="lg"
            onClick={startRecording}
            className="gap-2"
          >
            <Mic className="h-5 w-5" />
            Start Recording
          </Button>
        )}

        {isRecording && (
          <>
            {isPaused ? (
              <Button
                size="lg"
                variant="outline"
                onClick={resumeRecording}
                className="gap-2"
              >
                <Play className="h-5 w-5" />
                Resume
              </Button>
            ) : (
              <Button
                size="lg"
                variant="outline"
                onClick={pauseRecording}
                className="gap-2"
              >
                <Pause className="h-5 w-5" />
                Pause
              </Button>
            )}

            <Button
              size="lg"
              variant="destructive"
              onClick={handleStopRecording}
              className="gap-2"
            >
              <Square className="h-5 w-5" />
              Stop
            </Button>
          </>
        )}

        {audioUrl && (
          <>
            <Button
              size="lg"
              variant="outline"
              onClick={resetRecording}
              className="gap-2"
            >
              <RotateCcw className="h-5 w-5" />
              Re-record
            </Button>

            {onRecordingComplete && (
              <Button
                size="lg"
                onClick={handleUseRecording}
                className="gap-2"
              >
                Use Recording
              </Button>
            )}
          </>
        )}
      </div>

      {/* Recording indicator */}
      {isRecording && !isPaused && (
        <div className="flex items-center justify-center gap-2 text-sm text-destructive">
          <span className="h-2 w-2 animate-pulse rounded-full bg-destructive" />
          Recording...
        </div>
      )}

      {isRecording && isPaused && (
        <div className="flex items-center justify-center gap-2 text-sm text-muted-foreground">
          <span className="h-2 w-2 rounded-full bg-muted-foreground" />
          Paused
        </div>
      )}
    </div>
  );
}
