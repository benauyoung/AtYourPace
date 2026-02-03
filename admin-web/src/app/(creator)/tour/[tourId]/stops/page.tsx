'use client';

import { MapEditor } from '@/components/creator/map-editor';
import { StopDetailModal } from '@/components/creator/stop-detail-modal';
import { StopListPanel } from '@/components/creator/stop-list-panel';
import { CreatorPageWrapper } from '@/components/layout/creator-page-wrapper';
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
import { Button } from '@/components/ui/button';
import { useCreatorTour } from '@/hooks/use-creator-tours';
import {
  useCreateStop,
  useDeleteStop,
  useDeleteStopImage,
  useReorderStopImages,
  useReorderStops,
  useTourStops,
  useUpdateStop,
  useUploadStopImage,
} from '@/hooks/use-stops';
import { useToast } from '@/hooks/use-toast';
import {
  createAddStopCommand,
  createMoveStopCommand,
  createRemoveStopCommand,
  createReorderStopsCommand,
  StopData,
  useUndoRedo,
} from '@/hooks/use-undo-redo';
import { DEFAULT_TRIGGER_RADIUS } from '@/lib/mapbox/config';
import { GeoPoint, StopImage } from '@/types';
import { ArrowLeft, Loader2, PanelLeft, PanelLeftClose, Redo2, Undo2, X } from 'lucide-react';
import Link from 'next/link';
import { useCallback, useEffect, useState } from 'react';

interface StopsPageProps {
  params: { tourId: string };
}

export default function StopsPage({ params }: StopsPageProps) {
  const { tourId } = params;
  const { toast } = useToast();

  // Data fetching
  const { data: tourData, isLoading: tourLoading } = useCreatorTour(tourId);
  const { data: stops = [], isLoading: stopsLoading } = useTourStops(tourId);

  // Mutations
  const createStopMutation = useCreateStop();
  const updateStopMutation = useUpdateStop();
  const deleteStopMutation = useDeleteStop();
  const reorderStopsMutation = useReorderStops();
  const uploadStopImageMutation = useUploadStopImage();
  const deleteStopImageMutation = useDeleteStopImage();
  const reorderStopImagesMutation = useReorderStopImages();

  // Undo/redo
  const { execute, undo, redo, canUndo, canRedo } = useUndoRedo<string | void>();

  // Local state
  const [selectedStopId, setSelectedStopId] = useState<string | null>(null);
  const [isAddMode, setIsAddMode] = useState(false);
  const [editingStopId, setEditingStopId] = useState<string | null>(null);
  const [deleteStopId, setDeleteStopId] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

  // Get stops for modals
  const editingStop = stops.find((s) => s.id === editingStopId) || null;
  const deleteStop = stops.find((s) => s.id === deleteStopId) || null;

  // Handle stop selection with auto-close on tablet/mobile
  const handleStopSelect = useCallback((stopId: string | null) => {
    setSelectedStopId(stopId);
    if (stopId && typeof window !== 'undefined' && window.innerWidth < 1024) {
      setIsSidebarOpen(false);
    }
  }, []);

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
        setEditingStopId(newStopId as string); // Auto-open details modal
        toast({
          title: 'Stop added',
          description: `"${name}" has been added to the tour.`,
        });
      } catch (error) {
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
      } catch (error) {
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
      } catch (error) {
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
      } catch (error) {
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

  // Image handlers for stop detail modal
  const handleImageUpload = useCallback(
    async (file: File, order: number) => {
      if (!editingStopId) throw new Error('No stop selected');
      return uploadStopImageMutation.mutateAsync({
        tourId,
        stopId: editingStopId,
        file,
        order,
      });
    },
    [tourId, editingStopId, uploadStopImageMutation]
  );

  const handleImageDelete = useCallback(
    async (imageUrl: string) => {
      if (!editingStopId) throw new Error('No stop selected');
      await deleteStopImageMutation.mutateAsync({
        tourId,
        stopId: editingStopId,
        imageUrl,
      });
    },
    [tourId, editingStopId, deleteStopImageMutation]
  );

  const handleImagesReorder = useCallback(
    async (images: StopImage[]) => {
      if (!editingStopId) throw new Error('No stop selected');
      await reorderStopImagesMutation.mutateAsync({
        tourId,
        stopId: editingStopId,
        images,
      });
    },
    [tourId, editingStopId, reorderStopImagesMutation]
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
        const stopId = await createStopMutation.mutateAsync({
          tourId,
          input: {
            name: stop.name,
            description: stop.description,
            location: stop.location,
            triggerRadius: stop.triggerRadius,
            order: stop.order,
          },
        });
        return stopId;
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
    } catch (error) {
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

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Delete' && selectedStopId && !editingStopId) {
        e.preventDefault();
        setDeleteStopId(selectedStopId);
      }

      if ((e.ctrlKey || e.metaKey) && e.key === 'z' && !e.shiftKey) {
        e.preventDefault();
        if (canUndo) undo();
      }

      if ((e.ctrlKey || e.metaKey) && (e.key === 'y' || (e.key === 'z' && e.shiftKey))) {
        e.preventDefault();
        if (canRedo) redo();
      }

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
  }, [selectedStopId, editingStopId, isAddMode, canUndo, canRedo, undo, redo]);

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
    <CreatorPageWrapper title="Manage Stops" noPadding>
      {/* Header bar */}
      <header className="flex-none flex items-center justify-between border-b px-4 py-3 bg-background z-30">
        <div className="flex items-center gap-4">
          <Button variant="ghost" size="sm" asChild>
            <Link href={`/tour/${tourId}/edit`}>
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back
            </Link>
          </Button>
          <div>
            <h2 className="font-semibold text-foreground leading-tight">
              {tourData?.version.title || 'Loading...'}
            </h2>
            <p className="text-xs text-muted-foreground">
              {stops.length} stop{stops.length !== 1 ? 's' : ''}
            </p>
          </div>
        </div>

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
      </header>

      {/* Main content: sidebar + map as flex siblings */}
      <div className="flex-1 flex min-h-0">
        {/* Desktop sidebar - always visible, in document flow */}
        <aside
          className={`
            hidden lg:flex flex-col flex-shrink-0 bg-background border-r
            transition-[width] duration-300 ease-in-out overflow-hidden
            ${isSidebarOpen ? 'w-80' : 'w-0 border-r-0'}
          `}
        >
          <div className="w-80 h-full flex flex-col">
            <StopListPanel
              stops={stops}
              selectedStopId={selectedStopId}
              onStopSelect={handleStopSelect}
              onStopEdit={(id) => setEditingStopId(id)}
              onStopDelete={(id) => setDeleteStopId(id)}
              onReorder={handleReorder}
            />
          </div>
        </aside>

        {/* Map area */}
        <div className="flex-1 min-h-0 min-w-0 relative">
          {/* Mobile sidebar toggle */}
          <Button
            variant="secondary"
            size="sm"
            onClick={() => setIsSidebarOpen(!isSidebarOpen)}
            className="absolute top-4 left-4 z-20 lg:z-10 shadow-md h-10 w-10 p-0"
          >
            {isSidebarOpen ? <PanelLeftClose className="h-5 w-5" /> : <PanelLeft className="h-5 w-5" />}
          </Button>

          {/* Map fills entire area */}
          <MapEditor
            stops={stops}
            selectedStopId={selectedStopId}
            onStopSelect={handleStopSelect}
            onStopAdd={handleStopAdd}
            onStopMove={handleStopMove}
            centerLocation={tourData?.tour.startLocation}
            isAddMode={isAddMode}
            onAddModeChange={setIsAddMode}
            tourType={tourData?.tour.tourType}
          />
        </div>

        {/* Mobile sidebar - slides over map */}
        {isSidebarOpen && (
          <div className="lg:hidden fixed inset-0 z-40">
            {/* Backdrop */}
            <div
              className="absolute inset-0 bg-black/30"
              onClick={() => setIsSidebarOpen(false)}
            />
            {/* Drawer */}
            <aside className="absolute inset-y-0 left-0 w-80 bg-background border-r flex flex-col shadow-xl">
              <div className="flex justify-end p-2 border-b">
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setIsSidebarOpen(false)}
                  className="h-10 w-10 p-0"
                >
                  <X className="h-5 w-5" />
                </Button>
              </div>
              <div className="flex-1 overflow-hidden">
                <StopListPanel
                  stops={stops}
                  selectedStopId={selectedStopId}
                  onStopSelect={handleStopSelect}
                  onStopEdit={(id) => setEditingStopId(id)}
                  onStopDelete={(id) => setDeleteStopId(id)}
                  onReorder={handleReorder}
                />
              </div>
            </aside>
          </div>
        )}
      </div>

      <StopDetailModal
        stop={editingStop}
        isOpen={!!editingStopId}
        onClose={() => setEditingStopId(null)}
        onSave={handleStopSave}
        isSaving={isSaving}
        onImageUpload={handleImageUpload}
        onImageDelete={handleImageDelete}
        onImagesReorder={handleImagesReorder}
      />

      <AlertDialog open={!!deleteStopId} onOpenChange={() => setDeleteStopId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Stop</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete "{deleteStop?.name}"? This action can be undone using Ctrl+Z.
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
