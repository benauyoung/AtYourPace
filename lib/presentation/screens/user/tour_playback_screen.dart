import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../core/extensions/context_extensions.dart';
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
      ref.read(playbackStateProvider.notifier).startTour(
        widget.tourId,
        previewMode: widget.previewMode,
      );
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
            userPosition: userPosition != null
                ? mapbox.Position(userPosition.longitude, userPosition.latitude)
                : null,
            onStopTapped: widget.previewMode
                ? null
                : (marker) {
                    ref.read(playbackStateProvider.notifier).triggerStop(marker.order);
                    if (marker.order < stops.length && !stops[marker.order].hasAudio) {
                      context.showInfoSnackBar('No audio available for this stop');
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
                    color: context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.previewMode
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
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(icon: Icon(icon, color: Colors.black87), onPressed: onPressed),
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
      color: Colors.black54,
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
