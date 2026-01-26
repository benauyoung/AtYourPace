'use client';

import { useState, useMemo } from 'react';
import { useRouter, useParams } from 'next/navigation';
import {
  MapPin,
  User,
  Clock,
  ChevronLeft,
  Check,
  X,
  Mic,
  Image as ImageIcon,
  ChevronDown,
  ChevronUp,
} from 'lucide-react';
import { AdminLayout } from '@/components/layout/admin-layout';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Separator } from '@/components/ui/separator';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible';
import { useToast } from '@/hooks/use-toast';
import {
  useTour,
  useTourVersion,
  useTourStops,
  useApproveTour,
  useRejectTour,
  useReviewComments,
  useAddReviewComment,
  useDeleteReviewComment,
  useResolveReviewComment,
} from '@/hooks/use-tours';
import { categoryDisplayNames, statusDisplayNames, StopModel, ReviewCommentModel } from '@/types';

// Admin components
import { TourMapPreview } from '@/components/admin/tour-map-preview';
import { StopAudioPlayer } from '@/components/admin/stop-audio-player';
import { StopComments, StopComment, StopCommentsBadge } from '@/components/admin/stop-comments';
import { RejectionDialog } from '@/components/admin/rejection-dialog';
import { useAuth } from '@/hooks/use-auth';

export default function TourReviewPage() {
  const router = useRouter();
  const params = useParams();
  const tourId = params.tourId as string;
  const { toast } = useToast();
  const { user } = useAuth();

  const { data: tour, isLoading: tourLoading } = useTour(tourId);
  const { data: version, isLoading: versionLoading } = useTourVersion(
    tourId,
    tour?.draftVersionId ?? null
  );
  const { data: stops, isLoading: stopsLoading } = useTourStops(
    tourId,
    tour?.draftVersionId ?? null
  );

  const approveMutation = useApproveTour();
  const rejectMutation = useRejectTour();

  // Review comments - persisted to Firestore
  const { data: reviewComments = [], isLoading: commentsLoading } = useReviewComments(
    tourId,
    tour?.draftVersionId ?? null
  );
  const addCommentMutation = useAddReviewComment();
  const deleteCommentMutation = useDeleteReviewComment();
  const resolveCommentMutation = useResolveReviewComment();

  const [approveDialogOpen, setApproveDialogOpen] = useState(false);
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false);
  const [notes, setNotes] = useState('');
  const [expandedStops, setExpandedStops] = useState<Set<string>>(new Set());

  const isLoading = tourLoading || versionLoading || stopsLoading || commentsLoading;

  // Group comments by stopId
  const stopComments = useMemo(() => {
    const grouped: Record<string, StopComment[]> = {};
    reviewComments.forEach((comment: ReviewCommentModel) => {
      if (!grouped[comment.stopId]) {
        grouped[comment.stopId] = [];
      }
      grouped[comment.stopId].push({
        id: comment.id,
        stopId: comment.stopId,
        authorId: comment.authorId,
        authorName: comment.authorName,
        authorEmail: comment.authorEmail,
        content: comment.content,
        createdAt: comment.createdAt,
        resolved: comment.resolved,
        resolvedAt: comment.resolvedAt,
        resolvedBy: comment.resolvedBy,
      });
    });
    return grouped;
  }, [reviewComments]);

  // Get stops with their comments for the rejection dialog
  const stopsWithComments = useMemo(() => {
    if (!stops) return [];
    return stops.map((stop) => ({
      stopId: stop.id,
      stopName: stop.name,
      comments: stopComments[stop.id] || [],
    }));
  }, [stops, stopComments]);

  const handleApprove = async () => {
    try {
      await approveMutation.mutateAsync({ tourId, notes: notes || undefined });
      toast({
        title: 'Tour approved',
        description: 'The tour has been approved and published.',
      });
      router.push('/review-queue');
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to approve tour. Please try again.',
      });
    }
  };

  const handleReject = async (reason: string, includeComments: boolean) => {
    try {
      await rejectMutation.mutateAsync({ tourId, reason, includeComments });
      toast({
        title: 'Tour rejected',
        description: 'The creator has been notified of the rejection.',
      });
      router.push('/review-queue');
    } catch {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to reject tour. Please try again.',
      });
    }
  };

  const handleAddComment = async (stopId: string, content: string) => {
    if (!tour?.draftVersionId) return;

    await addCommentMutation.mutateAsync({
      tourId,
      versionId: tour.draftVersionId,
      stopId,
      content,
    });
  };

  const handleDeleteComment = async (commentId: string) => {
    if (!tour?.draftVersionId) return;

    await deleteCommentMutation.mutateAsync({
      commentId,
      tourId,
      versionId: tour.draftVersionId,
    });
  };

  const handleResolveComment = async (commentId: string) => {
    if (!tour?.draftVersionId) return;

    await resolveCommentMutation.mutateAsync({
      commentId,
      tourId,
      versionId: tour.draftVersionId,
    });
  };

  const toggleStopExpanded = (stopId: string) => {
    setExpandedStops((prev) => {
      const next = new Set(prev);
      if (next.has(stopId)) {
        next.delete(stopId);
      } else {
        next.add(stopId);
      }
      return next;
    });
  };

  if (isLoading) {
    return (
      <AdminLayout title="Review Tour">
        <div className="flex items-center justify-center py-8">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>
      </AdminLayout>
    );
  }

  if (!tour || !version) {
    return (
      <AdminLayout title="Review Tour">
        <Card>
          <CardContent className="py-8 text-center">
            <p className="text-muted-foreground">Tour not found</p>
            <Button
              variant="link"
              onClick={() => router.push('/review-queue')}
            >
              Back to review queue
            </Button>
          </CardContent>
        </Card>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout title="Review Tour">
      <div className="space-y-6">
        {/* Back button */}
        <Button
          variant="ghost"
          onClick={() => router.push('/review-queue')}
          className="gap-2"
        >
          <ChevronLeft className="h-4 w-4" />
          Back to queue
        </Button>

        {/* Tour Header */}
        <Card>
          <CardHeader>
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <CardTitle className="text-2xl">{version.title}</CardTitle>
                <div className="flex items-center gap-2">
                  <Badge variant="secondary">
                    {categoryDisplayNames[tour.category]}
                  </Badge>
                  <Badge variant="outline">{tour.tourType}</Badge>
                  <Badge>{statusDisplayNames[tour.status]}</Badge>
                </div>
              </div>
              {version.coverImageUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={version.coverImageUrl}
                  alt={version.title}
                  className="h-24 w-32 rounded-lg object-cover"
                />
              )}
            </div>
          </CardHeader>
          <CardContent className="space-y-4">
            <p className="text-muted-foreground">{version.description}</p>

            <div className="flex flex-wrap items-center gap-4 text-sm">
              <span className="flex items-center gap-1">
                <User className="h-4 w-4" />
                {tour.creatorName}
              </span>
              {tour.city && (
                <span className="flex items-center gap-1">
                  <MapPin className="h-4 w-4" />
                  {tour.city}, {tour.country}
                </span>
              )}
              {version.duration && (
                <span className="flex items-center gap-1">
                  <Clock className="h-4 w-4" />
                  {version.duration}
                </span>
              )}
              {version.distance && (
                <span className="flex items-center gap-1">
                  <MapPin className="h-4 w-4" />
                  {version.distance}
                </span>
              )}
            </div>

            <Separator />

            <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
              <div className="text-center">
                <div className="text-2xl font-bold">{tour.stats.totalPlays}</div>
                <div className="text-xs text-muted-foreground">Plays</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold">{tour.stats.totalDownloads}</div>
                <div className="text-xs text-muted-foreground">Downloads</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold">
                  {tour.stats.averageRating.toFixed(1)}
                </div>
                <div className="text-xs text-muted-foreground">Rating</div>
              </div>
              <div className="text-center">
                <div className="text-2xl font-bold">{stops?.length ?? 0}</div>
                <div className="text-xs text-muted-foreground">Stops</div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Map Preview */}
        {stops && stops.length > 0 && (
          <TourMapPreview
            stops={stops}
            startLocation={tour.startLocation}
          />
        )}

        {/* Tour Stops */}
        <Card>
          <CardHeader>
            <CardTitle>Tour Stops ({stops?.length ?? 0})</CardTitle>
          </CardHeader>
          <CardContent>
            {stops && stops.length > 0 ? (
              <div className="space-y-4">
                {stops.map((stop, index) => (
                  <StopReviewCard
                    key={stop.id}
                    stop={stop}
                    index={index}
                    isExpanded={expandedStops.has(stop.id)}
                    onToggleExpand={() => toggleStopExpanded(stop.id)}
                    comments={stopComments[stop.id] || []}
                    onAddComment={(content) => handleAddComment(stop.id, content)}
                    onDeleteComment={handleDeleteComment}
                    onResolveComment={handleResolveComment}
                    currentUserId={user?.uid}
                  />
                ))}
              </div>
            ) : (
              <p className="py-4 text-center text-muted-foreground">
                No stops in this tour
              </p>
            )}
          </CardContent>
        </Card>

        {/* Review Notes */}
        <Card>
          <CardHeader>
            <CardTitle>Review Notes (Optional)</CardTitle>
          </CardHeader>
          <CardContent>
            <Textarea
              placeholder="Add any notes about this tour..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={3}
            />
          </CardContent>
        </Card>

        {/* Action Buttons */}
        <div className="flex justify-end gap-4">
          <Button
            variant="destructive"
            onClick={() => setRejectDialogOpen(true)}
            disabled={approveMutation.isPending || rejectMutation.isPending}
          >
            <X className="mr-2 h-4 w-4" />
            Reject
          </Button>
          <Button
            onClick={() => setApproveDialogOpen(true)}
            disabled={approveMutation.isPending || rejectMutation.isPending}
          >
            <Check className="mr-2 h-4 w-4" />
            Approve
          </Button>
        </div>

        {/* Approve Dialog */}
        <Dialog open={approveDialogOpen} onOpenChange={setApproveDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Approve Tour</DialogTitle>
              <DialogDescription>
                This will publish the tour and make it available to all users.
              </DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button
                variant="outline"
                onClick={() => setApproveDialogOpen(false)}
              >
                Cancel
              </Button>
              <Button
                onClick={handleApprove}
                disabled={approveMutation.isPending}
              >
                {approveMutation.isPending ? 'Approving...' : 'Approve'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Enhanced Rejection Dialog */}
        <RejectionDialog
          isOpen={rejectDialogOpen}
          onClose={() => setRejectDialogOpen(false)}
          onReject={handleReject}
          tourTitle={version.title}
          stopsWithComments={stopsWithComments}
          isSubmitting={rejectMutation.isPending}
        />
      </div>
    </AdminLayout>
  );
}

// Stop review card with expandable details
interface StopReviewCardProps {
  stop: StopModel;
  index: number;
  isExpanded: boolean;
  onToggleExpand: () => void;
  comments: StopComment[];
  onAddComment: (content: string) => Promise<void>;
  onDeleteComment: (commentId: string) => Promise<void>;
  onResolveComment: (commentId: string) => Promise<void>;
  currentUserId?: string;
}

function StopReviewCard({
  stop,
  index,
  isExpanded,
  onToggleExpand,
  comments,
  onAddComment,
  onDeleteComment,
  onResolveComment,
  currentUserId,
}: StopReviewCardProps) {
  const unresolvedCount = comments.filter((c) => !c.resolved).length;

  return (
    <Collapsible open={isExpanded} onOpenChange={onToggleExpand}>
      <div className="rounded-lg border">
        {/* Header - always visible */}
        <CollapsibleTrigger asChild>
          <button className="flex w-full items-start gap-4 p-4 text-left hover:bg-muted/50 transition-colors">
            <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-primary text-sm font-medium text-primary-foreground">
              {index + 1}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2">
                <h4 className="font-medium">{stop.name}</h4>
                {comments.length > 0 && (
                  <StopCommentsBadge
                    count={comments.length}
                    unresolvedCount={unresolvedCount}
                  />
                )}
              </div>
              <div className="flex items-center gap-3 text-xs text-muted-foreground mt-1">
                {stop.media.audioUrl && (
                  <span className="flex items-center gap-1">
                    <Mic className="h-3 w-3" />
                    Audio
                    {stop.media.audioDuration &&
                      ` (${Math.floor(stop.media.audioDuration / 60)}:${String(
                        Math.floor(stop.media.audioDuration % 60)
                      ).padStart(2, '0')})`}
                  </span>
                )}
                {stop.media.images && stop.media.images.length > 0 && (
                  <span className="flex items-center gap-1">
                    <ImageIcon className="h-3 w-3" />
                    {stop.media.images.length} image
                    {stop.media.images.length !== 1 ? 's' : ''}
                  </span>
                )}
              </div>
            </div>
            {isExpanded ? (
              <ChevronUp className="h-5 w-5 text-muted-foreground" />
            ) : (
              <ChevronDown className="h-5 w-5 text-muted-foreground" />
            )}
          </button>
        </CollapsibleTrigger>

        {/* Expanded content */}
        <CollapsibleContent>
          <div className="border-t p-4 space-y-4">
            {/* Description */}
            {stop.description && (
              <p className="text-sm text-muted-foreground">{stop.description}</p>
            )}

            {/* Audio player */}
            {stop.media.audioUrl && (
              <div>
                <p className="text-xs font-medium mb-2">Audio Narration</p>
                <StopAudioPlayer
                  audioUrl={stop.media.audioUrl}
                  duration={stop.media.audioDuration}
                />
              </div>
            )}

            {/* Images */}
            {stop.media.images && stop.media.images.length > 0 && (
              <div>
                <p className="text-xs font-medium mb-2">Images</p>
                <div className="grid grid-cols-4 gap-2">
                  {stop.media.images.slice(0, 4).map((image, i) => (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      key={image.url}
                      src={image.url}
                      alt={image.caption || `Stop image ${i + 1}`}
                      className="aspect-square rounded-lg object-cover"
                    />
                  ))}
                  {stop.media.images.length > 4 && (
                    <div className="aspect-square rounded-lg bg-muted flex items-center justify-center text-sm text-muted-foreground">
                      +{stop.media.images.length - 4}
                    </div>
                  )}
                </div>
              </div>
            )}

            {/* Comments section */}
            <Separator />
            <StopComments
              stopId={stop.id}
              stopName={stop.name}
              comments={comments}
              onAddComment={(_, content) => onAddComment(content)}
              onDeleteComment={onDeleteComment}
              onResolveComment={onResolveComment}
              currentUserId={currentUserId}
            />
          </div>
        </CollapsibleContent>
      </div>
    </Collapsible>
  );
}
