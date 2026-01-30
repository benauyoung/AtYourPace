import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../data/models/waypoint_model.dart';
import 'providers/route_editor_provider.dart';
import 'widgets/interactive_route_map.dart';
import 'widgets/route_tools_panel.dart';
import 'widgets/trigger_radius_editor.dart';
import 'widgets/waypoint_list.dart';

/// Screen for editing tour routes and waypoints
class RouteEditorScreen extends ConsumerStatefulWidget {
  final String? tourId;
  final String? versionId;
  final String? routeId;

  /// When true, hides the app bar and adapts for embedding in another screen
  final bool embedded;

  const RouteEditorScreen({
    super.key,
    this.tourId,
    this.versionId,
    this.routeId,
    this.embedded = false,
  });

  @override
  ConsumerState<RouteEditorScreen> createState() => _RouteEditorScreenState();
}

class _RouteEditorScreenState extends ConsumerState<RouteEditorScreen> {
  final _mapKey = GlobalKey<InteractiveRouteMapState>();
  bool _showWaypointList = true;

  @override
  void initState() {
    super.initState();
    // Initialize route editor if editing existing route
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.routeId != null && widget.tourId != null && widget.versionId != null) {
        final params = (
          tourId: widget.tourId!,
          versionId: widget.versionId!,
          routeId: widget.routeId,
        );
        ref.read(routeEditorProvider(params).notifier).initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use empty string defaults for new tours
    final tourId = widget.tourId ?? '';
    final versionId = widget.versionId ?? '';
    final params = (
      tourId: tourId,
      versionId: versionId,
      routeId: widget.routeId,
    );
    final routeState = ref.watch(routeEditorProvider(params));
    final notifier = ref.read(routeEditorProvider(params).notifier);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    // Build body content
    final body = Column(
      children: [
        // Tools panel
        RouteToolsPanel(
          tourId: tourId,
          versionId: versionId,
          routeId: widget.routeId,
          onSave: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Route saved'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onClear: () => _showClearConfirmation(context, notifier),
          onFitToWaypoints: () => _mapKey.currentState?.fitToWaypoints(),
        ),
        // Main content
        Expanded(
          child: isDesktop
              ? _buildDesktopLayout(routeState, notifier)
              : _buildMobileLayout(routeState, notifier),
        ),
      ],
    );

    // In embedded mode, return just the body without scaffold
    if (widget.embedded) {
      return body;
    }

    // Full screen mode with app bar
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeId != null ? 'Edit Route' : 'Create Route'),
        actions: [
          if (routeState.hasChanges)
            TextButton.icon(
              onPressed: routeState.isSaving
                  ? null
                  : () async {
                      final success = await notifier.save();
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Route saved successfully'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              icon: routeState.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save'),
            ),
          IconButton(
            icon: Icon(_showWaypointList ? Icons.map : Icons.list),
            tooltip: _showWaypointList ? 'Show map only' : 'Show waypoint list',
            onPressed: () {
              setState(() {
                _showWaypointList = !_showWaypointList;
              });
            },
          ),
        ],
      ),
      body: body,
      // FAB for adding waypoints (mobile only)
      floatingActionButton: !isDesktop && routeState.selectedWaypointIndex != null
          ? FloatingActionButton(
              onPressed: () => _showWaypointEditor(routeState.selectedWaypointIndex!),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildDesktopLayout(RouteEditorState routeState, RouteEditorNotifier notifier) {
    final tourId = widget.tourId ?? '';
    final versionId = widget.versionId ?? '';

    return Row(
      children: [
        // Map
        Expanded(
          flex: 3,
          child: _buildMap(routeState, notifier),
        ),
        // Side panel
        if (_showWaypointList)
          SizedBox(
            width: 350,
            child: Column(
              children: [
                // Waypoint list
                Expanded(
                  child: WaypointList(
                    tourId: tourId,
                    versionId: versionId,
                    routeId: widget.routeId,
                    onWaypointTapped: (index) {
                      notifier.selectWaypoint(index);
                      _mapKey.currentState?.centerOnWaypoint(index);
                    },
                    onWaypointDeleted: (index) =>
                        _showDeleteConfirmation(context, notifier, index),
                    onWaypointEdit: (index) => _showWaypointEditor(index),
                  ),
                ),
                // Waypoint editor (if selected)
                if (routeState.selectedWaypointIndex != null)
                  TriggerRadiusEditor(
                    tourId: tourId,
                    versionId: versionId,
                    routeId: widget.routeId,
                    waypointIndex: routeState.selectedWaypointIndex!,
                    onClose: () => notifier.selectWaypoint(null),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMobileLayout(RouteEditorState routeState, RouteEditorNotifier notifier) {
    final tourId = widget.tourId ?? '';
    final versionId = widget.versionId ?? '';

    if (!_showWaypointList) {
      return _buildMap(routeState, notifier);
    }

    return Column(
      children: [
        // Map (smaller on mobile when list is visible)
        Expanded(
          flex: 1,
          child: _buildMap(routeState, notifier),
        ),
        // Waypoint list
        Expanded(
          flex: 1,
          child: WaypointList(
            tourId: tourId,
            versionId: versionId,
            routeId: widget.routeId,
            onWaypointTapped: (index) {
              notifier.selectWaypoint(index);
              _mapKey.currentState?.centerOnWaypoint(index);
            },
            onWaypointDeleted: (index) =>
                _showDeleteConfirmation(context, notifier, index),
            onWaypointEdit: (index) => _showWaypointEditor(index),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(RouteEditorState routeState, RouteEditorNotifier notifier) {
    final tourId = widget.tourId ?? '';
    final versionId = widget.versionId ?? '';

    return Stack(
      children: [
        InteractiveRouteMap(
          key: _mapKey,
          tourId: tourId,
          versionId: versionId,
          routeId: widget.routeId,
          onMapTapped: (location) => _showAddWaypointDialog(location, notifier),
          onMapLongPressed: (location) => _quickAddWaypoint(location, notifier),
          onWaypointTapped: (index) {
            notifier.selectWaypoint(index);
          },
          onWaypointDragged: (index, newLocation) {
            notifier.moveWaypoint(index, newLocation);
          },
        ),
        // Error banner
        if (routeState.error != null)
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: _ErrorBanner(
              message: routeState.error!,
              onDismiss: notifier.clearError,
            ),
          ),
        // Loading overlay
        if (routeState.isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        // Instructions overlay (when no waypoints)
        if (routeState.waypoints.isEmpty && !routeState.isLoading)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Tap on the map to add waypoints',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Long press to quick-add a stop',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAddWaypointDialog(LatLng location, RouteEditorNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _AddWaypointDialog(
        location: location,
        onAdd: (name, type) {
          notifier.addWaypoint(location, name: name, type: type);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _quickAddWaypoint(LatLng location, RouteEditorNotifier notifier) {
    notifier.addWaypoint(location);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Waypoint added'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => notifier.undo(),
        ),
      ),
    );
  }

  void _showWaypointEditor(int index) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final tourId = widget.tourId ?? '';
    final versionId = widget.versionId ?? '';

    if (isDesktop) {
      // On desktop, the editor is shown in the side panel
      final params = (
        tourId: tourId,
        versionId: versionId,
        routeId: widget.routeId,
      );
      ref.read(routeEditorProvider(params).notifier).selectWaypoint(index);
    } else {
      // On mobile, show as bottom sheet
      TriggerRadiusBottomSheet.show(
        context,
        tourId: tourId,
        versionId: versionId,
        routeId: widget.routeId,
        waypointIndex: index,
      );
    }
  }

  void _showDeleteConfirmation(
      BuildContext context, RouteEditorNotifier notifier, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Waypoint'),
        content: const Text('Are you sure you want to delete this waypoint?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.removeWaypoint(index);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, RouteEditorNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Waypoints'),
        content: const Text(
            'Are you sure you want to remove all waypoints? This action can be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.clearRoute();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for adding a new waypoint with name and type
class _AddWaypointDialog extends StatefulWidget {
  final LatLng location;
  final void Function(String name, WaypointType type) onAdd;

  const _AddWaypointDialog({
    required this.location,
    required this.onAdd,
  });

  @override
  State<_AddWaypointDialog> createState() => _AddWaypointDialogState();
}

class _AddWaypointDialogState extends State<_AddWaypointDialog> {
  final _nameController = TextEditingController();
  WaypointType _selectedType = WaypointType.stop;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Waypoint'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name (optional)',
              hintText: 'Enter waypoint name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Text(
            'Waypoint Type',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<WaypointType>(
            segments: const [
              ButtonSegment<WaypointType>(
                value: WaypointType.stop,
                label: Text('Stop'),
                icon: Icon(Icons.location_on),
              ),
              ButtonSegment<WaypointType>(
                value: WaypointType.waypoint,
                label: Text('Pass'),
                icon: Icon(Icons.radio_button_unchecked),
              ),
              ButtonSegment<WaypointType>(
                value: WaypointType.poi,
                label: Text('POI'),
                icon: Icon(Icons.place),
              ),
            ],
            selected: {_selectedType},
            onSelectionChanged: (selection) {
              setState(() {
                _selectedType = selection.first;
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location, size: 14),
                const SizedBox(width: 8),
                Text(
                  '${widget.location.latitude.toStringAsFixed(6)}, ${widget.location.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onAdd(_nameController.text, _selectedType);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

/// Error banner widget
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontSize: 13,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
