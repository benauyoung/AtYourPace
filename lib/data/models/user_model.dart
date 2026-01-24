import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

enum UserRole {
  @JsonValue('user')
  user,
  @JsonValue('creator')
  creator,
  @JsonValue('admin')
  admin,
}

enum TriggerMode {
  @JsonValue('geofence')
  geofence,
  @JsonValue('manual')
  manual,
}

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    @Default(UserRole.user) UserRole role,
    CreatorProfile? creatorProfile,
    @Default(UserPreferences()) UserPreferences preferences,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'uid': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('uid'); // Don't store uid as a field, it's the doc ID
    return json;
  }

  bool get isCreator => role == UserRole.creator || role == UserRole.admin;
  bool get isAdmin => role == UserRole.admin;
}

@freezed
class CreatorProfile with _$CreatorProfile {
  const factory CreatorProfile({
    @Default('') String bio,
    @Default(false) bool verified,
    @Default(0) int totalTours,
    @Default(0) int totalDownloads,
  }) = _CreatorProfile;

  factory CreatorProfile.fromJson(Map<String, dynamic> json) =>
      _$CreatorProfileFromJson(json);
}

@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @Default(true) bool autoPlayAudio,
    @Default(TriggerMode.geofence) TriggerMode triggerMode,
    @Default(true) bool offlineEnabled,
    String? preferredVoice,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

/// Converter for Firestore Timestamp to DateTime
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Converter for nullable Timestamp
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}
