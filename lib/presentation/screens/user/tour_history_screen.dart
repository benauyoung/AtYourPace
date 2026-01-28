import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/tour_history_provider.dart';

class TourHistoryScreen extends ConsumerWidget {
  const TourHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Tours'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  _showClearConfirmation(context, ref);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: ListTile(
                    leading: Icon(Icons.delete_sweep),
                    title: Text('Clear History'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'In Progress'),
              Tab(text: 'Completed'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InProgressTab(),
            _CompletedTab(),
            _HistoryTab(),
          ],
        ),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text(
          'This will remove all your tour history. Your completed tours and achievements will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(tourHistoryProvider.notifier).clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _InProgressTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inProgressAsync = ref.watch(inProgressToursProvider);

    return inProgressAsync.when(
      data: (tours) {
        if (tours.isEmpty) {
          return _EmptyState(
            icon: Icons.play_circle_outline,
            title: 'No tours in progress',
            subtitle: 'Start a tour to see your progress here',
            actionLabel: 'Discover Tours',
            onAction: () => context.go(RouteNames.discover),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tours.length,
          itemBuilder: (context, index) {
            final (tour, record) = tours[index];
            return _TourHistoryCard(
              key: ValueKey(tour.id),
              tour: tour,
              record: record,
              onTap: () => context.push(RouteNames.tourDetailsPath(tour.id)),
              onResume: () => context.go(RouteNames.tourPlaybackPath(tour.id)),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _CompletedTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedAsync = ref.watch(completedToursProvider);

    return completedAsync.when(
      data: (tours) {
        if (tours.isEmpty) {
          return _EmptyState(
            icon: Icons.emoji_events_outlined,
            title: 'No completed tours yet',
            subtitle: 'Complete a tour to earn achievements',
            actionLabel: 'Start a Tour',
            onAction: () => context.go(RouteNames.discover),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tours.length,
          itemBuilder: (context, index) {
            final (tour, record) = tours[index];
            return _TourHistoryCard(
              key: ValueKey(tour.id),
              tour: tour,
              record: record,
              onTap: () => context.push(RouteNames.tourDetailsPath(tour.id)),
              showCompletedBadge: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(recentlyViewedToursProvider);

    return historyAsync.when(
      data: (tours) {
        if (tours.isEmpty) {
          return _EmptyState(
            icon: Icons.history,
            title: 'No history yet',
            subtitle: 'Tours you view will appear here',
            actionLabel: 'Discover Tours',
            onAction: () => context.go(RouteNames.discover),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tours.length,
          itemBuilder: (context, index) {
            final (tour, record) = tours[index];
            return Dismissible(
              key: Key(tour.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                ref.read(tourHistoryProvider.notifier).removeFromHistory(tour.id);
              },
              child: _TourHistoryCard(
                tour: tour,
                record: record,
                onTap: () => context.push(RouteNames.tourDetailsPath(tour.id)),
                showTimestamp: true,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class _TourHistoryCard extends StatelessWidget {
  final TourModel tour;
  final TourViewRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onResume;
  final bool showCompletedBadge;
  final bool showTimestamp;

  const _TourHistoryCard({
    super.key,
    required this.tour,
    required this.record,
    this.onTap,
    this.onResume,
    this.showCompletedBadge = false,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Tour icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        tour.tourType.icon,
                        color: context.colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    if (showCompletedBadge)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Tour info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.city ?? 'Untitled Tour',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tour.category.displayName} • ${tour.creatorName}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Progress bar or timestamp
                    if (record.progressPercent != null && !record.completed)
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: record.progressPercent! / 100,
                                minHeight: 6,
                                backgroundColor: context.colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${record.progressPercent}%',
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      )
                    else if (showTimestamp)
                      Text(
                        _formatTimestamp(record.viewedAt),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      )
                    else if (record.completed)
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Colors.green),
                          const SizedBox(width: 4),
                          Text(
                            'Completed ${_formatTimestamp(record.viewedAt)}',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Resume button
              if (onResume != null && !record.completed)
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: onResume,
                  tooltip: 'Resume',
                  style: IconButton.styleFrom(
                    backgroundColor: context.colorScheme.primaryContainer,
                    foregroundColor: context.colorScheme.onPrimaryContainer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: context.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.explore),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
