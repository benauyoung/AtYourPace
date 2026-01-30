// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'waypoint_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WaypointModel _$WaypointModelFromJson(Map<String, dynamic> json) {
  return _WaypointModel.fromJson(json);
}

/// @nodoc
mixin _$WaypointModel {
  String get id => throw _privateConstructorUsedError;
  String get routeId => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  @LatLngConverter()
  LatLng get location => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get triggerRadius => throw _privateConstructorUsedError;
  WaypointType get type => throw _privateConstructorUsedError;
  String? get stopId => throw _privateConstructorUsedError;
  bool get manualPosition => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WaypointModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WaypointModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WaypointModelCopyWith<WaypointModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaypointModelCopyWith<$Res> {
  factory $WaypointModelCopyWith(
          WaypointModel value, $Res Function(WaypointModel) then) =
      _$WaypointModelCopyWithImpl<$Res, WaypointModel>;
  @useResult
  $Res call(
      {String id,
      String routeId,
      int order,
      @LatLngConverter() LatLng location,
      String name,
      int triggerRadius,
      WaypointType type,
      String? stopId,
      bool manualPosition,
      Map<String, dynamic> metadata,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$WaypointModelCopyWithImpl<$Res, $Val extends WaypointModel>
    implements $WaypointModelCopyWith<$Res> {
  _$WaypointModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WaypointModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? routeId = null,
    Object? order = null,
    Object? location = null,
    Object? name = null,
    Object? triggerRadius = null,
    Object? type = null,
    Object? stopId = freezed,
    Object? manualPosition = null,
    Object? metadata = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      routeId: null == routeId
          ? _value.routeId
          : routeId // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      triggerRadius: null == triggerRadius
          ? _value.triggerRadius
          : triggerRadius // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WaypointType,
      stopId: freezed == stopId
          ? _value.stopId
          : stopId // ignore: cast_nullable_to_non_nullable
              as String?,
      manualPosition: null == manualPosition
          ? _value.manualPosition
          : manualPosition // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$WaypointModelImplCopyWith<$Res>
    implements $WaypointModelCopyWith<$Res> {
  factory _$$WaypointModelImplCopyWith(
          _$WaypointModelImpl value, $Res Function(_$WaypointModelImpl) then) =
      __$$WaypointModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String routeId,
      int order,
      @LatLngConverter() LatLng location,
      String name,
      int triggerRadius,
      WaypointType type,
      String? stopId,
      bool manualPosition,
      Map<String, dynamic> metadata,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$WaypointModelImplCopyWithImpl<$Res>
    extends _$WaypointModelCopyWithImpl<$Res, _$WaypointModelImpl>
    implements _$$WaypointModelImplCopyWith<$Res> {
  __$$WaypointModelImplCopyWithImpl(
      _$WaypointModelImpl _value, $Res Function(_$WaypointModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of WaypointModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? routeId = null,
    Object? order = null,
    Object? location = null,
    Object? name = null,
    Object? triggerRadius = null,
    Object? type = null,
    Object? stopId = freezed,
    Object? manualPosition = null,
    Object? metadata = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$WaypointModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      routeId: null == routeId
          ? _value.routeId
          : routeId // ignore: cast_nullable_to_non_nullable
              as String,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      triggerRadius: null == triggerRadius
          ? _value.triggerRadius
          : triggerRadius // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as WaypointType,
      stopId: freezed == stopId
          ? _value.stopId
          : stopId // ignore: cast_nullable_to_non_nullable
              as String?,
      manualPosition: null == manualPosition
          ? _value.manualPosition
          : manualPosition // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$WaypointModelImpl extends _WaypointModel {
  const _$WaypointModelImpl(
      {required this.id,
      required this.routeId,
      required this.order,
      @LatLngConverter() required this.location,
      required this.name,
      this.triggerRadius = 30,
      this.type = WaypointType.stop,
      this.stopId,
      this.manualPosition = false,
      final Map<String, dynamic> metadata = const {},
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : _metadata = metadata,
        super._();

  factory _$WaypointModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WaypointModelImplFromJson(json);

  @override
  final String id;
  @override
  final String routeId;
  @override
  final int order;
  @override
  @LatLngConverter()
  final LatLng location;
  @override
  final String name;
  @override
  @JsonKey()
  final int triggerRadius;
  @override
  @JsonKey()
  final WaypointType type;
  @override
  final String? stopId;
  @override
  @JsonKey()
  final bool manualPosition;
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
    return 'WaypointModel(id: $id, routeId: $routeId, order: $order, location: $location, name: $name, triggerRadius: $triggerRadius, type: $type, stopId: $stopId, manualPosition: $manualPosition, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WaypointModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.routeId, routeId) || other.routeId == routeId) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.triggerRadius, triggerRadius) ||
                other.triggerRadius == triggerRadius) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.stopId, stopId) || other.stopId == stopId) &&
            (identical(other.manualPosition, manualPosition) ||
                other.manualPosition == manualPosition) &&
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
      routeId,
      order,
      location,
      name,
      triggerRadius,
      type,
      stopId,
      manualPosition,
      const DeepCollectionEquality().hash(_metadata),
      createdAt,
      updatedAt);

  /// Create a copy of WaypointModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WaypointModelImplCopyWith<_$WaypointModelImpl> get copyWith =>
      __$$WaypointModelImplCopyWithImpl<_$WaypointModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WaypointModelImplToJson(
      this,
    );
  }
}

abstract class _WaypointModel extends WaypointModel {
  const factory _WaypointModel(
          {required final String id,
          required final String routeId,
          required final int order,
          @LatLngConverter() required final LatLng location,
          required final String name,
          final int triggerRadius,
          final WaypointType type,
          final String? stopId,
          final bool manualPosition,
          final Map<String, dynamic> metadata,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$WaypointModelImpl;
  const _WaypointModel._() : super._();

  factory _WaypointModel.fromJson(Map<String, dynamic> json) =
      _$WaypointModelImpl.fromJson;

  @override
  String get id;
  @override
  String get routeId;
  @override
  int get order;
  @override
  @LatLngConverter()
  LatLng get location;
  @override
  String get name;
  @override
  int get triggerRadius;
  @override
  WaypointType get type;
  @override
  String? get stopId;
  @override
  bool get manualPosition;
  @override
  Map<String, dynamic> get metadata;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of WaypointModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WaypointModelImplCopyWith<_$WaypointModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
