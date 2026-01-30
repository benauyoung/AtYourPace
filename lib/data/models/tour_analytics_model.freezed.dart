// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tour_analytics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TourAnalyticsModel _$TourAnalyticsModelFromJson(Map<String, dynamic> json) {
  return _TourAnalyticsModel.fromJson(json);
}

/// @nodoc
mixin _$TourAnalyticsModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  AnalyticsPeriod get period => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get endDate => throw _privateConstructorUsedError;
  PlayMetrics get plays => throw _privateConstructorUsedError;
  DownloadMetrics get downloads => throw _privateConstructorUsedError;
  FavoriteMetrics get favorites => throw _privateConstructorUsedError;
  RevenueMetrics get revenue => throw _privateConstructorUsedError;
  CompletionMetrics get completion => throw _privateConstructorUsedError;
  GeographicMetrics get geographic => throw _privateConstructorUsedError;
  TimeSeriesData get timeSeries => throw _privateConstructorUsedError;
  UserFeedbackMetrics get feedback => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get generatedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get cachedUntil => throw _privateConstructorUsedError;

  /// Serializes this TourAnalyticsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TourAnalyticsModelCopyWith<TourAnalyticsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TourAnalyticsModelCopyWith<$Res> {
  factory $TourAnalyticsModelCopyWith(
          TourAnalyticsModel value, $Res Function(TourAnalyticsModel) then) =
      _$TourAnalyticsModelCopyWithImpl<$Res, TourAnalyticsModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      AnalyticsPeriod period,
      @TimestampConverter() DateTime startDate,
      @TimestampConverter() DateTime endDate,
      PlayMetrics plays,
      DownloadMetrics downloads,
      FavoriteMetrics favorites,
      RevenueMetrics revenue,
      CompletionMetrics completion,
      GeographicMetrics geographic,
      TimeSeriesData timeSeries,
      UserFeedbackMetrics feedback,
      @TimestampConverter() DateTime generatedAt,
      @NullableTimestampConverter() DateTime? cachedUntil});

  $PlayMetricsCopyWith<$Res> get plays;
  $DownloadMetricsCopyWith<$Res> get downloads;
  $FavoriteMetricsCopyWith<$Res> get favorites;
  $RevenueMetricsCopyWith<$Res> get revenue;
  $CompletionMetricsCopyWith<$Res> get completion;
  $GeographicMetricsCopyWith<$Res> get geographic;
  $TimeSeriesDataCopyWith<$Res> get timeSeries;
  $UserFeedbackMetricsCopyWith<$Res> get feedback;
}

/// @nodoc
class _$TourAnalyticsModelCopyWithImpl<$Res, $Val extends TourAnalyticsModel>
    implements $TourAnalyticsModelCopyWith<$Res> {
  _$TourAnalyticsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? period = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? plays = null,
    Object? downloads = null,
    Object? favorites = null,
    Object? revenue = null,
    Object? completion = null,
    Object? geographic = null,
    Object? timeSeries = null,
    Object? feedback = null,
    Object? generatedAt = null,
    Object? cachedUntil = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as AnalyticsPeriod,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      plays: null == plays
          ? _value.plays
          : plays // ignore: cast_nullable_to_non_nullable
              as PlayMetrics,
      downloads: null == downloads
          ? _value.downloads
          : downloads // ignore: cast_nullable_to_non_nullable
              as DownloadMetrics,
      favorites: null == favorites
          ? _value.favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as FavoriteMetrics,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as RevenueMetrics,
      completion: null == completion
          ? _value.completion
          : completion // ignore: cast_nullable_to_non_nullable
              as CompletionMetrics,
      geographic: null == geographic
          ? _value.geographic
          : geographic // ignore: cast_nullable_to_non_nullable
              as GeographicMetrics,
      timeSeries: null == timeSeries
          ? _value.timeSeries
          : timeSeries // ignore: cast_nullable_to_non_nullable
              as TimeSeriesData,
      feedback: null == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as UserFeedbackMetrics,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      cachedUntil: freezed == cachedUntil
          ? _value.cachedUntil
          : cachedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayMetricsCopyWith<$Res> get plays {
    return $PlayMetricsCopyWith<$Res>(_value.plays, (value) {
      return _then(_value.copyWith(plays: value) as $Val);
    });
  }

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DownloadMetricsCopyWith<$Res> get downloads {
    return $DownloadMetricsCopyWith<$Res>(_value.downloads, (value) {
      return _then(_value.copyWith(downloads: value) as $Val);
    });
  }

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FavoriteMetricsCopyWith<$Res> get favorites {
    return $FavoriteMetricsCopyWith<$Res>(_value.favorites, (value) {
      return _then(_value.copyWith(favorites: value) as $Val);
    });
  }

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RevenueMetricsCopyWith<$Res> get revenue {
    return $RevenueMetricsCopyWith<$Res>(_value.revenue, (value) {
      return _then(_value.copyWith(revenue: value) as $Val);
    });
  }

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CompletionMetricsCopyWith<$Res> get completion {
    return $CompletionMetricsCopyWith<$Res>(_value.completion, (value) {
      return _then(_value.copyWith(completion: value) as $Val);
    });
  }

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GeographicMetricsCopyWith<$Res> get geographic {
    return $GeographicMetricsCopyWith<$Res>(_value.geographic, (value) {
      return _then(_value.copyWith(geographic: value) as $Val);
    });
  }

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TimeSeriesDataCopyWith<$Res> get timeSeries {
    return $TimeSeriesDataCopyWith<$Res>(_value.timeSeries, (value) {
      return _then(_value.copyWith(timeSeries: value) as $Val);
    });
  }

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserFeedbackMetricsCopyWith<$Res> get feedback {
    return $UserFeedbackMetricsCopyWith<$Res>(_value.feedback, (value) {
      return _then(_value.copyWith(feedback: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TourAnalyticsModelImplCopyWith<$Res>
    implements $TourAnalyticsModelCopyWith<$Res> {
  factory _$$TourAnalyticsModelImplCopyWith(_$TourAnalyticsModelImpl value,
          $Res Function(_$TourAnalyticsModelImpl) then) =
      __$$TourAnalyticsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      AnalyticsPeriod period,
      @TimestampConverter() DateTime startDate,
      @TimestampConverter() DateTime endDate,
      PlayMetrics plays,
      DownloadMetrics downloads,
      FavoriteMetrics favorites,
      RevenueMetrics revenue,
      CompletionMetrics completion,
      GeographicMetrics geographic,
      TimeSeriesData timeSeries,
      UserFeedbackMetrics feedback,
      @TimestampConverter() DateTime generatedAt,
      @NullableTimestampConverter() DateTime? cachedUntil});

  @override
  $PlayMetricsCopyWith<$Res> get plays;
  @override
  $DownloadMetricsCopyWith<$Res> get downloads;
  @override
  $FavoriteMetricsCopyWith<$Res> get favorites;
  @override
  $RevenueMetricsCopyWith<$Res> get revenue;
  @override
  $CompletionMetricsCopyWith<$Res> get completion;
  @override
  $GeographicMetricsCopyWith<$Res> get geographic;
  @override
  $TimeSeriesDataCopyWith<$Res> get timeSeries;
  @override
  $UserFeedbackMetricsCopyWith<$Res> get feedback;
}

/// @nodoc
class __$$TourAnalyticsModelImplCopyWithImpl<$Res>
    extends _$TourAnalyticsModelCopyWithImpl<$Res, _$TourAnalyticsModelImpl>
    implements _$$TourAnalyticsModelImplCopyWith<$Res> {
  __$$TourAnalyticsModelImplCopyWithImpl(_$TourAnalyticsModelImpl _value,
      $Res Function(_$TourAnalyticsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? period = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? plays = null,
    Object? downloads = null,
    Object? favorites = null,
    Object? revenue = null,
    Object? completion = null,
    Object? geographic = null,
    Object? timeSeries = null,
    Object? feedback = null,
    Object? generatedAt = null,
    Object? cachedUntil = freezed,
  }) {
    return _then(_$TourAnalyticsModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as AnalyticsPeriod,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      plays: null == plays
          ? _value.plays
          : plays // ignore: cast_nullable_to_non_nullable
              as PlayMetrics,
      downloads: null == downloads
          ? _value.downloads
          : downloads // ignore: cast_nullable_to_non_nullable
              as DownloadMetrics,
      favorites: null == favorites
          ? _value.favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as FavoriteMetrics,
      revenue: null == revenue
          ? _value.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as RevenueMetrics,
      completion: null == completion
          ? _value.completion
          : completion // ignore: cast_nullable_to_non_nullable
              as CompletionMetrics,
      geographic: null == geographic
          ? _value.geographic
          : geographic // ignore: cast_nullable_to_non_nullable
              as GeographicMetrics,
      timeSeries: null == timeSeries
          ? _value.timeSeries
          : timeSeries // ignore: cast_nullable_to_non_nullable
              as TimeSeriesData,
      feedback: null == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as UserFeedbackMetrics,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      cachedUntil: freezed == cachedUntil
          ? _value.cachedUntil
          : cachedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TourAnalyticsModelImpl extends _TourAnalyticsModel {
  const _$TourAnalyticsModelImpl(
      {required this.id,
      required this.tourId,
      required this.period,
      @TimestampConverter() required this.startDate,
      @TimestampConverter() required this.endDate,
      required this.plays,
      required this.downloads,
      required this.favorites,
      required this.revenue,
      required this.completion,
      required this.geographic,
      required this.timeSeries,
      required this.feedback,
      @TimestampConverter() required this.generatedAt,
      @NullableTimestampConverter() this.cachedUntil})
      : super._();

  factory _$TourAnalyticsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TourAnalyticsModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  final AnalyticsPeriod period;
  @override
  @TimestampConverter()
  final DateTime startDate;
  @override
  @TimestampConverter()
  final DateTime endDate;
  @override
  final PlayMetrics plays;
  @override
  final DownloadMetrics downloads;
  @override
  final FavoriteMetrics favorites;
  @override
  final RevenueMetrics revenue;
  @override
  final CompletionMetrics completion;
  @override
  final GeographicMetrics geographic;
  @override
  final TimeSeriesData timeSeries;
  @override
  final UserFeedbackMetrics feedback;
  @override
  @TimestampConverter()
  final DateTime generatedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? cachedUntil;

  @override
  String toString() {
    return 'TourAnalyticsModel(id: $id, tourId: $tourId, period: $period, startDate: $startDate, endDate: $endDate, plays: $plays, downloads: $downloads, favorites: $favorites, revenue: $revenue, completion: $completion, geographic: $geographic, timeSeries: $timeSeries, feedback: $feedback, generatedAt: $generatedAt, cachedUntil: $cachedUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TourAnalyticsModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.plays, plays) || other.plays == plays) &&
            (identical(other.downloads, downloads) ||
                other.downloads == downloads) &&
            (identical(other.favorites, favorites) ||
                other.favorites == favorites) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            (identical(other.completion, completion) ||
                other.completion == completion) &&
            (identical(other.geographic, geographic) ||
                other.geographic == geographic) &&
            (identical(other.timeSeries, timeSeries) ||
                other.timeSeries == timeSeries) &&
            (identical(other.feedback, feedback) ||
                other.feedback == feedback) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt) &&
            (identical(other.cachedUntil, cachedUntil) ||
                other.cachedUntil == cachedUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tourId,
      period,
      startDate,
      endDate,
      plays,
      downloads,
      favorites,
      revenue,
      completion,
      geographic,
      timeSeries,
      feedback,
      generatedAt,
      cachedUntil);

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TourAnalyticsModelImplCopyWith<_$TourAnalyticsModelImpl> get copyWith =>
      __$$TourAnalyticsModelImplCopyWithImpl<_$TourAnalyticsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TourAnalyticsModelImplToJson(
      this,
    );
  }
}

abstract class _TourAnalyticsModel extends TourAnalyticsModel {
  const factory _TourAnalyticsModel(
          {required final String id,
          required final String tourId,
          required final AnalyticsPeriod period,
          @TimestampConverter() required final DateTime startDate,
          @TimestampConverter() required final DateTime endDate,
          required final PlayMetrics plays,
          required final DownloadMetrics downloads,
          required final FavoriteMetrics favorites,
          required final RevenueMetrics revenue,
          required final CompletionMetrics completion,
          required final GeographicMetrics geographic,
          required final TimeSeriesData timeSeries,
          required final UserFeedbackMetrics feedback,
          @TimestampConverter() required final DateTime generatedAt,
          @NullableTimestampConverter() final DateTime? cachedUntil}) =
      _$TourAnalyticsModelImpl;
  const _TourAnalyticsModel._() : super._();

  factory _TourAnalyticsModel.fromJson(Map<String, dynamic> json) =
      _$TourAnalyticsModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  AnalyticsPeriod get period;
  @override
  @TimestampConverter()
  DateTime get startDate;
  @override
  @TimestampConverter()
  DateTime get endDate;
  @override
  PlayMetrics get plays;
  @override
  DownloadMetrics get downloads;
  @override
  FavoriteMetrics get favorites;
  @override
  RevenueMetrics get revenue;
  @override
  CompletionMetrics get completion;
  @override
  GeographicMetrics get geographic;
  @override
  TimeSeriesData get timeSeries;
  @override
  UserFeedbackMetrics get feedback;
  @override
  @TimestampConverter()
  DateTime get generatedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get cachedUntil;

  /// Create a copy of TourAnalyticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TourAnalyticsModelImplCopyWith<_$TourAnalyticsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayMetrics _$PlayMetricsFromJson(Map<String, dynamic> json) {
  return _PlayMetrics.fromJson(json);
}

/// @nodoc
mixin _$PlayMetrics {
  int get total => throw _privateConstructorUsedError;
  int get unique => throw _privateConstructorUsedError;
  double get averageDuration => throw _privateConstructorUsedError;
  int get completions => throw _privateConstructorUsedError;
  double get completionRate => throw _privateConstructorUsedError;
  double get changeFromPrevious => throw _privateConstructorUsedError;

  /// Serializes this PlayMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayMetricsCopyWith<PlayMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayMetricsCopyWith<$Res> {
  factory $PlayMetricsCopyWith(
          PlayMetrics value, $Res Function(PlayMetrics) then) =
      _$PlayMetricsCopyWithImpl<$Res, PlayMetrics>;
  @useResult
  $Res call(
      {int total,
      int unique,
      double averageDuration,
      int completions,
      double completionRate,
      double changeFromPrevious});
}

/// @nodoc
class _$PlayMetricsCopyWithImpl<$Res, $Val extends PlayMetrics>
    implements $PlayMetricsCopyWith<$Res> {
  _$PlayMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? unique = null,
    Object? averageDuration = null,
    Object? completions = null,
    Object? completionRate = null,
    Object? changeFromPrevious = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      unique: null == unique
          ? _value.unique
          : unique // ignore: cast_nullable_to_non_nullable
              as int,
      averageDuration: null == averageDuration
          ? _value.averageDuration
          : averageDuration // ignore: cast_nullable_to_non_nullable
              as double,
      completions: null == completions
          ? _value.completions
          : completions // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlayMetricsImplCopyWith<$Res>
    implements $PlayMetricsCopyWith<$Res> {
  factory _$$PlayMetricsImplCopyWith(
          _$PlayMetricsImpl value, $Res Function(_$PlayMetricsImpl) then) =
      __$$PlayMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total,
      int unique,
      double averageDuration,
      int completions,
      double completionRate,
      double changeFromPrevious});
}

/// @nodoc
class __$$PlayMetricsImplCopyWithImpl<$Res>
    extends _$PlayMetricsCopyWithImpl<$Res, _$PlayMetricsImpl>
    implements _$$PlayMetricsImplCopyWith<$Res> {
  __$$PlayMetricsImplCopyWithImpl(
      _$PlayMetricsImpl _value, $Res Function(_$PlayMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlayMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? unique = null,
    Object? averageDuration = null,
    Object? completions = null,
    Object? completionRate = null,
    Object? changeFromPrevious = null,
  }) {
    return _then(_$PlayMetricsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      unique: null == unique
          ? _value.unique
          : unique // ignore: cast_nullable_to_non_nullable
              as int,
      averageDuration: null == averageDuration
          ? _value.averageDuration
          : averageDuration // ignore: cast_nullable_to_non_nullable
              as double,
      completions: null == completions
          ? _value.completions
          : completions // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayMetricsImpl extends _PlayMetrics {
  const _$PlayMetricsImpl(
      {required this.total,
      required this.unique,
      required this.averageDuration,
      required this.completions,
      required this.completionRate,
      required this.changeFromPrevious})
      : super._();

  factory _$PlayMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayMetricsImplFromJson(json);

  @override
  final int total;
  @override
  final int unique;
  @override
  final double averageDuration;
  @override
  final int completions;
  @override
  final double completionRate;
  @override
  final double changeFromPrevious;

  @override
  String toString() {
    return 'PlayMetrics(total: $total, unique: $unique, averageDuration: $averageDuration, completions: $completions, completionRate: $completionRate, changeFromPrevious: $changeFromPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayMetricsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.unique, unique) || other.unique == unique) &&
            (identical(other.averageDuration, averageDuration) ||
                other.averageDuration == averageDuration) &&
            (identical(other.completions, completions) ||
                other.completions == completions) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.changeFromPrevious, changeFromPrevious) ||
                other.changeFromPrevious == changeFromPrevious));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, total, unique, averageDuration,
      completions, completionRate, changeFromPrevious);

  /// Create a copy of PlayMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayMetricsImplCopyWith<_$PlayMetricsImpl> get copyWith =>
      __$$PlayMetricsImplCopyWithImpl<_$PlayMetricsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayMetricsImplToJson(
      this,
    );
  }
}

abstract class _PlayMetrics extends PlayMetrics {
  const factory _PlayMetrics(
      {required final int total,
      required final int unique,
      required final double averageDuration,
      required final int completions,
      required final double completionRate,
      required final double changeFromPrevious}) = _$PlayMetricsImpl;
  const _PlayMetrics._() : super._();

  factory _PlayMetrics.fromJson(Map<String, dynamic> json) =
      _$PlayMetricsImpl.fromJson;

  @override
  int get total;
  @override
  int get unique;
  @override
  double get averageDuration;
  @override
  int get completions;
  @override
  double get completionRate;
  @override
  double get changeFromPrevious;

  /// Create a copy of PlayMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayMetricsImplCopyWith<_$PlayMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadMetrics _$DownloadMetricsFromJson(Map<String, dynamic> json) {
  return _DownloadMetrics.fromJson(json);
}

/// @nodoc
mixin _$DownloadMetrics {
  int get total => throw _privateConstructorUsedError;
  int get unique => throw _privateConstructorUsedError;
  double get storageUsed => throw _privateConstructorUsedError;
  double get changeFromPrevious => throw _privateConstructorUsedError;

  /// Serializes this DownloadMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadMetricsCopyWith<DownloadMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadMetricsCopyWith<$Res> {
  factory $DownloadMetricsCopyWith(
          DownloadMetrics value, $Res Function(DownloadMetrics) then) =
      _$DownloadMetricsCopyWithImpl<$Res, DownloadMetrics>;
  @useResult
  $Res call(
      {int total, int unique, double storageUsed, double changeFromPrevious});
}

/// @nodoc
class _$DownloadMetricsCopyWithImpl<$Res, $Val extends DownloadMetrics>
    implements $DownloadMetricsCopyWith<$Res> {
  _$DownloadMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? unique = null,
    Object? storageUsed = null,
    Object? changeFromPrevious = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      unique: null == unique
          ? _value.unique
          : unique // ignore: cast_nullable_to_non_nullable
              as int,
      storageUsed: null == storageUsed
          ? _value.storageUsed
          : storageUsed // ignore: cast_nullable_to_non_nullable
              as double,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadMetricsImplCopyWith<$Res>
    implements $DownloadMetricsCopyWith<$Res> {
  factory _$$DownloadMetricsImplCopyWith(_$DownloadMetricsImpl value,
          $Res Function(_$DownloadMetricsImpl) then) =
      __$$DownloadMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total, int unique, double storageUsed, double changeFromPrevious});
}

/// @nodoc
class __$$DownloadMetricsImplCopyWithImpl<$Res>
    extends _$DownloadMetricsCopyWithImpl<$Res, _$DownloadMetricsImpl>
    implements _$$DownloadMetricsImplCopyWith<$Res> {
  __$$DownloadMetricsImplCopyWithImpl(
      _$DownloadMetricsImpl _value, $Res Function(_$DownloadMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DownloadMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? unique = null,
    Object? storageUsed = null,
    Object? changeFromPrevious = null,
  }) {
    return _then(_$DownloadMetricsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      unique: null == unique
          ? _value.unique
          : unique // ignore: cast_nullable_to_non_nullable
              as int,
      storageUsed: null == storageUsed
          ? _value.storageUsed
          : storageUsed // ignore: cast_nullable_to_non_nullable
              as double,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadMetricsImpl extends _DownloadMetrics {
  const _$DownloadMetricsImpl(
      {required this.total,
      required this.unique,
      required this.storageUsed,
      required this.changeFromPrevious})
      : super._();

  factory _$DownloadMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadMetricsImplFromJson(json);

  @override
  final int total;
  @override
  final int unique;
  @override
  final double storageUsed;
  @override
  final double changeFromPrevious;

  @override
  String toString() {
    return 'DownloadMetrics(total: $total, unique: $unique, storageUsed: $storageUsed, changeFromPrevious: $changeFromPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadMetricsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.unique, unique) || other.unique == unique) &&
            (identical(other.storageUsed, storageUsed) ||
                other.storageUsed == storageUsed) &&
            (identical(other.changeFromPrevious, changeFromPrevious) ||
                other.changeFromPrevious == changeFromPrevious));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, total, unique, storageUsed, changeFromPrevious);

  /// Create a copy of DownloadMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadMetricsImplCopyWith<_$DownloadMetricsImpl> get copyWith =>
      __$$DownloadMetricsImplCopyWithImpl<_$DownloadMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadMetricsImplToJson(
      this,
    );
  }
}

abstract class _DownloadMetrics extends DownloadMetrics {
  const factory _DownloadMetrics(
      {required final int total,
      required final int unique,
      required final double storageUsed,
      required final double changeFromPrevious}) = _$DownloadMetricsImpl;
  const _DownloadMetrics._() : super._();

  factory _DownloadMetrics.fromJson(Map<String, dynamic> json) =
      _$DownloadMetricsImpl.fromJson;

  @override
  int get total;
  @override
  int get unique;
  @override
  double get storageUsed;
  @override
  double get changeFromPrevious;

  /// Create a copy of DownloadMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadMetricsImplCopyWith<_$DownloadMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FavoriteMetrics _$FavoriteMetricsFromJson(Map<String, dynamic> json) {
  return _FavoriteMetrics.fromJson(json);
}

/// @nodoc
mixin _$FavoriteMetrics {
  int get total => throw _privateConstructorUsedError;
  double get changeFromPrevious => throw _privateConstructorUsedError;

  /// Serializes this FavoriteMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FavoriteMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoriteMetricsCopyWith<FavoriteMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoriteMetricsCopyWith<$Res> {
  factory $FavoriteMetricsCopyWith(
          FavoriteMetrics value, $Res Function(FavoriteMetrics) then) =
      _$FavoriteMetricsCopyWithImpl<$Res, FavoriteMetrics>;
  @useResult
  $Res call({int total, double changeFromPrevious});
}

/// @nodoc
class _$FavoriteMetricsCopyWithImpl<$Res, $Val extends FavoriteMetrics>
    implements $FavoriteMetricsCopyWith<$Res> {
  _$FavoriteMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoriteMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? changeFromPrevious = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FavoriteMetricsImplCopyWith<$Res>
    implements $FavoriteMetricsCopyWith<$Res> {
  factory _$$FavoriteMetricsImplCopyWith(_$FavoriteMetricsImpl value,
          $Res Function(_$FavoriteMetricsImpl) then) =
      __$$FavoriteMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int total, double changeFromPrevious});
}

/// @nodoc
class __$$FavoriteMetricsImplCopyWithImpl<$Res>
    extends _$FavoriteMetricsCopyWithImpl<$Res, _$FavoriteMetricsImpl>
    implements _$$FavoriteMetricsImplCopyWith<$Res> {
  __$$FavoriteMetricsImplCopyWithImpl(
      _$FavoriteMetricsImpl _value, $Res Function(_$FavoriteMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of FavoriteMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? changeFromPrevious = null,
  }) {
    return _then(_$FavoriteMetricsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FavoriteMetricsImpl extends _FavoriteMetrics {
  const _$FavoriteMetricsImpl(
      {required this.total, required this.changeFromPrevious})
      : super._();

  factory _$FavoriteMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FavoriteMetricsImplFromJson(json);

  @override
  final int total;
  @override
  final double changeFromPrevious;

  @override
  String toString() {
    return 'FavoriteMetrics(total: $total, changeFromPrevious: $changeFromPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoriteMetricsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.changeFromPrevious, changeFromPrevious) ||
                other.changeFromPrevious == changeFromPrevious));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, total, changeFromPrevious);

  /// Create a copy of FavoriteMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoriteMetricsImplCopyWith<_$FavoriteMetricsImpl> get copyWith =>
      __$$FavoriteMetricsImplCopyWithImpl<_$FavoriteMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FavoriteMetricsImplToJson(
      this,
    );
  }
}

abstract class _FavoriteMetrics extends FavoriteMetrics {
  const factory _FavoriteMetrics(
      {required final int total,
      required final double changeFromPrevious}) = _$FavoriteMetricsImpl;
  const _FavoriteMetrics._() : super._();

  factory _FavoriteMetrics.fromJson(Map<String, dynamic> json) =
      _$FavoriteMetricsImpl.fromJson;

  @override
  int get total;
  @override
  double get changeFromPrevious;

  /// Create a copy of FavoriteMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoriteMetricsImplCopyWith<_$FavoriteMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RevenueMetrics _$RevenueMetricsFromJson(Map<String, dynamic> json) {
  return _RevenueMetrics.fromJson(json);
}

/// @nodoc
mixin _$RevenueMetrics {
  double get total => throw _privateConstructorUsedError;
  int get transactions => throw _privateConstructorUsedError;
  double get averageTransaction => throw _privateConstructorUsedError;
  Map<String, double> get byPricingTier => throw _privateConstructorUsedError;
  double get changeFromPrevious => throw _privateConstructorUsedError;

  /// Serializes this RevenueMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RevenueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RevenueMetricsCopyWith<RevenueMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RevenueMetricsCopyWith<$Res> {
  factory $RevenueMetricsCopyWith(
          RevenueMetrics value, $Res Function(RevenueMetrics) then) =
      _$RevenueMetricsCopyWithImpl<$Res, RevenueMetrics>;
  @useResult
  $Res call(
      {double total,
      int transactions,
      double averageTransaction,
      Map<String, double> byPricingTier,
      double changeFromPrevious});
}

/// @nodoc
class _$RevenueMetricsCopyWithImpl<$Res, $Val extends RevenueMetrics>
    implements $RevenueMetricsCopyWith<$Res> {
  _$RevenueMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RevenueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? transactions = null,
    Object? averageTransaction = null,
    Object? byPricingTier = null,
    Object? changeFromPrevious = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as int,
      averageTransaction: null == averageTransaction
          ? _value.averageTransaction
          : averageTransaction // ignore: cast_nullable_to_non_nullable
              as double,
      byPricingTier: null == byPricingTier
          ? _value.byPricingTier
          : byPricingTier // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RevenueMetricsImplCopyWith<$Res>
    implements $RevenueMetricsCopyWith<$Res> {
  factory _$$RevenueMetricsImplCopyWith(_$RevenueMetricsImpl value,
          $Res Function(_$RevenueMetricsImpl) then) =
      __$$RevenueMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double total,
      int transactions,
      double averageTransaction,
      Map<String, double> byPricingTier,
      double changeFromPrevious});
}

/// @nodoc
class __$$RevenueMetricsImplCopyWithImpl<$Res>
    extends _$RevenueMetricsCopyWithImpl<$Res, _$RevenueMetricsImpl>
    implements _$$RevenueMetricsImplCopyWith<$Res> {
  __$$RevenueMetricsImplCopyWithImpl(
      _$RevenueMetricsImpl _value, $Res Function(_$RevenueMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of RevenueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? transactions = null,
    Object? averageTransaction = null,
    Object? byPricingTier = null,
    Object? changeFromPrevious = null,
  }) {
    return _then(_$RevenueMetricsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as int,
      averageTransaction: null == averageTransaction
          ? _value.averageTransaction
          : averageTransaction // ignore: cast_nullable_to_non_nullable
              as double,
      byPricingTier: null == byPricingTier
          ? _value._byPricingTier
          : byPricingTier // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      changeFromPrevious: null == changeFromPrevious
          ? _value.changeFromPrevious
          : changeFromPrevious // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RevenueMetricsImpl extends _RevenueMetrics {
  const _$RevenueMetricsImpl(
      {required this.total,
      required this.transactions,
      required this.averageTransaction,
      final Map<String, double> byPricingTier = const {},
      required this.changeFromPrevious})
      : _byPricingTier = byPricingTier,
        super._();

  factory _$RevenueMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RevenueMetricsImplFromJson(json);

  @override
  final double total;
  @override
  final int transactions;
  @override
  final double averageTransaction;
  final Map<String, double> _byPricingTier;
  @override
  @JsonKey()
  Map<String, double> get byPricingTier {
    if (_byPricingTier is EqualUnmodifiableMapView) return _byPricingTier;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byPricingTier);
  }

  @override
  final double changeFromPrevious;

  @override
  String toString() {
    return 'RevenueMetrics(total: $total, transactions: $transactions, averageTransaction: $averageTransaction, byPricingTier: $byPricingTier, changeFromPrevious: $changeFromPrevious)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RevenueMetricsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.transactions, transactions) ||
                other.transactions == transactions) &&
            (identical(other.averageTransaction, averageTransaction) ||
                other.averageTransaction == averageTransaction) &&
            const DeepCollectionEquality()
                .equals(other._byPricingTier, _byPricingTier) &&
            (identical(other.changeFromPrevious, changeFromPrevious) ||
                other.changeFromPrevious == changeFromPrevious));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      total,
      transactions,
      averageTransaction,
      const DeepCollectionEquality().hash(_byPricingTier),
      changeFromPrevious);

  /// Create a copy of RevenueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RevenueMetricsImplCopyWith<_$RevenueMetricsImpl> get copyWith =>
      __$$RevenueMetricsImplCopyWithImpl<_$RevenueMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RevenueMetricsImplToJson(
      this,
    );
  }
}

abstract class _RevenueMetrics extends RevenueMetrics {
  const factory _RevenueMetrics(
      {required final double total,
      required final int transactions,
      required final double averageTransaction,
      final Map<String, double> byPricingTier,
      required final double changeFromPrevious}) = _$RevenueMetricsImpl;
  const _RevenueMetrics._() : super._();

  factory _RevenueMetrics.fromJson(Map<String, dynamic> json) =
      _$RevenueMetricsImpl.fromJson;

  @override
  double get total;
  @override
  int get transactions;
  @override
  double get averageTransaction;
  @override
  Map<String, double> get byPricingTier;
  @override
  double get changeFromPrevious;

  /// Create a copy of RevenueMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RevenueMetricsImplCopyWith<_$RevenueMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompletionMetrics _$CompletionMetricsFromJson(Map<String, dynamic> json) {
  return _CompletionMetrics.fromJson(json);
}

/// @nodoc
mixin _$CompletionMetrics {
  double get completionRate => throw _privateConstructorUsedError;
  Map<int, int> get dropOffByStop => throw _privateConstructorUsedError;
  double get averageCompletionTime => throw _privateConstructorUsedError;

  /// Serializes this CompletionMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompletionMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompletionMetricsCopyWith<CompletionMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompletionMetricsCopyWith<$Res> {
  factory $CompletionMetricsCopyWith(
          CompletionMetrics value, $Res Function(CompletionMetrics) then) =
      _$CompletionMetricsCopyWithImpl<$Res, CompletionMetrics>;
  @useResult
  $Res call(
      {double completionRate,
      Map<int, int> dropOffByStop,
      double averageCompletionTime});
}

/// @nodoc
class _$CompletionMetricsCopyWithImpl<$Res, $Val extends CompletionMetrics>
    implements $CompletionMetricsCopyWith<$Res> {
  _$CompletionMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompletionMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completionRate = null,
    Object? dropOffByStop = null,
    Object? averageCompletionTime = null,
  }) {
    return _then(_value.copyWith(
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      dropOffByStop: null == dropOffByStop
          ? _value.dropOffByStop
          : dropOffByStop // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      averageCompletionTime: null == averageCompletionTime
          ? _value.averageCompletionTime
          : averageCompletionTime // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompletionMetricsImplCopyWith<$Res>
    implements $CompletionMetricsCopyWith<$Res> {
  factory _$$CompletionMetricsImplCopyWith(_$CompletionMetricsImpl value,
          $Res Function(_$CompletionMetricsImpl) then) =
      __$$CompletionMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double completionRate,
      Map<int, int> dropOffByStop,
      double averageCompletionTime});
}

/// @nodoc
class __$$CompletionMetricsImplCopyWithImpl<$Res>
    extends _$CompletionMetricsCopyWithImpl<$Res, _$CompletionMetricsImpl>
    implements _$$CompletionMetricsImplCopyWith<$Res> {
  __$$CompletionMetricsImplCopyWithImpl(_$CompletionMetricsImpl _value,
      $Res Function(_$CompletionMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompletionMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completionRate = null,
    Object? dropOffByStop = null,
    Object? averageCompletionTime = null,
  }) {
    return _then(_$CompletionMetricsImpl(
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      dropOffByStop: null == dropOffByStop
          ? _value._dropOffByStop
          : dropOffByStop // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
      averageCompletionTime: null == averageCompletionTime
          ? _value.averageCompletionTime
          : averageCompletionTime // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompletionMetricsImpl extends _CompletionMetrics {
  const _$CompletionMetricsImpl(
      {required this.completionRate,
      required final Map<int, int> dropOffByStop,
      required this.averageCompletionTime})
      : _dropOffByStop = dropOffByStop,
        super._();

  factory _$CompletionMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompletionMetricsImplFromJson(json);

  @override
  final double completionRate;
  final Map<int, int> _dropOffByStop;
  @override
  Map<int, int> get dropOffByStop {
    if (_dropOffByStop is EqualUnmodifiableMapView) return _dropOffByStop;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dropOffByStop);
  }

  @override
  final double averageCompletionTime;

  @override
  String toString() {
    return 'CompletionMetrics(completionRate: $completionRate, dropOffByStop: $dropOffByStop, averageCompletionTime: $averageCompletionTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletionMetricsImpl &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            const DeepCollectionEquality()
                .equals(other._dropOffByStop, _dropOffByStop) &&
            (identical(other.averageCompletionTime, averageCompletionTime) ||
                other.averageCompletionTime == averageCompletionTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      completionRate,
      const DeepCollectionEquality().hash(_dropOffByStop),
      averageCompletionTime);

  /// Create a copy of CompletionMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletionMetricsImplCopyWith<_$CompletionMetricsImpl> get copyWith =>
      __$$CompletionMetricsImplCopyWithImpl<_$CompletionMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompletionMetricsImplToJson(
      this,
    );
  }
}

abstract class _CompletionMetrics extends CompletionMetrics {
  const factory _CompletionMetrics(
      {required final double completionRate,
      required final Map<int, int> dropOffByStop,
      required final double averageCompletionTime}) = _$CompletionMetricsImpl;
  const _CompletionMetrics._() : super._();

  factory _CompletionMetrics.fromJson(Map<String, dynamic> json) =
      _$CompletionMetricsImpl.fromJson;

  @override
  double get completionRate;
  @override
  Map<int, int> get dropOffByStop;
  @override
  double get averageCompletionTime;

  /// Create a copy of CompletionMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompletionMetricsImplCopyWith<_$CompletionMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GeographicMetrics _$GeographicMetricsFromJson(Map<String, dynamic> json) {
  return _GeographicMetrics.fromJson(json);
}

/// @nodoc
mixin _$GeographicMetrics {
  Map<String, int> get byCity => throw _privateConstructorUsedError;
  Map<String, int> get byCountry => throw _privateConstructorUsedError;

  /// Serializes this GeographicMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GeographicMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GeographicMetricsCopyWith<GeographicMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GeographicMetricsCopyWith<$Res> {
  factory $GeographicMetricsCopyWith(
          GeographicMetrics value, $Res Function(GeographicMetrics) then) =
      _$GeographicMetricsCopyWithImpl<$Res, GeographicMetrics>;
  @useResult
  $Res call({Map<String, int> byCity, Map<String, int> byCountry});
}

/// @nodoc
class _$GeographicMetricsCopyWithImpl<$Res, $Val extends GeographicMetrics>
    implements $GeographicMetricsCopyWith<$Res> {
  _$GeographicMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GeographicMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byCity = null,
    Object? byCountry = null,
  }) {
    return _then(_value.copyWith(
      byCity: null == byCity
          ? _value.byCity
          : byCity // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      byCountry: null == byCountry
          ? _value.byCountry
          : byCountry // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GeographicMetricsImplCopyWith<$Res>
    implements $GeographicMetricsCopyWith<$Res> {
  factory _$$GeographicMetricsImplCopyWith(_$GeographicMetricsImpl value,
          $Res Function(_$GeographicMetricsImpl) then) =
      __$$GeographicMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, int> byCity, Map<String, int> byCountry});
}

/// @nodoc
class __$$GeographicMetricsImplCopyWithImpl<$Res>
    extends _$GeographicMetricsCopyWithImpl<$Res, _$GeographicMetricsImpl>
    implements _$$GeographicMetricsImplCopyWith<$Res> {
  __$$GeographicMetricsImplCopyWithImpl(_$GeographicMetricsImpl _value,
      $Res Function(_$GeographicMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GeographicMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? byCity = null,
    Object? byCountry = null,
  }) {
    return _then(_$GeographicMetricsImpl(
      byCity: null == byCity
          ? _value._byCity
          : byCity // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      byCountry: null == byCountry
          ? _value._byCountry
          : byCountry // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GeographicMetricsImpl extends _GeographicMetrics {
  const _$GeographicMetricsImpl(
      {required final Map<String, int> byCity,
      required final Map<String, int> byCountry})
      : _byCity = byCity,
        _byCountry = byCountry,
        super._();

  factory _$GeographicMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GeographicMetricsImplFromJson(json);

  final Map<String, int> _byCity;
  @override
  Map<String, int> get byCity {
    if (_byCity is EqualUnmodifiableMapView) return _byCity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byCity);
  }

  final Map<String, int> _byCountry;
  @override
  Map<String, int> get byCountry {
    if (_byCountry is EqualUnmodifiableMapView) return _byCountry;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byCountry);
  }

  @override
  String toString() {
    return 'GeographicMetrics(byCity: $byCity, byCountry: $byCountry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GeographicMetricsImpl &&
            const DeepCollectionEquality().equals(other._byCity, _byCity) &&
            const DeepCollectionEquality()
                .equals(other._byCountry, _byCountry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_byCity),
      const DeepCollectionEquality().hash(_byCountry));

  /// Create a copy of GeographicMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GeographicMetricsImplCopyWith<_$GeographicMetricsImpl> get copyWith =>
      __$$GeographicMetricsImplCopyWithImpl<_$GeographicMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GeographicMetricsImplToJson(
      this,
    );
  }
}

abstract class _GeographicMetrics extends GeographicMetrics {
  const factory _GeographicMetrics(
      {required final Map<String, int> byCity,
      required final Map<String, int> byCountry}) = _$GeographicMetricsImpl;
  const _GeographicMetrics._() : super._();

  factory _GeographicMetrics.fromJson(Map<String, dynamic> json) =
      _$GeographicMetricsImpl.fromJson;

  @override
  Map<String, int> get byCity;
  @override
  Map<String, int> get byCountry;

  /// Create a copy of GeographicMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GeographicMetricsImplCopyWith<_$GeographicMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeSeriesData _$TimeSeriesDataFromJson(Map<String, dynamic> json) {
  return _TimeSeriesData.fromJson(json);
}

/// @nodoc
mixin _$TimeSeriesData {
  List<TimeSeriesPoint> get plays => throw _privateConstructorUsedError;
  List<TimeSeriesPoint> get downloads => throw _privateConstructorUsedError;
  List<TimeSeriesPoint> get favorites => throw _privateConstructorUsedError;

  /// Serializes this TimeSeriesData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeSeriesDataCopyWith<TimeSeriesData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSeriesDataCopyWith<$Res> {
  factory $TimeSeriesDataCopyWith(
          TimeSeriesData value, $Res Function(TimeSeriesData) then) =
      _$TimeSeriesDataCopyWithImpl<$Res, TimeSeriesData>;
  @useResult
  $Res call(
      {List<TimeSeriesPoint> plays,
      List<TimeSeriesPoint> downloads,
      List<TimeSeriesPoint> favorites});
}

/// @nodoc
class _$TimeSeriesDataCopyWithImpl<$Res, $Val extends TimeSeriesData>
    implements $TimeSeriesDataCopyWith<$Res> {
  _$TimeSeriesDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plays = null,
    Object? downloads = null,
    Object? favorites = null,
  }) {
    return _then(_value.copyWith(
      plays: null == plays
          ? _value.plays
          : plays // ignore: cast_nullable_to_non_nullable
              as List<TimeSeriesPoint>,
      downloads: null == downloads
          ? _value.downloads
          : downloads // ignore: cast_nullable_to_non_nullable
              as List<TimeSeriesPoint>,
      favorites: null == favorites
          ? _value.favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as List<TimeSeriesPoint>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeSeriesDataImplCopyWith<$Res>
    implements $TimeSeriesDataCopyWith<$Res> {
  factory _$$TimeSeriesDataImplCopyWith(_$TimeSeriesDataImpl value,
          $Res Function(_$TimeSeriesDataImpl) then) =
      __$$TimeSeriesDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<TimeSeriesPoint> plays,
      List<TimeSeriesPoint> downloads,
      List<TimeSeriesPoint> favorites});
}

/// @nodoc
class __$$TimeSeriesDataImplCopyWithImpl<$Res>
    extends _$TimeSeriesDataCopyWithImpl<$Res, _$TimeSeriesDataImpl>
    implements _$$TimeSeriesDataImplCopyWith<$Res> {
  __$$TimeSeriesDataImplCopyWithImpl(
      _$TimeSeriesDataImpl _value, $Res Function(_$TimeSeriesDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plays = null,
    Object? downloads = null,
    Object? favorites = null,
  }) {
    return _then(_$TimeSeriesDataImpl(
      plays: null == plays
          ? _value._plays
          : plays // ignore: cast_nullable_to_non_nullable
              as List<TimeSeriesPoint>,
      downloads: null == downloads
          ? _value._downloads
          : downloads // ignore: cast_nullable_to_non_nullable
              as List<TimeSeriesPoint>,
      favorites: null == favorites
          ? _value._favorites
          : favorites // ignore: cast_nullable_to_non_nullable
              as List<TimeSeriesPoint>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeSeriesDataImpl extends _TimeSeriesData {
  const _$TimeSeriesDataImpl(
      {required final List<TimeSeriesPoint> plays,
      required final List<TimeSeriesPoint> downloads,
      required final List<TimeSeriesPoint> favorites})
      : _plays = plays,
        _downloads = downloads,
        _favorites = favorites,
        super._();

  factory _$TimeSeriesDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSeriesDataImplFromJson(json);

  final List<TimeSeriesPoint> _plays;
  @override
  List<TimeSeriesPoint> get plays {
    if (_plays is EqualUnmodifiableListView) return _plays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_plays);
  }

  final List<TimeSeriesPoint> _downloads;
  @override
  List<TimeSeriesPoint> get downloads {
    if (_downloads is EqualUnmodifiableListView) return _downloads;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_downloads);
  }

  final List<TimeSeriesPoint> _favorites;
  @override
  List<TimeSeriesPoint> get favorites {
    if (_favorites is EqualUnmodifiableListView) return _favorites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favorites);
  }

  @override
  String toString() {
    return 'TimeSeriesData(plays: $plays, downloads: $downloads, favorites: $favorites)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSeriesDataImpl &&
            const DeepCollectionEquality().equals(other._plays, _plays) &&
            const DeepCollectionEquality()
                .equals(other._downloads, _downloads) &&
            const DeepCollectionEquality()
                .equals(other._favorites, _favorites));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_plays),
      const DeepCollectionEquality().hash(_downloads),
      const DeepCollectionEquality().hash(_favorites));

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSeriesDataImplCopyWith<_$TimeSeriesDataImpl> get copyWith =>
      __$$TimeSeriesDataImplCopyWithImpl<_$TimeSeriesDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeSeriesDataImplToJson(
      this,
    );
  }
}

abstract class _TimeSeriesData extends TimeSeriesData {
  const factory _TimeSeriesData(
      {required final List<TimeSeriesPoint> plays,
      required final List<TimeSeriesPoint> downloads,
      required final List<TimeSeriesPoint> favorites}) = _$TimeSeriesDataImpl;
  const _TimeSeriesData._() : super._();

  factory _TimeSeriesData.fromJson(Map<String, dynamic> json) =
      _$TimeSeriesDataImpl.fromJson;

  @override
  List<TimeSeriesPoint> get plays;
  @override
  List<TimeSeriesPoint> get downloads;
  @override
  List<TimeSeriesPoint> get favorites;

  /// Create a copy of TimeSeriesData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeSeriesDataImplCopyWith<_$TimeSeriesDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeSeriesPoint _$TimeSeriesPointFromJson(Map<String, dynamic> json) {
  return _TimeSeriesPoint.fromJson(json);
}

/// @nodoc
mixin _$TimeSeriesPoint {
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;

  /// Serializes this TimeSeriesPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeSeriesPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeSeriesPointCopyWith<TimeSeriesPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeSeriesPointCopyWith<$Res> {
  factory $TimeSeriesPointCopyWith(
          TimeSeriesPoint value, $Res Function(TimeSeriesPoint) then) =
      _$TimeSeriesPointCopyWithImpl<$Res, TimeSeriesPoint>;
  @useResult
  $Res call({@TimestampConverter() DateTime date, int value});
}

/// @nodoc
class _$TimeSeriesPointCopyWithImpl<$Res, $Val extends TimeSeriesPoint>
    implements $TimeSeriesPointCopyWith<$Res> {
  _$TimeSeriesPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeSeriesPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeSeriesPointImplCopyWith<$Res>
    implements $TimeSeriesPointCopyWith<$Res> {
  factory _$$TimeSeriesPointImplCopyWith(_$TimeSeriesPointImpl value,
          $Res Function(_$TimeSeriesPointImpl) then) =
      __$$TimeSeriesPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@TimestampConverter() DateTime date, int value});
}

/// @nodoc
class __$$TimeSeriesPointImplCopyWithImpl<$Res>
    extends _$TimeSeriesPointCopyWithImpl<$Res, _$TimeSeriesPointImpl>
    implements _$$TimeSeriesPointImplCopyWith<$Res> {
  __$$TimeSeriesPointImplCopyWithImpl(
      _$TimeSeriesPointImpl _value, $Res Function(_$TimeSeriesPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of TimeSeriesPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? value = null,
  }) {
    return _then(_$TimeSeriesPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeSeriesPointImpl extends _TimeSeriesPoint {
  const _$TimeSeriesPointImpl(
      {@TimestampConverter() required this.date, required this.value})
      : super._();

  factory _$TimeSeriesPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeSeriesPointImplFromJson(json);

  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final int value;

  @override
  String toString() {
    return 'TimeSeriesPoint(date: $date, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeSeriesPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.value, value) || other.value == value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, value);

  /// Create a copy of TimeSeriesPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeSeriesPointImplCopyWith<_$TimeSeriesPointImpl> get copyWith =>
      __$$TimeSeriesPointImplCopyWithImpl<_$TimeSeriesPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeSeriesPointImplToJson(
      this,
    );
  }
}

abstract class _TimeSeriesPoint extends TimeSeriesPoint {
  const factory _TimeSeriesPoint(
      {@TimestampConverter() required final DateTime date,
      required final int value}) = _$TimeSeriesPointImpl;
  const _TimeSeriesPoint._() : super._();

  factory _TimeSeriesPoint.fromJson(Map<String, dynamic> json) =
      _$TimeSeriesPointImpl.fromJson;

  @override
  @TimestampConverter()
  DateTime get date;
  @override
  int get value;

  /// Create a copy of TimeSeriesPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeSeriesPointImplCopyWith<_$TimeSeriesPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserFeedbackMetrics _$UserFeedbackMetricsFromJson(Map<String, dynamic> json) {
  return _UserFeedbackMetrics.fromJson(json);
}

/// @nodoc
mixin _$UserFeedbackMetrics {
  double get averageRating => throw _privateConstructorUsedError;
  int get totalReviews => throw _privateConstructorUsedError;
  Map<int, int> get ratingDistribution => throw _privateConstructorUsedError;

  /// Serializes this UserFeedbackMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserFeedbackMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserFeedbackMetricsCopyWith<UserFeedbackMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserFeedbackMetricsCopyWith<$Res> {
  factory $UserFeedbackMetricsCopyWith(
          UserFeedbackMetrics value, $Res Function(UserFeedbackMetrics) then) =
      _$UserFeedbackMetricsCopyWithImpl<$Res, UserFeedbackMetrics>;
  @useResult
  $Res call(
      {double averageRating,
      int totalReviews,
      Map<int, int> ratingDistribution});
}

/// @nodoc
class _$UserFeedbackMetricsCopyWithImpl<$Res, $Val extends UserFeedbackMetrics>
    implements $UserFeedbackMetricsCopyWith<$Res> {
  _$UserFeedbackMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserFeedbackMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? ratingDistribution = null,
  }) {
    return _then(_value.copyWith(
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      ratingDistribution: null == ratingDistribution
          ? _value.ratingDistribution
          : ratingDistribution // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserFeedbackMetricsImplCopyWith<$Res>
    implements $UserFeedbackMetricsCopyWith<$Res> {
  factory _$$UserFeedbackMetricsImplCopyWith(_$UserFeedbackMetricsImpl value,
          $Res Function(_$UserFeedbackMetricsImpl) then) =
      __$$UserFeedbackMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double averageRating,
      int totalReviews,
      Map<int, int> ratingDistribution});
}

/// @nodoc
class __$$UserFeedbackMetricsImplCopyWithImpl<$Res>
    extends _$UserFeedbackMetricsCopyWithImpl<$Res, _$UserFeedbackMetricsImpl>
    implements _$$UserFeedbackMetricsImplCopyWith<$Res> {
  __$$UserFeedbackMetricsImplCopyWithImpl(_$UserFeedbackMetricsImpl _value,
      $Res Function(_$UserFeedbackMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserFeedbackMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageRating = null,
    Object? totalReviews = null,
    Object? ratingDistribution = null,
  }) {
    return _then(_$UserFeedbackMetricsImpl(
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalReviews: null == totalReviews
          ? _value.totalReviews
          : totalReviews // ignore: cast_nullable_to_non_nullable
              as int,
      ratingDistribution: null == ratingDistribution
          ? _value._ratingDistribution
          : ratingDistribution // ignore: cast_nullable_to_non_nullable
              as Map<int, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserFeedbackMetricsImpl extends _UserFeedbackMetrics {
  const _$UserFeedbackMetricsImpl(
      {required this.averageRating,
      required this.totalReviews,
      required final Map<int, int> ratingDistribution})
      : _ratingDistribution = ratingDistribution,
        super._();

  factory _$UserFeedbackMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserFeedbackMetricsImplFromJson(json);

  @override
  final double averageRating;
  @override
  final int totalReviews;
  final Map<int, int> _ratingDistribution;
  @override
  Map<int, int> get ratingDistribution {
    if (_ratingDistribution is EqualUnmodifiableMapView)
      return _ratingDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_ratingDistribution);
  }

  @override
  String toString() {
    return 'UserFeedbackMetrics(averageRating: $averageRating, totalReviews: $totalReviews, ratingDistribution: $ratingDistribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserFeedbackMetricsImpl &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalReviews, totalReviews) ||
                other.totalReviews == totalReviews) &&
            const DeepCollectionEquality()
                .equals(other._ratingDistribution, _ratingDistribution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, averageRating, totalReviews,
      const DeepCollectionEquality().hash(_ratingDistribution));

  /// Create a copy of UserFeedbackMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserFeedbackMetricsImplCopyWith<_$UserFeedbackMetricsImpl> get copyWith =>
      __$$UserFeedbackMetricsImplCopyWithImpl<_$UserFeedbackMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserFeedbackMetricsImplToJson(
      this,
    );
  }
}

abstract class _UserFeedbackMetrics extends UserFeedbackMetrics {
  const factory _UserFeedbackMetrics(
          {required final double averageRating,
          required final int totalReviews,
          required final Map<int, int> ratingDistribution}) =
      _$UserFeedbackMetricsImpl;
  const _UserFeedbackMetrics._() : super._();

  factory _UserFeedbackMetrics.fromJson(Map<String, dynamic> json) =
      _$UserFeedbackMetricsImpl.fromJson;

  @override
  double get averageRating;
  @override
  int get totalReviews;
  @override
  Map<int, int> get ratingDistribution;

  /// Create a copy of UserFeedbackMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserFeedbackMetricsImplCopyWith<_$UserFeedbackMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
