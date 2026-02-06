import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../config/theme/colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/stop_model.dart';
import '../../../services/audio_service.dart';
import '../../providers/playback_provider.dart';
import '../../widgets/map/tour_map_widget.dart';
import 'widgets/playback_bottom_sheet.dart';

class TourPlaybackScreen extends ConsumerStatefulWidget {
  final String tourId;
  final bool previewMode;

  const TourPlaybackScreen({super.key, required this.tourId, this.previewMode = false});

  @override
  ConsumerState<TourPlaybackScreen> createState() => _TourPlaybackScreenState();
}

class _TourPlaybackScreenState extends ConsumerState<TourPlaybackScreen> {
  // Replaced with PlaybackBottomSheet internal state
  // bool _showStopsList = false;
  final GlobalKey<TourMapWidgetState> _mapKey = GlobalKey<TourMapWidgetState>();

  @override
  void initState() {
    super.initState();
    // Start the tour
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(playbackStateProvider.notifier)
          .startTour(widget.tourId, previewMode: widget.previewMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only watch specific fields that trigger full rebuilds
    final isLoading = ref.watch(playbackStateProvider.select((s) => s.isLoading));
    final error = ref.watch(playbackStateProvider.select((s) => s.error));
    final tour = ref.watch(playbackStateProvider.select((s) => s.tour));
    final completedStopIndices = ref.watch(
      playbackStateProvider.select((s) => s.completedStopIndices),
    );
    final currentStopIndex = ref.watch(playbackStateProvider.select((s) => s.currentStopIndex));

    // For position updates, we pass the data down to child widgets rather than rebuilding the whole screen
    // except for the map which handles position internal optimizations now
    final userPosition = ref.watch(playbackStateProvider.select((s) => s.userPosition));

    // Audio state
    final audioState = ref.watch(audioStateProvider).valueOrNull ?? AudioState.idle;
    // final audioPosition = ref.watch(audioPositionProvider); // Used in bottom sheet if needed

    // Get stops list once
    final stops = ref.watch(playbackStateProvider.select((s) => s.stops));
    final version = ref.watch(playbackStateProvider.select((s) => s.version));

    // Watch additional fields for first-stop prompt
    final startedAt = ref.watch(playbackStateProvider.select((s) => s.startedAt));
    final previewMode = ref.watch(playbackStateProvider.select((s) => s.previewMode));

    // Reconstruct PlaybackState for compatibility with existing widgets logic
    final playbackState = PlaybackState(
      tour: tour,
      version: version,
      stops: stops,
      currentStopIndex: currentStopIndex,
      completedStopIndices: completedStopIndices,
      userPosition: userPosition,
      isLoading: isLoading,
      error: error,
      isPlaying: audioState == AudioState.playing,
      startedAt: startedAt,
      previewMode: previewMode,
    );

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Tour...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: context.colorScheme.error),
              const SizedBox(height: 16),
              Text(error, style: context.textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => GoRouter.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (tour == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tour Not Found')),
        body: const Center(child: Text('Tour not found')),
      );
    }

    // Convert stops to markers
    final markers =
        stops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          return StopMarker(
            id: stop.id,
            name: stop.name,
            latitude: stop.location.latitude,
            longitude: stop.location.longitude,
            order: index,
            isCompleted: completedStopIndices.contains(index),
            isCurrent: currentStopIndex == index,
            triggerRadius: stop.triggerRadius.toDouble(),
          );
        }).toList();

    // Build route coordinates from stops
    final routeCoordinates =
        stops.map((stop) => [stop.location.longitude, stop.location.latitude]).toList();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          TourMapWidget(
            key: _mapKey,
            initialCenter:
                playbackState.userPosition != null
                    ? mapbox.Position(
                      playbackState.userPosition!.longitude,
                      playbackState.userPosition!.latitude,
                    )
                    : mapbox.Position(tour.startLocation.longitude, tour.startLocation.latitude),
            routeCoordinates: routeCoordinates,
            stops: markers,
            showUserLocation: true,
            userPosition:
                userPosition != null
                    ? mapbox.Position(userPosition.longitude, userPosition.latitude)
                    : null,
            onStopTapped: (marker) {
              if (widget.previewMode) {
                if (marker.order < stops.length) {
                  _showStopInfoSheet(context, stops[marker.order]);
                }
              } else {
                ref.read(playbackStateProvider.notifier).triggerStop(marker.order);
                if (marker.order < stops.length && !stops[marker.order].hasAudio) {
                  context.showInfoSnackBar('No audio available for this stop');
                }
              }
            },
          ),

          // Top bar with tour info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed:
                            widget.previewMode
                                ? () => GoRouter.of(context).pop()
                                : () => showEndTourDialog(context),
                        tooltip: widget.previewMode ? 'Close preview' : 'End tour',
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tour.displayName,
                              style: context.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.previewMode
                                  ? 'Preview Mode'
                                  : '${playbackState.completedStopIndices.length}/${playbackState.stops.length} stops',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 80, right: 16), // Below top bar
              child: Align(
                alignment: Alignment.topRight,
                child: _MapOverlayButton(
                  icon: Icons.near_me_outlined,
                  onPressed: () {
                    _mapKey.currentState?.centerOnUserLocation();
                  },
                ),
              ),
            ),
          ),
          // Navigate to first stop prompt
          if (!widget.previewMode && playbackState.isWaitingForFirstStop)
            Positioned(
              bottom: 160,
              left: 16,
              right: 16,
              child: _NavigateToFirstStopCard(
                playbackState: playbackState,
                onCenterOnStop: () {
                  if (stops.isNotEmpty) {
                    _mapKey.currentState?.flyTo(
                      mapbox.Position(
                        stops.first.location.longitude,
                        stops.first.location.latitude,
                      ),
                    );
                  }
                },
              ),
            ),

          // Bottom Sheet (only in full playback mode)
          if (!widget.previewMode)
            PlaybackBottomSheet(
              playbackState: playbackState,
              onStopTap: (index) {
                ref.read(playbackStateProvider.notifier).triggerStop(index);
                if (index < stops.length && !stops[index].hasAudio) {
                  context.showInfoSnackBar('No audio available for this stop');
                }
              },
              onTogglePlayPause: () {
                ref.read(playbackStateProvider.notifier).togglePlayPause();
              },
            ),

          // Completed Overlay (only in full playback mode)
          if (!widget.previewMode && playbackState.isCompleted)
            _TourCompletedOverlay(tour: tour, onDone: () => GoRouter.of(context).pop()),
        ],
      ),
    );
  }

  void _showStopInfoSheet(BuildContext context, StopModel stop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.borderLinen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Stop name
                      Text(
                        stop.name,
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      // Images carousel
                      if (stop.media.images.isNotEmpty) ...[
                        SizedBox(
                          height: 180,
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
                                  width: 240,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 240,
                                      height: 180,
                                      color: context.colorScheme.surfaceContainerHighest,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 240,
                                      height: 180,
                                      color: context.colorScheme.surfaceContainerHighest,
                                      child: const Icon(Icons.broken_image_outlined),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Description
                      if (stop.description.isNotEmpty) ...[
                        Text(
                          stop.description,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Audio indicator
                      if (stop.hasAudio)
                        Row(
                          children: [
                            Icon(
                              Icons.volume_up_outlined,
                              size: 18,
                              color: context.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Audio available — start the tour to listen',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showEndTourDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('End Tour?'),
            content: const Text('Your progress will be saved. You can resume the tour later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Continue Tour'),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(playbackStateProvider.notifier).endTour();
                  Navigator.pop(dialogContext);
                  GoRouter.of(context).pop();
                },
                child: const Text('End Tour'),
              ),
            ],
          ),
    );
  }
}

class _MapOverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapOverlayButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(icon: Icon(icon, color: AppColors.textPrimary), onPressed: onPressed),
    );
  }
}

class _NavigateToFirstStopCard extends StatelessWidget {
  final PlaybackState playbackState;
  final VoidCallback onCenterOnStop;

  const _NavigateToFirstStopCard({required this.playbackState, required this.onCenterOnStop});

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  @override
  Widget build(BuildContext context) {
    final distance = playbackState.distanceToFirstStop;
    final stopName = playbackState.stops.isNotEmpty ? playbackState.stops.first.name : 'Stop 1';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_walk, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Head to the first stop',
                        style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        distance != null
                            ? '$stopName · ${_formatDistance(distance)} away'
                            : stopName,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: onCenterOnStop,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Show'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Audio will play automatically when you arrive',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourCompletedOverlay extends StatelessWidget {
  final dynamic tour;
  final VoidCallback onDone;

  const _TourCompletedOverlay({required this.tour, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textPrimary.withOpacity(0.6),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.celebration, size: 80, color: context.colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Tour Complete!',
                  style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve completed all stops',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: onDone, child: const Text('Done')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
