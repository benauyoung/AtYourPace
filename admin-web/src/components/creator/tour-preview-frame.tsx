'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import {
  ChevronLeft,
  ChevronRight,
  Play,
  Pause,
  MapPin,
  Clock,
  Route,
  Image as ImageIcon,
  Volume2,
  VolumeX,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { cn } from '@/lib/utils';
import { TourVersionModel, StopModel, categoryDisplayNames } from '@/types';

interface TourPreviewFrameProps {
  tour: TourVersionModel;
  stops: StopModel[];
  category?: string;
  className?: string;
}

export function TourPreviewFrame({
  tour,
  stops,
  category = 'other',
  className,
}: TourPreviewFrameProps) {
  const [currentStopIndex, setCurrentStopIndex] = useState(0);
  const [isPlaying, setIsPlaying] = useState(false);
  const [isMuted, setIsMuted] = useState(false);
  const [audioProgress, setAudioProgress] = useState(0);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const audioRef = useRef<HTMLAudioElement | null>(null);

  const sortedStops = [...stops].sort((a, b) => a.order - b.order);
  const currentStop = sortedStops[currentStopIndex];
  const hasNext = currentStopIndex < sortedStops.length - 1;
  const hasPrev = currentStopIndex > 0;

  // Reset image index when stop changes
  useEffect(() => {
    setCurrentImageIndex(0);
    setAudioProgress(0);
    setIsPlaying(false);
  }, [currentStopIndex]);

  // Handle audio playback
  useEffect(() => {
    if (!audioRef.current) return;

    if (isPlaying) {
      audioRef.current.play().catch(() => setIsPlaying(false));
    } else {
      audioRef.current.pause();
    }
  }, [isPlaying]);

  // Update audio progress
  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    const updateProgress = () => {
      if (audio.duration) {
        setAudioProgress((audio.currentTime / audio.duration) * 100);
      }
    };

    const handleEnded = () => {
      setIsPlaying(false);
      setAudioProgress(0);
    };

    audio.addEventListener('timeupdate', updateProgress);
    audio.addEventListener('ended', handleEnded);

    return () => {
      audio.removeEventListener('timeupdate', updateProgress);
      audio.removeEventListener('ended', handleEnded);
    };
  }, [currentStop]);

  const goToNextStop = useCallback(() => {
    if (hasNext) {
      setCurrentStopIndex((i) => i + 1);
    }
  }, [hasNext]);

  const goToPrevStop = useCallback(() => {
    if (hasPrev) {
      setCurrentStopIndex((i) => i - 1);
    }
  }, [hasPrev]);

  const togglePlayback = () => {
    if (currentStop?.media.audioUrl) {
      setIsPlaying(!isPlaying);
    }
  };

  const sortedImages = currentStop?.media.images
    ? [...currentStop.media.images].sort((a, b) => a.order - b.order)
    : [];

  const formatDuration = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  if (stops.length === 0) {
    return (
      <div className={cn('flex flex-col h-full bg-white dark:bg-gray-950', className)}>
        <div className="flex-1 flex items-center justify-center p-6 text-center">
          <div className="text-muted-foreground">
            <MapPin className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p className="font-medium">No stops added yet</p>
            <p className="text-sm mt-1">Add stops to preview your tour</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={cn('flex flex-col h-full bg-white dark:bg-gray-950 overflow-hidden', className)}>
      {/* Hidden audio element */}
      {currentStop?.media.audioUrl && (
        <audio
          ref={audioRef}
          src={currentStop.media.audioUrl}
          muted={isMuted}
        />
      )}

      {/* Tour header */}
      <div className="flex-shrink-0 p-4 border-b border-gray-200 dark:border-gray-800">
        <div className="flex items-center gap-2 mb-2">
          <span className="text-xs px-2 py-0.5 rounded-full bg-primary/10 text-primary font-medium">
            {categoryDisplayNames[category as keyof typeof categoryDisplayNames] || category}
          </span>
        </div>
        <h1 className="font-bold text-lg leading-tight line-clamp-2">
          {tour.title || 'Untitled Tour'}
        </h1>
        <div className="flex items-center gap-4 mt-2 text-sm text-muted-foreground">
          {tour.duration && (
            <span className="flex items-center gap-1">
              <Clock className="h-3.5 w-3.5" />
              {tour.duration}
            </span>
          )}
          {tour.distance && (
            <span className="flex items-center gap-1">
              <Route className="h-3.5 w-3.5" />
              {tour.distance}
            </span>
          )}
          <span className="flex items-center gap-1">
            <MapPin className="h-3.5 w-3.5" />
            {sortedStops.length} stop{sortedStops.length !== 1 ? 's' : ''}
          </span>
        </div>
      </div>

      {/* Stop progress indicator */}
      <div className="flex-shrink-0 px-4 py-2 border-b border-gray-200 dark:border-gray-800">
        <div className="flex items-center gap-2">
          {sortedStops.map((_, index) => (
            <button
              key={index}
              onClick={() => setCurrentStopIndex(index)}
              aria-label={`Go to stop ${index + 1}`}
              aria-current={index === currentStopIndex ? 'step' : undefined}
              className={cn(
                'flex-1 h-1.5 rounded-full transition-colors',
                index === currentStopIndex
                  ? 'bg-primary'
                  : index < currentStopIndex
                  ? 'bg-primary/50'
                  : 'bg-gray-200 dark:bg-gray-700'
              )}
            />
          ))}
        </div>
        <p className="text-xs text-muted-foreground mt-1.5 text-center">
          Stop {currentStopIndex + 1} of {sortedStops.length}
        </p>
      </div>

      {/* Stop content */}
      <div className="flex-1 overflow-y-auto">
        {/* Stop images */}
        {sortedImages.length > 0 ? (
          <div className="relative aspect-video bg-gray-100 dark:bg-gray-800">
            <img
              src={sortedImages[currentImageIndex]?.url}
              alt={sortedImages[currentImageIndex]?.caption || currentStop?.name || 'Stop image'}
              className="w-full h-full object-cover"
            />
            {sortedImages.length > 1 && (
              <>
                <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex items-center gap-1.5">
                  {sortedImages.map((_, index) => (
                    <button
                      key={index}
                      onClick={() => setCurrentImageIndex(index)}
                      aria-label={`View image ${index + 1}`}
                      aria-current={index === currentImageIndex ? 'true' : undefined}
                      className={cn(
                        'w-2 h-2 rounded-full transition-colors',
                        index === currentImageIndex
                          ? 'bg-white'
                          : 'bg-white/50'
                      )}
                    />
                  ))}
                </div>
                {currentImageIndex > 0 && (
                  <button
                    onClick={() => setCurrentImageIndex((i) => i - 1)}
                    aria-label="Previous image"
                    className="absolute left-2 top-1/2 -translate-y-1/2 p-1.5 rounded-full bg-black/50 text-white"
                  >
                    <ChevronLeft className="h-4 w-4" aria-hidden="true" />
                  </button>
                )}
                {currentImageIndex < sortedImages.length - 1 && (
                  <button
                    onClick={() => setCurrentImageIndex((i) => i + 1)}
                    aria-label="Next image"
                    className="absolute right-2 top-1/2 -translate-y-1/2 p-1.5 rounded-full bg-black/50 text-white"
                  >
                    <ChevronRight className="h-4 w-4" aria-hidden="true" />
                  </button>
                )}
              </>
            )}
          </div>
        ) : (
          <div className="aspect-video bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
            <ImageIcon className="h-12 w-12 text-gray-400" />
          </div>
        )}

        {/* Stop info */}
        <div className="p-4">
          <h2 className="font-semibold text-lg">{currentStop?.name || `Stop ${currentStopIndex + 1}`}</h2>
          <p className="mt-2 text-sm text-muted-foreground leading-relaxed">
            {currentStop?.description || 'No description provided.'}
          </p>
        </div>
      </div>

      {/* Audio player */}
      <div className="flex-shrink-0 border-t border-gray-200 dark:border-gray-800 p-3 bg-gray-50 dark:bg-gray-900">
        {currentStop?.media.audioUrl ? (
          <div className="space-y-2">
            <div className="flex items-center gap-3">
              <Button
                size="icon"
                variant="ghost"
                className="h-10 w-10"
                onClick={togglePlayback}
                aria-label={isPlaying ? 'Pause audio' : 'Play audio'}
              >
                {isPlaying ? (
                  <Pause className="h-5 w-5" aria-hidden="true" />
                ) : (
                  <Play className="h-5 w-5" aria-hidden="true" />
                )}
              </Button>
              <div className="flex-1">
                <Progress value={audioProgress} className="h-1.5" aria-label="Audio progress" />
              </div>
              <Button
                size="icon"
                variant="ghost"
                className="h-8 w-8"
                onClick={() => setIsMuted(!isMuted)}
                aria-label={isMuted ? 'Unmute audio' : 'Mute audio'}
                aria-pressed={isMuted}
              >
                {isMuted ? (
                  <VolumeX className="h-4 w-4" aria-hidden="true" />
                ) : (
                  <Volume2 className="h-4 w-4" aria-hidden="true" />
                )}
              </Button>
            </div>
            {currentStop.media.audioDuration && (
              <p className="text-xs text-muted-foreground text-center">
                {formatDuration(audioRef.current?.currentTime || 0)} / {formatDuration(currentStop.media.audioDuration)}
              </p>
            )}
          </div>
        ) : (
          <div className="text-center text-sm text-muted-foreground py-2">
            <Volume2 className="h-4 w-4 inline mr-2 opacity-50" />
            No audio for this stop
          </div>
        )}
      </div>

      {/* Navigation */}
      <div className="flex-shrink-0 flex items-center justify-between p-3 border-t border-gray-200 dark:border-gray-800">
        <Button
          variant="ghost"
          size="sm"
          onClick={goToPrevStop}
          disabled={!hasPrev}
        >
          <ChevronLeft className="h-4 w-4 mr-1" />
          Previous
        </Button>
        <Button
          variant="ghost"
          size="sm"
          onClick={goToNextStop}
          disabled={!hasNext}
        >
          Next
          <ChevronRight className="h-4 w-4 ml-1" />
        </Button>
      </div>
    </div>
  );
}
