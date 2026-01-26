'use client';

import { useEffect, useRef, useState, useCallback } from 'react';

interface UseAutoSaveOptions<T> {
  data: T;
  onSave: (data: T) => Promise<void>;
  interval?: number; // Default 2 minutes
  enabled?: boolean;
}

interface UseAutoSaveReturn {
  isSaving: boolean;
  lastSaved: Date | null;
  saveNow: () => Promise<void>;
  hasUnsavedChanges: boolean;
}

export function useAutoSave<T>({
  data,
  onSave,
  interval = 2 * 60 * 1000, // 2 minutes
  enabled = true,
}: UseAutoSaveOptions<T>): UseAutoSaveReturn {
  const [isSaving, setIsSaving] = useState(false);
  const [lastSaved, setLastSaved] = useState<Date | null>(null);
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  const dataRef = useRef(data);
  const savedDataRef = useRef<string | null>(null);
  const saveTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Update ref when data changes
  useEffect(() => {
    dataRef.current = data;
    const currentDataString = JSON.stringify(data);

    if (savedDataRef.current !== null && savedDataRef.current !== currentDataString) {
      setHasUnsavedChanges(true);
    }
  }, [data]);

  const saveNow = useCallback(async () => {
    if (isSaving) return;

    setIsSaving(true);
    try {
      await onSave(dataRef.current);
      const now = new Date();
      setLastSaved(now);
      savedDataRef.current = JSON.stringify(dataRef.current);
      setHasUnsavedChanges(false);
    } catch (error) {
      console.error('Auto-save failed:', error);
      throw error;
    } finally {
      setIsSaving(false);
    }
  }, [onSave, isSaving]);

  // Set up auto-save interval
  useEffect(() => {
    if (!enabled) return;

    // Initial save of data state
    if (savedDataRef.current === null) {
      savedDataRef.current = JSON.stringify(data);
    }

    saveTimeoutRef.current = setInterval(() => {
      const currentDataString = JSON.stringify(dataRef.current);

      // Only save if data has changed
      if (savedDataRef.current !== currentDataString) {
        saveNow().catch(console.error);
      }
    }, interval);

    return () => {
      if (saveTimeoutRef.current) {
        clearInterval(saveTimeoutRef.current);
      }
    };
  }, [enabled, interval, saveNow, data]);

  // Save on unmount if there are unsaved changes
  useEffect(() => {
    return () => {
      const currentDataString = JSON.stringify(dataRef.current);
      if (savedDataRef.current !== currentDataString) {
        // Fire and forget - we're unmounting
        onSave(dataRef.current).catch(console.error);
      }
    };
  }, [onSave]);

  return {
    isSaving,
    lastSaved,
    saveNow,
    hasUnsavedChanges,
  };
}
