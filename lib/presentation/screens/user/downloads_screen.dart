import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/local/offline_storage_service.dart';
import '../../../services/download_manager.dart';
import '../../providers/offline_map_provider.dart';
import '../../providers/tour_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/skeleton_loader.dart';
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
          _StorageInfoCard(cacheSizeAsync: cacheSizeAsync, downloadCount: downloadedIds.length),

          // Downloads list
          Expanded(
            child:
                downloadedIds.isEmpty
                    ? _buildEmptyState(context)
                    : _buildDownloadsList(context, ref, downloadedIds),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState.noDownloads(onExplore: () => context.go(RouteNames.discover));
  }

  Widget _buildDownloadsList(BuildContext context, WidgetRef ref, List<String> downloadedIds) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: downloadedIds.length,
      itemBuilder: (context, index) {
        final tourId = downloadedIds[index];
        return _DownloadedTourItem(
          key: ValueKey(tourId),
          tourId: tourId,
          onDelete: () => _showDeleteDialog(context, ref, tourId),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String tourId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Download'),
            content: const Text(
              'This will remove the downloaded tour from your device. You can download it again later.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Downloads'),
            content: const Text(
              'This will remove all downloaded tours from your device. You can download them again later.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: context.colorScheme.error),
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

class _StorageInfoCard extends ConsumerWidget {
  final AsyncValue<int> cacheSizeAsync;
  final int downloadCount;

  const _StorageInfoCard({required this.cacheSizeAsync, required this.downloadCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapTileSizeAsync = ref.watch(totalMapTileStorageProvider);

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
            child: Icon(Icons.storage, color: context.colorScheme.onPrimary, size: 24),
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
                _buildStorageBreakdown(context, mapTileSizeAsync),
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

  Widget _buildStorageBreakdown(BuildContext context, AsyncValue<int> mapTileSizeAsync) {
    return cacheSizeAsync.when(
      data: (mediaBytes) {
        return mapTileSizeAsync.when(
          data: (mapBytes) {
            final totalBytes = mediaBytes + mapBytes;
            if (mapBytes > 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatBytes(totalBytes),
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Media: ${_formatBytes(mediaBytes)} | Maps: ${_formatBytes(mapBytes)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              );
            }
            return Text(
              _formatBytes(mediaBytes),
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onPrimaryContainer,
              ),
            );
          },
          loading:
              () => Text(
                _formatBytes(mediaBytes),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
          error:
              (_, __) => Text(
                _formatBytes(mediaBytes),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
        );
      },
      loading:
          () => const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
      error:
          (_, __) => Text(
            'Unknown',
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colorScheme.onPrimaryContainer,
            ),
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

class _DownloadedTourItem extends ConsumerStatefulWidget {
  final String tourId;
  final VoidCallback onDelete;

  const _DownloadedTourItem({super.key, required this.tourId, required this.onDelete});

  @override
  ConsumerState<_DownloadedTourItem> createState() => _DownloadedTourItemState();
}

class _DownloadedTourItemState extends ConsumerState<_DownloadedTourItem> {
  bool _isDownloadingMap = false;

  Future<void> _downloadMapTiles() async {
    if (_isDownloadingMap) return;

    setState(() => _isDownloadingMap = true);

    try {
      await ref.read(downloadManagerProvider.notifier).downloadMapTilesOnly(widget.tourId);
      if (mounted) {
        context.showSuccessSnackBar('Map tiles downloaded');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to download map tiles');
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloadingMap = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tourAsync = ref.watch(tourByIdProvider(widget.tourId));
    final storage = ref.watch(offlineStorageServiceProvider);
    final downloadStatus = storage.getDownloadStatus(widget.tourId);
    final hasMapTiles = ref.watch(tourHasOfflineMapsProvider(widget.tourId));

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
                onTap: () => context.push(RouteNames.tourDetailsPath(widget.tourId)),
                showFavoriteButton: false,
              ),
              // Download info overlay with map indicator
              Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.download_done, size: 14, color: AppColors.textOnPrimary),
                          const SizedBox(width: 4),
                          Text(
                            _formatSize(downloadStatus?['fileSize'] as int?),
                            style: const TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Map tiles indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasMapTiles ? AppColors.primaryLight : AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasMapTiles ? Icons.map : Icons.map_outlined,
                            size: 14,
                            color: AppColors.textOnPrimary,
                          ),
                          if (!hasMapTiles && !_isDownloadingMap) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: _downloadMapTiles,
                              child: const Text(
                                'Get Map',
                                style: TextStyle(
                                  color: AppColors.textOnPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          if (_isDownloadingMap) ...[
                            const SizedBox(width: 4),
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: AppColors.textPrimary.withOpacity(0.5),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.onDelete,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.delete_outline, size: 20, color: AppColors.textOnPrimary),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule, size: 14, color: AppColors.textOnPrimary),
                        const SizedBox(width: 4),
                        Text(
                          _formatExpiration(downloadStatus!['expiresAt']),
                          style: const TextStyle(color: AppColors.textOnPrimary, fontSize: 12),
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
    return const TourCardSkeleton();
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: context.colorScheme.error),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Error loading tour', style: context.textTheme.titleMedium),
                  Text(
                    error,
                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.error),
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.delete), onPressed: widget.onDelete),
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
