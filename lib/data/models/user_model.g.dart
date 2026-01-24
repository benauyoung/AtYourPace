// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      role:
          $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.user,
      creatorProfile: json['creatorProfile'] == null
          ? null
          : CreatorProfile.fromJson(
              json['creatorProfile'] as Map<String, dynamic>),
      preferences: json['preferences'] == null
          ? const UserPreferences()
          : UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'role': _$UserRoleEnumMap[instance.role]!,
      'creatorProfile': instance.creatorProfile,
      'preferences': instance.preferences,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$UserRoleEnumMap = {
  UserRole.user: 'user',
  UserRole.creator: 'creator',
  UserRole.admin: 'admin',
};

_$CreatorProfileImpl _$$CreatorProfileImplFromJson(Map<String, dynamic> json) =>
    _$CreatorProfileImpl(
      bio: json['bio'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      totalTours: (json['totalTours'] as num?)?.toInt() ?? 0,
      totalDownloads: (json['totalDownloads'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CreatorProfileImplToJson(
        _$CreatorProfileImpl instance) =>
    <String, dynamic>{
      'bio': instance.bio,
      'verified': instance.verified,
      'totalTours': instance.totalTours,
      'totalDownloads': instance.totalDownloads,
    };

_$UserPreferencesImpl _$$UserPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$UserPreferencesImpl(
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? true,
      triggerMode:
          $enumDecodeNullable(_$TriggerModeEnumMap, json['triggerMode']) ??
              TriggerMode.geofence,
      offlineEnabled: json['offlineEnabled'] as bool? ?? true,
      preferredVoice: json['preferredVoice'] as String?,
    );

Map<String, dynamic> _$$UserPreferencesImplToJson(
        _$UserPreferencesImpl instance) =>
    <String, dynamic>{
      'autoPlayAudio': instance.autoPlayAudio,
      'triggerMode': _$TriggerModeEnumMap[instance.triggerMode]!,
      'offlineEnabled': instance.offlineEnabled,
      'preferredVoice': instance.preferredVoice,
    };

const _$TriggerModeEnumMap = {
  TriggerMode.geofence: 'geofence',
  TriggerMode.manual: 'manual',
};
