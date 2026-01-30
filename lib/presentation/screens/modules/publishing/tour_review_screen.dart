import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/publishing_submission_model.dart';
import 'providers/publishing_provider.dart';
import 'widgets/feedback_widgets.dart';

/// Admin screen for reviewing a specific tour submission
class TourReviewScreen extends ConsumerWidget {
  final String submissionId;

  const TourReviewScreen({
    super.key,
    required this.submissionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tourReviewProvider(submissionId));
    final notifier = ref.read(tourReviewProvider(submissionId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Tour'),
        actions: [
          // Preview/Edit toggle
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                icon: Icon(Icons.visibility),
                label: Text('Preview'),
              ),
              ButtonSegment(
                value: false,
                icon: Icon(Icons.edit),
                label: Text('Review'),
              ),
            ],
            selected: {state.isPreviewMode},
            onSelectionChanged: (_) => notifier.togglePreviewMode(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.submission == null
              ? _buildNotFound(context)
              : Row(
                  children: [
                    // Main content area
                    Expanded(
                      flex: 3,
                      child: _buildMainContent(context, state),
                    ),
                    // Side panel (review mode only)
                    if (!state.isPreviewMode)
                      SizedBox(
                        width: 400,
                        child: _buildReviewPanel(context, state, notifier),
                      ),
                  ],
                ),
      bottomNavigationBar: state.submission != null && !state.isPreviewMode
          ? _buildActionBar(context, state, notifier)
          : null,
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Submission not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, TourReviewState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Submission info header
          _buildSubmissionHeader(context, state),
          const SizedBox(height: 24),

          // Tour preview placeholder
          _buildTourPreview(context, state),
        ],
      ),
    );
  }

  Widget _buildSubmissionHeader(BuildContext context, TourReviewState state) {
    final theme = Theme.of(context);
    final submission = state.submission!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getStatusColor(submission.status).withValues(alpha: 0.1),
              child: Icon(
                _getStatusIcon(submission.status),
                color: _getStatusColor(submission.status),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tour ID: ${submission.tourId}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Status: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(submission.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          submission.status.displayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(submission.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Submitted ${_formatDate(submission.submittedAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourPreview(BuildContext context, TourReviewState state) {
    final theme = Theme.of(context);

    // Placeholder for tour content preview
    return Card(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tour,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Tour Preview',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tour content would be displayed here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Open full tour preview
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Full Preview'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewPanel(
    BuildContext context,
    TourReviewState state,
    TourReviewNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.rate_review,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Review Feedback',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${state.feedback.length} items',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),

          // Feedback form
          Padding(
            padding: const EdgeInsets.all(16),
            child: FeedbackForm(
              isLoading: state.isSaving,
              onSubmit: (data) => notifier.addFeedback(
                comment: data.comment,
                type: data.type,
                stopId: data.stopId,
              ),
            ),
          ),

          const Divider(height: 1),

          // Feedback list
          Expanded(
            child: state.feedback.isEmpty
                ? Center(
                    child: Text(
                      'No feedback yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.feedback.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      return FeedbackCard(feedback: state.feedback[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(
    BuildContext context,
    TourReviewState state,
    TourReviewNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Error message
          if (state.error != null)
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.error, color: theme.colorScheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            )
          else
            const Spacer(),

          // Action buttons
          OutlinedButton(
            onPressed: state.isSaving
                ? null
                : () => _showRejectDialog(context, notifier),
            child: const Text('Reject'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: state.isSaving || state.feedback.isEmpty
                ? null
                : () => _confirmRequestChanges(context, notifier),
            icon: const Icon(Icons.edit_note),
            label: const Text('Request Changes'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: state.isSaving
                ? null
                : () => _confirmApprove(context, notifier),
            icon: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, TourReviewNotifier notifier) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Submission'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) return;
              Navigator.pop(context);
              final success =
                  await notifier.reject(reason: reasonController.text);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Submission rejected'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _confirmRequestChanges(
    BuildContext context,
    TourReviewNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Changes'),
        content: const Text(
          'The creator will be notified to make changes based on your feedback. '
          'Make sure you have added all necessary feedback before proceeding.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.requestChanges();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Changes requested'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Request Changes'),
          ),
        ],
      ),
    );
  }

  void _confirmApprove(BuildContext context, TourReviewNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Tour'),
        content: const Text(
          'This tour will be published and visible to users. '
          'Are you sure you want to approve it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.approve();
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tour approved and published!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.draft:
        return Colors.grey;
      case SubmissionStatus.submitted:
        return Colors.orange;
      case SubmissionStatus.underReview:
        return Colors.blue;
      case SubmissionStatus.approved:
        return Colors.green;
      case SubmissionStatus.rejected:
        return Colors.red;
      case SubmissionStatus.changesRequested:
        return Colors.amber;
      case SubmissionStatus.withdrawn:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.draft:
        return Icons.edit;
      case SubmissionStatus.submitted:
        return Icons.hourglass_empty;
      case SubmissionStatus.underReview:
        return Icons.rate_review;
      case SubmissionStatus.approved:
        return Icons.check_circle;
      case SubmissionStatus.rejected:
        return Icons.cancel;
      case SubmissionStatus.changesRequested:
        return Icons.edit_note;
      case SubmissionStatus.withdrawn:
        return Icons.undo;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
