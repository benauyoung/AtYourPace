import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_config.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/tour_model.dart';
import '../../providers/tour_providers.dart';

/// Provider for creator analytics data
final creatorAnalyticsProvider = FutureProvider<CreatorAnalytics>((ref) async {
  final tours = await ref.watch(creatorToursProvider.future);

  if (AppConfig.demoMode) {
    await Future.delayed(const Duration(milliseconds: 300));
    return CreatorAnalytics.fromTours(tours);
  }

  return CreatorAnalytics.fromTours(tours);
});

class CreatorAnalytics {
  final int totalTours;
  final int publishedTours;
  final int pendingTours;
  final int draftTours;
  final int totalPlays;
  final int totalDownloads;
  final double averageRating;
  final int totalRatings;
  final int totalRevenue; // In cents
  final List<TourPerformance> tourPerformances;
  final List<DailyStats> last30Days;

  CreatorAnalytics({
    required this.totalTours,
    required this.publishedTours,
    required this.pendingTours,
    required this.draftTours,
    required this.totalPlays,
    required this.totalDownloads,
    required this.averageRating,
    required this.totalRatings,
    required this.totalRevenue,
    required this.tourPerformances,
    required this.last30Days,
  });

  factory CreatorAnalytics.fromTours(List<TourModel> tours) {
    final publishedTours = tours.where((t) => t.status == TourStatus.approved).toList();
    final pendingTours = tours.where((t) => t.status == TourStatus.pendingReview).length;
    final draftTours = tours.where((t) => t.status == TourStatus.draft).length;

    final totalPlays = publishedTours.fold<int>(0, (sum, t) => sum + t.stats.totalPlays);
    final totalDownloads = publishedTours.fold<int>(0, (sum, t) => sum + t.stats.totalDownloads);
    final totalRevenue = publishedTours.fold<int>(0, (sum, t) => sum + t.stats.totalRevenue);

    // Calculate weighted average rating
    final totalRatings = publishedTours.fold<int>(0, (sum, t) => sum + t.stats.totalRatings);
    final weightedRatingSum = publishedTours.fold<double>(
      0,
      (sum, t) => sum + (t.stats.averageRating * t.stats.totalRatings),
    );
    final averageRating = totalRatings > 0 ? weightedRatingSum / totalRatings : 0.0;

    // Create tour performances sorted by plays
    final tourPerformances = publishedTours
        .map((t) => TourPerformance(
              tourId: t.id,
              tourName: t.city ?? 'Untitled',
              plays: t.stats.totalPlays,
              downloads: t.stats.totalDownloads,
              rating: t.stats.averageRating,
              revenue: t.stats.totalRevenue,
            ))
        .toList()
      ..sort((a, b) => b.plays.compareTo(a.plays));

    // Generate demo daily stats for last 30 days
    final last30Days = List.generate(30, (index) {
      final date = DateTime.now().subtract(Duration(days: 29 - index));
      // Demo: Generate some realistic-looking data
      final basePlays = (totalPlays / 90).round();
      final variation = (index % 7 == 0 || index % 7 == 6) ? 1.5 : 1.0; // Weekend boost
      return DailyStats(
        date: date,
        plays: (basePlays * variation * (0.5 + (index / 30))).round(),
        downloads: (basePlays * 0.3 * variation * (0.5 + (index / 30))).round(),
        revenue: (basePlays * 50 * variation * (0.5 + (index / 30))).round(),
      );
    });

    return CreatorAnalytics(
      totalTours: tours.length,
      publishedTours: publishedTours.length,
      pendingTours: pendingTours,
      draftTours: draftTours,
      totalPlays: totalPlays,
      totalDownloads: totalDownloads,
      averageRating: averageRating,
      totalRatings: totalRatings,
      totalRevenue: totalRevenue,
      tourPerformances: tourPerformances,
      last30Days: last30Days,
    );
  }
}

class TourPerformance {
  final String tourId;
  final String tourName;
  final int plays;
  final int downloads;
  final double rating;
  final int revenue;

  TourPerformance({
    required this.tourId,
    required this.tourName,
    required this.plays,
    required this.downloads,
    required this.rating,
    required this.revenue,
  });
}

class DailyStats {
  final DateTime date;
  final int plays;
  final int downloads;
  final int revenue;

  DailyStats({
    required this.date,
    required this.plays,
    required this.downloads,
    required this.revenue,
  });
}

class CreatorAnalyticsScreen extends ConsumerWidget {
  const CreatorAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(creatorAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(creatorAnalyticsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) => _AnalyticsContent(analytics: analytics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final CreatorAnalytics analytics;

  const _AnalyticsContent({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overview Cards
        _SectionHeader(title: 'Overview'),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Plays',
                value: _formatNumber(analytics.totalPlays),
                icon: Icons.play_arrow,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Downloads',
                value: _formatNumber(analytics.totalDownloads),
                icon: Icons.download,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Avg Rating',
                value: analytics.averageRating > 0
                    ? analytics.averageRating.toStringAsFixed(1)
                    : 'N/A',
                subtitle: '${analytics.totalRatings} reviews',
                icon: Icons.star,
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Earnings',
                value: '\$${(analytics.totalRevenue / 100).toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tour Status Breakdown
        _SectionHeader(title: 'Tour Status'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatusStat(
                  label: 'Published',
                  value: analytics.publishedTours,
                  color: Colors.green,
                ),
                _StatusStat(
                  label: 'Pending',
                  value: analytics.pendingTours,
                  color: Colors.orange,
                ),
                _StatusStat(
                  label: 'Drafts',
                  value: analytics.draftTours,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 30-Day Performance Chart
        _SectionHeader(title: 'Last 30 Days'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PeriodStat(
                      label: 'Plays',
                      value: analytics.last30Days.fold<int>(0, (sum, d) => sum + d.plays),
                    ),
                    _PeriodStat(
                      label: 'Downloads',
                      value: analytics.last30Days.fold<int>(0, (sum, d) => sum + d.downloads),
                    ),
                    _PeriodStat(
                      label: 'Revenue',
                      value: analytics.last30Days.fold<int>(0, (sum, d) => sum + d.revenue),
                      isCurrency: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Simple bar chart visualization
                SizedBox(
                  height: 100,
                  child: _SimpleBarChart(data: analytics.last30Days),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Top Performing Tours
        _SectionHeader(title: 'Top Performing Tours'),
        if (analytics.tourPerformances.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No published tours yet',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...analytics.tourPerformances.take(5).map((tour) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(tour.tourName),
                  subtitle: Row(
                    children: [
                      Icon(Icons.play_arrow, size: 14, color: context.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${tour.plays}'),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(tour.rating > 0 ? tour.rating.toStringAsFixed(1) : 'N/A'),
                    ],
                  ),
                  trailing: Text(
                    '\$${(tour.revenue / 100).toStringAsFixed(2)}',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )),
        const SizedBox(height: 24),

        // Payout Info
        _SectionHeader(title: 'Payout'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${(analytics.totalRevenue / 100).toStringAsFixed(2)}',
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    FilledButton(
                      onPressed: analytics.totalRevenue >= 2000
                          ? () => _showPayoutDialog(context)
                          : null,
                      child: const Text('Request Payout'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Minimum payout: \$20.00',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
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

  void _showPayoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Payout'),
        content: const Text(
          'This will transfer your available balance to your connected bank account. '
          'Payouts typically process within 3-5 business days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payout request submitted!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatusStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
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

class _PeriodStat extends StatelessWidget {
  final String label;
  final int value;
  final bool isCurrency;

  const _PeriodStat({
    required this.label,
    required this.value,
    this.isCurrency = false,
  });

  @override
  Widget build(BuildContext context) {
    String displayValue;
    if (isCurrency) {
      displayValue = '\$${(value / 100).toStringAsFixed(0)}';
    } else {
      displayValue = value.toString();
    }

    return Column(
      children: [
        Text(
          displayValue,
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
    );
  }
}

class _SimpleBarChart extends StatelessWidget {
  final List<DailyStats> data;

  const _SimpleBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxPlays = data.fold<int>(1, (max, d) => d.plays > max ? d.plays : max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((day) {
        final height = maxPlays > 0 ? (day.plays / maxPlays) * 80 : 0.0;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            height: height.clamp(4.0, 80.0),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
