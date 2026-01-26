'use client';

import { useRef, useState, useEffect, useCallback } from 'react';
import { Play, Pause, RotateCcw, Volume2, VolumeX } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Slider } from '@/components/ui/slider';
import { StaticWaveform } from './waveform-visualizer';
import { formatDuration } from '@/hooks/use-audio-recording';
import { cn } from '@/lib/utils';

interface AudioPlayerProps {
  src: string | null;
  onDelete?: () => void;
  showDelete?: boolean;
  compact?: boolean;
  className?: string;
}

export function AudioPlayer({
  src,
  onDelete,
  showDelete = false,
  compact = false,
  className,
}: AudioPlayerProps) {
  const audioRef = useRef<HTMLAudioElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(1);
  const [isMuted, setIsMuted] = useState(false);

  // Update current time
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const handleTimeUpdate = () => setCurrentTime(audio.currentTime);
    const handleDurationChange = () => setDuration(audio.duration || 0);
    const handleEnded = () => setIsPlaying(false);
    const handlePlay = () => setIsPlaying(true);
    const handlePause = () => setIsPlaying(false);

    audio.addEventListener('timeupdate', handleTimeUpdate);
    audio.addEventListener('durationchange', handleDurationChange);
    audio.addEventListener('loadedmetadata', handleDurationChange);
    audio.addEventListener('ended', handleEnded);
    audio.addEventListener('play', handlePlay);
    audio.addEventListener('pause', handlePause);

    return () => {
      audio.removeEventListener('timeupdate', handleTimeUpdate);
      audio.removeEventListener('durationchange', handleDurationChange);
      audio.removeEventListener('loadedmetadata', handleDurationChange);
      audio.removeEventListener('ended', handleEnded);
      audio.removeEventListener('play', handlePlay);
      audio.removeEventListener('pause', handlePause);
    };
  }, [src]);

  // Reset when src changes
  useEffect(() => {
    setCurrentTime(0);
    setIsPlaying(false);
    if (audioRef.current) {
      audioRef.current.load();
    }
  }, [src]);

  const togglePlay = useCallback(() => {
    const audio = audioRef.current;
    if (!audio) return;

    if (isPlaying) {
      audio.pause();
    } else {
      audio.play();
    }
  }, [isPlaying]);

  const handleSeek = useCallback((value: number[]) => {
    const audio = audioRef.current;
    if (!audio) return;

    audio.currentTime = value[0];
    setCurrentTime(value[0]);
  }, []);

  const handleWaveformClick = useCallback((progress: number) => {
    const audio = audioRef.current;
    if (!audio || !duration) return;

    const newTime = progress * duration;
    audio.currentTime = newTime;
    setCurrentTime(newTime);
  }, [duration]);

  const handleVolumeChange = useCallback((value: number[]) => {
    const audio = audioRef.current;
    if (!audio) return;

    const newVolume = value[0];
    audio.volume = newVolume;
    setVolume(newVolume);
    setIsMuted(newVolume === 0);
  }, []);

  const toggleMute = useCallback(() => {
    const audio = audioRef.current;
    if (!audio) return;

    if (isMuted) {
      audio.volume = volume || 0.5;
      setIsMuted(false);
    } else {
      audio.volume = 0;
      setIsMuted(true);
    }
  }, [isMuted, volume]);

  const restart = useCallback(() => {
    const audio = audioRef.current;
    if (!audio) return;

    audio.currentTime = 0;
    setCurrentTime(0);
  }, []);

  const progress = duration > 0 ? currentTime / duration : 0;

  if (!src) {
    return null;
  }

  if (compact) {
    return (
      <div className={cn('flex items-center gap-2', className)}>
        <audio ref={audioRef} src={src} preload="metadata" />

        <Button
          size="icon"
          variant="ghost"
          className="h-8 w-8"
          onClick={togglePlay}
        >
          {isPlaying ? (
            <Pause className="h-4 w-4" />
          ) : (
            <Play className="h-4 w-4" />
          )}
        </Button>

        <Slider
          value={[currentTime]}
          max={duration || 100}
          step={0.1}
          onValueChange={handleSeek}
          className="flex-1"
        />

        <span className="min-w-[4rem] text-xs text-muted-foreground font-mono">
          {formatDuration(Math.floor(currentTime))} / {formatDuration(Math.floor(duration))}
        </span>

        {showDelete && onDelete && (
          <Button
            size="icon"
            variant="ghost"
            className="h-8 w-8 text-destructive hover:text-destructive"
            onClick={onDelete}
          >
            <RotateCcw className="h-4 w-4" />
          </Button>
        )}
      </div>
    );
  }

  return (
    <div className={cn('space-y-3', className)}>
      <audio ref={audioRef} src={src} preload="metadata" />

      {/* Waveform */}
      <StaticWaveform
        audioUrl={src}
        progress={progress}
        onClick={handleWaveformClick}
        className="h-16 rounded-lg"
      />

      {/* Controls */}
      <div className="flex items-center gap-3">
        {/* Play/Pause */}
        <Button
          size="icon"
          variant="outline"
          className="h-10 w-10"
          onClick={togglePlay}
        >
          {isPlaying ? (
            <Pause className="h-5 w-5" />
          ) : (
            <Play className="h-5 w-5" />
          )}
        </Button>

        {/* Restart */}
        <Button
          size="icon"
          variant="ghost"
          className="h-8 w-8"
          onClick={restart}
        >
          <RotateCcw className="h-4 w-4" />
        </Button>

        {/* Time display */}
        <div className="flex-1 text-sm font-mono">
          <span>{formatDuration(Math.floor(currentTime))}</span>
          <span className="text-muted-foreground"> / </span>
          <span className="text-muted-foreground">
            {formatDuration(Math.floor(duration))}
          </span>
        </div>

        {/* Volume */}
        <div className="flex items-center gap-2">
          <Button
            size="icon"
            variant="ghost"
            className="h-8 w-8"
            onClick={toggleMute}
          >
            {isMuted ? (
              <VolumeX className="h-4 w-4" />
            ) : (
              <Volume2 className="h-4 w-4" />
            )}
          </Button>
          <Slider
            value={[isMuted ? 0 : volume]}
            max={1}
            step={0.01}
            onValueChange={handleVolumeChange}
            className="w-20"
          />
        </div>

        {/* Delete */}
        {showDelete && onDelete && (
          <Button
            size="sm"
            variant="ghost"
            className="text-destructive hover:text-destructive"
            onClick={onDelete}
          >
            Remove
          </Button>
        )}
      </div>
    </div>
  );
}
