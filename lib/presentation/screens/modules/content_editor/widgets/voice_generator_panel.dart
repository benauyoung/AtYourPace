import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../data/models/voice_generation_model.dart';
import '../providers/voice_generation_provider.dart';
import 'script_editor.dart';

/// Panel for generating AI voice narration
class VoiceGeneratorPanel extends ConsumerStatefulWidget {
  final String tourId;
  final String stopId;
  final String? initialScript;
  final String? initialVoiceId;
  final String? initialAudioUrl;
  final int? initialAudioDuration;
  final ValueChanged<String?>? onAudioGenerated;

  const VoiceGeneratorPanel({
    super.key,
    required this.tourId,
    required this.stopId,
    this.initialScript,
    this.initialVoiceId,
    this.initialAudioUrl,
    this.initialAudioDuration,
    this.onAudioGenerated,
  });

  @override
  ConsumerState<VoiceGeneratorPanel> createState() =>
      _VoiceGeneratorPanelState();
}

class _VoiceGeneratorPanelState extends ConsumerState<VoiceGeneratorPanel> {
  late TextEditingController _scriptController;

  @override
  void initState() {
    super.initState();
    _scriptController = TextEditingController(text: widget.initialScript ?? '');
  }

  @override
  void dispose() {
    _scriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (
      tourId: widget.tourId,
      stopId: widget.stopId,
      initialScript: widget.initialScript,
      initialVoiceId: widget.initialVoiceId,
      initialAudioUrl: widget.initialAudioUrl,
      initialAudioDuration: widget.initialAudioDuration,
    );
    final state = ref.watch(voiceGenerationProvider(params));
    final notifier = ref.read(voiceGenerationProvider(params).notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Voice Generation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (state.hasAudio)
                  Chip(
                    label: const Text('Generated'),
                    avatar: const Icon(Icons.check_circle, size: 16),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Script editor
            ScriptEditor(
              controller: _scriptController,
              enabled: !state.isGenerating,
              estimatedDurationSeconds: state.estimatedDuration,
              onChanged: (value) => notifier.updateScript(value),
            ),
            const SizedBox(height: 16),

            // Voice selector
            _buildVoiceSelector(context, state, notifier),
            const SizedBox(height: 16),

            // Error message
            if (state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: notifier.clearError,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Audio preview (if generated)
            if (state.hasAudio) ...[
              _buildAudioPreview(context, state, notifier),
              const SizedBox(height: 16),
            ],

            // Generate button
            _buildGenerateButton(context, state, notifier),

            // Rate limit warning
            if (notifier.isRateLimited) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Rate limited. Try again in ${notifier.rateLimitRemainingSeconds}s',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ],

            // Regeneration history
            if (state.history.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildHistorySection(context, state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSelector(
    BuildContext context,
    VoiceGenerationState state,
    VoiceGenerationNotifier notifier,
  ) {
    final voices = notifier.availableVoices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: voices.map((voice) {
            final isSelected = state.selectedVoiceId == voice.id;
            return ChoiceChip(
              label: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(voice.name),
                  Text(
                    voice.accent,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: state.isGenerating
                  ? null
                  : (_) => notifier.selectVoice(voice.id),
              avatar: Icon(
                voice.gender == 'Male' ? Icons.man : Icons.woman,
                size: 18,
              ),
            );
          }).toList(),
        ),
        if (state.selectedVoice != null) ...[
          const SizedBox(height: 8),
          Text(
            state.selectedVoice!.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildAudioPreview(
    BuildContext context,
    VoiceGenerationState state,
    VoiceGenerationNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Play button
          IconButton.filled(
            onPressed: () {
              // TODO: Implement audio playback
              notifier.setPlaying(!state.isPlaying);
            },
            icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          // Audio info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generated Audio',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.actualDurationFormatted,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.record_voice_over,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.selectedVoice?.name ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            onPressed: () => _showDeleteConfirmation(context, notifier),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete audio',
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(
    BuildContext context,
    VoiceGenerationState state,
    VoiceGenerationNotifier notifier,
  ) {
    final validationMessage = state.validationMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: state.canGenerate && !notifier.isRateLimited
              ? () => _handleGenerate(notifier)
              : null,
          icon: state.isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(state.hasAudio ? Icons.refresh : Icons.auto_awesome),
          label: Text(
            state.isGenerating
                ? 'Generating...'
                : state.hasAudio
                    ? 'Regenerate Audio'
                    : 'Generate Audio',
          ),
        ),
        if (validationMessage != null && !state.isGenerating) ...[
          const SizedBox(height: 8),
          Text(
            validationMessage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    VoiceGenerationState state,
  ) {
    return ExpansionTile(
      title: Text(
        'Generation History (${state.history.length})',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      children: state.history.reversed.map((history) {
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(
            'Generated ${_formatDate(history.generatedAt)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            '${history.durationFormatted} • ${VoiceOptions.getById(history.voiceId)?.name ?? 'Unknown'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () {
              // TODO: Play historical audio
            },
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleGenerate(VoiceGenerationNotifier notifier) async {
    final success = await notifier.generate();
    if (success && mounted) {
      // Re-read state from provider after generation
      final params = (
        tourId: widget.tourId,
        stopId: widget.stopId,
        initialScript: widget.initialScript,
        initialVoiceId: widget.initialVoiceId,
        initialAudioUrl: widget.initialAudioUrl,
        initialAudioDuration: widget.initialAudioDuration,
      );
      final state = ref.read(voiceGenerationProvider(params));
      widget.onAudioGenerated?.call(state.audioUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio generated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    VoiceGenerationNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Audio?'),
        content: const Text(
          'This will permanently delete the generated audio. You can regenerate it later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await notifier.deleteAudio();
              widget.onAudioGenerated?.call(null);
              if (mounted) Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
