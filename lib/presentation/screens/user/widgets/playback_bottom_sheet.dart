import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../data/models/stop_model.dart';
import '../../../providers/playback_provider.dart';

class PlaybackBottomSheet extends StatefulWidget {
  final PlaybackState playbackState;
  final void Function(int index) onStopTap;
  final VoidCallback? onTogglePlayPause;

  const PlaybackBottomSheet({
    super.key,
    required this.playbackState,
    required this.onStopTap,
    this.onTogglePlayPause,
  });

  @override
  State<PlaybackBottomSheet> createState() => _PlaybackBottomSheetState();
}

class _PlaybackBottomSheetState extends State<PlaybackBottomSheet> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.playbackState.completedStopIndices.length;
    final totalCount = widget.playbackState.stops.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight.withOpacity(0.10),
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
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  itemCount: widget.playbackState.stops.length,
                  itemBuilder: (context, index) {
                    final stop = widget.playbackState.stops[index];
                    final isCompleted = widget.playbackState.completedStopIndices.contains(index);
                    final isCurrent = widget.playbackState.currentStopIndex == index;
                    final isExpanded = _expandedIndex == index;
                    final isPlaying = isCurrent && widget.playbackState.isPlaying;
                    return _StopListItem(
                      stop: stop,
                      index: index,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      isExpanded: isExpanded,
                      isPlaying: isPlaying,
                      onTap: () {
                        setState(() {
                          _expandedIndex = isExpanded ? null : index;
                        });
                      },
                      onPlay: () {
                        if (isCurrent) {
                          // Toggle pause/play for current stop
                          widget.onTogglePlayPause?.call();
                        } else {
                          // Trigger this stop's audio
                          widget.onStopTap(index);
                        }
                      },
                    );
                  },
                ),
              ),

              // Bottom Status Bar
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    border: Border(top: BorderSide(color: context.colorScheme.outlineVariant)),
                  ),
                  child: Text(
                    '${widget.playbackState.tour?.city ?? "Tour"} in progress...',
                    style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
  final bool isExpanded;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _StopListItem({
    required this.stop,
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
    required this.isExpanded,
    required this.isPlaying,
    required this.onTap,
    required this.onPlay,
  });

  String get _statusLabel {
    if (isCompleted) return 'Completed';
    if (isCurrent && isPlaying) return 'Now Playing';
    if (isCurrent) return 'Paused';
    if (stop.hasAudio) return 'Audio available';
    return 'No audio';
  }

  Color _statusColor(BuildContext context) {
    if (isCompleted) return AppColors.primary;
    if (isCurrent) return context.colorScheme.primary;
    return context.colorScheme.onSurfaceVariant;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color:
            isExpanded
                ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Main row (always visible)
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: context.colorScheme.surfaceContainerHighest,
                      child:
                          stop.media.images.isNotEmpty
                              ? Image.network(stop.media.images.first.url, fit: BoxFit.cover)
                              : const Icon(Icons.landscape),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.name,
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : isCurrent && isPlaying
                                  ? Icons.play_circle_filled
                                  : isCurrent
                                  ? Icons.pause_circle_filled
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
                  // Play/pause button
                  if (stop.hasAudio)
                    IconButton(
                      icon: Icon(
                        isCurrent && isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color:
                            isCurrent
                                ? context.colorScheme.primary
                                : context.colorScheme.onSurfaceVariant,
                        size: 36,
                      ),
                      onPressed: onPlay,
                      tooltip: isCurrent && isPlaying ? 'Pause' : 'Play',
                    ),
                  // Expand indicator
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: context.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _ExpandedContent(
              stop: stop,
              isCurrent: isCurrent,
              isPlaying: isPlaying,
              isCompleted: isCompleted,
              onPlay: onPlay,
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _ExpandedContent extends StatelessWidget {
  final StopModel stop;
  final bool isCurrent;
  final bool isPlaying;
  final bool isCompleted;
  final VoidCallback onPlay;

  const _ExpandedContent({
    required this.stop,
    required this.isCurrent,
    required this.isPlaying,
    required this.isCompleted,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Images carousel
          if (stop.media.images.isNotEmpty) ...[
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stop.media.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final image = stop.media.images[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image.url,
                      width: 220,
                      height: 160,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 220,
                          height: 160,
                          color: context.colorScheme.surfaceContainerHighest,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 220,
                          height: 160,
                          color: context.colorScheme.surfaceContainerHighest,
                          child: const Icon(Icons.broken_image_outlined),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Description
          if (stop.description.isNotEmpty) ...[
            Text(
              stop.description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Audio play/replay button
          if (stop.hasAudio)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onPlay,
                icon: Icon(
                  isCurrent && isPlaying
                      ? Icons.pause
                      : isCompleted
                      ? Icons.replay
                      : Icons.play_arrow,
                ),
                label: Text(
                  isCurrent && isPlaying
                      ? 'Pause Audio'
                      : isCompleted
                      ? 'Replay Audio'
                      : isCurrent
                      ? 'Resume Audio'
                      : 'Play Audio',
                ),
              ),
            ),

          if (!stop.hasAudio)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No audio available for this stop',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
