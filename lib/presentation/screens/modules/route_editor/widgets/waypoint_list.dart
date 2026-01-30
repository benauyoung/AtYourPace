import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/waypoint_model.dart';
import '../providers/route_editor_provider.dart';

/// Draggable list of waypoints for route editing
class WaypointList extends ConsumerWidget {
  final String tourId;
  final String versionId;
  final String? routeId;
  final void Function(int index)? onWaypointTapped;
  final void Function(int index)? onWaypointDeleted;
  final void Function(int index)? onWaypointEdit;

  const WaypointList({
    super.key,
    required this.tourId,
    required this.versionId,
    this.routeId,
    this.onWaypointTapped,
    this.onWaypointDeleted,
    this.onWaypointEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (
      tourId: tourId,
      versionId: versionId,
      routeId: routeId,
    );
    final routeState = ref.watch(routeEditorProvider(params));
    final notifier = ref.read(routeEditorProvider(params).notifier);

    if (routeState.waypoints.isEmpty) {
      return const _EmptyWaypointList();
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: routeState.waypoints.length,
      onReorder: (oldIndex, newIndex) {
        // ReorderableListView passes newIndex as if the item is still at oldIndex
        if (newIndex > oldIndex) newIndex--;
        notifier.reorderWaypoints(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final waypoint = routeState.waypoints[index];
        final isSelected = index == routeState.selectedWaypointIndex;
        final isOverlapping = routeState.overlappingWaypointIndices.contains(index);

        return _WaypointListItem(
          key: ValueKey('waypoint_$index'),
          index: index,
          waypoint: waypoint,
          isSelected: isSelected,
          isOverlapping: isOverlapping,
          onTap: () => onWaypointTapped?.call(index),
          onDelete: () => onWaypointDeleted?.call(index),
          onEdit: () => onWaypointEdit?.call(index),
        );
      },
    );
  }
}

class _EmptyWaypointList extends StatelessWidget {
  const _EmptyWaypointList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_location_alt,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No waypoints yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap on the map to add waypoints',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WaypointListItem extends StatelessWidget {
  final int index;
  final WaypointModel waypoint;
  final bool isSelected;
  final bool isOverlapping;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const _WaypointListItem({
    super.key,
    required this.index,
    required this.waypoint,
    required this.isSelected,
    required this.isOverlapping,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : isOverlapping
              ? Colors.orange.shade50
              : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 12),
              // Order number
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getTypeColor(waypoint.type),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Waypoint info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            waypoint.name.isNotEmpty
                                ? waypoint.name
                                : 'Waypoint ${index + 1}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOverlapping)
                          Tooltip(
                            message: 'Overlapping trigger radius',
                            child: Icon(
                              Icons.warning,
                              size: 16,
                              color: Colors.orange.shade700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _TypeChip(type: waypoint.type),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.radar,
                          size: 12,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${waypoint.triggerRadius}m',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        if (waypoint.hasLinkedStop) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.headphones,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
                tooltip: 'Edit waypoint',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: onDelete,
                color: theme.colorScheme.error,
                tooltip: 'Delete waypoint',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(WaypointType type) {
    switch (type) {
      case WaypointType.stop:
        return const Color(0xFF2196F3); // Blue
      case WaypointType.waypoint:
        return const Color(0xFF9E9E9E); // Grey
      case WaypointType.poi:
        return const Color(0xFF4CAF50); // Green
    }
  }
}

class _TypeChip extends StatelessWidget {
  final WaypointType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTypeColor(type).withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getTypeName(type),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getTypeColor(type),
        ),
      ),
    );
  }

  Color _getTypeColor(WaypointType type) {
    switch (type) {
      case WaypointType.stop:
        return const Color(0xFF2196F3);
      case WaypointType.waypoint:
        return const Color(0xFF9E9E9E);
      case WaypointType.poi:
        return const Color(0xFF4CAF50);
    }
  }

  String _getTypeName(WaypointType type) {
    switch (type) {
      case WaypointType.stop:
        return 'Stop';
      case WaypointType.waypoint:
        return 'Pass';
      case WaypointType.poi:
        return 'POI';
    }
  }
}
