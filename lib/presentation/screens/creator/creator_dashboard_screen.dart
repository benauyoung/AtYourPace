import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/tour_providers.dart';

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toursAsync = ref.watch(creatorToursProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => context.go(RouteNames.creatorAnalytics),
            tooltip: 'Analytics',
          ),
        ],
      ),
      body: toursAsync.when(
        data: (tours) {
          if (tours.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_box_outlined,
                    size: 80,
                    color: context.colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tours yet',
                    style: context.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first tour to get started',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go(RouteNames.createTour),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Tour'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats summary
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.tour,
                      label: 'Total Tours',
                      value: tours.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      label: 'Published',
                      value: tours
                          .where((t) => t.status == TourStatus.approved)
                          .length
                          .toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.pending,
                      label: 'Pending',
                      value: tours
                          .where((t) => t.status == TourStatus.pendingReview)
                          .length
                          .toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tours list
              Text(
                'Your Tours',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...tours.map((tour) => _TourListItem(tour: tour)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RouteNames.createTour),
        icon: const Icon(Icons.add),
        label: const Text('Create Tour'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: context.primaryColor),
            const SizedBox(height: 8),
            Text(
              value,
              style: context.textTheme.headlineSmall,
            ),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourListItem extends StatelessWidget {
  final TourModel tour;

  const _TourListItem({required this.tour});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            tour.tourType == TourType.walking
                ? Icons.directions_walk
                : Icons.directions_car,
            color: context.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(tour.city ?? 'Untitled Tour'),
        subtitle: Row(
          children: [
            _StatusChip(status: tour.status),
            const SizedBox(width: 8),
            Text(tour.category.displayName),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                context.go(RouteNames.editTourPath(tour.id));
                break;
              case 'preview':
                context.go(RouteNames.tourPreviewPath(tour.id));
                break;
            }
          },
          itemBuilder: (context) => [
            if (tour.isEditable)
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'preview',
              child: ListTile(
                leading: Icon(Icons.preview),
                title: Text('Preview'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: tour.isEditable
            ? () => context.go(RouteNames.editTourPath(tour.id))
            : () => context.go(RouteNames.tourPreviewPath(tour.id)),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TourStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case TourStatus.draft:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        break;
      case TourStatus.pendingReview:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case TourStatus.approved:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case TourStatus.rejected:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
      case TourStatus.hidden:
        backgroundColor = Colors.grey.shade300;
        textColor = Colors.grey.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: context.textTheme.labelSmall?.copyWith(color: textColor),
      ),
    );
  }
}
