'use client';

import { CreatorNavItem } from '@/components/creator/CreatorLayout';
import { CoverForm } from '@/components/creator/forms/CoverForm';
import { TipsForm } from '@/components/creator/forms/TipsForm';
import { MapEditor } from '@/components/creator/map-editor';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import {
  useCreatorTour,
  useSubmitTourForReview,
  useUpdateTour,
  useUploadCoverImage,
  useWithdrawTour,
} from '@/hooks/use-creator-tours';
import { useTourStops } from '@/hooks/use-stops';
import { useToast } from '@/hooks/use-toast';
import { GeoPoint, statusDisplayNames } from '@/types';
import { ArrowLeft, Image as ImageIcon, Loader2, Map, Send, Sun } from 'lucide-react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useState } from 'react';

interface EditTourPageProps {
  params: { tourId: string };
}

type Tab = 'cover' | 'route' | 'tips' | 'publish';

export default function EditTourPage({ params }: EditTourPageProps) {
  const { tourId } = params;
  const { toast } = useToast();
  const router = useRouter();
  const [activeTab, setActiveTab] = useState<Tab>('cover');

  const { data: tourData, isLoading, error } = useCreatorTour(tourId);
  const updateTour = useUpdateTour();
  const uploadCoverImage = useUploadCoverImage();
  const submitForReview = useSubmitTourForReview();
  const withdrawTour = useWithdrawTour();
  const { data: stops = [] } = useTourStops(tourId);

  const handleUpdateTour = async (data: Partial<any>) => {
    // Map flattened form data back to nested structure if needed, or just pass partials
    // The useUpdateTour hook expects specific input structure.

    // We need to construct the input based on what's changed.
    // For now, these forms pass flat data that matches the input type mostly.

    try {
      await updateTour.mutateAsync({
        tourId,
        input: data,
      });

      toast({
        title: 'Saved',
        description: 'Changes saved successfully.',
      });
    } catch (e) {
      toast({
        variant: 'destructive',
        title: 'Error',
        description: 'Failed to save changes.',
      });
      console.error(e);
    }
  };

  const handleCoverSave = async (data: any) => {
    await handleUpdateTour(data);
  };

  const handleTipsSave = async (data: any) => {
    await handleUpdateTour(data);
  };

  const handleStopAdd = (location: GeoPoint, name: string) => {
    // TODO: Connect this to actual mutation
    console.log('Stop added at', location, name);
    toast({
      title: 'Stop Added',
      description: 'Stops management will be updated in next iteration',
    });
  };

  const handleStopMove = (stopId: string, location: GeoPoint) => {
    // TODO: Connect this to actual mutation
    console.log('Stop moved', stopId, location);
  };

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
      </div>
    );
  }

  if (error || !tourData) {
    return (
      <div className="flex h-screen items-center justify-center flex-col gap-4">
        <p className="text-destructive">Failed to load tour</p>
        <Link href="/my-tours"><Button>Back to Dashboard</Button></Link>
      </div>
    );
  }

  const { tour, version } = tourData;


  return (
    <div className="flex h-screen bg-background">
      {/* Sidebar Navigation - Overriding the slot approach by just placing it here. 
             If Component separation was strict, we'd pass this as a prop or portal, but this is fine.
             We removed CreatorLayout wrapper because it forced a duplicate sidebar.
         */}
      <aside className="w-64 border-r bg-muted/10 flex flex-col h-full bg-white">
        <div className="p-4 border-b h-14 flex items-center">
          <Link href="/my-tours" className="flex items-center text-sm font-medium text-muted-foreground hover:text-foreground transition-colors">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Dashboard
          </Link>
        </div>

        <div className="p-4 space-y-4">
          <div>
            <h2 className="font-semibold px-2 mb-1 truncate" title={version.title}>
              {version.title || 'Untitled Tour'}
            </h2>
            <div className="px-2">
              <Badge variant="outline" className="text-xs">
                {statusDisplayNames[tour.status]}
              </Badge>
            </div>
          </div>

          <nav className="space-y-1">
            <CreatorNavItem
              icon={ImageIcon}
              label="Cover"
              isActive={activeTab === 'cover'}
              onClick={() => setActiveTab('cover')}
            />
            <CreatorNavItem
              icon={Map}
              label="Route Map"
              isActive={activeTab === 'route'}
              onClick={() => setActiveTab('route')}
            />
            <CreatorNavItem
              icon={Sun}
              label="Tips"
              isActive={activeTab === 'tips'}
              onClick={() => setActiveTab('tips')}
            />
            <CreatorNavItem
              icon={Send}
              label="Publish"
              isActive={activeTab === 'publish'}
              onClick={() => setActiveTab('publish')}
            />
          </nav>
        </div>
      </aside>

      <main className="flex-1 overflow-auto bg-slate-50 relative">
        <div className="h-full">
          {activeTab === 'cover' && (
            <div className="p-8 max-w-5xl mx-auto">
              <CoverForm
                version={version}
                onSave={handleCoverSave}
                onCoverImageUpload={(file) => uploadCoverImage.mutateAsync({ tourId, file })}
                onCoverImageSelect={async (url) => {
                  await handleCoverSave({ coverImageUrl: url });
                }}
                isSaving={updateTour.isPending}
              />
            </div>
          )}

          {activeTab === 'route' && (
            <div className="h-full w-full relative">
              {/* Map Editor fills the space */}
              <MapEditor
                stops={stops}
                selectedStopId={null} // Managing state here later
                onStopSelect={() => { }}
                onStopAdd={handleStopAdd}
                onStopMove={handleStopMove}
                centerLocation={tour.startLocation}
                isAddMode={false}
                tourType={tour.tourType}
              />
            </div>
          )}

          {activeTab === 'tips' && (
            <div className="p-8 max-w-5xl mx-auto">
              <TipsForm
                version={version}
                onSave={handleTipsSave}
                isSaving={updateTour.isPending}
              />
            </div>
          )}

          {activeTab === 'publish' && (
            <div className="p-8 max-w-3xl mx-auto">
              <Card>
                <CardContent className="pt-6 space-y-4">
                  <h3 className="text-lg font-medium">Ready to publish?</h3>
                  <p className="text-muted-foreground">
                    Once you submit your tour, our team will review it to ensure it meets our quality standards.
                  </p>
                  <div className="flex gap-4 pt-4">
                    <Button
                      onClick={() => submitForReview.mutateAsync(tourId)}
                      disabled={submitForReview.isPending || tour.status === 'pending_review'}
                    >
                      {submitForReview.isPending ? <Loader2 className="mr-2 h-4 w-4 animate-spin" /> : <Send className="mr-2 h-4 w-4" />}
                      Submit for Review
                    </Button>

                    {tour.status === 'pending_review' && (
                      <Button variant="outline" onClick={() => withdrawTour.mutateAsync(tourId)}>
                        Withdraw Submission
                      </Button>
                    )}
                  </div>
                </CardContent>
              </Card>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
