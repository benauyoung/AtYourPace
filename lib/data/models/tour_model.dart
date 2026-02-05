import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'tour_model.freezed.dart';
part 'tour_model.g.dart';

enum TourType {
  @JsonValue('walking')
  walking,
  @JsonValue('driving')
  driving,
}

enum TourStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('pending_review')
  pendingReview,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('hidden')
  hidden,
}

enum TourCategory {
  @JsonValue('history')
  history,
  @JsonValue('nature')
  nature,
  @JsonValue('ghost')
  ghost,
  @JsonValue('food')
  food,
  @JsonValue('art')
  art,
  @JsonValue('architecture')
  architecture,
  @JsonValue('other')
  other,
}

@freezed
class TourModel with _$TourModel {
  const TourModel._();

  const factory TourModel({
    required String id,
    required String creatorId,
    required String creatorName,
    String? slug,
    required TourCategory category,
    required TourType tourType,
    @Default(TourStatus.draft) TourStatus status,
    @Default(false) bool featured,

    // Geospatial
    @GeoPointConverter() required GeoPoint startLocation,
    required String geohash,
    String? city,
    String? region,
    String? country,
    String? draftTitle,

    // Version references
    String? liveVersionId,
    int? liveVersion,
    required String draftVersionId,
    required int draftVersion,

    // Stats
    @Default(TourStats()) TourStats stats,

    // Timestamps
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    @NullableTimestampConverter() DateTime? publishedAt,
    @NullableTimestampConverter() DateTime? lastReviewedAt,
  }) = _TourModel;

  factory TourModel.fromJson(Map<String, dynamic> json) =>
      _$TourModelFromJson(json);

  factory TourModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  String get displayName => draftTitle ?? city ?? 'Untitled Tour';

  bool get isPublished => liveVersionId != null;
  bool get isPendingReview => status == TourStatus.pendingReview;
  bool get isApproved => status == TourStatus.approved;
  bool get isEditable => status == TourStatus.draft || status == TourStatus.rejected;
  bool get hasPendingChanges =>
      isPublished && draftVersionId != liveVersionId;
}

@freezed
class TourStats with _$TourStats {
  const factory TourStats({
    @Default(0) int totalPlays,
    @Default(0) int totalDownloads,
    @Default(0.0) double averageRating,
    @Default(0) int totalRatings,
    @Default(0) int totalRevenue,
  }) = _TourStats;

  factory TourStats.fromJson(Map<String, dynamic> json) =>
      _$TourStatsFromJson(json);
}

/// Converter for Firestore GeoPoint
class GeoPointConverter implements JsonConverter<GeoPoint, dynamic> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(dynamic value) {
    if (value is GeoPoint) {
      return value;
    } else if (value is Map<String, dynamic>) {
      return GeoPoint(
        (value['latitude'] ?? value['lat'] ?? 0).toDouble(),
        (value['longitude'] ?? value['lng'] ?? value['lon'] ?? 0).toDouble(),
      );
    }
    return const GeoPoint(0, 0);
  }

  @override
  dynamic toJson(GeoPoint geoPoint) => geoPoint;
}

/// Converter for nullable GeoPoint
class NullableGeoPointConverter implements JsonConverter<GeoPoint?, dynamic> {
  const NullableGeoPointConverter();

  @override
  GeoPoint? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is GeoPoint) return value;
    if (value is Map<String, dynamic>) {
      return GeoPoint(
        (value['latitude'] ?? value['lat'] ?? 0).toDouble(),
        (value['longitude'] ?? value['lng'] ?? value['lon'] ?? 0).toDouble(),
      );
    }
    return null;
  }

  @override
  dynamic toJson(GeoPoint? geoPoint) => geoPoint;
}

extension TourCategoryExtension on TourCategory {
  String get displayName {
    switch (this) {
      case TourCategory.history:
        return 'History';
      case TourCategory.nature:
        return 'Nature';
      case TourCategory.ghost:
        return 'Ghost Tour';
      case TourCategory.food:
        return 'Food & Drink';
      case TourCategory.art:
        return 'Art';
      case TourCategory.architecture:
        return 'Architecture';
      case TourCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TourCategory.history:
        return Icons.account_balance;
      case TourCategory.nature:
        return Icons.park;
      case TourCategory.ghost:
        return Icons.dark_mode;
      case TourCategory.food:
        return Icons.restaurant;
      case TourCategory.art:
        return Icons.palette;
      case TourCategory.architecture:
        return Icons.architecture;
      case TourCategory.other:
        return Icons.explore;
    }
  }
}

extension TourTypeExtension on TourType {
  String get displayName {
    switch (this) {
      case TourType.walking:
        return 'Walking';
      case TourType.driving:
        return 'Driving';
    }
  }

  IconData get icon {
    switch (this) {
      case TourType.walking:
        return Icons.directions_walk;
      case TourType.driving:
        return Icons.directions_car;
    }
  }
}

extension TourStatusExtension on TourStatus {
  String get displayName {
    switch (this) {
      case TourStatus.draft:
        return 'Draft';
      case TourStatus.pendingReview:
        return 'Pending Review';
      case TourStatus.approved:
        return 'Approved';
      case TourStatus.rejected:
        return 'Rejected';
      case TourStatus.hidden:
        return 'Hidden';
    }
  }
}
