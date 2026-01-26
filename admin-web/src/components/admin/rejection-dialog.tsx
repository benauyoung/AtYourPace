'use client';

import { useState, useMemo } from 'react';
import { X, AlertTriangle, MessageSquare, Loader2 } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Checkbox } from '@/components/ui/checkbox';
import { Badge } from '@/components/ui/badge';
import { cn } from '@/lib/utils';
import { StopComment } from './stop-comments';

// Predefined rejection reasons
const REJECTION_REASONS = [
  {
    id: 'incomplete',
    label: 'Incomplete content',
    description: 'Missing audio, images, or descriptions',
  },
  {
    id: 'quality',
    label: 'Quality issues',
    description: 'Audio quality, image resolution, or content quality needs improvement',
  },
  {
    id: 'accuracy',
    label: 'Accuracy concerns',
    description: 'Historical or factual inaccuracies that need correction',
  },
  {
    id: 'guidelines',
    label: 'Guidelines violation',
    description: 'Content violates community guidelines or terms of service',
  },
  {
    id: 'other',
    label: 'Other',
    description: 'Specify a custom reason',
  },
] as const;

type RejectionReasonId = (typeof REJECTION_REASONS)[number]['id'];

interface StopWithComments {
  stopId: string;
  stopName: string;
  comments: StopComment[];
}

interface RejectionDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onReject: (reason: string, includeComments: boolean) => Promise<void>;
  tourTitle: string;
  stopsWithComments?: StopWithComments[];
  isSubmitting?: boolean;
}

export function RejectionDialog({
  isOpen,
  onClose,
  onReject,
  tourTitle,
  stopsWithComments = [],
  isSubmitting = false,
}: RejectionDialogProps) {
  const [selectedReason, setSelectedReason] = useState<RejectionReasonId | ''>('');
  const [customReason, setCustomReason] = useState('');
  const [includeComments, setIncludeComments] = useState(true);
  const [additionalNotes, setAdditionalNotes] = useState('');

  // Get unresolved comments count
  const unresolvedCommentsCount = useMemo(() => {
    return stopsWithComments.reduce(
      (sum, stop) => sum + stop.comments.filter((c) => !c.resolved).length,
      0
    );
  }, [stopsWithComments]);

  const handleSubmit = async () => {
    if (!selectedReason) return;

    let reason = '';

    if (selectedReason === 'other') {
      if (!customReason.trim()) return;
      reason = customReason.trim();
    } else {
      const preset = REJECTION_REASONS.find((r) => r.id === selectedReason);
      reason = preset ? preset.label : selectedReason;
    }

    if (additionalNotes.trim()) {
      reason += `\n\nAdditional notes:\n${additionalNotes.trim()}`;
    }

    await onReject(reason, includeComments);
  };

  const handleClose = () => {
    if (isSubmitting) return;
    setSelectedReason('');
    setCustomReason('');
    setAdditionalNotes('');
    setIncludeComments(true);
    onClose();
  };

  const canSubmit =
    selectedReason !== '' &&
    (selectedReason !== 'other' || customReason.trim().length > 0);

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && handleClose()}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2 text-destructive">
            <AlertTriangle className="h-5 w-5" />
            Reject Tour
          </DialogTitle>
          <DialogDescription>
            Rejecting &quot;{tourTitle}&quot;. The creator will be notified with your feedback.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          {/* Rejection reason selection */}
          <div className="space-y-3">
            <Label>Reason for rejection</Label>
            <RadioGroup
              value={selectedReason}
              onValueChange={(v) => setSelectedReason(v as RejectionReasonId)}
              className="space-y-2"
            >
              {REJECTION_REASONS.map((reason) => (
                <div
                  key={reason.id}
                  className={cn(
                    'flex items-start space-x-3 rounded-lg border p-3 transition-colors',
                    selectedReason === reason.id && 'border-primary bg-primary/5'
                  )}
                >
                  <RadioGroupItem value={reason.id} id={reason.id} className="mt-0.5" />
                  <div className="flex-1">
                    <Label
                      htmlFor={reason.id}
                      className="font-medium cursor-pointer"
                    >
                      {reason.label}
                    </Label>
                    <p className="text-xs text-muted-foreground mt-0.5">
                      {reason.description}
                    </p>
                  </div>
                </div>
              ))}
            </RadioGroup>
          </div>

          {/* Custom reason input */}
          {selectedReason === 'other' && (
            <div className="space-y-2">
              <Label htmlFor="customReason">Custom reason *</Label>
              <Textarea
                id="customReason"
                placeholder="Describe the reason for rejection..."
                value={customReason}
                onChange={(e) => setCustomReason(e.target.value)}
                rows={3}
                className="resize-none"
              />
            </div>
          )}

          {/* Additional notes */}
          <div className="space-y-2">
            <Label htmlFor="additionalNotes">Additional notes (optional)</Label>
            <Textarea
              id="additionalNotes"
              placeholder="Any additional feedback for the creator..."
              value={additionalNotes}
              onChange={(e) => setAdditionalNotes(e.target.value)}
              rows={2}
              className="resize-none"
            />
          </div>

          {/* Include comments option */}
          {unresolvedCommentsCount > 0 && (
            <div className="flex items-start space-x-3 rounded-lg border p-3 bg-orange-50 dark:bg-orange-950/20 border-orange-200 dark:border-orange-900">
              <Checkbox
                id="includeComments"
                checked={includeComments}
                onCheckedChange={(checked) => setIncludeComments(!!checked)}
              />
              <div className="flex-1">
                <Label
                  htmlFor="includeComments"
                  className="font-medium cursor-pointer flex items-center gap-2"
                >
                  <MessageSquare className="h-4 w-4 text-orange-600" />
                  Include stop comments
                </Label>
                <p className="text-xs text-muted-foreground mt-0.5">
                  {unresolvedCommentsCount} unresolved comment
                  {unresolvedCommentsCount !== 1 ? 's' : ''} will be included in
                  the rejection email
                </p>
              </div>
            </div>
          )}

          {/* Preview of included comments */}
          {includeComments && unresolvedCommentsCount > 0 && (
            <div className="rounded-lg border p-3 bg-muted/50 max-h-32 overflow-y-auto">
              <p className="text-xs font-medium mb-2">Comments to include:</p>
              <div className="space-y-2">
                {stopsWithComments.map((stop) => {
                  const unresolved = stop.comments.filter((c) => !c.resolved);
                  if (unresolved.length === 0) return null;
                  return (
                    <div key={stop.stopId} className="text-xs">
                      <Badge variant="outline" className="mb-1">
                        {stop.stopName}
                      </Badge>
                      {unresolved.map((comment) => (
                        <p
                          key={comment.id}
                          className="text-muted-foreground pl-2 border-l-2 border-orange-300 ml-1 mt-1"
                        >
                          {comment.content.slice(0, 100)}
                          {comment.content.length > 100 && '...'}
                        </p>
                      ))}
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={handleClose} disabled={isSubmitting}>
            Cancel
          </Button>
          <Button
            variant="destructive"
            onClick={handleSubmit}
            disabled={!canSubmit || isSubmitting}
          >
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Rejecting...
              </>
            ) : (
              <>
                <X className="h-4 w-4 mr-2" />
                Reject Tour
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
