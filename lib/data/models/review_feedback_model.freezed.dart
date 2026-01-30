// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_feedback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReviewFeedbackModel _$ReviewFeedbackModelFromJson(Map<String, dynamic> json) {
  return _ReviewFeedbackModel.fromJson(json);
}

/// @nodoc
mixin _$ReviewFeedbackModel {
  String get id => throw _privateConstructorUsedError;
  String get submissionId => throw _privateConstructorUsedError;
  String get reviewerId => throw _privateConstructorUsedError;
  String get reviewerName => throw _privateConstructorUsedError;
  FeedbackType get type => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get stopId => throw _privateConstructorUsedError;
  String? get stopName => throw _privateConstructorUsedError;
  FeedbackPriority get priority => throw _privateConstructorUsedError;
  bool get resolved => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get resolvedAt => throw _privateConstructorUsedError;
  String? get resolvedBy => throw _privateConstructorUsedError;
  String? get resolutionNote => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ReviewFeedbackModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewFeedbackModelCopyWith<ReviewFeedbackModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewFeedbackModelCopyWith<$Res> {
  factory $ReviewFeedbackModelCopyWith(
          ReviewFeedbackModel value, $Res Function(ReviewFeedbackModel) then) =
      _$ReviewFeedbackModelCopyWithImpl<$Res, ReviewFeedbackModel>;
  @useResult
  $Res call(
      {String id,
      String submissionId,
      String reviewerId,
      String reviewerName,
      FeedbackType type,
      String message,
      String? stopId,
      String? stopName,
      FeedbackPriority priority,
      bool resolved,
      @NullableTimestampConverter() DateTime? resolvedAt,
      String? resolvedBy,
      String? resolutionNote,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class _$ReviewFeedbackModelCopyWithImpl<$Res, $Val extends ReviewFeedbackModel>
    implements $ReviewFeedbackModelCopyWith<$Res> {
  _$ReviewFeedbackModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? reviewerId = null,
    Object? reviewerName = null,
    Object? type = null,
    Object? message = null,
    Object? stopId = freezed,
    Object? stopName = freezed,
    Object? priority = null,
    Object? resolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
    Object? resolutionNote = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      submissionId: null == submissionId
          ? _value.submissionId
          : submissionId // ignore: cast_nullable_to_non_nullable
              as String,
      reviewerId: null == reviewerId
          ? _value.reviewerId
          : reviewerId // ignore: cast_nullable_to_non_nullable
              as String,
      reviewerName: null == reviewerName
          ? _value.reviewerName
          : reviewerName // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeedbackType,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      stopId: freezed == stopId
          ? _value.stopId
          : stopId // ignore: cast_nullable_to_non_nullable
              as String?,
      stopName: freezed == stopName
          ? _value.stopName
          : stopName // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as FeedbackPriority,
      resolved: null == resolved
          ? _value.resolved
          : resolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolutionNote: freezed == resolutionNote
          ? _value.resolutionNote
          : resolutionNote // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewFeedbackModelImplCopyWith<$Res>
    implements $ReviewFeedbackModelCopyWith<$Res> {
  factory _$$ReviewFeedbackModelImplCopyWith(_$ReviewFeedbackModelImpl value,
          $Res Function(_$ReviewFeedbackModelImpl) then) =
      __$$ReviewFeedbackModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String submissionId,
      String reviewerId,
      String reviewerName,
      FeedbackType type,
      String message,
      String? stopId,
      String? stopName,
      FeedbackPriority priority,
      bool resolved,
      @NullableTimestampConverter() DateTime? resolvedAt,
      String? resolvedBy,
      String? resolutionNote,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class __$$ReviewFeedbackModelImplCopyWithImpl<$Res>
    extends _$ReviewFeedbackModelCopyWithImpl<$Res, _$ReviewFeedbackModelImpl>
    implements _$$ReviewFeedbackModelImplCopyWith<$Res> {
  __$$ReviewFeedbackModelImplCopyWithImpl(_$ReviewFeedbackModelImpl _value,
      $Res Function(_$ReviewFeedbackModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? reviewerId = null,
    Object? reviewerName = null,
    Object? type = null,
    Object? message = null,
    Object? stopId = freezed,
    Object? stopName = freezed,
    Object? priority = null,
    Object? resolved = null,
    Object? resolvedAt = freezed,
    Object? resolvedBy = freezed,
    Object? resolutionNote = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$ReviewFeedbackModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      submissionId: null == submissionId
          ? _value.submissionId
          : submissionId // ignore: cast_nullable_to_non_nullable
              as String,
      reviewerId: null == reviewerId
          ? _value.reviewerId
          : reviewerId // ignore: cast_nullable_to_non_nullable
              as String,
      reviewerName: null == reviewerName
          ? _value.reviewerName
          : reviewerName // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as FeedbackType,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      stopId: freezed == stopId
          ? _value.stopId
          : stopId // ignore: cast_nullable_to_non_nullable
              as String?,
      stopName: freezed == stopName
          ? _value.stopName
          : stopName // ignore: cast_nullable_to_non_nullable
              as String?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as FeedbackPriority,
      resolved: null == resolved
          ? _value.resolved
          : resolved // ignore: cast_nullable_to_non_nullable
              as bool,
      resolvedAt: freezed == resolvedAt
          ? _value.resolvedAt
          : resolvedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolvedBy: freezed == resolvedBy
          ? _value.resolvedBy
          : resolvedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      resolutionNote: freezed == resolutionNote
          ? _value.resolutionNote
          : resolutionNote // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewFeedbackModelImpl extends _ReviewFeedbackModel {
  const _$ReviewFeedbackModelImpl(
      {required this.id,
      required this.submissionId,
      required this.reviewerId,
      required this.reviewerName,
      required this.type,
      required this.message,
      this.stopId,
      this.stopName,
      this.priority = FeedbackPriority.medium,
      this.resolved = false,
      @NullableTimestampConverter() this.resolvedAt,
      this.resolvedBy,
      this.resolutionNote,
      @TimestampConverter() required this.createdAt})
      : super._();

  factory _$ReviewFeedbackModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewFeedbackModelImplFromJson(json);

  @override
  final String id;
  @override
  final String submissionId;
  @override
  final String reviewerId;
  @override
  final String reviewerName;
  @override
  final FeedbackType type;
  @override
  final String message;
  @override
  final String? stopId;
  @override
  final String? stopName;
  @override
  @JsonKey()
  final FeedbackPriority priority;
  @override
  @JsonKey()
  final bool resolved;
  @override
  @NullableTimestampConverter()
  final DateTime? resolvedAt;
  @override
  final String? resolvedBy;
  @override
  final String? resolutionNote;
  @override
  @TimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'ReviewFeedbackModel(id: $id, submissionId: $submissionId, reviewerId: $reviewerId, reviewerName: $reviewerName, type: $type, message: $message, stopId: $stopId, stopName: $stopName, priority: $priority, resolved: $resolved, resolvedAt: $resolvedAt, resolvedBy: $resolvedBy, resolutionNote: $resolutionNote, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewFeedbackModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId) &&
            (identical(other.reviewerId, reviewerId) ||
                other.reviewerId == reviewerId) &&
            (identical(other.reviewerName, reviewerName) ||
                other.reviewerName == reviewerName) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.stopId, stopId) || other.stopId == stopId) &&
            (identical(other.stopName, stopName) ||
                other.stopName == stopName) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.resolved, resolved) ||
                other.resolved == resolved) &&
            (identical(other.resolvedAt, resolvedAt) ||
                other.resolvedAt == resolvedAt) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolutionNote, resolutionNote) ||
                other.resolutionNote == resolutionNote) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      submissionId,
      reviewerId,
      reviewerName,
      type,
      message,
      stopId,
      stopName,
      priority,
      resolved,
      resolvedAt,
      resolvedBy,
      resolutionNote,
      createdAt);

  /// Create a copy of ReviewFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewFeedbackModelImplCopyWith<_$ReviewFeedbackModelImpl> get copyWith =>
      __$$ReviewFeedbackModelImplCopyWithImpl<_$ReviewFeedbackModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewFeedbackModelImplToJson(
      this,
    );
  }
}

abstract class _ReviewFeedbackModel extends ReviewFeedbackModel {
  const factory _ReviewFeedbackModel(
          {required final String id,
          required final String submissionId,
          required final String reviewerId,
          required final String reviewerName,
          required final FeedbackType type,
          required final String message,
          final String? stopId,
          final String? stopName,
          final FeedbackPriority priority,
          final bool resolved,
          @NullableTimestampConverter() final DateTime? resolvedAt,
          final String? resolvedBy,
          final String? resolutionNote,
          @TimestampConverter() required final DateTime createdAt}) =
      _$ReviewFeedbackModelImpl;
  const _ReviewFeedbackModel._() : super._();

  factory _ReviewFeedbackModel.fromJson(Map<String, dynamic> json) =
      _$ReviewFeedbackModelImpl.fromJson;

  @override
  String get id;
  @override
  String get submissionId;
  @override
  String get reviewerId;
  @override
  String get reviewerName;
  @override
  FeedbackType get type;
  @override
  String get message;
  @override
  String? get stopId;
  @override
  String? get stopName;
  @override
  FeedbackPriority get priority;
  @override
  bool get resolved;
  @override
  @NullableTimestampConverter()
  DateTime? get resolvedAt;
  @override
  String? get resolvedBy;
  @override
  String? get resolutionNote;
  @override
  @TimestampConverter()
  DateTime get createdAt;

  /// Create a copy of ReviewFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewFeedbackModelImplCopyWith<_$ReviewFeedbackModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
