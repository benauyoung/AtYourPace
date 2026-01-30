import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../route_editor/route_editor.dart';
import '../providers/tour_editor_provider.dart';

/// Route tab for tour editing - integrates the Route Editor
class RouteModule extends ConsumerWidget {
  final String? tourId;
  final String? versionId;

  const RouteModule({
    super.key,
    this.tourId,
    this.versionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (tourId: tourId, versionId: versionId);
    final state = ref.watch(tourEditorProvider(params));

    // Show route summary if we have stops, otherwise show empty state
    if (state.stops.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Route summary header
        _buildRouteSummary(context, state),
        const Divider(height: 1),
        // Route editor integration
        Expanded(
          child: RouteEditorScreen(
            tourId: tourId,
            versionId: versionId,
            embedded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Route Created Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Click on the map to add waypoints and create your tour route.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // The route editor will handle adding waypoints
              },
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Start Creating Route'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSummary(BuildContext context, TourEditorState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          _buildStatItem(
            context,
            icon: Icons.pin_drop,
            label: 'Stops',
            value: '${state.stopsCount}',
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            context,
            icon: Icons.straighten,
            label: 'Distance',
            value: _formatDistance(state),
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            context,
            icon: Icons.schedule,
            label: 'Est. Duration',
            value: _formatDuration(state),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              // Open route editor in full screen mode
            },
            icon: const Icon(Icons.fullscreen),
            label: const Text('Full Screen'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDistance(TourEditorState state) {
    // Calculate total distance from stops
    // For now, return placeholder
    final distance = state.stopsCount * 0.3; // Rough estimate
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  String _formatDuration(TourEditorState state) {
    // Estimate based on walking pace and stops
    final minutes = state.stopsCount * 10; // ~10 min per stop
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
  }
}
