import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/offline_storage_service.dart';
import '../../services/offline_map_service.dart';

/// Provider for the OfflineMapService instance
final offlineMapServiceProvider = Provider<OfflineMapService>((ref) {
  final storageService = ref.watch(offlineStorageServiceProvider);
  return OfflineMapService(storageService);
});

/// Provider to check if a tour has offline map tiles
final tourHasOfflineMapsProvider = Provider.family<bool, String>((ref, tourId) {
  final storageService = ref.watch(offlineStorageServiceProvider);
  return storageService.hasMapTiles(tourId);
});

/// Provider for total map tile storage size
final totalMapTileStorageProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(offlineMapServiceProvider);
  return service.getTotalMapTileStorageSize();
});

/// Provider to get map tile size for a specific tour
final tourMapTileSizeProvider = FutureProvider.family<int, String>((ref, tourId) async {
  final service = ref.watch(offlineMapServiceProvider);
  return service.getTileSizeForTour(tourId);
});

/// Provider for list of tour IDs with offline maps
final toursWithOfflineMapsProvider = Provider<List<String>>((ref) {
  final service = ref.watch(offlineMapServiceProvider);
  return service.getToursWithOfflineMaps();
});
