// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_generation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VoiceGenerationModel _$VoiceGenerationModelFromJson(Map<String, dynamic> json) {
  return _VoiceGenerationModel.fromJson(json);
}

/// @nodoc
mixin _$VoiceGenerationModel {
  String get id => throw _privateConstructorUsedError;
  String get stopId => throw _privateConstructorUsedError;
  String get tourId => throw _privateConstructorUsedError;
  String get script => throw _privateConstructorUsedError;
  String get voiceId => throw _privateConstructorUsedError;
  String get voiceName => throw _privateConstructorUsedError;
  String? get audioUrl => throw _privateConstructorUsedError;
  int? get audioDuration => throw _privateConstructorUsedError;
  VoiceGenerationStatus get status => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  int get regenerationCount => throw _privateConstructorUsedError;
  List<VoiceGenerationHistory> get history =>
      throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VoiceGenerationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceGenerationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceGenerationModelCopyWith<VoiceGenerationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceGenerationModelCopyWith<$Res> {
  factory $VoiceGenerationModelCopyWith(VoiceGenerationModel value,
          $Res Function(VoiceGenerationModel) then) =
      _$VoiceGenerationModelCopyWithImpl<$Res, VoiceGenerationModel>;
  @useResult
  $Res call(
      {String id,
      String stopId,
      String tourId,
      String script,
      String voiceId,
      String voiceName,
      String? audioUrl,
      int? audioDuration,
      VoiceGenerationStatus status,
      String? errorMessage,
      int regenerationCount,
      List<VoiceGenerationHistory> history,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class _$VoiceGenerationModelCopyWithImpl<$Res,
        $Val extends VoiceGenerationModel>
    implements $VoiceGenerationModelCopyWith<$Res> {
  _$VoiceGenerationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceGenerationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stopId = null,
    Object? tourId = null,
    Object? script = null,
    Object? voiceId = null,
    Object? voiceName = null,
    Object? audioUrl = freezed,
    Object? audioDuration = freezed,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? regenerationCount = null,
    Object? history = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      stopId: null == stopId
          ? _value.stopId
          : stopId // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      script: null == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String,
      voiceId: null == voiceId
          ? _value.voiceId
          : voiceId // ignore: cast_nullable_to_non_nullable
              as String,
      voiceName: null == voiceName
          ? _value.voiceName
          : voiceName // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      audioDuration: freezed == audioDuration
          ? _value.audioDuration
          : audioDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VoiceGenerationStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      regenerationCount: null == regenerationCount
          ? _value.regenerationCount
          : regenerationCount // ignore: cast_nullable_to_non_nullable
              as int,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<VoiceGenerationHistory>,
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
abstract class _$$VoiceGenerationModelImplCopyWith<$Res>
    implements $VoiceGenerationModelCopyWith<$Res> {
  factory _$$VoiceGenerationModelImplCopyWith(_$VoiceGenerationModelImpl value,
          $Res Function(_$VoiceGenerationModelImpl) then) =
      __$$VoiceGenerationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String stopId,
      String tourId,
      String script,
      String voiceId,
      String voiceName,
      String? audioUrl,
      int? audioDuration,
      VoiceGenerationStatus status,
      String? errorMessage,
      int regenerationCount,
      List<VoiceGenerationHistory> history,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});
}

/// @nodoc
class __$$VoiceGenerationModelImplCopyWithImpl<$Res>
    extends _$VoiceGenerationModelCopyWithImpl<$Res, _$VoiceGenerationModelImpl>
    implements _$$VoiceGenerationModelImplCopyWith<$Res> {
  __$$VoiceGenerationModelImplCopyWithImpl(_$VoiceGenerationModelImpl _value,
      $Res Function(_$VoiceGenerationModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoiceGenerationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stopId = null,
    Object? tourId = null,
    Object? script = null,
    Object? voiceId = null,
    Object? voiceName = null,
    Object? audioUrl = freezed,
    Object? audioDuration = freezed,
    Object? status = null,
    Object? errorMessage = freezed,
    Object? regenerationCount = null,
    Object? history = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$VoiceGenerationModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      stopId: null == stopId
          ? _value.stopId
          : stopId // ignore: cast_nullable_to_non_nullable
              as String,
      tourId: null == tourId
          ? _value.tourId
          : tourId // ignore: cast_nullable_to_non_nullable
              as String,
      script: null == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String,
      voiceId: null == voiceId
          ? _value.voiceId
          : voiceId // ignore: cast_nullable_to_non_nullable
              as String,
      voiceName: null == voiceName
          ? _value.voiceName
          : voiceName // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      audioDuration: freezed == audioDuration
          ? _value.audioDuration
          : audioDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as VoiceGenerationStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      regenerationCount: null == regenerationCount
          ? _value.regenerationCount
          : regenerationCount // ignore: cast_nullable_to_non_nullable
              as int,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<VoiceGenerationHistory>,
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
class _$VoiceGenerationModelImpl extends _VoiceGenerationModel {
  const _$VoiceGenerationModelImpl(
      {required this.id,
      required this.stopId,
      required this.tourId,
      required this.script,
      required this.voiceId,
      required this.voiceName,
      this.audioUrl,
      this.audioDuration,
      this.status = VoiceGenerationStatus.pending,
      this.errorMessage,
      this.regenerationCount = 0,
      final List<VoiceGenerationHistory> history = const [],
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : _history = history,
        super._();

  factory _$VoiceGenerationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceGenerationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String stopId;
  @override
  final String tourId;
  @override
  final String script;
  @override
  final String voiceId;
  @override
  final String voiceName;
  @override
  final String? audioUrl;
  @override
  final int? audioDuration;
  @override
  @JsonKey()
  final VoiceGenerationStatus status;
  @override
  final String? errorMessage;
  @override
  @JsonKey()
  final int regenerationCount;
  final List<VoiceGenerationHistory> _history;
  @override
  @JsonKey()
  List<VoiceGenerationHistory> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'VoiceGenerationModel(id: $id, stopId: $stopId, tourId: $tourId, script: $script, voiceId: $voiceId, voiceName: $voiceName, audioUrl: $audioUrl, audioDuration: $audioDuration, status: $status, errorMessage: $errorMessage, regenerationCount: $regenerationCount, history: $history, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceGenerationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stopId, stopId) || other.stopId == stopId) &&
            (identical(other.tourId, tourId) || other.tourId == tourId) &&
            (identical(other.script, script) || other.script == script) &&
            (identical(other.voiceId, voiceId) || other.voiceId == voiceId) &&
            (identical(other.voiceName, voiceName) ||
                other.voiceName == voiceName) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.audioDuration, audioDuration) ||
                other.audioDuration == audioDuration) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.regenerationCount, regenerationCount) ||
                other.regenerationCount == regenerationCount) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
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
      stopId,
      tourId,
      script,
      voiceId,
      voiceName,
      audioUrl,
      audioDuration,
      status,
      errorMessage,
      regenerationCount,
      const DeepCollectionEquality().hash(_history),
      createdAt,
      updatedAt);

  /// Create a copy of VoiceGenerationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceGenerationModelImplCopyWith<_$VoiceGenerationModelImpl>
      get copyWith =>
          __$$VoiceGenerationModelImplCopyWithImpl<_$VoiceGenerationModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceGenerationModelImplToJson(
      this,
    );
  }
}

abstract class _VoiceGenerationModel extends VoiceGenerationModel {
  const factory _VoiceGenerationModel(
          {required final String id,
          required final String stopId,
          required final String tourId,
          required final String script,
          required final String voiceId,
          required final String voiceName,
          final String? audioUrl,
          final int? audioDuration,
          final VoiceGenerationStatus status,
          final String? errorMessage,
          final int regenerationCount,
          final List<VoiceGenerationHistory> history,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$VoiceGenerationModelImpl;
  const _VoiceGenerationModel._() : super._();

  factory _VoiceGenerationModel.fromJson(Map<String, dynamic> json) =
      _$VoiceGenerationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get stopId;
  @override
  String get tourId;
  @override
  String get script;
  @override
  String get voiceId;
  @override
  String get voiceName;
  @override
  String? get audioUrl;
  @override
  int? get audioDuration;
  @override
  VoiceGenerationStatus get status;
  @override
  String? get errorMessage;
  @override
  int get regenerationCount;
  @override
  List<VoiceGenerationHistory> get history;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of VoiceGenerationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceGenerationModelImplCopyWith<_$VoiceGenerationModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

VoiceGenerationHistory _$VoiceGenerationHistoryFromJson(
    Map<String, dynamic> json) {
  return _VoiceGenerationHistory.fromJson(json);
}

/// @nodoc
mixin _$VoiceGenerationHistory {
  String get script => throw _privateConstructorUsedError;
  String get voiceId => throw _privateConstructorUsedError;
  String get audioUrl => throw _privateConstructorUsedError;
  int get audioDuration => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this VoiceGenerationHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VoiceGenerationHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VoiceGenerationHistoryCopyWith<VoiceGenerationHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VoiceGenerationHistoryCopyWith<$Res> {
  factory $VoiceGenerationHistoryCopyWith(VoiceGenerationHistory value,
          $Res Function(VoiceGenerationHistory) then) =
      _$VoiceGenerationHistoryCopyWithImpl<$Res, VoiceGenerationHistory>;
  @useResult
  $Res call(
      {String script,
      String voiceId,
      String audioUrl,
      int audioDuration,
      @TimestampConverter() DateTime generatedAt});
}

/// @nodoc
class _$VoiceGenerationHistoryCopyWithImpl<$Res,
        $Val extends VoiceGenerationHistory>
    implements $VoiceGenerationHistoryCopyWith<$Res> {
  _$VoiceGenerationHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VoiceGenerationHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? script = null,
    Object? voiceId = null,
    Object? audioUrl = null,
    Object? audioDuration = null,
    Object? generatedAt = null,
  }) {
    return _then(_value.copyWith(
      script: null == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String,
      voiceId: null == voiceId
          ? _value.voiceId
          : voiceId // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      audioDuration: null == audioDuration
          ? _value.audioDuration
          : audioDuration // ignore: cast_nullable_to_non_nullable
              as int,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VoiceGenerationHistoryImplCopyWith<$Res>
    implements $VoiceGenerationHistoryCopyWith<$Res> {
  factory _$$VoiceGenerationHistoryImplCopyWith(
          _$VoiceGenerationHistoryImpl value,
          $Res Function(_$VoiceGenerationHistoryImpl) then) =
      __$$VoiceGenerationHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String script,
      String voiceId,
      String audioUrl,
      int audioDuration,
      @TimestampConverter() DateTime generatedAt});
}

/// @nodoc
class __$$VoiceGenerationHistoryImplCopyWithImpl<$Res>
    extends _$VoiceGenerationHistoryCopyWithImpl<$Res,
        _$VoiceGenerationHistoryImpl>
    implements _$$VoiceGenerationHistoryImplCopyWith<$Res> {
  __$$VoiceGenerationHistoryImplCopyWithImpl(
      _$VoiceGenerationHistoryImpl _value,
      $Res Function(_$VoiceGenerationHistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of VoiceGenerationHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? script = null,
    Object? voiceId = null,
    Object? audioUrl = null,
    Object? audioDuration = null,
    Object? generatedAt = null,
  }) {
    return _then(_$VoiceGenerationHistoryImpl(
      script: null == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String,
      voiceId: null == voiceId
          ? _value.voiceId
          : voiceId // ignore: cast_nullable_to_non_nullable
              as String,
      audioUrl: null == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String,
      audioDuration: null == audioDuration
          ? _value.audioDuration
          : audioDuration // ignore: cast_nullable_to_non_nullable
              as int,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VoiceGenerationHistoryImpl extends _VoiceGenerationHistory {
  const _$VoiceGenerationHistoryImpl(
      {required this.script,
      required this.voiceId,
      required this.audioUrl,
      required this.audioDuration,
      @TimestampConverter() required this.generatedAt})
      : super._();

  factory _$VoiceGenerationHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$VoiceGenerationHistoryImplFromJson(json);

  @override
  final String script;
  @override
  final String voiceId;
  @override
  final String audioUrl;
  @override
  final int audioDuration;
  @override
  @TimestampConverter()
  final DateTime generatedAt;

  @override
  String toString() {
    return 'VoiceGenerationHistory(script: $script, voiceId: $voiceId, audioUrl: $audioUrl, audioDuration: $audioDuration, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VoiceGenerationHistoryImpl &&
            (identical(other.script, script) || other.script == script) &&
            (identical(other.voiceId, voiceId) || other.voiceId == voiceId) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.audioDuration, audioDuration) ||
                other.audioDuration == audioDuration) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, script, voiceId, audioUrl, audioDuration, generatedAt);

  /// Create a copy of VoiceGenerationHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VoiceGenerationHistoryImplCopyWith<_$VoiceGenerationHistoryImpl>
      get copyWith => __$$VoiceGenerationHistoryImplCopyWithImpl<
          _$VoiceGenerationHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VoiceGenerationHistoryImplToJson(
      this,
    );
  }
}

abstract class _VoiceGenerationHistory extends VoiceGenerationHistory {
  const factory _VoiceGenerationHistory(
          {required final String script,
          required final String voiceId,
          required final String audioUrl,
          required final int audioDuration,
          @TimestampConverter() required final DateTime generatedAt}) =
      _$VoiceGenerationHistoryImpl;
  const _VoiceGenerationHistory._() : super._();

  factory _VoiceGenerationHistory.fromJson(Map<String, dynamic> json) =
      _$VoiceGenerationHistoryImpl.fromJson;

  @override
  String get script;
  @override
  String get voiceId;
  @override
  String get audioUrl;
  @override
  int get audioDuration;
  @override
  @TimestampConverter()
  DateTime get generatedAt;

  /// Create a copy of VoiceGenerationHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VoiceGenerationHistoryImplCopyWith<_$VoiceGenerationHistoryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
