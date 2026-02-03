import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../core/extensions/context_extensions.dart';
import '../../../services/audio_service.dart';
import '../../providers/playback_provider.dart';
import '../../providers/review_providers.dart';
import '../../widgets/map/tour_map_widget.dart';
import '../../widgets/tour/tour_reviews_section.dart';
import 'widgets/playback_bottom_sheet.dart';

class TourPlaybackScreen extends ConsumerStatefulWidget {
  final String tourId;

  const TourPlaybackScreen({super.key, required this.tourId});

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
      ref.read(playbackStateProvider.notifier).startTour(widget.tourId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only watch specific fields that trigger full rebuilds
    final isLoading = ref.watch(playbackStateProvider.select((s) => s.isLoading));
    final error = ref.watch(playbackStateProvider.select((s) => s.error));
    final tour = ref.watch(playbackStateProvider.select((s) => s.tour));
    final triggerMode = ref.watch(playbackStateProvider.select((s) => s.triggerMode));
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
      triggerMode: triggerMode,
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
            onStopTapped: (marker) {
              // Map tap interaction
              ref.read(playbackStateProvider.notifier).triggerStop(marker.order);
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
                        onPressed: () => showEndTourDialog(context),
                        tooltip: 'End tour',
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tour.city ?? 'Tour',
                              style: context.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${playbackState.completedStopIndices.length}/${playbackState.stops.length} stops',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Trigger mode toggle
                      IconButton(
                        icon: Icon(
                          playbackState.triggerMode == TriggerMode.automatic
                              ? Icons.gps_fixed
                              : Icons.touch_app,
                        ),
                        onPressed: () {
                          final newMode =
                              playbackState.triggerMode == TriggerMode.automatic
                                  ? TriggerMode.manual
                                  : TriggerMode.automatic;
                          ref.read(playbackStateProvider.notifier).setTriggerMode(newMode);
                          context.showSuccessSnackBar(
                            newMode == TriggerMode.automatic
                                ? 'Auto-trigger enabled'
                                : 'Manual mode enabled',
                          );
                        },
                        tooltip:
                            playbackState.triggerMode == TriggerMode.automatic
                                ? 'Switch to manual mode'
                                : 'Switch to auto mode',
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MapOverlayButton(
                      icon: Icons.search,
                      onPressed: () => _showSearchSheet(context, stops),
                    ),
                    const SizedBox(height: 12),
                    _MapOverlayButton(
                      icon: Icons.near_me_outlined,
                      onPressed: () {
                        _mapKey.currentState?.centerOnUserLocation();
                      },
                    ),
                    const SizedBox(height: 12),
                    _MapOverlayButton(
                      icon: Icons.settings_outlined,
                      onPressed: () {}, // TODO: Settings
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Sheet
          PlaybackBottomSheet(
            playbackState: playbackState,
            onStopTap: (index) {
              ref.read(playbackStateProvider.notifier).triggerStop(index);
            },
            onModeToggle: (isAutomatic) {
              ref
                  .read(playbackStateProvider.notifier)
                  .setTriggerMode(isAutomatic ? TriggerMode.automatic : TriggerMode.manual);
            },
          ),

          // Completed Overlay
          if (playbackState.isCompleted)
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

  void _showSearchSheet(BuildContext context, List<dynamic> stops) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Search Stops', style: context.textTheme.titleLarge),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: stops.length,
                      itemBuilder: (context, index) {
                        final stop = stops[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(stop.name),
                          subtitle: Text(stop.hasAudio ? 'Audio available' : 'No audio'),
                          onTap: () {
                            Navigator.pop(context);
                            ref.read(playbackStateProvider.notifier).triggerStop(index);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
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

class _TourCompletedOverlay extends ConsumerWidget {
  final dynamic tour;
  final VoidCallback onDone;

  const _TourCompletedOverlay({required this.tour, required this.onDone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => showReviewSheet(context, ref),
                      icon: const Icon(Icons.star),
                      label: const Text('Rate Tour'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(onPressed: onDone, child: const Text('Done')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showReviewSheet(BuildContext context, WidgetRef ref) {
    final tourId = tour.id as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (context) => WriteReviewSheet(
            tourId: tourId,
            onSubmit: (rating, comment) async {
              final submitService = ref.read(submitReviewProvider);
              await submitService.submitReview(
                tourId: tourId,
                rating: rating,
                comment: comment.isNotEmpty ? comment : null,
              );
            },
          ),
    );
  }
}
