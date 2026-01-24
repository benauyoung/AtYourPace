// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  CreatorProfile? get creatorProfile => throw _privateConstructorUsedError;
  UserPreferences get preferences => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String uid,
      String email,
      String displayName,
      String? photoUrl,
      UserRole role,
      CreatorProfile? creatorProfile,
      UserPreferences preferences,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});

  $CreatorProfileCopyWith<$Res>? get creatorProfile;
  $UserPreferencesCopyWith<$Res> get preferences;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? photoUrl = freezed,
    Object? role = null,
    Object? creatorProfile = freezed,
    Object? preferences = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      creatorProfile: freezed == creatorProfile
          ? _value.creatorProfile
          : creatorProfile // ignore: cast_nullable_to_non_nullable
              as CreatorProfile?,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences,
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

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CreatorProfileCopyWith<$Res>? get creatorProfile {
    if (_value.creatorProfile == null) {
      return null;
    }

    return $CreatorProfileCopyWith<$Res>(_value.creatorProfile!, (value) {
      return _then(_value.copyWith(creatorProfile: value) as $Val);
    });
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserPreferencesCopyWith<$Res> get preferences {
    return $UserPreferencesCopyWith<$Res>(_value.preferences, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String email,
      String displayName,
      String? photoUrl,
      UserRole role,
      CreatorProfile? creatorProfile,
      UserPreferences preferences,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt});

  @override
  $CreatorProfileCopyWith<$Res>? get creatorProfile;
  @override
  $UserPreferencesCopyWith<$Res> get preferences;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? photoUrl = freezed,
    Object? role = null,
    Object? creatorProfile = freezed,
    Object? preferences = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserModelImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      creatorProfile: freezed == creatorProfile
          ? _value.creatorProfile
          : creatorProfile // ignore: cast_nullable_to_non_nullable
              as CreatorProfile?,
      preferences: null == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as UserPreferences,
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
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl(
      {required this.uid,
      required this.email,
      required this.displayName,
      this.photoUrl,
      this.role = UserRole.user,
      this.creatorProfile,
      this.preferences = const UserPreferences(),
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt})
      : super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final UserRole role;
  @override
  final CreatorProfile? creatorProfile;
  @override
  @JsonKey()
  final UserPreferences preferences;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, role: $role, creatorProfile: $creatorProfile, preferences: $preferences, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.creatorProfile, creatorProfile) ||
                other.creatorProfile == creatorProfile) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, email, displayName,
      photoUrl, role, creatorProfile, preferences, createdAt, updatedAt);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
          {required final String uid,
          required final String email,
          required final String displayName,
          final String? photoUrl,
          final UserRole role,
          final CreatorProfile? creatorProfile,
          final UserPreferences preferences,
          @TimestampConverter() required final DateTime createdAt,
          @TimestampConverter() required final DateTime updatedAt}) =
      _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String get displayName;
  @override
  String? get photoUrl;
  @override
  UserRole get role;
  @override
  CreatorProfile? get creatorProfile;
  @override
  UserPreferences get preferences;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreatorProfile _$CreatorProfileFromJson(Map<String, dynamic> json) {
  return _CreatorProfile.fromJson(json);
}

/// @nodoc
mixin _$CreatorProfile {
  String get bio => throw _privateConstructorUsedError;
  bool get verified => throw _privateConstructorUsedError;
  int get totalTours => throw _privateConstructorUsedError;
  int get totalDownloads => throw _privateConstructorUsedError;

  /// Serializes this CreatorProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreatorProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreatorProfileCopyWith<CreatorProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreatorProfileCopyWith<$Res> {
  factory $CreatorProfileCopyWith(
          CreatorProfile value, $Res Function(CreatorProfile) then) =
      _$CreatorProfileCopyWithImpl<$Res, CreatorProfile>;
  @useResult
  $Res call({String bio, bool verified, int totalTours, int totalDownloads});
}

/// @nodoc
class _$CreatorProfileCopyWithImpl<$Res, $Val extends CreatorProfile>
    implements $CreatorProfileCopyWith<$Res> {
  _$CreatorProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreatorProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bio = null,
    Object? verified = null,
    Object? totalTours = null,
    Object? totalDownloads = null,
  }) {
    return _then(_value.copyWith(
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      totalTours: null == totalTours
          ? _value.totalTours
          : totalTours // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownloads: null == totalDownloads
          ? _value.totalDownloads
          : totalDownloads // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreatorProfileImplCopyWith<$Res>
    implements $CreatorProfileCopyWith<$Res> {
  factory _$$CreatorProfileImplCopyWith(_$CreatorProfileImpl value,
          $Res Function(_$CreatorProfileImpl) then) =
      __$$CreatorProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String bio, bool verified, int totalTours, int totalDownloads});
}

/// @nodoc
class __$$CreatorProfileImplCopyWithImpl<$Res>
    extends _$CreatorProfileCopyWithImpl<$Res, _$CreatorProfileImpl>
    implements _$$CreatorProfileImplCopyWith<$Res> {
  __$$CreatorProfileImplCopyWithImpl(
      _$CreatorProfileImpl _value, $Res Function(_$CreatorProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreatorProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bio = null,
    Object? verified = null,
    Object? totalTours = null,
    Object? totalDownloads = null,
  }) {
    return _then(_$CreatorProfileImpl(
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      verified: null == verified
          ? _value.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      totalTours: null == totalTours
          ? _value.totalTours
          : totalTours // ignore: cast_nullable_to_non_nullable
              as int,
      totalDownloads: null == totalDownloads
          ? _value.totalDownloads
          : totalDownloads // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreatorProfileImpl implements _CreatorProfile {
  const _$CreatorProfileImpl(
      {this.bio = '',
      this.verified = false,
      this.totalTours = 0,
      this.totalDownloads = 0});

  factory _$CreatorProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreatorProfileImplFromJson(json);

  @override
  @JsonKey()
  final String bio;
  @override
  @JsonKey()
  final bool verified;
  @override
  @JsonKey()
  final int totalTours;
  @override
  @JsonKey()
  final int totalDownloads;

  @override
  String toString() {
    return 'CreatorProfile(bio: $bio, verified: $verified, totalTours: $totalTours, totalDownloads: $totalDownloads)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreatorProfileImpl &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.totalTours, totalTours) ||
                other.totalTours == totalTours) &&
            (identical(other.totalDownloads, totalDownloads) ||
                other.totalDownloads == totalDownloads));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, bio, verified, totalTours, totalDownloads);

  /// Create a copy of CreatorProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreatorProfileImplCopyWith<_$CreatorProfileImpl> get copyWith =>
      __$$CreatorProfileImplCopyWithImpl<_$CreatorProfileImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreatorProfileImplToJson(
      this,
    );
  }
}

abstract class _CreatorProfile implements CreatorProfile {
  const factory _CreatorProfile(
      {final String bio,
      final bool verified,
      final int totalTours,
      final int totalDownloads}) = _$CreatorProfileImpl;

  factory _CreatorProfile.fromJson(Map<String, dynamic> json) =
      _$CreatorProfileImpl.fromJson;

  @override
  String get bio;
  @override
  bool get verified;
  @override
  int get totalTours;
  @override
  int get totalDownloads;

  /// Create a copy of CreatorProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreatorProfileImplCopyWith<_$CreatorProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) {
  return _UserPreferences.fromJson(json);
}

/// @nodoc
mixin _$UserPreferences {
  bool get autoPlayAudio => throw _privateConstructorUsedError;
  TriggerMode get triggerMode => throw _privateConstructorUsedError;
  bool get offlineEnabled => throw _privateConstructorUsedError;
  String? get preferredVoice => throw _privateConstructorUsedError;

  /// Serializes this UserPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserPreferencesCopyWith<UserPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesCopyWith<$Res> {
  factory $UserPreferencesCopyWith(
          UserPreferences value, $Res Function(UserPreferences) then) =
      _$UserPreferencesCopyWithImpl<$Res, UserPreferences>;
  @useResult
  $Res call(
      {bool autoPlayAudio,
      TriggerMode triggerMode,
      bool offlineEnabled,
      String? preferredVoice});
}

/// @nodoc
class _$UserPreferencesCopyWithImpl<$Res, $Val extends UserPreferences>
    implements $UserPreferencesCopyWith<$Res> {
  _$UserPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoPlayAudio = null,
    Object? triggerMode = null,
    Object? offlineEnabled = null,
    Object? preferredVoice = freezed,
  }) {
    return _then(_value.copyWith(
      autoPlayAudio: null == autoPlayAudio
          ? _value.autoPlayAudio
          : autoPlayAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      triggerMode: null == triggerMode
          ? _value.triggerMode
          : triggerMode // ignore: cast_nullable_to_non_nullable
              as TriggerMode,
      offlineEnabled: null == offlineEnabled
          ? _value.offlineEnabled
          : offlineEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredVoice: freezed == preferredVoice
          ? _value.preferredVoice
          : preferredVoice // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPreferencesImplCopyWith<$Res>
    implements $UserPreferencesCopyWith<$Res> {
  factory _$$UserPreferencesImplCopyWith(_$UserPreferencesImpl value,
          $Res Function(_$UserPreferencesImpl) then) =
      __$$UserPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool autoPlayAudio,
      TriggerMode triggerMode,
      bool offlineEnabled,
      String? preferredVoice});
}

/// @nodoc
class __$$UserPreferencesImplCopyWithImpl<$Res>
    extends _$UserPreferencesCopyWithImpl<$Res, _$UserPreferencesImpl>
    implements _$$UserPreferencesImplCopyWith<$Res> {
  __$$UserPreferencesImplCopyWithImpl(
      _$UserPreferencesImpl _value, $Res Function(_$UserPreferencesImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? autoPlayAudio = null,
    Object? triggerMode = null,
    Object? offlineEnabled = null,
    Object? preferredVoice = freezed,
  }) {
    return _then(_$UserPreferencesImpl(
      autoPlayAudio: null == autoPlayAudio
          ? _value.autoPlayAudio
          : autoPlayAudio // ignore: cast_nullable_to_non_nullable
              as bool,
      triggerMode: null == triggerMode
          ? _value.triggerMode
          : triggerMode // ignore: cast_nullable_to_non_nullable
              as TriggerMode,
      offlineEnabled: null == offlineEnabled
          ? _value.offlineEnabled
          : offlineEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredVoice: freezed == preferredVoice
          ? _value.preferredVoice
          : preferredVoice // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPreferencesImpl implements _UserPreferences {
  const _$UserPreferencesImpl(
      {this.autoPlayAudio = true,
      this.triggerMode = TriggerMode.geofence,
      this.offlineEnabled = true,
      this.preferredVoice});

  factory _$UserPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final bool autoPlayAudio;
  @override
  @JsonKey()
  final TriggerMode triggerMode;
  @override
  @JsonKey()
  final bool offlineEnabled;
  @override
  final String? preferredVoice;

  @override
  String toString() {
    return 'UserPreferences(autoPlayAudio: $autoPlayAudio, triggerMode: $triggerMode, offlineEnabled: $offlineEnabled, preferredVoice: $preferredVoice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesImpl &&
            (identical(other.autoPlayAudio, autoPlayAudio) ||
                other.autoPlayAudio == autoPlayAudio) &&
            (identical(other.triggerMode, triggerMode) ||
                other.triggerMode == triggerMode) &&
            (identical(other.offlineEnabled, offlineEnabled) ||
                other.offlineEnabled == offlineEnabled) &&
            (identical(other.preferredVoice, preferredVoice) ||
                other.preferredVoice == preferredVoice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, autoPlayAudio, triggerMode, offlineEnabled, preferredVoice);

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      __$$UserPreferencesImplCopyWithImpl<_$UserPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesImplToJson(
      this,
    );
  }
}

abstract class _UserPreferences implements UserPreferences {
  const factory _UserPreferences(
      {final bool autoPlayAudio,
      final TriggerMode triggerMode,
      final bool offlineEnabled,
      final String? preferredVoice}) = _$UserPreferencesImpl;

  factory _UserPreferences.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesImpl.fromJson;

  @override
  bool get autoPlayAudio;
  @override
  TriggerMode get triggerMode;
  @override
  bool get offlineEnabled;
  @override
  String? get preferredVoice;

  /// Create a copy of UserPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserPreferencesImplCopyWith<_$UserPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
