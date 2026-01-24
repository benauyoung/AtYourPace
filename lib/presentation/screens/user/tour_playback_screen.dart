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

class TourPlaybackScreen extends ConsumerStatefulWidget {
  final String tourId;

  const TourPlaybackScreen({super.key, required this.tourId});

  @override
  ConsumerState<TourPlaybackScreen> createState() => _TourPlaybackScreenState();
}

class _TourPlaybackScreenState extends ConsumerState<TourPlaybackScreen> {
  bool _showStopsList = false;

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
    final playbackState = ref.watch(playbackStateProvider);
    final audioState = ref.watch(audioStateProvider);
    final audioPosition = ref.watch(audioPositionProvider);

    if (playbackState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading Tour...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (playbackState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                playbackState.error!,
                style: context.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
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

    final tour = playbackState.tour;
    if (tour == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tour Not Found')),
        body: const Center(child: Text('Tour not found')),
      );
    }

    // Convert stops to markers
    final markers = playbackState.stops.asMap().entries.map((entry) {
      final index = entry.key;
      final stop = entry.value;
      return StopMarker(
        id: stop.id,
        name: stop.name,
        latitude: stop.location.latitude,
        longitude: stop.location.longitude,
        order: index,
        isCompleted: playbackState.isStopCompleted(index),
        isCurrent: playbackState.currentStopIndex == index,
        triggerRadius: stop.triggerRadius.toDouble(),
      );
    }).toList();

    // Build route coordinates from stops
    final routeCoordinates = playbackState.stops
        .map((stop) => [stop.location.longitude, stop.location.latitude])
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          TourMapWidget(
            initialCenter: playbackState.userPosition != null
                ? mapbox.Position(
                    playbackState.userPosition!.longitude,
                    playbackState.userPosition!.latitude,
                  )
                : mapbox.Position(
                    tour.startLocation.longitude,
                    tour.startLocation.latitude,
                  ),
            routeCoordinates: routeCoordinates,
            stops: markers,
            showUserLocation: true,
            onStopTapped: (marker) {
              // In manual mode, trigger the stop
              if (playbackState.triggerMode == TriggerMode.manual) {
                ref.read(playbackStateProvider.notifier).triggerStop(marker.order);
              }
            },
          ),

          // Top bar with tour info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _showEndTourDialog(context),
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
                        ref
                            .read(playbackStateProvider.notifier)
                            .setTriggerMode(newMode);
                        context.showSuccessSnackBar(
                          newMode == TriggerMode.automatic
                              ? 'Auto-trigger enabled'
                              : 'Manual mode enabled',
                        );
                      },
                      tooltip: playbackState.triggerMode == TriggerMode.automatic
                          ? 'Switch to manual mode'
                          : 'Switch to auto mode',
                    ),
                    // Stops list toggle
                    IconButton(
                      icon: const Icon(Icons.list),
                      onPressed: () {
                        setState(() => _showStopsList = !_showStopsList);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Current stop panel (bottom)
          if (playbackState.currentStop != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _CurrentStopPanel(
                playbackState: playbackState,
                audioState: audioState.valueOrNull ?? AudioState.idle,
                audioPosition: audioPosition.valueOrNull ?? Duration.zero,
              ),
            ),

          // Stops list overlay
          if (_showStopsList)
            Positioned(
              top: 100,
              bottom: 200,
              left: 16,
              right: 16,
              child: _StopsListPanel(
                playbackState: playbackState,
                onStopTap: (index) {
                  ref.read(playbackStateProvider.notifier).triggerStop(index);
                  setState(() => _showStopsList = false);
                },
                onClose: () => setState(() => _showStopsList = false),
              ),
            ),

          // Next stop hint (when no stop is playing)
          if (playbackState.currentStop == null && playbackState.nextStop != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _NextStopHint(
                playbackState: playbackState,
                onTap: () {
                  ref.read(playbackStateProvider.notifier).nextStop();
                },
              ),
            ),

          // Tour completed overlay
          if (playbackState.isCompleted)
            _TourCompletedOverlay(
              tour: tour,
              onDone: () => GoRouter.of(context).pop(),
            ),
        ],
      ),
    );
  }

  void _showEndTourDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Tour?'),
        content: const Text(
          'Your progress will be saved. You can resume the tour later.',
        ),
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

class _CurrentStopPanel extends ConsumerWidget {
  final PlaybackState playbackState;
  final AudioState audioState;
  final Duration audioPosition;

  const _CurrentStopPanel({
    required this.playbackState,
    required this.audioState,
    required this.audioPosition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stop = playbackState.currentStop!;
    final audioDuration = ref.watch(audioDurationProvider).valueOrNull;

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
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Stop info
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${playbackState.currentStopIndex + 1}',
                        style: context.textTheme.titleLarge?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.name,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (stop.description.isNotEmpty)
                          Text(
                            stop.description,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress slider
              if (audioDuration != null && audioDuration > Duration.zero)
                Column(
                  children: [
                    Slider(
                      value: audioPosition.inMilliseconds.toDouble(),
                      max: audioDuration.inMilliseconds.toDouble(),
                      onChanged: (value) {
                        ref.read(playbackStateProvider.notifier).seek(
                              Duration(milliseconds: value.toInt()),
                            );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            audioPosition.toMMSS(),
                            style: context.textTheme.bodySmall,
                          ),
                          Text(
                            audioDuration.toMMSS(),
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 8),

              // Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    iconSize: 32,
                    onPressed: playbackState.currentStopIndex > 0
                        ? () => ref
                            .read(playbackStateProvider.notifier)
                            .previousStop()
                        : null,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.replay_10),
                    iconSize: 28,
                    onPressed: () =>
                        ref.read(playbackStateProvider.notifier).skipBackward(),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () =>
                        ref.read(playbackStateProvider.notifier).togglePlayPause(),
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                    ),
                    child: Icon(
                      audioState == AudioState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.forward_10),
                    iconSize: 28,
                    onPressed: () =>
                        ref.read(playbackStateProvider.notifier).skipForward(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    iconSize: 32,
                    onPressed:
                        playbackState.currentStopIndex < playbackState.stops.length - 1
                            ? () =>
                                ref.read(playbackStateProvider.notifier).nextStop()
                            : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StopsListPanel extends StatelessWidget {
  final PlaybackState playbackState;
  final void Function(int index) onStopTap;
  final VoidCallback onClose;

  const _StopsListPanel({
    required this.playbackState,
    required this.onStopTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stops',
                  style: context.textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Stops list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: playbackState.stops.length,
              itemBuilder: (context, index) {
                final stop = playbackState.stops[index];
                final isCompleted = playbackState.isStopCompleted(index);
                final isCurrent = playbackState.currentStopIndex == index;

                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? context.colorScheme.primary
                          : isCompleted
                              ? context.colorScheme.primaryContainer
                              : context.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              size: 20,
                              color: isCurrent
                                  ? context.colorScheme.onPrimary
                                  : context.colorScheme.onPrimaryContainer,
                            )
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? context.colorScheme.onPrimary
                                    : context.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  title: Text(
                    stop.name,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: playbackState.userPosition != null
                      ? Text(
                          _formatDistance(playbackState.distanceToStop(stop)),
                          style: context.textTheme.bodySmall,
                        )
                      : null,
                  trailing: isCurrent
                      ? Icon(
                          Icons.play_circle,
                          color: context.colorScheme.primary,
                        )
                      : null,
                  onTap: () => onStopTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDistance(double? distance) {
    if (distance == null) return '';
    if (distance < 1000) {
      return '${distance.toInt()} m away';
    }
    return '${(distance / 1000).toStringAsFixed(1)} km away';
  }
}

class _NextStopHint extends StatelessWidget {
  final PlaybackState playbackState;
  final VoidCallback onTap;

  const _NextStopHint({
    required this.playbackState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextStop = playbackState.nextStop!;
    final distance = playbackState.distanceToStop(nextStop);

    return Card(
      child: InkWell(
        onTap: playbackState.triggerMode == TriggerMode.manual ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  playbackState.triggerMode == TriggerMode.automatic
                      ? Icons.gps_fixed
                      : Icons.touch_app,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next: ${nextStop.name}',
                      style: context.textTheme.titleSmall,
                    ),
                    Text(
                      playbackState.triggerMode == TriggerMode.automatic
                          ? distance != null
                              ? '${distance.toInt()} m - Auto-plays when you arrive'
                              : 'Auto-plays when you arrive'
                          : 'Tap to play',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (playbackState.triggerMode == TriggerMode.manual)
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _TourCompletedOverlay extends ConsumerWidget {
  final dynamic tour;
  final VoidCallback onDone;

  const _TourCompletedOverlay({
    required this.tour,
    required this.onDone,
  });

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
                Icon(
                  Icons.celebration,
                  size: 80,
                  color: context.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tour Complete!',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
                      onPressed: () => _showReviewSheet(context, ref),
                      icon: const Icon(Icons.star),
                      label: const Text('Rate Tour'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: onDone,
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref) {
    final tourId = tour.id as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => WriteReviewSheet(
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
