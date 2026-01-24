import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_config.dart';
import '../../../services/download_manager.dart';

/// Button to download a tour for offline use
class TourDownloadButton extends ConsumerWidget {
  final String tourId;
  final bool showLabel;
  final double? size;

  const TourDownloadButton({
    super.key,
    required this.tourId,
    this.showLabel = true,
    this.size,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(tourDownloadStateProvider(tourId));
    final isDownloaded = ref.watch(isTourDownloadedProvider(tourId));

    final theme = Theme.of(context);
    final iconSize = size ?? 24.0;

    // Already downloaded
    if (isDownloaded && downloadState?.status != DownloadStatus.downloading) {
      if (showLabel) {
        return OutlinedButton.icon(
          onPressed: () => _showDeleteDialog(context, ref),
          icon: Icon(Icons.download_done, size: iconSize),
          label: const Text('Downloaded'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.green,
          ),
        );
      }
      return IconButton(
        onPressed: () => _showDeleteDialog(context, ref),
        icon: Icon(Icons.download_done, size: iconSize, color: Colors.green),
        tooltip: 'Downloaded - tap to delete',
      );
    }

    // Currently downloading
    if (downloadState?.status == DownloadStatus.downloading) {
      final progress = downloadState?.progress ?? 0.0;
      if (showLabel) {
        return OutlinedButton.icon(
          onPressed: () => _cancelDownload(ref),
          icon: SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
            ),
          ),
          label: Text('${(progress * 100).toInt()}%'),
        );
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: iconSize + 8,
            height: iconSize + 8,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
            ),
          ),
          IconButton(
            onPressed: () => _cancelDownload(ref),
            icon: Icon(Icons.close, size: iconSize * 0.6),
            tooltip: 'Cancel download',
          ),
        ],
      );
    }

    // Failed
    if (downloadState?.status == DownloadStatus.failed) {
      if (showLabel) {
        return OutlinedButton.icon(
          onPressed: () => _startDownload(ref),
          icon: Icon(Icons.error_outline, size: iconSize, color: theme.colorScheme.error),
          label: const Text('Retry'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
        );
      }
      return IconButton(
        onPressed: () => _startDownload(ref),
        icon: Icon(Icons.error_outline, size: iconSize, color: theme.colorScheme.error),
        tooltip: 'Download failed - tap to retry',
      );
    }

    // Not downloaded - show download button
    if (showLabel) {
      return OutlinedButton.icon(
        onPressed: () => _startDownload(ref),
        icon: Icon(Icons.download_outlined, size: iconSize),
        label: const Text('Download'),
      );
    }
    return IconButton(
      onPressed: () => _startDownload(ref),
      icon: Icon(Icons.download_outlined, size: iconSize),
      tooltip: 'Download for offline use',
    );
  }

  void _startDownload(WidgetRef ref) {
    final manager = ref.read(downloadManagerProvider.notifier);
    if (AppConfig.demoMode) {
      manager.downloadTourDemo(tourId);
    } else {
      manager.downloadTour(tourId);
    }
  }

  void _cancelDownload(WidgetRef ref) {
    final manager = ref.read(downloadManagerProvider.notifier);
    manager.cancelDownload(tourId);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download?'),
        content: const Text(
          'This will remove the offline version of this tour. '
          'You can download it again anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final manager = ref.read(downloadManagerProvider.notifier);
              manager.deleteDownload(tourId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Compact download indicator for list items
class DownloadIndicator extends ConsumerWidget {
  final String tourId;

  const DownloadIndicator({
    super.key,
    required this.tourId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDownloaded = ref.watch(isTourDownloadedProvider(tourId));
    final downloadState = ref.watch(tourDownloadStateProvider(tourId));

    if (downloadState?.status == DownloadStatus.downloading) {
      return Container(
        width: 20,
        height: 20,
        padding: const EdgeInsets.all(2),
        child: CircularProgressIndicator(
          value: downloadState?.progress,
          strokeWidth: 2,
        ),
      );
    }

    if (isDownloaded) {
      return const Icon(
        Icons.offline_pin,
        size: 20,
        color: Colors.green,
      );
    }

    return const SizedBox.shrink();
  }
}

/// Download all button for batch operations
class DownloadAllButton extends ConsumerWidget {
  final List<String> tourIds;

  const DownloadAllButton({
    super.key,
    required this.tourIds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check how many are already downloaded
    int downloadedCount = 0;
    for (final tourId in tourIds) {
      if (ref.watch(isTourDownloadedProvider(tourId))) {
        downloadedCount++;
      }
    }

    final allDownloaded = downloadedCount == tourIds.length;
    final someDownloaded = downloadedCount > 0 && !allDownloaded;

    return FilledButton.icon(
      onPressed: allDownloaded
          ? null
          : () {
              final manager = ref.read(downloadManagerProvider.notifier);
              for (final tourId in tourIds) {
                if (!ref.read(isTourDownloadedProvider(tourId))) {
                  if (AppConfig.demoMode) {
                    manager.downloadTourDemo(tourId);
                  } else {
                    manager.downloadTour(tourId);
                  }
                }
              }
            },
      icon: Icon(
        allDownloaded
            ? Icons.download_done
            : someDownloaded
                ? Icons.downloading
                : Icons.download,
      ),
      label: Text(
        allDownloaded
            ? 'All Downloaded'
            : someDownloaded
                ? 'Download Remaining (${tourIds.length - downloadedCount})'
                : 'Download All (${tourIds.length})',
      ),
    );
  }
}
