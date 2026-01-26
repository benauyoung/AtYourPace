'use client';

import { use, useState, useCallback, useEffect } from 'react';
import Link from 'next/link';
import { ArrowLeft, Undo2, Redo2, Loader2 } from 'lucide-react';
import { CreatorPageWrapper } from '@/components/layout/creator-page-wrapper';
import { Button } from '@/components/ui/button';
import { MapEditor } from '@/components/creator/map-editor';
import { StopListPanel } from '@/components/creator/stop-list-panel';
import { StopDetailModal } from '@/components/creator/stop-detail-modal';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { useToast } from '@/hooks/use-toast';
import {
  useTourStops,
  useCreateStop,
  useUpdateStop,
  useDeleteStop,
  useReorderStops,
} from '@/hooks/use-stops';
import { useCreatorTour } from '@/hooks/use-creator-tours';
import {
  useUndoRedo,
  createAddStopCommand,
  createRemoveStopCommand,
  createMoveStopCommand,
  createReorderStopsCommand,
  StopData,
} from '@/hooks/use-undo-redo';
import { GeoPoint } from '@/types';
import { DEFAULT_TRIGGER_RADIUS } from '@/lib/mapbox/config';

interface StopsPageProps {
  params: Promise<{ tourId: string }>;
}

export default function StopsPage({ params }: StopsPageProps) {
  const { tourId } = use(params);
  const { toast } = useToast();

  // Data fetching
  const { data: tourData, isLoading: tourLoading } = useCreatorTour(tourId);
  const { data: stops = [], isLoading: stopsLoading } = useTourStops(tourId);

  // Mutations
  const createStopMutation = useCreateStop();
  const updateStopMutation = useUpdateStop();
  const deleteStopMutation = useDeleteStop();
  const reorderStopsMutation = useReorderStops();

  // Undo/redo
  const { execute, undo, redo, canUndo, canRedo } = useUndoRedo<string | void>();

  // Local state
  const [selectedStopId, setSelectedStopId] = useState<string | null>(null);
  const [isAddMode, setIsAddMode] = useState(false);
  const [editingStopId, setEditingStopId] = useState<string | null>(null);
  const [deleteStopId, setDeleteStopId] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);

  // Get stops for modals
  const editingStop = stops.find((s) => s.id === editingStopId) || null;
  const deleteStop = stops.find((s) => s.id === deleteStopId) || null;

  // Handler for adding a new stop
  const handleStopAdd = useCallback(
    async (location: GeoPoint, name: string) => {
      const newStopData = {
        name,
        description: '',
        location,
        triggerRadius: DEFAULT_TRIGGER_RADIUS,
        order: stops.length,
      };

      const command = createAddStopCommand(
        async (stopData) => {
          const stopId = await createStopMutation.mutateAsync({
            tourId,
            input: stopData,
          });
          return stopId;
        },
        async (stopId) => {
          await deleteStopMutation.mutateAsync({ tourId, stopId });
        },
        newStopData
      );

      try {
        const newStopId = await execute(command);
        setSelectedStopId(newStopId as string);
        toast({
          title: 'Stop added',
          description: `"${name}" has been added to the tour.`,
        });
      } catch {
        toast({
          title: 'Error',
          description: 'Failed to add stop. Please try again.',
          variant: 'destructive',
        });
      }
    },
    [tourId, stops.length, createStopMutation, deleteStopMutation, execute, toast]
  );

  // Handler for moving a stop on the map
  const handleStopMove = useCallback(
    async (stopId: string, newLocation: GeoPoint) => {
      const stop = stops.find((s) => s.id === stopId);
      if (!stop) return;

      const oldLocation = stop.location;
      const command = createMoveStopCommand(
        async (id, location) => {
          await updateStopMutation.mutateAsync({
            tourId,
            stopId: id,
            input: { location },
          });
        },
        stopId,
        oldLocation,
        newLocation
      );

      try {
        await execute(command);
      } catch {
        toast({
          title: 'Error',
          description: 'Failed to move stop. Please try again.',
          variant: 'destructive',
        });
      }
    },
    [tourId, stops, updateStopMutation, execute, toast]
  );

  // Handler for reordering stops via drag and drop
  const handleReorder = useCallback(
    async (newStopIds: string[]) => {
      const oldOrder = stops
        .sort((a, b) => a.order - b.order)
        .map((s) => s.id);

      const command = createReorderStopsCommand(
        async (stopIds) => {
          await reorderStopsMutation.mutateAsync({ tourId, stopIds });
        },
        oldOrder,
        newStopIds
      );

      try {
        await execute(command);
      } catch {
        toast({
          title: 'Error',
          description: 'Failed to reorder stops. Please try again.',
          variant: 'destructive',
        });
      }
    },
    [tourId, stops, reorderStopsMutation, execute, toast]
  );

  // Handler for saving stop details from modal
  const handleStopSave = useCallback(
    async (stopId: string, data: Partial<StopData>) => {
      setIsSaving(true);
      try {
        await updateStopMutation.mutateAsync({
          tourId,
          stopId,
          input: data,
        });
        toast({
          title: 'Stop updated',
          description: 'Stop details have been saved.',
        });
      } catch {
        toast({
          title: 'Error',
          description: 'Failed to save stop. Please try again.',
          variant: 'destructive',
        });
      } finally {
        setIsSaving(false);
      }
    },
    [tourId, updateStopMutation, toast]
  );

  // Handler for confirming delete
  const handleDeleteConfirm = useCallback(async () => {
    if (!deleteStop) return;

    const stopData: StopData = {
      id: deleteStop.id,
      name: deleteStop.name,
      description: deleteStop.description,
      location: deleteStop.location,
      triggerRadius: deleteStop.triggerRadius,
      order: deleteStop.order,
    };

    const command = createRemoveStopCommand(
      async (stopId) => {
        await deleteStopMutation.mutateAsync({ tourId, stopId });
      },
      async (stop) => {
        await createStopMutation.mutateAsync({
          tourId,
          input: {
            name: stop.name,
            description: stop.description,
            location: stop.location,
            triggerRadius: stop.triggerRadius,
            order: stop.order,
          },
        });
        return stop.id;
      },
      stopData
    );

    try {
      await execute(command);
      if (selectedStopId === deleteStop.id) {
        setSelectedStopId(null);
      }
      toast({
        title: 'Stop deleted',
        description: `"${deleteStop.name}" has been removed.`,
      });
    } catch {
      toast({
        title: 'Error',
        description: 'Failed to delete stop. Please try again.',
        variant: 'destructive',
      });
    } finally {
      setDeleteStopId(null);
    }
  }, [
    tourId,
    deleteStop,
    selectedStopId,
    createStopMutation,
    deleteStopMutation,
    execute,
    toast,
  ]);

  // Keyboard shortcuts
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Delete selected stop
      if (e.key === 'Delete' && selectedStopId && !editingStopId) {
        e.preventDefault();
        setDeleteStopId(selectedStopId);
      }

      // Undo: Ctrl+Z / Cmd+Z
      if ((e.ctrlKey || e.metaKey) && e.key === 'z' && !e.shiftKey) {
        e.preventDefault();
        if (canUndo) {
          undo();
          toast({
            title: 'Undo',
            description: 'Action undone.',
          });
        }
      }

      // Redo: Ctrl+Y / Cmd+Y or Ctrl+Shift+Z / Cmd+Shift+Z
      if (
        (e.ctrlKey || e.metaKey) &&
        (e.key === 'y' || (e.key === 'z' && e.shiftKey))
      ) {
        e.preventDefault();
        if (canRedo) {
          redo();
          toast({
            title: 'Redo',
            description: 'Action redone.',
          });
        }
      }

      // Escape: deselect stop or exit add mode
      if (e.key === 'Escape') {
        if (isAddMode) {
          setIsAddMode(false);
        } else if (selectedStopId) {
          setSelectedStopId(null);
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [
    selectedStopId,
    editingStopId,
    isAddMode,
    canUndo,
    canRedo,
    undo,
    redo,
    toast,
  ]);

  const isLoading = tourLoading || stopsLoading;

  if (isLoading) {
    return (
      <CreatorPageWrapper title="Manage Stops">
        <div className="flex h-[calc(100vh-8rem)] items-center justify-center">
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
        </div>
      </CreatorPageWrapper>
    );
  }

  return (
    <CreatorPageWrapper title="Manage Stops">
      <div className="flex h-[calc(100vh-8rem)] flex-col">
        {/* Header */}
        <div className="flex items-center justify-between border-b px-4 py-3">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="sm" asChild>
              <Link href={`/tour/${tourId}/edit`}>
                <ArrowLeft className="mr-2 h-4 w-4" />
                Back
              </Link>
            </Button>
            <div>
              <h2 className="font-semibold">{tourData?.version.title || 'Loading...'}</h2>
              <p className="text-sm text-muted-foreground">
                {stops.length} stop{stops.length !== 1 ? 's' : ''}
              </p>
            </div>
          </div>

          {/* Undo/Redo buttons */}
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                undo();
                toast({ title: 'Undo', description: 'Action undone.' });
              }}
              disabled={!canUndo}
              title="Undo (Ctrl+Z)"
            >
              <Undo2 className="h-4 w-4" />
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                redo();
                toast({ title: 'Redo', description: 'Action redone.' });
              }}
              disabled={!canRedo}
              title="Redo (Ctrl+Y)"
            >
              <Redo2 className="h-4 w-4" />
            </Button>
          </div>
        </div>

        {/* Main content */}
        <div className="flex flex-1 overflow-hidden">
          {/* Stop list panel */}
          <div className="w-80 flex-shrink-0 border-r bg-muted/30">
            <StopListPanel
              stops={stops}
              selectedStopId={selectedStopId}
              onStopSelect={setSelectedStopId}
              onStopEdit={setEditingStopId}
              onStopDelete={setDeleteStopId}
              onReorder={handleReorder}
            />
          </div>

          {/* Map editor */}
          <div className="flex-1">
            <MapEditor
              stops={stops}
              selectedStopId={selectedStopId}
              onStopSelect={setSelectedStopId}
              onStopAdd={handleStopAdd}
              onStopMove={handleStopMove}
              centerLocation={tourData?.tour.startLocation}
              isAddMode={isAddMode}
              onAddModeChange={setIsAddMode}
            />
          </div>
        </div>
      </div>

      {/* Edit stop modal */}
      <StopDetailModal
        stop={editingStop}
        isOpen={!!editingStopId}
        onClose={() => setEditingStopId(null)}
        onSave={handleStopSave}
        isSaving={isSaving}
      />

      {/* Delete confirmation dialog */}
      <AlertDialog open={!!deleteStopId} onOpenChange={() => setDeleteStopId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Stop</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete &quot;{deleteStop?.name}&quot;? This
              action can be undone using Ctrl+Z.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleDeleteConfirm}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </CreatorPageWrapper>
  );
}
