import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Provider for the audio service
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Initialize audio service for background playback
/// This should be called once in main.dart before runApp
Future<void> initAudioService() async {
  // Skip background audio initialization on web - not supported
  if (kIsWeb) return;

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ayp.aypTourGuide.audio',
    androidNotificationChannelName: 'Tour Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );
}

/// Provider for the current audio state
final audioStateProvider = StreamProvider<AudioState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.stateStream;
});

/// Provider for the current playback position
final audioPositionProvider = StreamProvider<Duration>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.positionStream;
});

/// Provider for the current playback duration
final audioDurationProvider = StreamProvider<Duration?>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  return audioService.durationStream;
});

/// Audio playback states
enum AudioState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

/// Service for managing audio playback with background support
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  final StreamController<AudioState> _stateController =
      StreamController<AudioState>.broadcast();

  String? _currentAudioId;
  String? _currentTitle;
  String? _currentArtist;
  String? _currentArtworkUrl;
  bool _isSessionConfigured = false;

  AudioService() {
    _setupListeners();
    _configureAudioSession();
  }

  /// Configure audio session for playback
  Future<void> _configureAudioSession() async {
    if (_isSessionConfigured || kIsWeb) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          usage: AndroidAudioUsage.media,
          flags: AndroidAudioFlags.none,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      // Handle audio interruptions (phone calls, etc.)
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Another app wants us to lower volume
              _player.setVolume(0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // We should pause
              _player.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Restore volume
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // We can resume, but let user decide
              break;
          }
        }
      });

      // Handle becoming noisy (headphones unplugged)
      session.becomingNoisyEventStream.listen((_) {
        _player.pause();
      });

      _isSessionConfigured = true;
    } catch (e) {
      // Audio session configuration failed, continue without it
    }
  }

  /// Stream of audio states
  Stream<AudioState> get stateStream => _stateController.stream;

  /// Stream of playback position
  Stream<Duration> get positionStream => _player.positionStream;

  /// Stream of audio duration
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Current audio ID being played
  String? get currentAudioId => _currentAudioId;

  /// Current playback position
  Duration get position => _player.position;

  /// Current audio duration
  Duration? get duration => _player.duration;

  /// Whether audio is currently playing
  bool get isPlaying => _player.playing;

  /// Current playback state
  AudioState get currentState {
    final processingState = _player.processingState;
    if (_player.playing) {
      return AudioState.playing;
    } else if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return AudioState.loading;
    } else if (processingState == ProcessingState.completed) {
      return AudioState.completed;
    } else if (_player.position > Duration.zero) {
      return AudioState.paused;
    }
    return AudioState.idle;
  }

  void _setupListeners() {
    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      if (state.playing) {
        _stateController.add(AudioState.playing);
      } else {
        switch (state.processingState) {
          case ProcessingState.idle:
            _stateController.add(AudioState.idle);
            break;
          case ProcessingState.loading:
          case ProcessingState.buffering:
            _stateController.add(AudioState.loading);
            break;
          case ProcessingState.ready:
            if (_player.position > Duration.zero) {
              _stateController.add(AudioState.paused);
            } else {
              _stateController.add(AudioState.idle);
            }
            break;
          case ProcessingState.completed:
            _stateController.add(AudioState.completed);
            break;
        }
      }
    });
  }

  /// Set metadata for lock screen display
  void setMetadata({
    String? title,
    String? artist,
    String? artworkUrl,
  }) {
    _currentTitle = title;
    _currentArtist = artist;
    _currentArtworkUrl = artworkUrl;
  }

  /// Load audio from URL with optional lock screen metadata
  Future<Duration?> loadUrl(
    String url, {
    String? audioId,
    String? title,
    String? artist,
    String? artworkUrl,
  }) async {
    try {
      _stateController.add(AudioState.loading);
      _currentAudioId = audioId;
      _currentTitle = title;
      _currentArtist = artist;
      _currentArtworkUrl = artworkUrl;

      // Create audio source with media item for lock screen controls
      final audioSource = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: audioId ?? url,
          title: title ?? 'Tour Audio',
          artist: artist ?? 'AYP Tour Guide',
          artUri: artworkUrl != null ? Uri.parse(artworkUrl) : null,
        ),
      );

      final duration = await _player.setAudioSource(audioSource);
      return duration;
    } catch (e) {
      _stateController.add(AudioState.error);
      rethrow;
    }
  }

  /// Load audio from local file with optional lock screen metadata
  Future<Duration?> loadFile(
    String filePath, {
    String? audioId,
    String? title,
    String? artist,
    String? artworkUrl,
  }) async {
    try {
      _stateController.add(AudioState.loading);
      _currentAudioId = audioId;
      _currentTitle = title;
      _currentArtist = artist;
      _currentArtworkUrl = artworkUrl;

      // Create audio source with media item for lock screen controls
      final audioSource = AudioSource.file(
        filePath,
        tag: MediaItem(
          id: audioId ?? filePath,
          title: title ?? 'Tour Audio',
          artist: artist ?? 'AYP Tour Guide',
          artUri: artworkUrl != null ? Uri.parse(artworkUrl) : null,
        ),
      );

      final duration = await _player.setAudioSource(audioSource);
      return duration;
    } catch (e) {
      _stateController.add(AudioState.error);
      rethrow;
    }
  }

  /// Load audio from asset with optional lock screen metadata
  Future<Duration?> loadAsset(
    String assetPath, {
    String? audioId,
    String? title,
    String? artist,
    String? artworkUrl,
  }) async {
    try {
      _stateController.add(AudioState.loading);
      _currentAudioId = audioId;
      _currentTitle = title;
      _currentArtist = artist;
      _currentArtworkUrl = artworkUrl;

      // Create audio source with media item for lock screen controls
      final audioSource = AudioSource.asset(
        assetPath,
        tag: MediaItem(
          id: audioId ?? assetPath,
          title: title ?? 'Tour Audio',
          artist: artist ?? 'AYP Tour Guide',
          artUri: artworkUrl != null ? Uri.parse(artworkUrl) : null,
        ),
      );

      final duration = await _player.setAudioSource(audioSource);
      return duration;
    } catch (e) {
      _stateController.add(AudioState.error);
      rethrow;
    }
  }

  /// Play the loaded audio
  Future<void> play() async {
    await _player.play();
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop playback and reset position
  Future<void> stop() async {
    await _player.stop();
    _currentAudioId = null;
  }

  /// Seek to a position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Skip forward by duration
  Future<void> skipForward(Duration duration) async {
    final newPosition = _player.position + duration;
    final max = _player.duration ?? Duration.zero;
    await _player.seek(newPosition > max ? max : newPosition);
  }

  /// Skip backward by duration
  Future<void> skipBackward(Duration duration) async {
    final newPosition = _player.position - duration;
    await _player.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Load and play audio from URL
  Future<void> playUrl(
    String url, {
    String? audioId,
    String? title,
    String? artist,
    String? artworkUrl,
  }) async {
    await loadUrl(
      url,
      audioId: audioId,
      title: title,
      artist: artist,
      artworkUrl: artworkUrl,
    );
    await play();
  }

  /// Load and play audio from file
  Future<void> playFile(
    String filePath, {
    String? audioId,
    String? title,
    String? artist,
    String? artworkUrl,
  }) async {
    await loadFile(
      filePath,
      audioId: audioId,
      title: title,
      artist: artist,
      artworkUrl: artworkUrl,
    );
    await play();
  }

  /// Get formatted position string (MM:SS)
  String getFormattedPosition() {
    return _formatDuration(_player.position);
  }

  /// Get formatted duration string (MM:SS)
  String getFormattedDuration() {
    return _formatDuration(_player.duration ?? Duration.zero);
  }

  /// Get playback progress (0.0 to 1.0)
  double getProgress() {
    final duration = _player.duration;
    if (duration == null || duration.inMilliseconds == 0) return 0.0;
    return _player.position.inMilliseconds / duration.inMilliseconds;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
    await _stateController.close();
  }
}

/// Extension for Duration formatting
extension DurationFormatting on Duration {
  String toMMSS() {
    final minutes = inMinutes;
    final seconds = inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String toHHMMSS() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
