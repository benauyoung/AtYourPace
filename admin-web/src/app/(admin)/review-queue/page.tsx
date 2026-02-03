'use client';

import { AdminLayout } from '@/components/layout/admin-layout';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { subscribeToPendingTours, subscribeToSubmissions } from '@/lib/firebase/admin';
import { PublishingSubmissionModel, SubmissionStatus, TourModel } from '@/types';
import { format } from 'date-fns';
import { Clock, FileText, User } from 'lucide-react';
import Link from 'next/link';
import { useEffect, useState } from 'react';

const statusDisplayNames: Record<SubmissionStatus, string> = {
  draft: 'Draft',
  submitted: 'Submitted',
  under_review: 'Under Review',
  changes_requested: 'Changes Requested',
  approved: 'Approved',
  rejected: 'Rejected',
  withdrawn: 'Withdrawn',
};

const statusColors: Record<SubmissionStatus, "default" | "secondary" | "destructive" | "outline"> = {
  draft: 'outline',
  submitted: 'default',
  under_review: 'secondary',
  changes_requested: 'secondary',
  approved: 'default',
  rejected: 'destructive',
  withdrawn: 'outline',
};

export default function ReviewQueuePage() {
  const [submissions, setSubmissions] = useState<PublishingSubmissionModel[]>([]);
  const [legacyTours, setLegacyTours] = useState<TourModel[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Subscribe to new submissions
    const unsubscribeSubmissions = subscribeToSubmissions((items) => {
      setSubmissions(items);
      // Don't set loading false yet, wait for both
    });

    // Subscribe to legacy pending tours
    const unsubscribeLegacy = subscribeToPendingTours((items) => {
      setLegacyTours(items);
    });

    const timeout = setTimeout(() => setIsLoading(false), 500); // Small buffer for initial load

    return () => {
      unsubscribeSubmissions();
      unsubscribeLegacy();
      clearTimeout(timeout);
    };
  }, []);

  // Merge and deduplicate
  const allSubmissions = [
    ...submissions,
    ...legacyTours
      .filter(t => !submissions.some(s => s.tourId === t.id)) // Dedupe: if updated via new flow, ignore legacy doc
      .map(t => ({
        id: `legacy-${t.id}`,
        tourId: t.id,
        versionId: t.draftVersionId,
        creatorId: t.creatorId,
        creatorName: t.creatorName,
        status: 'submitted' as SubmissionStatus,
        submittedAt: t.updatedAt, // Best approximation
        resubmissionCount: 0,
        creatorIgnoredSuggestions: false,
        tourTitle: t.slug || 'Untitled Legacy Tour', // Legacy tours might not have title easily accessible without fetching version
        feedback: [],
        createdAt: t.createdAt,
        updatedAt: t.updatedAt,
      } as PublishingSubmissionModel))
  ].sort((a, b) => a.submittedAt.getTime() - b.submittedAt.getTime());


  return (
    <AdminLayout title="Review Queue">
      {isLoading ? (
        <div className="flex items-center justify-center py-8">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-primary border-t-transparent" />
        </div>
      ) : allSubmissions.length === 0 ? (
        <Card>
          <CardContent className="flex flex-col items-center justify-center py-12">
            <p className="text-lg font-medium text-muted-foreground">
              No submissions pending review
            </p>
            <p className="text-sm text-muted-foreground">
              Check back later for new submissions
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          <p className="text-sm text-muted-foreground">
            {allSubmissions.length} submission{allSubmissions.length !== 1 ? 's' : ''} awaiting review
          </p>

          <div className="grid gap-4">
            {allSubmissions.map((submission) => (
              <Card key={submission.id} className="overflow-hidden">
                <CardContent className="p-0">
                  <div className="flex items-center justify-between p-4">
                    <div className="space-y-2">
                      <div className="flex items-center gap-2">
                        <Badge variant={statusColors[submission.status] || 'default'}>
                          {statusDisplayNames[submission.status] || submission.status}
                        </Badge>
                        {submission.resubmissionCount > 0 && (
                          <Badge variant="outline">
                            Resubmission #{submission.resubmissionCount}
                          </Badge>
                        )}
                      </div>

                      <h3 className="font-semibold text-lg">
                        {submission.tourTitle || `Tour ${submission.tourId.substring(0, 8)}...`}
                      </h3>

                      <div className="flex items-center gap-4 text-sm text-muted-foreground">
                        <span className="flex items-center gap-1">
                          <User className="h-3 w-3" />
                          {submission.creatorName}
                        </span>
                        <span className="flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          Submitted {format(submission.submittedAt, 'MMM d, yyyy')}
                        </span>
                        {submission.reviewerName && (
                          <span className="flex items-center gap-1 text-primary">
                            <FileText className="h-3 w-3" />
                            Reviewer: {submission.reviewerName}
                          </span>
                        )}
                      </div>
                    </div>

                    <Link href={`/review-queue/${submission.id}`}>
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
