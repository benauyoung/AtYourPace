import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/publishing_submission_model.dart';
import 'providers/publishing_provider.dart';
import 'widgets/feedback_widgets.dart';
import 'widgets/submission_checklist.dart';

/// Screen for submitting a tour for review
class SubmissionScreen extends ConsumerStatefulWidget {
  final String tourId;
  final String versionId;

  const SubmissionScreen({
    super.key,
    required this.tourId,
    required this.versionId,
  });

  @override
  ConsumerState<SubmissionScreen> createState() => _SubmissionScreenState();
}

class _SubmissionScreenState extends ConsumerState<SubmissionScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (tourId: widget.tourId, versionId: widget.versionId);
    final state = ref.watch(publishingProvider(params));
    final notifier = ref.read(publishingProvider(params).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit for Review'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status section (if already submitted)
                  if (state.hasSubmission) ...[
                    _buildStatusSection(context, state),
                    const SizedBox(height: 24),
                  ],

                  // Feedback section (if has feedback)
                  if (state.hasFeedback) ...[
                    _buildFeedbackSection(context, state),
                    const SizedBox(height: 24),
                  ],

                  // Checklist section (if not yet approved)
                  if (!state.isApproved) ...[
                    SubmissionChecklist(
                      errors: state.checklistErrors,
                      onRefresh: notifier.refreshChecklist,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Submission form (if can submit)
                  if (!state.hasSubmission || state.needsChanges) ...[
                    _buildSubmissionForm(context, state, notifier),
                  ],

                  // Error message
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorBanner(context, state.error!, notifier),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusSection(BuildContext context, PublishingState state) {
    final theme = Theme.of(context);
    final submission = state.submission!;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (state.isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      statusText = 'Your tour is waiting for review';
    } else if (state.isInReview) {
      statusColor = Colors.blue;
      statusIcon = Icons.rate_review;
      statusText = 'Your tour is being reviewed';
    } else if (state.isApproved) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Your tour has been approved!';
    } else if (state.isRejected) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.cancel;
      statusText = 'Your tour was not approved';
    } else if (state.needsChanges) {
      statusColor = Colors.orange;
      statusIcon = Icons.edit_note;
      statusText = 'Changes requested';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.info;
      statusText = submission.status.displayName;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Icon(statusIcon, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submission Status',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Text(
                        statusText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Submitted ${_formatDate(submission.submittedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (submission.resubmissionJustification != null &&
                submission.resubmissionJustification!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${submission.resubmissionJustification}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (state.isPending || state.isInReview) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _confirmWithdraw(context, ref),
                icon: const Icon(Icons.undo),
                label: const Text('Withdraw Submission'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context, PublishingState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.feedback,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Reviewer Feedback',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  '${state.feedback.length} items',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FeedbackList(
              feedback: state.feedback,
              showActions: state.needsChanges,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionForm(
    BuildContext context,
    PublishingState state,
    PublishingNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final isResubmit = state.needsChanges;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isResubmit ? Icons.refresh : Icons.send,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isResubmit ? 'Resubmit for Review' : 'Submit for Review',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: isResubmit
                    ? 'What changes did you make?'
                    : 'Notes for reviewer (optional)',
                hintText: isResubmit
                    ? 'Describe the changes you made based on feedback...'
                    : 'Any additional information for the reviewer...',
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              maxLength: 500,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.canSubmit && !state.isSubmitting
                    ? () => _submit(notifier, isResubmit)
                    : null,
                icon: state.isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(isResubmit ? Icons.refresh : Icons.send),
                label: Text(
                  state.isSubmitting
                      ? 'Submitting...'
                      : isResubmit
                          ? 'Resubmit'
                          : 'Submit for Review',
                ),
              ),
            ),
            if (!state.canSubmit) ...[
              const SizedBox(height: 8),
              Text(
                'Fix the checklist issues above before submitting',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    String error,
    PublishingNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(error)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: notifier.clearError,
          ),
        ],
      ),
    );
  }

  Future<void> _submit(PublishingNotifier notifier, bool isResubmit) async {
    final notes = _notesController.text.isNotEmpty ? _notesController.text : null;

    bool success;
    if (isResubmit) {
      success = await notifier.resubmit(justification: notes);
    } else {
      success = await notifier.submitForReview(notes: notes);
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isResubmit
                ? 'Tour resubmitted for review'
                : 'Tour submitted for review',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _notesController.clear();
    }
  }

  void _confirmWithdraw(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Submission?'),
        content: const Text(
          'Are you sure you want to withdraw this submission? '
          'You can resubmit later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final params = (tourId: widget.tourId, versionId: widget.versionId);
              final success = await ref
                  .read(publishingProvider(params).notifier)
                  .withdrawSubmission();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Submission withdrawn'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
