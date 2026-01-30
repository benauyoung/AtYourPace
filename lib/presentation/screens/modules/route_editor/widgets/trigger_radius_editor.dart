import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/waypoint_model.dart';
import '../providers/route_editor_provider.dart';

/// Editor for adjusting waypoint trigger radius
class TriggerRadiusEditor extends ConsumerStatefulWidget {
  final String tourId;
  final String versionId;
  final String? routeId;
  final int waypointIndex;
  final VoidCallback? onClose;

  const TriggerRadiusEditor({
    super.key,
    required this.tourId,
    required this.versionId,
    this.routeId,
    required this.waypointIndex,
    this.onClose,
  });

  @override
  ConsumerState<TriggerRadiusEditor> createState() => _TriggerRadiusEditorState();
}

class _TriggerRadiusEditorState extends ConsumerState<TriggerRadiusEditor> {
  late TextEditingController _nameController;
  WaypointType? _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadWaypointData();
  }

  void _loadWaypointData() {
    final params = (
      tourId: widget.tourId,
      versionId: widget.versionId,
      routeId: widget.routeId,
    );
    final routeState = ref.read(routeEditorProvider(params));
    if (widget.waypointIndex >= 0 &&
        widget.waypointIndex < routeState.waypoints.length) {
      final waypoint = routeState.waypoints[widget.waypointIndex];
      _nameController.text = waypoint.name;
      _selectedType = waypoint.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (
      tourId: widget.tourId,
      versionId: widget.versionId,
      routeId: widget.routeId,
    );
    final routeState = ref.watch(routeEditorProvider(params));
    final notifier = ref.read(routeEditorProvider(params).notifier);

    if (widget.waypointIndex < 0 ||
        widget.waypointIndex >= routeState.waypoints.length) {
      return const SizedBox.shrink();
    }

    final waypoint = routeState.waypoints[widget.waypointIndex];
    final isOverlapping =
        routeState.overlappingWaypointIndices.contains(widget.waypointIndex);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getTypeColor(waypoint.type),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.waypointIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Waypoint',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const Divider(height: 24),
            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Waypoint Name',
                hintText: 'Enter a name for this waypoint',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                notifier.updateWaypointName(widget.waypointIndex, value);
              },
            ),
            const SizedBox(height: 16),
            // Type selector
            Text(
              'Waypoint Type',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<WaypointType>(
              segments: [
                ButtonSegment<WaypointType>(
                  value: WaypointType.stop,
                  label: const Text('Stop'),
                  icon: const Icon(Icons.location_on),
                ),
                ButtonSegment<WaypointType>(
                  value: WaypointType.waypoint,
                  label: const Text('Pass'),
                  icon: const Icon(Icons.radio_button_unchecked),
                ),
                ButtonSegment<WaypointType>(
                  value: WaypointType.poi,
                  label: const Text('POI'),
                  icon: const Icon(Icons.place),
                ),
              ],
              selected: {_selectedType ?? waypoint.type},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedType = selection.first;
                });
                notifier.updateWaypointType(widget.waypointIndex, selection.first);
              },
            ),
            const SizedBox(height: 16),
            // Trigger radius slider
            Row(
              children: [
                Text(
                  'Trigger Radius',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (isOverlapping) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Overlaps with nearby waypoint',
                    child: Icon(
                      Icons.warning,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: waypoint.triggerRadius.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 18,
                    label: '${waypoint.triggerRadius}m',
                    onChanged: (value) {
                      notifier.updateTriggerRadius(
                          widget.waypointIndex, value.round());
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '${waypoint.triggerRadius}m',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            // Radius presets
            Wrap(
              spacing: 8,
              children: [15, 25, 35, 50, 75].map((radius) {
                final isSelected = waypoint.triggerRadius == radius;
                return ActionChip(
                  label: Text('${radius}m'),
                  avatar: isSelected
                      ? const Icon(Icons.check, size: 16)
                      : null,
                  backgroundColor: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  onPressed: () {
                    notifier.updateTriggerRadius(widget.waypointIndex, radius);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Coordinates display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${waypoint.latitude.toStringAsFixed(6)}, ${waypoint.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Overlap warning
            if (isOverlapping) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 20, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This waypoint\'s trigger radius overlaps with another. Consider reducing the radius or moving the waypoints further apart.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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
}

/// Bottom sheet version for mobile
class TriggerRadiusBottomSheet extends StatelessWidget {
  final String tourId;
  final String versionId;
  final String? routeId;
  final int waypointIndex;

  const TriggerRadiusBottomSheet({
    super.key,
    required this.tourId,
    required this.versionId,
    this.routeId,
    required this.waypointIndex,
  });

  static Future<void> show(
    BuildContext context, {
    required String tourId,
    required String versionId,
    String? routeId,
    required int waypointIndex,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TriggerRadiusBottomSheet(
        tourId: tourId,
        versionId: versionId,
        routeId: routeId,
        waypointIndex: waypointIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: TriggerRadiusEditor(
              tourId: tourId,
              versionId: versionId,
              routeId: routeId,
              waypointIndex: waypointIndex,
              onClose: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }
}
