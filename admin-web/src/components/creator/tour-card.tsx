'use client';

import { useState } from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { formatDistanceToNow } from 'date-fns';
import {
  MoreHorizontal,
  Edit,
  Copy,
  Trash2,
  Map,
  MapPin,
  Clock,
  Eye,
} from 'lucide-react';
import { TourModel, TourVersionModel, statusDisplayNames, categoryDisplayNames } from '@/types';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';

interface TourCardProps {
  tour: TourModel;
  version?: TourVersionModel;
  onDuplicate?: (tourId: string) => void;
  onDelete?: (tourId: string) => void;
  isDeleting?: boolean;
  isDuplicating?: boolean;
}

const statusColors: Record<TourModel['status'], string> = {
  draft: 'bg-muted text-muted-foreground',
  pending_review: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
  approved: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
  rejected: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
  hidden: 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200',
};

export function TourCard({
  tour,
  version,
  onDuplicate,
  onDelete,
  isDeleting,
  isDuplicating,
}: TourCardProps) {
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);

  const canDelete = tour.status === 'draft' || tour.status === 'rejected';
  const canEdit = tour.status !== 'pending_review';

  const handleDuplicate = () => {
    onDuplicate?.(tour.id);
  };

  const handleDelete = () => {
    setShowDeleteDialog(false);
    onDelete?.(tour.id);
  };

  const locationText = [tour.city, tour.region, tour.country]
    .filter(Boolean)
    .join(', ') || 'Location not set';

  return (
    <>
      <Card className="overflow-hidden hover:shadow-md transition-shadow">
        {/* Cover Image */}
        <div className="relative aspect-video bg-muted">
          {version?.coverImageUrl ? (
            <Image
              src={version.coverImageUrl}
              alt={version.title || 'Tour cover'}
              fill
              className="object-cover"
            />
          ) : (
            <div className="flex h-full items-center justify-center">
              <Map className="h-12 w-12 text-muted-foreground/50" />
            </div>
          )}
          {/* Status Badge */}
          <div className="absolute top-2 left-2">
            <Badge className={statusColors[tour.status]}>
              {statusDisplayNames[tour.status]}
            </Badge>
          </div>
          {/* Category Badge */}
          <div className="absolute top-2 right-2">
            <Badge variant="secondary">
              {categoryDisplayNames[tour.category]}
            </Badge>
          </div>
        </div>

        <CardHeader className="pb-2">
          <div className="flex items-start justify-between gap-2">
            <div className="flex-1 min-w-0">
              <h3 className="font-semibold text-lg truncate">
                {version?.title || 'Untitled Tour'}
              </h3>
              <p className="text-sm text-muted-foreground flex items-center gap-1 truncate">
                <MapPin className="h-3 w-3 flex-shrink-0" />
                {locationText}
              </p>
            </div>

            {/* Actions Menu */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="icon" className="h-8 w-8 flex-shrink-0">
                  <MoreHorizontal className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                {canEdit && (
                  <DropdownMenuItem asChild>
                    <Link href={`/tour/${tour.id}/edit`}>
                      <Edit className="mr-2 h-4 w-4" />
                      Edit Tour
                    </Link>
                  </DropdownMenuItem>
                )}
                <DropdownMenuItem asChild>
                  <Link href={`/tour/${tour.id}/stops`}>
                    <MapPin className="mr-2 h-4 w-4" />
                    Manage Stops
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuItem asChild>
                  <Link href={`/tour/${tour.id}/preview`}>
                    <Eye className="mr-2 h-4 w-4" />
                    Preview
                  </Link>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleDuplicate} disabled={isDuplicating}>
                  <Copy className="mr-2 h-4 w-4" />
                  {isDuplicating ? 'Duplicating...' : 'Duplicate'}
                </DropdownMenuItem>
                {canDelete && (
                  <>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem
                      onClick={() => setShowDeleteDialog(true)}
                      className="text-destructive focus:text-destructive"
                      disabled={isDeleting}
                    >
                      <Trash2 className="mr-2 h-4 w-4" />
                      Delete
                    </DropdownMenuItem>
                  </>
                )}
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </CardHeader>

        <CardContent className="pt-0">
          {/* Description */}
          {version?.description && (
            <p className="text-sm text-muted-foreground line-clamp-2 mb-3">
              {version.description}
            </p>
          )}

          {/* Stats row */}
          <div className="flex items-center gap-4 text-sm text-muted-foreground">
            {version?.duration && (
              <span className="flex items-center gap-1">
                <Clock className="h-3 w-3" />
                {version.duration}
              </span>
            )}
            <span className="flex items-center gap-1">
              {tour.tourType === 'walking' ? 'Walking' : 'Driving'}
            </span>
            <span className="ml-auto text-xs">
              Updated {formatDistanceToNow(tour.updatedAt, { addSuffix: true })}
            </span>
          </div>

          {/* Rejection reason */}
          {tour.status === 'rejected' && tour.rejectionReason && (
            <div className="mt-3 p-2 rounded bg-destructive/10 text-destructive text-sm">
              <strong>Rejected:</strong> {tour.rejectionReason}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Delete Confirmation Dialog */}
      <Dialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Delete Tour</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete &quot;{version?.title || 'this tour'}&quot;? This action cannot be undone.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowDeleteDialog(false)}>
              Cancel
            </Button>
            <Button variant="destructive" onClick={handleDelete} disabled={isDeleting}>
              {isDeleting ? 'Deleting...' : 'Delete'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </>
  );
}
