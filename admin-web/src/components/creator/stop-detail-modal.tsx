'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { MapPin, Save, Loader2 } from 'lucide-react';
import { StopModel } from '@/types';
import {
  DEFAULT_TRIGGER_RADIUS,
  MIN_TRIGGER_RADIUS,
  MAX_TRIGGER_RADIUS,
} from '@/lib/mapbox/config';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Slider } from '@/components/ui/slider';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';

const stopFormSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100, 'Name must be less than 100 characters'),
  description: z.string().max(1000, 'Description must be less than 1000 characters').optional(),
  triggerRadius: z.number().min(MIN_TRIGGER_RADIUS).max(MAX_TRIGGER_RADIUS),
});

type StopFormValues = z.infer<typeof stopFormSchema>;

interface StopDetailModalProps {
  stop: StopModel | null;
  isOpen: boolean;
  onClose: () => void;
  onSave: (stopId: string, data: Partial<StopFormValues>) => Promise<void>;
  isSaving?: boolean;
}

export function StopDetailModal({
  stop,
  isOpen,
  onClose,
  onSave,
  isSaving,
}: StopDetailModalProps) {
  const form = useForm<StopFormValues>({
    resolver: zodResolver(stopFormSchema),
    defaultValues: {
      name: '',
      description: '',
      triggerRadius: DEFAULT_TRIGGER_RADIUS,
    },
  });

  // Update form when stop changes
  useEffect(() => {
    if (stop) {
      form.reset({
        name: stop.name,
        description: stop.description || '',
        triggerRadius: stop.triggerRadius,
      });
    }
  }, [stop, form]);

  const handleSubmit = async (data: StopFormValues) => {
    if (!stop) return;
    await onSave(stop.id, data);
    onClose();
  };

  const triggerRadius = form.watch('triggerRadius');

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <MapPin className="h-5 w-5" />
            Edit Stop
          </DialogTitle>
          <DialogDescription>
            Update the stop details. Changes are saved when you click save.
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Stop Name</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g., Golden Gate Bridge Viewpoint" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Description</FormLabel>
                  <FormControl>
                    <Textarea
                      placeholder="Describe what visitors will see or do at this stop..."
                      className="min-h-[100px]"
                      {...field}
                    />
                  </FormControl>
                  <FormDescription>
                    Optional. This will be shown to users when they arrive at this stop.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="triggerRadius"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Trigger Radius: {triggerRadius}m</FormLabel>
                  <FormControl>
                    <Slider
                      min={MIN_TRIGGER_RADIUS}
                      max={MAX_TRIGGER_RADIUS}
                      step={10}
                      value={[field.value]}
                      onValueChange={(v) => field.onChange(v[0])}
                    />
                  </FormControl>
                  <FormDescription>
                    How close users need to be for the audio to play automatically.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            {/* Location info (read-only) */}
            {stop && (
              <div className="rounded-lg bg-muted p-3 text-sm">
                <p className="font-medium mb-1">Location</p>
                <p className="text-muted-foreground">
                  {stop.location.latitude.toFixed(6)}, {stop.location.longitude.toFixed(6)}
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  Drag the marker on the map to change the location.
                </p>
              </div>
            )}

            <DialogFooter>
              <Button type="button" variant="outline" onClick={onClose}>
                Cancel
              </Button>
              <Button type="submit" disabled={isSaving}>
                {isSaving ? (
                  <>
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <Save className="mr-2 h-4 w-4" />
                    Save Changes
                  </>
                )}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
