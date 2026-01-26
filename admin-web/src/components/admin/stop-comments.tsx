'use client';

import { useState } from 'react';
import { MessageSquare, Send, Trash2, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from '@/components/ui/collapsible';
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
import { cn } from '@/lib/utils';

export interface StopComment {
  id: string;
  stopId: string;
  authorId: string;
  authorName: string;
  authorEmail: string;
  content: string;
  createdAt: Date;
  resolved?: boolean;
  resolvedAt?: Date;
  resolvedBy?: string;
}

interface StopCommentsProps {
  stopId: string;
  stopName: string;
  comments: StopComment[];
  onAddComment: (stopId: string, content: string) => Promise<void>;
  onDeleteComment: (commentId: string) => Promise<void>;
  onResolveComment?: (commentId: string) => Promise<void>;
  isLoading?: boolean;
  currentUserId?: string;
  className?: string;
}

export function StopComments({
  stopId,
  stopName,
  comments,
  onAddComment,
  onDeleteComment,
  onResolveComment,
  isLoading = false,
  currentUserId,
  className,
}: StopCommentsProps) {
  const [isOpen, setIsOpen] = useState(comments.length > 0);
  const [newComment, setNewComment] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  const unresolvedComments = comments.filter((c) => !c.resolved);
  const resolvedComments = comments.filter((c) => c.resolved);

  const handleSubmit = async () => {
    if (!newComment.trim() || isSubmitting) return;

    setIsSubmitting(true);
    try {
      await onAddComment(stopId, newComment.trim());
      setNewComment('');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteId || isDeleting) return;

    setIsDeleting(true);
    try {
      await onDeleteComment(deleteId);
    } finally {
      setIsDeleting(false);
      setDeleteId(null);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && (e.metaKey || e.ctrlKey)) {
      e.preventDefault();
      handleSubmit();
    }
  };

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const formatDate = (date: Date) => {
    return new Intl.DateTimeFormat('en-US', {
      month: 'short',
      day: 'numeric',
      hour: 'numeric',
      minute: '2-digit',
    }).format(date);
  };

  return (
    <Collapsible open={isOpen} onOpenChange={setIsOpen} className={className}>
      <CollapsibleTrigger asChild>
        <Button
          variant="ghost"
          size="sm"
          className={cn(
            'gap-2 text-muted-foreground hover:text-foreground',
            unresolvedComments.length > 0 && 'text-orange-600 hover:text-orange-700'
          )}
        >
          <MessageSquare className="h-4 w-4" />
          {comments.length > 0 ? (
            <>
              {unresolvedComments.length} comment
              {unresolvedComments.length !== 1 ? 's' : ''}
              {resolvedComments.length > 0 && (
                <span className="text-xs text-muted-foreground">
                  (+{resolvedComments.length} resolved)
                </span>
              )}
            </>
          ) : (
            'Add comment'
          )}
        </Button>
      </CollapsibleTrigger>

      <CollapsibleContent className="mt-3 space-y-3">
        {/* Existing comments */}
        {unresolvedComments.length > 0 && (
          <div className="space-y-3">
            {unresolvedComments.map((comment) => (
              <CommentItem
                key={comment.id}
                comment={comment}
                onDelete={() => setDeleteId(comment.id)}
                onResolve={onResolveComment ? () => onResolveComment(comment.id) : undefined}
                canDelete={currentUserId === comment.authorId}
                formatDate={formatDate}
                getInitials={getInitials}
              />
            ))}
          </div>
        )}

        {/* Resolved comments (collapsed) */}
        {resolvedComments.length > 0 && (
          <details className="text-sm">
            <summary className="cursor-pointer text-muted-foreground hover:text-foreground">
              {resolvedComments.length} resolved comment
              {resolvedComments.length !== 1 ? 's' : ''}
            </summary>
            <div className="mt-2 space-y-2 pl-2 border-l-2 border-muted">
              {resolvedComments.map((comment) => (
                <CommentItem
                  key={comment.id}
                  comment={comment}
                  onDelete={() => setDeleteId(comment.id)}
                  canDelete={currentUserId === comment.authorId}
                  formatDate={formatDate}
                  getInitials={getInitials}
                  isResolved
                />
              ))}
            </div>
          </details>
        )}

        {/* New comment input */}
        <div className="flex gap-2">
          <Textarea
            placeholder={`Comment on "${stopName}"...`}
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            onKeyDown={handleKeyDown}
            rows={2}
            className="resize-none text-sm"
            disabled={isSubmitting || isLoading}
          />
          <Button
            size="icon"
            onClick={handleSubmit}
            disabled={!newComment.trim() || isSubmitting || isLoading}
            className="shrink-0"
          >
            {isSubmitting ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              <Send className="h-4 w-4" />
            )}
          </Button>
        </div>
        <p className="text-xs text-muted-foreground">
          Press Ctrl+Enter to submit
        </p>

        {/* Delete confirmation dialog */}
        <AlertDialog open={!!deleteId} onOpenChange={() => setDeleteId(null)}>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle>Delete comment?</AlertDialogTitle>
              <AlertDialogDescription>
                This action cannot be undone.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel disabled={isDeleting}>Cancel</AlertDialogCancel>
              <AlertDialogAction
                onClick={handleDelete}
                disabled={isDeleting}
                className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              >
                {isDeleting ? 'Deleting...' : 'Delete'}
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </CollapsibleContent>
    </Collapsible>
  );
}

interface CommentItemProps {
  comment: StopComment;
  onDelete: () => void;
  onResolve?: () => void;
  canDelete: boolean;
  formatDate: (date: Date) => string;
  getInitials: (name: string) => string;
  isResolved?: boolean;
}

function CommentItem({
  comment,
  onDelete,
  onResolve,
  canDelete,
  formatDate,
  getInitials,
  isResolved = false,
}: CommentItemProps) {
  return (
    <div
      className={cn(
        'flex gap-3 rounded-lg border p-3',
        isResolved && 'opacity-60 bg-muted/30'
      )}
    >
      <Avatar className="h-8 w-8 shrink-0">
        <AvatarFallback className="text-xs">
          {getInitials(comment.authorName)}
        </AvatarFallback>
      </Avatar>
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 flex-wrap">
          <span className="font-medium text-sm">{comment.authorName}</span>
          <span className="text-xs text-muted-foreground">
            {formatDate(comment.createdAt)}
          </span>
          {isResolved && (
            <span className="text-xs text-green-600 flex items-center gap-1">
              ✓ Resolved
            </span>
          )}
        </div>
        <p className="text-sm mt-1 whitespace-pre-wrap">{comment.content}</p>
        <div className="flex items-center gap-2 mt-2">
          {onResolve && !isResolved && (
            <Button
              variant="ghost"
              size="sm"
              className="h-6 text-xs text-green-600 hover:text-green-700"
              onClick={onResolve}
            >
              Mark resolved
            </Button>
          )}
          {canDelete && (
            <Button
              variant="ghost"
              size="sm"
              className="h-6 text-xs text-destructive hover:text-destructive"
              onClick={onDelete}
            >
              <Trash2 className="h-3 w-3 mr-1" />
              Delete
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}

// Compact inline version for stop cards
interface StopCommentsBadgeProps {
  count: number;
  unresolvedCount: number;
  onClick?: () => void;
}

export function StopCommentsBadge({
  count,
  unresolvedCount,
  onClick,
}: StopCommentsBadgeProps) {
  if (count === 0) return null;

  return (
    <button
      onClick={onClick}
      className={cn(
        'inline-flex items-center gap-1 text-xs px-2 py-0.5 rounded-full',
        unresolvedCount > 0
          ? 'bg-orange-100 text-orange-700 dark:bg-orange-900/30 dark:text-orange-400'
          : 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'
      )}
    >
      <MessageSquare className="h-3 w-3" />
      {unresolvedCount > 0 ? unresolvedCount : count}
      {unresolvedCount === 0 && ' ✓'}
    </button>
  );
}
