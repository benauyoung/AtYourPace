import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Audio recording service for creating stop narrations
class AudioRecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<RecordState>? _recordStateSubscription;
  StreamSubscription<Amplitude>? _amplitudeSubscription;

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get currentRecordingPath => _currentRecordingPath;
  Duration get recordingDuration => _recordingDuration;

  /// Check and request microphone permission
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      // Web handles permissions differently via browser
      return await _recorder.hasPermission();
    }

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    if (kIsWeb) {
      return await _recorder.hasPermission();
    }
    return await Permission.microphone.isGranted;
  }

  /// Start recording audio
  Future<bool> startRecording({
    String? customPath,
    void Function(Duration)? onDurationUpdate,
    void Function(double)? onAmplitudeUpdate,
  }) async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        return false;
      }

      // Generate file path
      if (customPath != null) {
        _currentRecordingPath = customPath;
      } else {
        final dir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _currentRecordingPath = '${dir.path}/recording_$timestamp.m4a';
      }

      // Configure recording
      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      );

      // Start recording
      await _recorder.start(config, path: _currentRecordingPath!);
      _isRecording = true;
      _recordingDuration = Duration.zero;

      // Start duration timer
      _durationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        _recordingDuration += const Duration(milliseconds: 100);
        onDurationUpdate?.call(_recordingDuration);
      });

      // Listen to amplitude changes
      _amplitudeSubscription = _recorder.onAmplitudeChanged(
        const Duration(milliseconds: 100),
      ).listen((amplitude) {
        // Normalize amplitude to 0-1 range
        final normalized = (amplitude.current + 60) / 60;
        onAmplitudeUpdate?.call(normalized.clamp(0.0, 1.0));
      });

      return true;
    } catch (e) {
      debugPrint('Error starting recording: $e');
      return false;
    }
  }

  /// Stop recording and return the file path
  Future<String?> stopRecording() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;

      final path = await _recorder.stop();
      _isRecording = false;

      return path ?? _currentRecordingPath;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Cancel recording and delete the file
  Future<void> cancelRecording() async {
    try {
      _durationTimer?.cancel();
      _durationTimer = null;
      await _amplitudeSubscription?.cancel();
      _amplitudeSubscription = null;

      await _recorder.stop();
      _isRecording = false;

      // Delete the recording file
      if (_currentRecordingPath != null && !kIsWeb) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;
    } catch (e) {
      debugPrint('Error canceling recording: $e');
    }
  }

  /// Play recorded audio
  Future<void> playRecording({
    String? path,
    void Function()? onComplete,
    void Function(Duration, Duration)? onPositionUpdate,
  }) async {
    try {
      final audioPath = path ?? _currentRecordingPath;
      if (audioPath == null) return;

      if (kIsWeb) {
        // Web uses different audio source
        await _player.setUrl(audioPath);
      } else {
        await _player.setFilePath(audioPath);
      }

      _isPlaying = true;

      // Listen to position updates
      _player.positionStream.listen((position) {
        final duration = _player.duration ?? Duration.zero;
        onPositionUpdate?.call(position, duration);
      });

      // Listen to completion
      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          onComplete?.call();
        }
      });

      await _player.play();
    } catch (e) {
      debugPrint('Error playing recording: $e');
      _isPlaying = false;
    }
  }

  /// Pause playback
  Future<void> pausePlayback() async {
    await _player.pause();
    _isPlaying = false;
  }

  /// Resume playback
  Future<void> resumePlayback() async {
    await _player.play();
    _isPlaying = true;
  }

  /// Stop playback
  Future<void> stopPlayback() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Seek to position
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  /// Get audio duration from file
  Future<Duration?> getAudioDuration(String path) async {
    try {
      if (kIsWeb) {
        await _player.setUrl(path);
      } else {
        await _player.setFilePath(path);
      }
      return _player.duration;
    } catch (e) {
      debugPrint('Error getting audio duration: $e');
      return null;
    }
  }

  /// Delete recording file
  Future<void> deleteRecording(String? path) async {
    try {
      final audioPath = path ?? _currentRecordingPath;
      if (audioPath != null && !kIsWeb) {
        final file = File(audioPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      if (path == _currentRecordingPath) {
        _currentRecordingPath = null;
      }
    } catch (e) {
      debugPrint('Error deleting recording: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _durationTimer?.cancel();
    await _recordStateSubscription?.cancel();
    await _amplitudeSubscription?.cancel();
    _recorder.dispose();
    await _player.dispose();
  }
}

/// Recording state for UI
enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}

/// Audio recording state model
class AudioRecordingState {
  final RecordingState recordingState;
  final Duration duration;
  final double amplitude;
  final String? filePath;
  final String? error;
  final bool isPlaying;
  final Duration playbackPosition;
  final Duration playbackDuration;

  const AudioRecordingState({
    this.recordingState = RecordingState.idle,
    this.duration = Duration.zero,
    this.amplitude = 0.0,
    this.filePath,
    this.error,
    this.isPlaying = false,
    this.playbackPosition = Duration.zero,
    this.playbackDuration = Duration.zero,
  });

  AudioRecordingState copyWith({
    RecordingState? recordingState,
    Duration? duration,
    double? amplitude,
    String? filePath,
    String? error,
    bool? isPlaying,
    Duration? playbackPosition,
    Duration? playbackDuration,
  }) {
    return AudioRecordingState(
      recordingState: recordingState ?? this.recordingState,
      duration: duration ?? this.duration,
      amplitude: amplitude ?? this.amplitude,
      filePath: filePath ?? this.filePath,
      error: error,
      isPlaying: isPlaying ?? this.isPlaying,
      playbackPosition: playbackPosition ?? this.playbackPosition,
      playbackDuration: playbackDuration ?? this.playbackDuration,
    );
  }

  bool get hasRecording => filePath != null;
  bool get isRecording => recordingState == RecordingState.recording;
  bool get canPlay => hasRecording && !isRecording;
}

/// Audio recording notifier for state management
class AudioRecordingNotifier extends StateNotifier<AudioRecordingState> {
  final AudioRecordingService _service;

  AudioRecordingNotifier(this._service) : super(const AudioRecordingState());

  Future<bool> startRecording() async {
    final success = await _service.startRecording(
      onDurationUpdate: (duration) {
        state = state.copyWith(duration: duration);
      },
      onAmplitudeUpdate: (amplitude) {
        state = state.copyWith(amplitude: amplitude);
      },
    );

    if (success) {
      state = state.copyWith(
        recordingState: RecordingState.recording,
        error: null,
      );
    } else {
      state = state.copyWith(
        error: 'Failed to start recording. Please check microphone permissions.',
      );
    }

    return success;
  }

  Future<String?> stopRecording() async {
    final path = await _service.stopRecording();

    if (path != null) {
      // Get duration
      final duration = await _service.getAudioDuration(path);

      state = state.copyWith(
        recordingState: RecordingState.stopped,
        filePath: path,
        playbackDuration: duration ?? state.duration,
        error: null,
      );
    } else {
      state = state.copyWith(
        recordingState: RecordingState.idle,
        error: 'Failed to save recording',
      );
    }

    return path;
  }

  Future<void> cancelRecording() async {
    await _service.cancelRecording();
    state = const AudioRecordingState();
  }

  Future<void> playRecording() async {
    if (!state.hasRecording) return;

    await _service.playRecording(
      path: state.filePath,
      onComplete: () {
        state = state.copyWith(
          isPlaying: false,
          playbackPosition: Duration.zero,
        );
      },
      onPositionUpdate: (position, duration) {
        state = state.copyWith(
          playbackPosition: position,
          playbackDuration: duration,
        );
      },
    );

    state = state.copyWith(isPlaying: true);
  }

  Future<void> pausePlayback() async {
    await _service.pausePlayback();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> stopPlayback() async {
    await _service.stopPlayback();
    state = state.copyWith(
      isPlaying: false,
      playbackPosition: Duration.zero,
    );
  }

  Future<void> seekTo(Duration position) async {
    await _service.seekTo(position);
  }

  Future<void> deleteRecording() async {
    await _service.stopPlayback();
    await _service.deleteRecording(state.filePath);
    state = const AudioRecordingState();
  }

  /// Load existing audio file
  Future<void> loadExistingAudio(String path) async {
    final duration = await _service.getAudioDuration(path);
    state = state.copyWith(
      recordingState: RecordingState.stopped,
      filePath: path,
      playbackDuration: duration ?? Duration.zero,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

/// Provider for audio recording service
final audioRecordingServiceProvider = Provider<AudioRecordingService>((ref) {
  final service = AudioRecordingService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for audio recording state
final audioRecordingProvider = StateNotifierProvider.autoDispose<
    AudioRecordingNotifier, AudioRecordingState>((ref) {
  final service = ref.watch(audioRecordingServiceProvider);
  return AudioRecordingNotifier(service);
});
