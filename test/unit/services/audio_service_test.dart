
import 'package:flutter_test/flutter_test.dart';

import 'package:ayp_tour_guide/services/audio_service.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('AudioService', () {
    late FakeAudioService audioService;

    setUp(() {
      audioService = FakeAudioService();
    });

    tearDown(() async {
      await audioService.dispose();
    });

    group('Audio Loading', () {
      test('loads audio from URL and returns duration', () async {
        final duration = await audioService.loadUrl(
          'https://example.com/audio.mp3',
          audioId: 'test_1',
        );

        expect(duration, isNotNull);
        expect(duration!.inMinutes, equals(3));
        expect(audioService.loadedUrl, equals('https://example.com/audio.mp3'));
        expect(audioService.currentAudioId, equals('test_1'));
      });

      test('loads audio from file and returns duration', () async {
        final duration = await audioService.loadFile(
          '/path/to/audio.mp3',
          audioId: 'test_2',
        );

        expect(duration, isNotNull);
        expect(duration!.inMinutes, equals(2));
        expect(audioService.loadedFile, equals('/path/to/audio.mp3'));
      });

      test('loads audio from asset and returns duration', () async {
        final duration = await audioService.loadAsset(
          'assets/audio/test.mp3',
          audioId: 'test_3',
        );

        expect(duration, isNotNull);
        expect(duration!.inMinutes, equals(1));
        expect(audioService.loadedAsset, equals('assets/audio/test.mp3'));
      });

      test('emits loading state when loading audio', () async {
        final states = <AudioState>[];
        final subscription = audioService.stateStream.listen(states.add);

        await audioService.loadUrl('https://example.com/audio.mp3');
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, contains(AudioState.loading));
        expect(states.last, equals(AudioState.idle));

        await subscription.cancel();
      });

      test('playUrl loads and plays audio', () async {
        final states = <AudioState>[];
        final subscription = audioService.stateStream.listen(states.add);

        await audioService.playUrl('https://example.com/audio.mp3');
        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, contains(AudioState.loading));
        expect(states, contains(AudioState.playing));
        expect(audioService.isPlaying, isTrue);

        await subscription.cancel();
      });

      test('playFile loads and plays audio from file', () async {
        await audioService.playFile('/path/to/audio.mp3');

        expect(audioService.isPlaying, isTrue);
        expect(audioService.loadedFile, equals('/path/to/audio.mp3'));
      });
    });

    group('Playback Controls', () {
      setUp(() async {
        await audioService.loadUrl('https://example.com/audio.mp3');
      });

      test('play starts playback', () async {
        expect(audioService.isPlaying, isFalse);

        await audioService.play();

        expect(audioService.isPlaying, isTrue);
        expect(audioService.currentState, equals(AudioState.playing));
      });

      test('pause pauses playback', () async {
        await audioService.play();
        expect(audioService.isPlaying, isTrue);

        await audioService.pause();

        expect(audioService.isPlaying, isFalse);
        expect(audioService.currentState, equals(AudioState.paused));
      });

      test('stop stops playback and resets position', () async {
        await audioService.play();
        await audioService.seek(const Duration(seconds: 30));

        await audioService.stop();

        expect(audioService.isPlaying, isFalse);
        expect(audioService.position, equals(Duration.zero));
        expect(audioService.currentState, equals(AudioState.idle));
      });

      test('seek moves position correctly', () async {
        await audioService.seek(const Duration(seconds: 30));

        expect(audioService.position, equals(const Duration(seconds: 30)));
      });

      test('seek clamps to duration', () async {
        // Duration is 3 minutes
        await audioService.seek(const Duration(minutes: 5));

        expect(audioService.position, equals(const Duration(minutes: 3)));
      });

      test('seek clamps to zero for negative values', () async {
        await audioService.seek(const Duration(seconds: -10));

        expect(audioService.position, equals(Duration.zero));
      });

      test('skipForward advances position', () async {
        await audioService.seek(const Duration(seconds: 30));

        await audioService.skipForward(const Duration(seconds: 10));

        expect(audioService.position, equals(const Duration(seconds: 40)));
      });

      test('skipForward clamps to duration', () async {
        await audioService.seek(const Duration(minutes: 2, seconds: 55));

        await audioService.skipForward(const Duration(seconds: 10));

        expect(audioService.position, equals(const Duration(minutes: 3)));
      });

      test('skipBackward moves position back', () async {
        await audioService.seek(const Duration(seconds: 30));

        await audioService.skipBackward(const Duration(seconds: 10));

        expect(audioService.position, equals(const Duration(seconds: 20)));
      });

      test('skipBackward clamps to zero', () async {
        await audioService.seek(const Duration(seconds: 5));

        await audioService.skipBackward(const Duration(seconds: 10));

        expect(audioService.position, equals(Duration.zero));
      });
    });

    group('Volume and Speed Controls', () {
      test('setVolume sets volume correctly', () async {
        await audioService.setVolume(0.5);

        expect(audioService.volumeLevel, equals(0.5));
      });

      test('setVolume clamps to valid range', () async {
        await audioService.setVolume(1.5);
        expect(audioService.volumeLevel, equals(1.0));

        await audioService.setVolume(-0.5);
        expect(audioService.volumeLevel, equals(0.0));
      });

      test('setSpeed sets playback speed', () async {
        await audioService.setSpeed(1.5);

        expect(audioService.speed, equals(1.5));
      });
    });

    group('State Streams', () {
      test('stateStream emits state changes', () async {
        final states = <AudioState>[];
        final subscription = audioService.stateStream.listen(states.add);

        await audioService.loadUrl('https://example.com/audio.mp3');
        await audioService.play();
        await audioService.pause();
        await audioService.stop();

        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, contains(AudioState.loading));
        expect(states, contains(AudioState.playing));
        expect(states, contains(AudioState.paused));
        expect(states, contains(AudioState.idle));

        await subscription.cancel();
      });

      test('positionStream emits position updates', () async {
        final positions = <Duration>[];
        final subscription = audioService.positionStream.listen(positions.add);

        await audioService.loadUrl('https://example.com/audio.mp3');
        await audioService.seek(const Duration(seconds: 10));
        await audioService.seek(const Duration(seconds: 20));

        await Future.delayed(const Duration(milliseconds: 50));

        expect(positions, contains(const Duration(seconds: 10)));
        expect(positions, contains(const Duration(seconds: 20)));

        await subscription.cancel();
      });

      test('durationStream emits duration on load', () async {
        final durations = <Duration?>[];
        final subscription = audioService.durationStream.listen(durations.add);

        await audioService.loadUrl('https://example.com/audio.mp3');

        await Future.delayed(const Duration(milliseconds: 50));

        expect(durations, contains(const Duration(minutes: 3)));

        await subscription.cancel();
      });
    });

    group('Progress Tracking', () {
      setUp(() async {
        await audioService.loadUrl('https://example.com/audio.mp3');
      });

      test('getProgress returns correct progress', () async {
        await audioService.seek(const Duration(seconds: 90)); // Half of 3 minutes

        final progress = audioService.getProgress();

        expect(progress, closeTo(0.5, 0.01));
      });

      test('getProgress returns 0 when duration is null', () {
        audioService.reset();
        final progress = audioService.getProgress();

        expect(progress, equals(0.0));
      });

      test('getProgress returns 0 at start', () {
        final progress = audioService.getProgress();

        expect(progress, equals(0.0));
      });

      test('getProgress returns 1 at end', () async {
        await audioService.seek(const Duration(minutes: 3));

        final progress = audioService.getProgress();

        expect(progress, equals(1.0));
      });
    });

    group('Formatted Output', () {
      test('getFormattedPosition returns MM:SS format', () async {
        await audioService.loadUrl('https://example.com/audio.mp3');
        await audioService.seek(const Duration(minutes: 1, seconds: 30));

        final formatted = audioService.getFormattedPosition();

        expect(formatted, equals('01:30'));
      });

      test('getFormattedDuration returns MM:SS format', () async {
        await audioService.loadUrl('https://example.com/audio.mp3');

        final formatted = audioService.getFormattedDuration();

        expect(formatted, equals('03:00'));
      });

      test('format handles zero-padding correctly', () async {
        await audioService.loadUrl('https://example.com/audio.mp3');
        await audioService.seek(const Duration(seconds: 5));

        final formatted = audioService.getFormattedPosition();

        expect(formatted, equals('00:05'));
      });
    });

    group('Completion Handling', () {
      test('simulateCompletion emits completed state', () async {
        final states = <AudioState>[];
        final subscription = audioService.stateStream.listen(states.add);

        await audioService.loadUrl('https://example.com/audio.mp3');
        await audioService.play();
        audioService.simulateCompletion();

        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, contains(AudioState.completed));
        expect(audioService.isPlaying, isFalse);

        await subscription.cancel();
      });
    });

    group('Error Handling', () {
      test('simulateError emits error state', () async {
        final states = <AudioState>[];
        final subscription = audioService.stateStream.listen(states.add);

        await audioService.loadUrl('https://example.com/audio.mp3');
        audioService.simulateError();

        await Future.delayed(const Duration(milliseconds: 50));

        expect(states, contains(AudioState.error));
        expect(audioService.isPlaying, isFalse);

        await subscription.cancel();
      });
    });

    group('Resource Disposal', () {
      test('reset clears all state', () async {
        await audioService.loadUrl('https://example.com/audio.mp3');
        await audioService.play();
        await audioService.seek(const Duration(seconds: 30));
        await audioService.setVolume(0.5);
        await audioService.setSpeed(1.5);

        audioService.reset();

        expect(audioService.isPlaying, isFalse);
        expect(audioService.position, equals(Duration.zero));
        expect(audioService.duration, isNull);
        expect(audioService.loadedUrl, isNull);
        expect(audioService.speed, equals(1.0));
        expect(audioService.volumeLevel, equals(1.0));
      });
    });
  });

  group('DurationFormatting Extension', () {
    test('toMMSS formats duration correctly', () {
      const duration = Duration(minutes: 5, seconds: 30);

      expect(duration.toMMSS(), equals('05:30'));
    });

    test('toMMSS handles single digits', () {
      const duration = Duration(seconds: 5);

      expect(duration.toMMSS(), equals('00:05'));
    });

    test('toHHMMSS formats duration with hours', () {
      const duration = Duration(hours: 1, minutes: 30, seconds: 45);

      expect(duration.toHHMMSS(), equals('01:30:45'));
    });

    test('toHHMMSS handles zero hours', () {
      const duration = Duration(minutes: 5, seconds: 30);

      expect(duration.toHHMMSS(), equals('00:05:30'));
    });
  });
}
