import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/constants/route_names.dart';
import '../../../data/local/offline_storage_service.dart';
import '../../../services/download_manager.dart';
import '../../providers/tour_providers.dart';
import '../../widgets/tour/tour_card.dart';

/// Provider for the list of downloaded tour IDs
final downloadedTourIdsProvider = Provider<List<String>>((ref) {
  final manager = ref.watch(downloadManagerProvider.notifier);
  return manager.getDownloadedTourIds();
});

/// Provider for total cache size
final cacheSizeProvider = FutureProvider<int>((ref) async {
  final storage = ref.watch(offlineStorageServiceProvider);
  return storage.getCacheSize();
});

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedIds = ref.watch(downloadedTourIdsProvider);
    final cacheSizeAsync = ref.watch(cacheSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        actions: [
          if (downloadedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All Downloads',
              onPressed: () => _showClearAllDialog(context, ref),
            ),
        ],
      ),
      body: Column(
        children: [
          // Storage info header
          _StorageInfoCard(
            cacheSizeAsync: cacheSizeAsync,
            downloadCount: downloadedIds.length,
          ),

          // Downloads list
          Expanded(
            child: downloadedIds.isEmpty
                ? _buildEmptyState(context)
                : _buildDownloadsList(context, ref, downloadedIds),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_done,
              size: 80,
              color: context.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No downloads yet',
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Download tours to enjoy them offline without an internet connection',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(RouteNames.discover),
              icon: const Icon(Icons.explore),
              label: const Text('Discover Tours'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadsList(
    BuildContext context,
    WidgetRef ref,
    List<String> downloadedIds,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: downloadedIds.length,
      itemBuilder: (context, index) {
        final tourId = downloadedIds[index];
        return _DownloadedTourItem(
          tourId: tourId,
          onDelete: () => _showDeleteDialog(context, ref, tourId),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String tourId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: const Text(
          'This will remove the downloaded tour from your device. You can download it again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(downloadManagerProvider.notifier).deleteDownload(tourId);
              Navigator.pop(context);
              context.showSuccessSnackBar('Download removed');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Downloads'),
        content: const Text(
          'This will remove all downloaded tours from your device. You can download them again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
            ),
            onPressed: () async {
              final storage = ref.read(offlineStorageServiceProvider);
              await storage.clearAll();
              if (context.mounted) {
                Navigator.pop(context);
                context.showSuccessSnackBar('All downloads cleared');
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _StorageInfoCard extends StatelessWidget {
  final AsyncValue<int> cacheSizeAsync;
  final int downloadCount;

  const _StorageInfoCard({
    required this.cacheSizeAsync,
    required this.downloadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.storage,
              color: context.colorScheme.onPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Used',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                cacheSizeAsync.when(
                  data: (bytes) => Text(
                    _formatBytes(bytes),
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Text(
                    'Unknown',
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                downloadCount.toString(),
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                downloadCount == 1 ? 'tour' : 'tours',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}

class _DownloadedTourItem extends ConsumerWidget {
  final String tourId;
  final VoidCallback onDelete;

  const _DownloadedTourItem({
    required this.tourId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tourAsync = ref.watch(tourByIdProvider(tourId));
    final downloadState = ref.watch(tourDownloadStateProvider(tourId));
    final storage = ref.watch(offlineStorageServiceProvider);
    final downloadStatus = storage.getDownloadStatus(tourId);

    return tourAsync.when(
      data: (tour) {
        if (tour == null) {
          return _buildErrorCard(context, 'Tour not found');
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              TourCard(
                tour: tour,
                onTap: () => context.go(RouteNames.tourDetailsPath(tourId)),
                showFavoriteButton: false,
              ),
              // Download info overlay
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.download_done,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatSize(downloadStatus?['fileSize'] as int?),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Delete button
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Expiration info
              if (downloadStatus?['expiresAt'] != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatExpiration(downloadStatus!['expiresAt']),
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
      },
      loading: () => _buildLoadingCard(context),
      error: (error, _) => _buildErrorCard(context, error.toString()),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: context.colorScheme.error,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error loading tour',
                    style: context.textTheme.titleMedium,
                  ),
                  Text(
                    error,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int? bytes) {
    if (bytes == null || bytes == 0) return 'Downloaded';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatExpiration(String expiresAt) {
    final date = DateTime.tryParse(expiresAt);
    if (date == null) return 'Unknown';

    final days = date.difference(DateTime.now()).inDays;
    if (days <= 0) return 'Expires today';
    if (days == 1) return 'Expires tomorrow';
    if (days < 7) return 'Expires in $days days';
    return 'Expires in ${(days / 7).round()} weeks';
  }
}
