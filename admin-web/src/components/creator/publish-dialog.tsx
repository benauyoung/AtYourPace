'use client';

import { useState, useEffect } from 'react';
import { Send, Loader2, AlertTriangle, CheckCircle2 } from 'lucide-react';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { ValidationChecklist, useValidationStatus } from './validation-checklist';
import { TourVersionModel, StopModel, TourStatus } from '@/types';
import { cn } from '@/lib/utils';

interface PublishDialogProps {
  tour: TourVersionModel;
  stops: StopModel[];
  tourStatus: TourStatus;
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (notes?: string) => Promise<void>;
}

export function PublishDialog({
  tour,
  stops,
  tourStatus,
  isOpen,
  onClose,
  onSubmit,
}: PublishDialogProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [notes, setNotes] = useState('');
  const [error, setError] = useState<string | null>(null);
  const validation = useValidationStatus(tour, stops);

  const isResubmission = tourStatus === 'rejected' || tourStatus === 'approved';

  // Reset state when dialog opens
  useEffect(() => {
    if (isOpen) {
      setNotes('');
      setError(null);
    }
  }, [isOpen]);

  const handleSubmit = async () => {
    if (!validation.isValid) return;

    setIsSubmitting(true);
    setError(null);

    try {
      await onSubmit(notes.trim() || undefined);
      onClose();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to submit tour');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && !isSubmitting && onClose()}>
      <DialogContent className="sm:max-w-[550px] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Send className="h-5 w-5" />
            {isResubmission ? 'Resubmit for Review' : 'Submit for Review'}
          </DialogTitle>
          <DialogDescription>
            {isResubmission
              ? 'Your tour will be reviewed again after resubmission. Previous approval will be invalidated.'
              : 'Once submitted, your tour will be reviewed by our team. You can still make edits while pending review.'}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 py-4">
          {/* Resubmission warning */}
          {tourStatus === 'approved' && (
            <Alert className="border-yellow-200 bg-yellow-50 dark:bg-yellow-950/20 dark:border-yellow-900">
              <AlertTriangle className="h-4 w-4 text-yellow-600" />
              <AlertDescription className="text-yellow-800 dark:text-yellow-400">
                This tour is currently live. Resubmitting will require re-approval before changes go live.
              </AlertDescription>
            </Alert>
          )}

          {tourStatus === 'rejected' && (
            <Alert className="border-blue-200 bg-blue-50 dark:bg-blue-950/20 dark:border-blue-900">
              <CheckCircle2 className="h-4 w-4 text-blue-600" />
              <AlertDescription className="text-blue-800 dark:text-blue-400">
                This tour was previously rejected. Make sure you&apos;ve addressed the feedback before resubmitting.
              </AlertDescription>
            </Alert>
          )}

          {/* Validation checklist */}
          <ValidationChecklist tour={tour} stops={stops} />

          {/* Optional notes */}
          {validation.isValid && (
            <div className="space-y-2">
              <Label htmlFor="notes" className="text-sm font-medium">
                Notes for reviewer (optional)
              </Label>
              <Textarea
                id="notes"
                placeholder="Add any context or notes for the reviewer..."
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                rows={3}
                className="resize-none"
              />
            </div>
          )}

          {/* Error message */}
          {error && (
            <Alert variant="destructive">
              <AlertTriangle className="h-4 w-4" />
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}
        </div>

        <DialogFooter className="flex-col sm:flex-row gap-2">
          <Button
            variant="outline"
            onClick={onClose}
            disabled={isSubmitting}
            className="sm:flex-1"
          >
            Cancel
          </Button>
          <Button
            onClick={handleSubmit}
            disabled={!validation.isValid || isSubmitting}
            className={cn(
              'sm:flex-1',
              validation.isValid && 'bg-green-600 hover:bg-green-700'
            )}
          >
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                Submitting...
              </>
            ) : (
              <>
                <Send className="h-4 w-4 mr-2" />
                {isResubmission ? 'Resubmit Tour' : 'Submit for Review'}
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// Compact submit button with validation indicator
interface SubmitButtonProps {
  tour: TourVersionModel;
  stops: StopModel[];
  tourStatus: TourStatus;
  onClick: () => void;
  className?: string;
}

export function SubmitButton({
  tour,
  stops,
  tourStatus,
  onClick,
  className,
}: SubmitButtonProps) {
  const validation = useValidationStatus(tour, stops);

  const getButtonText = () => {
    if (tourStatus === 'pending_review') {
      return 'Pending Review';
    }
    if (tourStatus === 'approved') {
      return 'Resubmit Changes';
    }
    if (tourStatus === 'rejected') {
      return 'Resubmit for Review';
    }
    return 'Submit for Review';
  };

  const isDisabled = tourStatus === 'pending_review';

  return (
    <Button
      onClick={onClick}
      disabled={isDisabled}
      className={cn(
        validation.isValid && !isDisabled && 'bg-green-600 hover:bg-green-700',
        className
      )}
    >
      <Send className="h-4 w-4 mr-2" />
      {getButtonText()}
      {!validation.isValid && !isDisabled && (
        <span className="ml-2 px-1.5 py-0.5 text-xs rounded bg-white/20">
          Incomplete
        </span>
      )}
    </Button>
  );
}
