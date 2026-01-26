'use client';

import { useMemo } from 'react';
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
} from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  useSortable,
  verticalListSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { GripVertical, MapPin, Edit, Trash2, Volume2 } from 'lucide-react';
import { StopModel } from '@/types';
import { Button } from '@/components/ui/button';
import { ScrollArea } from '@/components/ui/scroll-area';
import { cn } from '@/lib/utils';

interface StopListPanelProps {
  stops: StopModel[];
  selectedStopId: string | null;
  onStopSelect: (stopId: string | null) => void;
  onStopEdit: (stopId: string) => void;
  onStopDelete: (stopId: string) => void;
  onReorder: (stopIds: string[]) => void;
}

export function StopListPanel({
  stops,
  selectedStopId,
  onStopSelect,
  onStopEdit,
  onStopDelete,
  onReorder,
}: StopListPanelProps) {
  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const sortedStops = useMemo(
    () => [...stops].sort((a, b) => a.order - b.order),
    [stops]
  );

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      const oldIndex = sortedStops.findIndex((s) => s.id === active.id);
      const newIndex = sortedStops.findIndex((s) => s.id === over.id);
      const newOrder = arrayMove(sortedStops, oldIndex, newIndex);
      onReorder(newOrder.map((s) => s.id));
    }
  };

  if (stops.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-full text-center p-4">
        <MapPin className="h-12 w-12 text-muted-foreground/50 mb-4" />
        <p className="font-medium">No stops yet</p>
        <p className="text-sm text-muted-foreground mt-1">
          Click &quot;Add Stop&quot; and then click on the map to add your first stop.
        </p>
      </div>
    );
  }

  return (
    <ScrollArea className="h-full">
      <div className="p-2">
        <DndContext
          sensors={sensors}
          collisionDetection={closestCenter}
          onDragEnd={handleDragEnd}
        >
          <SortableContext
            items={sortedStops.map((s) => s.id)}
            strategy={verticalListSortingStrategy}
          >
            <div className="space-y-2">
              {sortedStops.map((stop) => (
                <SortableStopItem
                  key={stop.id}
                  stop={stop}
                  isSelected={stop.id === selectedStopId}
                  onSelect={() => onStopSelect(stop.id)}
                  onEdit={() => onStopEdit(stop.id)}
                  onDelete={() => onStopDelete(stop.id)}
                />
              ))}
            </div>
          </SortableContext>
        </DndContext>
      </div>
    </ScrollArea>
  );
}

interface SortableStopItemProps {
  stop: StopModel;
  isSelected: boolean;
  onSelect: () => void;
  onEdit: () => void;
  onDelete: () => void;
}

function SortableStopItem({
  stop,
  isSelected,
  onSelect,
  onEdit,
  onDelete,
}: SortableStopItemProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: stop.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  const hasAudio = !!stop.media?.audioUrl;
  const imageCount = stop.media?.images?.length || 0;

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={cn(
        'flex items-center gap-2 p-2 rounded-lg border bg-card transition-colors',
        isSelected && 'border-primary bg-primary/5',
        isDragging && 'opacity-50 shadow-lg'
      )}
    >
      {/* Drag handle */}
      <button
        className="cursor-grab active:cursor-grabbing p-1 text-muted-foreground hover:text-foreground"
        {...attributes}
        {...listeners}
      >
        <GripVertical className="h-4 w-4" />
      </button>

      {/* Stop number */}
      <div
        className={cn(
          'flex-shrink-0 w-7 h-7 rounded-full flex items-center justify-center text-sm font-medium',
          isSelected
            ? 'bg-primary text-primary-foreground'
            : 'bg-muted text-muted-foreground'
        )}
      >
        {stop.order + 1}
      </div>

      {/* Stop info */}
      <button
        className="flex-1 min-w-0 text-left"
        onClick={onSelect}
      >
        <p className="font-medium truncate">{stop.name}</p>
        <div className="flex items-center gap-2 text-xs text-muted-foreground">
          <span className="flex items-center gap-0.5">
            <MapPin className="h-3 w-3" />
            {stop.triggerRadius}m
          </span>
          {hasAudio && (
            <span className="flex items-center gap-0.5">
              <Volume2 className="h-3 w-3" />
              Audio
            </span>
          )}
          {imageCount > 0 && (
            <span>{imageCount} image{imageCount !== 1 ? 's' : ''}</span>
          )}
        </div>
      </button>

      {/* Actions */}
      <div className="flex-shrink-0 flex gap-1">
        <Button
          size="icon"
          variant="ghost"
          className="h-7 w-7"
          onClick={(e) => {
            e.stopPropagation();
            onEdit();
          }}
        >
          <Edit className="h-3.5 w-3.5" />
        </Button>
        <Button
          size="icon"
          variant="ghost"
          className="h-7 w-7 text-destructive hover:text-destructive"
          onClick={(e) => {
            e.stopPropagation();
            onDelete();
          }}
        >
          <Trash2 className="h-3.5 w-3.5" />
        </Button>
      </div>
    </div>
  );
}
