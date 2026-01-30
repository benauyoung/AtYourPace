import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/stop_model.dart';
import '../providers/tour_editor_provider.dart';

/// Stops tab for tour editing - manage stop content
class StopsModule extends ConsumerStatefulWidget {
  final String? tourId;
  final String? versionId;

  const StopsModule({
    super.key,
    this.tourId,
    this.versionId,
  });

  @override
  ConsumerState<StopsModule> createState() => _StopsModuleState();
}

class _StopsModuleState extends ConsumerState<StopsModule> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final params = (tourId: widget.tourId, versionId: widget.versionId);
    final state = ref.watch(tourEditorProvider(params));
    final notifier = ref.read(tourEditorProvider(params).notifier);

    if (state.stops.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Header with stop count
        _buildHeader(context, state),
        const Divider(height: 1),
        // Stops list
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.stops.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              notifier.reorderStops(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final stop = state.stops[index];
              return _buildStopCard(
                context,
                stop,
                index,
                notifier,
                isExpanded: _expandedIndex == index,
              );
            },
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
              Icons.format_list_bulleted,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Stops Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Add waypoints in the Route tab to create stops for your tour.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // Navigate to route tab
              },
              icon: const Icon(Icons.route),
              label: const Text('Go to Route Tab'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TourEditorState state) {
    final stopsWithAudio =
        state.stops.where((s) => s.hasAudio).length;
    final stopsWithoutAudio = state.stops.length - stopsWithAudio;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          Text(
            '${state.stopsCount} Stops',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 16),
          if (stopsWithAudio > 0) ...[
            Icon(
              Icons.check_circle,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              '$stopsWithAudio with audio',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
          if (stopsWithoutAudio > 0) ...[
            const SizedBox(width: 16),
            Icon(
              Icons.warning_amber,
              size: 16,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 4),
            Text(
              '$stopsWithoutAudio missing audio',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              setState(() => _expandedIndex = null);
            },
            icon: const Icon(Icons.unfold_less),
            label: const Text('Collapse All'),
          ),
        ],
      ),
    );
  }

  Widget _buildStopCard(
    BuildContext context,
    StopModel stop,
    int index,
    TourEditorNotifier notifier, {
    required bool isExpanded,
  }) {
    return Card(
      key: ValueKey(stop.id.isEmpty ? 'stop_$index' : stop.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // Stop header (always visible)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              stop.name.isEmpty ? 'Stop ${index + 1}' : stop.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                if (stop.hasAudio) ...[
                  Icon(
                    Icons.audiotrack,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(stop.media.audioDuration),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.mic_off,
                    size: 14,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'No audio',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
                IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    });
                  },
                ),
              ],
            ),
          ),
          // Expanded content
          if (isExpanded) ...[
            const Divider(height: 1),
            _buildExpandedContent(context, stop, index, notifier),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    StopModel stop,
    int index,
    TourEditorNotifier notifier,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Stop Name',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: stop.name),
            onChanged: (value) {
              final updatedStop = stop.copyWith(name: value);
              _updateStop(notifier, index, updatedStop);
            },
          ),
          const SizedBox(height: 16),
          // Description field
          TextField(
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            controller: TextEditingController(text: stop.description),
            maxLines: 3,
            onChanged: (value) {
              final updatedStop = stop.copyWith(description: value);
              _updateStop(notifier, index, updatedStop);
            },
          ),
          const SizedBox(height: 16),
          // Audio section
          _buildAudioSection(context, stop, index, notifier),
          const SizedBox(height: 16),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  _showDeleteConfirmation(context, index, notifier);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Stop'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSection(
    BuildContext context,
    StopModel stop,
    int index,
    TourEditorNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio Narration',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          if (stop.hasAudio) ...[
            // Audio preview
            Row(
              children: [
                IconButton.filled(
                  onPressed: () {
                    // Play audio preview
                  },
                  icon: const Icon(Icons.play_arrow),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio recorded',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        _formatDuration(stop.media.audioDuration),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Re-record or regenerate
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Replace'),
                ),
              ],
            ),
          ] else ...[
            // No audio - show options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Record audio
                    },
                    icon: const Icon(Icons.mic),
                    label: const Text('Record Audio'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      // Generate with AI
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate with AI'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _updateStop(TourEditorNotifier notifier, int index, StopModel stop) {
    final params = (tourId: widget.tourId, versionId: widget.versionId);
    final state = ref.read(tourEditorProvider(params));
    final updatedStops = [...state.stops];
    updatedStops[index] = stop;
    notifier.updateStops(updatedStops);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int index,
    TourEditorNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Stop?'),
        content: const Text(
          'This will remove the stop and its audio. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.removeStop(index);
              Navigator.pop(context);
              setState(() => _expandedIndex = null);
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

  String _formatDuration(int? seconds) {
    if (seconds == null) return '0:00';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
