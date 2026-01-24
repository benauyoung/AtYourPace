// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tour_version_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TourVersionModel _$TourVersionModelFromJson(Map<String, dynamic> json) {
  return _TourVersionModel.fromJson(json);
}

/// @nodoc
mixin _$TourVersionModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  int get versionNumber => throw _privateConstructorUsedError;
  VersionType get versionType =>
      throw _privateConstructorUsedError; // Tour Content
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get coverImageUrl => throw _privateConstructorUsedError;
  String? get duration => throw _privateConstructorUsedError;
  String? get distance => throw _privateConstructorUsedError;
  TourDifficulty get difficulty => throw _privateConstructorUsedError;
  List<String> get languages =>
      throw _privateConstructorUsedError; // Route Data
  TourRoute? get route => throw _privateConstructorUsedError; // Review workflow
  @NullableTimestampConverter()
  DateTime? get submittedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String? get reviewedBy => throw _privateConstructorUsedError;
  String? get reviewNotes => throw _privateConstructorUsedError; // Timestamps
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this TourVersionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TourVersionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TourVersionModelCopyWith<TourVersionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TourVersionModelCopyWith<$Res> {
  factory $TourVersionModelCopyWith(
          TourVersionModel value, $Res Function(TourVersionModel) then) =
      _$TourVersionModelCopyWithImpl<$Res, TourVersionModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      int versionNumber,
      VersionType versionType,
      String title,
      String description,
      String? coverImageUrl,
      String? duration,
      String? distance,
      TourDifficulty difficulty,
      List<String> languages,
      TourRoute? route,
      @NullableTimestampConverter() DateTime? submittedAt,
      @NullableTimestampConverter() DateTime? reviewedAt,
      String? reviewedBy,
      String? reviewNotes,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});

  $TourRouteCopyWith<$Res>? get route;
}

/// @nodoc
class _$TourVersionModelCopyWithImpl<$Res, $Val extends TourVersionModel>
    implements $TourVersionModelCopyWith<$Res> {
  _$TourVersionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TourVersionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionNumber = null,
    Object? versionType = null,
    Object? title = null,
    Object? description = null,
    Object? coverImageUrl = freezed,
    Object? duration = freezed,
    Object? distance = freezed,
    Object? difficulty = null,
    Object? languages = null,
    Object? route = freezed,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? reviewNotes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      versionNumber: null == versionNumber
          ? _value.versionNumber
          : versionNumber // ignore: cast_nullable_to_non_nullable
              as int,
      versionType: null == versionType
          ? _value.versionType
          : versionType // ignore: cast_nullable_to_non_nullable
              as VersionType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as TourDifficulty,
      languages: null == languages
          ? _value.languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      route: freezed == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as TourRoute?,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewNotes: freezed == reviewNotes
          ? _value.reviewNotes
          : reviewNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of TourVersionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TourRouteCopyWith<$Res>? get route {
    if (_value.route == null) {
      return null;
    }

    return $TourRouteCopyWith<$Res>(_value.route!, (value) {
      return _then(_value.copyWith(route: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TourVersionModelImplCopyWith<$Res>
    implements $TourVersionModelCopyWith<$Res> {
  factory _$$TourVersionModelImplCopyWith(_$TourVersionModelImpl value,
          $Res Function(_$TourVersionModelImpl) then) =
      __$$TourVersionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      int versionNumber,
      VersionType versionType,
      String title,
      String description,
      String? coverImageUrl,
      String? duration,
      String? distance,
      TourDifficulty difficulty,
      List<String> languages,
      TourRoute? route,
      @NullableTimestampConverter() DateTime? submittedAt,
      @NullableTimestampConverter() DateTime? reviewedAt,
      String? reviewedBy,
      String? reviewNotes,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});

  @override
  $TourRouteCopyWith<$Res>? get route;
}

/// @nodoc
class __$$TourVersionModelImplCopyWithImpl<$Res>
    extends _$TourVersionModelCopyWithImpl<$Res, _$TourVersionModelImpl>
    implements _$$TourVersionModelImplCopyWith<$Res> {
  __$$TourVersionModelImplCopyWithImpl(_$TourVersionModelImpl _value,
      $Res Function(_$TourVersionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TourVersionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionNumber = null,
    Object? versionType = null,
    Object? title = null,
    Object? description = null,
    Object? coverImageUrl = freezed,
    Object? duration = freezed,
    Object? distance = freezed,
    Object? difficulty = null,
    Object? languages = null,
    Object? route = freezed,
    Object? submittedAt = freezed,
    Object? reviewedAt = freezed,
    Object? reviewedBy = freezed,
    Object? reviewNotes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TourVersionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      versionNumber: null == versionNumber
          ? _value.versionNumber
          : versionNumber // ignore: cast_nullable_to_non_nullable
              as int,
      versionType: null == versionType
          ? _value.versionType
          : versionType // ignore: cast_nullable_to_non_nullable
              as VersionType,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as TourDifficulty,
      languages: null == languages
          ? _value._languages
          : languages // ignore: cast_nullable_to_non_nullable
              as List<String>,
      route: freezed == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as TourRoute?,
      submittedAt: freezed == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewedBy: freezed == reviewedBy
          ? _value.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewNotes: freezed == reviewNotes
          ? _value.reviewNotes
          : reviewNotes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TourVersionModelImpl extends _TourVersionModel {
  const _$TourVersionModelImpl(
      {required this.id,
      required this.tourId,
      required this.versionNumber,
      this.versionType = VersionType.draft,
      required this.title,
      required this.description,
      this.coverImageUrl,
      this.duration,
      this.distance,
      this.difficulty = TourDifficulty.moderate,
      final List<String> languages = const [],
      this.route,
      @NullableTimestampConverter() this.submittedAt,
      @NullableTimestampConverter() this.reviewedAt,
      this.reviewedBy,
      this.reviewNotes,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : _languages = languages,
        super._();

  factory _$TourVersionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TourVersionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  final int versionNumber;
  @override
  @JsonKey()
  final VersionType versionType;
// Tour Content
  @override
  final String title;
  @override
  final String description;
  @override
  final String? coverImageUrl;
  @override
  final String? duration;
  @override
  final String? distance;
  @override
  @JsonKey()
  final TourDifficulty difficulty;
  final List<String> _languages;
  @override
  @JsonKey()
  List<String> get languages {
    if (_languages is EqualUnmodifiableListView) return _languages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_languages);
  }

// Route Data
  @override
  final TourRoute? route;
// Review workflow
  @override
  @NullableTimestampConverter()
  final DateTime? submittedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? reviewedAt;
  @override
  final String? reviewedBy;
  @override
  final String? reviewNotes;
// Timestamps
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TourVersionModel(id: $id, tourId: $tourId, versionNumber: $versionNumber, versionType: $versionType, title: $title, description: $description, coverImageUrl: $coverImageUrl, duration: $duration, distance: $distance, difficulty: $difficulty, languages: $languages, route: $route, submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewedBy: $reviewedBy, reviewNotes: $reviewNotes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TourVersionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.versionNumber, versionNumber) ||
                other.versionNumber == versionNumber) &&
            (identical(other.versionType, versionType) ||
                other.versionType == versionType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            const DeepCollectionEquality()
                .equals(other._languages, _languages) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewNotes, reviewNotes) ||
                other.reviewNotes == reviewNotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tourId,
      versionNumber,
      versionType,
      title,
      description,
      coverImageUrl,
      duration,
      distance,
      difficulty,
      const DeepCollectionEquality().hash(_languages),
      route,
      submittedAt,
      reviewedAt,
      reviewedBy,
      reviewNotes,
      createdAt,
      updatedAt);

  /// Create a copy of TourVersionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TourVersionModelImplCopyWith<_$TourVersionModelImpl> get copyWith =>
      __$$TourVersionModelImplCopyWithImpl<_$TourVersionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TourVersionModelImplToJson(
      this,
    );
  }
}

abstract class _TourVersionModel extends TourVersionModel {
  const factory _TourVersionModel(
          {required final String id,
          required final String tourId,
          required final int versionNumber,
          final VersionType versionType,
          required final String title,
          required final String description,
          final String? coverImageUrl,
          final String? duration,
          final String? distance,
          final TourDifficulty difficulty,
          final List<String> languages,
          final TourRoute? route,
          @NullableTimestampConverter() final DateTime? submittedAt,
          @NullableTimestampConverter() final DateTime? reviewedAt,
          final String? reviewedBy,
          final String? reviewNotes,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$TourVersionModelImpl;
  const _TourVersionModel._() : super._();

  factory _TourVersionModel.fromJson(Map<String, dynamic> json) =
      _$TourVersionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  int get versionNumber;
  @override
  VersionType get versionType; // Tour Content
  @override
  String get title;
  @override
  String get description;
  @override
  String? get coverImageUrl;
  @override
  String? get duration;
  @override
  String? get distance;
  @override
  TourDifficulty get difficulty;
  @override
  List<String> get languages; // Route Data
  @override
  TourRoute? get route; // Review workflow
  @override
  @NullableTimestampConverter()
  DateTime? get submittedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get reviewedAt;
  @override
  String? get reviewedBy;
  @override
  String? get reviewNotes; // Timestamps
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of TourVersionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TourVersionModelImplCopyWith<_$TourVersionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TourRoute _$TourRouteFromJson(Map<String, dynamic> json) {
  return _TourRoute.fromJson(json);
}

/// @nodoc
mixin _$TourRoute {
  String? get encodedPolyline => throw _privateConstructorUsedError;
  BoundingBox? get boundingBox => throw _privateConstructorUsedError;
  List<RouteWaypoint> get waypoints => throw _privateConstructorUsedError;

  /// Serializes this TourRoute to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TourRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TourRouteCopyWith<TourRoute> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TourRouteCopyWith<$Res> {
  factory $TourRouteCopyWith(TourRoute value, $Res Function(TourRoute) then) =
      _$TourRouteCopyWithImpl<$Res, TourRoute>;
  @useResult
  $Res call(
      {String? encodedPolyline,
      BoundingBox? boundingBox,
      List<RouteWaypoint> waypoints});

  $BoundingBoxCopyWith<$Res>? get boundingBox;
}

/// @nodoc
class _$TourRouteCopyWithImpl<$Res, $Val extends TourRoute>
    implements $TourRouteCopyWith<$Res> {
  _$TourRouteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TourRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? encodedPolyline = freezed,
    Object? boundingBox = freezed,
    Object? waypoints = null,
  }) {
    return _then(_value.copyWith(
      encodedPolyline: freezed == encodedPolyline
          ? _value.encodedPolyline
          : encodedPolyline // ignore: cast_nullable_to_non_nullable
              as String?,
      boundingBox: freezed == boundingBox
          ? _value.boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as BoundingBox?,
      waypoints: null == waypoints
          ? _value.waypoints
          : waypoints // ignore: cast_nullable_to_non_nullable
              as List<RouteWaypoint>,
    ) as $Val);
  }

  /// Create a copy of TourRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BoundingBoxCopyWith<$Res>? get boundingBox {
    if (_value.boundingBox == null) {
      return null;
    }

    return $BoundingBoxCopyWith<$Res>(_value.boundingBox!, (value) {
      return _then(_value.copyWith(boundingBox: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TourRouteImplCopyWith<$Res>
    implements $TourRouteCopyWith<$Res> {
  factory _$$TourRouteImplCopyWith(
          _$TourRouteImpl value, $Res Function(_$TourRouteImpl) then) =
      __$$TourRouteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? encodedPolyline,
      BoundingBox? boundingBox,
      List<RouteWaypoint> waypoints});

  @override
  $BoundingBoxCopyWith<$Res>? get boundingBox;
}

/// @nodoc
class __$$TourRouteImplCopyWithImpl<$Res>
    extends _$TourRouteCopyWithImpl<$Res, _$TourRouteImpl>
    implements _$$TourRouteImplCopyWith<$Res> {
  __$$TourRouteImplCopyWithImpl(
      _$TourRouteImpl _value, $Res Function(_$TourRouteImpl) _then)
      : super(_value, _then);

  /// Create a copy of TourRoute
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? encodedPolyline = freezed,
    Object? boundingBox = freezed,
    Object? waypoints = null,
  }) {
    return _then(_$TourRouteImpl(
      encodedPolyline: freezed == encodedPolyline
          ? _value.encodedPolyline
          : encodedPolyline // ignore: cast_nullable_to_non_nullable
              as String?,
      boundingBox: freezed == boundingBox
          ? _value.boundingBox
          : boundingBox // ignore: cast_nullable_to_non_nullable
              as BoundingBox?,
      waypoints: null == waypoints
          ? _value._waypoints
          : waypoints // ignore: cast_nullable_to_non_nullable
              as List<RouteWaypoint>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TourRouteImpl implements _TourRoute {
  const _$TourRouteImpl(
      {this.encodedPolyline,
      this.boundingBox,
      final List<RouteWaypoint> waypoints = const []})
      : _waypoints = waypoints;

  factory _$TourRouteImpl.fromJson(Map<String, dynamic> json) =>
      _$$TourRouteImplFromJson(json);

  @override
  final String? encodedPolyline;
  @override
  final BoundingBox? boundingBox;
  final List<RouteWaypoint> _waypoints;
  @override
  @JsonKey()
  List<RouteWaypoint> get waypoints {
    if (_waypoints is EqualUnmodifiableListView) return _waypoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_waypoints);
  }

  @override
  String toString() {
    return 'TourRoute(encodedPolyline: $encodedPolyline, boundingBox: $boundingBox, waypoints: $waypoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TourRouteImpl &&
            (identical(other.encodedPolyline, encodedPolyline) ||
                other.encodedPolyline == encodedPolyline) &&
            (identical(other.boundingBox, boundingBox) ||
                other.boundingBox == boundingBox) &&
            const DeepCollectionEquality()
                .equals(other._waypoints, _waypoints));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, encodedPolyline, boundingBox,
      const DeepCollectionEquality().hash(_waypoints));

  /// Create a copy of TourRoute
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TourRouteImplCopyWith<_$TourRouteImpl> get copyWith =>
      __$$TourRouteImplCopyWithImpl<_$TourRouteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TourRouteImplToJson(
      this,
    );
  }
}

abstract class _TourRoute implements TourRoute {
  const factory _TourRoute(
      {final String? encodedPolyline,
      final BoundingBox? boundingBox,
      final List<RouteWaypoint> waypoints}) = _$TourRouteImpl;

  factory _TourRoute.fromJson(Map<String, dynamic> json) =
      _$TourRouteImpl.fromJson;

  @override
  String? get encodedPolyline;
  @override
  BoundingBox? get boundingBox;
  @override
  List<RouteWaypoint> get waypoints;

  /// Create a copy of TourRoute
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TourRouteImplCopyWith<_$TourRouteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BoundingBox _$BoundingBoxFromJson(Map<String, dynamic> json) {
  return _BoundingBox.fromJson(json);
}

/// @nodoc
mixin _$BoundingBox {
  @GeoPointConverter()
  GeoPoint get northeast => throw _privateConstructorUsedError;
  @GeoPointConverter()
  GeoPoint get southwest => throw _privateConstructorUsedError;

  /// Serializes this BoundingBox to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BoundingBoxCopyWith<BoundingBox> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BoundingBoxCopyWith<$Res> {
  factory $BoundingBoxCopyWith(
          BoundingBox value, $Res Function(BoundingBox) then) =
      _$BoundingBoxCopyWithImpl<$Res, BoundingBox>;
  @useResult
  $Res call(
      {@GeoPointConverter() GeoPoint northeast,
      @GeoPointConverter() GeoPoint southwest});
}

/// @nodoc
class _$BoundingBoxCopyWithImpl<$Res, $Val extends BoundingBox>
    implements $BoundingBoxCopyWith<$Res> {
  _$BoundingBoxCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? northeast = null,
    Object? southwest = null,
  }) {
    return _then(_value.copyWith(
      northeast: null == northeast
          ? _value.northeast
          : northeast // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
      southwest: null == southwest
          ? _value.southwest
          : southwest // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BoundingBoxImplCopyWith<$Res>
    implements $BoundingBoxCopyWith<$Res> {
  factory _$$BoundingBoxImplCopyWith(
          _$BoundingBoxImpl value, $Res Function(_$BoundingBoxImpl) then) =
      __$$BoundingBoxImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@GeoPointConverter() GeoPoint northeast,
      @GeoPointConverter() GeoPoint southwest});
}

/// @nodoc
class __$$BoundingBoxImplCopyWithImpl<$Res>
    extends _$BoundingBoxCopyWithImpl<$Res, _$BoundingBoxImpl>
    implements _$$BoundingBoxImplCopyWith<$Res> {
  __$$BoundingBoxImplCopyWithImpl(
      _$BoundingBoxImpl _value, $Res Function(_$BoundingBoxImpl) _then)
      : super(_value, _then);

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? northeast = null,
    Object? southwest = null,
  }) {
    return _then(_$BoundingBoxImpl(
      northeast: null == northeast
          ? _value.northeast
          : northeast // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
      southwest: null == southwest
          ? _value.southwest
          : southwest // ignore: cast_nullable_to_non_nullable
              as GeoPoint,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BoundingBoxImpl implements _BoundingBox {
  const _$BoundingBoxImpl(
      {@GeoPointConverter() required this.northeast,
      @GeoPointConverter() required this.southwest});

  factory _$BoundingBoxImpl.fromJson(Map<String, dynamic> json) =>
      _$$BoundingBoxImplFromJson(json);

  @override
  @GeoPointConverter()
  final GeoPoint northeast;
  @override
  @GeoPointConverter()
  final GeoPoint southwest;

  @override
  String toString() {
    return 'BoundingBox(northeast: $northeast, southwest: $southwest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BoundingBoxImpl &&
            (identical(other.northeast, northeast) ||
                other.northeast == northeast) &&
            (identical(other.southwest, southwest) ||
                other.southwest == southwest));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, northeast, southwest);

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BoundingBoxImplCopyWith<_$BoundingBoxImpl> get copyWith =>
      __$$BoundingBoxImplCopyWithImpl<_$BoundingBoxImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BoundingBoxImplToJson(
      this,
    );
  }
}

abstract class _BoundingBox implements BoundingBox {
  const factory _BoundingBox(
          {@GeoPointConverter() required final GeoPoint northeast,
          @GeoPointConverter() required final GeoPoint southwest}) =
      _$BoundingBoxImpl;

  factory _BoundingBox.fromJson(Map<String, dynamic> json) =
      _$BoundingBoxImpl.fromJson;

  @override
  @GeoPointConverter()
  GeoPoint get northeast;
  @override
  @GeoPointConverter()
  GeoPoint get southwest;

  /// Create a copy of BoundingBox
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BoundingBoxImplCopyWith<_$BoundingBoxImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RouteWaypoint _$RouteWaypointFromJson(Map<String, dynamic> json) {
  return _RouteWaypoint.fromJson(json);
}

/// @nodoc
mixin _$RouteWaypoint {
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;

  /// Serializes this RouteWaypoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteWaypoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteWaypointCopyWith<RouteWaypoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteWaypointCopyWith<$Res> {
  factory $RouteWaypointCopyWith(
          RouteWaypoint value, $Res Function(RouteWaypoint) then) =
      _$RouteWaypointCopyWithImpl<$Res, RouteWaypoint>;
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class _$RouteWaypointCopyWithImpl<$Res, $Val extends RouteWaypoint>
    implements $RouteWaypointCopyWith<$Res> {
  _$RouteWaypointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteWaypoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(_value.copyWith(
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RouteWaypointImplCopyWith<$Res>
    implements $RouteWaypointCopyWith<$Res> {
  factory _$$RouteWaypointImplCopyWith(
          _$RouteWaypointImpl value, $Res Function(_$RouteWaypointImpl) then) =
      __$$RouteWaypointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double lat, double lng});
}

/// @nodoc
class __$$RouteWaypointImplCopyWithImpl<$Res>
    extends _$RouteWaypointCopyWithImpl<$Res, _$RouteWaypointImpl>
    implements _$$RouteWaypointImplCopyWith<$Res> {
  __$$RouteWaypointImplCopyWithImpl(
      _$RouteWaypointImpl _value, $Res Function(_$RouteWaypointImpl) _then)
      : super(_value, _then);

  /// Create a copy of RouteWaypoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(_$RouteWaypointImpl(
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteWaypointImpl implements _RouteWaypoint {
  const _$RouteWaypointImpl({required this.lat, required this.lng});

  factory _$RouteWaypointImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteWaypointImplFromJson(json);

  @override
  final double lat;
  @override
  final double lng;

  @override
  String toString() {
    return 'RouteWaypoint(lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteWaypointImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng);

  /// Create a copy of RouteWaypoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteWaypointImplCopyWith<_$RouteWaypointImpl> get copyWith =>
      __$$RouteWaypointImplCopyWithImpl<_$RouteWaypointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteWaypointImplToJson(
      this,
    );
  }
}

abstract class _RouteWaypoint implements RouteWaypoint {
  const factory _RouteWaypoint(
      {required final double lat,
      required final double lng}) = _$RouteWaypointImpl;

  factory _RouteWaypoint.fromJson(Map<String, dynamic> json) =
      _$RouteWaypointImpl.fromJson;

  @override
  double get lat;
  @override
  double get lng;

  /// Create a copy of RouteWaypoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteWaypointImplCopyWith<_$RouteWaypointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
