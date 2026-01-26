import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../config/mapbox_config.dart';
import '../data/local/offline_storage_service.dart';
import '../data/models/stop_model.dart';
import '../data/models/tour_version_model.dart';

/// Progress callback for tile downloads
typedef TileDownloadProgressCallback = void Function(
  int completedResources,
  int requiredResources,
  double progress,
);

/// Service for managing offline map tiles using Mapbox SDK
class OfflineMapService {
  TileStore? _tileStore;
  bool _isInitialized = false;

  final OfflineStorageService _storageService;

  OfflineMapService(this._storageService);

  /// Initialize the offline map service
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      debugPrint('OfflineMapService: Web platform not supported');
      return;
    }

    try {
      _tileStore = await TileStore.createDefault();
      _isInitialized = true;
      debugPrint('OfflineMapService initialized successfully');
    } catch (e, stack) {
      debugPrint('Failed to initialize OfflineMapService: $e');
      if (kDebugMode) {
        debugPrint('Stack: $stack');
      }
    }
  }

  /// Download map tiles for a tour's bounding box
  Future<void> downloadTourMapTiles(
    String tourId,
    BoundingBox boundingBox, {
    TileDownloadProgressCallback? onProgress,
  }) async {
    if (!_isInitialized || kIsWeb || _tileStore == null) {
      debugPrint('OfflineMapService: Cannot download - not initialized or web');
      return;
    }

    final regionId = MapboxConfig.tileRegionId(tourId);

    try {
      // Check if we already have tiles for this tour
      if (await hasTilesForTour(tourId)) {
        debugPrint('Tiles already exist for tour $tourId');
        onProgress?.call(1, 1, 1.0);
        return;
      }

      // Create geometry as GeoJSON map from bounding box
      final geometry = _createGeoJsonFromBoundingBox(boundingBox);

      // Define tile region load options
      final tileRegionLoadOptions = TileRegionLoadOptions(
        geometry: geometry,
        descriptorsOptions: [
          TilesetDescriptorOptions(
            styleURI: MapboxConfig.defaultStyle,
            minZoom: MapboxConfig.offlineMinZoom.toInt(),
            maxZoom: MapboxConfig.offlineMaxZoom.toInt(),
          ),
        ],
        acceptExpired: true,
        networkRestriction: NetworkRestriction.NONE,
      );

      // Start the download with progress callback
      int lastReportedRequired = 0;

      final cancelable = _tileStore!.loadTileRegion(
        regionId,
        tileRegionLoadOptions,
        (progress) {
          final completed = progress.completedResourceCount;
          final required = progress.requiredResourceCount;
          final progressPercent = required > 0 ? completed / required : 0.0;

          lastReportedRequired = required;

          debugPrint(
            'Tile download progress: $completed/$required (${(progressPercent * 100).toStringAsFixed(1)}%)',
          );

          onProgress?.call(completed, required, progressPercent);
        },
      );

      // Wait for completion - the cancelable is a Future
      final result = await cancelable;

      // Calculate estimated size (rough estimate based on resource count)
      final resourceCount = lastReportedRequired > 0
          ? lastReportedRequired
          : result.completedResourceCount;
      final estimatedSize = resourceCount * 50 * 1024; // ~50KB per tile

      // Save metadata to Hive
      await _storageService.saveMapTileMetadata(
        tourId: tourId,
        estimatedSize: estimatedSize,
        downloadedAt: DateTime.now(),
        expiresAt: DateTime.now().add(
          Duration(days: MapboxConfig.tileExpirationDays),
        ),
      );

      debugPrint('Tile download complete for tour $tourId');
    } catch (e, stack) {
      debugPrint('Error downloading tiles for tour $tourId: $e');
      if (kDebugMode) {
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }

  /// Calculate bounding box from a list of stops with padding
  BoundingBox calculateBoundingBoxFromStops(List<StopModel> stops) {
    if (stops.isEmpty) {
      throw ArgumentError('Cannot calculate bounding box from empty stops list');
    }

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;

    for (final stop in stops) {
      final lat = stop.location.latitude;
      final lng = stop.location.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    // Add padding (10% on each side)
    final latPadding =
        (maxLat - minLat) * MapboxConfig.boundingBoxPaddingPercent;
    final lngPadding =
        (maxLng - minLng) * MapboxConfig.boundingBoxPaddingPercent;

    // Ensure minimum padding for single-point or very close stops
    const minPadding = 0.005; // ~500m
    final effectiveLatPadding =
        latPadding > minPadding ? latPadding : minPadding;
    final effectiveLngPadding =
        lngPadding > minPadding ? lngPadding : minPadding;

    return BoundingBox(
      northeast: GeoPoint(
        maxLat + effectiveLatPadding,
        maxLng + effectiveLngPadding,
      ),
      southwest: GeoPoint(
        minLat - effectiveLatPadding,
        minLng - effectiveLngPadding,
      ),
    );
  }

  /// Check if tiles exist for a tour
  Future<bool> hasTilesForTour(String tourId) async {
    if (!_isInitialized || kIsWeb || _tileStore == null) return false;

    // First check metadata
    if (!_storageService.hasMapTiles(tourId)) {
      return false;
    }

    // Verify tiles actually exist in TileStore
    try {
      final regionId = MapboxConfig.tileRegionId(tourId);
      final regions = await _tileStore!.allTileRegions();

      for (final region in regions) {
        if (region.id == regionId) {
          return true;
        }
      }

      // Tiles don't exist in TileStore, clean up stale metadata
      await _storageService.deleteMapTileMetadata(tourId);
      return false;
    } catch (e) {
      debugPrint('Error checking tiles for tour $tourId: $e');
      return false;
    }
  }

  /// Get estimated tile storage size for a tour
  Future<int> getTileSizeForTour(String tourId) async {
    final metadata = _storageService.getMapTileMetadata(tourId);
    return metadata?['estimatedSize'] as int? ?? 0;
  }

  /// Delete map tiles for a tour
  Future<void> deleteTourMapTiles(String tourId) async {
    if (!_isInitialized || kIsWeb || _tileStore == null) return;

    final regionId = MapboxConfig.tileRegionId(tourId);

    try {
      // Use removeRegion method
      await _tileStore!.removeRegion(regionId);
      await _storageService.deleteMapTileMetadata(tourId);
      debugPrint('Deleted tiles for tour $tourId');
    } catch (e) {
      debugPrint('Error deleting tiles for tour $tourId: $e');
      // Still try to clean up metadata even if TileStore fails
      await _storageService.deleteMapTileMetadata(tourId);
    }
  }

  /// Clean up expired tiles
  Future<void> cleanupExpiredTiles() async {
    if (!_isInitialized || kIsWeb) return;

    try {
      final expiredTourIds = _storageService.getExpiredMapTileIds();

      for (final tourId in expiredTourIds) {
        await deleteTourMapTiles(tourId);
      }

      if (expiredTourIds.isNotEmpty) {
        debugPrint('Cleaned up ${expiredTourIds.length} expired tile regions');
      }
    } catch (e) {
      debugPrint('Error cleaning up expired tiles: $e');
    }
  }

  /// Get total map tile storage size across all tours
  Future<int> getTotalMapTileStorageSize() async {
    return _storageService.getMapTileStorageSize();
  }

  /// Get all tour IDs with offline maps
  List<String> getToursWithOfflineMaps() {
    return _storageService.getMapTileTourIds();
  }

  /// Create a GeoJSON map from a bounding box for the TileRegionLoadOptions
  Map<String, Object?> _createGeoJsonFromBoundingBox(BoundingBox boundingBox) {
    final sw = [boundingBox.southwest.longitude, boundingBox.southwest.latitude];
    final ne = [boundingBox.northeast.longitude, boundingBox.northeast.latitude];
    final se = [ne[0], sw[1]];
    final nw = [sw[0], ne[1]];

    return {
      'type': 'Polygon',
      'coordinates': [
        [sw, se, ne, nw, sw], // Ring must close
      ],
    };
  }

  bool get isInitialized => _isInitialized;
}
