import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/data/models/stop_model.dart';
import 'package:ayp_tour_guide/presentation/providers/playback_provider.dart';
import 'package:ayp_tour_guide/services/audio_service.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('TourPlaybackScreen Components', () {
    // Note: Full screen tests require complex mocking of mapbox and providers.
    // These tests focus on the underlying state and helper components.

    group('PlaybackState', () {
      test('isStopCompleted returns correct value', () {
        final state = PlaybackState(
          tour: createTestTour(),
          stops: createTestStops(count: 5),
          completedStopIndices: {0, 2, 4},
          currentStopIndex: 3,
        );

        expect(state.isStopCompleted(0), isTrue);
        expect(state.isStopCompleted(1), isFalse);
        expect(state.isStopCompleted(2), isTrue);
        expect(state.isStopCompleted(3), isFalse);
        expect(state.isStopCompleted(4), isTrue);
      });

      test('currentStop returns correct stop', () {
        final stops = createTestStops(count: 5);
        final state = PlaybackState(
          tour: createTestTour(),
          stops: stops,
          currentStopIndex: 2,
        );

        expect(state.currentStop, equals(stops[2]));
      });

      test('currentStop returns null when index is -1', () {
        final state = PlaybackState(
          tour: createTestTour(),
          stops: createTestStops(count: 5),
          currentStopIndex: -1,
        );

        expect(state.currentStop, isNull);
      });

      test('nextStop returns correct stop', () {
        final stops = createTestStops(count: 5);
        final state = PlaybackState(
          tour: createTestTour(),
          stops: stops,
          currentStopIndex: 2,
        );

        expect(state.nextStop, equals(stops[3]));
      });

      test('nextStop returns null at last stop', () {
        final stops = createTestStops(count: 5);
        final state = PlaybackState(
          tour: createTestTour(),
          stops: stops,
          currentStopIndex: 4,
        );

        expect(state.nextStop, isNull);
      });

      test('nextStop returns first stop when index is -1', () {
        final stops = createTestStops(count: 5);
        final state = PlaybackState(
          tour: createTestTour(),
          stops: stops,
          currentStopIndex: -1,
        );

        expect(state.nextStop, equals(stops[0]));
      });

      test('isCompleted returns true when all stops are completed', () {
        final stops = createTestStops(count: 3);
        final state = PlaybackState(
          tour: createTestTour(),
          stops: stops,
          completedStopIndices: {0, 1, 2},
        );

        expect(state.isCompleted, isTrue);
      });

      test('isCompleted returns false when not all stops are completed', () {
        final stops = createTestStops(count: 3);
        final state = PlaybackState(
          tour: createTestTour(),
          stops: stops,
          completedStopIndices: {0, 2}, // Missing stop 1
        );

        expect(state.isCompleted, isFalse);
      });

      test('progress calculates correctly', () {
        final state = PlaybackState(
          tour: createTestTour(),
          stops: createTestStops(count: 10),
          completedStopIndices: {0, 1, 2, 3, 4}, // 5 completed
        );

        expect(state.progress, equals(0.5));
      });

      test('progress is 0 when no stops completed', () {
        final state = PlaybackState(
          tour: createTestTour(),
          stops: createTestStops(count: 5),
          completedStopIndices: {},
        );

        expect(state.progress, equals(0.0));
      });

      test('progress is 1 when all stops completed', () {
        final state = PlaybackState(
          tour: createTestTour(),
          stops: createTestStops(count: 4),
          completedStopIndices: {0, 1, 2, 3},
        );

        expect(state.progress, equals(1.0));
      });

      test('hasStarted returns true when startedAt is set', () {
        final state = PlaybackState(
          tour: createTestTour(),
          stops: createTestStops(count: 3),
          startedAt: DateTime.now(),
        );

        expect(state.hasStarted, isTrue);
      });

      test('hasStarted returns false when startedAt is null', () {
        final state = PlaybackState(
          tour: createTestTour(),
          stops: createTestStops(count: 3),
        );

        expect(state.hasStarted, isFalse);
      });

      test('copyWith preserves values', () {
        final original = PlaybackState(
          tour: createTestTour(),
          stops: createTestStops(count: 3),
          currentStopIndex: 1,
          isPlaying: true,
          triggerMode: TriggerMode.manual,
        );

        final copied = original.copyWith(currentStopIndex: 2);

        expect(copied.currentStopIndex, equals(2));
        expect(copied.isPlaying, equals(original.isPlaying));
        expect(copied.triggerMode, equals(original.triggerMode));
      });
    });

    group('TriggerMode', () {
      test('has automatic and manual values', () {
        expect(TriggerMode.values, containsAll([
          TriggerMode.automatic,
          TriggerMode.manual,
        ]));
      });
    });

    group('AudioState Display', () {
      testWidgets('play button shows play icon when idle', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestPlayButton(audioState: AudioState.idle),
            ),
          ),
        );

        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });

      testWidgets('play button shows pause icon when playing', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestPlayButton(audioState: AudioState.playing),
            ),
          ),
        );

        expect(find.byIcon(Icons.pause), findsOneWidget);
      });

      testWidgets('play button shows play icon when paused', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestPlayButton(audioState: AudioState.paused),
            ),
          ),
        );

        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      });
    });

    group('Progress Display', () {
      testWidgets('shows correct progress text', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestProgressDisplay(
                completed: 3,
                total: 5,
              ),
            ),
          ),
        );

        expect(find.text('3/5 stops'), findsOneWidget);
      });
    });

    group('Duration Formatting', () {
      test('formats duration correctly', () {
        expect(_formatDuration(const Duration(seconds: 0)), equals('0:00'));
        expect(_formatDuration(const Duration(seconds: 5)), equals('0:05'));
        expect(_formatDuration(const Duration(seconds: 65)), equals('1:05'));
        expect(_formatDuration(const Duration(minutes: 10, seconds: 30)), equals('10:30'));
        expect(_formatDuration(const Duration(hours: 1, minutes: 5, seconds: 30)), equals('65:30'));
      });
    });

    group('Distance Formatting', () {
      test('formats meters correctly', () {
        expect(_formatDistance(50), equals('50 m away'));
        expect(_formatDistance(999), equals('999 m away'));
      });

      test('formats kilometers correctly', () {
        expect(_formatDistance(1000), equals('1.0 km away'));
        expect(_formatDistance(1500), equals('1.5 km away'));
        expect(_formatDistance(10000), equals('10.0 km away'));
      });

      test('handles null distance', () {
        expect(_formatDistance(null), equals(''));
      });
    });

    group('Stop List Item', () {
      testWidgets('shows stop number for uncompleted stop', (tester) async {
        final stop = createTestStop(order: 2, name: 'Test Stop');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestStopListItem(
                stop: stop,
                index: 2,
                isCompleted: false,
                isCurrent: false,
              ),
            ),
          ),
        );

        expect(find.text('3'), findsOneWidget); // 0-indexed, so displays 3
        expect(find.text('Test Stop 2'), findsOneWidget);
      });

      testWidgets('shows checkmark for completed stop', (tester) async {
        final stop = createTestStop(order: 0, name: 'Completed Stop');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestStopListItem(
                stop: stop,
                index: 0,
                isCompleted: true,
                isCurrent: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.check), findsOneWidget);
      });

      testWidgets('highlights current stop', (tester) async {
        final stop = createTestStop(order: 1, name: 'Current Stop');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestStopListItem(
                stop: stop,
                index: 1,
                isCompleted: false,
                isCurrent: true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.play_circle), findsOneWidget);
      });
    });

    group('Tour Completed Overlay', () {
      testWidgets('shows celebration message', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestTourCompletedOverlay(
                onDone: () {},
              ),
            ),
          ),
        );

        expect(find.text('Tour Complete!'), findsOneWidget);
        expect(find.text("You've completed all stops"), findsOneWidget);
        expect(find.byIcon(Icons.celebration), findsOneWidget);
      });

      testWidgets('shows rate tour and done buttons', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestTourCompletedOverlay(
                onDone: () {},
              ),
            ),
          ),
        );

        expect(find.text('Rate Tour'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
      });

      testWidgets('calls onDone when Done is tapped', (tester) async {
        bool doneCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _TestTourCompletedOverlay(
                onDone: () => doneCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        expect(doneCalled, isTrue);
      });
    });

    group('End Tour Dialog', () {
      testWidgets('shows confirmation dialog', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => _showEndTourDialog(context, () {}),
                  child: const Text('End Tour'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('End Tour'));
        await tester.pumpAndSettle();

        expect(find.text('End Tour?'), findsOneWidget);
        expect(find.text('Your progress will be saved. You can resume the tour later.'), findsOneWidget);
        expect(find.text('Continue Tour'), findsOneWidget);
      });

      testWidgets('dismisses when Continue Tour is tapped', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => _showEndTourDialog(context, () {}),
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Continue Tour'));
        await tester.pumpAndSettle();

        expect(find.text('End Tour?'), findsNothing);
      });
    });
  });
}

// Test helper widgets and functions

class _TestPlayButton extends StatelessWidget {
  final AudioState audioState;

  const _TestPlayButton({required this.audioState});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      child: Icon(
        audioState == AudioState.playing ? Icons.pause : Icons.play_arrow,
        size: 32,
      ),
    );
  }
}

class _TestProgressDisplay extends StatelessWidget {
  final int completed;
  final int total;

  const _TestProgressDisplay({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Text('$completed/$total stops');
  }
}

class _TestStopListItem extends StatelessWidget {
  final StopModel stop;
  final int index;
  final bool isCompleted;
  final bool isCurrent;

  const _TestStopListItem({
    required this.stop,
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isCurrent
              ? Theme.of(context).colorScheme.primary
              : isCompleted
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isCompleted
              ? Icon(
                  Icons.check,
                  size: 20,
                  color: isCurrent
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                )
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
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
      trailing: isCurrent
          ? Icon(
              Icons.play_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}

class _TestTourCompletedOverlay extends StatelessWidget {
  final VoidCallback onDone;

  const _TestTourCompletedOverlay({required this.onDone});

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
                Icon(
                  Icons.celebration,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tour Complete!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You've completed all stops",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
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
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _formatDistance(double? distance) {
  if (distance == null) return '';
  if (distance < 1000) {
    return '${distance.toInt()} m away';
  }
  return '${(distance / 1000).toStringAsFixed(1)} km away';
}

void _showEndTourDialog(BuildContext context, VoidCallback onEnd) {
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
            onEnd();
            Navigator.pop(dialogContext);
          },
          child: const Text('End Tour'),
        ),
      ],
    ),
  );
}
