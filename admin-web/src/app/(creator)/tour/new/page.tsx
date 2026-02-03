'use client';

import { StartTourModal } from '@/components/creator/StartTourModal';
import { CreatorPageWrapper } from '@/components/layout/creator-page-wrapper';
import { useCreateTour } from '@/hooks/use-creator-tours';
import { useToast } from '@/hooks/use-toast';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';

export default function NewTourPage() {
  const router = useRouter();
  const { toast } = useToast();
  const createTour = useCreateTour();
  const [open, setOpen] = useState(false);

  // Auto-open modal on mount
  useEffect(() => {
    setOpen(true);
  }, []);

  const handleOpenChange = (isOpen: boolean) => {
    setOpen(isOpen);
    if (!isOpen) {
      // Logic: If they close the modal without creating, go back to dashboard
      // We can check if we are navigating away or just closed.
      // For now, let's assume close = cancel = back to dashboard
      // But we need a way to distinguish "success close" vs "cancel close".
      // The modal props I wrote handles validation internally. 
      // Actually, onCreate calls onOpenChange(false).
      // Let's rely on the routing in handleCreate to move away.
      // If the user manually closes, we redirect. Needs a flag or just handle it here.
      // Simplest: If !isOpen and not redirected, go back. 
      // But router.push is async. 

      // Let's simply redirect to my-tours if closed.
      // We will handle the "success" case by redirecting BEFORE closing or avoiding this callback.
    }
  };

  // Custom close handler for "Cancel" or backdrop click
  const handleCancel = () => {
    setOpen(false);
    router.push('/my-tours');
  };

  const handleCreate = async (data: {
    title: string;
    destination: string;
    price?: string;
    transportMode: 'walking' | 'driving';
  }) => {
    try {
      // Maps defaults for fields not yet in the start modal
      const tourId = await createTour.mutateAsync({
        title: data.title,
        description: '',
        category: 'other',
        tourType: data.transportMode, // Map 'walking' | 'driving'
        difficulty: 'moderate',
        city: data.destination, // Store the text input as city for now
        startLocation: {
          latitude: 0, // Default to 0, user sets on map
          longitude: 0,
        },
      });

      toast({
        title: 'Tour created',
        description: 'Draft created. Now you can design your route.',
      });

      // Redirect to the edit page
      router.push(`/tour/${tourId}/edit`);
    } catch (error) {
      toast({
        variant: 'destructive',
        title: 'Failed to create tour',
        description: error instanceof Error ? error.message : 'An error occurred',
      });
      // Re-open if failed?
    }
  };

  return (
    <CreatorPageWrapper title="Create Tour">
      <div className="flex items-center justify-center h-[calc(100vh-200px)]">
        {/* Show a placeholder or loading state while modal is open */}
        <p className="text-muted-foreground">Opening tour creator...</p>

        <StartTourModal
          open={open}
          onOpenChange={(val) => !val ? handleCancel() : setOpen(val)}
          onCreate={handleCreate}
        />
      </div>
    </CreatorPageWrapper>
  );
}
