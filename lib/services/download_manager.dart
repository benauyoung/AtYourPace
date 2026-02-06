import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/local/offline_storage_service.dart';
import '../data/models/stop_model.dart';
import '../data/models/tour_version_model.dart';
import '../presentation/providers/offline_map_provider.dart';
import '../presentation/providers/tour_providers.dart';
import 'offline_map_service.dart';

/// Download state for a tour
class TourDownloadState {
  final String tourId;
  final DownloadStatus status;
  final double progress;
  final int? totalBytes;
  final int? downloadedBytes;
  final String? errorMessage;
  final double mapTileProgress;
  final bool hasMapTiles;

  const TourDownloadState({
    required this.tourId,
    this.status = DownloadStatus.idle,
    this.progress = 0.0,
    this.totalBytes,
    this.downloadedBytes,
    this.errorMessage,
    this.mapTileProgress = 0.0,
    this.hasMapTiles = false,
  });

  TourDownloadState copyWith({
    String? tourId,
    DownloadStatus? status,
    double? progress,
    int? totalBytes,
    int? downloadedBytes,
    String? errorMessage,
    double? mapTileProgress,
    bool? hasMapTiles,
  }) {
    return TourDownloadState(
      tourId: tourId ?? this.tourId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      errorMessage: errorMessage,
      mapTileProgress: mapTileProgress ?? this.mapTileProgress,
      hasMapTiles: hasMapTiles ?? this.hasMapTiles,
    );
  }

  bool get isDownloading => status == DownloadStatus.downloading;
  bool get isComplete => status == DownloadStatus.complete;
  bool get isFailed => status == DownloadStatus.failed;
  bool get isPaused => status == DownloadStatus.paused;
}

enum DownloadStatus { idle, queued, downloading, paused, complete, failed }

/// Manages downloading tours for offline use
class DownloadManager extends StateNotifier<Map<String, TourDownloadState>> {
  final Ref _ref;
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};

  DownloadManager(this._ref) : super({});

  OfflineStorageService get _storage => _ref.read(offlineStorageServiceProvider);
  OfflineMapService get _offlineMapService => _ref.read(offlineMapServiceProvider);

  /// Ensure storage is initialized before use
  Future<void> _ensureStorageInitialized() async {
    await _storage.initialize();
  }

  /// Start downloading a tour
  Future<void> downloadTour(String tourId) async {
    // Check if already downloading
    if (state[tourId]?.isDownloading == true) {
      return;
    }

    // Update state to downloading
    state = {
      ...state,
      tourId: TourDownloadState(tourId: tourId, status: DownloadStatus.downloading, progress: 0.0),
    };

    try {
      // Ensure storage is initialized
      await _ensureStorageInitialized();
      // Get tour data
      final tour = await _ref.read(tourByIdProvider(tourId).future);
      if (tour == null) {
        throw Exception('Tour not found');
      }

      // Get version data - prefer live version, fall back to draft
      final versionId = tour.liveVersionId ?? tour.draftVersionId;

      final version = await _ref.read(
        tourVersionProvider((tourId: tourId, versionId: versionId)).future,
      );
      if (version == null) {
        throw Exception('Version not found');
      }

      // Get stops
      final stops = await _ref.read(stopsProvider((tourId: tourId, versionId: versionId)).future);

      // Cache the data
      await _storage.cacheTour(tour);
      await _storage.cacheVersion(version);
      await _storage.cacheStops(tourId, versionId, stops);

      // Start download tracking
      await _storage.startDownload(tourId, versionId);

      // Calculate total files to download
      final filesToDownload = <_DownloadItem>[];

      // Add cover image
      if (version.coverImageUrl != null) {
        filesToDownload.add(
          _DownloadItem(url: version.coverImageUrl!, type: _FileType.image, stopId: null),
        );
      }

      // Add stop media (audio and images, but NOT video)
      for (final stop in stops) {
        if (stop.media.audioUrl != null) {
          filesToDownload.add(
            _DownloadItem(url: stop.media.audioUrl!, type: _FileType.audio, stopId: stop.id),
          );
        }
        for (final image in stop.media.images) {
          filesToDownload.add(
            _DownloadItem(url: image.url, type: _FileType.image, stopId: stop.id),
          );
        }
        // Note: We explicitly skip video as per the spec
      }

      // Download files
      if (!kIsWeb && filesToDownload.isNotEmpty) {
        await _downloadFiles(tourId, filesToDownload);
      }

      // Download map tiles (non-blocking - don't fail download if map tiles fail)
      bool tilesDownloaded = false;
      if (!kIsWeb && stops.isNotEmpty) {
        try {
          await _downloadMapTilesForTour(tourId, version, stops);
          tilesDownloaded = await _offlineMapService.hasTilesForTour(tourId);
        } catch (e) {
          debugPrint('Map tile download failed (non-fatal): $e');
        }
      }

      // Calculate final size
      int totalSize = 0;
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        final tourDir = Directory('${dir.path}/tours/$tourId');
        if (await tourDir.exists()) {
          await for (final entity in tourDir.list(recursive: true)) {
            if (entity is File) {
              totalSize += await entity.length();
            }
          }
        }
      }

      // Mark complete
      await _storage.completeDownload(tourId, totalSize);
      state = {
        ...state,
        tourId: TourDownloadState(
          tourId: tourId,
          status: DownloadStatus.complete,
          progress: 1.0,
          totalBytes: totalSize,
          downloadedBytes: totalSize,
          mapTileProgress: tilesDownloaded ? 1.0 : 0.0,
          hasMapTiles: tilesDownloaded,
        ),
      };
    } catch (e, stack) {
      // Mark failed
      debugPrint('[DownloadManager] Download failed for $tourId: $e');
      debugPrint('[DownloadManager] Stack: $stack');
      await _storage.failDownload(tourId, e.toString());
      state = {
        ...state,
        tourId: TourDownloadState(
          tourId: tourId,
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        ),
      };
    } finally {
      _cancelTokens.remove(tourId);
    }
  }

  /// Download a tour in demo mode (simulated)
  Future<void> downloadTourDemo(String tourId) async {
    state = {
      ...state,
      tourId: TourDownloadState(tourId: tourId, status: DownloadStatus.downloading, progress: 0.0),
    };

    // Simulate download progress
    for (var i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      state = {
        ...state,
        tourId: TourDownloadState(
          tourId: tourId,
          status: DownloadStatus.downloading,
          progress: i / 10,
        ),
      };
    }

    // Mark complete
    state = {
      ...state,
      tourId: TourDownloadState(
        tourId: tourId,
        status: DownloadStatus.complete,
        progress: 1.0,
        totalBytes: 5000000, // 5MB simulated
        downloadedBytes: 5000000,
      ),
    };
  }

  Future<void> _downloadFiles(String tourId, List<_DownloadItem> files) async {
    final cancelToken = CancelToken();
    _cancelTokens[tourId] = cancelToken;

    final dir = await getApplicationDocumentsDirectory();
    final tourDir = Directory('${dir.path}/tours/$tourId');
    await tourDir.create(recursive: true);

    int downloadedFiles = 0;
    int totalBytes = 0;

    for (final file in files) {
      if (cancelToken.isCancelled) break;

      try {
        final fileName = _getFileName(file.url, file.type, file.stopId);
        final filePath = '${tourDir.path}/$fileName';

        final response = await _dio.download(
          file.url,
          filePath,
          cancelToken: cancelToken,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              totalBytes = received;
            }
          },
        );

        if (response.statusCode == 200) {
          downloadedFiles++;
          final progress = downloadedFiles / files.length;

          await _storage.updateDownloadProgress(tourId, progress, fileSize: totalBytes);

          state = {
            ...state,
            tourId: TourDownloadState(
              tourId: tourId,
              status: DownloadStatus.downloading,
              progress: progress,
              downloadedBytes: totalBytes,
            ),
          };
        }
      } catch (e) {
        debugPrint('Error downloading file ${file.url}: $e');
        // Continue with other files even if one fails
      }
    }
  }

  String _getFileName(String url, _FileType type, String? stopId) {
    final uri = Uri.parse(url);
    final extension = uri.path.split('.').last;

    switch (type) {
      case _FileType.audio:
        return 'audio_${stopId ?? 'unknown'}.$extension';
      case _FileType.image:
        final hash = url.hashCode.abs().toString();
        return 'image_${stopId ?? 'cover'}_$hash.$extension';
    }
  }

  /// Download map tiles for a tour
  Future<void> _downloadMapTilesForTour(
    String tourId,
    TourVersionModel version,
    List<StopModel> stops,
  ) async {
    // Get bounding box - prefer from version route, fall back to calculating from stops
    BoundingBox? boundingBox = version.route?.boundingBox;

    if (boundingBox == null && stops.isNotEmpty) {
      boundingBox = _offlineMapService.calculateBoundingBoxFromStops(stops);
    }

    if (boundingBox == null) {
      debugPrint('Cannot download map tiles: no bounding box available');
      return;
    }

    await _offlineMapService.downloadTourMapTiles(
      tourId,
      boundingBox,
      onProgress: (completed, required, progress) {
        // Update state with map tile progress
        final currentState = state[tourId];
        if (currentState != null) {
          state = {...state, tourId: currentState.copyWith(mapTileProgress: progress)};
        }
      },
    );
  }

  /// Download map tiles for an already downloaded tour (standalone)
  Future<void> downloadMapTilesOnly(String tourId) async {
    // Get version and stops from cache
    final tour = _storage.getCachedTour(tourId);
    if (tour == null) {
      throw Exception('Tour not found in cache');
    }

    final versionId = tour.liveVersionId ?? tour.draftVersionId;
    final version = _storage.getCachedVersion(tourId, versionId);
    if (version == null) {
      throw Exception('Version not found in cache');
    }

    final stops = _storage.getCachedStops(tourId, versionId);
    if (stops == null || stops.isEmpty) {
      throw Exception('Stops not found in cache');
    }

    await _downloadMapTilesForTour(tourId, version, stops);

    // Update state to reflect map tiles downloaded
    final currentState = state[tourId];
    if (currentState != null) {
      state = {...state, tourId: currentState.copyWith(mapTileProgress: 1.0, hasMapTiles: true)};
    }
  }

  /// Cancel a download
  void cancelDownload(String tourId) {
    _cancelTokens[tourId]?.cancel('User cancelled');
    _cancelTokens.remove(tourId);

    state = {...state, tourId: TourDownloadState(tourId: tourId, status: DownloadStatus.idle)};
  }

  /// Delete a downloaded tour
  Future<void> deleteDownload(String tourId) async {
    await _storage.deleteDownload(tourId);

    // Also delete map tiles
    try {
      await _offlineMapService.deleteTourMapTiles(tourId);
    } catch (e) {
      debugPrint('Error deleting map tiles for $tourId: $e');
    }

    final newState = Map<String, TourDownloadState>.from(state);
    newState.remove(tourId);
    state = newState;
  }

  /// Check if a tour is downloaded
  bool isDownloaded(String tourId) {
    return _storage.isDownloaded(tourId);
  }

  /// Get download state for a tour
  TourDownloadState? getDownloadState(String tourId) {
    // Check local state first
    final localState = state[tourId];
    if (localState != null) return localState;

    // Check storage
    final storageStatus = _storage.getDownloadStatus(tourId);
    if (storageStatus == null) return null;

    // Check map tile status
    final hasMapTiles = _storage.hasMapTiles(tourId);

    return TourDownloadState(
      tourId: tourId,
      status: _parseStatus(storageStatus['status']),
      progress: (storageStatus['progress'] as num?)?.toDouble() ?? 0.0,
      totalBytes: storageStatus['fileSize'] as int?,
      downloadedBytes: storageStatus['fileSize'] as int?,
      errorMessage: storageStatus['error'] as String?,
      mapTileProgress: hasMapTiles ? 1.0 : 0.0,
      hasMapTiles: hasMapTiles,
    );
  }

  DownloadStatus _parseStatus(String? status) {
    switch (status) {
      case 'downloading':
        return DownloadStatus.downloading;
      case 'complete':
        return DownloadStatus.complete;
      case 'failed':
        return DownloadStatus.failed;
      case 'paused':
        return DownloadStatus.paused;
      default:
        return DownloadStatus.idle;
    }
  }

  /// Get all downloaded tour IDs
  List<String> getDownloadedTourIds() {
    return _storage.getDownloadedTourIds();
  }

  @override
  void dispose() {
    for (final token in _cancelTokens.values) {
      token.cancel('Manager disposed');
    }
    _dio.close();
    super.dispose();
  }
}

class _DownloadItem {
  final String url;
  final _FileType type;
  final String? stopId;

  _DownloadItem({required this.url, required this.type, this.stopId});
}

enum _FileType { audio, image }

/// Provider for download manager
final downloadManagerProvider =
    StateNotifierProvider<DownloadManager, Map<String, TourDownloadState>>((ref) {
      return DownloadManager(ref);
    });

/// Provider to check if a specific tour is downloaded
final isTourDownloadedProvider = Provider.family<bool, String>((ref, tourId) {
  final manager = ref.watch(downloadManagerProvider.notifier);
  return manager.isDownloaded(tourId);
});

/// Provider for download state of a specific tour
final tourDownloadStateProvider = Provider.family<TourDownloadState?, String>((ref, tourId) {
  final allStates = ref.watch(downloadManagerProvider);
  return allStates[tourId];
});
