import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/tour_model.dart';
import 'providers/tour_manager_provider.dart';
import 'widgets/tour_card_compact.dart';
import 'widgets/tour_card_grid.dart';
import 'widgets/tour_manager_filters.dart';

/// Main tour manager screen for creators and admins
class TourManagerScreen extends ConsumerStatefulWidget {
  final String? userId;
  final bool isAdmin;

  const TourManagerScreen({
    super.key,
    this.userId,
    this.isAdmin = false,
  });

  @override
  ConsumerState<TourManagerScreen> createState() => _TourManagerScreenState();
}

class _TourManagerScreenState extends ConsumerState<TourManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params = (userId: widget.userId, isAdmin: widget.isAdmin);
    final state = ref.watch(tourManagerProvider(params));
    final notifier = ref.read(tourManagerProvider(params).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? 'All Tours' : 'My Tours'),
        actions: [
          // View mode toggle
          SegmentedButton<TourManagerViewMode>(
            segments: const [
              ButtonSegment(
                value: TourManagerViewMode.list,
                icon: Icon(Icons.view_list),
              ),
              ButtonSegment(
                value: TourManagerViewMode.grid,
                icon: Icon(Icons.grid_view),
              ),
            ],
            selected: {state.viewMode},
            onSelectionChanged: (selection) {
              notifier.setViewMode(selection.first);
            },
            showSelectedIcon: false,
          ),
          const SizedBox(width: 8),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading ? null : notifier.refresh,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TourStatusFilters(
            selectedStatus: state.filters.status,
            onStatusChanged: notifier.filterByStatus,
            draftCount: state.draftCount,
            pendingCount: state.pendingCount,
            approvedCount: state.approvedCount,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filters panel
          TourManagerFiltersPanel(
            filters: state.filters,
            onStatusChanged: notifier.filterByStatus,
            onCategoryChanged: notifier.filterByCategory,
            onSearchChanged: notifier.search,
            onClearFilters: notifier.clearFilters,
            isAdmin: widget.isAdmin,
            onShowOnlyMineChanged: (_) => notifier.toggleShowOnlyMine(),
          ),

          // Error banner
          if (state.error != null)
            MaterialBanner(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              leading: Icon(
                Icons.error,
                color: Theme.of(context).colorScheme.error,
              ),
              actions: [
                TextButton(
                  onPressed: notifier.clearError,
                  child: const Text('Dismiss'),
                ),
              ],
            ),

          // Tour list/grid
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.tours.isEmpty
                    ? _buildEmptyState(context, state)
                    : _buildTourList(context, state, notifier),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createNewTour(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Tour'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, TourManagerState state) {
    final hasFilters = state.filters.hasFilters;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_alt_off : Icons.tour,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters ? 'No Tours Match Filters' : 'No Tours Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              hasFilters
                  ? 'Try adjusting your filters or search query'
                  : 'Create your first tour to get started',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: () {
                  final params = (userId: widget.userId, isAdmin: widget.isAdmin);
                  ref.read(tourManagerProvider(params).notifier).clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
              )
            else
              FilledButton.icon(
                onPressed: () => _createNewTour(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Tour'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourList(
    BuildContext context,
    TourManagerState state,
    TourManagerNotifier notifier,
  ) {
    // Filter tours by search query locally
    var tours = state.tours;
    if (state.filters.searchQuery != null &&
        state.filters.searchQuery!.isNotEmpty) {
      final query = state.filters.searchQuery!.toLowerCase();
      tours = tours
          .where((t) =>
              (t.city?.toLowerCase().contains(query) ?? false) ||
              t.category.displayName.toLowerCase().contains(query))
          .toList();
    }

    if (state.viewMode == TourManagerViewMode.grid) {
      return _buildGridView(context, tours, notifier, state);
    }

    return _buildListView(context, tours, notifier, state);
  }

  Widget _buildListView(
    BuildContext context,
    List<TourModel> tours,
    TourManagerNotifier notifier,
    TourManagerState state,
  ) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tours.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tours.length) {
            // Load more indicator
            if (!state.isLoadingMore) {
              notifier.loadMore();
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final tour = tours[index];
          return TourCardCompact(
            tour: tour,
            onTap: () => _openTour(context, tour),
            onEdit: () => _editTour(context, tour),
            onDelete: () => _confirmDelete(context, tour, notifier),
            onDuplicate: () => _duplicateTour(context, tour, notifier),
            onViewAnalytics: () => _viewAnalytics(context, tour),
          );
        },
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    List<TourModel> tours,
    TourManagerNotifier notifier,
    TourManagerState state,
  ) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 320,
          childAspectRatio: 0.8,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: tours.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tours.length) {
            if (!state.isLoadingMore) {
              notifier.loadMore();
            }
            return const Center(child: CircularProgressIndicator());
          }

          final tour = tours[index];
          return TourCardGrid(
            tour: tour,
            onTap: () => _openTour(context, tour),
            onEdit: () => _editTour(context, tour),
            onDelete: () => _confirmDelete(context, tour, notifier),
          );
        },
      ),
    );
  }

  void _createNewTour(BuildContext context) {
    // TODO: Navigate to tour editor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to create tour'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openTour(BuildContext context, TourModel tour) {
    // TODO: Navigate to tour details/editor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open tour: ${tour.city ?? 'Untitled Tour'}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editTour(BuildContext context, TourModel tour) {
    // TODO: Navigate to tour editor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit tour: ${tour.city ?? 'Untitled Tour'}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TourModel tour,
    TourManagerNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tour?'),
        content: Text(
          'Are you sure you want to delete "${tour.city ?? 'Untitled Tour'}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await notifier.deleteTour(tour.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Tour deleted' : 'Failed to delete tour',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
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

  void _duplicateTour(
    BuildContext context,
    TourModel tour,
    TourManagerNotifier notifier,
  ) async {
    final newId = await notifier.duplicateTour(tour.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newId != null ? 'Tour duplicated' : 'Failed to duplicate tour',
          ),
          behavior: SnackBarBehavior.floating,
          action: newId != null
              ? SnackBarAction(
                  label: 'Edit',
                  onPressed: () {
                    // TODO: Navigate to edit duplicated tour
                  },
                )
              : null,
        ),
      );
    }
  }

  void _viewAnalytics(BuildContext context, TourModel tour) {
    // TODO: Navigate to analytics
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View analytics for: ${tour.city ?? 'Untitled Tour'}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
