'use client';

import { useRouter } from 'next/navigation';
import { ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { CreatorPageWrapper } from '@/components/layout/creator-page-wrapper';
import { TourForm } from '@/components/creator/tour-form';
import { Button } from '@/components/ui/button';
import { useCreateTour } from '@/hooks/use-creator-tours';
import { useToast } from '@/hooks/use-toast';

export default function NewTourPage() {
  const router = useRouter();
  const { toast } = useToast();
  const createTour = useCreateTour();

  const handleSave = async (data: {
    title: string;
    description: string;
    category: 'history' | 'nature' | 'ghost' | 'food' | 'art' | 'architecture' | 'other';
    tourType: 'walking' | 'driving';
    difficulty: 'easy' | 'moderate' | 'challenging';
    city?: string;
    region?: string;
    country?: string;
    startLatitude: number;
    startLongitude: number;
  }) => {
    try {
      const tourId = await createTour.mutateAsync({
        title: data.title,
        description: data.description,
        category: data.category,
        tourType: data.tourType,
        difficulty: data.difficulty,
        city: data.city,
        region: data.region,
        country: data.country,
        startLocation: {
          latitude: data.startLatitude,
          longitude: data.startLongitude,
        },
      });

      toast({
        title: 'Tour created',
        description: 'Your tour has been created. You can now add stops.',
      });

      // Redirect to the edit page
      router.push(`/tour/${tourId}/edit`);
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to create tour',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
    }
  };

  return (
    <CreatorPageWrapper title="Create Tour">
      <div className="mx-auto max-w-3xl space-y-6">
        {/* Back button */}
        <Button variant="ghost" size="sm" asChild>
          <Link href="/my-tours">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to My Tours
          </Link>
        </Button>

        {/* Header */}
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Create New Tour</h2>
          <p className="text-muted-foreground">
            Fill in the basic information to create your tour. You can add stops and media after.
          </p>
        </div>

        {/* Form */}
        <TourForm
          onSave={handleSave}
          isSaving={createTour.isPending}
          isNew
        />
      </div>
    </CreatorPageWrapper>
  );
}
