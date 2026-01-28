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

  // Use refs for values that shouldn't trigger re-renders
  const dataRef = useRef(data);
  const savedDataRef = useRef<string | null>(null);
  const onSaveRef = useRef(onSave);
  const isSavingRef = useRef(false);

  // Update refs when values change (without triggering effects)
  useEffect(() => {
    dataRef.current = data;
  }, [data]);

  useEffect(() => {
    onSaveRef.current = onSave;
  }, [onSave]);

  // Track unsaved changes separately
  useEffect(() => {
    const currentDataString = JSON.stringify(data);
    if (savedDataRef.current !== null && savedDataRef.current !== currentDataString) {
      setHasUnsavedChanges(true);
    }
  }, [data]);

  // Stable saveNow function that doesn't change on every render
  const saveNow = useCallback(async () => {
    if (isSavingRef.current) return;

    isSavingRef.current = true;
    setIsSaving(true);

    try {
      await onSaveRef.current(dataRef.current);
      const now = new Date();
      setLastSaved(now);
      savedDataRef.current = JSON.stringify(dataRef.current);
      setHasUnsavedChanges(false);
    } catch (error) {
      console.error('Auto-save failed:', error);
      throw error;
    } finally {
      isSavingRef.current = false;
      setIsSaving(false);
    }
  }, []); // No dependencies - uses refs

  // Set up auto-save interval (only depends on enabled and interval)
  useEffect(() => {
    if (!enabled) return;

    // Initial save of data state
    if (savedDataRef.current === null) {
      savedDataRef.current = JSON.stringify(dataRef.current);
    }

    const intervalId = setInterval(() => {
      const currentDataString = JSON.stringify(dataRef.current);

      // Only save if data has changed
      if (savedDataRef.current !== currentDataString) {
        saveNow().catch(console.error);
      }
    }, interval);

    return () => {
      clearInterval(intervalId);
    };
  }, [enabled, interval, saveNow]);

  // Save on unmount if there are unsaved changes
  useEffect(() => {
    return () => {
      const currentDataString = JSON.stringify(dataRef.current);
      if (savedDataRef.current !== null && savedDataRef.current !== currentDataString) {
        // Fire and forget - we're unmounting
        onSaveRef.current(dataRef.current).catch(console.error);
      }
    };
  }, []); // Empty deps - only runs on unmount

  return {
    isSaving,
    lastSaved,
    saveNow,
    hasUnsavedChanges,
  };
}
