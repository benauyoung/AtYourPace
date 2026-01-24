import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/tour_providers.dart';

/// Widget for selecting an ElevenLabs voice for AI audio generation.
class VoiceSelectorWidget extends ConsumerWidget {
  final String? selectedVoiceId;
  final ValueChanged<String> onVoiceSelected;

  const VoiceSelectorWidget({
    super.key,
    this.selectedVoiceId,
    required this.onVoiceSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctionsService = ref.read(cloudFunctionsServiceProvider);
    final voices = cloudFunctionsService.getAvailableVoices();

    final selectedVoice = voices.firstWhere(
      (v) => v.id == selectedVoiceId,
      orElse: () => voices.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voice',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedVoice.id,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              items: voices.map((voice) {
                return DropdownMenuItem<String>(
                  value: voice.id,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        voice.name,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        voice.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onVoiceSelected(newValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Preview voices at elevenlabs.io to hear samples',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// Compact version for use in dialogs or smaller spaces
class VoiceSelectorCompact extends ConsumerWidget {
  final String? selectedVoiceId;
  final ValueChanged<String> onVoiceSelected;

  const VoiceSelectorCompact({
    super.key,
    this.selectedVoiceId,
    required this.onVoiceSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cloudFunctionsService = ref.read(cloudFunctionsServiceProvider);
    final voices = cloudFunctionsService.getAvailableVoices();

    final selectedVoice = voices.firstWhere(
      (v) => v.id == selectedVoiceId,
      orElse: () => voices.first,
    );

    return DropdownButton<String>(
      value: selectedVoice.id,
      isExpanded: true,
      items: voices.map((voice) {
        return DropdownMenuItem<String>(
          value: voice.id,
          child: Text('${voice.name} - ${voice.description}'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onVoiceSelected(newValue);
        }
      },
    );
  }
}
