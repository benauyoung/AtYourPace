import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'tour_model.dart';
import 'user_model.dart';

part 'tour_version_model.freezed.dart';
part 'tour_version_model.g.dart';

enum VersionType {
  @JsonValue('draft')
  draft,
  @JsonValue('live')
  live,
  @JsonValue('archived')
  archived,
}

enum TourDifficulty {
  @JsonValue('easy')
  easy,
  @JsonValue('moderate')
  moderate,
  @JsonValue('challenging')
  challenging,
}

@freezed
class TourVersionModel with _$TourVersionModel {
  const TourVersionModel._();

  const factory TourVersionModel({
    required String id,
    required String tourId,
    required int versionNumber,
    @Default(VersionType.draft) VersionType versionType,

    // Tour Content
    required String title,
    required String description,
    String? coverImageUrl,
    String? duration,
    String? distance,
    @Default(TourDifficulty.moderate) TourDifficulty difficulty,
    @Default([]) List<String> languages,

    // Route Data
    TourRoute? route,

    // Review workflow
    @NullableTimestampConverter() DateTime? submittedAt,
    @NullableTimestampConverter() DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,

    // Timestamps
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _TourVersionModel;

  factory TourVersionModel.fromJson(Map<String, dynamic> json) =>
      _$TourVersionModelFromJson(json);

  factory TourVersionModel.fromFirestore(
    DocumentSnapshot doc, {
    required String tourId,
  }) {
    final data = doc.data() as Map<String, dynamic>;
    return TourVersionModel.fromJson({
      'id': doc.id,
      'tourId': tourId,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    json.remove('tourId');
    return json;
  }

  bool get isDraft => versionType == VersionType.draft;
  bool get isLive => versionType == VersionType.live;
  bool get isArchived => versionType == VersionType.archived;
}

@freezed
class TourRoute with _$TourRoute {
  const factory TourRoute({
    String? encodedPolyline,
    BoundingBox? boundingBox,
    @Default([]) List<RouteWaypoint> waypoints,
  }) = _TourRoute;

  factory TourRoute.fromJson(Map<String, dynamic> json) =>
      _$TourRouteFromJson(json);
}

@freezed
class BoundingBox with _$BoundingBox {
  const factory BoundingBox({
    @GeoPointConverter() required GeoPoint northeast,
    @GeoPointConverter() required GeoPoint southwest,
  }) = _BoundingBox;

  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);
}

@freezed
class RouteWaypoint with _$RouteWaypoint {
  const factory RouteWaypoint({
    required double lat,
    required double lng,
  }) = _RouteWaypoint;

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) =>
      _$RouteWaypointFromJson(json);
}

extension TourDifficultyExtension on TourDifficulty {
  String get displayName {
    switch (this) {
      case TourDifficulty.easy:
        return 'Easy';
      case TourDifficulty.moderate:
        return 'Moderate';
      case TourDifficulty.challenging:
        return 'Challenging';
    }
  }

  String get description {
    switch (this) {
      case TourDifficulty.easy:
        return 'Flat terrain, accessible paths';
      case TourDifficulty.moderate:
        return 'Some inclines, mostly paved';
      case TourDifficulty.challenging:
        return 'Steep terrain, uneven surfaces';
    }
  }
}

extension VersionTypeExtension on VersionType {
  String get displayName {
    switch (this) {
      case VersionType.draft:
        return 'Draft';
      case VersionType.live:
        return 'Live';
      case VersionType.archived:
        return 'Archived';
    }
  }
}
