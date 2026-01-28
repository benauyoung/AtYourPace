import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';

/// A reusable empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;
  final bool compact;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.customAction,
    this.compact = false,
  });

  /// Empty state for no tours found
  factory EmptyState.noTours({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.tour_outlined,
      title: 'No Tours Found',
      description: 'We couldn\'t find any tours matching your criteria.',
      actionLabel: 'Explore Tours',
      onAction: onExplore,
    );
  }

  /// Empty state for no favorites
  factory EmptyState.noFavorites({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: 'No Favorites Yet',
      description: 'Tours you save will appear here for easy access.',
      actionLabel: 'Discover Tours',
      onAction: onExplore,
    );
  }

  /// Empty state for no downloads
  factory EmptyState.noDownloads({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.download_outlined,
      title: 'No Downloads',
      description: 'Download tours to enjoy them offline.',
      actionLabel: 'Browse Tours',
      onAction: onExplore,
    );
  }

  /// Empty state for no reviews
  factory EmptyState.noReviews({VoidCallback? onWriteReview}) {
    return EmptyState(
      icon: Icons.rate_review_outlined,
      title: 'No Reviews Yet',
      description: 'Be the first to share your experience!',
      actionLabel: 'Write a Review',
      onAction: onWriteReview,
    );
  }

  /// Empty state for no history
  factory EmptyState.noHistory({VoidCallback? onExplore}) {
    return EmptyState(
      icon: Icons.history,
      title: 'No Tour History',
      description: 'Tours you\'ve taken will appear here.',
      actionLabel: 'Start Exploring',
      onAction: onExplore,
    );
  }

  /// Empty state for no search results
  factory EmptyState.noSearchResults({VoidCallback? onClear}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results',
      description: 'Try adjusting your search or filters.',
      actionLabel: 'Clear Filters',
      onAction: onClear,
    );
  }

  /// Empty state for no notifications
  factory EmptyState.noNotifications() {
    return const EmptyState(
      icon: Icons.notifications_none,
      title: 'No Notifications',
      description: 'You\'re all caught up!',
    );
  }

  /// Empty state for no stops in a tour
  factory EmptyState.noStops({VoidCallback? onAddStop}) {
    return EmptyState(
      icon: Icons.location_off,
      title: 'No Stops Added',
      description: 'Add stops to create your tour route.',
      actionLabel: 'Add First Stop',
      onAction: onAddStop,
    );
  }

  /// Empty state for offline mode
  factory EmptyState.offline({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.cloud_off,
      title: 'You\'re Offline',
      description: 'Please check your internet connection.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Empty state for creator with no tours
  factory EmptyState.noCreatedTours({VoidCallback? onCreate}) {
    return EmptyState(
      icon: Icons.add_location_alt_outlined,
      title: 'Create Your First Tour',
      description: 'Share your local knowledge with the world.',
      actionLabel: 'Create Tour',
      onAction: onCreate,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall,
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onAction != null && actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: 24),
              customAction!,
            ] else if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A card-based empty state for inline use
class EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
