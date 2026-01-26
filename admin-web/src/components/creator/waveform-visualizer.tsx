'use client';

import { useRef, useEffect, useCallback } from 'react';
import { cn } from '@/lib/utils';

interface WaveformVisualizerProps {
  analyser: AnalyserNode | null;
  isActive?: boolean;
  barColor?: string;
  backgroundColor?: string;
  className?: string;
  barWidth?: number;
  barGap?: number;
  barRadius?: number;
  smoothing?: number;
}

export function WaveformVisualizer({
  analyser,
  isActive = false,
  barColor = 'hsl(var(--primary))',
  backgroundColor = 'transparent',
  className,
  barWidth = 3,
  barGap = 2,
  barRadius = 1.5,
  smoothing = 0.5,
}: WaveformVisualizerProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const animationRef = useRef<number | null>(null);
  const previousDataRef = useRef<Uint8Array | null>(null);

  const draw = useCallback(() => {
    const canvas = canvasRef.current;
    const ctx = canvas?.getContext('2d');
    if (!canvas || !ctx || !analyser) return;

    const bufferLength = analyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    analyser.getByteFrequencyData(dataArray);

    // Apply smoothing
    if (previousDataRef.current) {
      for (let i = 0; i < bufferLength; i++) {
        dataArray[i] = Math.round(
          previousDataRef.current[i] * smoothing +
            dataArray[i] * (1 - smoothing)
        );
      }
    }
    previousDataRef.current = new Uint8Array(dataArray);

    // Clear canvas
    ctx.fillStyle = backgroundColor;
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Calculate number of bars that fit
    const totalBarWidth = barWidth + barGap;
    const barCount = Math.floor(canvas.width / totalBarWidth);

    // Sample the data to match bar count
    const step = Math.floor(bufferLength / barCount);

    ctx.fillStyle = barColor;

    for (let i = 0; i < barCount; i++) {
      // Get average value for this bar
      let sum = 0;
      for (let j = 0; j < step; j++) {
        sum += dataArray[i * step + j] || 0;
      }
      const average = sum / step;

      // Calculate bar height (min 2px for visibility)
      const barHeight = Math.max(2, (average / 255) * canvas.height * 0.9);
      const x = i * totalBarWidth;
      const y = (canvas.height - barHeight) / 2;

      // Draw rounded bar
      ctx.beginPath();
      ctx.roundRect(x, y, barWidth, barHeight, barRadius);
      ctx.fill();
    }

    if (isActive) {
      animationRef.current = requestAnimationFrame(draw);
    }
  }, [analyser, isActive, barColor, backgroundColor, barWidth, barGap, barRadius, smoothing]);

  useEffect(() => {
    if (isActive && analyser) {
      draw();
    }

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
    };
  }, [isActive, analyser, draw]);

  // Handle canvas resize
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const resizeObserver = new ResizeObserver(() => {
      const rect = canvas.getBoundingClientRect();
      canvas.width = rect.width * window.devicePixelRatio;
      canvas.height = rect.height * window.devicePixelRatio;
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
      }
    });

    resizeObserver.observe(canvas);
    return () => resizeObserver.disconnect();
  }, []);

  return (
    <canvas
      ref={canvasRef}
      className={cn('w-full h-16', className)}
      style={{ backgroundColor }}
    />
  );
}

// Static waveform for displaying recorded audio
interface StaticWaveformProps {
  audioUrl: string | null;
  progress?: number; // 0-1
  barColor?: string;
  progressColor?: string;
  backgroundColor?: string;
  className?: string;
  barWidth?: number;
  barGap?: number;
  barRadius?: number;
  onClick?: (progress: number) => void;
}

export function StaticWaveform({
  audioUrl,
  progress = 0,
  barColor = 'hsl(var(--muted-foreground) / 0.3)',
  progressColor = 'hsl(var(--primary))',
  backgroundColor = 'transparent',
  className,
  barWidth = 3,
  barGap = 2,
  barRadius = 1.5,
  onClick,
}: StaticWaveformProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const waveformDataRef = useRef<number[]>([]);

  // Generate waveform data from audio
  useEffect(() => {
    if (!audioUrl) {
      waveformDataRef.current = [];
      return;
    }

    const audioContext = new AudioContext();

    fetch(audioUrl)
      .then((response) => response.arrayBuffer())
      .then((arrayBuffer) => audioContext.decodeAudioData(arrayBuffer))
      .then((audioBuffer) => {
        const rawData = audioBuffer.getChannelData(0);
        const samples = 100; // Number of bars
        const blockSize = Math.floor(rawData.length / samples);
        const filteredData: number[] = [];

        for (let i = 0; i < samples; i++) {
          let sum = 0;
          for (let j = 0; j < blockSize; j++) {
            sum += Math.abs(rawData[i * blockSize + j]);
          }
          filteredData.push(sum / blockSize);
        }

        // Normalize
        const maxVal = Math.max(...filteredData);
        waveformDataRef.current = filteredData.map((v) => v / maxVal);

        // Trigger redraw
        drawWaveform();
      })
      .catch(console.error)
      .finally(() => audioContext.close());
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [audioUrl]);

  const drawWaveform = useCallback(() => {
    const canvas = canvasRef.current;
    const ctx = canvas?.getContext('2d');
    if (!canvas || !ctx) return;

    const data = waveformDataRef.current;
    if (data.length === 0) {
      ctx.fillStyle = backgroundColor;
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      return;
    }

    // Clear canvas
    ctx.fillStyle = backgroundColor;
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Calculate bar dimensions
    const totalBarWidth = barWidth + barGap;
    const barCount = Math.min(data.length, Math.floor(canvas.width / totalBarWidth));
    const progressIndex = Math.floor(progress * barCount);

    for (let i = 0; i < barCount; i++) {
      const dataIndex = Math.floor((i / barCount) * data.length);
      const barHeight = Math.max(4, data[dataIndex] * canvas.height * 0.8);
      const x = i * totalBarWidth;
      const y = (canvas.height - barHeight) / 2;

      ctx.fillStyle = i < progressIndex ? progressColor : barColor;
      ctx.beginPath();
      ctx.roundRect(x, y, barWidth, barHeight, barRadius);
      ctx.fill();
    }
  }, [progress, barColor, progressColor, backgroundColor, barWidth, barGap, barRadius]);

  // Redraw when progress changes
  useEffect(() => {
    drawWaveform();
  }, [progress, drawWaveform]);

  // Handle canvas resize
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const resizeObserver = new ResizeObserver(() => {
      const rect = canvas.getBoundingClientRect();
      canvas.width = rect.width * window.devicePixelRatio;
      canvas.height = rect.height * window.devicePixelRatio;
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
      }
      drawWaveform();
    });

    resizeObserver.observe(canvas);
    return () => resizeObserver.disconnect();
  }, [drawWaveform]);

  const handleClick = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (!onClick) return;
    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const clickProgress = x / rect.width;
    onClick(Math.max(0, Math.min(1, clickProgress)));
  };

  return (
    <canvas
      ref={canvasRef}
      className={cn('w-full h-16', onClick && 'cursor-pointer', className)}
      style={{ backgroundColor }}
      onClick={onClick ? handleClick : undefined}
    />
  );
}
