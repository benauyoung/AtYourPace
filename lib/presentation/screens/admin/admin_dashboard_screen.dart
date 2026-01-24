import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/tour_providers.dart';
import '../../providers/user_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewQueue = ref.watch(reviewQueueProvider);
    final allTours = ref.watch(allToursAdminProvider);
    final allUsers = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(reviewQueueProvider);
              ref.invalidate(allToursAdminProvider);
              ref.invalidate(allUsersProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reviewQueueProvider);
          ref.invalidate(allToursAdminProvider);
          ref.invalidate(allUsersProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quick stats grid
            Text(
              'Overview',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.pending_actions,
                    label: 'Pending Review',
                    value: reviewQueue.when(
                      data: (tours) => tours.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '-',
                    ),
                    color: Colors.orange,
                    onTap: () => context.go(RouteNames.reviewQueue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.tour,
                    label: 'Total Tours',
                    value: allTours.when(
                      data: (tours) => tours.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '-',
                    ),
                    color: Colors.blue,
                    onTap: () => context.go(RouteNames.allTours),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Live Tours',
                    value: allTours.when(
                      data: (tours) => tours
                          .where((t) => t.status == TourStatus.approved)
                          .length
                          .toString(),
                      loading: () => '...',
                      error: (_, __) => '-',
                    ),
                    color: Colors.green,
                    onTap: () => context.go(RouteNames.allTours),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    label: 'Total Users',
                    value: allUsers.when(
                      data: (users) => users.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '-',
                    ),
                    color: Colors.purple,
                    onTap: () => context.go(RouteNames.userManagement),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Aggregated stats
            Text(
              'Platform Statistics',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            allTours.when(
              data: (tours) => _buildPlatformStats(context, tours),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $error'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Menu items
            Text(
              'Management',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.rate_review, color: Colors.orange),
                    ),
                    title: const Text('Review Queue'),
                    subtitle: const Text('Review pending tour submissions'),
                    trailing: reviewQueue.when(
                      data: (tours) => tours.isNotEmpty
                          ? Badge(
                              label: Text(tours.length.toString()),
                              child: const Icon(Icons.arrow_forward_ios, size: 16),
                            )
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      loading: () => const Icon(Icons.arrow_forward_ios, size: 16),
                      error: (_, __) => const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    onTap: () => context.go(RouteNames.reviewQueue),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.people, color: Colors.purple),
                    ),
                    title: const Text('User Management'),
                    subtitle: const Text('Manage users and roles'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go(RouteNames.userManagement),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tour, color: Colors.blue),
                    ),
                    title: const Text('All Tours'),
                    subtitle: const Text('Browse and manage all tours'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go(RouteNames.allTours),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.settings, color: Colors.grey),
                    ),
                    title: const Text('App Settings'),
                    subtitle: const Text('Configure app behavior'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.go(RouteNames.adminSettings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick actions
            Text(
              'Quick Actions',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.star, size: 18),
                  label: const Text('Manage Featured'),
                  onPressed: () => context.go(RouteNames.allTours),
                ),
                ActionChip(
                  avatar: const Icon(Icons.download, size: 18),
                  label: const Text('Export Data'),
                  onPressed: () {
                    context.showInfoSnackBar('Export feature coming soon');
                  },
                ),
                ActionChip(
                  avatar: const Icon(Icons.analytics, size: 18),
                  label: const Text('View Analytics'),
                  onPressed: () {
                    context.showInfoSnackBar('Analytics feature coming soon');
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformStats(BuildContext context, List<TourModel> tours) {
    final totalPlays = tours.fold(0, (sum, t) => sum + t.stats.totalPlays);
    final totalDownloads = tours.fold(0, (sum, t) => sum + t.stats.totalDownloads);
    final totalRatings = tours.fold(0, (sum, t) => sum + t.stats.totalRatings);
    final avgRating = tours.isEmpty
        ? 0.0
        : tours.where((t) => t.stats.totalRatings > 0).fold(0.0,
                (sum, t) => sum + t.stats.averageRating * t.stats.totalRatings) /
            (totalRatings == 0 ? 1 : totalRatings);
    final featuredCount = tours.where((t) => t.featured).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.play_arrow,
                    value: _formatNumber(totalPlays),
                    label: 'Total Plays',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.download,
                    value: _formatNumber(totalDownloads),
                    label: 'Downloads',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.star,
                    value: avgRating.toStringAsFixed(1),
                    label: 'Avg Rating',
                    color: Colors.amber,
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.rate_review,
                    value: _formatNumber(totalRatings),
                    label: 'Reviews',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatusCount(
                  label: 'Draft',
                  count: tours.where((t) => t.status == TourStatus.draft).length,
                  color: Colors.grey,
                ),
                _StatusCount(
                  label: 'Pending',
                  count: tours.where((t) => t.status == TourStatus.pendingReview).length,
                  color: Colors.orange,
                ),
                _StatusCount(
                  label: 'Live',
                  count: tours.where((t) => t.status == TourStatus.approved).length,
                  color: Colors.green,
                ),
                _StatusCount(
                  label: 'Featured',
                  count: featuredCount,
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusCount extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusCount({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
