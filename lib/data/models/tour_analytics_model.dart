import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'tour_analytics_model.freezed.dart';
part 'tour_analytics_model.g.dart';

enum AnalyticsPeriod {
  @JsonValue('day')
  day,
  @JsonValue('week')
  week,
  @JsonValue('month')
  month,
  @JsonValue('quarter')
  quarter,
  @JsonValue('year')
  year,
  @JsonValue('all_time')
  allTime,
  @JsonValue('custom')
  custom,
}

@freezed
class TourAnalyticsModel with _$TourAnalyticsModel {
  const TourAnalyticsModel._();

  const factory TourAnalyticsModel({
    required String id,
    required String tourId,
    required AnalyticsPeriod period,
    @TimestampConverter() required DateTime startDate,
    @TimestampConverter() required DateTime endDate,
    required PlayMetrics plays,
    required DownloadMetrics downloads,
    required FavoriteMetrics favorites,
    required RevenueMetrics revenue,
    required CompletionMetrics completion,
    required GeographicMetrics geographic,
    required TimeSeriesData timeSeries,
    required UserFeedbackMetrics feedback,
    @TimestampConverter() required DateTime generatedAt,
    @NullableTimestampConverter() DateTime? cachedUntil,
  }) = _TourAnalyticsModel;

  factory TourAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$TourAnalyticsModelFromJson(json);

  factory TourAnalyticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourAnalyticsModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Check if the cached data is still valid
  bool get isCacheValid {
    if (cachedUntil == null) return false;
    return DateTime.now().isBefore(cachedUntil!);
  }

  /// Get the period display name
  String get periodDisplay {
    switch (period) {
      case AnalyticsPeriod.day:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.quarter:
        return 'This Quarter';
      case AnalyticsPeriod.year:
        return 'This Year';
      case AnalyticsPeriod.allTime:
        return 'All Time';
      case AnalyticsPeriod.custom:
        return 'Custom Range';
    }
  }

  /// Get overall engagement score (0-100)
  double get engagementScore {
    // Simple weighted average of key metrics
    final completionScore = completion.completionRate * 40;
    final playScore = (plays.total > 0 ? 1 : 0) * 20;
    final downloadScore = (downloads.total > 0 ? 1 : 0) * 20;
    final ratingScore = (feedback.averageRating / 5) * 20;
    return completionScore + playScore + downloadScore + ratingScore;
  }

  /// Create empty analytics for a tour
  factory TourAnalyticsModel.empty({
    required String id,
    required String tourId,
    required AnalyticsPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return TourAnalyticsModel(
      id: id,
      tourId: tourId,
      period: period,
      startDate: startDate,
      endDate: endDate,
      plays: const PlayMetrics(
        total: 0,
        unique: 0,
        averageDuration: 0,
        completions: 0,
        completionRate: 0,
        changeFromPrevious: 0,
      ),
      downloads: const DownloadMetrics(
        total: 0,
        unique: 0,
        storageUsed: 0,
        changeFromPrevious: 0,
      ),
      favorites: const FavoriteMetrics(
        total: 0,
        changeFromPrevious: 0,
      ),
      revenue: const RevenueMetrics(
        total: 0,
        transactions: 0,
        averageTransaction: 0,
        byPricingTier: {},
        changeFromPrevious: 0,
      ),
      completion: const CompletionMetrics(
        completionRate: 0,
        dropOffByStop: {},
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
      feedback: const UserFeedbackMetrics(
        averageRating: 0,
        totalReviews: 0,
        ratingDistribution: {},
      ),
      generatedAt: DateTime.now(),
    );
  }
}

@freezed
class PlayMetrics with _$PlayMetrics {
  const PlayMetrics._();

  const factory PlayMetrics({
    required int total,
    required int unique,
    required double averageDuration,
    required int completions,
    required double completionRate,
    required double changeFromPrevious,
  }) = _PlayMetrics;

  factory PlayMetrics.fromJson(Map<String, dynamic> json) =>
      _$PlayMetricsFromJson(json);

  /// Format average duration as string
  String get averageDurationFormatted {
    final minutes = averageDuration ~/ 60;
    final seconds = (averageDuration % 60).toInt();
    return '${minutes}m ${seconds}s';
  }

  /// Check if metrics are trending up
  bool get isTrendingUp => changeFromPrevious > 0;

  /// Check if metrics are trending down
  bool get isTrendingDown => changeFromPrevious < 0;

  /// Get trend percentage formatted
  String get trendFormatted {
    final prefix = changeFromPrevious >= 0 ? '+' : '';
    return '$prefix${changeFromPrevious.toStringAsFixed(1)}%';
  }
}

@freezed
class DownloadMetrics with _$DownloadMetrics {
  const DownloadMetrics._();

  const factory DownloadMetrics({
    required int total,
    required int unique,
    required double storageUsed,
    required double changeFromPrevious,
  }) = _DownloadMetrics;

  factory DownloadMetrics.fromJson(Map<String, dynamic> json) =>
      _$DownloadMetricsFromJson(json);

  /// Format storage used as human-readable string
  String get storageFormatted {
    if (storageUsed < 1024) {
      return '${storageUsed.toStringAsFixed(0)} KB';
    } else if (storageUsed < 1024 * 1024) {
      return '${(storageUsed / 1024).toStringAsFixed(1)} MB';
    }
    return '${(storageUsed / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  bool get isTrendingUp => changeFromPrevious > 0;
  bool get isTrendingDown => changeFromPrevious < 0;

  String get trendFormatted {
    final prefix = changeFromPrevious >= 0 ? '+' : '';
    return '$prefix${changeFromPrevious.toStringAsFixed(1)}%';
  }
}

@freezed
class FavoriteMetrics with _$FavoriteMetrics {
  const FavoriteMetrics._();

  const factory FavoriteMetrics({
    required int total,
    required double changeFromPrevious,
  }) = _FavoriteMetrics;

  factory FavoriteMetrics.fromJson(Map<String, dynamic> json) =>
      _$FavoriteMetricsFromJson(json);

  bool get isTrendingUp => changeFromPrevious > 0;
  bool get isTrendingDown => changeFromPrevious < 0;

  String get trendFormatted {
    final prefix = changeFromPrevious >= 0 ? '+' : '';
    return '$prefix${changeFromPrevious.toStringAsFixed(1)}%';
  }
}

@freezed
class RevenueMetrics with _$RevenueMetrics {
  const RevenueMetrics._();

  const factory RevenueMetrics({
    required double total,
    required int transactions,
    required double averageTransaction,
    @Default({}) Map<String, double> byPricingTier,
    required double changeFromPrevious,
  }) = _RevenueMetrics;

  factory RevenueMetrics.fromJson(Map<String, dynamic> json) =>
      _$RevenueMetricsFromJson(json);

  /// Format total revenue as currency
  String get totalFormatted => '\$${total.toStringAsFixed(2)}';

  /// Format average transaction as currency
  String get averageFormatted => '\$${averageTransaction.toStringAsFixed(2)}';

  bool get isTrendingUp => changeFromPrevious > 0;
  bool get isTrendingDown => changeFromPrevious < 0;

  String get trendFormatted {
    final prefix = changeFromPrevious >= 0 ? '+' : '';
    return '$prefix${changeFromPrevious.toStringAsFixed(1)}%';
  }

  /// Check if there's any revenue
  bool get hasRevenue => total > 0;
}

@freezed
class CompletionMetrics with _$CompletionMetrics {
  const CompletionMetrics._();

  const factory CompletionMetrics({
    required double completionRate,
    required Map<int, int> dropOffByStop,
    required double averageCompletionTime,
  }) = _CompletionMetrics;

  factory CompletionMetrics.fromJson(Map<String, dynamic> json) =>
      _$CompletionMetricsFromJson(json);

  /// Format completion rate as percentage
  String get completionRateFormatted =>
      '${(completionRate * 100).toStringAsFixed(1)}%';

  /// Format average completion time
  String get averageTimeFormatted {
    final hours = averageCompletionTime ~/ 3600;
    final minutes = (averageCompletionTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Get the stop with highest drop-off
  int? get highestDropOffStop {
    if (dropOffByStop.isEmpty) return null;
    return dropOffByStop.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Check if completion rate is good (>70%)
  bool get isGoodCompletion => completionRate >= 0.7;

  /// Check if there's significant drop-off at any stop
  bool get hasSignificantDropOff {
    if (dropOffByStop.isEmpty) return false;
    final maxDropOff = dropOffByStop.values.reduce((a, b) => a > b ? a : b);
    return maxDropOff > 20; // More than 20% drop-off at any stop
  }
}

@freezed
class GeographicMetrics with _$GeographicMetrics {
  const GeographicMetrics._();

  const factory GeographicMetrics({
    required Map<String, int> byCity,
    required Map<String, int> byCountry,
  }) = _GeographicMetrics;

  factory GeographicMetrics.fromJson(Map<String, dynamic> json) =>
      _$GeographicMetricsFromJson(json);

  /// Get top N cities
  List<MapEntry<String, int>> topCities(int n) {
    final sorted = byCity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  /// Get top N countries
  List<MapEntry<String, int>> topCountries(int n) {
    final sorted = byCountry.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).toList();
  }

  /// Check if there's geographic data
  bool get hasData => byCity.isNotEmpty || byCountry.isNotEmpty;

  /// Get total unique locations
  int get uniqueLocations => byCity.length;

  /// Get total unique countries
  int get uniqueCountries => byCountry.length;
}

@freezed
class TimeSeriesData with _$TimeSeriesData {
  const TimeSeriesData._();

  const factory TimeSeriesData({
    required List<TimeSeriesPoint> plays,
    required List<TimeSeriesPoint> downloads,
    required List<TimeSeriesPoint> favorites,
  }) = _TimeSeriesData;

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesDataFromJson(json);

  /// Check if there's any data
  bool get hasData =>
      plays.isNotEmpty || downloads.isNotEmpty || favorites.isNotEmpty;

  /// Get total plays across all points
  int get totalPlays =>
      plays.fold(0, (acc, point) => acc + point.value);

  /// Get total downloads across all points
  int get totalDownloads =>
      downloads.fold(0, (acc, point) => acc + point.value);

  /// Get total favorites across all points
  int get totalFavorites =>
      favorites.fold(0, (acc, point) => acc + point.value);
}

@freezed
class TimeSeriesPoint with _$TimeSeriesPoint {
  const TimeSeriesPoint._();

  const factory TimeSeriesPoint({
    @TimestampConverter() required DateTime date,
    required int value,
  }) = _TimeSeriesPoint;

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesPointFromJson(json);

  /// Format date for display
  String get dateFormatted {
    return '${date.day}/${date.month}';
  }

  /// Format date for longer display
  String get dateLongFormatted {
    return '${date.day}/${date.month}/${date.year}';
  }
}

@freezed
class UserFeedbackMetrics with _$UserFeedbackMetrics {
  const UserFeedbackMetrics._();

  const factory UserFeedbackMetrics({
    required double averageRating,
    required int totalReviews,
    required Map<int, int> ratingDistribution,
  }) = _UserFeedbackMetrics;

  factory UserFeedbackMetrics.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackMetricsFromJson(json);

  /// Format average rating as string
  String get ratingFormatted => averageRating.toStringAsFixed(1);

  /// Check if rating is good (>=4.0)
  bool get isGoodRating => averageRating >= 4.0;

  /// Check if rating is excellent (>=4.5)
  bool get isExcellentRating => averageRating >= 4.5;

  /// Check if there are reviews
  bool get hasReviews => totalReviews > 0;

  /// Get percentage of 5-star ratings
  double get fiveStarPercentage {
    if (totalReviews == 0) return 0;
    return ((ratingDistribution[5] ?? 0) / totalReviews) * 100;
  }

  /// Get percentage of positive ratings (4-5 stars)
  double get positivePercentage {
    if (totalReviews == 0) return 0;
    final positive = (ratingDistribution[4] ?? 0) + (ratingDistribution[5] ?? 0);
    return (positive / totalReviews) * 100;
  }

  /// Get percentage of negative ratings (1-2 stars)
  double get negativePercentage {
    if (totalReviews == 0) return 0;
    final negative = (ratingDistribution[1] ?? 0) + (ratingDistribution[2] ?? 0);
    return (negative / totalReviews) * 100;
  }
}

extension AnalyticsPeriodExtension on AnalyticsPeriod {
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.day:
        return 'Today';
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.quarter:
        return 'This Quarter';
      case AnalyticsPeriod.year:
        return 'This Year';
      case AnalyticsPeriod.allTime:
        return 'All Time';
      case AnalyticsPeriod.custom:
        return 'Custom';
    }
  }

  String get shortName {
    switch (this) {
      case AnalyticsPeriod.day:
        return '1D';
      case AnalyticsPeriod.week:
        return '1W';
      case AnalyticsPeriod.month:
        return '1M';
      case AnalyticsPeriod.quarter:
        return '3M';
      case AnalyticsPeriod.year:
        return '1Y';
      case AnalyticsPeriod.allTime:
        return 'All';
      case AnalyticsPeriod.custom:
        return 'Custom';
    }
  }

  /// Get date range for this period
  (DateTime, DateTime) getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case AnalyticsPeriod.day:
        return (today, now);
      case AnalyticsPeriod.week:
        return (today.subtract(const Duration(days: 7)), now);
      case AnalyticsPeriod.month:
        return (DateTime(now.year, now.month - 1, now.day), now);
      case AnalyticsPeriod.quarter:
        return (DateTime(now.year, now.month - 3, now.day), now);
      case AnalyticsPeriod.year:
        return (DateTime(now.year - 1, now.month, now.day), now);
      case AnalyticsPeriod.allTime:
        return (DateTime(2020, 1, 1), now);
      case AnalyticsPeriod.custom:
        return (today, now); // Custom should be set explicitly
    }
  }
}
