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
  rectSortingStrategy,
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { GripVertical, Trash2, Maximize2, ImageIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';
import { StopImage } from '@/types';

interface ImageGalleryProps {
  images: StopImage[];
  onReorder: (images: StopImage[]) => void;
  onDelete: (imageUrl: string) => void;
  onPreview: (index: number) => void;
  isDeleting?: string | null;
  className?: string;
}

export function ImageGallery({
  images,
  onReorder,
  onDelete,
  onPreview,
  isDeleting,
  className,
}: ImageGalleryProps) {
  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const sortedImages = useMemo(
    () => [...images].sort((a, b) => a.order - b.order),
    [images]
  );

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;

    if (over && active.id !== over.id) {
      const oldIndex = sortedImages.findIndex((img) => img.url === active.id);
      const newIndex = sortedImages.findIndex((img) => img.url === over.id);

      const newOrder = arrayMove(sortedImages, oldIndex, newIndex).map(
        (img, index) => ({ ...img, order: index })
      );

      onReorder(newOrder);
    }
  };

  if (images.length === 0) {
    return (
      <div className={cn(
        'flex flex-col items-center justify-center rounded-lg border border-dashed p-8 text-center',
        className
      )}>
        <ImageIcon className="mb-4 h-10 w-10 text-muted-foreground/50" />
        <p className="font-medium text-muted-foreground">No images yet</p>
        <p className="mt-1 text-sm text-muted-foreground">
          Upload images to showcase this stop
        </p>
      </div>
    );
  }

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragEnd={handleDragEnd}
    >
      <SortableContext
        items={sortedImages.map((img) => img.url)}
        strategy={rectSortingStrategy}
      >
        <div className={cn(
          'grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3',
          className
        )}>
          {sortedImages.map((image, index) => (
            <SortableImageItem
              key={image.url}
              image={image}
              index={index}
              onDelete={() => onDelete(image.url)}
              onPreview={() => onPreview(index)}
              isDeleting={isDeleting === image.url}
            />
          ))}
        </div>
      </SortableContext>
    </DndContext>
  );
}

interface SortableImageItemProps {
  image: StopImage;
  index: number;
  onDelete: () => void;
  onPreview: () => void;
  isDeleting: boolean;
}

function SortableImageItem({
  image,
  index,
  onDelete,
  onPreview,
  isDeleting,
}: SortableImageItemProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: image.url });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={cn(
        'group relative aspect-square rounded-lg overflow-hidden bg-muted',
        isDragging && 'opacity-50 shadow-lg z-10',
        isDeleting && 'opacity-50 pointer-events-none'
      )}
    >
      {/* Image */}
      <img
        src={image.url}
        alt={image.caption || `Image ${index + 1}`}
        className="w-full h-full object-cover"
      />

      {/* Order badge */}
      <div className="absolute top-2 left-2 px-2 py-0.5 rounded-full bg-black/60 text-white text-xs font-medium">
        {index + 1}
      </div>

      {/* Drag handle */}
      <button
        className="absolute top-2 right-2 p-1.5 rounded-full bg-black/60 text-white opacity-0 group-hover:opacity-100 transition-opacity cursor-grab active:cursor-grabbing"
        {...attributes}
        {...listeners}
      >
        <GripVertical className="h-4 w-4" />
      </button>

      {/* Actions overlay */}
      <div className="absolute inset-x-0 bottom-0 p-2 bg-gradient-to-t from-black/70 to-transparent opacity-0 group-hover:opacity-100 transition-opacity">
        <div className="flex items-center justify-center gap-2">
          <Button
            size="icon"
            variant="secondary"
            className="h-8 w-8"
            onClick={onPreview}
          >
            <Maximize2 className="h-4 w-4" />
          </Button>
          <Button
            size="icon"
            variant="secondary"
            className="h-8 w-8 text-destructive hover:text-destructive"
            onClick={onDelete}
            disabled={isDeleting}
          >
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Caption */}
      {image.caption && (
        <div className="absolute inset-x-0 bottom-0 p-2 bg-black/60 text-white text-xs truncate opacity-0 group-hover:opacity-100 transition-opacity">
          {image.caption}
        </div>
      )}
    </div>
  );
}
