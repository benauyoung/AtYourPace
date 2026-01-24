// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) {
  return _ReviewModel.fromJson(json);
}

/// @nodoc
mixin _$ReviewModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userPhotoUrl => throw _privateConstructorUsedError;
  int get rating => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ReviewModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewModelCopyWith<ReviewModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewModelCopyWith<$Res> {
  factory $ReviewModelCopyWith(
          ReviewModel value, $Res Function(ReviewModel) then) =
      _$ReviewModelCopyWithImpl<$Res, ReviewModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      String userId,
      String userName,
      String? userPhotoUrl,
      int rating,
      String? comment,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$ReviewModelCopyWithImpl<$Res, $Val extends ReviewModel>
    implements $ReviewModelCopyWith<$Res> {
  _$ReviewModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userPhotoUrl = freezed,
    Object? rating = null,
    Object? comment = freezed,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userPhotoUrl: freezed == userPhotoUrl
          ? _value.userPhotoUrl
          : userPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ReviewModelImplCopyWith<$Res>
    implements $ReviewModelCopyWith<$Res> {
  factory _$$ReviewModelImplCopyWith(
          _$ReviewModelImpl value, $Res Function(_$ReviewModelImpl) then) =
      __$$ReviewModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      String userId,
      String userName,
      String? userPhotoUrl,
      int rating,
      String? comment,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$ReviewModelImplCopyWithImpl<$Res>
    extends _$ReviewModelCopyWithImpl<$Res, _$ReviewModelImpl>
    implements _$$ReviewModelImplCopyWith<$Res> {
  __$$ReviewModelImplCopyWithImpl(
      _$ReviewModelImpl _value, $Res Function(_$ReviewModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userPhotoUrl = freezed,
    Object? rating = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ReviewModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userPhotoUrl: freezed == userPhotoUrl
          ? _value.userPhotoUrl
          : userPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
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
class _$ReviewModelImpl extends _ReviewModel {
  const _$ReviewModelImpl(
      {required this.id,
      required this.tourId,
      required this.userId,
      required this.userName,
      this.userPhotoUrl,
      required this.rating,
      this.comment,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : super._();

  factory _$ReviewModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userPhotoUrl;
  @override
  final int rating;
  @override
  final String? comment;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ReviewModel(id: $id, tourId: $tourId, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userPhotoUrl, userPhotoUrl) ||
                other.userPhotoUrl == userPhotoUrl) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tourId, userId, userName,
      userPhotoUrl, rating, comment, createdAt, updatedAt);

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewModelImplCopyWith<_$ReviewModelImpl> get copyWith =>
      __$$ReviewModelImplCopyWithImpl<_$ReviewModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewModelImplToJson(
      this,
    );
  }
}

abstract class _ReviewModel extends ReviewModel {
  const factory _ReviewModel(
          {required final String id,
          required final String tourId,
          required final String userId,
          required final String userName,
          final String? userPhotoUrl,
          required final int rating,
          final String? comment,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$ReviewModelImpl;
  const _ReviewModel._() : super._();

  factory _ReviewModel.fromJson(Map<String, dynamic> json) =
      _$ReviewModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userPhotoUrl;
  @override
  int get rating;
  @override
  String? get comment;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of ReviewModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewModelImplCopyWith<_$ReviewModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewQueueItem _$ReviewQueueItemFromJson(Map<String, dynamic> json) {
  return _ReviewQueueItem.fromJson(json);
}

/// @nodoc
mixin _$ReviewQueueItem {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get versionId => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String get creatorName => throw _privateConstructorUsedError;
  String get tourTitle => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get submittedAt => throw _privateConstructorUsedError;
  ReviewQueueStatus get status => throw _privateConstructorUsedError;
  String? get assignedTo => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this ReviewQueueItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewQueueItemCopyWith<ReviewQueueItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewQueueItemCopyWith<$Res> {
  factory $ReviewQueueItemCopyWith(
          ReviewQueueItem value, $Res Function(ReviewQueueItem) then) =
      _$ReviewQueueItemCopyWithImpl<$Res, ReviewQueueItem>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      String creatorId,
      String creatorName,
      String tourTitle,
      @TimestampConverter() DateTime submittedAt,
      ReviewQueueStatus status,
      String? assignedTo,
      int priority,
      String? notes});
}

/// @nodoc
class _$ReviewQueueItemCopyWithImpl<$Res, $Val extends ReviewQueueItem>
    implements $ReviewQueueItemCopyWith<$Res> {
  _$ReviewQueueItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? creatorId = null,
    Object? creatorName = null,
    Object? tourTitle = null,
    Object? submittedAt = null,
    Object? status = null,
    Object? assignedTo = freezed,
    Object? priority = null,
    Object? notes = freezed,
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
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      tourTitle: null == tourTitle
          ? _value.tourTitle
          : tourTitle // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReviewQueueStatus,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewQueueItemImplCopyWith<$Res>
    implements $ReviewQueueItemCopyWith<$Res> {
  factory _$$ReviewQueueItemImplCopyWith(_$ReviewQueueItemImpl value,
          $Res Function(_$ReviewQueueItemImpl) then) =
      __$$ReviewQueueItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      String creatorId,
      String creatorName,
      String tourTitle,
      @TimestampConverter() DateTime submittedAt,
      ReviewQueueStatus status,
      String? assignedTo,
      int priority,
      String? notes});
}

/// @nodoc
class __$$ReviewQueueItemImplCopyWithImpl<$Res>
    extends _$ReviewQueueItemCopyWithImpl<$Res, _$ReviewQueueItemImpl>
    implements _$$ReviewQueueItemImplCopyWith<$Res> {
  __$$ReviewQueueItemImplCopyWithImpl(
      _$ReviewQueueItemImpl _value, $Res Function(_$ReviewQueueItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? creatorId = null,
    Object? creatorName = null,
    Object? tourTitle = null,
    Object? submittedAt = null,
    Object? status = null,
    Object? assignedTo = freezed,
    Object? priority = null,
    Object? notes = freezed,
  }) {
    return _then(_$ReviewQueueItemImpl(
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
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      tourTitle: null == tourTitle
          ? _value.tourTitle
          : tourTitle // ignore: cast_nullable_to_non_nullable
              as String,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReviewQueueStatus,
      assignedTo: freezed == assignedTo
          ? _value.assignedTo
          : assignedTo // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewQueueItemImpl extends _ReviewQueueItem {
  const _$ReviewQueueItemImpl(
      {required this.id,
      required this.tourId,
      required this.versionId,
      required this.creatorId,
      required this.creatorName,
      required this.tourTitle,
      @TimestampConverter() required this.submittedAt,
      this.status = ReviewQueueStatus.pending,
      this.assignedTo,
      this.priority = 0,
      this.notes})
      : super._();

  factory _$ReviewQueueItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewQueueItemImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  final String versionId;
  @override
  final String creatorId;
  @override
  final String creatorName;
  @override
  final String tourTitle;
  @override
  @TimestampConverter()
  final DateTime submittedAt;
  @override
  @JsonKey()
  final ReviewQueueStatus status;
  @override
  final String? assignedTo;
  @override
  @JsonKey()
  final int priority;
  @override
  final String? notes;

  @override
  String toString() {
    return 'ReviewQueueItem(id: $id, tourId: $tourId, versionId: $versionId, creatorId: $creatorId, creatorName: $creatorName, tourTitle: $tourTitle, submittedAt: $submittedAt, status: $status, assignedTo: $assignedTo, priority: $priority, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewQueueItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.versionId, versionId) ||
                other.versionId == versionId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.tourTitle, tourTitle) ||
                other.tourTitle == tourTitle) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.assignedTo, assignedTo) ||
                other.assignedTo == assignedTo) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, tourId, versionId, creatorId,
      creatorName, tourTitle, submittedAt, status, assignedTo, priority, notes);

  /// Create a copy of ReviewQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewQueueItemImplCopyWith<_$ReviewQueueItemImpl> get copyWith =>
      __$$ReviewQueueItemImplCopyWithImpl<_$ReviewQueueItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewQueueItemImplToJson(
      this,
    );
  }
}

abstract class _ReviewQueueItem extends ReviewQueueItem {
  const factory _ReviewQueueItem(
      {required final String id,
      required final String tourId,
      required final String versionId,
      required final String creatorId,
      required final String creatorName,
      required final String tourTitle,
      @TimestampConverter() required final DateTime submittedAt,
      final ReviewQueueStatus status,
      final String? assignedTo,
      final int priority,
      final String? notes}) = _$ReviewQueueItemImpl;
  const _ReviewQueueItem._() : super._();

  factory _ReviewQueueItem.fromJson(Map<String, dynamic> json) =
      _$ReviewQueueItemImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  String get versionId;
  @override
  String get creatorId;
  @override
  String get creatorName;
  @override
  String get tourTitle;
  @override
  @TimestampConverter()
  DateTime get submittedAt;
  @override
  ReviewQueueStatus get status;
  @override
  String? get assignedTo;
  @override
  int get priority;
  @override
  String? get notes;

  /// Create a copy of ReviewQueueItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewQueueItemImplCopyWith<_$ReviewQueueItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
