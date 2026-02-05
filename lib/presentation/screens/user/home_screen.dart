import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/recommendations_provider.dart';
import '../../providers/tour_providers.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/skeleton_loader.dart';
import 'discover_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final featuredTours = ref.watch(featuredToursProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user?.displayName.split(' ').first ?? 'Explorer'}!',
              style: context.textTheme.titleMedium,
            ),
            Text(
              'Ready for your next adventure?',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(RouteNames.discover),
            tooltip: 'Search',
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => context.go(RouteNames.favorites),
                tooltip: 'Favorites',
              ),
              // Badge showing favorites count
              Positioned(
                right: 4,
                top: 4,
                child: Consumer(
                  builder: (context, ref, _) {
                    final count = ref.watch(favoritesCountProvider);
                    if (count == 0) return const SizedBox();
                    return Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        count > 9 ? '9+' : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredToursProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Featured tours section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Tours',
                      style: context.textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.discover),
                      child: const Text('See All'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              featuredTours.when(
                data: (tours) {
                  if (tours.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No featured tours available'),
                    );
                  }
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tours.length,
                      itemBuilder: (context, index) {
                        final tour = tours[index];
                        return _FeaturedTourCard(
                          key: ValueKey(tour.id),
                          tour: tour,
                          onTap: () => context.push(
                            RouteNames.tourDetailsPath(tour.id),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 3,
                    itemBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 280,
                        child: TourCardSkeleton(),
                      ),
                    ),
                  ),
                ),
                error: (error, _) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(featuredToursProvider),
                  compact: true,
                ),
              ),
              const SizedBox(height: 24),

              // Recommended for you section
              _RecommendedSection(),
              const SizedBox(height: 24),

              // Categories section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Browse by Category',
                  style: context.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: TourCategory.values.map((category) {
                    return _CategoryCard(
                      key: ValueKey(category),
                      category: category,
                      onTap: () {
                        // Set the category filter and navigate to discover
                        ref.read(selectedCategoryProvider.notifier).state = category;
                        context.go(RouteNames.discover);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Quick actions for creators
              if (user?.isCreator ?? false) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Creator Tools',
                    style: context.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.add_box),
                      title: const Text('Create New Tour'),
                      subtitle: const Text('Start building your next adventure'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.go(RouteNames.createTour),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.dashboard),
                      title: const Text('Creator Dashboard'),
                      subtitle: const Text('Manage your tours'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.go(RouteNames.creatorDashboard),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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

class _FeaturedTourCard extends ConsumerWidget {
  final TourModel tour;
  final VoidCallback onTap;

  const _FeaturedTourCard({
    super.key,
    required this.tour,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionId = tour.liveVersionId ?? tour.draftVersionId;
    final versionAsync = ref.watch(
      tourVersionProvider((tourId: tour.id, versionId: versionId)),
    );
    final coverImageUrl = versionAsync.valueOrNull?.coverImageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover image or gradient placeholder
              SizedBox(
                height: 120,
                width: double.infinity,
                child: coverImageUrl != null && coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: coverImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildGradientPlaceholder(),
                        errorWidget: (_, __, ___) => _buildGradientPlaceholder(),
                      )
                    : _buildGradientPlaceholder(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tour.category.displayName,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                            semanticLabel: 'Rating',
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tour.stats.averageRating.toStringAsFixed(1),
                            style: context.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          tour.displayName,
                          style: context.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'by ${tour.creatorName}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildGradientPlaceholder() {
    final colors = _categoryGradientColors(tour.category);
    return Container(
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
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final TourCategory category;
  final VoidCallback onTap;

  const _CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 32,
                color: context.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                category.displayName,
                style: context.textTheme.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(TourCategory category) {
    switch (category) {
      case TourCategory.history:
        return Icons.account_balance;
      case TourCategory.nature:
        return Icons.park;
      case TourCategory.ghost:
        return Icons.nightlight;
      case TourCategory.food:
        return Icons.restaurant;
      case TourCategory.art:
        return Icons.palette;
      case TourCategory.architecture:
        return Icons.location_city;
      case TourCategory.other:
        return Icons.category;
    }
  }
}

class _RecommendedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendedToursProvider);

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recommended for You',
                    style: context.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  return _RecommendedTourCard(
                    key: ValueKey(rec.tour.id),
                    recommendation: rec,
                    onTap: () => context.push(
                      RouteNames.tourDetailsPath(rec.tour.id),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RecommendedTourCard extends ConsumerWidget {
  final TourRecommendation recommendation;
  final VoidCallback onTap;

  const _RecommendedTourCard({
    super.key,
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tour = recommendation.tour;
    final versionId = tour.liveVersionId ?? tour.draftVersionId;
    final versionAsync = ref.watch(
      tourVersionProvider((tourId: tour.id, versionId: versionId)),
    );
    final coverImageUrl = versionAsync.valueOrNull?.coverImageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image or gradient placeholder
              SizedBox(
                height: 80,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: coverImageUrl != null && coverImageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: coverImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => _buildGradientPlaceholder(tour),
                              errorWidget: (_, __, ___) => _buildGradientPlaceholder(tour),
                            )
                          : _buildGradientPlaceholder(tour),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(
                              'For You',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tour.displayName,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (recommendation.reasons.isNotEmpty)
                        Text(
                          recommendation.reasons.first,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          if (tour.stats.averageRating > 0) ...[
                            const Icon(Icons.star, size: 12, color: Colors.amber, semanticLabel: 'Rating'),
                            const SizedBox(width: 2),
                            Text(
                              tour.stats.averageRating.toStringAsFixed(1),
                              style: context.textTheme.labelSmall,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            tour.tourType.icon,
                            size: 12,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            tour.tourType.displayName,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
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

  Widget _buildGradientPlaceholder(TourModel tour) {
    final colors = _categoryGradientColors(tour.category);
    return Container(
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
          size: 36,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
