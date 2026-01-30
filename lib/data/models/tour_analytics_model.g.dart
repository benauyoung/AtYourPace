// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TourAnalyticsModelImpl _$$TourAnalyticsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TourAnalyticsModelImpl(
      id: json['id'] as String,
      tourId: json['tourId'] as String,
      period: $enumDecode(_$AnalyticsPeriodEnumMap, json['period']),
      startDate: const TimestampConverter().fromJson(json['startDate']),
      endDate: const TimestampConverter().fromJson(json['endDate']),
      plays: PlayMetrics.fromJson(json['plays'] as Map<String, dynamic>),
      downloads:
          DownloadMetrics.fromJson(json['downloads'] as Map<String, dynamic>),
      favorites:
          FavoriteMetrics.fromJson(json['favorites'] as Map<String, dynamic>),
      revenue: RevenueMetrics.fromJson(json['revenue'] as Map<String, dynamic>),
      completion: CompletionMetrics.fromJson(
          json['completion'] as Map<String, dynamic>),
      geographic: GeographicMetrics.fromJson(
          json['geographic'] as Map<String, dynamic>),
      timeSeries:
          TimeSeriesData.fromJson(json['timeSeries'] as Map<String, dynamic>),
      feedback: UserFeedbackMetrics.fromJson(
          json['feedback'] as Map<String, dynamic>),
      generatedAt: const TimestampConverter().fromJson(json['generatedAt']),
      cachedUntil:
          const NullableTimestampConverter().fromJson(json['cachedUntil']),
    );

Map<String, dynamic> _$$TourAnalyticsModelImplToJson(
        _$TourAnalyticsModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tourId': instance.tourId,
      'period': _$AnalyticsPeriodEnumMap[instance.period]!,
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
      'plays': instance.plays,
      'downloads': instance.downloads,
      'favorites': instance.favorites,
      'revenue': instance.revenue,
      'completion': instance.completion,
      'geographic': instance.geographic,
      'timeSeries': instance.timeSeries,
      'feedback': instance.feedback,
      'generatedAt': const TimestampConverter().toJson(instance.generatedAt),
      'cachedUntil':
          const NullableTimestampConverter().toJson(instance.cachedUntil),
    };

const _$AnalyticsPeriodEnumMap = {
  AnalyticsPeriod.day: 'day',
  AnalyticsPeriod.week: 'week',
  AnalyticsPeriod.month: 'month',
  AnalyticsPeriod.quarter: 'quarter',
  AnalyticsPeriod.year: 'year',
  AnalyticsPeriod.allTime: 'all_time',
  AnalyticsPeriod.custom: 'custom',
};

_$PlayMetricsImpl _$$PlayMetricsImplFromJson(Map<String, dynamic> json) =>
    _$PlayMetricsImpl(
      total: (json['total'] as num).toInt(),
      unique: (json['unique'] as num).toInt(),
      averageDuration: (json['averageDuration'] as num).toDouble(),
      completions: (json['completions'] as num).toInt(),
      completionRate: (json['completionRate'] as num).toDouble(),
      changeFromPrevious: (json['changeFromPrevious'] as num).toDouble(),
    );

Map<String, dynamic> _$$PlayMetricsImplToJson(_$PlayMetricsImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'unique': instance.unique,
      'averageDuration': instance.averageDuration,
      'completions': instance.completions,
      'completionRate': instance.completionRate,
      'changeFromPrevious': instance.changeFromPrevious,
    };

_$DownloadMetricsImpl _$$DownloadMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$DownloadMetricsImpl(
      total: (json['total'] as num).toInt(),
      unique: (json['unique'] as num).toInt(),
      storageUsed: (json['storageUsed'] as num).toDouble(),
      changeFromPrevious: (json['changeFromPrevious'] as num).toDouble(),
    );

Map<String, dynamic> _$$DownloadMetricsImplToJson(
        _$DownloadMetricsImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'unique': instance.unique,
      'storageUsed': instance.storageUsed,
      'changeFromPrevious': instance.changeFromPrevious,
    };

_$FavoriteMetricsImpl _$$FavoriteMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$FavoriteMetricsImpl(
      total: (json['total'] as num).toInt(),
      changeFromPrevious: (json['changeFromPrevious'] as num).toDouble(),
    );

Map<String, dynamic> _$$FavoriteMetricsImplToJson(
        _$FavoriteMetricsImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'changeFromPrevious': instance.changeFromPrevious,
    };

_$RevenueMetricsImpl _$$RevenueMetricsImplFromJson(Map<String, dynamic> json) =>
    _$RevenueMetricsImpl(
      total: (json['total'] as num).toDouble(),
      transactions: (json['transactions'] as num).toInt(),
      averageTransaction: (json['averageTransaction'] as num).toDouble(),
      byPricingTier: (json['byPricingTier'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      changeFromPrevious: (json['changeFromPrevious'] as num).toDouble(),
    );

Map<String, dynamic> _$$RevenueMetricsImplToJson(
        _$RevenueMetricsImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'transactions': instance.transactions,
      'averageTransaction': instance.averageTransaction,
      'byPricingTier': instance.byPricingTier,
      'changeFromPrevious': instance.changeFromPrevious,
    };

_$CompletionMetricsImpl _$$CompletionMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$CompletionMetricsImpl(
      completionRate: (json['completionRate'] as num).toDouble(),
      dropOffByStop: (json['dropOffByStop'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
      averageCompletionTime: (json['averageCompletionTime'] as num).toDouble(),
    );

Map<String, dynamic> _$$CompletionMetricsImplToJson(
        _$CompletionMetricsImpl instance) =>
    <String, dynamic>{
      'completionRate': instance.completionRate,
      'dropOffByStop':
          instance.dropOffByStop.map((k, e) => MapEntry(k.toString(), e)),
      'averageCompletionTime': instance.averageCompletionTime,
    };

_$GeographicMetricsImpl _$$GeographicMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$GeographicMetricsImpl(
      byCity: Map<String, int>.from(json['byCity'] as Map),
      byCountry: Map<String, int>.from(json['byCountry'] as Map),
    );

Map<String, dynamic> _$$GeographicMetricsImplToJson(
        _$GeographicMetricsImpl instance) =>
    <String, dynamic>{
      'byCity': instance.byCity,
      'byCountry': instance.byCountry,
    };

_$TimeSeriesDataImpl _$$TimeSeriesDataImplFromJson(Map<String, dynamic> json) =>
    _$TimeSeriesDataImpl(
      plays: (json['plays'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      downloads: (json['downloads'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      favorites: (json['favorites'] as List<dynamic>)
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TimeSeriesDataImplToJson(
        _$TimeSeriesDataImpl instance) =>
    <String, dynamic>{
      'plays': instance.plays,
      'downloads': instance.downloads,
      'favorites': instance.favorites,
    };

_$TimeSeriesPointImpl _$$TimeSeriesPointImplFromJson(
        Map<String, dynamic> json) =>
    _$TimeSeriesPointImpl(
      date: const TimestampConverter().fromJson(json['date']),
      value: (json['value'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeSeriesPointImplToJson(
        _$TimeSeriesPointImpl instance) =>
    <String, dynamic>{
      'date': const TimestampConverter().toJson(instance.date),
      'value': instance.value,
    };

_$UserFeedbackMetricsImpl _$$UserFeedbackMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$UserFeedbackMetricsImpl(
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      ratingDistribution:
          (json['ratingDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toInt()),
      ),
    );

Map<String, dynamic> _$$UserFeedbackMetricsImplToJson(
        _$UserFeedbackMetricsImpl instance) =>
    <String, dynamic>{
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'ratingDistribution':
          instance.ratingDistribution.map((k, e) => MapEntry(k.toString(), e)),
    };
