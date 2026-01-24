// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tour_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TourModel _$TourModelFromJson(Map<String, dynamic> json) {
  return _TourModel.fromJson(json);
}

/// @nodoc
mixin _$TourModel {
  String get id => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String get creatorName => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  TourCategory get category => throw _privateConstructorUsedError;
  TourType get tourType => throw _privateConstructorUsedError;
  TourStatus get status => throw _privateConstructorUsedError;
  bool get featured => throw _privateConstructorUsedError; // Geospatial
  @GeoPointConverter()
  GeoPoint get startLocation => throw _privateConstructorUsedError;
  String get geohash => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  String? get country =>
      throw _privateConstructorUsedError; // Version references
  String? get liveVersionId => throw _privateConstructorUsedError;
  int? get liveVersion => throw _privateConstructorUsedError;
  String get draftVersionId => throw _privateConstructorUsedError;
  int get draftVersion => throw _privateConstructorUsedError; // Stats
  TourStats get stats => throw _privateConstructorUsedError; // Timestamps
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get publishedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get lastReviewedAt => throw _privateConstructorUsedError;

  /// Serializes this TourModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TourModelCopyWith<TourModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TourModelCopyWith<$Res> {
  factory $TourModelCopyWith(TourModel value, $Res Function(TourModel) then) =
      _$TourModelCopyWithImpl<$Res, TourModel>;
  @useResult
  $Res call(
      {String id,
      String creatorId,
      String creatorName,
      String? slug,
      TourCategory category,
      TourType tourType,
      TourStatus status,
      bool featured,
      @GeoPointConverter() GeoPoint startLocation,
      String geohash,
      String? city,
      String? region,
      String? country,
      String? liveVersionId,
      int? liveVersion,
      String draftVersionId,
      int draftVersion,
      TourStats stats,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      @NullableTimestampConverter() DateTime? publishedAt,
      @NullableTimestampConverter() DateTime? lastReviewedAt});

  $TourStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$TourModelCopyWithImpl<$Res, $Val extends TourModel>
    implements $TourModelCopyWith<$Res> {
  _$TourModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creatorName = null,
    Object? slug = freezed,
    Object? category = null,
    Object? tourType = null,
    Object? status = null,
    Object? featured = null,
    Object? startLocation = null,
    Object? geohash = null,
    Object? city = freezed,
    Object? region = freezed,
    Object? country = freezed,
    Object? liveVersionId = freezed,
    Object? liveVersion = freezed,
    Object? draftVersionId = null,
    Object? draftVersion = null,
    Object? stats = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? publishedAt = freezed,
    Object? lastReviewedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TourCategory,
      tourType: null == tourType
          ? _value.tourType
          : tourType // ignore: cast_nullable_to_non_nullable
              as TourType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TourStatus,
      featured: null == featured
          ? _value.featured
          : featured // ignore: cast_nullable_to_non_nullable
              as bool,
      startLocation: null == startLocation
          ? _value.startLocation
          : startLocation // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
      geohash: null == geohash
          ? _value.geohash
          : geohash // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      liveVersionId: freezed == liveVersionId
          ? _value.liveVersionId
          : liveVersionId // ignore: cast_nullable_to_non_nullable
              as String?,
      liveVersion: freezed == liveVersion
          ? _value.liveVersion
          : liveVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      draftVersionId: null == draftVersionId
          ? _value.draftVersionId
          : draftVersionId // ignore: cast_nullable_to_non_nullable
              as String,
      draftVersion: null == draftVersion
          ? _value.draftVersion
          : draftVersion // ignore: cast_nullable_to_non_nullable
              as int,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as TourStats,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TourStatsCopyWith<$Res> get stats {
    return $TourStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TourModelImplCopyWith<$Res>
    implements $TourModelCopyWith<$Res> {
  factory _$$TourModelImplCopyWith(
          _$TourModelImpl value, $Res Function(_$TourModelImpl) then) =
      __$$TourModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String creatorId,
      String creatorName,
      String? slug,
      TourCategory category,
      TourType tourType,
      TourStatus status,
      bool featured,
      @GeoPointConverter() GeoPoint startLocation,
      String geohash,
      String? city,
      String? region,
      String? country,
      String? liveVersionId,
      int? liveVersion,
      String draftVersionId,
      int draftVersion,
      TourStats stats,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      @NullableTimestampConverter() DateTime? publishedAt,
      @NullableTimestampConverter() DateTime? lastReviewedAt});

  @override
  $TourStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$TourModelImplCopyWithImpl<$Res>
    extends _$TourModelCopyWithImpl<$Res, _$TourModelImpl>
    implements _$$TourModelImplCopyWith<$Res> {
  __$$TourModelImplCopyWithImpl(
      _$TourModelImpl _value, $Res Function(_$TourModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? creatorId = null,
    Object? creatorName = null,
    Object? slug = freezed,
    Object? category = null,
    Object? tourType = null,
    Object? status = null,
    Object? featured = null,
    Object? startLocation = null,
    Object? geohash = null,
    Object? city = freezed,
    Object? region = freezed,
    Object? country = freezed,
    Object? liveVersionId = freezed,
    Object? liveVersion = freezed,
    Object? draftVersionId = null,
    Object? draftVersion = null,
    Object? stats = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? publishedAt = freezed,
    Object? lastReviewedAt = freezed,
  }) {
    return _then(_$TourModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      slug: freezed == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as TourCategory,
      tourType: null == tourType
          ? _value.tourType
          : tourType // ignore: cast_nullable_to_non_nullable
              as TourType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TourStatus,
      featured: null == featured
          ? _value.featured
          : featured // ignore: cast_nullable_to_non_nullable
              as bool,
      startLocation: null == startLocation
          ? _value.startLocation
          : startLocation // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
      geohash: null == geohash
          ? _value.geohash
          : geohash // ignore: cast_nullable_to_non_nullable
              as String,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      liveVersionId: freezed == liveVersionId
          ? _value.liveVersionId
          : liveVersionId // ignore: cast_nullable_to_non_nullable
              as String?,
      liveVersion: freezed == liveVersion
          ? _value.liveVersion
          : liveVersion // ignore: cast_nullable_to_non_nullable
              as int?,
      draftVersionId: null == draftVersionId
          ? _value.draftVersionId
          : draftVersionId // ignore: cast_nullable_to_non_nullable
              as String,
      draftVersion: null == draftVersion
          ? _value.draftVersion
          : draftVersion // ignore: cast_nullable_to_non_nullable
              as int,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as TourStats,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastReviewedAt: freezed == lastReviewedAt
          ? _value.lastReviewedAt
          : lastReviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TourModelImpl extends _TourModel {
  const _$TourModelImpl(
      {required this.id,
      required this.creatorId,
      required this.creatorName,
      this.slug,
      required this.category,
      required this.tourType,
      this.status = TourStatus.draft,
      this.featured = false,
      @GeoPointConverter() required this.startLocation,
      required this.geohash,
      this.city,
      this.region,
      this.country,
      this.liveVersionId,
      this.liveVersion,
      required this.draftVersionId,
      required this.draftVersion,
      this.stats = const TourStats(),
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt,
      @NullableTimestampConverter() this.publishedAt,
      @NullableTimestampConverter() this.lastReviewedAt})
      : super._();

  factory _$TourModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TourModelImplFromJson(json);

  @override
  final String id;
  @override
  final String creatorId;
  @override
  final String creatorName;
  @override
  final String? slug;
  @override
  final TourCategory category;
  @override
  final TourType tourType;
  @override
  @JsonKey()
  final TourStatus status;
  @override
  @JsonKey()
  final bool featured;
// Geospatial
  @override
  @GeoPointConverter()
  final GeoPoint startLocation;
  @override
  final String geohash;
  @override
  final String? city;
  @override
  final String? region;
  @override
  final String? country;
// Version references
  @override
  final String? liveVersionId;
  @override
  final int? liveVersion;
  @override
  final String draftVersionId;
  @override
  final int draftVersion;
// Stats
  @override
  @JsonKey()
  final TourStats stats;
// Timestamps
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? publishedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? lastReviewedAt;

  @override
  String toString() {
    return 'TourModel(id: $id, creatorId: $creatorId, creatorName: $creatorName, slug: $slug, category: $category, tourType: $tourType, status: $status, featured: $featured, startLocation: $startLocation, geohash: $geohash, city: $city, region: $region, country: $country, liveVersionId: $liveVersionId, liveVersion: $liveVersion, draftVersionId: $draftVersionId, draftVersion: $draftVersion, stats: $stats, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt, lastReviewedAt: $lastReviewedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TourModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.tourType, tourType) ||
                other.tourType == tourType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.featured, featured) ||
                other.featured == featured) &&
            (identical(other.startLocation, startLocation) ||
                other.startLocation == startLocation) &&
            (identical(other.geohash, geohash) || other.geohash == geohash) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.liveVersionId, liveVersionId) ||
                other.liveVersionId == liveVersionId) &&
            (identical(other.liveVersion, liveVersion) ||
                other.liveVersion == liveVersion) &&
            (identical(other.draftVersionId, draftVersionId) ||
                other.draftVersionId == draftVersionId) &&
            (identical(other.draftVersion, draftVersion) ||
                other.draftVersion == draftVersion) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt) &&
            (identical(other.lastReviewedAt, lastReviewedAt) ||
                other.lastReviewedAt == lastReviewedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        creatorId,
        creatorName,
        slug,
        category,
        tourType,
        status,
        featured,
        startLocation,
        geohash,
        city,
        region,
        country,
        liveVersionId,
        liveVersion,
        draftVersionId,
        draftVersion,
        stats,
        createdAt,
        updatedAt,
        publishedAt,
        lastReviewedAt
      ]);

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TourModelImplCopyWith<_$TourModelImpl> get copyWith =>
      __$$TourModelImplCopyWithImpl<_$TourModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TourModelImplToJson(
      this,
    );
  }
}

abstract class _TourModel extends TourModel {
  const factory _TourModel(
          {required final String id,
          required final String creatorId,
          required final String creatorName,
          final String? slug,
          required final TourCategory category,
          required final TourType tourType,
          final TourStatus status,
          final bool featured,
          @GeoPointConverter() required final GeoPoint startLocation,
          required final String geohash,
          final String? city,
          final String? region,
          final String? country,
          final String? liveVersionId,
          final int? liveVersion,
          required final String draftVersionId,
          required final int draftVersion,
          final TourStats stats,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt,
          @NullableTimestampConverter() final DateTime? publishedAt,
          @NullableTimestampConverter() final DateTime? lastReviewedAt}) =
      _$TourModelImpl;
  const _TourModel._() : super._();

  factory _TourModel.fromJson(Map<String, dynamic> json) =
      _$TourModelImpl.fromJson;

  @override
  String get id;
  @override
  String get creatorId;
  @override
  String get creatorName;
  @override
  String? get slug;
  @override
  TourCategory get category;
  @override
  TourType get tourType;
  @override
  TourStatus get status;
  @override
  bool get featured; // Geospatial
  @override
  @GeoPointConverter()
  GeoPoint get startLocation;
  @override
  String get geohash;
  @override
  String? get city;
  @override
  String? get region;
  @override
  String? get country; // Version references
  @override
  String? get liveVersionId;
  @override
  int? get liveVersion;
  @override
  String get draftVersionId;
  @override
  int get draftVersion; // Stats
  @override
  TourStats get stats; // Timestamps
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get publishedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get lastReviewedAt;

  /// Create a copy of TourModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TourModelImplCopyWith<_$TourModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TourStats _$TourStatsFromJson(Map<String, dynamic> json) {
  return _TourStats.fromJson(json);
}

/// @nodoc
mixin _$TourStats {
  int get totalPlays => throw _privateConstructorUsedError;
  int get totalDownloads => throw _privateConstructorUsedError;
  double get averageRating => throw _privateConstructorUsedError;
  int get totalRatings => throw _privateConstructorUsedError;
  int get totalRevenue => throw _privateConstructorUsedError;

  /// Serializes this TourStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TourStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TourStatsCopyWith<TourStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TourStatsCopyWith<$Res> {
  factory $TourStatsCopyWith(TourStats value, $Res Function(TourStats) then) =
      _$TourStatsCopyWithImpl<$Res, TourStats>;
  @useResult
  $Res call(
      {int totalPlays,
      int totalDownloads,
      double averageRating,
      int totalRatings,
      int totalRevenue});
}

/// @nodoc
class _$TourStatsCopyWithImpl<$Res, $Val extends TourStats>
    implements $TourStatsCopyWith<$Res> {
  _$TourStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TourStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPlays = null,
    Object? totalDownloads = null,
    Object? averageRating = null,
    Object? totalRatings = null,
    Object? totalRevenue = null,
  }) {
    return _then(_value.copyWith(
      totalPlays: null == totalPlays
          ? _value.totalPlays
          : totalPlays // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownloads: null == totalDownloads
          ? _value.totalDownloads
          : totalDownloads // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TourStatsImplCopyWith<$Res>
    implements $TourStatsCopyWith<$Res> {
  factory _$$TourStatsImplCopyWith(
          _$TourStatsImpl value, $Res Function(_$TourStatsImpl) then) =
      __$$TourStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalPlays,
      int totalDownloads,
      double averageRating,
      int totalRatings,
      int totalRevenue});
}

/// @nodoc
class __$$TourStatsImplCopyWithImpl<$Res>
    extends _$TourStatsCopyWithImpl<$Res, _$TourStatsImpl>
    implements _$$TourStatsImplCopyWith<$Res> {
  __$$TourStatsImplCopyWithImpl(
      _$TourStatsImpl _value, $Res Function(_$TourStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of TourStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPlays = null,
    Object? totalDownloads = null,
    Object? averageRating = null,
    Object? totalRatings = null,
    Object? totalRevenue = null,
  }) {
    return _then(_$TourStatsImpl(
      totalPlays: null == totalPlays
          ? _value.totalPlays
          : totalPlays // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownloads: null == totalDownloads
          ? _value.totalDownloads
          : totalDownloads // ignore: cast_nullable_to_non_nullable
              as int,
      averageRating: null == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double,
      totalRatings: null == totalRatings
          ? _value.totalRatings
          : totalRatings // ignore: cast_nullable_to_non_nullable
              as int,
      totalRevenue: null == totalRevenue
          ? _value.totalRevenue
          : totalRevenue // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TourStatsImpl implements _TourStats {
  const _$TourStatsImpl(
      {this.totalPlays = 0,
      this.totalDownloads = 0,
      this.averageRating = 0.0,
      this.totalRatings = 0,
      this.totalRevenue = 0});

  factory _$TourStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TourStatsImplFromJson(json);

  @override
  @JsonKey()
  final int totalPlays;
  @override
  @JsonKey()
  final int totalDownloads;
  @override
  @JsonKey()
  final double averageRating;
  @override
  @JsonKey()
  final int totalRatings;
  @override
  @JsonKey()
  final int totalRevenue;

  @override
  String toString() {
    return 'TourStats(totalPlays: $totalPlays, totalDownloads: $totalDownloads, averageRating: $averageRating, totalRatings: $totalRatings, totalRevenue: $totalRevenue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TourStatsImpl &&
            (identical(other.totalPlays, totalPlays) ||
                other.totalPlays == totalPlays) &&
            (identical(other.totalDownloads, totalDownloads) ||
                other.totalDownloads == totalDownloads) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.totalRatings, totalRatings) ||
                other.totalRatings == totalRatings) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalPlays, totalDownloads,
      averageRating, totalRatings, totalRevenue);

  /// Create a copy of TourStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TourStatsImplCopyWith<_$TourStatsImpl> get copyWith =>
      __$$TourStatsImplCopyWithImpl<_$TourStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TourStatsImplToJson(
      this,
    );
  }
}

abstract class _TourStats implements TourStats {
  const factory _TourStats(
      {final int totalPlays,
      final int totalDownloads,
      final double averageRating,
      final int totalRatings,
      final int totalRevenue}) = _$TourStatsImpl;

  factory _TourStats.fromJson(Map<String, dynamic> json) =
      _$TourStatsImpl.fromJson;

  @override
  int get totalPlays;
  @override
  int get totalDownloads;
  @override
  double get averageRating;
  @override
  int get totalRatings;
  @override
  int get totalRevenue;

  /// Create a copy of TourStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TourStatsImplCopyWith<_$TourStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
