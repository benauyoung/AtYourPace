'use client';

import { AdminLayout } from '@/components/layout/admin-layout';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
    Collapsible,
    CollapsibleContent,
    CollapsibleTrigger,
} from '@/components/ui/collapsible';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import { Separator } from '@/components/ui/separator';
import { Textarea } from '@/components/ui/textarea';
import { useAuth } from '@/hooks/use-auth';
import { useToast } from '@/hooks/use-toast';
import {
    useAddSubmissionFeedback,
    useResolveSubmissionFeedback,
    useSubmission,
    useTour,
    useTourStops,
    useTourVersion,
    useUpdateSubmissionStatus,
} from '@/hooks/use-tours';
import {
    categoryDisplayNames,
    ReviewFeedbackModel,
    StopModel
} from '@/types';
import {
    Check,
    ChevronDown,
    ChevronLeft,
    ChevronUp,
    Clock,
    Image as ImageIcon,
    MapPin,
    Mic,
    User,
    X,
} from 'lucide-react';
import { useParams, useRouter } from 'next/navigation';
import { useMemo, useState } from 'react';

// Admin components
import { RejectionDialog } from '@/components/admin/rejection-dialog';
import { StopAudioPlayer } from '@/components/admin/stop-audio-player';
import { StopComment, StopComments, StopCommentsBadge } from '@/components/admin/stop-comments'; // Need to update StopComments to handle FeedbackModel if types differ
import { TourMapPreview } from '@/components/admin/tour-map-preview';

export default function TourReviewPage() {
    const router = useRouter();
    const params = useParams();
    const submissionId = params.submissionId as string;
    const { toast } = useToast();
    const { user } = useAuth();

    const { data: submission, isLoading: submissionLoading } = useSubmission(submissionId);
    const { data: tour, isLoading: tourLoading } = useTour(submission?.tourId ?? null);
    const { data: version, isLoading: versionLoading } = useTourVersion(
        submission?.tourId ?? null,
        submission?.versionId ?? null
    );
    const { data: stops, isLoading: stopsLoading } = useTourStops(
        submission?.tourId ?? null,
        submission?.versionId ?? null
    );

    const updateStatusMutation = useUpdateSubmissionStatus();
    const addFeedbackMutation = useAddSubmissionFeedback();
    const resolveFeedbackMutation = useResolveSubmissionFeedback();

    const [approveDialogOpen, setApproveDialogOpen] = useState(false);
    const [rejectDialogOpen, setRejectDialogOpen] = useState(false);
    const [notes, setNotes] = useState('');
    const [expandedStops, setExpandedStops] = useState<Set<string>>(new Set());

    const isLoading = submissionLoading || tourLoading || versionLoading || stopsLoading;

    // Group feedback by stopId
    // ReviewFeedbackModel has structure compatible with StopComment for display purposes?
    // StopComment interface: id, stopId, authorId, authorName, authorEmail, content, createdAt, resolved, resolvedAt, resolvedBy
    // ReviewFeedbackModel: id, submissionId, reviewerId, reviewerName, type, message, stopId, ...
    const stopFeedback = useMemo(() => {
        const grouped: Record<string, StopComment[]> = {};
        if (!submission?.feedback) return grouped;

        submission.feedback.forEach((item: ReviewFeedbackModel) => {
            if (!item.stopId) return;

            if (!grouped[item.stopId]) {
                grouped[item.stopId] = [];
            }

            grouped[item.stopId].push({
                id: item.id,
                stopId: item.stopId!,
                authorId: item.reviewerId,
                authorName: item.reviewerName,
                authorEmail: '', // Not strictly needed for display usually
                content: item.message,
                createdAt: item.createdAt,
                resolved: item.resolved,
                resolvedAt: item.resolvedAt,
                resolvedBy: item.resolvedBy,
                type: item.type, // Pass type (issue|suggestion|compliment)
            } as any); // Casting to any/StopComment as needed. Ideally update StopComment type.
        });
        return grouped;
    }, [submission?.feedback]);

    // Get stops with their comments for the rejection dialog
    const stopsWithComments = useMemo(() => {
        if (!stops) return [];
        return stops.map((stop) => ({
            stopId: stop.id,
            stopName: stop.name,
            comments: stopFeedback[stop.id] || [],
        }));
    }, [stops, stopFeedback]);

    const handleApprove = async () => {
        if (!submission || !user) return;
        try {
            await updateStatusMutation.mutateAsync({
                submissionId: submission.id,
                status: 'approved',
                data: {
                    reviewerId: user.uid,
                    reviewerName: user.displayName || 'Admin',
                }
            });
            toast({
                title: 'Submission approved',
                description: 'The tour has been approved and published.',
            });
            router.push('/review-queue');
        } catch {
            toast({
                variant: 'destructive',
                title: 'Error',
                description: 'Failed to approve submission. Please try again.',
            });
        }
    };

    const handleReject = async (reason: string, _includeComments: boolean) => {
        if (!submission || !user) return;
        try {
            await updateStatusMutation.mutateAsync({
                submissionId: submission.id,
                status: 'rejected',
                data: {
                    reviewerId: user.uid,
                    reviewerName: user.displayName || 'Admin',
                    rejectionReason: reason,
                }
            });
            toast({
                title: 'Submission rejected',
                description: 'The creator has been notified of the rejection.',
            });
            router.push('/review-queue');
        } catch {
            toast({
                variant: 'destructive',
                title: 'Error',
                description: 'Failed to reject submission. Please try again.',
            });
        }
    };

    const handleAddFeedback = async (stopId: string, content: string) => {
        if (!submission || !user) return;

        await addFeedbackMutation.mutateAsync({
            submissionId: submission.id,
            feedback: {
                reviewerId: user.uid,
                reviewerName: user.displayName || 'Admin',
                type: 'issue', // Default to issue for now, could add UI to select type
                priority: 'medium',
                message: content,
                stopId,
                stopName: stops?.find(s => s.id === stopId)?.name,
                resolved: false,
            }
        });
    };

    const handleResolveFeedback = async (feedbackId: string) => {
        if (!submission || !user) return;

        await resolveFeedbackMutation.mutateAsync({
            submissionId: submission.id,
            feedbackId,
            resolvedBy: user.uid,
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

    if (!submission || !tour || !version) {
        return (
            <AdminLayout title="Review Tour">
                <Card>
                    <CardContent className="py-8 text-center">
                        <p className="text-muted-foreground">Submission not found</p>
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
                                    <Badge>{submission.status}</Badge>
                                    {submission.resubmissionCount > 0 && <Badge variant="outline">Resubmission #{submission.resubmissionCount}</Badge>}
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

                        {submission.resubmissionJustification && (
                            <div className="bg-muted p-4 rounded-md">
                                <p className="text-sm font-semibold mb-1">Resubmission Note:</p>
                                <p className="text-sm">{submission.resubmissionJustification}</p>
                            </div>
                        )}

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
                                        comments={stopFeedback[stop.id] || []}
                                        onAddComment={(content) => handleAddFeedback(stop.id, content)}
                                        onDeleteComment={async () => { }} // Not supporting deletion yet via UI or need new hook
                                        onResolveComment={handleResolveFeedback}
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

                {/* Review Notes (General Feedback) */}
                <Card>
                    <CardHeader>
                        <CardTitle>Decision Notes (Optional)</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <Textarea
                            placeholder="Add any notes for the decision..."
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
                        disabled={updateStatusMutation.isPending}
                    >
                        <X className="mr-2 h-4 w-4" />
                        Reject / Request Changes
                    </Button>
                    <Button
                        onClick={() => setApproveDialogOpen(true)}
                        disabled={updateStatusMutation.isPending}
                    >
                        <Check className="mr-2 h-4 w-4" />
                        Approve
                    </Button>
                </div>

                {/* Approve Dialog */}
                <Dialog open={approveDialogOpen} onOpenChange={setApproveDialogOpen}>
                    <DialogContent>
                        <DialogHeader>
                            <DialogTitle>Approve Submission</DialogTitle>
                            <DialogDescription>
                                This will publish the tour version and make it available to all users.
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
                                disabled={updateStatusMutation.isPending}
                            >
                                {updateStatusMutation.isPending ? 'Approving...' : 'Approve'}
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
                    isSubmitting={updateStatusMutation.isPending}
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
