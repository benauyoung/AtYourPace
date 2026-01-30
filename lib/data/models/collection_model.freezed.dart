// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CollectionModel _$CollectionModelFromJson(Map<String, dynamic> json) {
  return _CollectionModel.fromJson(json);
}

/// @nodoc
mixin _$CollectionModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get coverImageUrl => throw _privateConstructorUsedError;
  List<String> get tourIds => throw _privateConstructorUsedError;
  bool get isCurated => throw _privateConstructorUsedError;
  String? get curatorId => throw _privateConstructorUsedError;
  String? get curatorName => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  CollectionType get type => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get region => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CollectionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectionModelCopyWith<CollectionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectionModelCopyWith<$Res> {
  factory $CollectionModelCopyWith(
          CollectionModel value, $Res Function(CollectionModel) then) =
      _$CollectionModelCopyWithImpl<$Res, CollectionModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String? coverImageUrl,
      List<String> tourIds,
      bool isCurated,
      String? curatorId,
      String? curatorName,
      bool isFeatured,
      List<String> tags,
      CollectionType type,
      int sortOrder,
      String? city,
      String? region,
      String? country,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$CollectionModelCopyWithImpl<$Res, $Val extends CollectionModel>
    implements $CollectionModelCopyWith<$Res> {
  _$CollectionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? coverImageUrl = freezed,
    Object? tourIds = null,
    Object? isCurated = null,
    Object? curatorId = freezed,
    Object? curatorName = freezed,
    Object? isFeatured = null,
    Object? tags = null,
    Object? type = null,
    Object? sortOrder = null,
    Object? city = freezed,
    Object? region = freezed,
    Object? country = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tourIds: null == tourIds
          ? _value.tourIds
          : tourIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isCurated: null == isCurated
          ? _value.isCurated
          : isCurated // ignore: cast_nullable_to_non_nullable
              as bool,
      curatorId: freezed == curatorId
          ? _value.curatorId
          : curatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      curatorName: freezed == curatorName
          ? _value.curatorName
          : curatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CollectionType,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$CollectionModelImplCopyWith<$Res>
    implements $CollectionModelCopyWith<$Res> {
  factory _$$CollectionModelImplCopyWith(_$CollectionModelImpl value,
          $Res Function(_$CollectionModelImpl) then) =
      __$$CollectionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String? coverImageUrl,
      List<String> tourIds,
      bool isCurated,
      String? curatorId,
      String? curatorName,
      bool isFeatured,
      List<String> tags,
      CollectionType type,
      int sortOrder,
      String? city,
      String? region,
      String? country,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$CollectionModelImplCopyWithImpl<$Res>
    extends _$CollectionModelCopyWithImpl<$Res, _$CollectionModelImpl>
    implements _$$CollectionModelImplCopyWith<$Res> {
  __$$CollectionModelImplCopyWithImpl(
      _$CollectionModelImpl _value, $Res Function(_$CollectionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CollectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? coverImageUrl = freezed,
    Object? tourIds = null,
    Object? isCurated = null,
    Object? curatorId = freezed,
    Object? curatorName = freezed,
    Object? isFeatured = null,
    Object? tags = null,
    Object? type = null,
    Object? sortOrder = null,
    Object? city = freezed,
    Object? region = freezed,
    Object? country = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$CollectionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverImageUrl: freezed == coverImageUrl
          ? _value.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tourIds: null == tourIds
          ? _value._tourIds
          : tourIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isCurated: null == isCurated
          ? _value.isCurated
          : isCurated // ignore: cast_nullable_to_non_nullable
              as bool,
      curatorId: freezed == curatorId
          ? _value.curatorId
          : curatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      curatorName: freezed == curatorName
          ? _value.curatorName
          : curatorName // ignore: cast_nullable_to_non_nullable
              as String?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as CollectionType,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$CollectionModelImpl extends _CollectionModel {
  const _$CollectionModelImpl(
      {required this.id,
      required this.name,
      required this.description,
      this.coverImageUrl,
      required final List<String> tourIds,
      this.isCurated = true,
      this.curatorId,
      this.curatorName,
      this.isFeatured = false,
      final List<String> tags = const [],
      this.type = CollectionType.geographic,
      this.sortOrder = 0,
      this.city,
      this.region,
      this.country,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : _tourIds = tourIds,
        _tags = tags,
        super._();

  factory _$CollectionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String? coverImageUrl;
  final List<String> _tourIds;
  @override
  List<String> get tourIds {
    if (_tourIds is EqualUnmodifiableListView) return _tourIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tourIds);
  }

  @override
  @JsonKey()
  final bool isCurated;
  @override
  final String? curatorId;
  @override
  final String? curatorName;
  @override
  @JsonKey()
  final bool isFeatured;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final CollectionType type;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final String? city;
  @override
  final String? region;
  @override
  final String? country;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CollectionModel(id: $id, name: $name, description: $description, coverImageUrl: $coverImageUrl, tourIds: $tourIds, isCurated: $isCurated, curatorId: $curatorId, curatorName: $curatorName, isFeatured: $isFeatured, tags: $tags, type: $type, sortOrder: $sortOrder, city: $city, region: $region, country: $country, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            const DeepCollectionEquality().equals(other._tourIds, _tourIds) &&
            (identical(other.isCurated, isCurated) ||
                other.isCurated == isCurated) &&
            (identical(other.curatorId, curatorId) ||
                other.curatorId == curatorId) &&
            (identical(other.curatorName, curatorName) ||
                other.curatorName == curatorName) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.country, country) || other.country == country) &&
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
      name,
      description,
      coverImageUrl,
      const DeepCollectionEquality().hash(_tourIds),
      isCurated,
      curatorId,
      curatorName,
      isFeatured,
      const DeepCollectionEquality().hash(_tags),
      type,
      sortOrder,
      city,
      region,
      country,
      createdAt,
      updatedAt);

  /// Create a copy of CollectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectionModelImplCopyWith<_$CollectionModelImpl> get copyWith =>
      __$$CollectionModelImplCopyWithImpl<_$CollectionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectionModelImplToJson(
      this,
    );
  }
}

abstract class _CollectionModel extends CollectionModel {
  const factory _CollectionModel(
          {required final String id,
          required final String name,
          required final String description,
          final String? coverImageUrl,
          required final List<String> tourIds,
          final bool isCurated,
          final String? curatorId,
          final String? curatorName,
          final bool isFeatured,
          final List<String> tags,
          final CollectionType type,
          final int sortOrder,
          final String? city,
          final String? region,
          final String? country,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$CollectionModelImpl;
  const _CollectionModel._() : super._();

  factory _CollectionModel.fromJson(Map<String, dynamic> json) =
      _$CollectionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String? get coverImageUrl;
  @override
  List<String> get tourIds;
  @override
  bool get isCurated;
  @override
  String? get curatorId;
  @override
  String? get curatorName;
  @override
  bool get isFeatured;
  @override
  List<String> get tags;
  @override
  CollectionType get type;
  @override
  int get sortOrder;
  @override
  String? get city;
  @override
  String? get region;
  @override
  String? get country;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of CollectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectionModelImplCopyWith<_$CollectionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
