// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TourProgressModel _$TourProgressModelFromJson(Map<String, dynamic> json) {
  return _TourProgressModel.fromJson(json);
}

/// @nodoc
mixin _$TourProgressModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get versionId => throw _privateConstructorUsedError;
  TourProgressStatus get status => throw _privateConstructorUsedError;
  int get currentStopIndex => throw _privateConstructorUsedError;
  List<String> get completedStops => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get startedAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get totalTimeSpent => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get lastPlayedAt => throw _privateConstructorUsedError;

  /// Serializes this TourProgressModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TourProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TourProgressModelCopyWith<TourProgressModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TourProgressModelCopyWith<$Res> {
  factory $TourProgressModelCopyWith(
          TourProgressModel value, $Res Function(TourProgressModel) then) =
      _$TourProgressModelCopyWithImpl<$Res, TourProgressModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      String userId,
      String versionId,
      TourProgressStatus status,
      int currentStopIndex,
      List<String> completedStops,
      @NullableTimestampConverter() DateTime? startedAt,
      @NullableTimestampConverter() DateTime? completedAt,
      int totalTimeSpent,
      @TimestampConverter() DateTime lastPlayedAt});
}

/// @nodoc
class _$TourProgressModelCopyWithImpl<$Res, $Val extends TourProgressModel>
    implements $TourProgressModelCopyWith<$Res> {
  _$TourProgressModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TourProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? userId = null,
    Object? versionId = null,
    Object? status = null,
    Object? currentStopIndex = null,
    Object? completedStops = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? totalTimeSpent = null,
    Object? lastPlayedAt = null,
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
      versionId: null == versionId
          ? _value.versionId
          : versionId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TourProgressStatus,
      currentStopIndex: null == currentStopIndex
          ? _value.currentStopIndex
          : currentStopIndex // ignore: cast_nullable_to_non_nullable
              as int,
      completedStops: null == completedStops
          ? _value.completedStops
          : completedStops // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalTimeSpent: null == totalTimeSpent
          ? _value.totalTimeSpent
          : totalTimeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayedAt: null == lastPlayedAt
          ? _value.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TourProgressModelImplCopyWith<$Res>
    implements $TourProgressModelCopyWith<$Res> {
  factory _$$TourProgressModelImplCopyWith(_$TourProgressModelImpl value,
          $Res Function(_$TourProgressModelImpl) then) =
      __$$TourProgressModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      String userId,
      String versionId,
      TourProgressStatus status,
      int currentStopIndex,
      List<String> completedStops,
      @NullableTimestampConverter() DateTime? startedAt,
      @NullableTimestampConverter() DateTime? completedAt,
      int totalTimeSpent,
      @TimestampConverter() DateTime lastPlayedAt});
}

/// @nodoc
class __$$TourProgressModelImplCopyWithImpl<$Res>
    extends _$TourProgressModelCopyWithImpl<$Res, _$TourProgressModelImpl>
    implements _$$TourProgressModelImplCopyWith<$Res> {
  __$$TourProgressModelImplCopyWithImpl(_$TourProgressModelImpl _value,
      $Res Function(_$TourProgressModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TourProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? userId = null,
    Object? versionId = null,
    Object? status = null,
    Object? currentStopIndex = null,
    Object? completedStops = null,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? totalTimeSpent = null,
    Object? lastPlayedAt = null,
  }) {
    return _then(_$TourProgressModelImpl(
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
      versionId: null == versionId
          ? _value.versionId
          : versionId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TourProgressStatus,
      currentStopIndex: null == currentStopIndex
          ? _value.currentStopIndex
          : currentStopIndex // ignore: cast_nullable_to_non_nullable
              as int,
      completedStops: null == completedStops
          ? _value._completedStops
          : completedStops // ignore: cast_nullable_to_non_nullable
              as List<String>,
      startedAt: freezed == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalTimeSpent: null == totalTimeSpent
          ? _value.totalTimeSpent
          : totalTimeSpent // ignore: cast_nullable_to_non_nullable
              as int,
      lastPlayedAt: null == lastPlayedAt
          ? _value.lastPlayedAt
          : lastPlayedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TourProgressModelImpl extends _TourProgressModel {
  const _$TourProgressModelImpl(
      {required this.id,
      required this.tourId,
      required this.userId,
      required this.versionId,
      this.status = TourProgressStatus.notStarted,
      this.currentStopIndex = 0,
      final List<String> completedStops = const [],
      @NullableTimestampConverter() this.startedAt,
      @NullableTimestampConverter() this.completedAt,
      this.totalTimeSpent = 0,
      @TimestampConverter() required this.lastPlayedAt})
      : _completedStops = completedStops,
        super._();

  factory _$TourProgressModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TourProgressModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  final String userId;
  @override
  final String versionId;
  @override
  @JsonKey()
  final TourProgressStatus status;
  @override
  @JsonKey()
  final int currentStopIndex;
  final List<String> _completedStops;
  @override
  @JsonKey()
  List<String> get completedStops {
    if (_completedStops is EqualUnmodifiableListView) return _completedStops;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedStops);
  }

  @override
  @NullableTimestampConverter()
  final DateTime? startedAt;
  @override
  @NullableTimestampConverter()
  final DateTime? completedAt;
  @override
  @JsonKey()
  final int totalTimeSpent;
  @override
  @TimestampConverter()
  final DateTime lastPlayedAt;

  @override
  String toString() {
    return 'TourProgressModel(id: $id, tourId: $tourId, userId: $userId, versionId: $versionId, status: $status, currentStopIndex: $currentStopIndex, completedStops: $completedStops, startedAt: $startedAt, completedAt: $completedAt, totalTimeSpent: $totalTimeSpent, lastPlayedAt: $lastPlayedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TourProgressModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.versionId, versionId) ||
                other.versionId == versionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.currentStopIndex, currentStopIndex) ||
                other.currentStopIndex == currentStopIndex) &&
            const DeepCollectionEquality()
                .equals(other._completedStops, _completedStops) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.totalTimeSpent, totalTimeSpent) ||
                other.totalTimeSpent == totalTimeSpent) &&
            (identical(other.lastPlayedAt, lastPlayedAt) ||
                other.lastPlayedAt == lastPlayedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tourId,
      userId,
      versionId,
      status,
      currentStopIndex,
      const DeepCollectionEquality().hash(_completedStops),
      startedAt,
      completedAt,
      totalTimeSpent,
      lastPlayedAt);

  /// Create a copy of TourProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TourProgressModelImplCopyWith<_$TourProgressModelImpl> get copyWith =>
      __$$TourProgressModelImplCopyWithImpl<_$TourProgressModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TourProgressModelImplToJson(
      this,
    );
  }
}

abstract class _TourProgressModel extends TourProgressModel {
  const factory _TourProgressModel(
          {required final String id,
          required final String tourId,
          required final String userId,
          required final String versionId,
          final TourProgressStatus status,
          final int currentStopIndex,
          final List<String> completedStops,
          @NullableTimestampConverter() final DateTime? startedAt,
          @NullableTimestampConverter() final DateTime? completedAt,
          final int totalTimeSpent,
          @TimestampConverter() required final DateTime lastPlayedAt}) =
      _$TourProgressModelImpl;
  const _TourProgressModel._() : super._();

  factory _TourProgressModel.fromJson(Map<String, dynamic> json) =
      _$TourProgressModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  String get userId;
  @override
  String get versionId;
  @override
  TourProgressStatus get status;
  @override
  int get currentStopIndex;
  @override
  List<String> get completedStops;
  @override
  @NullableTimestampConverter()
  DateTime? get startedAt;
  @override
  @NullableTimestampConverter()
  DateTime? get completedAt;
  @override
  int get totalTimeSpent;
  @override
  @TimestampConverter()
  DateTime get lastPlayedAt;

  /// Create a copy of TourProgressModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TourProgressModelImplCopyWith<_$TourProgressModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadedTourModel _$DownloadedTourModelFromJson(Map<String, dynamic> json) {
  return _DownloadedTourModel.fromJson(json);
}

/// @nodoc
mixin _$DownloadedTourModel {
  String get id => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get versionId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get downloadedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get expiresAt => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  DownloadStatus get status => throw _privateConstructorUsedError;
  Map<String, String> get localPaths => throw _privateConstructorUsedError;

  /// Serializes this DownloadedTourModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadedTourModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadedTourModelCopyWith<DownloadedTourModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadedTourModelCopyWith<$Res> {
  factory $DownloadedTourModelCopyWith(
          DownloadedTourModel value, $Res Function(DownloadedTourModel) then) =
      _$DownloadedTourModelCopyWithImpl<$Res, DownloadedTourModel>;
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      String userId,
      @TimestampConverter() DateTime downloadedAt,
      @TimestampConverter() DateTime expiresAt,
      int fileSize,
      DownloadStatus status,
      Map<String, String> localPaths});
}

/// @nodoc
class _$DownloadedTourModelCopyWithImpl<$Res, $Val extends DownloadedTourModel>
    implements $DownloadedTourModelCopyWith<$Res> {
  _$DownloadedTourModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadedTourModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? userId = null,
    Object? downloadedAt = null,
    Object? expiresAt = null,
    Object? fileSize = null,
    Object? status = null,
    Object? localPaths = null,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      downloadedAt: null == downloadedAt
          ? _value.downloadedAt
          : downloadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
      localPaths: null == localPaths
          ? _value.localPaths
          : localPaths // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DownloadedTourModelImplCopyWith<$Res>
    implements $DownloadedTourModelCopyWith<$Res> {
  factory _$$DownloadedTourModelImplCopyWith(_$DownloadedTourModelImpl value,
          $Res Function(_$DownloadedTourModelImpl) then) =
      __$$DownloadedTourModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tourId,
      String versionId,
      String userId,
      @TimestampConverter() DateTime downloadedAt,
      @TimestampConverter() DateTime expiresAt,
      int fileSize,
      DownloadStatus status,
      Map<String, String> localPaths});
}

/// @nodoc
class __$$DownloadedTourModelImplCopyWithImpl<$Res>
    extends _$DownloadedTourModelCopyWithImpl<$Res, _$DownloadedTourModelImpl>
    implements _$$DownloadedTourModelImplCopyWith<$Res> {
  __$$DownloadedTourModelImplCopyWithImpl(_$DownloadedTourModelImpl _value,
      $Res Function(_$DownloadedTourModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of DownloadedTourModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tourId = null,
    Object? versionId = null,
    Object? userId = null,
    Object? downloadedAt = null,
    Object? expiresAt = null,
    Object? fileSize = null,
    Object? status = null,
    Object? localPaths = null,
  }) {
    return _then(_$DownloadedTourModelImpl(
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      downloadedAt: null == downloadedAt
          ? _value.downloadedAt
          : downloadedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as DownloadStatus,
      localPaths: null == localPaths
          ? _value._localPaths
          : localPaths // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadedTourModelImpl extends _DownloadedTourModel {
  const _$DownloadedTourModelImpl(
      {required this.id,
      required this.tourId,
      required this.versionId,
      required this.userId,
      @TimestampConverter() required this.downloadedAt,
      @TimestampConverter() required this.expiresAt,
      required this.fileSize,
      this.status = DownloadStatus.complete,
      final Map<String, String> localPaths = const {}})
      : _localPaths = localPaths,
        super._();

  factory _$DownloadedTourModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadedTourModelImplFromJson(json);

  @override
  final String id;
  @override
  final String tourId;
  @override
  final String versionId;
  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime downloadedAt;
  @override
  @TimestampConverter()
  final DateTime expiresAt;
  @override
  final int fileSize;
  @override
  @JsonKey()
  final DownloadStatus status;
  final Map<String, String> _localPaths;
  @override
  @JsonKey()
  Map<String, String> get localPaths {
    if (_localPaths is EqualUnmodifiableMapView) return _localPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_localPaths);
  }

  @override
  String toString() {
    return 'DownloadedTourModel(id: $id, tourId: $tourId, versionId: $versionId, userId: $userId, downloadedAt: $downloadedAt, expiresAt: $expiresAt, fileSize: $fileSize, status: $status, localPaths: $localPaths)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadedTourModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.versionId, versionId) ||
                other.versionId == versionId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.downloadedAt, downloadedAt) ||
                other.downloadedAt == downloadedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._localPaths, _localPaths));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tourId,
      versionId,
      userId,
      downloadedAt,
      expiresAt,
      fileSize,
      status,
      const DeepCollectionEquality().hash(_localPaths));

  /// Create a copy of DownloadedTourModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadedTourModelImplCopyWith<_$DownloadedTourModelImpl> get copyWith =>
      __$$DownloadedTourModelImplCopyWithImpl<_$DownloadedTourModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadedTourModelImplToJson(
      this,
    );
  }
}

abstract class _DownloadedTourModel extends DownloadedTourModel {
  const factory _DownloadedTourModel(
      {required final String id,
      required final String tourId,
      required final String versionId,
      required final String userId,
      @TimestampConverter() required final DateTime downloadedAt,
      @TimestampConverter() required final DateTime expiresAt,
      required final int fileSize,
      final DownloadStatus status,
      final Map<String, String> localPaths}) = _$DownloadedTourModelImpl;
  const _DownloadedTourModel._() : super._();

  factory _DownloadedTourModel.fromJson(Map<String, dynamic> json) =
      _$DownloadedTourModelImpl.fromJson;

  @override
  String get id;
  @override
  String get tourId;
  @override
  String get versionId;
  @override
  String get userId;
  @override
  @TimestampConverter()
  DateTime get downloadedAt;
  @override
  @TimestampConverter()
  DateTime get expiresAt;
  @override
  int get fileSize;
  @override
  DownloadStatus get status;
  @override
  Map<String, String> get localPaths;

  /// Create a copy of DownloadedTourModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadedTourModelImplCopyWith<_$DownloadedTourModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
