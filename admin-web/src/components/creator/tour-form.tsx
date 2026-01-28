'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Save, Loader2, Clock } from 'lucide-react';
import { formatDistanceToNow } from 'date-fns';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { TourModel, TourVersionModel, TourCategory, TourDifficulty, categoryDisplayNames } from '@/types';
import { useAutoSave } from '@/hooks/use-auto-save';
import { CoverImageUpload } from './cover-image-upload';
import { LocationPicker, LocationInfo } from './location-picker';

const tourFormSchema = z.object({
  title: z.string().min(3, 'Title must be at least 3 characters').max(100, 'Title must be less than 100 characters'),
  description: z.string().min(10, 'Description must be at least 10 characters').max(2000, 'Description must be less than 2000 characters'),
  category: z.enum(['history', 'nature', 'ghost', 'food', 'art', 'architecture', 'other'] as const),
  tourType: z.enum(['walking', 'driving'] as const),
  difficulty: z.enum(['easy', 'moderate', 'challenging'] as const),
  city: z.string().optional(),
  region: z.string().optional(),
  country: z.string().optional(),
  duration: z.string().optional(),
  distance: z.string().optional(),
  startLatitude: z.coerce.number().min(-90).max(90),
  startLongitude: z.coerce.number().min(-180).max(180),
});

type TourFormValues = z.infer<typeof tourFormSchema>;

interface TourFormProps {
  tour?: TourModel;
  version?: TourVersionModel;
  onSave: (data: TourFormValues) => Promise<void>;
  onCoverImageUpload?: (file: File) => Promise<void>;
  coverImageUrl?: string;
  isSaving?: boolean;
  isNew?: boolean;
}

const difficultyOptions: { value: TourDifficulty; label: string; description: string }[] = [
  { value: 'easy', label: 'Easy', description: 'Suitable for all fitness levels' },
  { value: 'moderate', label: 'Moderate', description: 'Some walking or light activity required' },
  { value: 'challenging', label: 'Challenging', description: 'Requires good fitness level' },
];

export function TourForm({
  tour,
  version,
  onSave,
  onCoverImageUpload,
  coverImageUrl,
  isSaving,
  isNew = false,
}: TourFormProps) {
  const [isUploadingImage, setIsUploadingImage] = useState(false);

  const form = useForm<TourFormValues>({
    resolver: zodResolver(tourFormSchema),
    defaultValues: {
      title: version?.title || '',
      description: version?.description || '',
      category: tour?.category || 'other',
      tourType: tour?.tourType || 'walking',
      difficulty: version?.difficulty || 'moderate',
      city: tour?.city || '',
      region: tour?.region || '',
      country: tour?.country || '',
      duration: version?.duration || '',
      distance: version?.distance || '',
      startLatitude: tour?.startLocation?.latitude || 0,
      startLongitude: tour?.startLocation?.longitude || 0,
    },
  });

  const formValues = form.watch();

  // Auto-save functionality (only for existing tours)
  const { isSaving: isAutoSaving, lastSaved, hasUnsavedChanges, saveNow } = useAutoSave({
    data: formValues,
    onSave: async (data) => {
      if (form.formState.isValid && !isNew) {
        await onSave(data);
      }
    },
    enabled: !isNew && form.formState.isValid,
    interval: 2 * 60 * 1000, // 2 minutes
  });

  const handleSubmit = async (data: TourFormValues) => {
    await onSave(data);
  };

  const handleImageUpload = async (file: File) => {
    if (!onCoverImageUpload) return;

    setIsUploadingImage(true);
    try {
      await onCoverImageUpload(file);
    } finally {
      setIsUploadingImage(false);
    }
  };

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-6">
        {/* Auto-save indicator */}
        {!isNew && (
          <div className="flex items-center justify-end gap-2 text-sm text-muted-foreground">
            {isAutoSaving && (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                <span>Saving...</span>
              </>
            )}
            {!isAutoSaving && lastSaved && (
              <>
                <Clock className="h-4 w-4" />
                <span>Last saved {formatDistanceToNow(lastSaved, { addSuffix: true })}</span>
              </>
            )}
            {hasUnsavedChanges && !isAutoSaving && (
              <span className="text-yellow-600 dark:text-yellow-500">Unsaved changes</span>
            )}
          </div>
        )}

        {/* Cover Image */}
        <Card>
          <CardHeader>
            <CardTitle>Cover Image</CardTitle>
          </CardHeader>
          <CardContent>
            <CoverImageUpload
              imageUrl={coverImageUrl}
              onUpload={handleImageUpload}
              isUploading={isUploadingImage}
              disabled={isNew} // Disable upload until tour is created
            />
            {isNew && (
              <p className="text-sm text-muted-foreground mt-2">
                You can add a cover image after creating the tour.
              </p>
            )}
          </CardContent>
        </Card>

        {/* Basic Info */}
        <Card>
          <CardHeader>
            <CardTitle>Basic Information</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <FormField
              control={form.control}
              name="title"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Tour Title</FormLabel>
                  <FormControl>
                    <Input placeholder="e.g., Historic Downtown Walking Tour" {...field} />
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
                      placeholder="Describe your tour, what visitors will see and experience..."
                      className="min-h-[120px]"
                      {...field}
                    />
                  </FormControl>
                  <FormDescription>
                    {field.value?.length || 0}/2000 characters
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid gap-4 sm:grid-cols-2">
              <FormField
                control={form.control}
                name="category"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Category</FormLabel>
                    <Select onValueChange={field.onChange} defaultValue={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Select a category" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {(Object.keys(categoryDisplayNames) as TourCategory[]).map((category) => (
                          <SelectItem key={category} value={category}>
                            {categoryDisplayNames[category]}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="tourType"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Tour Type</FormLabel>
                    <Select onValueChange={field.onChange} defaultValue={field.value}>
                      <FormControl>
                        <SelectTrigger>
                          <SelectValue placeholder="Select tour type" />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        <SelectItem value="walking">Walking Tour</SelectItem>
                        <SelectItem value="driving">Driving Tour</SelectItem>
                      </SelectContent>
                    </Select>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="difficulty"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Difficulty Level</FormLabel>
                  <Select onValueChange={field.onChange} defaultValue={field.value}>
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue placeholder="Select difficulty" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      {difficultyOptions.map((option) => (
                        <SelectItem key={option.value} value={option.value}>
                          <div>
                            <span className="font-medium">{option.label}</span>
                            <span className="text-muted-foreground ml-2">- {option.description}</span>
                          </div>
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid gap-4 sm:grid-cols-2">
              <FormField
                control={form.control}
                name="duration"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Estimated Duration</FormLabel>
                    <FormControl>
                      <Input placeholder="e.g., 1.5 hours" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="distance"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Distance</FormLabel>
                    <FormControl>
                      <Input placeholder="e.g., 2.5 km" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>
          </CardContent>
        </Card>

        {/* Location */}
        <Card>
          <CardHeader>
            <CardTitle>Location</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {/* Start Location Picker */}
            <div className="space-y-2">
              <label className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70">
                Start Location
              </label>
              <LocationPicker
                latitude={form.watch('startLatitude')}
                longitude={form.watch('startLongitude')}
                onLocationChange={(lat, lng, locationInfo) => {
                  form.setValue('startLatitude', lat, { shouldDirty: true });
                  form.setValue('startLongitude', lng, { shouldDirty: true });
                  // Auto-fill city, region, country if not already set
                  if (locationInfo) {
                    if (locationInfo.city && !form.getValues('city')) {
                      form.setValue('city', locationInfo.city, { shouldDirty: true });
                    }
                    if (locationInfo.region && !form.getValues('region')) {
                      form.setValue('region', locationInfo.region, { shouldDirty: true });
                    }
                    if (locationInfo.country && !form.getValues('country')) {
                      form.setValue('country', locationInfo.country, { shouldDirty: true });
                    }
                  }
                }}
              />
              <p className="text-sm text-muted-foreground">
                Click to choose the starting point using a map, address search, or coordinates
              </p>
              {(form.formState.errors.startLatitude || form.formState.errors.startLongitude) && (
                <p className="text-sm font-medium text-destructive">
                  Please select a valid start location
                </p>
              )}
            </div>

            <div className="grid gap-4 sm:grid-cols-3">
              <FormField
                control={form.control}
                name="city"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>City</FormLabel>
                    <FormControl>
                      <Input placeholder="e.g., San Francisco" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="region"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>State/Region</FormLabel>
                    <FormControl>
                      <Input placeholder="e.g., California" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="country"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Country</FormLabel>
                    <FormControl>
                      <Input placeholder="e.g., United States" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>
          </CardContent>
        </Card>

        {/* Submit Button */}
        <div className="flex justify-end gap-4">
          {!isNew && hasUnsavedChanges && (
            <Button type="button" variant="outline" onClick={saveNow} disabled={isAutoSaving}>
              <Save className="mr-2 h-4 w-4" />
              Save Now
            </Button>
          )}
          <Button type="submit" disabled={isSaving || isAutoSaving}>
            {isSaving ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                {isNew ? 'Creating...' : 'Saving...'}
              </>
            ) : (
              <>
                <Save className="mr-2 h-4 w-4" />
                {isNew ? 'Create Tour' : 'Save Changes'}
              </>
            )}
          </Button>
        </div>
      </form>
    </Form>
  );
}
