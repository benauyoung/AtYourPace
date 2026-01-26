'use client';

import { use, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import {
  ArrowLeft,
  Smartphone,
  ClipboardCheck,
  Send,
  Map,
  Loader2,
  AlertCircle,
} from 'lucide-react';
import { CreatorPageWrapper } from '@/components/layout/creator-page-wrapper';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { MobileDeviceFrame, DeviceSelector, DeviceType } from '@/components/creator/mobile-device-frame';
import { TourPreviewFrame } from '@/components/creator/tour-preview-frame';
import { ValidationChecklist, useValidationStatus } from '@/components/creator/validation-checklist';
import { PublishDialog, SubmitButton } from '@/components/creator/publish-dialog';
import { useCreatorTour, useSubmitTourForReview } from '@/hooks/use-creator-tours';
import { useTourStops } from '@/hooks/use-stops';
import { useToast } from '@/hooks/use-toast';
import { statusDisplayNames, TourVersionModel } from '@/types';
import { cn } from '@/lib/utils';

// Default empty tour version for validation when data is loading
const EMPTY_TOUR_VERSION: TourVersionModel = {
  id: '',
  tourId: '',
  versionNumber: 0,
  versionType: 'draft',
  title: '',
  description: '',
  difficulty: 'easy',
  languages: [],
  createdAt: new Date(),
  updatedAt: new Date(),
};

interface PreviewPageProps {
  params: Promise<{ tourId: string }>;
}

export default function PreviewPage({ params }: PreviewPageProps) {
  const { tourId } = use(params);
  const router = useRouter();
  const { toast } = useToast();

  const [activeTab, setActiveTab] = useState<'preview' | 'checklist'>('preview');
  const [deviceType, setDeviceType] = useState<DeviceType>('iphone-14');
  const [isPublishDialogOpen, setIsPublishDialogOpen] = useState(false);

  const { data: tourData, isLoading: isLoadingTour, error: tourError } = useCreatorTour(tourId);
  const { data: stops = [], isLoading: isLoadingStops } = useTourStops(tourId);
  const submitMutation = useSubmitTourForReview();

  const tour = tourData?.version;
  const tourMeta = tourData?.tour;
  const validation = useValidationStatus(tour || EMPTY_TOUR_VERSION, stops);

  const isLoading = isLoadingTour || isLoadingStops;

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const handleSubmit = async (notes?: string) => {
    // TODO: Pass notes to the API when backend supports it
    await submitMutation.mutateAsync(tourId);
    toast({
      title: 'Tour submitted',
      description: 'Your tour has been submitted for review. We\'ll notify you once it\'s reviewed.',
    });
    router.push('/my-tours');
  };

  if (isLoading) {
    return (
      <CreatorPageWrapper title="Preview Tour">
        <div className="flex flex-col items-center justify-center h-[60vh]" role="status" aria-live="polite">
          <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" aria-hidden="true" />
          <span className="sr-only">Loading tour preview...</span>
        </div>
      </CreatorPageWrapper>
    );
  }

  if (tourError || !tour || !tourMeta) {
    return (
      <CreatorPageWrapper title="Preview Tour">
        <div className="mx-auto max-w-5xl space-y-6">
          <Button variant="ghost" size="sm" asChild>
            <Link href="/my-tours">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back to My Tours
            </Link>
          </Button>
          <Alert variant="destructive">
            <AlertCircle className="h-4 w-4" />
            <AlertTitle>Error loading tour</AlertTitle>
            <AlertDescription>
              {tourError instanceof Error ? tourError.message : 'Tour not found'}
            </AlertDescription>
          </Alert>
        </div>
      </CreatorPageWrapper>
    );
  }

  return (
    <CreatorPageWrapper title="Preview Tour">
      <div className="mx-auto max-w-7xl space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="sm" asChild>
              <Link href={`/tour/${tourId}/stops`}>
                <ArrowLeft className="mr-2 h-4 w-4" />
                Back to Stops
              </Link>
            </Button>
            <div>
              <h1 className="text-xl font-bold">{tour.title || 'Untitled Tour'}</h1>
              <div className="flex items-center gap-2 mt-1">
                <span
                  className={cn(
                    'text-xs px-2 py-0.5 rounded-full font-medium',
                    tourMeta.status === 'draft' && 'bg-gray-100 text-gray-700 dark:bg-gray-800 dark:text-gray-300',
                    tourMeta.status === 'pending_review' && 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400',
                    tourMeta.status === 'approved' && 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400',
                    tourMeta.status === 'rejected' && 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400'
                  )}
                >
                  {statusDisplayNames[tourMeta.status]}
                </span>
                {stops.length > 0 && (
                  <span className="text-xs text-muted-foreground">
                    {stops.length} stop{stops.length !== 1 ? 's' : ''}
                  </span>
                )}
              </div>
            </div>
          </div>

          <SubmitButton
            tour={tour}
            stops={stops}
            tourStatus={tourMeta.status}
            onClick={() => setIsPublishDialogOpen(true)}
          />
        </div>

        {/* Status alerts */}
        {tourMeta.status === 'pending_review' && (
          <Alert className="border-yellow-200 bg-yellow-50 dark:bg-yellow-950/20 dark:border-yellow-900">
            <AlertCircle className="h-4 w-4 text-yellow-600" />
            <AlertTitle className="text-yellow-800 dark:text-yellow-400">
              Pending Review
            </AlertTitle>
            <AlertDescription className="text-yellow-700 dark:text-yellow-500">
              Your tour is currently being reviewed by our team. You&apos;ll be notified once the review is complete.
            </AlertDescription>
          </Alert>
        )}

        {tourMeta.status === 'rejected' && tourMeta.rejectionReason && (
          <Alert variant="destructive">
            <AlertCircle className="h-4 w-4" />
            <AlertTitle>Tour Rejected</AlertTitle>
            <AlertDescription>
              <strong>Reason:</strong> {tourMeta.rejectionReason}
            </AlertDescription>
          </Alert>
        )}

        {/* Main content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Device preview */}
          <div className="lg:col-span-2">
            <Card>
              <CardHeader className="pb-4">
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2 text-base">
                    <Smartphone className="h-5 w-5" />
                    Mobile Preview
                  </CardTitle>
                  <DeviceSelector value={deviceType} onChange={setDeviceType} />
                </div>
              </CardHeader>
              <CardContent>
                <div className="flex justify-center py-4 bg-gradient-to-br from-gray-100 to-gray-200 dark:from-gray-800 dark:to-gray-900 rounded-lg">
                  <MobileDeviceFrame device={deviceType} scale={0.65}>
                    <TourPreviewFrame
                      tour={tour}
                      stops={stops}
                      category={tourMeta.category}
                    />
                  </MobileDeviceFrame>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Tabs */}
            <Tabs value={activeTab} onValueChange={(v) => setActiveTab(v as 'preview' | 'checklist')}>
              <TabsList className="grid w-full grid-cols-2">
                <TabsTrigger value="preview" className="flex items-center gap-2">
                  <Map className="h-4 w-4" />
                  Overview
                </TabsTrigger>
                <TabsTrigger value="checklist" className="flex items-center gap-2">
                  <ClipboardCheck className="h-4 w-4" />
                  Checklist
                  {!validation.isValid && (
                    <span className="w-2 h-2 rounded-full bg-red-500" />
                  )}
                </TabsTrigger>
              </TabsList>

              <TabsContent value="preview" className="mt-4">
                <Card>
                  <CardContent className="pt-6 space-y-4">
                    {/* Tour stats */}
                    <div className="grid grid-cols-2 gap-4">
                      <div className="text-center p-3 rounded-lg bg-muted">
                        <p className="text-2xl font-bold">{stops.length}</p>
                        <p className="text-xs text-muted-foreground">Stops</p>
                      </div>
                      <div className="text-center p-3 rounded-lg bg-muted">
                        <p className="text-2xl font-bold">
                          {stops.filter((s) => s.media.audioUrl).length}
                        </p>
                        <p className="text-xs text-muted-foreground">With Audio</p>
                      </div>
                      <div className="text-center p-3 rounded-lg bg-muted">
                        <p className="text-2xl font-bold">
                          {stops.filter((s) => s.media.images?.length > 0).length}
                        </p>
                        <p className="text-xs text-muted-foreground">With Images</p>
                      </div>
                      <div className="text-center p-3 rounded-lg bg-muted">
                        <p className="text-2xl font-bold">{tour.duration || '—'}</p>
                        <p className="text-xs text-muted-foreground">Duration</p>
                      </div>
                    </div>

                    {/* Quick actions */}
                    <div className="space-y-2">
                      <Button variant="outline" className="w-full" asChild>
                        <Link href={`/tour/${tourId}/edit`}>
                          Edit Tour Details
                        </Link>
                      </Button>
                      <Button variant="outline" className="w-full" asChild>
                        <Link href={`/tour/${tourId}/stops`}>
                          Edit Stops
                        </Link>
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="checklist" className="mt-4">
                <Card>
                  <CardContent className="pt-6">
                    <ValidationChecklist tour={tour} stops={stops} />
                  </CardContent>
                </Card>
              </TabsContent>
            </Tabs>

            {/* Submit button at bottom of sidebar */}
            <Button
              onClick={() => setIsPublishDialogOpen(true)}
              disabled={tourMeta.status === 'pending_review'}
              className={cn(
                'w-full',
                validation.isValid && tourMeta.status !== 'pending_review' && 'bg-green-600 hover:bg-green-700'
              )}
            >
              <Send className="h-4 w-4 mr-2" />
              {tourMeta.status === 'pending_review'
                ? 'Pending Review'
                : tourMeta.status === 'approved'
                ? 'Resubmit Changes'
                : 'Submit for Review'}
            </Button>
          </div>
        </div>
      </div>

      {/* Publish dialog */}
      <PublishDialog
        tour={tour}
        stops={stops}
        tourStatus={tourMeta.status}
        isOpen={isPublishDialogOpen}
        onClose={() => setIsPublishDialogOpen(false)}
        onSubmit={handleSubmit}
      />
    </CreatorPageWrapper>
  );
}
