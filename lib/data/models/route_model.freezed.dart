// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RouteModel _$RouteModelFromJson(Map<String, dynamic> json) {
  return _RouteModel.fromJson(json);
}

/// @nodoc
mixin _$RouteModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get versionId => throw _privateConstructorUsedError;
  List<WaypointModel> get waypoints => throw _privateConstructorUsedError;
  @LatLngListConverter()
  List<LatLng> get routePolyline => throw _privateConstructorUsedError;
  RouteSnapMode get snapMode => throw _privateConstructorUsedError;
  double get totalDistance => throw _privateConstructorUsedError;
  int get estimatedDuration => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this RouteModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RouteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RouteModelCopyWith<RouteModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteModelCopyWith<$Res> {
  factory $RouteModelCopyWith(
          RouteModel value, $Res Function(RouteModel) then) =
      _$RouteModelCopyWithImpl<$Res, RouteModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      List<WaypointModel> waypoints,
      @LatLngListConverter() List<LatLng> routePolyline,
      RouteSnapMode snapMode,
      double totalDistance,
      int estimatedDuration,
      Map<String, dynamic> metadata,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$RouteModelCopyWithImpl<$Res, $Val extends RouteModel>
    implements $RouteModelCopyWith<$Res> {
  _$RouteModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RouteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? waypoints = null,
    Object? routePolyline = null,
    Object? snapMode = null,
    Object? totalDistance = null,
    Object? estimatedDuration = null,
    Object? metadata = null,
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
      versionId: null == versionId
          ? _value.versionId
          : versionId // ignore: cast_nullable_to_non_nullable
              as String,
      waypoints: null == waypoints
          ? _value.waypoints
          : waypoints // ignore: cast_nullable_to_non_nullable
              as List<WaypointModel>,
      routePolyline: null == routePolyline
          ? _value.routePolyline
          : routePolyline // ignore: cast_nullable_to_non_nullable
              as List<LatLng>,
      snapMode: null == snapMode
          ? _value.snapMode
          : snapMode // ignore: cast_nullable_to_non_nullable
              as RouteSnapMode,
      totalDistance: null == totalDistance
          ? _value.totalDistance
          : totalDistance // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedDuration: null == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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
}

/// @nodoc
abstract class _$$RouteModelImplCopyWith<$Res>
    implements $RouteModelCopyWith<$Res> {
  factory _$$RouteModelImplCopyWith(
          _$RouteModelImpl value, $Res Function(_$RouteModelImpl) then) =
      __$$RouteModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      List<WaypointModel> waypoints,
      @LatLngListConverter() List<LatLng> routePolyline,
      RouteSnapMode snapMode,
      double totalDistance,
      int estimatedDuration,
      Map<String, dynamic> metadata,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$RouteModelImplCopyWithImpl<$Res>
    extends _$RouteModelCopyWithImpl<$Res, _$RouteModelImpl>
    implements _$$RouteModelImplCopyWith<$Res> {
  __$$RouteModelImplCopyWithImpl(
      _$RouteModelImpl _value, $Res Function(_$RouteModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RouteModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? waypoints = null,
    Object? routePolyline = null,
    Object? snapMode = null,
    Object? totalDistance = null,
    Object? estimatedDuration = null,
    Object? metadata = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RouteModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      versionId: null == versionId
          ? _value.versionId
          : versionId // ignore: cast_nullable_to_non_nullable
              as String,
      waypoints: null == waypoints
          ? _value._waypoints
          : waypoints // ignore: cast_nullable_to_non_nullable
              as List<WaypointModel>,
      routePolyline: null == routePolyline
          ? _value._routePolyline
          : routePolyline // ignore: cast_nullable_to_non_nullable
              as List<LatLng>,
      snapMode: null == snapMode
          ? _value.snapMode
          : snapMode // ignore: cast_nullable_to_non_nullable
              as RouteSnapMode,
      totalDistance: null == totalDistance
          ? _value.totalDistance
          : totalDistance // ignore: cast_nullable_to_non_nullable
              as double,
      estimatedDuration: null == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
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
class _$RouteModelImpl extends _RouteModel {
  const _$RouteModelImpl(
      {required this.id,
      required this.tourId,
      required this.versionId,
      required final List<WaypointModel> waypoints,
      @LatLngListConverter() final List<LatLng> routePolyline = const [],
      this.snapMode = RouteSnapMode.roads,
      required this.totalDistance,
      required this.estimatedDuration,
      final Map<String, dynamic> metadata = const {},
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : _waypoints = waypoints,
        _routePolyline = routePolyline,
        _metadata = metadata,
        super._();

  factory _$RouteModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  final String versionId;
  final List<WaypointModel> _waypoints;
  @override
  List<WaypointModel> get waypoints {
    if (_waypoints is EqualUnmodifiableListView) return _waypoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_waypoints);
  }

  final List<LatLng> _routePolyline;
  @override
  @JsonKey()
  @LatLngListConverter()
  List<LatLng> get routePolyline {
    if (_routePolyline is EqualUnmodifiableListView) return _routePolyline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_routePolyline);
  }

  @override
  @JsonKey()
  final RouteSnapMode snapMode;
  @override
  final double totalDistance;
  @override
  final int estimatedDuration;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'RouteModel(id: $id, tourId: $tourId, versionId: $versionId, waypoints: $waypoints, routePolyline: $routePolyline, snapMode: $snapMode, totalDistance: $totalDistance, estimatedDuration: $estimatedDuration, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.versionId, versionId) ||
                other.versionId == versionId) &&
            const DeepCollectionEquality()
                .equals(other._waypoints, _waypoints) &&
            const DeepCollectionEquality()
                .equals(other._routePolyline, _routePolyline) &&
            (identical(other.snapMode, snapMode) ||
                other.snapMode == snapMode) &&
            (identical(other.totalDistance, totalDistance) ||
                other.totalDistance == totalDistance) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
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
      versionId,
      const DeepCollectionEquality().hash(_waypoints),
      const DeepCollectionEquality().hash(_routePolyline),
      snapMode,
      totalDistance,
      estimatedDuration,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  /// Create a copy of RouteModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteModelImplCopyWith<_$RouteModelImpl> get copyWith =>
      __$$RouteModelImplCopyWithImpl<_$RouteModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteModelImplToJson(
      this,
    );
  }
}

abstract class _RouteModel extends RouteModel {
  const factory _RouteModel(
          {required final String id,
          required final String tourId,
          required final String versionId,
          required final List<WaypointModel> waypoints,
          @LatLngListConverter() final List<LatLng> routePolyline,
          final RouteSnapMode snapMode,
          required final double totalDistance,
          required final int estimatedDuration,
          final Map<String, dynamic> metadata,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$RouteModelImpl;
  const _RouteModel._() : super._();

  factory _RouteModel.fromJson(Map<String, dynamic> json) =
      _$RouteModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  String get versionId;
  @override
  List<WaypointModel> get waypoints;
  @override
  @LatLngListConverter()
  List<LatLng> get routePolyline;
  @override
  RouteSnapMode get snapMode;
  @override
  double get totalDistance;
  @override
  int get estimatedDuration;
  @override
  Map<String, dynamic> get metadata;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of RouteModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RouteModelImplCopyWith<_$RouteModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
