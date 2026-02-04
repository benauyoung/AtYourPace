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
import '../../widgets/tour/creator_pile.dart';
import '../../widgets/tour/tour_reviews_section.dart';
import '../../widgets/tour/tour_stop_card.dart';

class TourDetailsScreen extends ConsumerWidget {
  final String tourId;

  const TourDetailsScreen({super.key, required this.tourId});

  void _shareTour(BuildContext context, TourModel tour) {
    final location =
        tour.city != null && tour.country != null
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
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => _shareTour(context, tour),
                  ),
                  IconButton(
                    icon:
                        isDownloaded
                            ? const Icon(Icons.bookmark)
                            : const Icon(Icons.bookmark_border),
                    onPressed: () {}, // Todo: Implement bookmark
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(tour.city ?? 'Tour'),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Map Placeholder (in real app, this should be a static map image or MapView)
                      Container(
                        color: Colors.blue[100],
                        child: Center(
                          child: Icon(
                            tour.tourType.name == 'walking'
                                ? Icons.directions_walk
                                : Icons.directions_car,
                            size: 80,
                            color: Colors.blue[300],
                          ),
                        ),
                      ),
                      // Explore Tour Map Button (Overlay)
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FilledButton.icon(
                          onPressed: () => context.push(RouteNames.tourPlaybackPath(tourId)),
                          icon: const Icon(Icons.map, size: 16),
                          label: const Text('Explore Tour Map'),
                          style: FilledButton.styleFrom(
                            backgroundColor: context.colorScheme.surface,
                            foregroundColor: context.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        // Need a robust title logic, falling back to city or category if missing
                        tour.city ?? 'Amazing Tour',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // About the Tour
                      Text(
                        'About the Tour',
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      _TourVersionDescription(tourId: tourId, versionId: versionId),
                      const SizedBox(height: 16),

                      // Metrics Grid
                      _TourVersionMetrics(tourId: tourId, versionId: versionId),

                      const SizedBox(height: 24),
                      // Meet the Creators
                      Text(
                        'Meet the creators',
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const CreatorPile(imageUrls: []), // TODO: Add creator images to model

                      const SizedBox(height: 24),

                      // Load stops
                      Text(
                        'Tour Stops',
                        style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _TourStopsList(tourId: tourId, versionId: versionId),

                      const SizedBox(height: 32),
                      // Reviews section
                      TourReviewsSection(tourId: tourId, stats: tour.stats),
                      const SizedBox(height: 100), // Spacing for bottom bar
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
      bottomSheet: tourAsync.when(
        data:
            (tour) =>
                tour != null
                    ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "Read before you go" Notification
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: context.colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_outlined,
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Read this before you go',
                                      style: context.textTheme.bodyMedium,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                // Download Progress/Check
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC4EED0),
                                    /* Light Green */
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      color: Color(0xFF1E2F36),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Begin Tour Button
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () {
                                      context.push(RouteNames.tourPlaybackPath(tourId));
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF90F6D7),
                                      /* Teal Custom Color */
                                      foregroundColor: const Color(0xFF1E2F36),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    child: const Text('Begin Tour'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Download Complete',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
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

class _TourVersionDescription extends ConsumerWidget {
  final String tourId;
  final String versionId;

  const _TourVersionDescription({required this.tourId, required this.versionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(tourVersionProvider((tourId: tourId, versionId: versionId)));

    return versionAsync.when(
      data:
          (version) => Text(
            version?.description ?? 'No description available.',
            style: context.textTheme.bodyLarge,
          ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _TourVersionMetrics extends ConsumerWidget {
  final String tourId;
  final String versionId;

  const _TourVersionMetrics({required this.tourId, required this.versionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(tourVersionProvider((tourId: tourId, versionId: versionId)));
    final stopsAsync = ref.watch(stopsProvider((tourId: tourId, versionId: versionId)));

    return versionAsync.when(
      data: (version) {
        if (version == null) return const SizedBox.shrink();

        return stopsAsync.when(
          data: (stops) {
            final audioStopsCount = stops.where((s) => s.hasAudio).length;

            return Column(
              children: [
                if (audioStopsCount > 0)
                  _MetricItem(
                    icon: Icons.volume_up_outlined,
                    title: '$audioStopsCount Audio Points',
                    subtitle: 'Listen to stories at each stop.',
                  ),
                if (audioStopsCount > 0) const SizedBox(height: 16),

                if (version.duration != null && version.duration!.isNotEmpty)
                  _MetricItem(
                    icon: Icons.access_time,
                    title: version.duration!,
                    subtitle: 'Estimated time to complete.',
                  ),
                if (version.duration != null && version.duration!.isNotEmpty)
                  const SizedBox(height: 16),

                _MetricItem(
                  icon: Icons.terrain,
                  title: version.difficulty.displayName,
                  subtitle: 'Tour difficulty level.',
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MetricItem({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: const Color(0xFF1E2F36)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TourStopsList extends ConsumerWidget {
  final String tourId;
  final String versionId;

  const _TourStopsList({required this.tourId, required this.versionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopsAsync = ref.watch(stopsProvider((tourId: tourId, versionId: versionId)));

    return stopsAsync.when(
      data: (stops) {
        if (stops.isEmpty) return const Text('No stops in this tour');

        return SizedBox(
          height: 180, // Height for card + text
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stops.length,
            itemBuilder: (context, index) {
              return TourStopCard(stop: stops[index], index: index);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text('Error loading stops: $error'),
    );
  }
}
