import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../data/local/offline_storage_service.dart';
import '../presentation/providers/auth_provider.dart';

/// Connectivity status enum
enum ConnectivityStatus {
  online,
  offline,
  unknown,
}

/// Pending sync item types
enum SyncItemType {
  progress,
  tourStart,
  tourComplete,
  review,
}

/// Model for pending sync items
class PendingSyncItem {
  final String id;
  final SyncItemType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  PendingSyncItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory PendingSyncItem.fromJson(Map<String, dynamic> json) => PendingSyncItem(
        id: json['id'] as String,
        type: SyncItemType.values.firstWhere((e) => e.name == json['type']),
        data: Map<String, dynamic>.from(json['data'] as Map),
        createdAt: DateTime.parse(json['createdAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
      );

  PendingSyncItem incrementRetry() => PendingSyncItem(
        id: id,
        type: type,
        data: data,
        createdAt: createdAt,
        retryCount: retryCount + 1,
      );
}

/// Provider for connectivity status
final connectivityStatusProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier(ref);
});

/// Provider for pending sync count
final pendingSyncCountProvider = Provider<int>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.pendingCount;
});

/// Provider for sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final storage = ref.watch(offlineStorageServiceProvider);
  return SyncService(firestore: firestore, storage: storage);
});

/// Notifier for connectivity state
class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  final Ref _ref;
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityNotifier(this._ref) : super(ConnectivityStatus.unknown) {
    _connectivity = Connectivity();
    _init();
  }

  Future<void> _init() async {
    // Get initial status
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasOffline = state == ConnectivityStatus.offline;

    if (results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.offline;
    } else if (results.isEmpty) {
      state = ConnectivityStatus.unknown;
    } else {
      state = ConnectivityStatus.online;

      // Trigger sync when coming back online
      if (wasOffline) {
        _triggerSync();
      }
    }
  }

  void _triggerSync() {
    final syncService = _ref.read(syncServiceProvider);
    final currentUser = _ref.read(currentUserProvider).value;

    if (currentUser != null) {
      syncService.syncPendingItems(currentUser.uid);
    }
  }

  /// Check current connectivity
  Future<ConnectivityStatus> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    return state;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Service for syncing offline data
class SyncService {
  static const String _syncBoxName = 'pending_sync';
  static const int _maxRetries = 3;

  final FirebaseFirestore _firestore;
  final OfflineStorageService _storage;
  Box<Map>? _syncBox;
  bool _isSyncing = false;

  SyncService({
    required FirebaseFirestore firestore,
    required OfflineStorageService storage,
  })  : _firestore = firestore,
        _storage = storage;

  /// Initialize the sync box
  Future<void> initialize() async {
    if (_syncBox != null && _syncBox!.isOpen) return;
    _syncBox = await Hive.openBox<Map>(_syncBoxName);
  }

  /// Get count of pending sync items
  int get pendingCount => _syncBox?.length ?? 0;

  /// Add a progress update to sync queue
  Future<void> queueProgressUpdate({
    required String tourId,
    required String userId,
    required int currentStopIndex,
    required int progressPercent,
    int? totalStops,
  }) async {
    await initialize();

    final item = PendingSyncItem(
      id: '${userId}_${tourId}_progress_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncItemType.progress,
      data: {
        'tourId': tourId,
        'userId': userId,
        'currentStopIndex': currentStopIndex,
        'progressPercent': progressPercent,
        if (totalStops != null) 'totalStops': totalStops,
      },
      createdAt: DateTime.now(),
    );

    await _syncBox!.put(item.id, item.toJson());
    debugPrint('SyncService: Queued progress update for tour $tourId');
  }

  /// Add a tour start event to sync queue
  Future<void> queueTourStart({
    required String tourId,
    required String userId,
  }) async {
    await initialize();

    final item = PendingSyncItem(
      id: '${userId}_${tourId}_start_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncItemType.tourStart,
      data: {
        'tourId': tourId,
        'userId': userId,
      },
      createdAt: DateTime.now(),
    );

    await _syncBox!.put(item.id, item.toJson());
    debugPrint('SyncService: Queued tour start for $tourId');
  }

  /// Add a tour completion event to sync queue
  Future<void> queueTourComplete({
    required String tourId,
    required String userId,
    int? durationSeconds,
  }) async {
    await initialize();

    final item = PendingSyncItem(
      id: '${userId}_${tourId}_complete_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncItemType.tourComplete,
      data: {
        'tourId': tourId,
        'userId': userId,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
      },
      createdAt: DateTime.now(),
    );

    await _syncBox!.put(item.id, item.toJson());
    debugPrint('SyncService: Queued tour completion for $tourId');
  }

  /// Add a review to sync queue
  Future<void> queueReview({
    required String tourId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
  }) async {
    await initialize();

    final item = PendingSyncItem(
      id: '${userId}_${tourId}_review_${DateTime.now().millisecondsSinceEpoch}',
      type: SyncItemType.review,
      data: {
        'tourId': tourId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
      },
      createdAt: DateTime.now(),
    );

    await _syncBox!.put(item.id, item.toJson());
    debugPrint('SyncService: Queued review for tour $tourId');
  }

  /// Sync all pending items to Firestore
  Future<SyncResult> syncPendingItems(String userId) async {
    if (_isSyncing) {
      return SyncResult(synced: 0, failed: 0, remaining: pendingCount);
    }

    await initialize();

    if (_syncBox!.isEmpty) {
      return SyncResult(synced: 0, failed: 0, remaining: 0);
    }

    _isSyncing = true;
    int synced = 0;
    int failed = 0;
    final itemsToRemove = <String>[];
    final itemsToRetry = <String, PendingSyncItem>{};

    debugPrint('SyncService: Starting sync of ${_syncBox!.length} items');

    try {
      for (final key in _syncBox!.keys.toList()) {
        final data = _syncBox!.get(key);
        if (data == null) continue;

        try {
          final item = PendingSyncItem.fromJson(Map<String, dynamic>.from(data));

          // Only sync items belonging to this user
          if (item.data['userId'] != userId) continue;

          await _syncItem(item);
          itemsToRemove.add(key.toString());
          synced++;
          debugPrint('SyncService: Synced ${item.type.name} for tour ${item.data['tourId']}');
        } catch (e) {
          debugPrint('SyncService: Failed to sync item $key: $e');

          final item = PendingSyncItem.fromJson(Map<String, dynamic>.from(data));
          if (item.retryCount < _maxRetries) {
            itemsToRetry[key.toString()] = item.incrementRetry();
          } else {
            // Max retries reached, remove item
            itemsToRemove.add(key.toString());
            failed++;
            debugPrint('SyncService: Max retries reached for item $key, removing');
          }
        }
      }

      // Remove synced items
      for (final key in itemsToRemove) {
        await _syncBox!.delete(key);
      }

      // Update retry counts
      for (final entry in itemsToRetry.entries) {
        await _syncBox!.put(entry.key, entry.value.toJson());
      }

    } finally {
      _isSyncing = false;
    }

    final result = SyncResult(
      synced: synced,
      failed: failed,
      remaining: _syncBox!.length,
    );

    debugPrint('SyncService: Sync complete - ${result.synced} synced, ${result.failed} failed, ${result.remaining} remaining');
    return result;
  }

  Future<void> _syncItem(PendingSyncItem item) async {
    switch (item.type) {
      case SyncItemType.progress:
        await _syncProgress(item.data);
        break;
      case SyncItemType.tourStart:
        await _syncTourStart(item.data);
        break;
      case SyncItemType.tourComplete:
        await _syncTourComplete(item.data);
        break;
      case SyncItemType.review:
        await _syncReview(item.data);
        break;
    }
  }

  Future<void> _syncProgress(Map<String, dynamic> data) async {
    final userId = data['userId'] as String;
    final tourId = data['tourId'] as String;

    await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('progress')
        .doc(tourId)
        .set({
      'tourId': tourId,
      'currentStopIndex': data['currentStopIndex'],
      'progressPercent': data['progressPercent'],
      if (data['totalStops'] != null) 'totalStops': data['totalStops'],
      'lastPlayedAt': FieldValue.serverTimestamp(),
      'completed': false,
    }, SetOptions(merge: true));
  }

  Future<void> _syncTourStart(Map<String, dynamic> data) async {
    final userId = data['userId'] as String;
    final tourId = data['tourId'] as String;

    final batch = _firestore.batch();

    // Increment play count
    batch.update(
      _firestore.collection(FirestoreCollections.tours).doc(tourId),
      {'stats.totalPlays': FieldValue.increment(1)},
    );

    // Create progress entry if needed
    batch.set(
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('progress')
          .doc(tourId),
      {
        'tourId': tourId,
        'currentStopIndex': 0,
        'progressPercent': 0,
        'lastPlayedAt': FieldValue.serverTimestamp(),
        'completed': false,
        'startedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> _syncTourComplete(Map<String, dynamic> data) async {
    final userId = data['userId'] as String;
    final tourId = data['tourId'] as String;
    final durationSeconds = data['durationSeconds'] as int?;

    final batch = _firestore.batch();

    // Update progress
    batch.set(
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('progress')
          .doc(tourId),
      {
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
        'progressPercent': 100,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
      },
      SetOptions(merge: true),
    );

    // Increment completion count
    batch.update(
      _firestore.collection(FirestoreCollections.tours).doc(tourId),
      {'stats.completions': FieldValue.increment(1)},
    );

    await batch.commit();
  }

  Future<void> _syncReview(Map<String, dynamic> data) async {
    final tourId = data['tourId'] as String;
    final userId = data['userId'] as String;

    await _firestore
        .collection(FirestoreCollections.reviews)
        .doc('${tourId}_$userId')
        .set({
      'tourId': tourId,
      'userId': userId,
      'userName': data['userName'],
      'rating': data['rating'],
      'comment': data['comment'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update tour rating stats
    await _updateTourRatingStats(tourId);
  }

  Future<void> _updateTourRatingStats(String tourId) async {
    // Get all reviews for this tour
    final reviews = await _firestore
        .collection(FirestoreCollections.reviews)
        .where('tourId', isEqualTo: tourId)
        .get();

    if (reviews.docs.isEmpty) return;

    final ratings = reviews.docs.map((doc) => doc.data()['rating'] as int).toList();
    final average = ratings.reduce((a, b) => a + b) / ratings.length;

    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'stats.averageRating': average,
      'stats.totalRatings': ratings.length,
    });
  }

  /// Clear all pending sync items
  Future<void> clearPendingItems() async {
    await initialize();
    await _syncBox!.clear();
  }

  /// Get all pending items for debugging
  Future<List<PendingSyncItem>> getPendingItems() async {
    await initialize();
    return _syncBox!.values
        .map((data) => PendingSyncItem.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }
}

/// Result of a sync operation
class SyncResult {
  final int synced;
  final int failed;
  final int remaining;

  SyncResult({
    required this.synced,
    required this.failed,
    required this.remaining,
  });

  bool get hasFailures => failed > 0;
  bool get hasPending => remaining > 0;
  bool get isComplete => remaining == 0 && failed == 0;

  @override
  String toString() => 'SyncResult(synced: $synced, failed: $failed, remaining: $remaining)';
}
