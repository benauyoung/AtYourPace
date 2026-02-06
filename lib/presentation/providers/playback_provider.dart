import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/local/offline_storage_service.dart';
import '../../data/models/stop_model.dart';
import '../../data/models/tour_model.dart';
import '../../data/models/tour_version_model.dart';
import '../../services/audio_service.dart';
import '../../services/background_location_service.dart';
import '../../services/geofence_service.dart';
import '../../services/location_service.dart';
import 'tour_providers.dart';

/// Provider for the playback state
final playbackStateProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  return PlaybackNotifier(
    ref.watch(audioServiceProvider),
    ref.watch(geofenceServiceProvider),
    ref.watch(locationServiceProvider),
    ref.watch(backgroundLocationServiceProvider),
    ref,
  );
});

/// Trigger mode for stops
enum TriggerMode {
  /// Automatically trigger stops when entering geofence
  automatic,

  /// Manual mode - user taps to trigger stops
  manual,
}

/// Playback state
class PlaybackState {
  final TourModel? tour;
  final TourVersionModel? version;
  final List<StopModel> stops;
  final int currentStopIndex;
  final bool isPlaying;
  final bool isLoading;
  final TriggerMode triggerMode;
  final Set<int> completedStopIndices;
  final Position? userPosition;
  final String? error;
  final DateTime? startedAt;
  final bool isPaused;
  final bool previewMode;

  const PlaybackState({
    this.tour,
    this.version,
    this.stops = const [],
    this.currentStopIndex = -1,
    this.isPlaying = false,
    this.isLoading = false,
    this.triggerMode = TriggerMode.automatic,
    this.completedStopIndices = const {},
    this.userPosition,
    this.error,
    this.startedAt,
    this.isPaused = false,
    this.previewMode = false,
  });

  PlaybackState copyWith({
    TourModel? tour,
    TourVersionModel? version,
    List<StopModel>? stops,
    int? currentStopIndex,
    bool? isPlaying,
    bool? isLoading,
    TriggerMode? triggerMode,
    Set<int>? completedStopIndices,
    Position? userPosition,
    String? error,
    DateTime? startedAt,
    bool? isPaused,
    bool? previewMode,
  }) {
    return PlaybackState(
      tour: tour ?? this.tour,
      version: version ?? this.version,
      stops: stops ?? this.stops,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      triggerMode: triggerMode ?? this.triggerMode,
      completedStopIndices: completedStopIndices ?? this.completedStopIndices,
      userPosition: userPosition ?? this.userPosition,
      error: error,
      startedAt: startedAt ?? this.startedAt,
      isPaused: isPaused ?? this.isPaused,
      previewMode: previewMode ?? this.previewMode,
    );
  }

  /// Current stop (if any)
  StopModel? get currentStop =>
      currentStopIndex >= 0 && currentStopIndex < stops.length ? stops[currentStopIndex] : null;

  /// Next stop (if any)
  StopModel? get nextStop =>
      currentStopIndex >= -1 && currentStopIndex < stops.length - 1
          ? stops[currentStopIndex + 1]
          : null;

  /// Progress (0.0 to 1.0)
  double get progress {
    if (stops.isEmpty) return 0.0;
    return completedStopIndices.length / stops.length;
  }

  /// Whether the tour has started
  bool get hasStarted => startedAt != null;

  /// Whether all stops are completed
  bool get isCompleted => stops.isNotEmpty && completedStopIndices.length == stops.length;

  /// Whether a specific stop is completed
  bool isStopCompleted(int index) => completedStopIndices.contains(index);

  /// Whether the user is waiting to reach the first stop (tour started but no stop triggered yet)
  bool get isWaitingForFirstStop =>
      hasStarted && currentStopIndex == -1 && stops.isNotEmpty && !previewMode;

  /// Distance in meters from user to the first stop (null if no position or no stops)
  double? get distanceToFirstStop {
    if (userPosition == null || stops.isEmpty) return null;
    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      stops.first.location.latitude,
      stops.first.location.longitude,
    );
  }

  /// Get distance to a stop from user position
  double? distanceToStop(StopModel stop) {
    if (userPosition == null) return null;
    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      stop.location.latitude,
      stop.location.longitude,
    );
  }
}

/// Playback state notifier
class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final AudioService _audioService;
  final GeofenceService _geofenceService;
  final LocationService _locationService;
  final BackgroundLocationService _backgroundLocationService;
  final Ref _ref;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<GeofenceEvent>? _geofenceSubscription;
  StreamSubscription<AudioState>? _audioSubscription;
  bool _isBackgroundTrackingActive = false;

  PlaybackNotifier(
    this._audioService,
    this._geofenceService,
    this._locationService,
    this._backgroundLocationService,
    this._ref,
  ) : super(const PlaybackState()) {
    // Set up callback for background geofence events
    BackgroundLocationService.setGeofenceCallback(_onBackgroundGeofenceEvent);
  }

  /// Handle geofence events from background service
  void _onBackgroundGeofenceEvent(String geofenceId, String eventType) {
    if (eventType != 'enter') return;

    // Find the stop index for this geofence
    final stopIndex = state.stops.indexWhere((s) => s.id == geofenceId);
    if (stopIndex >= 0 && !state.isStopCompleted(stopIndex)) {
      _triggerStop(stopIndex);
    }
  }

  /// Start a tour
  Future<void> startTour(String tourId, {TriggerMode? mode, bool previewMode = false}) async {
    // Clear error state before starting
    state = state.copyWith(isLoading: true, error: null, previewMode: previewMode);
    debugPrint('Starting tour $tourId');

    try {
      // Try to load from network first
      TourModel? tour;
      TourVersionModel? version;
      List<StopModel>? stops;

      try {
        tour = await _ref.read(tourByIdProvider(tourId).future);
      } catch (e) {
        debugPrint('Failed to load tour from network: $e');
        // If it's a Firestore unavailable error, specifically log it
        if (e.toString().contains('unavailable')) {
          debugPrint('Firestore unavailable - checking offline cache');
        }
      }

      // Fallback to offline storage if network failed
      final offlineStorage = _ref.read(offlineStorageServiceProvider);
      tour ??= offlineStorage.getCachedTour(tourId);

      if (tour == null) {
        state = state.copyWith(isLoading: false, error: 'Tour not found');
        return;
      }

      // Load version data
      debugPrint(
        '[Playback] Tour ${tour.id}: status=${tour.status}, liveVersionId=${tour.liveVersionId}, draftVersionId=${tour.draftVersionId}',
      );
      final versionId = tour.liveVersionId ?? tour.draftVersionId;
      debugPrint('[Playback] Using versionId=$versionId');

      try {
        version = await _ref.read(
          tourVersionProvider((tourId: tourId, versionId: versionId)).future,
        );
      } catch (e) {
        debugPrint('Failed to load version from network: $e');
        version = offlineStorage.getCachedVersion(tourId, versionId);
      }

      // Load stops
      try {
        stops = await _ref.read(stopsProvider((tourId: tourId, versionId: versionId)).future);
      } catch (e) {
        debugPrint('Failed to load stops from network: $e');
        stops = offlineStorage.getCachedStops(tourId, versionId);
      }

      stops ??= [];

      state = state.copyWith(
        tour: tour,
        version: version,
        stops: stops,
        isLoading: false,
        currentStopIndex: -1,
        completedStopIndices: {},
        triggerMode: previewMode ? TriggerMode.manual : (mode ?? TriggerMode.automatic),
        startedAt: previewMode ? null : DateTime.now(),
      );

      // Skip audio, geofence, progress tracking in preview mode
      if (!previewMode) {
        // Record tour start for analytics
        final progressService = _ref.read(progressServiceProvider);
        if (progressService != null) {
          try {
            await progressService.recordTourStart(tourId);
          } catch (e) {
            debugPrint('Failed to record tour start: $e');
          }
        }

        // Set up geofences for all stops
        _setupGeofences(stops);

        // Start location tracking
        await _startTracking();

        // Listen for geofence events
        _listenToGeofenceEvents();

        // Listen for audio completion
        _listenToAudioState();

        // Immediate proximity check — if user is already at a stop, trigger it
        // (geofence "enter" events only fire on boundary crossing, not if already inside)
        await _initialProximityCheck();
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _setupGeofences(List<StopModel> stops) {
    _geofenceService.clearGeofences();

    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      _geofenceService.addGeofence(
        Geofence(
          id: stop.id,
          name: stop.name,
          latitude: stop.location.latitude,
          longitude: stop.location.longitude,
          radiusMeters: stop.triggerRadius.toDouble(),
          data: {'index': i},
        ),
      );
    }
  }

  Future<void> _startTracking() async {
    await _geofenceService.startMonitoring();

    _positionSubscription?.cancel();
    _positionSubscription = _locationService.positionStream.listen((position) {
      state = state.copyWith(userPosition: position);

      // Continuously check proximity so subsequent stops auto-trigger
      if (state.hasStarted) {
        _checkProximityToStops(position);
      }
    });

    // Start background location tracking
    if (state.tour != null) {
      await _startBackgroundTracking();
    }
  }

  Future<void> _startBackgroundTracking() async {
    if (_isBackgroundTrackingActive) return;

    final geofences = _geofenceService.geofences;
    final tour = state.tour;
    if (tour == null || geofences.isEmpty) return;

    final success = await _backgroundLocationService.startTracking(
      geofences: geofences,
      tourId: tour.id,
      tourName: state.version?.title ?? 'Tour',
    );

    if (success) {
      _isBackgroundTrackingActive = true;
      debugPrint('Background location tracking started');
    } else {
      debugPrint('Failed to start background location tracking');
    }
  }

  Future<void> _stopBackgroundTracking() async {
    if (!_isBackgroundTrackingActive) return;
    await _backgroundLocationService.stopTracking();
    _isBackgroundTrackingActive = false;
    debugPrint('Background location tracking stopped');
  }

  void _listenToGeofenceEvents() {
    _geofenceSubscription?.cancel();
    _geofenceSubscription = _geofenceService.eventStream.listen((event) {
      if (event.type != GeofenceEventType.enter) return;

      final index = event.geofence.data?['index'] as int?;
      if (index != null && !state.isStopCompleted(index)) {
        _triggerStop(index);
      }
    });
  }

  void _listenToAudioState() {
    _audioSubscription?.cancel();
    _audioSubscription = _audioService.stateStream.listen((audioState) {
      if (audioState == AudioState.playing) {
        state = state.copyWith(isPlaying: true);
      } else if (audioState == AudioState.completed) {
        _onAudioCompleted();
      } else if (audioState == AudioState.paused) {
        state = state.copyWith(isPlaying: false);
      }
    });
  }

  void _onAudioCompleted() async {
    final currentIndex = state.currentStopIndex;
    if (currentIndex >= 0) {
      // Mark current stop as completed
      final newCompleted = Set<int>.from(state.completedStopIndices)..add(currentIndex);

      state = state.copyWith(completedStopIndices: newCompleted, isPlaying: false);

      // Save progress
      _saveProgress();

      // Check if tour is completed
      if (state.isCompleted) {
        _onTourCompleted();
      }
    }
  }

  /// Save current progress to Firestore
  void _saveProgress() async {
    final progressService = _ref.read(progressServiceProvider);
    if (progressService == null || state.tour == null) return;

    final tourId = state.tour!.id;
    final progressPercent =
        state.stops.isEmpty
            ? 0
            : ((state.completedStopIndices.length / state.stops.length) * 100).round();

    try {
      await progressService.saveProgress(
        tourId: tourId,
        currentStopIndex: state.currentStopIndex,
        progressPercent: progressPercent,
        totalStops: state.stops.length,
      );
    } catch (e) {
      debugPrint('Failed to save progress: $e');
    }
  }

  void _onTourCompleted() async {
    // Save progress and update stats
    final progressService = _ref.read(progressServiceProvider);
    if (progressService == null || state.tour == null) return;

    final tourId = state.tour!.id;
    final durationSeconds =
        state.startedAt != null ? DateTime.now().difference(state.startedAt!).inSeconds : null;

    try {
      await progressService.markCompleted(tourId: tourId, durationSeconds: durationSeconds);
      debugPrint('Tour $tourId marked as completed');
    } catch (e) {
      debugPrint('Failed to save tour completion: $e');
    }
  }

  /// Manually trigger a stop
  Future<void> triggerStop(int index) async {
    if (index < 0 || index >= state.stops.length) return;
    await _triggerStop(index);
  }

  Future<void> _triggerStop(int index) async {
    if (state.previewMode) return; // No triggers in preview mode
    if (state.currentStopIndex == index) return; // Already on this stop

    final stop = state.stops[index];
    debugPrint('[Playback] Triggering stop $index: "${stop.name}", id=${stop.id}');
    state = state.copyWith(currentStopIndex: index);

    // Play audio if available
    final audioUrl = stop.media.audioUrl;
    debugPrint('[Playback] Stop $index audioUrl: ${audioUrl ?? 'null'}');
    if (audioUrl != null && audioUrl.isNotEmpty) {
      debugPrint('[Playback] Playing audio for stop $index: $audioUrl');
      try {
        await _audioService.playUrl(audioUrl, audioId: stop.id, title: stop.name);
        debugPrint('[Playback] Audio playback started for stop $index');
      } catch (e) {
        debugPrint('[Playback] ERROR playing audio for stop $index: $e');
      }
    } else {
      debugPrint('[Playback] No audio for stop $index - marking completed');
      // No audio - mark as completed immediately
      final newCompleted = Set<int>.from(state.completedStopIndices)..add(index);
      state = state.copyWith(completedStopIndices: newCompleted);
    }
  }

  /// Skip to next stop
  Future<void> nextStop() async {
    final nextIndex = state.currentStopIndex + 1;
    if (nextIndex < state.stops.length) {
      await triggerStop(nextIndex);
    }
  }

  /// Go to previous stop
  Future<void> previousStop() async {
    final prevIndex = state.currentStopIndex - 1;
    if (prevIndex >= 0) {
      await triggerStop(prevIndex);
    }
  }

  /// Play/resume audio
  Future<void> play() async {
    await _audioService.play();
  }

  /// Pause audio
  Future<void> pause() async {
    await _audioService.pause();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_audioService.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Seek audio to position
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  /// Skip forward 10 seconds
  Future<void> skipForward() async {
    await _audioService.skipForward(const Duration(seconds: 10));
  }

  /// Skip backward 10 seconds
  Future<void> skipBackward() async {
    await _audioService.skipBackward(const Duration(seconds: 10));
  }

  /// Pause the tour (stop tracking)
  Future<void> pauseTour() async {
    _geofenceService.stopMonitoring();
    await _audioService.pause();
    await _stopBackgroundTracking();
    state = state.copyWith(isPaused: true);
  }

  /// Resume the tour
  Future<void> resumeTour() async {
    await _geofenceService.startMonitoring();
    await _startBackgroundTracking();
    state = state.copyWith(isPaused: false);
  }

  /// End the tour
  Future<void> endTour() async {
    await _audioService.stop();
    _geofenceService.stopMonitoring();
    _geofenceService.clearGeofences();

    // Stop background tracking
    await _stopBackgroundTracking();

    _positionSubscription?.cancel();
    _geofenceSubscription?.cancel();
    _audioSubscription?.cancel();

    state = const PlaybackState();
  }

  /// One-time check right after tour start to trigger any stop the user is already inside
  Future<void> _initialProximityCheck() async {
    // Get current position
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        state = state.copyWith(userPosition: position);
        _checkProximityToStops(position);
      }
    } catch (e) {
      debugPrint('[Playback] Initial proximity check failed: $e');
    }
  }

  void _checkProximityToStops(Position position) {
    for (int i = 0; i < state.stops.length; i++) {
      if (state.isStopCompleted(i)) continue;
      if (state.currentStopIndex == i) continue; // Skip active stop

      final stop = state.stops[i];
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        stop.location.latitude,
        stop.location.longitude,
      );

      if (distance <= stop.triggerRadius.toDouble()) {
        _triggerStop(i);
        break; // Only trigger one at a time
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _geofenceSubscription?.cancel();
    _audioSubscription?.cancel();
    super.dispose();
  }
}
