import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../../data/models/tour_version_model.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/tour_providers.dart';

List<Color> _categoryGradientColors(TourCategory category) {
  switch (category) {
    case TourCategory.history:
      return [Colors.amber.shade300, Colors.amber.shade700];
    case TourCategory.nature:
      return [Colors.green.shade300, Colors.green.shade700];
    case TourCategory.ghost:
      return [Colors.grey.shade600, Colors.grey.shade900];
    case TourCategory.food:
      return [Colors.orange.shade300, Colors.orange.shade700];
    case TourCategory.art:
      return [Colors.purple.shade300, Colors.purple.shade700];
    case TourCategory.architecture:
      return [Colors.blue.shade300, Colors.blue.shade700];
    case TourCategory.other:
      return [Colors.blueGrey.shade300, Colors.blueGrey.shade600];
  }
}

/// A card widget for displaying tour information
class TourCard extends ConsumerWidget {
  final TourModel tour;
  final VoidCallback? onTap;
  final bool showStats;
  final bool showFavoriteButton;

  const TourCard({
    super.key,
    required this.tour,
    this.onTap,
    this.showStats = true,
    this.showFavoriteButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the live version if available, otherwise draft
    final versionId = tour.liveVersionId ?? tour.draftVersionId;
    final versionAsync = ref.watch(
      tourVersionProvider((tourId: tour.id, versionId: versionId)),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            versionAsync.when(
              data: (version) => _buildCoverImage(context, version, ref),
              loading: () => _buildCoverImagePlaceholder(context),
              error: (_, __) => _buildCoverImagePlaceholder(context),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  versionAsync.when(
                    data: (version) => Text(
                      version?.title ?? tour.city ?? 'Untitled Tour',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    loading: () => Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    error: (_, __) => Text(
                      tour.city ?? 'Untitled Tour',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location and creator
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${tour.city ?? "Unknown"}, ${tour.country ?? ""}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'by ${tour.creatorName}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tags and stats row
                  Row(
                    children: [
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tour.category.icon,
                              size: 14,
                              color: context.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.category.displayName,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tour type chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              tour.tourType.icon,
                              size: 14,
                              color: context.colorScheme.onSecondaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.tourType.displayName,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (showStats) ...[
                        const Spacer(),

                        // Rating
                        if (tour.stats.totalRatings > 0) ...[
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            tour.stats.averageRating.toStringAsFixed(1),
                            style: context.textTheme.labelMedium,
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Play count
                        Icon(
                          Icons.play_arrow,
                          size: 16,
                          color: context.colorScheme.onSurfaceVariant,
                          semanticLabel: 'Plays',
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(tour.stats.totalPlays),
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context, TourVersionModel? version, WidgetRef ref) {
    final imageUrl = version?.coverImageUrl;
    debugPrint('[TourCard] Tour ${tour.id}: coverImageUrl=${imageUrl ?? 'null'}, version=${version?.id ?? 'null'}');
    final isFavorited = ref.watch(isTourFavoritedProvider(tour.id));

    Widget coverContent;
    if (imageUrl == null || imageUrl.isEmpty) {
      coverContent = _buildCoverImagePlaceholder(context);
    } else {
      coverContent = AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: context.colorScheme.surfaceContainerHighest,
            child: Center(
              child: CircularProgressIndicator(
                color: context.colorScheme.primary,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => _buildCoverImagePlaceholder(context),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          coverContent,

          // Featured badge
          if (tour.featured)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Favorite button
          if (showFavoriteButton)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black54,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    ref.read(favoriteTourIdsProvider.notifier).toggleFavorite(tour.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isFavorited ? Colors.red : Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // Duration badge
          if (version?.duration != null)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      version!.duration!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoverImagePlaceholder(BuildContext context) {
    final colors = _categoryGradientColors(tour.category);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Center(
          child: Icon(
            tour.category.icon,
            size: 48,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// Compact horizontal tour card for lists
class CompactTourCard extends ConsumerWidget {
  final TourModel tour;
  final VoidCallback? onTap;

  const CompactTourCard({
    super.key,
    required this.tour,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionId = tour.liveVersionId ?? tour.draftVersionId;
    final versionAsync = ref.watch(
      tourVersionProvider((tourId: tour.id, versionId: versionId)),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              // Image
              versionAsync.when(
                data: (version) {
                  final imageUrl = version?.coverImageUrl;
                  if (imageUrl != null && imageUrl.isNotEmpty) {
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 100,
                        color: context.colorScheme.surfaceContainerHighest,
                      ),
                      errorWidget: (_, __, ___) => _buildImagePlaceholder(context),
                    );
                  }
                  return _buildImagePlaceholder(context);
                },
                loading: () => Container(
                  width: 100,
                  color: context.colorScheme.surfaceContainerHighest,
                ),
                error: (_, __) => _buildImagePlaceholder(context),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      versionAsync.when(
                        data: (version) => Text(
                          version?.title ?? tour.city ?? 'Untitled',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        loading: () => Container(
                          height: 16,
                          width: 100,
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        error: (_, __) => Text(
                          tour.city ?? 'Untitled',
                          style: context.textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tour.creatorName,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            tour.category.icon,
                            size: 14,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tour.category.displayName,
                            style: context.textTheme.labelSmall,
                          ),
                          const Spacer(),
                          if (tour.stats.totalRatings > 0) ...[
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              tour.stats.averageRating.toStringAsFixed(1),
                              style: context.textTheme.labelSmall,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final colors = _categoryGradientColors(tour.category);
    return Container(
      width: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Icon(
        tour.category.icon,
        size: 32,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }
}
