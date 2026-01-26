'use client';

import { useState } from 'react';
import { Check, X, Loader2, ChevronDown, AlertTriangle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { cn } from '@/lib/utils';

interface BulkActionsProps {
  selectedCount: number;
  onApproveAll: (notes?: string) => Promise<void>;
  onRejectAll: (reason: string) => Promise<void>;
  onClearSelection: () => void;
  isProcessing?: boolean;
  className?: string;
}

export function BulkActions({
  selectedCount,
  onApproveAll,
  onRejectAll,
  onClearSelection,
  isProcessing = false,
  className,
}: BulkActionsProps) {
  const [showApproveDialog, setShowApproveDialog] = useState(false);
  const [showRejectDialog, setShowRejectDialog] = useState(false);
  const [approveNotes, setApproveNotes] = useState('');
  const [rejectReason, setRejectReason] = useState('');
  const [isApproving, setIsApproving] = useState(false);
  const [isRejecting, setIsRejecting] = useState(false);

  const handleApprove = async () => {
    setIsApproving(true);
    try {
      await onApproveAll(approveNotes.trim() || undefined);
      setShowApproveDialog(false);
      setApproveNotes('');
    } finally {
      setIsApproving(false);
    }
  };

  const handleReject = async () => {
    if (!rejectReason.trim()) return;

    setIsRejecting(true);
    try {
      await onRejectAll(rejectReason.trim());
      setShowRejectDialog(false);
      setRejectReason('');
    } finally {
      setIsRejecting(false);
    }
  };

  if (selectedCount === 0) {
    return null;
  }

  return (
    <div
      className={cn(
        'flex items-center gap-3 rounded-lg border bg-muted/50 px-4 py-2',
        className
      )}
    >
      <span className="text-sm font-medium">
        {selectedCount} tour{selectedCount !== 1 ? 's' : ''} selected
      </span>

      <div className="flex items-center gap-2 ml-auto">
        <Button
          variant="outline"
          size="sm"
          onClick={onClearSelection}
          disabled={isProcessing}
        >
          Clear
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button size="sm" disabled={isProcessing}>
              {isProcessing ? (
                <Loader2 className="h-4 w-4 mr-2 animate-spin" />
              ) : (
                <ChevronDown className="h-4 w-4 mr-2" />
              )}
              Actions
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => setShowApproveDialog(true)}>
              <Check className="h-4 w-4 mr-2 text-green-600" />
              Approve all ({selectedCount})
            </DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem
              onClick={() => setShowRejectDialog(true)}
              className="text-destructive focus:text-destructive"
            >
              <X className="h-4 w-4 mr-2" />
              Reject all ({selectedCount})
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      {/* Bulk Approve Dialog */}
      <AlertDialog open={showApproveDialog} onOpenChange={setShowApproveDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2">
              <Check className="h-5 w-5 text-green-600" />
              Approve {selectedCount} Tour{selectedCount !== 1 ? 's' : ''}
            </AlertDialogTitle>
            <AlertDialogDescription>
              This will publish all selected tours and make them available to users.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <div className="py-4">
            <Label htmlFor="approveNotes" className="text-sm font-medium">
              Notes (optional)
            </Label>
            <Textarea
              id="approveNotes"
              placeholder="Add notes for all approved tours..."
              value={approveNotes}
              onChange={(e) => setApproveNotes(e.target.value)}
              rows={2}
              className="mt-2"
            />
          </div>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isApproving}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleApprove}
              disabled={isApproving}
              className="bg-green-600 hover:bg-green-700"
            >
              {isApproving ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Approving...
                </>
              ) : (
                <>
                  <Check className="h-4 w-4 mr-2" />
                  Approve All
                </>
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Bulk Reject Dialog */}
      <AlertDialog open={showRejectDialog} onOpenChange={setShowRejectDialog}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2 text-destructive">
              <AlertTriangle className="h-5 w-5" />
              Reject {selectedCount} Tour{selectedCount !== 1 ? 's' : ''}
            </AlertDialogTitle>
            <AlertDialogDescription>
              All selected tours will be rejected with the same reason. Creators
              will be notified.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <div className="py-4">
            <Label htmlFor="rejectReason" className="text-sm font-medium">
              Rejection reason *
            </Label>
            <Textarea
              id="rejectReason"
              placeholder="Provide a reason for rejection..."
              value={rejectReason}
              onChange={(e) => setRejectReason(e.target.value)}
              rows={3}
              className="mt-2"
            />
          </div>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={isRejecting}>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleReject}
              disabled={isRejecting || !rejectReason.trim()}
              className="bg-destructive hover:bg-destructive/90"
            >
              {isRejecting ? (
                <>
                  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                  Rejecting...
                </>
              ) : (
                <>
                  <X className="h-4 w-4 mr-2" />
                  Reject All
                </>
              )}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}

// Selection checkbox for individual items
interface SelectionCheckboxProps {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  disabled?: boolean;
}

export function SelectionCheckbox({
  checked,
  onCheckedChange,
  disabled = false,
}: SelectionCheckboxProps) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      disabled={disabled}
      onClick={(e) => {
        e.stopPropagation();
        onCheckedChange(!checked);
      }}
      className={cn(
        'h-5 w-5 rounded border-2 flex items-center justify-center transition-colors',
        checked
          ? 'bg-primary border-primary text-primary-foreground'
          : 'border-muted-foreground/30 hover:border-primary/50',
        disabled && 'opacity-50 cursor-not-allowed'
      )}
    >
      {checked && <Check className="h-3 w-3" />}
    </button>
  );
}

// Select all header checkbox
interface SelectAllCheckboxProps {
  checked: boolean;
  indeterminate?: boolean;
  onCheckedChange: (checked: boolean) => void;
  disabled?: boolean;
}

export function SelectAllCheckbox({
  checked,
  indeterminate = false,
  onCheckedChange,
  disabled = false,
}: SelectAllCheckboxProps) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={indeterminate ? 'mixed' : checked}
      disabled={disabled}
      onClick={(e) => {
        e.stopPropagation();
        onCheckedChange(!checked);
      }}
      className={cn(
        'h-5 w-5 rounded border-2 flex items-center justify-center transition-colors',
        checked || indeterminate
          ? 'bg-primary border-primary text-primary-foreground'
          : 'border-muted-foreground/30 hover:border-primary/50',
        disabled && 'opacity-50 cursor-not-allowed'
      )}
    >
      {checked && <Check className="h-3 w-3" />}
      {indeterminate && !checked && (
        <div className="h-0.5 w-2.5 bg-current rounded" />
      )}
    </button>
  );
}
