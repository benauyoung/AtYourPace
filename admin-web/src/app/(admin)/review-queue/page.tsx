'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { format } from 'date-fns';
import { Clock, MapPin, User } from 'lucide-react';
import { AdminLayout } from '@/components/layout/admin-layout';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { subscribeToPendingTours } from '@/lib/firebase/admin';
import { TourModel, categoryDisplayNames } from '@/types';

export default function ReviewQueuePage() {
  const [tours, setTours] = useState<TourModel[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = subscribeToPendingTours((pendingTours) => {
      setTours(pendingTours);
      setIsLoading(false);
    });

    return unsubscribe;
  }, []);

  return (
    <AdminLayout title="Review Queue">
      {isLoading ? (
        <div className="flex items-center justify-center py-8">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>
      ) : tours.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <p className="text-lg font-medium text-muted-foreground">
              No tours pending review
            </p>
            <p className="text-sm text-muted-foreground">
              Check back later for new submissions
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          <p className="text-sm text-muted-foreground">
            {tours.length} tour{tours.length !== 1 ? 's' : ''} awaiting review
          </p>

          <div className="grid gap-4">
            {tours.map((tour) => (
              <Card key={tour.id} className="overflow-hidden">
                <CardContent className="p-0">
                  <div className="flex items-center justify-between p-4">
                    <div className="space-y-2">
                      <div className="flex items-center gap-2">
                        <Badge variant="secondary">
                          {categoryDisplayNames[tour.category]}
                        </Badge>
                        <Badge variant="outline">{tour.tourType}</Badge>
                      </div>

                      <div className="flex items-center gap-4 text-sm text-muted-foreground">
                        <span className="flex items-center gap-1">
                          <User className="h-3 w-3" />
                          {tour.creatorName}
                        </span>
                        {tour.city && (
                          <span className="flex items-center gap-1">
                            <MapPin className="h-3 w-3" />
                            {tour.city}, {tour.country}
                          </span>
                        )}
                        <span className="flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          Submitted {format(tour.updatedAt, 'MMM d, yyyy')}
                        </span>
                      </div>
                    </div>

                    <Link href={`/review-queue/${tour.id}`}>
                      <Button>Review</Button>
                    </Link>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
