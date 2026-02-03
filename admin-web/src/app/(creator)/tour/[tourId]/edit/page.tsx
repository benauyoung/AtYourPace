'use client';

import Link from 'next/link';
import { ArrowLeft, Loader2, MapPin, Eye, Send, Undo2 } from 'lucide-react';
import { CreatorPageWrapper } from '@/components/layout/creator-page-wrapper';
import { TourForm } from '@/components/creator/tour-form';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
  useCreatorTour,
  useUpdateTour,
  useUploadCoverImage,
  useSubmitTourForReview,
  useWithdrawTour,
} from '@/hooks/use-creator-tours';
import { useToast } from '@/hooks/use-toast';
import { statusDisplayNames } from '@/types';

interface EditTourPageProps {
  params: { tourId: string };
}

export default function EditTourPage({ params }: EditTourPageProps) {
  const { tourId } = params;
  const { toast } = useToast();

  const { data, isLoading, error } = useCreatorTour(tourId);
  const updateTour = useUpdateTour();
  const uploadCoverImage = useUploadCoverImage();
  const submitForReview = useSubmitTourForReview();
  const withdrawTour = useWithdrawTour();

  const handleSave = async (formData: {
    title?: string;
    description?: string;
    category?: 'history' | 'nature' | 'ghost' | 'food' | 'art' | 'architecture' | 'other';
    tourType?: 'walking' | 'driving';
    difficulty?: 'easy' | 'moderate' | 'challenging';
    city?: string;
    region?: string;
    country?: string;
    duration?: string;
    distance?: string;
    startLatitude?: number;
    startLongitude?: number;
  }) => {
    try {
      await updateTour.mutateAsync({
        tourId,
        input: {
          title: formData.title,
          description: formData.description,
          category: formData.category,
          tourType: formData.tourType,
          difficulty: formData.difficulty,
          city: formData.city,
          region: formData.region,
          country: formData.country,
          duration: formData.duration,
          distance: formData.distance,
          startLocation:
            formData.startLatitude !== undefined && formData.startLongitude !== undefined
              ? { latitude: formData.startLatitude, longitude: formData.startLongitude }
              : undefined,
        },
      });

      toast({
        title: 'Tour saved',
        description: 'Your changes have been saved.',
      });
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to save tour',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
      throw error; // Re-throw so auto-save knows it failed
    }
  };

  const handleImageUpload = async (file: File) => {
    try {
      await uploadCoverImage.mutateAsync({ tourId, file });
      toast({
        title: 'Image uploaded',
        description: 'Cover image has been updated.',
      });
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to upload image',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  };

  const handleSubmitForReview = async () => {
    try {
      await submitForReview.mutateAsync(tourId);
      toast({
        title: 'Tour submitted',
        description: 'Your tour has been submitted for review.',
      });
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to submit tour',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  };

  const handleWithdraw = async () => {
    try {
      await withdrawTour.mutateAsync(tourId);
      toast({
        title: 'Submission withdrawn',
        description: 'Your tour has been moved back to draft. You can now edit it.',
      });
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to withdraw submission',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  };

  if (isLoading) {
    return (
      <CreatorPageWrapper title="Edit Tour">
        <div className="flex items-center justify-center py-12">
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
        </div>
      </CreatorPageWrapper>
    );
  }

  if (error || !data) {
    return (
      <CreatorPageWrapper title="Edit Tour">
        <div className="mx-auto max-w-3xl">
          <Card className="border-destructive">
            <CardContent className="pt-6">
              <p className="text-destructive">
                {error instanceof Error ? error.message : 'Tour not found'}
              </p>
              <Button variant="outline" asChild className="mt-4">
                <Link href="/my-tours">Back to My Tours</Link>
              </Button>
            </CardContent>
          </Card>
        </div>
      </CreatorPageWrapper>
    );
  }

  const { tour, version } = data;
  const canEdit = tour.status !== 'pending_review';
  const canSubmit = tour.status === 'draft' || tour.status === 'rejected';
  const canWithdraw = tour.status === 'pending_review';

  return (
    <CreatorPageWrapper title="Edit Tour">
      <div className="mx-auto max-w-3xl space-y-6">
        {/* Back button */}
        <Button variant="ghost" size="sm" asChild>
          <Link href="/my-tours">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to My Tours
          </Link>
        </Button>

        {/* Header with status */}
        <div className="flex items-start justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <h2 className="text-2xl font-bold tracking-tight">
                {version.title || 'Untitled Tour'}
              </h2>
              <Badge variant={tour.status === 'approved' ? 'default' : 'secondary'}>
                {statusDisplayNames[tour.status]}
              </Badge>
            </div>
            <p className="text-muted-foreground">
              Edit your tour details and settings
            </p>
          </div>
        </div>

        {/* Status-specific messages */}
        {tour.status === 'pending_review' && (
          <Card className="border-yellow-500 bg-yellow-50 dark:bg-yellow-950/20">
            <CardContent className="pt-6">
              <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <p className="text-yellow-800 dark:text-yellow-200">
                  This tour is currently under review. You cannot make changes until the review is complete.
                </p>
                <Button
                  variant="outline"
                  onClick={handleWithdraw}
                  disabled={withdrawTour.isPending}
                  className="shrink-0"
                >
                  {withdrawTour.isPending ? (
                    <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  ) : (
                    <Undo2 className="mr-2 h-4 w-4" />
                  )}
                  Withdraw Submission
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        {tour.status === 'rejected' && tour.rejectionReason && (
          <Card className="border-destructive bg-destructive/10">
            <CardHeader>
              <CardTitle className="text-destructive">Tour Rejected</CardTitle>
              <CardDescription>{tour.rejectionReason}</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground">
                Please address the feedback above and resubmit your tour for review.
              </p>
            </CardContent>
          </Card>
        )}

        {tour.status === 'approved' && (
          <Card className="border-green-500 bg-green-50 dark:bg-green-950/20">
            <CardContent className="pt-6">
              <p className="text-green-800 dark:text-green-200">
                This tour is approved and live. Making changes will require re-approval.
              </p>
            </CardContent>
          </Card>
        )}

        {/* Action buttons */}
        <div className="flex flex-wrap gap-2">
          <Button variant="outline" asChild>
            <Link href={`/tour/${tourId}/stops`}>
              <MapPin className="mr-2 h-4 w-4" />
              Manage Stops
            </Link>
          </Button>
          <Button variant="outline" asChild>
            <Link href={`/tour/${tourId}/preview`}>
              <Eye className="mr-2 h-4 w-4" />
              Preview
            </Link>
          </Button>
          {canSubmit && (
            <Button
              onClick={handleSubmitForReview}
              disabled={submitForReview.isPending}
            >
              {submitForReview.isPending ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : (
                <Send className="mr-2 h-4 w-4" />
              )}
              Submit for Review
            </Button>
          )}
        </div>

        {/* Form */}
        {canEdit ? (
          <TourForm
            tour={tour}
            version={version}
            onSave={handleSave}
            onCoverImageUpload={handleImageUpload}
            coverImageUrl={version.coverImageUrl}
            isSaving={updateTour.isPending}
          />
        ) : (
          <Card>
            <CardContent className="pt-6">
              <p className="text-muted-foreground text-center py-8">
                Editing is disabled while the tour is under review.
              </p>
            </CardContent>
          </Card>
        )}
      </div>
    </CreatorPageWrapper>
  );
}
