import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/audio_recording_service.dart';

/// Widget for recording and playing back audio
class AudioRecorderWidget extends ConsumerStatefulWidget {
  final String? existingAudioUrl;
  final void Function(String path)? onRecordingComplete;
  final void Function()? onRecordingDeleted;

  const AudioRecorderWidget({
    super.key,
    this.existingAudioUrl,
    this.onRecordingComplete,
    this.onRecordingDeleted,
  });

  @override
  ConsumerState<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends ConsumerState<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Load existing audio if provided
    if (widget.existingAudioUrl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(audioRecordingProvider.notifier)
            .loadExistingAudio(widget.existingAudioUrl!);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(audioRecordingProvider);
    final notifier = ref.read(audioRecordingProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Error message
        if (state.error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.error!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Dismiss error',
                  onPressed: notifier.clearError,
                  iconSize: 18,
                ),
              ],
            ),
          ),

        // Recording visualization
        if (state.isRecording) ...[
          _buildRecordingIndicator(state, theme),
          const SizedBox(height: 16),
        ],

        // Audio player when recording exists
        if (state.hasRecording && !state.isRecording) ...[
          _buildAudioPlayer(state, notifier, theme),
          const SizedBox(height: 16),
        ],

        // Recording controls
        _buildRecordingControls(state, notifier, theme),
      ],
    );
  }

  Widget _buildRecordingIndicator(AudioRecordingState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Animated microphone icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.2),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic,
                    color: theme.colorScheme.onError,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Recording duration
          Text(
            _formatDuration(state.duration),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Amplitude visualization
          _buildAmplitudeVisualizer(state.amplitude, theme),
        ],
      ),
    );
  }

  Widget _buildAmplitudeVisualizer(double amplitude, ThemeData theme) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (index) {
          final random = Random(index);
          final baseHeight = 0.2 + (random.nextDouble() * 0.3);
          final height = baseHeight + (amplitude * 0.5);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 4,
              height: 40 * height.clamp(0.1, 1.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAudioPlayer(
    AudioRecordingState state,
    AudioRecordingNotifier notifier,
    ThemeData theme,
  ) {
    final progress = state.playbackDuration.inMilliseconds > 0
        ? state.playbackPosition.inMilliseconds /
            state.playbackDuration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Progress slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                final position = Duration(
                  milliseconds:
                      (value * state.playbackDuration.inMilliseconds).toInt(),
                );
                notifier.seekTo(position);
              },
            ),
          ),

          // Time display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(state.playbackPosition),
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  _formatDuration(state.playbackDuration),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Delete button
              IconButton(
                tooltip: 'Delete recording',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Recording?'),
                      content: const Text(
                        'This will permanently delete the recorded audio.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await notifier.deleteRecording();
                    widget.onRecordingDeleted?.call();
                  }
                },
                icon: const Icon(Icons.delete_outline),
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 16),

              // Play/Pause button
              FilledButton.icon(
                onPressed: () {
                  if (state.isPlaying) {
                    notifier.pausePlayback();
                  } else {
                    notifier.playRecording();
                  }
                },
                icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(state.isPlaying ? 'Pause' : 'Play'),
              ),
              const SizedBox(width: 16),

              // Stop button
              IconButton(
                tooltip: 'Stop playback',
                onPressed:
                    state.isPlaying ? () => notifier.stopPlayback() : null,
                icon: const Icon(Icons.stop),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingControls(
    AudioRecordingState state,
    AudioRecordingNotifier notifier,
    ThemeData theme,
  ) {
    if (state.isRecording) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Cancel button
          OutlinedButton.icon(
            onPressed: () => notifier.cancelRecording(),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),

          // Stop button
          FilledButton.icon(
            onPressed: () async {
              final path = await notifier.stopRecording();
              if (path != null) {
                widget.onRecordingComplete?.call(path);
              }
            },
            icon: const Icon(Icons.stop),
            label: const Text('Stop Recording'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
          ),
        ],
      );
    }

    // Show record button when not recording
    return Center(
      child: FilledButton.icon(
        onPressed: () async {
          await notifier.startRecording();
        },
        icon: const Icon(Icons.mic),
        label: Text(state.hasRecording ? 'Record Again' : 'Start Recording'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Compact audio recorder for inline use
class CompactAudioRecorder extends ConsumerWidget {
  final String? existingAudioUrl;
  final void Function(String path)? onRecordingComplete;
  final void Function()? onRecordingDeleted;

  const CompactAudioRecorder({
    super.key,
    this.existingAudioUrl,
    this.onRecordingComplete,
    this.onRecordingDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioRecordingProvider);
    final notifier = ref.read(audioRecordingProvider.notifier);
    final theme = Theme.of(context);

    // Show recording progress
    if (state.isRecording) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _RecordingPulse(color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recording...',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  Text(
                    _formatDuration(state.duration),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => notifier.cancelRecording(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                final path = await notifier.stopRecording();
                if (path != null) {
                  onRecordingComplete?.call(path);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: const Text('Stop'),
            ),
          ],
        ),
      );
    }

    // Show player when recording exists
    if (state.hasRecording) {
      final progress = state.playbackDuration.inMilliseconds > 0
          ? state.playbackPosition.inMilliseconds /
              state.playbackDuration.inMilliseconds
          : 0.0;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Play/Pause button
            IconButton(
              onPressed: () {
                if (state.isPlaying) {
                  notifier.pausePlayback();
                } else {
                  notifier.playRecording();
                }
              },
              icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
            ),

            // Progress and time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatDuration(state.playbackPosition)} / ${_formatDuration(state.playbackDuration)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              onPressed: () async {
                await notifier.deleteRecording();
                onRecordingDeleted?.call();
              },
              icon: const Icon(Icons.delete_outline),
              color: theme.colorScheme.error,
            ),

            // Re-record button
            IconButton(
              onPressed: () => notifier.startRecording(),
              icon: const Icon(Icons.mic),
            ),
          ],
        ),
      );
    }

    // Show record button
    return OutlinedButton.icon(
      onPressed: () => notifier.startRecording(),
      icon: const Icon(Icons.mic),
      label: const Text('Record Audio'),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// Animated recording pulse indicator
class _RecordingPulse extends StatefulWidget {
  final Color color;

  const _RecordingPulse({required this.color});

  @override
  State<_RecordingPulse> createState() => _RecordingPulseState();
}

class _RecordingPulseState extends State<_RecordingPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.5 + (_controller.value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
