import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tour_model.dart';
import '../models/tour_version_model.dart';
import '../models/stop_model.dart';

/// Service for managing offline storage using Hive
class OfflineStorageService {
  static const String _toursBoxName = 'tours_cache';
  static const String _versionsBoxName = 'versions_cache';
  static const String _stopsBoxName = 'stops_cache';
  static const String _downloadsBoxName = 'downloads_metadata';
  static const String _progressBoxName = 'user_progress';
  static const String _settingsBoxName = 'app_settings';

  late Box<Map> _toursBox;
  late Box<Map> _versionsBox;
  late Box<Map> _stopsBox;
  late Box<Map> _downloadsBox;
  late Box<Map> _progressBox;
  late Box<dynamic> _settingsBox;

  bool _isInitialized = false;

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    _toursBox = await Hive.openBox<Map>(_toursBoxName);
    _versionsBox = await Hive.openBox<Map>(_versionsBoxName);
    _stopsBox = await Hive.openBox<Map>(_stopsBoxName);
    _downloadsBox = await Hive.openBox<Map>(_downloadsBoxName);
    _progressBox = await Hive.openBox<Map>(_progressBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    _isInitialized = true;
  }

  // ==================== Tours ====================

  /// Cache a tour for quick offline access
  Future<void> cacheTour(TourModel tour) async {
    await _toursBox.put(tour.id, {
      ...tour.toJson(),
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Cache multiple tours
  Future<void> cacheTours(List<TourModel> tours) async {
    final entries = <String, Map>{};
    for (final tour in tours) {
      entries[tour.id] = {
        ...tour.toJson(),
        'cachedAt': DateTime.now().toIso8601String(),
      };
    }
    await _toursBox.putAll(entries);
  }

  /// Get a cached tour
  TourModel? getCachedTour(String tourId) {
    final data = _toursBox.get(tourId);
    if (data == null) return null;

    // Check if cache is expired (1 hour)
    final cachedAt = DateTime.tryParse(data['cachedAt'] ?? '');
    if (cachedAt != null && DateTime.now().difference(cachedAt).inHours > 1) {
      return null;
    }

    try {
      return TourModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      debugPrint('Error parsing cached tour: $e');
      return null;
    }
  }

  /// Get all cached tours
  List<TourModel> getAllCachedTours() {
    final tours = <TourModel>[];
    for (final data in _toursBox.values) {
      try {
        final tour = TourModel.fromJson(Map<String, dynamic>.from(data));
        tours.add(tour);
      } catch (e) {
        debugPrint('Error parsing cached tour: $e');
      }
    }
    return tours;
  }

  /// Clear tour cache
  Future<void> clearTourCache() async {
    await _toursBox.clear();
  }

  // ==================== Tour Versions ====================

  /// Cache a tour version
  Future<void> cacheVersion(TourVersionModel version) async {
    final key = '${version.tourId}_${version.id}';
    await _versionsBox.put(key, {
      ...version.toJson(),
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get a cached version
  TourVersionModel? getCachedVersion(String tourId, String versionId) {
    final key = '${tourId}_$versionId';
    final data = _versionsBox.get(key);
    if (data == null) return null;

    try {
      final jsonData = Map<String, dynamic>.from(data);
      jsonData['tourId'] = tourId;
      return TourVersionModel.fromJson(jsonData);
    } catch (e) {
      debugPrint('Error parsing cached version: $e');
      return null;
    }
  }

  // ==================== Stops ====================

  /// Cache stops for a version
  Future<void> cacheStops(String tourId, String versionId, List<StopModel> stops) async {
    final key = '${tourId}_$versionId';
    await _stopsBox.put(key, {
      'stops': stops.map((s) => s.toJson()).toList(),
      'cachedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get cached stops
  List<StopModel>? getCachedStops(String tourId, String versionId) {
    final key = '${tourId}_$versionId';
    final data = _stopsBox.get(key);
    if (data == null) return null;

    try {
      final stopsData = (data['stops'] as List).cast<Map>();
      return stopsData.map((s) {
        final json = Map<String, dynamic>.from(s);
        json['tourId'] = tourId;
        json['versionId'] = versionId;
        return StopModel.fromJson(json);
      }).toList();
    } catch (e) {
      debugPrint('Error parsing cached stops: $e');
      return null;
    }
  }

  // ==================== Downloads ====================

  /// Mark a tour as being downloaded
  Future<void> startDownload(String tourId, String versionId) async {
    await _downloadsBox.put(tourId, {
      'tourId': tourId,
      'versionId': versionId,
      'status': 'downloading',
      'progress': 0.0,
      'startedAt': DateTime.now().toIso8601String(),
      'fileSize': 0,
    });
  }

  /// Update download progress
  Future<void> updateDownloadProgress(String tourId, double progress, {int? fileSize}) async {
    final data = _downloadsBox.get(tourId);
    if (data == null) return;

    await _downloadsBox.put(tourId, {
      ...Map<String, dynamic>.from(data),
      'progress': progress,
      if (fileSize != null) 'fileSize': fileSize,
    });
  }

  /// Mark download as complete
  Future<void> completeDownload(String tourId, int fileSize) async {
    final data = _downloadsBox.get(tourId);
    if (data == null) return;

    await _downloadsBox.put(tourId, {
      ...Map<String, dynamic>.from(data),
      'status': 'complete',
      'progress': 1.0,
      'fileSize': fileSize,
      'completedAt': DateTime.now().toIso8601String(),
      // Downloads expire after 30 days
      'expiresAt': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    });
  }

  /// Mark download as failed
  Future<void> failDownload(String tourId, String error) async {
    final data = _downloadsBox.get(tourId);
    if (data == null) return;

    await _downloadsBox.put(tourId, {
      ...Map<String, dynamic>.from(data),
      'status': 'failed',
      'error': error,
    });
  }

  /// Check if a tour is downloaded
  bool isDownloaded(String tourId) {
    final data = _downloadsBox.get(tourId);
    if (data == null) return false;

    final status = data['status'];
    if (status != 'complete') return false;

    // Check if expired
    final expiresAt = DateTime.tryParse(data['expiresAt'] ?? '');
    if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
      return false;
    }

    return true;
  }

  /// Get download status
  Map<String, dynamic>? getDownloadStatus(String tourId) {
    final data = _downloadsBox.get(tourId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Get all downloaded tours
  List<String> getDownloadedTourIds() {
    final ids = <String>[];
    for (final key in _downloadsBox.keys) {
      final data = _downloadsBox.get(key);
      if (data != null && data['status'] == 'complete') {
        // Check if expired
        final expiresAt = DateTime.tryParse(data['expiresAt'] ?? '');
        if (expiresAt == null || DateTime.now().isBefore(expiresAt)) {
          ids.add(key.toString());
        }
      }
    }
    return ids;
  }

  /// Delete a downloaded tour
  Future<void> deleteDownload(String tourId) async {
    await _downloadsBox.delete(tourId);

    // Also delete cached data
    await _toursBox.delete(tourId);

    // Delete version and stop caches for this tour
    final keysToDelete = <String>[];
    for (final key in _versionsBox.keys) {
      if (key.toString().startsWith('${tourId}_')) {
        keysToDelete.add(key.toString());
      }
    }
    for (final key in keysToDelete) {
      await _versionsBox.delete(key);
    }

    keysToDelete.clear();
    for (final key in _stopsBox.keys) {
      if (key.toString().startsWith('${tourId}_')) {
        keysToDelete.add(key.toString());
      }
    }
    for (final key in keysToDelete) {
      await _stopsBox.delete(key);
    }

    // Delete local files
    await _deleteLocalFiles(tourId);
  }

  Future<void> _deleteLocalFiles(String tourId) async {
    if (kIsWeb) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final tourDir = Directory('${dir.path}/tours/$tourId');
      if (await tourDir.exists()) {
        await tourDir.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error deleting local files: $e');
    }
  }

  // ==================== User Progress ====================

  /// Save user progress for a tour
  Future<void> saveProgress({
    required String tourId,
    required String versionId,
    required int currentStopIndex,
    required List<int> completedStops,
    required String status, // 'in_progress', 'completed', 'paused'
  }) async {
    await _progressBox.put(tourId, {
      'tourId': tourId,
      'versionId': versionId,
      'currentStopIndex': currentStopIndex,
      'completedStops': completedStops,
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get user progress for a tour
  Map<String, dynamic>? getProgress(String tourId) {
    final data = _progressBox.get(tourId);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Clear progress for a tour
  Future<void> clearProgress(String tourId) async {
    await _progressBox.delete(tourId);
  }

  /// Get all in-progress tours
  List<String> getInProgressTourIds() {
    final ids = <String>[];
    for (final key in _progressBox.keys) {
      final data = _progressBox.get(key);
      if (data != null && data['status'] == 'in_progress') {
        ids.add(key.toString());
      }
    }
    return ids;
  }

  // ==================== Settings ====================

  /// Save a setting
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get a setting
  T? getSetting<T>(String key, {T? defaultValue}) {
    final value = _settingsBox.get(key);
    if (value == null) return defaultValue;
    return value as T;
  }

  // ==================== Cleanup ====================

  /// Clear all expired data
  Future<void> cleanupExpired() async {
    // Clean up expired downloads
    final expiredDownloads = <String>[];
    for (final key in _downloadsBox.keys) {
      final data = _downloadsBox.get(key);
      if (data != null) {
        final expiresAt = DateTime.tryParse(data['expiresAt'] ?? '');
        if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
          expiredDownloads.add(key.toString());
        }
      }
    }
    for (final tourId in expiredDownloads) {
      await deleteDownload(tourId);
    }

    // Clean up expired cache (older than 24 hours)
    final oneDayAgo = DateTime.now().subtract(const Duration(hours: 24));
    final expiredTours = <String>[];
    for (final key in _toursBox.keys) {
      final data = _toursBox.get(key);
      if (data != null) {
        final cachedAt = DateTime.tryParse(data['cachedAt'] ?? '');
        if (cachedAt != null && cachedAt.isBefore(oneDayAgo)) {
          expiredTours.add(key.toString());
        }
      }
    }
    for (final tourId in expiredTours) {
      await _toursBox.delete(tourId);
    }
  }

  /// Get total cache size
  Future<int> getCacheSize() async {
    if (kIsWeb) return 0;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/tours');
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0;
    }
  }

  /// Clear all offline data
  Future<void> clearAll() async {
    await _toursBox.clear();
    await _versionsBox.clear();
    await _stopsBox.clear();
    await _downloadsBox.clear();
    await _progressBox.clear();

    // Delete local files
    if (!kIsWeb) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final cacheDir = Directory('${dir.path}/tours');
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
        }
      } catch (e) {
        debugPrint('Error clearing local files: $e');
      }
    }
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }
}

/// Provider for offline storage service
final offlineStorageServiceProvider = Provider<OfflineStorageService>((ref) {
  return OfflineStorageService();
});

/// Provider for offline storage initialization state
final offlineStorageInitializedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(offlineStorageServiceProvider);
  await service.initialize();
  return true;
});
