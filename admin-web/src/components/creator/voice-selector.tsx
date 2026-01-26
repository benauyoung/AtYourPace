'use client';

import { useState, useRef } from 'react';
import { Play, Pause, Volume2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  ElevenLabsVoice,
  getVoiceById,
  getGroupedVoices,
} from '@/lib/elevenlabs/voices';
import { cn } from '@/lib/utils';

interface VoiceSelectorProps {
  value?: string;
  onValueChange?: (voiceId: string) => void;
  disabled?: boolean;
  className?: string;
}

export function VoiceSelector({
  value,
  onValueChange,
  disabled = false,
  className,
}: VoiceSelectorProps) {
  const selectedVoice = value ? getVoiceById(value) : undefined;
  const groupedVoices = getGroupedVoices();

  return (
    <Select value={value} onValueChange={onValueChange} disabled={disabled}>
      <SelectTrigger className={cn('w-full', className)}>
        <SelectValue placeholder="Select a voice">
          {selectedVoice && (
            <div className="flex items-center gap-2">
              <Volume2 className="h-4 w-4 text-muted-foreground" />
              <span>{selectedVoice.name}</span>
              <span className="text-muted-foreground">
                ({selectedVoice.accent})
              </span>
            </div>
          )}
        </SelectValue>
      </SelectTrigger>
      <SelectContent>
        {Object.entries(groupedVoices).map(([category, voices]) =>
          voices.length > 0 ? (
            <SelectGroup key={category}>
              <SelectLabel>{category} Voices</SelectLabel>
              {voices.map((voice) => (
                <SelectItem key={voice.id} value={voice.id}>
                  <div className="flex flex-col">
                    <span className="font-medium">{voice.name}</span>
                    <span className="text-xs text-muted-foreground">
                      {voice.accent} &bull; {voice.style}
                    </span>
                  </div>
                </SelectItem>
              ))}
            </SelectGroup>
          ) : null
        )}
      </SelectContent>
    </Select>
  );
}

// Detailed voice selector with preview capability
interface VoiceSelectorWithPreviewProps {
  value?: string;
  onValueChange?: (voiceId: string) => void;
  disabled?: boolean;
  className?: string;
  previewText?: string;
}

export function VoiceSelectorWithPreview({
  value,
  onValueChange,
  disabled = false,
  className,
}: VoiceSelectorWithPreviewProps) {
  const [playingVoice, setPlayingVoice] = useState<string | null>(null);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  const selectedVoice = value ? getVoiceById(value) : undefined;
  const groupedVoices = getGroupedVoices();

  // Note: Preview would require calling the ElevenLabs API
  // For now, this is a placeholder that could be implemented
  // by adding preview URLs to the voice list or calling a function
  const handlePreview = async (voice: ElevenLabsVoice) => {
    if (playingVoice === voice.id) {
      // Stop playing
      audioRef.current?.pause();
      setPlayingVoice(null);
      return;
    }

    // In a real implementation, you would either:
    // 1. Use pre-recorded preview audio URLs
    // 2. Call a cloud function to generate a short preview
    // For now, we just select the voice
    setPlayingVoice(null);
    onValueChange?.(voice.id);
  };

  return (
    <div className={cn('space-y-3', className)}>
      <audio ref={audioRef} onEnded={() => setPlayingVoice(null)} />

      <div className="grid gap-2">
        {Object.entries(groupedVoices).map(([category, voices]) =>
          voices.length > 0 ? (
            <div key={category}>
              <h4 className="mb-2 text-sm font-medium text-muted-foreground">
                {category} Voices
              </h4>
              <div className="grid gap-2">
                {voices.map((voice) => (
                  <button
                    key={voice.id}
                    type="button"
                    disabled={disabled}
                    onClick={() => onValueChange?.(voice.id)}
                    className={cn(
                      'flex items-center justify-between rounded-lg border p-3 text-left transition-colors',
                      'hover:bg-muted/50',
                      value === voice.id && 'border-primary bg-primary/5',
                      disabled && 'opacity-50 cursor-not-allowed'
                    )}
                  >
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <span className="font-medium">{voice.name}</span>
                        <span className="text-xs text-muted-foreground">
                          {voice.accent}
                        </span>
                      </div>
                      <p className="mt-0.5 text-sm text-muted-foreground">
                        {voice.description}
                      </p>
                    </div>
                    <Button
                      size="icon"
                      variant="ghost"
                      className="ml-2 h-8 w-8"
                      onClick={(e) => {
                        e.stopPropagation();
                        handlePreview(voice);
                      }}
                      disabled={disabled}
                    >
                      {playingVoice === voice.id ? (
                        <Pause className="h-4 w-4" />
                      ) : (
                        <Play className="h-4 w-4" />
                      )}
                    </Button>
                  </button>
                ))}
              </div>
            </div>
          ) : null
        )}
      </div>

      {selectedVoice && (
        <div className="rounded-lg bg-muted/50 p-3 text-sm">
          <p className="font-medium">Selected: {selectedVoice.name}</p>
          <p className="text-muted-foreground">
            {selectedVoice.description} &bull; {selectedVoice.style} style
          </p>
        </div>
      )}
    </div>
  );
}
