import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../data/models/stop_model.dart';
import '../../../providers/playback_provider.dart';

class PlaybackBottomSheet extends StatelessWidget {
  final PlaybackState playbackState;
  final void Function(int index) onStopTap;
  final Function(bool isManual) onModeToggle;

  const PlaybackBottomSheet({
    super.key,
    required this.playbackState,
    required this.onStopTap,
    required this.onModeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = playbackState.completedStopIndices.length;
    final totalCount = playbackState.stops.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Tour Stops Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'Tour Stops',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$completedCount/$totalCount',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Stops List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: playbackState.stops.length,
                  itemBuilder: (context, index) {
                    final stop = playbackState.stops[index];
                    final isCompleted = playbackState.completedStopIndices.contains(index);
                    final isCurrent = playbackState.currentStopIndex == index;
                    return _StopListItem(
                      stop: stop,
                      index: index,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      onTap: () => onStopTap(index),
                    );
                  },
                ),
              ),

              // Bottom Status Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  border: Border(top: BorderSide(color: context.colorScheme.outlineVariant)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${playbackState.tour?.city ?? "Tour"} in progress...',
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Switch(
                      value: playbackState.triggerMode == TriggerMode.automatic,
                      onChanged: (val) => onModeToggle(!val),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StopListItem extends StatelessWidget {
  final StopModel stop;
  final int index;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback onTap;

  const _StopListItem({
    required this.stop,
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
    required this.onTap,
  });

  String get _statusLabel {
    if (isCompleted) return 'Completed';
    if (isCurrent) return 'Now Playing';
    if (stop.hasAudio) return 'Audio available';
    return 'No audio';
  }

  Color _statusColor(BuildContext context) {
    if (isCompleted) return Colors.green;
    if (isCurrent) return context.colorScheme.primary;
    return context.colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: context.colorScheme.surfaceContainerHighest,
                child:
                    stop.media.images.isNotEmpty
                        ? Image.network(stop.media.images.first.url, fit: BoxFit.cover)
                        : const Icon(Icons.landscape),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stop.name, style: context.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : isCurrent
                                ? Icons.play_circle_filled
                                : stop.hasAudio
                                    ? Icons.volume_up_outlined
                                    : Icons.volume_off_outlined,
                        size: 14,
                        color: _statusColor(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _statusLabel,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: _statusColor(context),
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Play button
            if (stop.hasAudio)
              IconButton(
                icon: Icon(
                  isCurrent ? Icons.pause_circle_filled : Icons.play_circle_outline,
                  color: isCurrent ? context.colorScheme.primary : context.colorScheme.onSurfaceVariant,
                  size: 36,
                ),
                onPressed: onTap,
                tooltip: isCurrent ? 'Playing' : 'Play audio',
              ),
          ],
        ),
      ),
    );
  }
}
