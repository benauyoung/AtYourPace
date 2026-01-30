import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../models/tour_analytics_model.dart';

/// Repository for managing tour analytics data.
class AnalyticsRepository {
  final FirebaseFirestore _firestore;

  AnalyticsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Gets the analytics collection reference for a tour.
  CollectionReference<Map<String, dynamic>> _analyticsRef(String tourId) =>
      _firestore
          .collection(FirestoreCollections.analytics)
          .doc(tourId)
          .collection(FirestoreCollections.analyticsPeriods);

  /// Gets a specific analytics document reference.
  DocumentReference<Map<String, dynamic>> _analyticsDocRef(
    String tourId,
    String periodId,
  ) =>
      _analyticsRef(tourId).doc(periodId);

  // ==================== CRUD Operations ====================

  /// Creates or updates analytics data.
  Future<TourAnalyticsModel> save({
    required String tourId,
    required TourAnalyticsModel analytics,
  }) async {
    final docRef = _analyticsDocRef(tourId, analytics.id);

    await docRef.set(analytics.toFirestore(), SetOptions(merge: true));
    return analytics;
  }

  /// Gets analytics for a specific period.
  Future<TourAnalyticsModel?> get({
    required String tourId,
    required String periodId,
  }) async {
    final doc = await _analyticsDocRef(tourId, periodId).get();
    if (!doc.exists) return null;
    return TourAnalyticsModel.fromFirestore(doc);
  }

  /// Gets analytics for a period type (day, week, month, etc.).
  Future<TourAnalyticsModel?> getByPeriod({
    required String tourId,
    required AnalyticsPeriod period,
  }) async {
    final periodId = _getPeriodId(tourId, period);
    return get(tourId: tourId, periodId: periodId);
  }

  /// Gets analytics with caching support.
  Future<TourAnalyticsModel?> getCached({
    required String tourId,
    required AnalyticsPeriod period,
  }) async {
    final analytics = await getByPeriod(tourId: tourId, period: period);

    if (analytics != null && analytics.isCacheValid) {
      return analytics;
    }

    return null;
  }

  /// Deletes analytics for a period.
  Future<void> delete({
    required String tourId,
    required String periodId,
  }) async {
    await _analyticsDocRef(tourId, periodId).delete();
  }

  /// Deletes all analytics for a tour.
  Future<void> deleteAllForTour(String tourId) async {
    final snapshot = await _analyticsRef(tourId).get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // ==================== Query Methods ====================

  /// Gets all analytics periods for a tour.
  Future<List<TourAnalyticsModel>> getAllForTour(String tourId) async {
    final snapshot = await _analyticsRef(tourId)
        .orderBy('generatedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TourAnalyticsModel.fromFirestore(doc))
        .toList();
  }

  /// Gets analytics history for a specific metric.
  Future<List<TourAnalyticsModel>> getHistory({
    required String tourId,
    required AnalyticsPeriod period,
    int limit = 30,
  }) async {
    final snapshot = await _analyticsRef(tourId)
        .where('period', isEqualTo: period.name)
        .orderBy('startDate', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => TourAnalyticsModel.fromFirestore(doc))
        .toList();
  }

  /// Gets analytics for multiple tours (for dashboard).
  Future<Map<String, TourAnalyticsModel>> getMultipleTours({
    required List<String> tourIds,
    required AnalyticsPeriod period,
  }) async {
    final results = <String, TourAnalyticsModel>{};

    for (final tourId in tourIds) {
      final analytics = await getByPeriod(tourId: tourId, period: period);
      if (analytics != null) {
        results[tourId] = analytics;
      }
    }

    return results;
  }

  // ==================== Aggregation Methods ====================

  /// Aggregates analytics for a creator (all their tours).
  Future<TourAnalyticsModel> aggregateForCreator({
    required String creatorId,
    required List<String> tourIds,
    required AnalyticsPeriod period,
  }) async {
    final analytics = await getMultipleTours(tourIds: tourIds, period: period);

    if (analytics.isEmpty) {
      return TourAnalyticsModel.empty(
        id: 'creator_$creatorId',
        tourId: 'aggregate',
        period: period,
        startDate: period.getDateRange().$1,
        endDate: period.getDateRange().$2,
      );
    }

    // Aggregate all metrics
    int totalPlays = 0;
    int totalUniquePlays = 0;
    double totalAvgDuration = 0;
    int totalCompletions = 0;
    int totalDownloads = 0;
    int totalUniqueDownloads = 0;
    double totalStorageUsed = 0;
    int totalFavorites = 0;
    double totalRevenue = 0;
    int totalTransactions = 0;
    int totalReviews = 0;
    double totalRating = 0;

    for (final a in analytics.values) {
      totalPlays += a.plays.total;
      totalUniquePlays += a.plays.unique;
      totalAvgDuration += a.plays.averageDuration;
      totalCompletions += a.plays.completions;
      totalDownloads += a.downloads.total;
      totalUniqueDownloads += a.downloads.unique;
      totalStorageUsed += a.downloads.storageUsed;
      totalFavorites += a.favorites.total;
      totalRevenue += a.revenue.total;
      totalTransactions += a.revenue.transactions;
      totalReviews += a.feedback.totalReviews;
      if (a.feedback.totalReviews > 0) {
        totalRating += a.feedback.averageRating * a.feedback.totalReviews;
      }
    }

    final count = analytics.length;
    final avgRating = totalReviews > 0 ? totalRating / totalReviews : 0.0;
    final avgCompletionRate = analytics.values
            .map((a) => a.completion.completionRate)
            .fold(0.0, (a, b) => a + b) /
        count;

    final dateRange = period.getDateRange();

    return TourAnalyticsModel(
      id: 'creator_$creatorId',
      tourId: 'aggregate',
      period: period,
      startDate: dateRange.$1,
      endDate: dateRange.$2,
      plays: PlayMetrics(
        total: totalPlays,
        unique: totalUniquePlays,
        averageDuration: count > 0 ? totalAvgDuration / count : 0,
        completions: totalCompletions,
        completionRate: avgCompletionRate,
        changeFromPrevious: 0,
      ),
      downloads: DownloadMetrics(
        total: totalDownloads,
        unique: totalUniqueDownloads,
        storageUsed: totalStorageUsed,
        changeFromPrevious: 0,
      ),
      favorites: FavoriteMetrics(
        total: totalFavorites,
        changeFromPrevious: 0,
      ),
      revenue: RevenueMetrics(
        total: totalRevenue,
        transactions: totalTransactions,
        averageTransaction:
            totalTransactions > 0 ? totalRevenue / totalTransactions : 0,
        changeFromPrevious: 0,
      ),
      completion: CompletionMetrics(
        completionRate: avgCompletionRate,
        dropOffByStop: const {},
        averageCompletionTime: 0,
      ),
      geographic: const GeographicMetrics(
        byCity: {},
        byCountry: {},
      ),
      timeSeries: const TimeSeriesData(
        plays: [],
        downloads: [],
        favorites: [],
      ),
      feedback: UserFeedbackMetrics(
        averageRating: avgRating,
        totalReviews: totalReviews,
        ratingDistribution: const {},
      ),
      generatedAt: DateTime.now(),
    );
  }

  // ==================== Update Methods ====================

  /// Increments play count.
  Future<void> incrementPlays({
    required String tourId,
    required String periodId,
    bool isUnique = false,
  }) async {
    await _analyticsDocRef(tourId, periodId).set({
      'plays': {
        'total': FieldValue.increment(1),
        if (isUnique) 'unique': FieldValue.increment(1),
      },
    }, SetOptions(merge: true));
  }

  /// Increments download count.
  Future<void> incrementDownloads({
    required String tourId,
    required String periodId,
    bool isUnique = false,
    double storageUsed = 0,
  }) async {
    await _analyticsDocRef(tourId, periodId).set({
      'downloads': {
        'total': FieldValue.increment(1),
        if (isUnique) 'unique': FieldValue.increment(1),
        if (storageUsed > 0) 'storageUsed': FieldValue.increment(storageUsed),
      },
    }, SetOptions(merge: true));
  }

  /// Increments favorite count.
  Future<void> incrementFavorites({
    required String tourId,
    required String periodId,
    int delta = 1,
  }) async {
    await _analyticsDocRef(tourId, periodId).set({
      'favorites': {
        'total': FieldValue.increment(delta),
      },
    }, SetOptions(merge: true));
  }

  /// Records a completion.
  Future<void> recordCompletion({
    required String tourId,
    required String periodId,
    required int completionTime,
  }) async {
    await _analyticsDocRef(tourId, periodId).set({
      'plays': {
        'completions': FieldValue.increment(1),
      },
    }, SetOptions(merge: true));
  }

  /// Records a drop-off at a specific stop.
  Future<void> recordDropOff({
    required String tourId,
    required String periodId,
    required int stopIndex,
  }) async {
    await _analyticsDocRef(tourId, periodId).set({
      'completion': {
        'dropOffByStop': {
          stopIndex.toString(): FieldValue.increment(1),
        },
      },
    }, SetOptions(merge: true));
  }

  // ==================== Helper Methods ====================

  /// Generates a period ID for consistent naming.
  String _getPeriodId(String tourId, AnalyticsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case AnalyticsPeriod.day:
        return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      case AnalyticsPeriod.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return 'week-${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
      case AnalyticsPeriod.month:
        return 'month-${now.year}-${now.month.toString().padLeft(2, '0')}';
      case AnalyticsPeriod.quarter:
        final quarter = ((now.month - 1) ~/ 3) + 1;
        return 'quarter-${now.year}-Q$quarter';
      case AnalyticsPeriod.year:
        return 'year-${now.year}';
      case AnalyticsPeriod.allTime:
        return 'all-time';
      case AnalyticsPeriod.custom:
        return 'custom-${now.millisecondsSinceEpoch}';
    }
  }

  /// Gets the current period ID.
  String getCurrentPeriodId(String tourId, AnalyticsPeriod period) {
    return _getPeriodId(tourId, period);
  }

  // ==================== Stream Methods ====================

  /// Watches analytics for a tour.
  Stream<TourAnalyticsModel?> watchAnalytics({
    required String tourId,
    required AnalyticsPeriod period,
  }) {
    final periodId = _getPeriodId(tourId, period);
    return _analyticsDocRef(tourId, periodId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TourAnalyticsModel.fromFirestore(doc);
    });
  }

  /// Watches all analytics periods for a tour.
  Stream<List<TourAnalyticsModel>> watchAllForTour(String tourId) {
    return _analyticsRef(tourId)
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TourAnalyticsModel.fromFirestore(doc))
          .toList();
    });
  }
}
