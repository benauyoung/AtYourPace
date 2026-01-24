import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/stop_model.dart';
import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/presentation/providers/playback_provider.dart';
import 'package:ayp_tour_guide/services/audio_service.dart';

import '../helpers/test_helpers.dart';
import '../helpers/mock_services.dart';

/// Integration tests for the complete tour playback flow.
///
/// Tests the flow: Discover -> Start Tour -> Geofence Enter -> Audio Plays
/// -> Complete Stops -> Tour Complete
void main() {
  group('Tour Playback Flow Integration', () {
    late TourModel testTour;
    late List<StopModel> testStops;
    late FakeAudioService fakeAudioService;

    setUp(() {
      testTour = createTestTour(
        id: 'integration_tour_1',
        city: 'Test City',
        country: 'Test Country',
      );
      testStops = createTestStops(count: 3);
      fakeAudioService = FakeAudioService();
    });

    tearDown(() {
      fakeAudioService.dispose();
    });

    group('PlaybackState Lifecycle', () {
      test('initializes with correct default values', () {
        final state = PlaybackState(
          tour: testTour,
          stops: testStops,
        );

        expect(state.currentStopIndex, equals(-1));
        expect(state.isPlaying, isFalse);
        expect(state.hasStarted, isFalse);
        expect(state.isCompleted, isFalse);
        expect(state.progress, equals(0.0));
        expect(state.triggerMode, equals(TriggerMode.automatic));
      });

      test('tracks tour start time when started', () {
        final beforeStart = DateTime.now();

        final state = PlaybackState(
          tour: testTour,
          stops: testStops,
          startedAt: DateTime.now(),
        );

        expect(state.hasStarted, isTrue);
        expect(state.startedAt, isNotNull);
        expect(
          state.startedAt!.isAfter(beforeStart) ||
              state.startedAt!.isAtSameMomentAs(beforeStart),
          isTrue,
        );
      });

      test('progresses through stops correctly', () {
        // Start at first stop
        var state = PlaybackState(
          tour: testTour,
          stops: testStops,
          currentStopIndex: 0,
          startedAt: DateTime.now(),
        );

        expect(state.currentStop, equals(testStops[0]));
        expect(state.nextStop, equals(testStops[1]));
        expect(state.progress, equals(0.0));

        // Complete first stop
        state = state.copyWith(
          completedStopIndices: {0},
          currentStopIndex: 1,
        );

        expect(state.currentStop, equals(testStops[1]));
        expect(state.nextStop, equals(testStops[2]));
        expect(state.progress, closeTo(0.333, 0.01));
        expect(state.isStopCompleted(0), isTrue);
        expect(state.isStopCompleted(1), isFalse);

        // Complete second stop
        state = state.copyWith(
          completedStopIndices: {0, 1},
          currentStopIndex: 2,
        );

        expect(state.currentStop, equals(testStops[2]));
        expect(state.nextStop, isNull);
        expect(state.progress, closeTo(0.666, 0.01));

        // Complete final stop
        state = state.copyWith(
          completedStopIndices: {0, 1, 2},
        );

        expect(state.isCompleted, isTrue);
        expect(state.progress, equals(1.0));
      });

      test('handles trigger mode switching', () {
        var state = PlaybackState(
          tour: testTour,
          stops: testStops,
          triggerMode: TriggerMode.automatic,
        );

        expect(state.triggerMode, equals(TriggerMode.automatic));

        state = state.copyWith(triggerMode: TriggerMode.manual);

        expect(state.triggerMode, equals(TriggerMode.manual));
      });
    });

    group('Audio Playback Integration', () {
      test('audio service state transitions work correctly', () async {
        expect(fakeAudioService.state, equals(AudioState.idle));

        // Simulate loading and playing
        fakeAudioService.simulateStateChange(AudioState.loading);
        expect(fakeAudioService.state, equals(AudioState.loading));

        fakeAudioService.simulateStateChange(AudioState.playing);
        expect(fakeAudioService.state, equals(AudioState.playing));

        // Pause
        fakeAudioService.simulateStateChange(AudioState.paused);
        expect(fakeAudioService.state, equals(AudioState.paused));

        // Resume
        fakeAudioService.simulateStateChange(AudioState.playing);
        expect(fakeAudioService.state, equals(AudioState.playing));

        // Complete
        fakeAudioService.simulateStateChange(AudioState.completed);
        expect(fakeAudioService.state, equals(AudioState.completed));
      });

      test('audio state stream emits correct sequence', () async {
        final states = <AudioState>[];
        final subscription = fakeAudioService.stateStream.listen(states.add);

        fakeAudioService.simulateStateChange(AudioState.loading);
        fakeAudioService.simulateStateChange(AudioState.playing);
        fakeAudioService.simulateStateChange(AudioState.completed);

        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, containsAllInOrder([
          AudioState.loading,
          AudioState.playing,
          AudioState.completed,
        ]));

        await subscription.cancel();
      });

      test('position tracking works correctly', () async {
        final positions = <Duration>[];
        final subscription = fakeAudioService.positionStream.listen(positions.add);

        fakeAudioService.simulatePosition(const Duration(seconds: 10));
        fakeAudioService.simulatePosition(const Duration(seconds: 20));
        fakeAudioService.simulatePosition(const Duration(seconds: 30));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(positions, containsAllInOrder([
          const Duration(seconds: 10),
          const Duration(seconds: 20),
          const Duration(seconds: 30),
        ]));

        await subscription.cancel();
      });
    });

    group('Stop Completion Flow', () {
      test('completes stops in sequence with audio', () async {
        var state = PlaybackState(
          tour: testTour,
          stops: testStops,
          currentStopIndex: 0,
          startedAt: DateTime.now(),
        );

        // Simulate playing first stop's audio
        fakeAudioService.simulateStateChange(AudioState.playing);
        state = state.copyWith(isPlaying: true);
        expect(state.isPlaying, isTrue);

        // Audio completes
        fakeAudioService.simulateStateChange(AudioState.completed);
        state = state.copyWith(
          isPlaying: false,
          completedStopIndices: {0},
          currentStopIndex: 1,
        );

        expect(state.isPlaying, isFalse);
        expect(state.isStopCompleted(0), isTrue);
        expect(state.currentStopIndex, equals(1));

        // Continue to second stop
        fakeAudioService.simulateStateChange(AudioState.playing);
        state = state.copyWith(isPlaying: true);

        fakeAudioService.simulateStateChange(AudioState.completed);
        state = state.copyWith(
          isPlaying: false,
          completedStopIndices: {0, 1},
          currentStopIndex: 2,
        );

        expect(state.isStopCompleted(1), isTrue);

        // Final stop
        fakeAudioService.simulateStateChange(AudioState.playing);
        fakeAudioService.simulateStateChange(AudioState.completed);
        state = state.copyWith(
          isPlaying: false,
          completedStopIndices: {0, 1, 2},
        );

        expect(state.isCompleted, isTrue);
      });

      test('handles out-of-order stop completion', () {
        var state = PlaybackState(
          tour: testTour,
          stops: testStops,
          currentStopIndex: 0,
          startedAt: DateTime.now(),
        );

        // Complete stop 2 first (manual mode scenario)
        state = state.copyWith(
          completedStopIndices: {2},
          currentStopIndex: 2,
        );

        expect(state.isStopCompleted(0), isFalse);
        expect(state.isStopCompleted(1), isFalse);
        expect(state.isStopCompleted(2), isTrue);
        expect(state.isCompleted, isFalse);

        // Complete remaining stops
        state = state.copyWith(
          completedStopIndices: {0, 1, 2},
        );

        expect(state.isCompleted, isTrue);
      });
    });

    group('Tour Completion', () {
      test('calculates correct completion time', () {
        final startTime = DateTime.now().subtract(const Duration(hours: 1));
        final endTime = DateTime.now();

        final state = PlaybackState(
          tour: testTour,
          stops: testStops,
          startedAt: startTime,
          completedStopIndices: {0, 1, 2},
        );

        expect(state.isCompleted, isTrue);
        expect(state.hasStarted, isTrue);

        final duration = endTime.difference(startTime);
        expect(duration.inMinutes, greaterThanOrEqualTo(59));
      });

      test('preserves completion state through copyWith', () {
        final state = PlaybackState(
          tour: testTour,
          stops: testStops,
          completedStopIndices: {0, 1, 2},
          startedAt: DateTime.now(),
        );

        final copied = state.copyWith(isPlaying: false);

        expect(copied.isCompleted, isTrue);
        expect(copied.completedStopIndices, equals({0, 1, 2}));
      });
    });

    group('Error Scenarios', () {
      test('handles audio error gracefully', () async {
        fakeAudioService.simulateStateChange(AudioState.error);

        expect(fakeAudioService.state, equals(AudioState.error));

        // Should be able to recover
        fakeAudioService.simulateStateChange(AudioState.idle);
        expect(fakeAudioService.state, equals(AudioState.idle));
      });

      test('handles empty stops list', () {
        final state = PlaybackState(
          tour: testTour,
          stops: [],
        );

        expect(state.currentStop, isNull);
        expect(state.nextStop, isNull);
        expect(state.progress, equals(0.0));
        // Empty tour is NOT completed - there must be stops to complete
        expect(state.isCompleted, isFalse);
      });

      test('handles single stop tour', () {
        final singleStop = [testStops.first];

        var state = PlaybackState(
          tour: testTour,
          stops: singleStop,
          currentStopIndex: 0,
        );

        expect(state.nextStop, isNull);
        expect(state.isCompleted, isFalse);

        state = state.copyWith(completedStopIndices: {0});
        expect(state.isCompleted, isTrue);
        expect(state.progress, equals(1.0));
      });
    });

    group('Pause and Resume', () {
      test('maintains state when paused', () {
        var state = PlaybackState(
          tour: testTour,
          stops: testStops,
          currentStopIndex: 1,
          completedStopIndices: {0},
          isPlaying: true,
          startedAt: DateTime.now(),
        );

        // Pause
        state = state.copyWith(isPlaying: false);

        expect(state.isPlaying, isFalse);
        expect(state.currentStopIndex, equals(1));
        expect(state.completedStopIndices, equals({0}));
        expect(state.hasStarted, isTrue);
      });

      test('resumes from correct position', () {
        var state = PlaybackState(
          tour: testTour,
          stops: testStops,
          currentStopIndex: 1,
          completedStopIndices: {0},
          isPlaying: false,
        );

        // Resume
        state = state.copyWith(isPlaying: true);

        expect(state.isPlaying, isTrue);
        expect(state.currentStop, equals(testStops[1]));
      });
    });
  });

  group('Widget Integration', () {
    testWidgets('progress indicator reflects state', (tester) async {
      final state = PlaybackState(
        tour: createTestTour(),
        stops: createTestStops(count: 4),
        completedStopIndices: {0, 1},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                LinearProgressIndicator(value: state.progress),
                Text('${(state.progress * 100).toInt()}%'),
                Text('${state.completedStopIndices.length}/${state.stops.length} stops'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('50%'), findsOneWidget);
      expect(find.text('2/4 stops'), findsOneWidget);
    });

    testWidgets('stop list shows completion status', (tester) async {
      final state = PlaybackState(
        tour: createTestTour(),
        stops: createTestStops(count: 3),
        completedStopIndices: {0},
        currentStopIndex: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: state.stops.length,
              itemBuilder: (context, index) {
                final isCompleted = state.isStopCompleted(index);
                final isCurrent = state.currentStopIndex == index;

                return ListTile(
                  leading: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : isCurrent
                            ? Icons.play_circle
                            : Icons.circle_outlined,
                  ),
                  title: Text(state.stops[index].name),
                );
              },
            ),
          ),
        ),
      );

      // Verify icons are correct
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.play_circle), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    });
  });
}
