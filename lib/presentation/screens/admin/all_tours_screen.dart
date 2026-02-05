import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/tour_providers.dart';

class AllToursScreen extends ConsumerStatefulWidget {
  const AllToursScreen({super.key});

  @override
  ConsumerState<AllToursScreen> createState() => _AllToursScreenState();
}

class _AllToursScreenState extends ConsumerState<AllToursScreen> {
  String _searchQuery = '';
  TourStatus? _statusFilter;
  TourCategory? _categoryFilter;
  bool _showFeaturedOnly = false;

  @override
  Widget build(BuildContext context) {
    final toursAsync = ref.watch(allToursAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allToursAdminProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Search field
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Status filter
                DropdownButton<TourStatus?>(
                  value: _statusFilter,
                  hint: const Text('Status'),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...TourStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _statusFilter = value);
                  },
                ),
                const SizedBox(width: 12),

                // Category filter
                DropdownButton<TourCategory?>(
                  value: _categoryFilter,
                  hint: const Text('Category'),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...TourCategory.values.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _categoryFilter = value);
                  },
                ),
                const SizedBox(width: 12),

                // Featured only toggle
                FilterChip(
                  label: const Text('Featured'),
                  selected: _showFeaturedOnly,
                  onSelected: (selected) {
                    setState(() => _showFeaturedOnly = selected);
                  },
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: toursAsync.when(
              data: (tours) => _buildStatsRow(tours),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),

          // Tours list
          Expanded(
            child: toursAsync.when(
              data: (tours) {
                final filteredTours = _filterTours(tours);

                if (filteredTours.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.tour_outlined,
                          size: 64,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tours found',
                          style: context.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTours.length,
                  itemBuilder: (context, index) {
                    final tour = filteredTours[index];
                    return _TourAdminCard(
                      key: ValueKey(tour.id),
                      tour: tour,
                      onTap: () => _showTourDetails(tour),
                      onToggleFeatured: () => _toggleFeatured(tour),
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
                      onPressed: () => ref.invalidate(allToursAdminProvider),
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

  Widget _buildStatsRow(List<TourModel> tours) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _MiniStatChip(
            label: 'Total',
            value: tours.length.toString(),
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _MiniStatChip(
            label: 'Live',
            value: tours.where((t) => t.status == TourStatus.approved).length.toString(),
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _MiniStatChip(
            label: 'Pending',
            value: tours.where((t) => t.status == TourStatus.pendingReview).length.toString(),
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _MiniStatChip(
            label: 'Draft',
            value: tours.where((t) => t.status == TourStatus.draft).length.toString(),
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          _MiniStatChip(
            label: 'Featured',
            value: tours.where((t) => t.featured).length.toString(),
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  List<TourModel> _filterTours(List<TourModel> tours) {
    return tours.where((tour) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        // Note: We'll need to join with version data for title search in real impl
        final matchesSearch = tour.creatorName.toLowerCase().contains(_searchQuery) ||
            tour.city?.toLowerCase().contains(_searchQuery) == true ||
            tour.country?.toLowerCase().contains(_searchQuery) == true;
        if (!matchesSearch) return false;
      }

      // Status filter
      if (_statusFilter != null && tour.status != _statusFilter) {
        return false;
      }

      // Category filter
      if (_categoryFilter != null && tour.category != _categoryFilter) {
        return false;
      }

      // Featured filter
      if (_showFeaturedOnly && !tour.featured) {
        return false;
      }

      return true;
    }).toList();
  }

  void _showTourDetails(TourModel tour) {
    if (tour.status == TourStatus.pendingReview) {
      // Go to review screen
      context.go(RouteNames.reviewTourPath(tour.id));
    } else {
      // Show tour details dialog
      showDialog(
        context: context,
        builder: (context) => _TourDetailsDialog(tour: tour),
      );
    }
  }

  Future<void> _toggleFeatured(TourModel tour) async {
    final action = tour.featured ? 'unfeature' : 'feature';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${tour.featured ? 'Unfeature' : 'Feature'} Tour?'),
        content: Text(
          'Are you sure you want to $action this tour?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      if (AppConfig.demoMode) {
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        // Call AdminService to toggle featured status
        final adminService = ref.read(adminServiceProvider);
        await adminService.featureTour(tour.id, !tour.featured);
      }

      if (mounted) {
        context.showSuccessSnackBar(
          tour.featured ? 'Tour unfeatured' : 'Tour featured',
        );
        ref.invalidate(allToursAdminProvider);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to update tour: $e');
      }
    }
  }
}

class _MiniStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TourAdminCard extends StatelessWidget {
  final TourModel tour;
  final VoidCallback onTap;
  final VoidCallback onToggleFeatured;

  const _TourAdminCard({
    super.key,
    required this.tour,
    required this.onTap,
    required this.onToggleFeatured,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(tour.status),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),

              // Tour info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          tour.category.icon,
                          size: 18,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tour.displayName,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (tour.featured)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${tour.creatorName}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _StatusBadge(status: tour.status),
                        const SizedBox(width: 8),
                        Text(
                          '${tour.category.displayName} \u2022 ${tour.tourType.displayName}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Stats column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_arrow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        tour.stats.totalPlays.toString(),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        tour.stats.totalDownloads.toString(),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        tour.stats.averageRating.toStringAsFixed(1),
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),

              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'feature') {
                    onToggleFeatured();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'feature',
                    child: Row(
                      children: [
                        Icon(
                          tour.featured ? Icons.star_border : Icons.star,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(tour.featured ? 'Unfeature' : 'Feature'),
                      ],
                    ),
                  ),
                  if (tour.status == TourStatus.pendingReview)
                    const PopupMenuItem(
                      value: 'review',
                      child: Row(
                        children: [
                          Icon(Icons.rate_review, size: 20),
                          SizedBox(width: 12),
                          Text('Review'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TourStatus status) {
    switch (status) {
      case TourStatus.draft:
        return Colors.grey;
      case TourStatus.pendingReview:
        return Colors.orange;
      case TourStatus.approved:
        return Colors.green;
      case TourStatus.rejected:
        return Colors.red;
      case TourStatus.hidden:
        return Colors.blueGrey;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TourStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TourStatus.draft:
        color = Colors.grey;
      case TourStatus.pendingReview:
        color = Colors.orange;
      case TourStatus.approved:
        color = Colors.green;
      case TourStatus.rejected:
        color = Colors.red;
      case TourStatus.hidden:
        color = Colors.blueGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _TourDetailsDialog extends StatelessWidget {
  final TourModel tour;

  const _TourDetailsDialog({required this.tour});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(tour.category.icon, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tour.displayName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow('ID', tour.id),
            _DetailRow('Creator', tour.creatorName),
            _DetailRow('Status', tour.status.displayName),
            _DetailRow('Category', tour.category.displayName),
            _DetailRow('Type', tour.tourType.displayName),
            _DetailRow('Location', '${tour.city ?? ''}, ${tour.country ?? ''}'),
            _DetailRow('Featured', tour.featured ? 'Yes' : 'No'),
            const Divider(),
            _DetailRow('Total Plays', tour.stats.totalPlays.toString()),
            _DetailRow('Downloads', tour.stats.totalDownloads.toString()),
            _DetailRow('Rating', '${tour.stats.averageRating.toStringAsFixed(1)} (${tour.stats.totalRatings} reviews)'),
            const Divider(),
            _DetailRow('Created', _formatDate(tour.createdAt)),
            _DetailRow('Updated', _formatDate(tour.updatedAt)),
            if (tour.publishedAt != null)
              _DetailRow('Published', _formatDate(tour.publishedAt!)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (tour.status == TourStatus.approved)
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(RouteNames.tourDetailsPath(tour.id));
            },
            child: const Text('View Tour'),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
