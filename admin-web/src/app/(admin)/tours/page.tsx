'use client';

import { useState } from 'react';
import { format } from 'date-fns';
import {
  Search,
  Star,
  StarOff,
  Eye,
  EyeOff,
  MoreHorizontal,
} from 'lucide-react';
import { AdminLayout } from '@/components/layout/admin-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
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
import { Textarea } from '@/components/ui/textarea';
import { useToast } from '@/hooks/use-toast';
import { useTours, useFeatureTour, useHideTour, useUnhideTour } from '@/hooks/use-tours';
import {
  TourModel,
  TourStatus,
  TourCategory,
  categoryDisplayNames,
  statusDisplayNames,
} from '@/types';

const statusOptions: { value: TourStatus | 'all'; label: string }[] = [
  { value: 'all', label: 'All Statuses' },
  { value: 'draft', label: 'Draft' },
  { value: 'pending_review', label: 'Pending Review' },
  { value: 'approved', label: 'Approved' },
  { value: 'rejected', label: 'Rejected' },
  { value: 'hidden', label: 'Hidden' },
];

const categoryOptions: { value: TourCategory | 'all'; label: string }[] = [
  { value: 'all', label: 'All Categories' },
  { value: 'history', label: 'History' },
  { value: 'nature', label: 'Nature' },
  { value: 'ghost', label: 'Ghost Tour' },
  { value: 'food', label: 'Food & Drink' },
  { value: 'art', label: 'Art' },
  { value: 'architecture', label: 'Architecture' },
  { value: 'other', label: 'Other' },
];

function getStatusBadgeVariant(status: TourStatus): 'default' | 'secondary' | 'destructive' | 'outline' {
  switch (status) {
    case 'approved':
      return 'default';
    case 'pending_review':
      return 'secondary';
    case 'rejected':
    case 'hidden':
      return 'destructive';
    default:
      return 'outline';
  }
}

export default function ToursPage() {
  const { toast } = useToast();
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<TourStatus | 'all'>('all');
  const [categoryFilter, setCategoryFilter] = useState<TourCategory | 'all'>('all');
  const [hideDialogOpen, setHideDialogOpen] = useState(false);
  const [selectedTour, setSelectedTour] = useState<TourModel | null>(null);
  const [hideReason, setHideReason] = useState('');

  const { data: tours, isLoading } = useTours({
    status: statusFilter === 'all' ? undefined : statusFilter,
    category: categoryFilter === 'all' ? undefined : categoryFilter,
    searchQuery: searchQuery || undefined,
  });

  const featureMutation = useFeatureTour();
  const hideMutation = useHideTour();
  const unhideMutation = useUnhideTour();

  const handleFeatureToggle = async (tour: TourModel) => {
    try {
      await featureMutation.mutateAsync({
        tourId: tour.id,
        featured: !tour.featured,
      });
      toast({
        title: tour.featured ? 'Tour unfeatured' : 'Tour featured',
        description: tour.featured
          ? 'The tour has been removed from featured.'
          : 'The tour is now featured.',
      });
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to update tour. Please try again.',
      });
    }
  };

  const handleHide = async () => {
    if (!selectedTour) return;

    try {
      await hideMutation.mutateAsync({
        tourId: selectedTour.id,
        reason: hideReason || undefined,
      });
      toast({
        title: 'Tour hidden',
        description: 'The tour has been hidden from public view.',
      });
      setHideDialogOpen(false);
      setSelectedTour(null);
      setHideReason('');
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to hide tour. Please try again.',
      });
    }
  };

  const handleUnhide = async (tour: TourModel) => {
    try {
      await unhideMutation.mutateAsync(tour.id);
      toast({
        title: 'Tour unhidden',
        description: 'The tour is now visible again.',
      });
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to unhide tour. Please try again.',
      });
    }
  };

  const filteredTours = tours?.filter((tour) => {
    if (searchQuery) {
      const search = searchQuery.toLowerCase();
      return (
        tour.creatorName.toLowerCase().includes(search) ||
        tour.city?.toLowerCase().includes(search) ||
        tour.country?.toLowerCase().includes(search)
      );
    }
    return true;
  });

  return (
    <AdminLayout title="All Tours">
      <Card>
        <CardHeader>
          <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
            <CardTitle>Tours ({filteredTours?.length ?? 0})</CardTitle>
            <div className="flex flex-wrap items-center gap-2">
              <div className="relative">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  placeholder="Search by creator, city..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-9 sm:w-64"
                />
              </div>
              <Select
                value={statusFilter}
                onValueChange={(v) => setStatusFilter(v as TourStatus | 'all')}
              >
                <SelectTrigger className="w-40">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {statusOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
              <Select
                value={categoryFilter}
                onValueChange={(v) => setCategoryFilter(v as TourCategory | 'all')}
              >
                <SelectTrigger className="w-40">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {categoryOptions.map((option) => (
                    <SelectItem key={option.value} value={option.value}>
                      {option.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="flex items-center justify-center py-8">
              <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
            </div>
          ) : filteredTours && filteredTours.length > 0 ? (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Tour</TableHead>
                  <TableHead>Creator</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Stats</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead className="w-[70px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredTours.map((tour) => (
                  <TableRow key={tour.id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        {tour.featured && (
                          <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
                        )}
                        <span className="font-medium">
                          {tour.city || 'Unknown location'}
                        </span>
                      </div>
                    </TableCell>
                    <TableCell>{tour.creatorName}</TableCell>
                    <TableCell>
                      <Badge variant={getStatusBadgeVariant(tour.status)}>
                        {statusDisplayNames[tour.status]}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">
                        {categoryDisplayNames[tour.category]}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="text-sm text-muted-foreground">
                        {tour.stats.totalPlays} plays
                      </div>
                    </TableCell>
                    <TableCell className="text-muted-foreground">
                      {format(tour.createdAt, 'MMM d, yyyy')}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem
                            onClick={() => handleFeatureToggle(tour)}
                            disabled={tour.status !== 'approved'}
                          >
                            {tour.featured ? (
                              <>
                                <StarOff className="mr-2 h-4 w-4" />
                                Unfeature
                              </>
                            ) : (
                              <>
                                <Star className="mr-2 h-4 w-4" />
                                Feature
                              </>
                            )}
                          </DropdownMenuItem>
                          {tour.status === 'hidden' ? (
                            <DropdownMenuItem onClick={() => handleUnhide(tour)}>
                              <Eye className="mr-2 h-4 w-4" />
                              Unhide
                            </DropdownMenuItem>
                          ) : (
                            <DropdownMenuItem
                              onClick={() => {
                                setSelectedTour(tour);
                                setHideDialogOpen(true);
                              }}
                              className="text-destructive"
                            >
                              <EyeOff className="mr-2 h-4 w-4" />
                              Hide
                            </DropdownMenuItem>
                          )}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <div className="py-8 text-center text-muted-foreground">
              No tours found
            </div>
          )}
        </CardContent>
      </Card>

      {/* Hide Dialog */}
      <Dialog open={hideDialogOpen} onOpenChange={setHideDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Hide Tour</DialogTitle>
            <DialogDescription>
              This will hide the tour from public view. You can optionally
              provide a reason.
            </DialogDescription>
          </DialogHeader>
          <Textarea
            placeholder="Reason for hiding (optional)..."
            value={hideReason}
            onChange={(e) => setHideReason(e.target.value)}
            rows={3}
          />
          <DialogFooter>
            <Button variant="outline" onClick={() => setHideDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={handleHide}
              disabled={hideMutation.isPending}
            >
              {hideMutation.isPending ? 'Hiding...' : 'Hide Tour'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </AdminLayout>
  );
}
