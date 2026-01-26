'use client';

import { useCallback, useState } from 'react';

// Command interface for undo/redo
export interface Command<T> {
  execute: () => T | Promise<T>;
  undo: () => void | Promise<void>;
  description?: string;
}

interface UndoRedoState<T> {
  past: Command<T>[];
  future: Command<T>[];
}

interface UseUndoRedoReturn<T> {
  execute: (command: Command<T>) => Promise<T>;
  undo: () => Promise<void>;
  redo: () => Promise<void>;
  canUndo: boolean;
  canRedo: boolean;
  clear: () => void;
  undoStack: Command<T>[];
  redoStack: Command<T>[];
}

export function useUndoRedo<T = void>(maxHistory = 50): UseUndoRedoReturn<T> {
  const [state, setState] = useState<UndoRedoState<T>>({
    past: [],
    future: [],
  });

  const execute = useCallback(
    async (command: Command<T>): Promise<T> => {
      const result = await command.execute();

      setState((prev) => ({
        past: [...prev.past.slice(-maxHistory + 1), command],
        future: [], // Clear redo stack when new command is executed
      }));

      return result;
    },
    [maxHistory]
  );

  const undo = useCallback(async () => {
    setState((prev) => {
      if (prev.past.length === 0) return prev;

      const command = prev.past[prev.past.length - 1];

      // Execute undo asynchronously
      Promise.resolve(command.undo()).catch(console.error);

      return {
        past: prev.past.slice(0, -1),
        future: [command, ...prev.future],
      };
    });
  }, []);

  const redo = useCallback(async () => {
    setState((prev) => {
      if (prev.future.length === 0) return prev;

      const command = prev.future[0];

      // Execute redo (re-execute) asynchronously
      Promise.resolve(command.execute()).catch(console.error);

      return {
        past: [...prev.past, command],
        future: prev.future.slice(1),
      };
    });
  }, []);

  const clear = useCallback(() => {
    setState({ past: [], future: [] });
  }, []);

  return {
    execute,
    undo,
    redo,
    canUndo: state.past.length > 0,
    canRedo: state.future.length > 0,
    clear,
    undoStack: state.past,
    redoStack: state.future,
  };
}

// Pre-built command factories for common stop operations

export interface StopData {
  id: string;
  name: string;
  description: string;
  location: { latitude: number; longitude: number };
  triggerRadius: number;
  order: number;
}

export function createAddStopCommand(
  addFn: (stop: Omit<StopData, 'id'>) => Promise<string>,
  removeFn: (stopId: string) => Promise<void>,
  stopData: Omit<StopData, 'id'>
): Command<string> {
  let createdId: string | null = null;

  return {
    execute: async () => {
      createdId = await addFn(stopData);
      return createdId;
    },
    undo: async () => {
      if (createdId) {
        await removeFn(createdId);
      }
    },
    description: `Add stop: ${stopData.name}`,
  };
}

export function createRemoveStopCommand(
  removeFn: (stopId: string) => Promise<void>,
  restoreFn: (stop: StopData) => Promise<string>,
  stopData: StopData
): Command<void> {
  return {
    execute: async () => {
      await removeFn(stopData.id);
    },
    undo: async () => {
      await restoreFn(stopData);
    },
    description: `Remove stop: ${stopData.name}`,
  };
}

export function createMoveStopCommand(
  updateFn: (stopId: string, location: { latitude: number; longitude: number }) => Promise<void>,
  stopId: string,
  oldLocation: { latitude: number; longitude: number },
  newLocation: { latitude: number; longitude: number }
): Command<void> {
  return {
    execute: async () => {
      await updateFn(stopId, newLocation);
    },
    undo: async () => {
      await updateFn(stopId, oldLocation);
    },
    description: 'Move stop',
  };
}

export function createReorderStopsCommand(
  reorderFn: (stopIds: string[]) => Promise<void>,
  oldOrder: string[],
  newOrder: string[]
): Command<void> {
  return {
    execute: async () => {
      await reorderFn(newOrder);
    },
    undo: async () => {
      await reorderFn(oldOrder);
    },
    description: 'Reorder stops',
  };
}

export function createUpdateStopCommand<K extends keyof StopData>(
  updateFn: (stopId: string, field: K, value: StopData[K]) => Promise<void>,
  stopId: string,
  field: K,
  oldValue: StopData[K],
  newValue: StopData[K]
): Command<void> {
  return {
    execute: async () => {
      await updateFn(stopId, field, newValue);
    },
    undo: async () => {
      await updateFn(stopId, field, oldValue);
    },
    description: `Update stop ${field}`,
  };
}
