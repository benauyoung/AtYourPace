import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../data/models/stop_model.dart';
import '../../../providers/playback_provider.dart';

class PlaybackBottomSheet extends StatefulWidget {
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
  State<PlaybackBottomSheet> createState() => _PlaybackBottomSheetState();
}

class _PlaybackBottomSheetState extends State<PlaybackBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2, // Collapsed state
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

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF1E2F36), // Dark color from screenshot
                      borderRadius: BorderRadius.circular(24),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF1E2F36),
                    dividerColor: Colors.transparent,
                    tabs: const [Tab(text: 'Audio Points'), Tab(text: 'Highlights')],
                  ),
                ),
              ),

              // Filters Row
              Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'All', isSelected: true),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Bookmark'),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Tour Stops'),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Waterfalls'),
                    ],
                  ),
                ),
              ),

              // Content List
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Audio Points Tab
                    _buildStopsList(scrollController),
                    // Highlights Tab (Mock content)
                    const Center(child: Text('Highlights coming soon')),
                  ],
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
                        '${widget.playbackState.version?.title ?? "Tour"} in progress...',
                        style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Switch(
                      value: widget.playbackState.triggerMode == TriggerMode.automatic,
                      onChanged: (val) => widget.onModeToggle(!val),
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

  Widget _buildStopsList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.playbackState.stops.length,
      itemBuilder: (context, index) {
        final stop = widget.playbackState.stops[index];
        return _StopListItem(stop: stop, onTap: () => widget.onStopTap(index));
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? const Color(0xFF2B8C98)
                : context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : context.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _StopListItem extends StatelessWidget {
  final StopModel stop;
  final VoidCallback onTap;

  const _StopListItem({required this.stop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    'STOP', // Category placeholder
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Distance placeholder - logic needs access to user position
                  Text(
                    '-- mi.', // Distance placeholder
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Bookmark Icon
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {}, // Todo: Implement bookmark
            ),
          ],
        ),
      ),
    );
  }
}
