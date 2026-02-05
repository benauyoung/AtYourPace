import 'package:flutter/material.dart';

import '../../../../../data/models/tour_model.dart';

/// Compact tour card for list view
class TourCardCompact extends StatelessWidget {
  final TourModel tour;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onViewAnalytics;
  final VoidCallback? onWithdraw;

  const TourCardCompact({
    super.key,
    required this.tour,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onViewAnalytics,
    this.onWithdraw,
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(tour.status, theme),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Tour info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tour.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildStatusBadge(context, tour.status),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Details row
                    Row(
                      children: [
                        Icon(
                          tour.category.icon,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.category.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          tour.tourType.icon,
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tour.tourType.displayName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (tour.city != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tour.city!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Stats row
                    Row(
                      children: [
                        Text(
                          'Updated ${_formatDate(tour.updatedAt)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (tour.isPublished) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.visibility,
                            size: 12,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${tour.stats.totalPlays} plays',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'duplicate':
                      onDuplicate?.call();
                      break;
                    case 'analytics':
                      onViewAnalytics?.call();
                      break;
                    case 'withdraw':
                      onWithdraw?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (tour.isEditable)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  if (tour.isPendingReview)
                    const PopupMenuItem(
                      value: 'withdraw',
                      child: Row(
                        children: [
                          Icon(Icons.undo),
                          SizedBox(width: 8),
                          Text('Withdraw & Edit'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                  if (tour.isPublished)
                    const PopupMenuItem(
                      value: 'analytics',
                      child: Row(
                        children: [
                          Icon(Icons.analytics),
                          SizedBox(width: 8),
                          Text('View Analytics'),
                        ],
                      ),
                    ),
                  if (tour.isEditable) ...[
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: theme.colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TourStatus status) {
    final theme = Theme.of(context);
    final color = _getStatusColor(status, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(TourStatus status, ThemeData theme) {
    switch (status) {
      case TourStatus.draft:
        return Colors.grey;
      case TourStatus.pendingReview:
        return Colors.orange;
      case TourStatus.approved:
        return Colors.green;
      case TourStatus.rejected:
        return theme.colorScheme.error;
      case TourStatus.hidden:
        return Colors.blueGrey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
