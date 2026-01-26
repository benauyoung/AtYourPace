'use client';

import { useState, useRef, useCallback, useEffect } from 'react';

export interface AudioRecordingState {
  isRecording: boolean;
  isPaused: boolean;
  duration: number;
  audioBlob: Blob | null;
  audioUrl: string | null;
  error: string | null;
}

export interface UseAudioRecordingOptions {
  maxDuration?: number; // in seconds, default 300 (5 minutes)
  mimeType?: string;
  onMaxDurationReached?: () => void;
}

export interface UseAudioRecordingReturn extends AudioRecordingState {
  startRecording: () => Promise<void>;
  stopRecording: () => void;
  pauseRecording: () => void;
  resumeRecording: () => void;
  resetRecording: () => void;
  analyserNode: AnalyserNode | null;
  isSupported: boolean;
}

const DEFAULT_MAX_DURATION = 300; // 5 minutes in seconds

export function useAudioRecording(
  options: UseAudioRecordingOptions = {}
): UseAudioRecordingReturn {
  const {
    maxDuration = DEFAULT_MAX_DURATION,
    mimeType = 'audio/webm;codecs=opus',
    onMaxDurationReached,
  } = options;

  const [state, setState] = useState<AudioRecordingState>({
    isRecording: false,
    isPaused: false,
    duration: 0,
    audioBlob: null,
    audioUrl: null,
    error: null,
  });

  const mediaRecorderRef = useRef<MediaRecorder | null>(null);
  const audioChunksRef = useRef<Blob[]>([]);
  const streamRef = useRef<MediaStream | null>(null);
  const analyserRef = useRef<AnalyserNode | null>(null);
  const audioContextRef = useRef<AudioContext | null>(null);
  const timerRef = useRef<NodeJS.Timeout | null>(null);
  const startTimeRef = useRef<number>(0);
  const pausedDurationRef = useRef<number>(0);

  // Check if MediaRecorder is supported
  const isSupported = typeof window !== 'undefined' && 'MediaRecorder' in window;

  // Get supported MIME type
  const getSupportedMimeType = useCallback(() => {
    if (typeof MediaRecorder === 'undefined') return null;

    const types = [
      mimeType,
      'audio/webm;codecs=opus',
      'audio/webm',
      'audio/mp4',
      'audio/ogg;codecs=opus',
      'audio/ogg',
    ];

    for (const type of types) {
      if (MediaRecorder.isTypeSupported(type)) {
        return type;
      }
    }
    return null;
  }, [mimeType]);

  // Start recording
  const startRecording = useCallback(async () => {
    if (!isSupported) {
      setState((prev) => ({
        ...prev,
        error: 'Audio recording is not supported in this browser',
      }));
      return;
    }

    try {
      // Request microphone access
      const stream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      });

      streamRef.current = stream;
      audioChunksRef.current = [];

      // Set up audio context and analyser for visualization
      const audioContext = new AudioContext();
      const analyser = audioContext.createAnalyser();
      analyser.fftSize = 256;
      const source = audioContext.createMediaStreamSource(stream);
      source.connect(analyser);

      audioContextRef.current = audioContext;
      analyserRef.current = analyser;

      // Get supported MIME type
      const supportedType = getSupportedMimeType();
      if (!supportedType) {
        throw new Error('No supported audio MIME type found');
      }

      // Create MediaRecorder
      const mediaRecorder = new MediaRecorder(stream, {
        mimeType: supportedType,
      });

      mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          audioChunksRef.current.push(event.data);
        }
      };

      mediaRecorder.onstop = () => {
        const audioBlob = new Blob(audioChunksRef.current, {
          type: supportedType,
        });
        const audioUrl = URL.createObjectURL(audioBlob);

        setState((prev) => ({
          ...prev,
          isRecording: false,
          isPaused: false,
          audioBlob,
          audioUrl,
        }));

        // Stop all tracks
        stream.getTracks().forEach((track) => track.stop());

        // Close audio context
        if (audioContextRef.current) {
          audioContextRef.current.close();
          audioContextRef.current = null;
        }
        analyserRef.current = null;
      };

      mediaRecorderRef.current = mediaRecorder;
      mediaRecorder.start(100); // Collect data every 100ms

      // Start duration timer
      startTimeRef.current = Date.now();
      pausedDurationRef.current = 0;

      timerRef.current = setInterval(() => {
        const elapsed = Math.floor(
          (Date.now() - startTimeRef.current + pausedDurationRef.current) / 1000
        );

        if (elapsed >= maxDuration) {
          stopRecording();
          onMaxDurationReached?.();
        } else {
          setState((prev) => ({
            ...prev,
            duration: elapsed,
          }));
        }
      }, 100);

      setState({
        isRecording: true,
        isPaused: false,
        duration: 0,
        audioBlob: null,
        audioUrl: null,
        error: null,
      });
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : 'Failed to start recording';

      setState((prev) => ({
        ...prev,
        error: message.includes('Permission denied')
          ? 'Microphone access denied. Please allow microphone access in your browser settings.'
          : message,
      }));
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isSupported, maxDuration, getSupportedMimeType, onMaxDurationReached]);

  // Stop recording
  const stopRecording = useCallback(() => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }

    if (
      mediaRecorderRef.current &&
      mediaRecorderRef.current.state !== 'inactive'
    ) {
      mediaRecorderRef.current.stop();
    }
  }, []);

  // Pause recording
  const pauseRecording = useCallback(() => {
    if (
      mediaRecorderRef.current &&
      mediaRecorderRef.current.state === 'recording'
    ) {
      mediaRecorderRef.current.pause();
      pausedDurationRef.current += Date.now() - startTimeRef.current;

      if (timerRef.current) {
        clearInterval(timerRef.current);
        timerRef.current = null;
      }

      setState((prev) => ({
        ...prev,
        isPaused: true,
      }));
    }
  }, []);

  // Resume recording
  const resumeRecording = useCallback(() => {
    if (
      mediaRecorderRef.current &&
      mediaRecorderRef.current.state === 'paused'
    ) {
      mediaRecorderRef.current.resume();
      startTimeRef.current = Date.now();

      timerRef.current = setInterval(() => {
        const elapsed = Math.floor(
          (Date.now() - startTimeRef.current + pausedDurationRef.current) / 1000
        );

        if (elapsed >= maxDuration) {
          stopRecording();
          onMaxDurationReached?.();
        } else {
          setState((prev) => ({
            ...prev,
            duration: elapsed,
          }));
        }
      }, 100);

      setState((prev) => ({
        ...prev,
        isPaused: false,
      }));
    }
  }, [maxDuration, stopRecording, onMaxDurationReached]);

  // Reset recording
  const resetRecording = useCallback(() => {
    // Clean up existing recording
    if (state.audioUrl) {
      URL.revokeObjectURL(state.audioUrl);
    }

    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }

    if (streamRef.current) {
      streamRef.current.getTracks().forEach((track) => track.stop());
      streamRef.current = null;
    }

    if (audioContextRef.current) {
      audioContextRef.current.close();
      audioContextRef.current = null;
    }

    mediaRecorderRef.current = null;
    analyserRef.current = null;
    audioChunksRef.current = [];
    pausedDurationRef.current = 0;

    setState({
      isRecording: false,
      isPaused: false,
      duration: 0,
      audioBlob: null,
      audioUrl: null,
      error: null,
    });
  }, [state.audioUrl]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timerRef.current) {
        clearInterval(timerRef.current);
      }
      if (streamRef.current) {
        streamRef.current.getTracks().forEach((track) => track.stop());
      }
      if (audioContextRef.current) {
        audioContextRef.current.close();
      }
      if (state.audioUrl) {
        URL.revokeObjectURL(state.audioUrl);
      }
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return {
    ...state,
    startRecording,
    stopRecording,
    pauseRecording,
    resumeRecording,
    resetRecording,
    analyserNode: analyserRef.current,
    isSupported,
  };
}

// Helper function to format duration
export function formatDuration(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

// Helper function to get remaining time
export function getRemainingTime(
  currentDuration: number,
  maxDuration: number
): string {
  const remaining = maxDuration - currentDuration;
  return formatDuration(Math.max(0, remaining));
}
