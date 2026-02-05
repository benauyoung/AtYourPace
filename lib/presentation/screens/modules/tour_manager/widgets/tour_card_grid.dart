import 'package:flutter/material.dart';

import '../../../../../data/models/tour_model.dart';

/// Grid card for tour display
class TourCardGrid extends StatelessWidget {
  final TourModel tour;
  final String? coverImageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;
  final VoidCallback? onWithdraw;

  const TourCardGrid({
    super.key,
    required this.tour,
    this.coverImageUrl,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onDuplicate,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  coverImageUrl != null
                      ? Image.network(
                          coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                        )
                      : _buildPlaceholder(context),
                  // Status badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildStatusBadge(context, tour.status),
                  ),
                  // Actions
                  Positioned(
                    top: 8,
                    right: 8,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'duplicate':
                            onDuplicate?.call();
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
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    tour.displayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Category & Type
                  Row(
                    children: [
                      Icon(
                        tour.category.icon,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour.category.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        tour.tourType.icon,
                        size: 12,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tour.tourType.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Stats
                  Row(
                    children: [
                      if (tour.city != null) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tour.city!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      if (tour.isPublished) ...[
                        Icon(
                          Icons.play_circle_outline,
                          size: 12,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tour.stats.totalPlays}',
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
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, TourStatus status) {
    final theme = Theme.of(context);
    final color = _getStatusColor(status, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
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
}
