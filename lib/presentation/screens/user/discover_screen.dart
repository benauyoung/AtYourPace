import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/tour_providers.dart';
import '../../widgets/tour/tour_card.dart';

/// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected category filter provider
final selectedCategoryProvider = StateProvider<TourCategory?>((ref) => null);

/// Selected tour type filter provider
final selectedTourTypeProvider = StateProvider<TourType?>((ref) => null);

/// Filtered tours provider
final filteredToursProvider = FutureProvider<List<TourModel>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedTourType = ref.watch(selectedTourTypeProvider);

  // Get all featured tours (in a real app, this would be a proper search)
  final tours = await ref.watch(featuredToursProvider.future);

  return tours.where((tour) {
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final matchesCity = tour.city?.toLowerCase().contains(searchQuery) ?? false;
      final matchesCountry = tour.country?.toLowerCase().contains(searchQuery) ?? false;
      final matchesCreator = tour.creatorName.toLowerCase().contains(searchQuery);
      if (!matchesCity && !matchesCountry && !matchesCreator) {
        return false;
      }
    }

    // Filter by category
    if (selectedCategory != null && tour.category != selectedCategory) {
      return false;
    }

    // Filter by tour type
    if (selectedTourType != null && tour.tourType != selectedTourType) {
      return false;
    }

    return true;
  }).toList();
});

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTours = ref.watch(filteredToursProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedTourType = ref.watch(selectedTourTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
            tooltip: 'Toggle filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tours by city, country, or creator...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: context.colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Filters section
          if (_showFilters) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: context.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: selectedCategory == null,
                          onSelected: (_) {
                            ref.read(selectedCategoryProvider.notifier).state = null;
                          },
                        ),
                        const SizedBox(width: 8),
                        ...TourCategory.values.map((category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            avatar: Icon(category.icon, size: 18),
                            label: Text(category.displayName),
                            selected: selectedCategory == category,
                            onSelected: (selected) {
                              ref.read(selectedCategoryProvider.notifier).state =
                                  selected ? category : null;
                            },
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tour Type',
                    style: context.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: selectedTourType == null,
                        onSelected: (_) {
                          ref.read(selectedTourTypeProvider.notifier).state = null;
                        },
                      ),
                      const SizedBox(width: 8),
                      ...TourType.values.map((type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Icon(type.icon, size: 18),
                          label: Text(type.displayName),
                          selected: selectedTourType == type,
                          onSelected: (selected) {
                            ref.read(selectedTourTypeProvider.notifier).state =
                                selected ? type : null;
                          },
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
          ],

          // Active filters display
          if (selectedCategory != null || selectedTourType != null || _searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Active filters:',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_searchController.text.isNotEmpty)
                    Chip(
                      label: Text('"${_searchController.text}"'),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  if (selectedCategory != null) ...[
                    const SizedBox(width: 4),
                    Chip(
                      avatar: Icon(selectedCategory.icon, size: 16),
                      label: Text(selectedCategory.displayName),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        ref.read(selectedCategoryProvider.notifier).state = null;
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  if (selectedTourType != null) ...[
                    const SizedBox(width: 4),
                    Chip(
                      avatar: Icon(selectedTourType.icon, size: 16),
                      label: Text(selectedTourType.displayName),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        ref.read(selectedTourTypeProvider.notifier).state = null;
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      ref.read(selectedTourTypeProvider.notifier).state = null;
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),

          // Results
          Expanded(
            child: filteredTours.when(
              data: (tours) {
                if (tours.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: context.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tours found',
                          style: context.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedCategoryProvider.notifier).state = null;
                            ref.read(selectedTourTypeProvider.notifier).state = null;
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tours.length,
                  itemBuilder: (context, index) {
                    final tour = tours[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TourCard(
                        tour: tour,
                        onTap: () => context.go(RouteNames.tourDetailsPath(tour.id)),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(filteredToursProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
