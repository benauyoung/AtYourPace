import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../../data/models/tour_version_model.dart';
import '../../../services/download_manager.dart';
import '../../providers/tour_providers.dart';
import '../../widgets/tour/download_button.dart';
import '../../widgets/tour/tour_reviews_section.dart';

class TourDetailsScreen extends ConsumerWidget {
  final String tourId;

  const TourDetailsScreen({super.key, required this.tourId});

  void _shareTour(BuildContext context, TourModel tour) {
    final location = tour.city != null && tour.country != null
        ? '${tour.city}, ${tour.country}'
        : tour.city ?? tour.country ?? 'an amazing location';

    final shareText = '''
Check out this ${tour.category.displayName.toLowerCase()} tour in $location!

${tour.stats.averageRating > 0 ? '${tour.stats.averageRating.toStringAsFixed(1)} stars from ${tour.stats.totalRatings} reviews' : ''}

Download the AYP Tour Guide app to explore it yourself!
https://ayp.tours/${tour.slug ?? tour.id}
''';

    Share.share(shareText.trim());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourByIdProvider(tourId));
    final isDownloaded = ref.watch(isTourDownloadedProvider(tourId));

    return Scaffold(
      body: tourAsync.when(
        data: (tour) {
          if (tour == null) {
            return const Center(child: Text('Tour not found'));
          }

          // Get the version ID
          final versionId = tour.liveVersionId ?? tour.draftVersionId;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                actions: [
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareTour(context, tour),
                    tooltip: 'Share tour',
                  ),
                  // Download indicator in app bar
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TourDownloadButton(
                      tourId: tourId,
                      showLabel: false,
                      size: 24,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(tour.city ?? 'Tour'),
                  background: Container(
                    color: context.colorScheme.primaryContainer,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            tour.tourType.name == 'walking'
                                ? Icons.directions_walk
                                : Icons.directions_car,
                            size: 80,
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        // Offline indicator
                        if (isDownloaded)
                          Positioned(
                            right: 16,
                            bottom: 60,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.offline_pin,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Available Offline',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Chip(label: Text(tour.category.displayName)),
                          const SizedBox(width: 8),
                          Chip(label: Text(tour.tourType.displayName)),
                          const Spacer(),
                          DownloadIndicator(tourId: tourId),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'by ${tour.creatorName}',
                        style: context.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Rating: ${tour.stats.averageRating.toStringAsFixed(1)} stars from ${tour.stats.totalRatings} reviews. ${tour.stats.totalPlays} plays',
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20, semanticLabel: 'Rating'),
                            const SizedBox(width: 4),
                            Text(
                              '${tour.stats.averageRating.toStringAsFixed(1)} (${tour.stats.totalRatings} reviews)',
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.play_arrow, size: 20, semanticLabel: 'Plays'),
                            const SizedBox(width: 4),
                            Text(
                              '${tour.stats.totalPlays} plays',
                              style: context.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Load version details
                      _TourVersionDetails(
                        tourId: tourId,
                        versionId: versionId,
                        stats: tour.stats,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: tourAsync.when(
        data: (tour) => tour != null
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Start Tour button (primary action)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            context.push(RouteNames.tourPlaybackPath(tourId));
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Tour'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Download button (secondary action)
                      SizedBox(
                        width: double.infinity,
                        child: TourDownloadButton(
                          tourId: tourId,
                          showLabel: true,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}

/// Widget to display tour version details
class _TourVersionDetails extends ConsumerWidget {
  final String tourId;
  final String versionId;
  final TourStats stats;

  const _TourVersionDetails({
    required this.tourId,
    required this.versionId,
    required this.stats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(
      tourVersionProvider((tourId: tourId, versionId: versionId)),
    );
    final stopsAsync = ref.watch(
      stopsProvider((tourId: tourId, versionId: versionId)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        versionAsync.when(
          data: (version) {
            if (version == null) {
              return const Text('Version not found');
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  version.title,
                  style: context.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  version.description,
                  style: context.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                // Tour info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (version.duration != null)
                      _InfoChip(
                        icon: Icons.access_time,
                        label: version.duration!,
                      ),
                    if (version.distance != null)
                      _InfoChip(
                        icon: Icons.straighten,
                        label: version.distance!,
                      ),
                    _InfoChip(
                      icon: Icons.terrain,
                      label: version.difficulty.displayName,
                    ),
                    if (version.languages.isNotEmpty)
                      _InfoChip(
                        icon: Icons.language,
                        label: version.languages.join(', '),
                      ),
                  ],
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Text('Error loading version: $error'),
        ),
        const SizedBox(height: 24),
        // Stops preview
        Text(
          'Stops',
          style: context.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        stopsAsync.when(
          data: (stops) {
            if (stops.isEmpty) {
              return const Text('No stops in this tour');
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stops.length,
              itemBuilder: (context, index) {
                final stop = stops[index];
                return Card(
                  key: ValueKey(stop.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: context.colorScheme.primaryContainer,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: context.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(stop.name),
                    subtitle: stop.description.isNotEmpty
                        ? Text(
                            stop.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: stop.hasAudio
                        ? Semantics(
                            label: 'Has audio narration',
                            child: const Icon(Icons.audiotrack, size: 20),
                          )
                        : null,
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Text('Error loading stops: $error'),
        ),
        const SizedBox(height: 32),
        // Reviews section
        TourReviewsSection(tourId: tourId, stats: stats),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
