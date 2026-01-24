import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'tour_model.dart';
import 'user_model.dart';

part 'stop_model.freezed.dart';
part 'stop_model.g.dart';

enum AudioSource {
  @JsonValue('recorded')
  recorded,
  @JsonValue('elevenlabs')
  elevenlabs,
  @JsonValue('uploaded')
  uploaded,
}

@freezed
class StopModel with _$StopModel {
  const StopModel._();

  const factory StopModel({
    required String id,
    required String tourId,
    required String versionId,
    required int order,
    required String name,
    @Default('') String description,

    // Location & Geofencing
    @GeoPointConverter() required GeoPoint location,
    required String geohash,
    @Default(30) int triggerRadius,

    // Media
    @Default(StopMedia()) StopMedia media,

    // Navigation hints (for driving tours)
    StopNavigation? navigation,

    // Timestamps
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _StopModel;

  factory StopModel.fromJson(Map<String, dynamic> json) =>
      _$StopModelFromJson(json);

  factory StopModel.fromFirestore(
    DocumentSnapshot doc, {
    required String tourId,
    required String versionId,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return StopModel.fromJson({
      'id': doc.id,
      'tourId': tourId,
      'versionId': versionId,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('tourId');
    json.remove('versionId');
    return json;
  }

  double get latitude => location.latitude;
  double get longitude => location.longitude;
  bool get hasAudio => media.audioUrl != null;
  bool get hasImages => media.images.isNotEmpty;
  bool get hasVideo => media.videoUrl != null;
}

@freezed
class StopMedia with _$StopMedia {
  const StopMedia._();

  const factory StopMedia({
    String? audioUrl,
    @Default(AudioSource.recorded) AudioSource audioSource,
    int? audioDuration,
    String? audioText,
    String? voiceId,
    @Default([]) List<StopImage> images,
    String? videoUrl,
  }) = _StopMedia;

  factory StopMedia.fromJson(Map<String, dynamic> json) =>
      _$StopMediaFromJson(json);

  bool get hasAudio => audioUrl != null;
  bool get hasImages => images.isNotEmpty;
  bool get hasVideo => videoUrl != null;
  bool get isElevenLabsAudio => audioSource == AudioSource.elevenlabs;
}

@freezed
class StopImage with _$StopImage {
  const factory StopImage({
    required String url,
    String? caption,
    @Default(0) int order,
  }) = _StopImage;

  factory StopImage.fromJson(Map<String, dynamic> json) =>
      _$StopImageFromJson(json);
}

@freezed
class StopNavigation with _$StopNavigation {
  const factory StopNavigation({
    String? arrivalInstruction,
    String? parkingInfo,
    String? direction,
  }) = _StopNavigation;

  factory StopNavigation.fromJson(Map<String, dynamic> json) =>
      _$StopNavigationFromJson(json);
}

extension AudioSourceExtension on AudioSource {
  String get displayName {
    switch (this) {
      case AudioSource.recorded:
        return 'Recorded';
      case AudioSource.elevenlabs:
        return 'AI Generated';
      case AudioSource.uploaded:
        return 'Uploaded';
    }
  }

  String get icon {
    switch (this) {
      case AudioSource.recorded:
        return 'mic';
      case AudioSource.elevenlabs:
        return 'smart_toy';
      case AudioSource.uploaded:
        return 'upload_file';
    }
  }
}
