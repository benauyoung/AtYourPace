import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/route_model.dart';
import '../providers/route_editor_provider.dart';

/// Toolbar panel with route editing tools
class RouteToolsPanel extends ConsumerWidget {
  final String tourId;
  final String versionId;
  final String? routeId;
  final VoidCallback? onSave;
  final VoidCallback? onClear;
  final VoidCallback? onFitToWaypoints;

  const RouteToolsPanel({
    super.key,
    required this.tourId,
    required this.versionId,
    this.routeId,
    this.onSave,
    this.onClear,
    this.onFitToWaypoints,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Snap mode dropdown
          _SnapModeSelector(
            currentMode: routeState.snapMode,
            onChanged: notifier.setSnapMode,
          ),
          const SizedBox(width: 8),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),
          const SizedBox(width: 8),
          // Undo/Redo buttons
          _ToolButton(
            icon: Icons.undo,
            tooltip: 'Undo',
            onPressed: routeState.canUndo ? notifier.undo : null,
          ),
          _ToolButton(
            icon: Icons.redo,
            tooltip: 'Redo',
            onPressed: routeState.canRedo ? notifier.redo : null,
          ),
          const SizedBox(width: 8),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),
          const SizedBox(width: 8),
          // View controls
          _ToolButton(
            icon: Icons.fit_screen,
            tooltip: 'Fit to waypoints',
            onPressed: routeState.waypoints.isNotEmpty ? onFitToWaypoints : null,
          ),
          const Spacer(),
          // Stats display
          if (routeState.waypoints.isNotEmpty) ...[
            _StatBadge(
              icon: Icons.place,
              label: '${routeState.waypoints.length}',
              tooltip: 'Waypoints',
            ),
            const SizedBox(width: 8),
            _StatBadge(
              icon: Icons.straighten,
              label: routeState.distanceFormatted,
              tooltip: 'Total distance',
            ),
            const SizedBox(width: 8),
            _StatBadge(
              icon: Icons.schedule,
              label: routeState.durationFormatted,
              tooltip: 'Estimated duration',
            ),
            const SizedBox(width: 16),
          ],
          // Clear and Save buttons
          _ToolButton(
            icon: Icons.delete_sweep,
            tooltip: 'Clear all waypoints',
            onPressed: routeState.waypoints.isNotEmpty ? onClear : null,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: routeState.hasChanges && !routeState.isSaving
                ? () async {
                    await notifier.save();
                    onSave?.call();
                  }
                : null,
            icon: routeState.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save, size: 18),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SnapModeSelector extends StatelessWidget {
  final RouteSnapMode currentMode;
  final void Function(RouteSnapMode mode) onChanged;

  const _SnapModeSelector({
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<RouteSnapMode>(
      tooltip: 'Route snapping mode',
      onSelected: onChanged,
      itemBuilder: (context) => RouteSnapMode.values.map((mode) {
        return PopupMenuItem<RouteSnapMode>(
          value: mode,
          child: Row(
            children: [
              Icon(
                _getModeIcon(mode),
                size: 20,
                color: mode == currentMode
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.displayName,
                    style: TextStyle(
                      fontWeight:
                          mode == currentMode ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Text(
                    mode.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
              if (mode == currentMode) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getModeIcon(currentMode), size: 18),
            const SizedBox(width: 8),
            Text(currentMode.displayName),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  IconData _getModeIcon(RouteSnapMode mode) {
    switch (mode) {
      case RouteSnapMode.none:
        return Icons.timeline;
      case RouteSnapMode.roads:
        return Icons.directions_car;
      case RouteSnapMode.walking:
        return Icons.directions_walk;
      case RouteSnapMode.manual:
        return Icons.edit;
    }
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  const _ToolButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      color: color,
      style: IconButton.styleFrom(
        foregroundColor: color ?? Theme.of(context).colorScheme.onSurface,
        disabledForegroundColor: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
