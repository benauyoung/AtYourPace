import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/publishing_submission_model.dart';
import 'providers/publishing_provider.dart';

/// Admin screen for reviewing submission queue
class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewQueueProvider);
    final notifier = ref.read(reviewQueueProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading ? null : notifier.refresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildStatusTabs(context, state, notifier),
        ),
      ),
      body: Column(
        children: [
          // Stats header
          _buildStatsHeader(context, state),

          // Error banner
          if (state.error != null)
            MaterialBanner(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Dismiss'),
                ),
              ],
            ),

          // Submissions list
          Expanded(
            child: state.isLoading && state.submissions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.submissions.isEmpty
                    ? _buildEmptyState(context, state)
                    : _buildSubmissionsList(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs(
    BuildContext context,
    ReviewQueueState state,
    ReviewQueueNotifier notifier,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabChip(
            context,
            label: 'All',
            isSelected: state.filterStatus == null,
            onTap: () => notifier.filterByStatus(null),
          ),
          const SizedBox(width: 8),
          _buildTabChip(
            context,
            label: 'Submitted',
            count: state.pendingCount,
            color: Colors.orange,
            isSelected: state.filterStatus == SubmissionStatus.submitted,
            onTap: () => notifier.filterByStatus(SubmissionStatus.submitted),
          ),
          const SizedBox(width: 8),
          _buildTabChip(
            context,
            label: 'Under Review',
            count: state.inReviewCount,
            color: Colors.blue,
            isSelected: state.filterStatus == SubmissionStatus.underReview,
            onTap: () => notifier.filterByStatus(SubmissionStatus.underReview),
          ),
          const SizedBox(width: 8),
          _buildTabChip(
            context,
            label: 'Approved',
            color: Colors.green,
            isSelected: state.filterStatus == SubmissionStatus.approved,
            onTap: () => notifier.filterByStatus(SubmissionStatus.approved),
          ),
          const SizedBox(width: 8),
          _buildTabChip(
            context,
            label: 'Changes Requested',
            color: Colors.orange,
            isSelected: state.filterStatus == SubmissionStatus.changesRequested,
            onTap: () =>
                notifier.filterByStatus(SubmissionStatus.changesRequested),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(
    BuildContext context, {
    required String label,
    int? count,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? theme.colorScheme.primary).withValues(alpha: 0.2)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? theme.colorScheme.primary)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (color ?? theme.colorScheme.primary)
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color ?? theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(BuildContext context, ReviewQueueState state) {
    final theme = Theme.of(context);

    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context, 'Pending', state.pendingCount, Colors.orange),
          _buildStatItem(context, 'In Review', state.inReviewCount, Colors.blue),
          _buildStatItem(context, 'Total', state.submissions.length, null),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    Color? color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '$count',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ReviewQueueState state) {
    final hasFilter = state.filterStatus != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilter ? Icons.filter_alt_off : Icons.inbox,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              hasFilter ? 'No submissions match filter' : 'No submissions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilter
                  ? 'Try a different filter or check back later'
                  : 'New submissions will appear here',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsList(
    BuildContext context,
    ReviewQueueState state,
    ReviewQueueNotifier notifier,
  ) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.submissions.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.submissions.length) {
            if (!state.isLoading) {
              notifier.loadMore();
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final submission = state.submissions[index];
          return _SubmissionCard(
            submission: submission,
            onTap: () => _openReview(context, submission),
          );
        },
      ),
    );
  }

  void _openReview(BuildContext context, PublishingSubmissionModel submission) {
    // TODO: Navigate to tour review screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open review for tour ${submission.tourId}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Submission card for the queue
class _SubmissionCard extends StatelessWidget {
  final PublishingSubmissionModel submission;
  final VoidCallback onTap;

  const _SubmissionCard({
    required this.submission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(submission.status),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            submission.tourTitle ?? 'Untitled Tour',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(context, submission.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Submitted ${_formatDate(submission.submittedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (submission.tourDescription != null &&
                        submission.tourDescription!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        submission.tourDescription!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, SubmissionStatus status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
