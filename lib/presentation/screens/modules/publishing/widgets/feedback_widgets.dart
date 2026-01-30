import 'package:flutter/material.dart';

import '../../../../../data/models/review_feedback_model.dart';

/// Feedback list widget
class FeedbackList extends StatelessWidget {
  final List<ReviewFeedbackModel> feedback;
  final bool showActions;
  final ValueChanged<ReviewFeedbackModel>? onResolve;

  const FeedbackList({
    super.key,
    required this.feedback,
    this.showActions = false,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    if (feedback.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedback.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return FeedbackCard(
          feedback: feedback[index],
          showActions: showActions,
          onResolve: onResolve,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No feedback yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}

/// Individual feedback card
class FeedbackCard extends StatelessWidget {
  final ReviewFeedbackModel feedback;
  final bool showActions;
  final ValueChanged<ReviewFeedbackModel>? onResolve;

  const FeedbackCard({
    super.key,
    required this.feedback,
    this.showActions = false,
    this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildTypeIcon(context, feedback.type),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feedback.reviewerName.isNotEmpty
                          ? feedback.reviewerName
                          : 'Reviewer',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(feedback.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTypeBadge(context, feedback.type),
            ],
          ),
          const SizedBox(height: 12),

          // Comment
          Text(
            feedback.message,
            style: theme.textTheme.bodyMedium,
          ),

          // Stop reference
          if (feedback.stopId != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Stop: ${feedback.stopId}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Resolved status
          if (feedback.resolved) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Resolved',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Actions
          if (showActions && !feedback.resolved) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => onResolve?.call(feedback),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Mark Resolved'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeIcon(BuildContext context, FeedbackType type) {
    final color = _getTypeColor(type);
    return CircleAvatar(
      radius: 16,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(
        _getTypeIcon(type),
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context, FeedbackType type) {
    final color = _getTypeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        type.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  IconData _getTypeIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.required:
        return Icons.error;
      case FeedbackType.suggestion:
        return Icons.lightbulb;
      case FeedbackType.compliment:
        return Icons.thumb_up;
      case FeedbackType.issue:
        return Icons.help;
    }
  }

  Color _getTypeColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.required:
        return Colors.red;
      case FeedbackType.suggestion:
        return Colors.orange;
      case FeedbackType.compliment:
        return Colors.green;
      case FeedbackType.issue:
        return Colors.blue;
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

/// Feedback form for adding new feedback
class FeedbackForm extends StatefulWidget {
  final ValueChanged<({String comment, FeedbackType type, String? stopId})>
      onSubmit;
  final bool isLoading;
  final List<String>? stopIds;

  const FeedbackForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.stopIds,
  });

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _commentController = TextEditingController();
  FeedbackType _selectedType = FeedbackType.suggestion;
  String? _selectedStopId;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Feedback',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Feedback type selector
            Text(
              'Type',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<FeedbackType>(
              segments: FeedbackType.values.map((type) {
                return ButtonSegment(
                  value: type,
                  label: Text(type.displayName),
                );
              }).toList(),
              selected: {_selectedType},
              onSelectionChanged: (selection) {
                setState(() => _selectedType = selection.first);
              },
            ),
            const SizedBox(height: 16),

            // Stop selector (optional)
            if (widget.stopIds != null && widget.stopIds!.isNotEmpty) ...[
              Text(
                'Related Stop (optional)',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                value: _selectedStopId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select a stop',
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('General feedback'),
                  ),
                  ...widget.stopIds!.map((id) => DropdownMenuItem(
                        value: id,
                        child: Text('Stop $id'),
                      )),
                ],
                onChanged: (value) {
                  setState(() => _selectedStopId = value);
                },
              ),
              const SizedBox(height: 16),
            ],

            // Comment input
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment',
                hintText: 'Enter your feedback...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
            ),
            const SizedBox(height: 16),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.isLoading || _commentController.text.isEmpty
                    ? null
                    : _submit,
                icon: widget.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(widget.isLoading ? 'Sending...' : 'Add Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    widget.onSubmit((
      comment: _commentController.text,
      type: _selectedType,
      stopId: _selectedStopId,
    ));
    _commentController.clear();
    setState(() {
      _selectedStopId = null;
      _selectedType = FeedbackType.suggestion;
    });
  }
}
