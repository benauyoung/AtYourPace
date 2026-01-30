import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../data/models/tour_analytics_model.dart';
import '../data/repositories/analytics_repository.dart';

/// Service for aggregating and exporting analytics data.
class AnalyticsAggregationService {
  final FirebaseFirestore _firestore;
  final AnalyticsRepository _analyticsRepository;

  // In-memory cache
  final Map<String, _CachedAnalytics> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 5);

  AnalyticsAggregationService({
    required FirebaseFirestore firestore,
    required AnalyticsRepository analyticsRepository,
  })  : _firestore = firestore,
        _analyticsRepository = analyticsRepository;

  // ==================== Aggregation Methods ====================

  /// Gets analytics for a tour with caching.
  Future<TourAnalyticsModel> getAnalytics({
    required String tourId,
    required AnalyticsPeriod period,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${tourId}_${period.name}';

    // Check cache
    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        return cached.analytics;
      }
    }

    // Check Firestore cache
    if (!forceRefresh) {
      final cached = await _analyticsRepository.getCached(
        tourId: tourId,
        period: period,
      );
      if (cached != null) {
        _cache[cacheKey] = _CachedAnalytics(
          analytics: cached,
          timestamp: DateTime.now(),
        );
        return cached;
      }
    }

    // Aggregate fresh data
    final analytics = await _aggregateAnalytics(tourId: tourId, period: period);

    // Cache in memory
    _cache[cacheKey] = _CachedAnalytics(
      analytics: analytics,
      timestamp: DateTime.now(),
    );

    // Cache in Firestore
    await _analyticsRepository.save(tourId: tourId, analytics: analytics);

    return analytics;
  }

  /// Aggregates analytics for a tour from raw event data.
  Future<TourAnalyticsModel> _aggregateAnalytics({
    required String tourId,
    required AnalyticsPeriod period,
  }) async {
    final dateRange = period.getDateRange();
    final startDate = dateRange.$1;
    final endDate = dateRange.$2;

    // Get raw event data
    final plays = await _getPlayEvents(tourId, startDate, endDate);
    final downloads = await _getDownloadEvents(tourId, startDate, endDate);
    final favorites = await _getFavoriteCount(tourId);
    final reviews = await _getReviewData(tourId);

    // Calculate metrics
    final playMetrics = _calculatePlayMetrics(plays);
    final downloadMetrics = _calculateDownloadMetrics(downloads);
    final favoriteMetrics = FavoriteMetrics(
      total: favorites,
      changeFromPrevious: 0, // Would need previous period data
    );

    final completionMetrics = _calculateCompletionMetrics(plays);
    final geographicMetrics = _calculateGeographicMetrics(plays);
    final timeSeriesData = _calculateTimeSeries(plays, downloads, startDate, endDate);
    final feedbackMetrics = _calculateFeedbackMetrics(reviews);

    final periodId = _analyticsRepository.getCurrentPeriodId(tourId, period);

    return TourAnalyticsModel(
      id: periodId,
      tourId: tourId,
      period: period,
      startDate: startDate,
      endDate: endDate,
      plays: playMetrics,
      downloads: downloadMetrics,
      favorites: favoriteMetrics,
      revenue: const RevenueMetrics(
        total: 0,
        transactions: 0,
        averageTransaction: 0,
        changeFromPrevious: 0,
      ), // Placeholder until payments are implemented
      completion: completionMetrics,
      geographic: geographicMetrics,
      timeSeries: timeSeriesData,
      feedback: feedbackMetrics,
      generatedAt: DateTime.now(),
      cachedUntil: DateTime.now().add(_cacheDuration),
    );
  }

  // ==================== Data Fetching ====================

  Future<List<Map<String, dynamic>>> _getPlayEvents(
    String tourId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.tourProgress)
        .where('tourId', isEqualTo: tourId)
        .where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('startedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> _getDownloadEvents(
    String tourId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.downloads)
        .where('tourId', isEqualTo: tourId)
        .where('downloadedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('downloadedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<int> _getFavoriteCount(String tourId) async {
    // Assuming favorites are tracked in user documents or a favorites collection
    final snapshot = await _firestore
        .collectionGroup('favorites')
        .where('tourId', isEqualTo: tourId)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<List<Map<String, dynamic>>> _getReviewData(String tourId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .collection(FirestoreCollections.reviews)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ==================== Metric Calculations ====================

  PlayMetrics _calculatePlayMetrics(List<Map<String, dynamic>> plays) {
    if (plays.isEmpty) {
      return const PlayMetrics(
        total: 0,
        unique: 0,
        averageDuration: 0,
        completions: 0,
        completionRate: 0,
        changeFromPrevious: 0,
      );
    }

    final uniqueUsers = plays.map((p) => p['userId'] as String?).toSet();
    final completedPlays = plays.where((p) => p['completed'] == true).length;

    double totalDuration = 0;
    for (final play in plays) {
      final duration = play['duration'] as int?;
      if (duration != null) {
        totalDuration += duration;
      }
    }

    return PlayMetrics(
      total: plays.length,
      unique: uniqueUsers.length,
      averageDuration: plays.isNotEmpty ? totalDuration / plays.length : 0,
      completions: completedPlays,
      completionRate: plays.isNotEmpty ? completedPlays / plays.length : 0,
      changeFromPrevious: 0,
    );
  }

  DownloadMetrics _calculateDownloadMetrics(List<Map<String, dynamic>> downloads) {
    if (downloads.isEmpty) {
      return const DownloadMetrics(
        total: 0,
        unique: 0,
        storageUsed: 0,
        changeFromPrevious: 0,
      );
    }

    final uniqueUsers = downloads.map((d) => d['userId'] as String?).toSet();

    double totalStorage = 0;
    for (final download in downloads) {
      final size = download['sizeBytes'] as int?;
      if (size != null) {
        totalStorage += size / 1024; // Convert to KB
      }
    }

    return DownloadMetrics(
      total: downloads.length,
      unique: uniqueUsers.length,
      storageUsed: totalStorage,
      changeFromPrevious: 0,
    );
  }

  CompletionMetrics _calculateCompletionMetrics(List<Map<String, dynamic>> plays) {
    if (plays.isEmpty) {
      return const CompletionMetrics(
        completionRate: 0,
        dropOffByStop: {},
        averageCompletionTime: 0,
      );
    }

    final completedPlays = plays.where((p) => p['completed'] == true);
    final dropOffByStop = <int, int>{};

    for (final play in plays) {
      if (play['completed'] != true) {
        final lastStop = play['lastStopIndex'] as int?;
        if (lastStop != null) {
          dropOffByStop[lastStop] = (dropOffByStop[lastStop] ?? 0) + 1;
        }
      }
    }

    double totalCompletionTime = 0;
    int completionCount = 0;

    for (final play in completedPlays) {
      final duration = play['duration'] as int?;
      if (duration != null) {
        totalCompletionTime += duration;
        completionCount++;
      }
    }

    return CompletionMetrics(
      completionRate: plays.isNotEmpty ? completedPlays.length / plays.length : 0,
      dropOffByStop: dropOffByStop,
      averageCompletionTime: completionCount > 0 ? totalCompletionTime / completionCount : 0,
    );
  }

  GeographicMetrics _calculateGeographicMetrics(List<Map<String, dynamic>> plays) {
    final byCity = <String, int>{};
    final byCountry = <String, int>{};

    for (final play in plays) {
      final city = play['city'] as String?;
      final country = play['country'] as String?;

      if (city != null) {
        byCity[city] = (byCity[city] ?? 0) + 1;
      }
      if (country != null) {
        byCountry[country] = (byCountry[country] ?? 0) + 1;
      }
    }

    return GeographicMetrics(
      byCity: byCity,
      byCountry: byCountry,
    );
  }

  TimeSeriesData _calculateTimeSeries(
    List<Map<String, dynamic>> plays,
    List<Map<String, dynamic>> downloads,
    DateTime startDate,
    DateTime endDate,
  ) {
    final playsByDate = <DateTime, int>{};
    final downloadsByDate = <DateTime, int>{};

    for (final play in plays) {
      final timestamp = play['startedAt'] as Timestamp?;
      if (timestamp != null) {
        final date = DateTime(
          timestamp.toDate().year,
          timestamp.toDate().month,
          timestamp.toDate().day,
        );
        playsByDate[date] = (playsByDate[date] ?? 0) + 1;
      }
    }

    for (final download in downloads) {
      final timestamp = download['downloadedAt'] as Timestamp?;
      if (timestamp != null) {
        final date = DateTime(
          timestamp.toDate().year,
          timestamp.toDate().month,
          timestamp.toDate().day,
        );
        downloadsByDate[date] = (downloadsByDate[date] ?? 0) + 1;
      }
    }

    return TimeSeriesData(
      plays: playsByDate.entries
          .map((e) => TimeSeriesPoint(date: e.key, value: e.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date)),
      downloads: downloadsByDate.entries
          .map((e) => TimeSeriesPoint(date: e.key, value: e.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date)),
      favorites: const [], // Would need time-series favorite data
    );
  }

  UserFeedbackMetrics _calculateFeedbackMetrics(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) {
      return const UserFeedbackMetrics(
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: {},
      );
    }

    final ratingDistribution = <int, int>{};
    double totalRating = 0;

    for (final review in reviews) {
      final rating = review['rating'] as int?;
      if (rating != null) {
        totalRating += rating;
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }
    }

    return UserFeedbackMetrics(
      averageRating: reviews.isNotEmpty ? totalRating / reviews.length : 0,
      totalReviews: reviews.length,
      ratingDistribution: ratingDistribution,
    );
  }

  // ==================== CSV Export ====================

  /// Exports analytics data to CSV format.
  String exportToCsv(TourAnalyticsModel analytics) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Analytics Report for Tour: ${analytics.tourId}');
    buffer.writeln('Period: ${analytics.periodDisplay}');
    buffer.writeln('Generated: ${analytics.generatedAt.toIso8601String()}');
    buffer.writeln('');

    // Play Metrics
    buffer.writeln('PLAY METRICS');
    buffer.writeln('Total Plays,${analytics.plays.total}');
    buffer.writeln('Unique Plays,${analytics.plays.unique}');
    buffer.writeln('Average Duration (seconds),${analytics.plays.averageDuration.toStringAsFixed(1)}');
    buffer.writeln('Completions,${analytics.plays.completions}');
    buffer.writeln('Completion Rate,${(analytics.plays.completionRate * 100).toStringAsFixed(1)}%');
    buffer.writeln('');

    // Download Metrics
    buffer.writeln('DOWNLOAD METRICS');
    buffer.writeln('Total Downloads,${analytics.downloads.total}');
    buffer.writeln('Unique Downloads,${analytics.downloads.unique}');
    buffer.writeln('Storage Used (KB),${analytics.downloads.storageUsed.toStringAsFixed(1)}');
    buffer.writeln('');

    // Favorite Metrics
    buffer.writeln('FAVORITE METRICS');
    buffer.writeln('Total Favorites,${analytics.favorites.total}');
    buffer.writeln('');

    // Revenue Metrics
    buffer.writeln('REVENUE METRICS');
    buffer.writeln('Total Revenue,${analytics.revenue.totalFormatted}');
    buffer.writeln('Transactions,${analytics.revenue.transactions}');
    buffer.writeln('Average Transaction,${analytics.revenue.averageFormatted}');
    buffer.writeln('');

    // Completion Metrics
    buffer.writeln('COMPLETION METRICS');
    buffer.writeln('Completion Rate,${analytics.completion.completionRateFormatted}');
    buffer.writeln('Average Completion Time (seconds),${analytics.completion.averageCompletionTime.toStringAsFixed(1)}');
    buffer.writeln('');

    // Drop-off by Stop
    if (analytics.completion.dropOffByStop.isNotEmpty) {
      buffer.writeln('DROP-OFF BY STOP');
      buffer.writeln('Stop Index,Drop-offs');
      analytics.completion.dropOffByStop.forEach((stop, dropCount) {
        buffer.writeln('$stop,$dropCount');
      });
      buffer.writeln('');
    }

    // Geographic Metrics
    if (analytics.geographic.hasData) {
      buffer.writeln('GEOGRAPHIC METRICS');
      buffer.writeln('');
      buffer.writeln('By City');
      buffer.writeln('City,Count');
      analytics.geographic.byCity.forEach((city, cityCount) {
        buffer.writeln('$city,$cityCount');
      });
      buffer.writeln('');
      buffer.writeln('By Country');
      buffer.writeln('Country,Count');
      analytics.geographic.byCountry.forEach((country, countryCount) {
        buffer.writeln('$country,$countryCount');
      });
      buffer.writeln('');
    }

    // Time Series
    if (analytics.timeSeries.hasData) {
      buffer.writeln('TIME SERIES - PLAYS');
      buffer.writeln('Date,Plays');
      for (final point in analytics.timeSeries.plays) {
        buffer.writeln('${point.dateLongFormatted},${point.value}');
      }
      buffer.writeln('');

      buffer.writeln('TIME SERIES - DOWNLOADS');
      buffer.writeln('Date,Downloads');
      for (final point in analytics.timeSeries.downloads) {
        buffer.writeln('${point.dateLongFormatted},${point.value}');
      }
      buffer.writeln('');
    }

    // Feedback Metrics
    buffer.writeln('FEEDBACK METRICS');
    buffer.writeln('Average Rating,${analytics.feedback.ratingFormatted}');
    buffer.writeln('Total Reviews,${analytics.feedback.totalReviews}');
    buffer.writeln('');
    buffer.writeln('Rating Distribution');
    buffer.writeln('Stars,Count');
    for (var i = 5; i >= 1; i--) {
      buffer.writeln('$i,${analytics.feedback.ratingDistribution[i] ?? 0}');
    }

    return buffer.toString();
  }

  /// Exports multiple tour analytics to a single CSV.
  String exportMultipleToCsv(Map<String, TourAnalyticsModel> analyticsMap) {
    final buffer = StringBuffer();

    buffer.writeln('Tour ID,Total Plays,Unique Plays,Completions,Completion Rate,Downloads,Favorites,Avg Rating,Reviews');

    analyticsMap.forEach((tourId, analytics) {
      buffer.writeln(
        '$tourId,'
        '${analytics.plays.total},'
        '${analytics.plays.unique},'
        '${analytics.plays.completions},'
        '${(analytics.plays.completionRate * 100).toStringAsFixed(1)}%,'
        '${analytics.downloads.total},'
        '${analytics.favorites.total},'
        '${analytics.feedback.ratingFormatted},'
        '${analytics.feedback.totalReviews}',
      );
    });

    return buffer.toString();
  }

  // ==================== Cache Management ====================

  /// Clears the in-memory cache.
  void clearCache() {
    _cache.clear();
  }

  /// Clears cache for a specific tour.
  void clearCacheForTour(String tourId) {
    _cache.removeWhere((key, value) => key.startsWith(tourId));
  }

  /// Gets cache statistics.
  Map<String, dynamic> getCacheStats() {
    int validCount = 0;
    int expiredCount = 0;

    for (final entry in _cache.entries) {
      if (DateTime.now().difference(entry.value.timestamp) < _cacheDuration) {
        validCount++;
      } else {
        expiredCount++;
      }
    }

    return {
      'totalEntries': _cache.length,
      'validEntries': validCount,
      'expiredEntries': expiredCount,
    };
  }
}

/// Cached analytics entry.
class _CachedAnalytics {
  final TourAnalyticsModel analytics;
  final DateTime timestamp;

  _CachedAnalytics({
    required this.analytics,
    required this.timestamp,
  });
}
