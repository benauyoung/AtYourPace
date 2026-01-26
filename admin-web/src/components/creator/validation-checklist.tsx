'use client';

import { useMemo } from 'react';
import {
  Check,
  X,
  AlertCircle,
  CheckCircle2,
  Circle,
  Type,
  FileText,
  Image as ImageIcon,
  MapPin,
  Volume2,
} from 'lucide-react';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { cn } from '@/lib/utils';
import { TourVersionModel, StopModel } from '@/types';

interface ValidationItem {
  id: string;
  label: string;
  description?: string;
  passed: boolean;
  required: boolean;
  icon: typeof Check;
}

interface ValidationChecklistProps {
  tour: TourVersionModel;
  stops: StopModel[];
  className?: string;
}

export function ValidationChecklist({
  tour,
  stops,
  className,
}: ValidationChecklistProps) {
  const validationItems = useMemo(() => {
    const items: ValidationItem[] = [
      {
        id: 'title',
        label: 'Tour title',
        description: tour.title ? `"${tour.title}"` : 'Add a title for your tour',
        passed: !!tour.title && tour.title.trim().length >= 3,
        required: true,
        icon: Type,
      },
      {
        id: 'description',
        label: 'Tour description',
        description: tour.description
          ? `${tour.description.slice(0, 50)}...`
          : 'Add a description to attract visitors',
        passed: !!tour.description && tour.description.trim().length >= 20,
        required: true,
        icon: FileText,
      },
      {
        id: 'coverImage',
        label: 'Cover image',
        description: tour.coverImageUrl
          ? 'Cover image uploaded'
          : 'Upload a cover image for your tour',
        passed: !!tour.coverImageUrl,
        required: true,
        icon: ImageIcon,
      },
      {
        id: 'minStops',
        label: 'At least 2 stops',
        description: `${stops.length} stop${stops.length !== 1 ? 's' : ''} added`,
        passed: stops.length >= 2,
        required: true,
        icon: MapPin,
      },
      {
        id: 'allStopsHaveAudio',
        label: 'Audio for all stops',
        description: stops.every((s) => s.media.audioUrl)
          ? 'All stops have audio'
          : `${stops.filter((s) => s.media.audioUrl).length}/${stops.length} stops have audio`,
        passed: stops.length > 0 && stops.every((s) => s.media.audioUrl),
        required: true,
        icon: Volume2,
      },
      {
        id: 'allStopsHaveImages',
        label: 'Images for all stops',
        description: stops.every((s) => s.media.images?.length > 0)
          ? 'All stops have images'
          : `${stops.filter((s) => s.media.images?.length > 0).length}/${stops.length} stops have images`,
        passed: stops.length > 0 && stops.every((s) => s.media.images?.length > 0),
        required: false,
        icon: ImageIcon,
      },
      {
        id: 'stopNames',
        label: 'All stops named',
        description: stops.every((s) => s.name && s.name.trim().length > 0)
          ? 'All stops have names'
          : 'Some stops are missing names',
        passed: stops.length > 0 && stops.every((s) => s.name && s.name.trim().length > 0),
        required: true,
        icon: Type,
      },
    ];

    return items;
  }, [tour, stops]);

  const requiredItems = validationItems.filter((item) => item.required);
  const optionalItems = validationItems.filter((item) => !item.required);

  const requiredPassed = requiredItems.filter((item) => item.passed).length;
  const allRequiredPassed = requiredPassed === requiredItems.length;
  const optionalPassed = optionalItems.filter((item) => item.passed).length;

  return (
    <div className={cn('space-y-4', className)}>
      {/* Summary */}
      {allRequiredPassed ? (
        <Alert className="border-green-200 bg-green-50 dark:bg-green-950/20 dark:border-green-900">
          <CheckCircle2 className="h-4 w-4 text-green-600" />
          <AlertTitle className="text-green-800 dark:text-green-400">
            Ready to submit!
          </AlertTitle>
          <AlertDescription className="text-green-700 dark:text-green-500">
            All required items are complete. You can submit your tour for review.
          </AlertDescription>
        </Alert>
      ) : (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>Not ready for submission</AlertTitle>
          <AlertDescription>
            {requiredItems.length - requiredPassed} required item
            {requiredItems.length - requiredPassed !== 1 ? 's' : ''} still
            {requiredItems.length - requiredPassed === 1 ? 'needs' : 'need'} to be completed.
          </AlertDescription>
        </Alert>
      )}

      {/* Required items */}
      <div>
        <h4 className="text-sm font-medium mb-2 flex items-center gap-2">
          Required
          <span className="text-xs text-muted-foreground">
            ({requiredPassed}/{requiredItems.length})
          </span>
        </h4>
        <div className="space-y-1">
          {requiredItems.map((item) => (
            <ValidationItemRow key={item.id} item={item} />
          ))}
        </div>
      </div>

      {/* Optional items */}
      {optionalItems.length > 0 && (
        <div>
          <h4 className="text-sm font-medium mb-2 flex items-center gap-2">
            Recommended
            <span className="text-xs text-muted-foreground">
              ({optionalPassed}/{optionalItems.length})
            </span>
          </h4>
          <div className="space-y-1">
            {optionalItems.map((item) => (
              <ValidationItemRow key={item.id} item={item} />
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

interface ValidationItemRowProps {
  item: ValidationItem;
}

function ValidationItemRow({ item }: ValidationItemRowProps) {
  const Icon = item.icon;

  return (
    <div
      className={cn(
        'flex items-start gap-3 p-3 rounded-lg border',
        item.passed
          ? 'border-green-200 bg-green-50/50 dark:bg-green-950/10 dark:border-green-900/50'
          : item.required
          ? 'border-red-200 bg-red-50/50 dark:bg-red-950/10 dark:border-red-900/50'
          : 'border-gray-200 dark:border-gray-800'
      )}
    >
      <div
        className={cn(
          'flex-shrink-0 p-1.5 rounded-full',
          item.passed
            ? 'bg-green-100 text-green-600 dark:bg-green-900/30 dark:text-green-400'
            : item.required
            ? 'bg-red-100 text-red-600 dark:bg-red-900/30 dark:text-red-400'
            : 'bg-gray-100 text-gray-500 dark:bg-gray-800 dark:text-gray-400'
        )}
      >
        <Icon className="h-4 w-4" />
      </div>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span
            className={cn(
              'text-sm font-medium',
              item.passed
                ? 'text-green-800 dark:text-green-400'
                : item.required
                ? 'text-red-800 dark:text-red-400'
                : 'text-foreground'
            )}
          >
            {item.label}
          </span>
          {item.passed ? (
            <Check className="h-4 w-4 text-green-600 dark:text-green-400" />
          ) : item.required ? (
            <X className="h-4 w-4 text-red-600 dark:text-red-400" />
          ) : (
            <Circle className="h-3 w-3 text-gray-400" />
          )}
        </div>
        {item.description && (
          <p className="text-xs text-muted-foreground mt-0.5 truncate">
            {item.description}
          </p>
        )}
      </div>
    </div>
  );
}

// Hook to check validation status
export function useValidationStatus(tour: TourVersionModel, stops: StopModel[]) {
  return useMemo(() => {
    const hasTitle = !!tour.title && tour.title.trim().length >= 3;
    const hasDescription = !!tour.description && tour.description.trim().length >= 20;
    const hasCoverImage = !!tour.coverImageUrl;
    const hasMinStops = stops.length >= 2;
    const allStopsHaveAudio = stops.length > 0 && stops.every((s) => s.media.audioUrl);
    const allStopsNamed = stops.length > 0 && stops.every((s) => s.name && s.name.trim().length > 0);

    const isValid =
      hasTitle &&
      hasDescription &&
      hasCoverImage &&
      hasMinStops &&
      allStopsHaveAudio &&
      allStopsNamed;

    return {
      isValid,
      hasTitle,
      hasDescription,
      hasCoverImage,
      hasMinStops,
      allStopsHaveAudio,
      allStopsNamed,
    };
  }, [tour, stops]);
}
