// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'publishing_submission_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PublishingSubmissionModel _$PublishingSubmissionModelFromJson(
    Map<String, dynamic> json) {
  return _PublishingSubmissionModel.fromJson(json);
}

/// @nodoc
mixin _$PublishingSubmissionModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get versionId => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String get creatorName => throw _privateConstructorUsedError;
  SubmissionStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get submittedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get reviewedAt => throw _privateConstructorUsedError;
  String? get reviewerId => throw _privateConstructorUsedError;
  String? get reviewerName => throw _privateConstructorUsedError;
  List<ReviewFeedbackModel> get feedback => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  String? get resubmissionJustification => throw _privateConstructorUsedError;
  int get resubmissionCount => throw _privateConstructorUsedError;
  bool get creatorIgnoredSuggestions => throw _privateConstructorUsedError;
  String? get tourTitle => throw _privateConstructorUsedError;
  String? get tourDescription => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PublishingSubmissionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PublishingSubmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublishingSubmissionModelCopyWith<PublishingSubmissionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublishingSubmissionModelCopyWith<$Res> {
  factory $PublishingSubmissionModelCopyWith(PublishingSubmissionModel value,
          $Res Function(PublishingSubmissionModel) then) =
      _$PublishingSubmissionModelCopyWithImpl<$Res, PublishingSubmissionModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      String creatorId,
      String creatorName,
      SubmissionStatus status,
      @TimestampConverter() DateTime submittedAt,
      @NullableTimestampConverter() DateTime? reviewedAt,
      String? reviewerId,
      String? reviewerName,
      List<ReviewFeedbackModel> feedback,
      String? rejectionReason,
      String? resubmissionJustification,
      int resubmissionCount,
      bool creatorIgnoredSuggestions,
      String? tourTitle,
      String? tourDescription,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$PublishingSubmissionModelCopyWithImpl<$Res,
        $Val extends PublishingSubmissionModel>
    implements $PublishingSubmissionModelCopyWith<$Res> {
  _$PublishingSubmissionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublishingSubmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? creatorId = null,
    Object? creatorName = null,
    Object? status = null,
    Object? submittedAt = null,
    Object? reviewedAt = freezed,
    Object? reviewerId = freezed,
    Object? reviewerName = freezed,
    Object? feedback = null,
    Object? rejectionReason = freezed,
    Object? resubmissionJustification = freezed,
    Object? resubmissionCount = null,
    Object? creatorIgnoredSuggestions = null,
    Object? tourTitle = freezed,
    Object? tourDescription = freezed,
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
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      creatorName: null == creatorName
          ? _value.creatorName
          : creatorName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubmissionStatus,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewerId: freezed == reviewerId
          ? _value.reviewerId
          : reviewerId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewerName: freezed == reviewerName
          ? _value.reviewerName
          : reviewerName // ignore: cast_nullable_to_non_nullable
              as String?,
      feedback: null == feedback
          ? _value.feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as List<ReviewFeedbackModel>,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      resubmissionJustification: freezed == resubmissionJustification
          ? _value.resubmissionJustification
          : resubmissionJustification // ignore: cast_nullable_to_non_nullable
              as String?,
      resubmissionCount: null == resubmissionCount
          ? _value.resubmissionCount
          : resubmissionCount // ignore: cast_nullable_to_non_nullable
              as int,
      creatorIgnoredSuggestions: null == creatorIgnoredSuggestions
          ? _value.creatorIgnoredSuggestions
          : creatorIgnoredSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      tourTitle: freezed == tourTitle
          ? _value.tourTitle
          : tourTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      tourDescription: freezed == tourDescription
          ? _value.tourDescription
          : tourDescription // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PublishingSubmissionModelImplCopyWith<$Res>
    implements $PublishingSubmissionModelCopyWith<$Res> {
  factory _$$PublishingSubmissionModelImplCopyWith(
          _$PublishingSubmissionModelImpl value,
          $Res Function(_$PublishingSubmissionModelImpl) then) =
      __$$PublishingSubmissionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      String creatorId,
      String creatorName,
      SubmissionStatus status,
      @TimestampConverter() DateTime submittedAt,
      @NullableTimestampConverter() DateTime? reviewedAt,
      String? reviewerId,
      String? reviewerName,
      List<ReviewFeedbackModel> feedback,
      String? rejectionReason,
      String? resubmissionJustification,
      int resubmissionCount,
      bool creatorIgnoredSuggestions,
      String? tourTitle,
      String? tourDescription,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$PublishingSubmissionModelImplCopyWithImpl<$Res>
    extends _$PublishingSubmissionModelCopyWithImpl<$Res,
        _$PublishingSubmissionModelImpl>
    implements _$$PublishingSubmissionModelImplCopyWith<$Res> {
  __$$PublishingSubmissionModelImplCopyWithImpl(
      _$PublishingSubmissionModelImpl _value,
      $Res Function(_$PublishingSubmissionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublishingSubmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? creatorId = null,
    Object? creatorName = null,
    Object? status = null,
    Object? submittedAt = null,
    Object? reviewedAt = freezed,
    Object? reviewerId = freezed,
    Object? reviewerName = freezed,
    Object? feedback = null,
    Object? rejectionReason = freezed,
    Object? resubmissionJustification = freezed,
    Object? resubmissionCount = null,
    Object? creatorIgnoredSuggestions = null,
    Object? tourTitle = freezed,
    Object? tourDescription = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PublishingSubmissionModelImpl(
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SubmissionStatus,
      submittedAt: null == submittedAt
          ? _value.submittedAt
          : submittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reviewedAt: freezed == reviewedAt
          ? _value.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewerId: freezed == reviewerId
          ? _value.reviewerId
          : reviewerId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewerName: freezed == reviewerName
          ? _value.reviewerName
          : reviewerName // ignore: cast_nullable_to_non_nullable
              as String?,
      feedback: null == feedback
          ? _value._feedback
          : feedback // ignore: cast_nullable_to_non_nullable
              as List<ReviewFeedbackModel>,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      resubmissionJustification: freezed == resubmissionJustification
          ? _value.resubmissionJustification
          : resubmissionJustification // ignore: cast_nullable_to_non_nullable
              as String?,
      resubmissionCount: null == resubmissionCount
          ? _value.resubmissionCount
          : resubmissionCount // ignore: cast_nullable_to_non_nullable
              as int,
      creatorIgnoredSuggestions: null == creatorIgnoredSuggestions
          ? _value.creatorIgnoredSuggestions
          : creatorIgnoredSuggestions // ignore: cast_nullable_to_non_nullable
              as bool,
      tourTitle: freezed == tourTitle
          ? _value.tourTitle
          : tourTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      tourDescription: freezed == tourDescription
          ? _value.tourDescription
          : tourDescription // ignore: cast_nullable_to_non_nullable
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
class _$PublishingSubmissionModelImpl extends _PublishingSubmissionModel {
  const _$PublishingSubmissionModelImpl(
      {required this.id,
      required this.tourId,
      required this.versionId,
      required this.creatorId,
      required this.creatorName,
      required this.status,
      @TimestampConverter() required this.submittedAt,
      @NullableTimestampConverter() this.reviewedAt,
      this.reviewerId,
      this.reviewerName,
      final List<ReviewFeedbackModel> feedback = const [],
      this.rejectionReason,
      this.resubmissionJustification,
      this.resubmissionCount = 0,
      this.creatorIgnoredSuggestions = false,
      this.tourTitle,
      this.tourDescription,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : _feedback = feedback,
        super._();

  factory _$PublishingSubmissionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PublishingSubmissionModelImplFromJson(json);

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
  final SubmissionStatus status;
  @override
  @TimestampConverter()
  final DateTime submittedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? reviewedAt;
  @override
  final String? reviewerId;
  @override
  final String? reviewerName;
  final List<ReviewFeedbackModel> _feedback;
  @override
  @JsonKey()
  List<ReviewFeedbackModel> get feedback {
    if (_feedback is EqualUnmodifiableListView) return _feedback;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feedback);
  }

  @override
  final String? rejectionReason;
  @override
  final String? resubmissionJustification;
  @override
  @JsonKey()
  final int resubmissionCount;
  @override
  @JsonKey()
  final bool creatorIgnoredSuggestions;
  @override
  final String? tourTitle;
  @override
  final String? tourDescription;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PublishingSubmissionModel(id: $id, tourId: $tourId, versionId: $versionId, creatorId: $creatorId, creatorName: $creatorName, status: $status, submittedAt: $submittedAt, reviewedAt: $reviewedAt, reviewerId: $reviewerId, reviewerName: $reviewerName, feedback: $feedback, rejectionReason: $rejectionReason, resubmissionJustification: $resubmissionJustification, resubmissionCount: $resubmissionCount, creatorIgnoredSuggestions: $creatorIgnoredSuggestions, tourTitle: $tourTitle, tourDescription: $tourDescription, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublishingSubmissionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.versionId, versionId) ||
                other.versionId == versionId) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.reviewerId, reviewerId) ||
                other.reviewerId == reviewerId) &&
            (identical(other.reviewerName, reviewerName) ||
                other.reviewerName == reviewerName) &&
            const DeepCollectionEquality().equals(other._feedback, _feedback) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.resubmissionJustification,
                    resubmissionJustification) ||
                other.resubmissionJustification == resubmissionJustification) &&
            (identical(other.resubmissionCount, resubmissionCount) ||
                other.resubmissionCount == resubmissionCount) &&
            (identical(other.creatorIgnoredSuggestions,
                    creatorIgnoredSuggestions) ||
                other.creatorIgnoredSuggestions == creatorIgnoredSuggestions) &&
            (identical(other.tourTitle, tourTitle) ||
                other.tourTitle == tourTitle) &&
            (identical(other.tourDescription, tourDescription) ||
                other.tourDescription == tourDescription) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        tourId,
        versionId,
        creatorId,
        creatorName,
        status,
        submittedAt,
        reviewedAt,
        reviewerId,
        reviewerName,
        const DeepCollectionEquality().hash(_feedback),
        rejectionReason,
        resubmissionJustification,
        resubmissionCount,
        creatorIgnoredSuggestions,
        tourTitle,
        tourDescription,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of PublishingSubmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublishingSubmissionModelImplCopyWith<_$PublishingSubmissionModelImpl>
      get copyWith => __$$PublishingSubmissionModelImplCopyWithImpl<
          _$PublishingSubmissionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PublishingSubmissionModelImplToJson(
      this,
    );
  }
}

abstract class _PublishingSubmissionModel extends PublishingSubmissionModel {
  const factory _PublishingSubmissionModel(
          {required final String id,
          required final String tourId,
          required final String versionId,
          required final String creatorId,
          required final String creatorName,
          required final SubmissionStatus status,
          @TimestampConverter() required final DateTime submittedAt,
          @NullableTimestampConverter() final DateTime? reviewedAt,
          final String? reviewerId,
          final String? reviewerName,
          final List<ReviewFeedbackModel> feedback,
          final String? rejectionReason,
          final String? resubmissionJustification,
          final int resubmissionCount,
          final bool creatorIgnoredSuggestions,
          final String? tourTitle,
          final String? tourDescription,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$PublishingSubmissionModelImpl;
  const _PublishingSubmissionModel._() : super._();

  factory _PublishingSubmissionModel.fromJson(Map<String, dynamic> json) =
      _$PublishingSubmissionModelImpl.fromJson;

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
  SubmissionStatus get status;
  @override
  @TimestampConverter()
  DateTime get submittedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get reviewedAt;
  @override
  String? get reviewerId;
  @override
  String? get reviewerName;
  @override
  List<ReviewFeedbackModel> get feedback;
  @override
  String? get rejectionReason;
  @override
  String? get resubmissionJustification;
  @override
  int get resubmissionCount;
  @override
  bool get creatorIgnoredSuggestions;
  @override
  String? get tourTitle;
  @override
  String? get tourDescription;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of PublishingSubmissionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublishingSubmissionModelImplCopyWith<_$PublishingSubmissionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
