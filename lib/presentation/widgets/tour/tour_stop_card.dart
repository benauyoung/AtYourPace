import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/theme/colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../data/models/stop_model.dart';
import '../../../../services/audio_service.dart';

class TourStopCard extends ConsumerWidget {
  final StopModel stop;
  final int index;
  final VoidCallback? onTap;

  const TourStopCard({super.key, required this.stop, required this.index, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to audio state to update UI
    final audioState = ref.watch(audioStateProvider).valueOrNull ?? AudioState.idle;
    final currentAudioId = ref.watch(audioServiceProvider).currentAudioId;

    final isPlayingThisStop = audioState == AudioState.playing && currentAudioId == stop.id;
    final isPausedThisStop = audioState == AudioState.paused && currentAudioId == stop.id;
    final hasAudio = stop.media.audioUrl != null && stop.media.audioUrl!.isNotEmpty;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with index badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child:
                        stop.media.images.isNotEmpty
                            ? Image.network(
                              stop.media.images.first.url,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: context.colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.image_not_supported),
                                  ),
                            )
                            : Container(
                              color: context.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.landscape, size: 32),
                            ),
                  ),
                ),
                // Index badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Play/Pause Button
                if (hasAudio)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        final audioService = ref.read(audioServiceProvider);
                        if (isPlayingThisStop) {
                          await audioService.pause();
                        } else if (isPausedThisStop) {
                          await audioService.play();
                        } else {
                          await audioService.playUrl(stop.media.audioUrl!, audioId: stop.id);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPlayingThisStop ? Icons.pause : Icons.play_arrow,
                          size: 20,
                          color: context.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${index + 1}. ${stop.name}',
              style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
