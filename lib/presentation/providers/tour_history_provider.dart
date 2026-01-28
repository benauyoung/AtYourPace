import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../data/models/tour_model.dart';
import 'tour_providers.dart';

/// Record of a tour view
class TourViewRecord {
  final String tourId;
  final DateTime viewedAt;
  final int? progressPercent; // 0-100, null if just viewed
  final bool completed;

  TourViewRecord({
    required this.tourId,
    required this.viewedAt,
    this.progressPercent,
    this.completed = false,
  });

  factory TourViewRecord.fromFirestore(Map<String, dynamic> data) {
    return TourViewRecord(
      tourId: data['tourId'] as String,
      viewedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progressPercent: data['progressPercent'] as int?,
      completed: data['completed'] as bool? ?? false,
    );
  }

  TourViewRecord copyWith({
    String? tourId,
    DateTime? viewedAt,
    int? progressPercent,
    bool? completed,
  }) {
    return TourViewRecord(
      tourId: tourId ?? this.tourId,
      viewedAt: viewedAt ?? this.viewedAt,
      progressPercent: progressPercent ?? this.progressPercent,
      completed: completed ?? this.completed,
    );
  }
}

/// Provider for managing tour view history
final tourHistoryProvider = StateNotifierProvider<TourHistoryNotifier, List<TourViewRecord>>((ref) {
  return TourHistoryNotifier(ref);
});

class TourHistoryNotifier extends StateNotifier<List<TourViewRecord>> {
  final Ref _ref;

  TourHistoryNotifier(this._ref) : super(AppConfig.demoMode ? _demoHistory : []) {
    _loadHistory();
  }

  // Demo history only used when AppConfig.demoMode is true
  static final List<TourViewRecord> _demoHistory = [
    TourViewRecord(
      tourId: 'demo-tour-1',
      viewedAt: DateTime.now().subtract(const Duration(hours: 2)),
      progressPercent: 75,
      completed: false,
    ),
    TourViewRecord(
      tourId: 'demo-tour-2',
      viewedAt: DateTime.now().subtract(const Duration(days: 1)),
      progressPercent: 100,
      completed: true,
    ),
    TourViewRecord(
      tourId: 'demo-tour-3',
      viewedAt: DateTime.now().subtract(const Duration(days: 3)),
      progressPercent: 30,
      completed: false,
    ),
  ];

  /// Load history from ProgressService
  Future<void> _loadHistory() async {
    if (AppConfig.demoMode) return;

    final progressService = _ref.read(progressServiceProvider);
    if (progressService == null) return;

    try {
      // Get both in-progress and completed tours
      final inProgressData = await progressService.getInProgressTours();
      final completedData = await progressService.getCompletedTours();

      final records = <TourViewRecord>[];

      // Convert in-progress tours
      for (final data in inProgressData) {
        records.add(TourViewRecord.fromFirestore(data));
      }

      // Convert completed tours
      for (final data in completedData) {
        records.add(TourViewRecord.fromFirestore(data));
      }

      // Sort by viewed date (most recent first)
      records.sort((a, b) => b.viewedAt.compareTo(a.viewedAt));

      // Take only the most recent 20
      state = records.take(20).toList();
    } catch (e) {
      // Keep current state on error (empty list in Firebase mode)
      debugPrint('Failed to load tour history: $e');
    }
  }

  void recordView(String tourId) {
    // Remove existing record for this tour if any
    final existingIndex = state.indexWhere((r) => r.tourId == tourId);

    final newRecord = TourViewRecord(
      tourId: tourId,
      viewedAt: DateTime.now(),
      progressPercent: existingIndex >= 0 ? state[existingIndex].progressPercent : null,
      completed: existingIndex >= 0 ? state[existingIndex].completed : false,
    );

    if (existingIndex >= 0) {
      // Move to front
      final newList = [...state];
      newList.removeAt(existingIndex);
      newList.insert(0, newRecord);
      state = newList;
    } else {
      // Add to front, limit to 20 items
      state = [newRecord, ...state.take(19)];
    }

    _persistToStorage();
  }

  void updateProgress(String tourId, int progressPercent, {bool completed = false}) {
    final index = state.indexWhere((r) => r.tourId == tourId);
    if (index >= 0) {
      final newList = [...state];
      newList[index] = newList[index].copyWith(
        progressPercent: progressPercent,
        completed: completed,
      );
      state = newList;
    } else {
      // Create new record
      state = [
        TourViewRecord(
          tourId: tourId,
          viewedAt: DateTime.now(),
          progressPercent: progressPercent,
          completed: completed,
        ),
        ...state.take(19),
      ];
    }
    _persistToStorage();
  }

  void clearHistory() {
    state = [];
    _persistToStorage();
  }

  void removeFromHistory(String tourId) {
    state = state.where((r) => r.tourId != tourId).toList();
    _persistToStorage();
  }

  Future<void> _persistToStorage() async {
    // Note: Persistence is handled by ProgressService when tours are played.
    // History is a read-only view of progress data.
    // This method is kept for local state updates in demo mode.
    if (!AppConfig.demoMode) {
      // Optionally refresh from Firestore to keep in sync
      await _loadHistory();
    }
  }
}

/// Get recently viewed tours with full tour data
final recentlyViewedToursProvider = FutureProvider<List<(TourModel, TourViewRecord)>>((ref) async {
  final history = ref.watch(tourHistoryProvider);
  final allTours = await ref.watch(featuredToursProvider.future);

  final result = <(TourModel, TourViewRecord)>[];

  for (final record in history) {
    final tour = allTours.where((t) => t.id == record.tourId).firstOrNull;
    if (tour != null) {
      result.add((tour, record));
    }
  }

  return result;
});

/// Get in-progress tours (started but not completed)
final inProgressToursProvider = FutureProvider<List<(TourModel, TourViewRecord)>>((ref) async {
  final recentTours = await ref.watch(recentlyViewedToursProvider.future);
  return recentTours
      .where((item) => item.$2.progressPercent != null && !item.$2.completed)
      .toList();
});

/// Get completed tours
final completedToursProvider = FutureProvider<List<(TourModel, TourViewRecord)>>((ref) async {
  final recentTours = await ref.watch(recentlyViewedToursProvider.future);
  return recentTours.where((item) => item.$2.completed).toList();
});

/// Count of completed tours
final completedToursCountProvider = Provider<int>((ref) {
  final history = ref.watch(tourHistoryProvider);
  return history.where((r) => r.completed).length;
});
