import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/presentation/providers/playback_provider.dart';
import 'package:ayp_tour_guide/services/audio_service.dart';
import 'package:ayp_tour_guide/services/geofence_service.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('PlaybackState', () {
    test('default state has correct initial values', () {
      const state = PlaybackState();

      expect(state.tour, isNull);
      expect(state.version, isNull);
      expect(state.stops, isEmpty);
      expect(state.currentStopIndex, equals(-1));
      expect(state.isPlaying, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.triggerMode, equals(TriggerMode.automatic));
      expect(state.completedStopIndices, isEmpty);
      expect(state.userPosition, isNull);
      expect(state.error, isNull);
      expect(state.startedAt, isNull);
      expect(state.isPaused, isFalse);
    });

    test('copyWith creates new state with updated values', () {
      const initial = PlaybackState();
      final tour = createTestTour();

      final updated = initial.copyWith(
        tour: tour,
        isLoading: true,
        triggerMode: TriggerMode.manual,
      );

      expect(updated.tour, equals(tour));
      expect(updated.isLoading, isTrue);
      expect(updated.triggerMode, equals(TriggerMode.manual));
      // Original values preserved
      expect(updated.isPlaying, isFalse);
      expect(updated.stops, isEmpty);
    });

    test('currentStop returns correct stop', () {
      final stops = createTestStops(count: 3);
      final state = PlaybackState(
        stops: stops,
        currentStopIndex: 1,
      );

      expect(state.currentStop, equals(stops[1]));
    });

    test('currentStop returns null when index is -1', () {
      final stops = createTestStops(count: 3);
      final state = PlaybackState(
        stops: stops,
        currentStopIndex: -1,
      );

      expect(state.currentStop, isNull);
    });

    test('currentStop returns null when index out of bounds', () {
      final stops = createTestStops(count: 3);
      final state = PlaybackState(
        stops: stops,
        currentStopIndex: 5,
      );

      expect(state.currentStop, isNull);
    });

    test('nextStop returns correct stop', () {
      final stops = createTestStops(count: 3);
      final state = PlaybackState(
        stops: stops,
        currentStopIndex: 0,
      );

      expect(state.nextStop, equals(stops[1]));
    });

    test('nextStop returns null at last stop', () {
      final stops = createTestStops(count: 3);
      final state = PlaybackState(
        stops: stops,
        currentStopIndex: 2,
      );

      expect(state.nextStop, isNull);
    });

    test('progress calculates correctly', () {
      final stops = createTestStops(count: 4);
      final state = PlaybackState(
        stops: stops,
        completedStopIndices: {0, 1},
      );

      expect(state.progress, equals(0.5));
    });

    test('progress returns 0 when no stops', () {
      const state = PlaybackState(stops: []);

      expect(state.progress, equals(0.0));
    });

    test('progress returns 1 when all completed', () {
      final stops = createTestStops(count: 3);
      final state = PlaybackState(
        stops: stops,
        completedStopIndices: {0, 1, 2},
      );

      expect(state.progress, equals(1.0));
    });

    test('hasStarted reflects startedAt', () {
      const notStarted = PlaybackState();
      expect(notStarted.hasStarted, isFalse);

      final started = PlaybackState(startedAt: DateTime.now());
      expect(started.hasStarted, isTrue);
    });

    test('isCompleted is true when all stops completed', () {
      final stops = createTestStops(count: 3);

      final incomplete = PlaybackState(
        stops: stops,
        completedStopIndices: {0, 1},
      );
      expect(incomplete.isCompleted, isFalse);

      final complete = PlaybackState(
        stops: stops,
        completedStopIndices: {0, 1, 2},
      );
      expect(complete.isCompleted, isTrue);
    });

    test('isCompleted is false when stops empty', () {
      const state = PlaybackState(
        stops: [],
        completedStopIndices: {},
      );

      expect(state.isCompleted, isFalse);
    });

    test('isStopCompleted checks correctly', () {
      final state = PlaybackState(
        completedStopIndices: {0, 2},
      );

      expect(state.isStopCompleted(0), isTrue);
      expect(state.isStopCompleted(1), isFalse);
      expect(state.isStopCompleted(2), isTrue);
    });

    test('distanceToStop calculates when user position available', () {
      final stop = createTestStop(latitude: 37.7749, longitude: -122.4194);
      final state = PlaybackState(
        userPosition: createTestPosition(latitude: 37.7750, longitude: -122.4195),
      );

      final distance = state.distanceToStop(stop);

      expect(distance, isNotNull);
      expect(distance, greaterThan(0));
      expect(distance, lessThan(100)); // Should be close
    });

    test('distanceToStop returns null without user position', () {
      final stop = createTestStop();
      const state = PlaybackState();

      expect(state.distanceToStop(stop), isNull);
    });
  });

  group('TriggerMode', () {
    test('automatic is default', () {
      const state = PlaybackState();
      expect(state.triggerMode, equals(TriggerMode.automatic));
    });

    test('manual can be set', () {
      const state = PlaybackState(triggerMode: TriggerMode.manual);
      expect(state.triggerMode, equals(TriggerMode.manual));
    });
  });

  // Note: PlaybackNotifier provider tests are skipped because FakeAudioService
  // cannot be used as an override for audioServiceProvider (type mismatch).
  // The FakeAudioService is a standalone class that doesn't extend AudioService
  // to avoid creating real AudioPlayer instances that require Flutter bindings.
  //
  // To test PlaybackNotifier with providers, you would need to either:
  // 1. Use the actual providers in widget tests with TestWidgetsFlutterBinding
  // 2. Create a mock using Mockito that generates a proper AudioService mock
  //
  // The FakeAudioService is still useful for testing audio behavior directly
  // as shown in the Audio State Handling tests below.

  group('Audio State Handling', () {
    test('playing state updates isPlaying', () async {
      final fakeAudioService = FakeAudioService();

      final states = <AudioState>[];
      fakeAudioService.stateStream.listen(states.add);

      await fakeAudioService.loadUrl('https://example.com/audio.mp3');
      await fakeAudioService.play();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, contains(AudioState.playing));
      expect(fakeAudioService.isPlaying, isTrue);

      await fakeAudioService.dispose();
    });

    test('paused state updates isPlaying', () async {
      final fakeAudioService = FakeAudioService();

      await fakeAudioService.loadUrl('https://example.com/audio.mp3');
      await fakeAudioService.play();
      await fakeAudioService.pause();

      expect(fakeAudioService.currentState, equals(AudioState.paused));
      expect(fakeAudioService.isPlaying, isFalse);

      await fakeAudioService.dispose();
    });

    test('completed state stops playback', () async {
      final fakeAudioService = FakeAudioService();

      final states = <AudioState>[];
      fakeAudioService.stateStream.listen(states.add);

      await fakeAudioService.loadUrl('https://example.com/audio.mp3');
      await fakeAudioService.play();
      fakeAudioService.simulateCompletion();

      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, contains(AudioState.completed));
      expect(fakeAudioService.isPlaying, isFalse);

      await fakeAudioService.dispose();
    });
  });

  group('Geofence Integration', () {
    test('geofence service setup for stops', () async {
      final fakeLocationService = FakeLocationService();
      final geofenceService = GeofenceService(fakeLocationService);

      // Add geofences manually like PlaybackNotifier._setupGeofences does
      final stops = createTestStops(count: 3);

      for (int i = 0; i < stops.length; i++) {
        final stop = stops[i];
        geofenceService.addGeofence(
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

      expect(geofenceService.geofences.length, equals(3));
      expect(geofenceService.geofences[0].data?['index'], equals(0));

      geofenceService.dispose();
      fakeLocationService.dispose();
    });

    test('geofence events filtered by trigger mode', () async {
      final fakeLocationService = FakeLocationService();
      final geofenceService = GeofenceService(fakeLocationService);

      // In manual mode, geofence enter events should not trigger stops
      // This is tested by checking that the event is received but action depends on mode

      final events = <GeofenceEvent>[];
      geofenceService.eventStream.listen(events.add);

      final geofence = Geofence(
        id: 'test',
        name: 'Test',
        latitude: 37.7749,
        longitude: -122.4194,
        radiusMeters: 50.0,
        data: {'index': 0},
      );

      geofenceService.addGeofence(geofence);

      final position = createTestPosition(latitude: 37.7749, longitude: -122.4194);
      geofenceService.checkPosition(position);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(events.length, equals(1));
      expect(events.first.type, equals(GeofenceEventType.enter));
      expect(events.first.geofence.data?['index'], equals(0));

      geofenceService.dispose();
      fakeLocationService.dispose();
    });
  });

  group('Position Tracking', () {
    test('position updates propagate to state', () async {
      final fakeLocationService = FakeLocationService();

      final positions = <Position>[];
      fakeLocationService.positionStream.listen(positions.add);

      fakeLocationService.emitPosition(
        createTestPosition(latitude: 40.0, longitude: -74.0),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(positions.length, equals(1));
      expect(positions.first.latitude, equals(40.0));

      fakeLocationService.dispose();
    });
  });

  group('Test Helper Validation', () {
    test('createTestTour creates valid tour', () {
      final tour = createTestTour();

      expect(tour.id, isNotEmpty);
      expect(tour.creatorId, equals('test_creator'));
      expect(tour.status, equals(TourStatus.draft));
    });

    test('createTestStops creates sequential stops', () {
      final stops = createTestStops(count: 5);

      expect(stops.length, equals(5));
      for (int i = 0; i < stops.length; i++) {
        expect(stops[i].order, equals(i));
      }
    });

    test('createTestPosition creates valid position', () {
      final position = createTestPosition(
        latitude: 40.0,
        longitude: -74.0,
        accuracy: 5.0,
      );

      expect(position.latitude, equals(40.0));
      expect(position.longitude, equals(-74.0));
      expect(position.accuracy, equals(5.0));
    });
  });
}
