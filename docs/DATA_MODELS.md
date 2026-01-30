# Data Models Documentation

**Last Updated**: January 30, 2026  
**Purpose**: Complete specification for all new data models in the Tour Manager rebuild

---

## Table of Contents

1. [Overview](#overview)
2. [PricingModel](#pricingmodel)
3. [RouteModel](#routemodel)
4. [WaypointModel](#waypointmodel)
5. [PublishingSubmissionModel](#publishingsubmissionmodel)
6. [ReviewFeedbackModel](#reviewfeedbackmodel)
7. [VoiceGenerationModel](#voicegenerationmodel)
8. [CollectionModel](#collectionmodel)
9. [TourAnalyticsModel](#touranalyticsmodel)
10. [Firestore Schema](#firestore-schema)
11. [Relationships](#relationships)

---

## Overview

All models use **Freezed** for immutability and **json_serializable** for JSON conversion. They follow these conventions:

- Immutable data classes with `@freezed` annotation
- JSON serialization with custom converters for Firebase types
- Firestore integration with `fromFirestore()` and `toFirestore()` methods
- Enums with `@JsonValue` for consistent serialization
- Timestamp converters for DateTime fields
- GeoPoint converters for location fields

### Code Generation Command
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## PricingModel

**Purpose**: Manages tour pricing information with support for free, paid, and future subscription models.

**File**: `lib/data/models/pricing_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pricing_model.freezed.dart';
part 'pricing_model.g.dart';

enum PricingType {
  @JsonValue('free')
  free,
  @JsonValue('paid')
  paid,
  @JsonValue('subscription')
  subscription,
  @JsonValue('pay_what_you_want')
  payWhatYouWant,
}

@freezed
class PricingModel with _$PricingModel {
  const PricingModel._();

  const factory PricingModel({
    required String id,
    required String tourId,
    @Default(PricingType.free) PricingType type,
    double? price,
    @Default('EUR') String currency,
    @Default(false) bool allowPayWhatYouWant,
    double? suggestedPrice,
    double? minimumPrice,
    @Default([]) List<PricingTier> tiers,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _PricingModel;

  factory PricingModel.fromJson(Map<String, dynamic> json) =>
      _$PricingModelFromJson(json);

  factory PricingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PricingModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  bool get isFree => type == PricingType.free;
  bool get isPaid => type == PricingType.paid;
  String get displayPrice => isFree ? 'Free' : '$currency $price';
}

@freezed
class PricingTier with _$PricingTier {
  const factory PricingTier({
    required String id,
    required String name,
    required double price,
    required String description,
    @Default([]) List<String> features,
    @Default(0) int sortOrder,
  }) = _PricingTier;

  factory PricingTier.fromJson(Map<String, dynamic> json) =>
      _$PricingTierFromJson(json);
}
```

**Firestore Path**: `tours/{tourId}/pricing/{pricingId}`

**Example JSON**:
```json
{
  "id": "pricing_123",
  "tourId": "tour_456",
  "type": "free",
  "price": null,
  "currency": "EUR",
  "allowPayWhatYouWant": false,
  "suggestedPrice": null,
  "minimumPrice": null,
  "tiers": [],
  "createdAt": "2026-01-30T09:00:00Z",
  "updatedAt": "2026-01-30T09:00:00Z"
}
```

---

## RouteModel

**Purpose**: Represents the complete route for a tour with waypoints and polyline data.

**File**: `lib/data/models/route_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';
import 'waypoint_model.dart';

part 'route_model.freezed.dart';
part 'route_model.g.dart';

enum RouteSnapMode {
  @JsonValue('none')
  none,
  @JsonValue('roads')
  roads,
  @JsonValue('walking')
  walking,
  @JsonValue('manual')
  manual,
}

@freezed
class RouteModel with _$RouteModel {
  const RouteModel._();

  const factory RouteModel({
    required String id,
    required String tourId,
    required String versionId,
    required List<WaypointModel> waypoints,
    @LatLngListConverter() @Default([]) List<LatLng> routePolyline,
    @Default(RouteSnapMode.roads) RouteSnapMode snapMode,
    required double totalDistance,
    required int estimatedDuration,
    @Default({}) Map<String, dynamic> metadata,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _RouteModel;

  factory RouteModel.fromJson(Map<String, dynamic> json) =>
      _$RouteModelFromJson(json);

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RouteModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  String get distanceFormatted {
    if (totalDistance < 1000) {
      return '${totalDistance.toStringAsFixed(0)}m';
    }
    return '${(totalDistance / 1000).toStringAsFixed(1)}km';
  }

  String get durationFormatted {
    final hours = estimatedDuration ~/ 3600;
    final minutes = (estimatedDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}

class LatLngListConverter implements JsonConverter<List<LatLng>, List<dynamic>> {
  const LatLngListConverter();

  @override
  List<LatLng> fromJson(List<dynamic> json) {
    return json
        .map((e) => LatLng(
              (e['lat'] as num).toDouble(),
              (e['lng'] as num).toDouble(),
            ))
        .toList();
  }

  @override
  List<dynamic> toJson(List<LatLng> object) {
    return object
        .map((e) => {
              'lat': e.latitude,
              'lng': e.longitude,
            })
        .toList();
  }
}
```

**Firestore Path**: `tour_versions/{versionId}/routes/{routeId}`

**Example JSON**:
```json
{
  "id": "route_123",
  "tourId": "tour_456",
  "versionId": "version_789",
  "waypoints": [...],
  "routePolyline": [
    {"lat": 48.8566, "lng": 2.3522},
    {"lat": 48.8584, "lng": 2.2945}
  ],
  "snapMode": "roads",
  "totalDistance": 5200.5,
  "estimatedDuration": 7200,
  "metadata": {},
  "createdAt": "2026-01-30T09:00:00Z",
  "updatedAt": "2026-01-30T09:00:00Z"
}
```

---

## WaypointModel

**Purpose**: Represents individual waypoints in a route with trigger radius and positioning.

**File**: `lib/data/models/waypoint_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'waypoint_model.freezed.dart';
part 'waypoint_model.g.dart';

enum WaypointType {
  @JsonValue('stop')
  stop,
  @JsonValue('waypoint')
  waypoint,
  @JsonValue('poi')
  poi,
}

@freezed
class WaypointModel with _$WaypointModel {
  const WaypointModel._();

  const factory WaypointModel({
    required String id,
    required String routeId,
    required int order,
    @LatLngConverter() required LatLng location,
    required String name,
    @Default(30) int triggerRadius,
    @Default(WaypointType.stop) WaypointType type,
    String? stopId,
    @Default(false) bool manualPosition,
    @Default({}) Map<String, dynamic> metadata,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _WaypointModel;

  factory WaypointModel.fromJson(Map<String, dynamic> json) =>
      _$WaypointModelFromJson(json);

  bool get isStop => type == WaypointType.stop;
  bool get isWaypoint => type == WaypointType.waypoint;
  bool get isPoi => type == WaypointType.poi;

  String get radiusColor {
    if (triggerRadius <= 50) return 'green';
    if (triggerRadius <= 100) return 'yellow';
    if (triggerRadius <= 200) return 'orange';
    return 'red';
  }

  bool hasOverlapWith(WaypointModel other) {
    final distance = Distance().as(
      LengthUnit.Meter,
      location,
      other.location,
    );
    return distance < (triggerRadius + other.triggerRadius);
  }

  bool isTooCloseTo(WaypointModel other, {double minDistance = 20}) {
    final distance = Distance().as(
      LengthUnit.Meter,
      location,
      other.location,
    );
    return distance < minDistance;
  }
}

class LatLngConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) {
    return LatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(LatLng object) {
    return {
      'lat': object.latitude,
      'lng': object.longitude,
    };
  }
}
```

**Firestore Path**: `routes/{routeId}/waypoints/{waypointId}`

**Example JSON**:
```json
{
  "id": "waypoint_123",
  "routeId": "route_456",
  "order": 1,
  "location": {"lat": 48.8566, "lng": 2.3522},
  "name": "Eiffel Tower",
  "triggerRadius": 50,
  "type": "stop",
  "stopId": "stop_789",
  "manualPosition": false,
  "metadata": {},
  "createdAt": "2026-01-30T09:00:00Z",
  "updatedAt": "2026-01-30T09:00:00Z"
}
```

---

## PublishingSubmissionModel

**Purpose**: Tracks tour submissions through the publishing workflow.

**File**: `lib/data/models/publishing_submission_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'review_feedback_model.dart';

part 'publishing_submission_model.freezed.dart';
part 'publishing_submission_model.g.dart';

enum SubmissionStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('submitted')
  submitted,
  @JsonValue('under_review')
  underReview,
  @JsonValue('changes_requested')
  changesRequested,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('withdrawn')
  withdrawn,
}

@freezed
class PublishingSubmissionModel with _$PublishingSubmissionModel {
  const PublishingSubmissionModel._();

  const factory PublishingSubmissionModel({
    required String id,
    required String tourId,
    required String versionId,
    required String creatorId,
    required String creatorName,
    required SubmissionStatus status,
    @TimestampConverter() required DateTime submittedAt,
    @NullableTimestampConverter() DateTime? reviewedAt,
    String? reviewerId,
    String? reviewerName,
    @Default([]) List<ReviewFeedbackModel> feedback,
    String? rejectionReason,
    String? resubmissionJustification,
    @Default(0) int resubmissionCount,
    @Default(false) bool creatorIgnoredSuggestions,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _PublishingSubmissionModel;

  factory PublishingSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$PublishingSubmissionModelFromJson(json);

  factory PublishingSubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PublishingSubmissionModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  bool get isPending => status == SubmissionStatus.submitted || 
                        status == SubmissionStatus.underReview;
  bool get isApproved => status == SubmissionStatus.approved;
  bool get isRejected => status == SubmissionStatus.rejected;
  bool get needsChanges => status == SubmissionStatus.changesRequested;

  String get statusDisplay {
    switch (status) {
      case SubmissionStatus.draft:
        return 'Draft';
      case SubmissionStatus.submitted:
        return 'Submitted';
      case SubmissionStatus.underReview:
        return 'Under Review';
      case SubmissionStatus.changesRequested:
        return 'Changes Requested';
      case SubmissionStatus.approved:
        return 'Approved';
      case SubmissionStatus.rejected:
        return 'Rejected';
      case SubmissionStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}
```

**Firestore Path**: `publishing_submissions/{submissionId}`

**Example JSON**:
```json
{
  "id": "submission_123",
  "tourId": "tour_456",
  "versionId": "version_789",
  "creatorId": "user_abc",
  "creatorName": "John Doe",
  "status": "submitted",
  "submittedAt": "2026-01-30T09:00:00Z",
  "reviewedAt": null,
  "reviewerId": null,
  "reviewerName": null,
  "feedback": [],
  "rejectionReason": null,
  "resubmissionJustification": null,
  "resubmissionCount": 0,
  "creatorIgnoredSuggestions": false,
  "createdAt": "2026-01-30T09:00:00Z",
  "updatedAt": "2026-01-30T09:00:00Z"
}
```

---

## ReviewFeedbackModel

**Purpose**: Stores admin feedback on tour submissions.

**File**: `lib/data/models/review_feedback_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_feedback_model.freezed.dart';
part 'review_feedback_model.g.dart';

enum FeedbackType {
  @JsonValue('issue')
  issue,
  @JsonValue('suggestion')
  suggestion,
  @JsonValue('compliment')
  compliment,
  @JsonValue('required')
  required,
}

@freezed
class ReviewFeedbackModel with _$ReviewFeedbackModel {
  const ReviewFeedbackModel._();

  const factory ReviewFeedbackModel({
    required String id,
    required String submissionId,
    required String reviewerId,
    required String reviewerName,
    required FeedbackType type,
    required String message,
    String? stopId,
    @Default(false) bool resolved,
    @NullableTimestampConverter() DateTime? resolvedAt,
    @TimestampConverter() required DateTime createdAt,
  }) = _ReviewFeedbackModel;

  factory ReviewFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewFeedbackModelFromJson(json);

  factory ReviewFeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewFeedbackModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  bool get isStopSpecific => stopId != null;
  bool get isGeneral => stopId == null;
  bool get isRequired => type == FeedbackType.required;

  String get typeDisplay {
    switch (type) {
      case FeedbackType.issue:
        return 'Issue';
      case FeedbackType.suggestion:
        return 'Suggestion';
      case FeedbackType.compliment:
        return 'Compliment';
      case FeedbackType.required:
        return 'Required Change';
    }
  }
}
```

**Firestore Path**: `publishing_submissions/{submissionId}/feedback/{feedbackId}`

**Example JSON**:
```json
{
  "id": "feedback_123",
  "submissionId": "submission_456",
  "reviewerId": "admin_789",
  "reviewerName": "Admin User",
  "type": "suggestion",
  "message": "Consider adding more detail to the description",
  "stopId": "stop_abc",
  "resolved": false,
  "resolvedAt": null,
  "createdAt": "2026-01-30T09:00:00Z"
}
```

---

## VoiceGenerationModel

**Purpose**: Manages AI voice generation for tour stops.

**File**: `lib/data/models/voice_generation_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_generation_model.freezed.dart';
part 'voice_generation_model.g.dart';

enum VoiceGenerationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
}

@freezed
class VoiceGenerationModel with _$VoiceGenerationModel {
  const VoiceGenerationModel._();

  const factory VoiceGenerationModel({
    required String id,
    required String stopId,
    required String tourId,
    required String script,
    required String voiceId,
    required String voiceName,
    String? audioUrl,
    int? audioDuration,
    @Default(VoiceGenerationStatus.pending) VoiceGenerationStatus status,
    String? errorMessage,
    @Default(0) int regenerationCount,
    @Default([]) List<VoiceGenerationHistory> history,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _VoiceGenerationModel;

  factory VoiceGenerationModel.fromJson(Map<String, dynamic> json) =>
      _$VoiceGenerationModelFromJson(json);

  factory VoiceGenerationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VoiceGenerationModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  bool get isCompleted => status == VoiceGenerationStatus.completed;
  bool get isFailed => status == VoiceGenerationStatus.failed;
  bool get isProcessing => status == VoiceGenerationStatus.processing;

  int get estimatedDuration {
    final wordCount = script.split(' ').length;
    return (wordCount / 150 * 60).round();
  }

  String get durationFormatted {
    if (audioDuration == null) return 'Unknown';
    final minutes = audioDuration! ~/ 60;
    final seconds = audioDuration! % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

@freezed
class VoiceGenerationHistory with _$VoiceGenerationHistory {
  const factory VoiceGenerationHistory({
    required String script,
    required String voiceId,
    required String audioUrl,
    required int audioDuration,
    @TimestampConverter() required DateTime generatedAt,
  }) = _VoiceGenerationHistory;

  factory VoiceGenerationHistory.fromJson(Map<String, dynamic> json) =>
      _$VoiceGenerationHistoryFromJson(json);
}

class VoiceOption {
  final String id;
  final String name;
  final String description;
  final String accent;
  final String gender;
  final String previewUrl;

  const VoiceOption({
    required this.id,
    required this.name,
    required this.description,
    required this.accent,
    required this.gender,
    required this.previewUrl,
  });
}

class VoiceOptions {
  static const List<VoiceOption> available = [
    VoiceOption(
      id: 'voice_sophie',
      name: 'Sophie',
      description: 'Warm, friendly female voice',
      accent: 'French',
      gender: 'Female',
      previewUrl: 'https://storage.googleapis.com/ayp-voices/sophie_preview.mp3',
    ),
    VoiceOption(
      id: 'voice_pierre',
      name: 'Pierre',
      description: 'Professional male voice',
      accent: 'French',
      gender: 'Male',
      previewUrl: 'https://storage.googleapis.com/ayp-voices/pierre_preview.mp3',
    ),
    VoiceOption(
      id: 'voice_emma',
      name: 'Emma',
      description: 'Clear, articulate female voice',
      accent: 'British English',
      gender: 'Female',
      previewUrl: 'https://storage.googleapis.com/ayp-voices/emma_preview.mp3',
    ),
    VoiceOption(
      id: 'voice_james',
      name: 'James',
      description: 'Engaging male narrator',
      accent: 'American English',
      gender: 'Male',
      previewUrl: 'https://storage.googleapis.com/ayp-voices/james_preview.mp3',
    ),
  ];

  static VoiceOption? getById(String id) {
    try {
      return available.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
}
```

**Firestore Path**: `stops/{stopId}/voice_generations/{voiceGenId}`

**Example JSON**:
```json
{
  "id": "voice_gen_123",
  "stopId": "stop_456",
  "tourId": "tour_789",
  "script": "Welcome to the Eiffel Tower, one of the most iconic landmarks in Paris...",
  "voiceId": "voice_sophie",
  "voiceName": "Sophie",
  "audioUrl": "https://storage.googleapis.com/ayp-audio/voice_gen_123.mp3",
  "audioDuration": 45,
  "status": "completed",
  "errorMessage": null,
  "regenerationCount": 0,
  "history": [],
  "createdAt": "2026-01-30T09:00:00Z",
  "updatedAt": "2026-01-30T09:05:00Z"
}
```

---

## CollectionModel

**Purpose**: Manages curated collections of tours.

**File**: `lib/data/models/collection_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'collection_model.freezed.dart';
part 'collection_model.g.dart';

enum CollectionType {
  @JsonValue('geographic')
  geographic,
  @JsonValue('thematic')
  thematic,
  @JsonValue('seasonal')
  seasonal,
}

@freezed
class CollectionModel with _$CollectionModel {
  const CollectionModel._();

  const factory CollectionModel({
    required String id,
    required String name,
    required String description,
    String? coverImageUrl,
    required List<String> tourIds,
    @Default(true) bool isCurated,
    String? curatorId,
    String? curatorName,
    @Default(false) bool isFeatured,
    @Default([]) List<String> tags,
    @Default(CollectionType.geographic) CollectionType type,
    @Default(0) int sortOrder,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _CollectionModel;

  factory CollectionModel.fromJson(Map<String, dynamic> json) =>
      _$CollectionModelFromJson(json);

  factory CollectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectionModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  int get tourCount => tourIds.length;
}

class ParisCollections {
  static const List<Map<String, dynamic>> predefined = [
    {
      'name': 'Iconic Paris',
      'description': 'Must-see landmarks: Eiffel Tower, Louvre, Notre-Dame, Arc de Triomphe',
      'type': 'geographic',
      'tags': ['landmarks', 'famous', 'must-see'],
      'sortOrder': 1,
    },
    {
      'name': 'Hidden Montmartre',
      'description': 'Off-the-beaten-path gems in the artistic Montmartre neighborhood',
      'type': 'geographic',
      'tags': ['montmartre', 'hidden', 'local'],
      'sortOrder': 2,
    },
    {
      'name': 'Seine Riverside',
      'description': 'Scenic tours along the beautiful Seine river banks',
      'type': 'geographic',
      'tags': ['seine', 'river', 'scenic'],
      'sortOrder': 3,
    },
    {
      'name': 'Art & Museums',
      'description': 'World-class museums: Louvre, Orsay, Rodin, Picasso',
      'type': 'thematic',
      'tags': ['art', 'museums', 'culture'],
      'sortOrder': 4,
    },
    {
      'name': 'Historic Paris',
      'description': 'Medieval quarters, Latin Quarter, Le Marais',
      'type': 'thematic',
      'tags': ['history', 'medieval', 'heritage'],
      'sortOrder': 5,
    },
    {
      'name': 'Foodie\'s Paris',
      'description': 'Markets, bakeries, restaurants, wine bars',
      'type': 'thematic',
      'tags': ['food', 'gastronomy', 'culinary'],
      'sortOrder': 6,
    },
    {
      'name': 'Romantic Paris',
      'description': 'Perfect tours for couples and romantic spots',
      'type': 'thematic',
      'tags': ['romantic', 'couples', 'love'],
      'sortOrder': 7,
    },
    {
      'name': 'Paris by Night',
      'description': 'Evening and nighttime tours of illuminated Paris',
      'type': 'seasonal',
      'tags': ['night', 'evening', 'lights'],
      'sortOrder': 8,
    },
    {
      'name': 'Literary Paris',
      'description': 'Shakespeare & Co, historic cafés, writer haunts',
      'type': 'thematic',
      'tags': ['literature', 'books', 'writers'],
      'sortOrder': 9,
    },
    {
      'name': 'Modern Paris',
      'description': 'La Défense, contemporary architecture, new Paris',
      'type': 'geographic',
      'tags': ['modern', 'contemporary', 'architecture'],
      'sortOrder': 10,
    },
  ];
}
```

**Firestore Path**: `collections/{collectionId}`

**Example JSON**:
```json
{
  "id": "collection_123",
  "name": "Iconic Paris",
  "description": "Must-see landmarks: Eiffel Tower, Louvre, Notre-Dame, Arc de Triomphe",
  "coverImageUrl": "https://storage.googleapis.com/ayp-collections/iconic_paris.jpg",
  "tourIds": ["tour_1", "tour_2", "tour_3"],
  "isCurated": true,
  "curatorId": "admin_456",
  "curatorName": "Admin User",
  "isFeatured": true,
  "tags": ["landmarks", "famous", "must-see"],
  "type": "geographic",
  "sortOrder": 1,
  "createdAt": "2026-01-30T09:00:00Z",
  "updatedAt": "2026-01-30T09:00:00Z"
}
```

---

## TourAnalyticsModel

**Purpose**: Comprehensive analytics data for tours.

**File**: `lib/data/models/tour_analytics_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tour_analytics_model.freezed.dart';
part 'tour_analytics_model.g.dart';

enum AnalyticsPeriod {
  @JsonValue('day')
  day,
  @JsonValue('week')
  week,
  @JsonValue('month')
  month,
  @JsonValue('quarter')
  quarter,
  @JsonValue('year')
  year,
  @JsonValue('all_time')
  allTime,
  @JsonValue('custom')
  custom,
}

@freezed
class TourAnalyticsModel with _$TourAnalyticsModel {
  const factory TourAnalyticsModel({
    required String id,
    required String tourId,
    required AnalyticsPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required PlayMetrics plays,
    required DownloadMetrics downloads,
    required FavoriteMetrics favorites,
    required RevenueMetrics revenue,
    required CompletionMetrics completion,
    required GeographicMetrics geographic,
    required TimeSeriesData timeSeries,
    required UserFeedbackMetrics feedback,
    @TimestampConverter() required DateTime generatedAt,
  }) = _TourAnalyticsModel;

  factory TourAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$TourAnalyticsModelFromJson(json);

  factory TourAnalyticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TourAnalyticsModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

@freezed
class PlayMetrics with _$PlayMetrics {
  const factory PlayMetrics({
    required int total,
    required int unique,
    required double averageDuration,
    required int completions,
    required double completionRate,
    required double changeFromPrevious,
  }) = _PlayMetrics;

  factory PlayMetrics.fromJson(Map<String, dynamic> json) =>
      _$PlayMetricsFromJson(json);
}

@freezed
class DownloadMetrics with _$DownloadMetrics {
  const factory DownloadMetrics({
    required int total,
    required int unique,
    required double storageUsed,
    required double changeFromPrevious,
  }) = _DownloadMetrics;

  factory DownloadMetrics.fromJson(Map<String, dynamic> json) =>
      _$DownloadMetricsFromJson(json);
}

@freezed
class FavoriteMetrics with _$FavoriteMetrics {
  const factory FavoriteMetrics({
    required int total,
    required double changeFromPrevious,
  }) = _FavoriteMetrics;

  factory FavoriteMetrics.fromJson(Map<String, dynamic> json) =>
      _$FavoriteMetricsFromJson(json);
}

@freezed
class RevenueMetrics with _$RevenueMetrics {
  const factory RevenueMetrics({
    required double total,
    required int transactions,
    required double averageTransaction,
    @Default({}) Map<String, double> byPricingTier,
    required double changeFromPrevious,
  }) = _RevenueMetrics;

  factory RevenueMetrics.fromJson(Map<String, dynamic> json) =>
      _$RevenueMetricsFromJson(json);
}

@freezed
class CompletionMetrics with _$CompletionMetrics {
  const factory CompletionMetrics({
    required double completionRate,
    required Map<int, int> dropOffByStop,
    required double averageCompletionTime,
  }) = _CompletionMetrics;

  factory CompletionMetrics.fromJson(Map<String, dynamic> json) =>
      _$CompletionMetricsFromJson(json);
}

@freezed
class GeographicMetrics with _$GeographicMetrics {
  const factory GeographicMetrics({
    required Map<String, int> byCity,
    required Map<String, int> byCountry,
  }) = _GeographicMetrics;

  factory GeographicMetrics.fromJson(Map<String, dynamic> json) =>
      _$GeographicMetricsFromJson(json);
}

@freezed
class TimeSeriesData with _$TimeSeriesData {
  const factory TimeSeriesData({
    required List<TimeSeriesPoint> plays,
    required List<TimeSeriesPoint> downloads,
    required List<TimeSeriesPoint> favorites,
  }) = _TimeSeriesData;

  factory TimeSeriesData.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesDataFromJson(json);
}

@freezed
class TimeSeriesPoint with _$TimeSeriesPoint {
  const factory TimeSeriesPoint({
    required DateTime date,
    required int value,
  }) = _TimeSeriesPoint;

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesPointFromJson(json);
}

@freezed
class UserFeedbackMetrics with _$UserFeedbackMetrics {
  const factory UserFeedbackMetrics({
    required double averageRating,
    required int totalReviews,
    required Map<int, int> ratingDistribution,
  }) = _UserFeedbackMetrics;

  factory UserFeedbackMetrics.fromJson(Map<String, dynamic> json) =>
      _$UserFeedbackMetricsFromJson(json);
}
```

**Firestore Path**: `analytics/{tourId}/periods/{periodId}`

---

## Firestore Schema

### Collections Structure

```
firestore/
├── tours/
│   └── {tourId}/
│       └── pricing/
│           └── {pricingId}
├── tour_versions/
│   └── {versionId}/
│       └── routes/
│           └── {routeId}/
│               └── waypoints/
│                   └── {waypointId}
├── stops/
│   └── {stopId}/
│       └── voice_generations/
│           └── {voiceGenId}
├── publishing_submissions/
│   └── {submissionId}/
│       └── feedback/
│           └── {feedbackId}
├── collections/
│   └── {collectionId}
└── analytics/
    └── {tourId}/
        └── periods/
            └── {periodId}
```

### Indexes Required

```javascript
// Firestore indexes
db.collection('publishing_submissions')
  .createIndex({ status: 1, submittedAt: -1 });

db.collection('collections')
  .createIndex({ isFeatured: 1, sortOrder: 1 });

db.collection('analytics')
  .createIndex({ tourId: 1, period: 1, startDate: -1 });
```

---

## Relationships

```
TourModel
  ├── PricingModel (1:1)
  ├── TourVersionModel
  │   └── RouteModel (1:1)
  │       └── WaypointModel (1:many)
  │           └── StopModel (optional reference)
  ├── PublishingSubmissionModel (1:many)
  │   └── ReviewFeedbackModel (1:many)
  └── TourAnalyticsModel (1:many)

StopModel
  └── VoiceGenerationModel (1:1)

CollectionModel
  └── TourModel (many:many via tourIds array)
```

---

## Usage Examples

### Creating a Route with Waypoints

```dart
final route = RouteModel(
  id: 'route_123',
  tourId: 'tour_456',
  versionId: 'version_789',
  waypoints: [
    WaypointModel(
      id: 'wp_1',
      routeId: 'route_123',
      order: 1,
      location: LatLng(48.8566, 2.3522),
      name: 'Start Point',
      triggerRadius: 30,
      type: WaypointType.stop,
      stopId: 'stop_1',
      manualPosition: false,
      metadata: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ],
  routePolyline: [],
  snapMode: RouteSnapMode.roads,
  totalDistance: 5200.5,
  estimatedDuration: 7200,
  metadata: {},
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await routeRepository.create(route);
```

### Submitting a Tour for Review

```dart
final submission = PublishingSubmissionModel(
  id: 'submission_123',
  tourId: 'tour_456',
  versionId: 'version_789',
  creatorId: 'user_abc',
  creatorName: 'John Doe',
  status: SubmissionStatus.submitted,
  submittedAt: DateTime.now(),
  feedback: [],
  resubmissionCount: 0,
  creatorIgnoredSuggestions: false,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await publishingRepository.submitForReview(submission);
```

### Generating Voice

```dart
final voiceGen = VoiceGenerationModel(
  id: 'voice_gen_123',
  stopId: 'stop_456',
  tourId: 'tour_789',
  script: 'Welcome to the Eiffel Tower...',
  voiceId: 'voice_sophie',
  voiceName: 'Sophie',
  status: VoiceGenerationStatus.pending,
  regenerationCount: 0,
  history: [],
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

await voiceGenerationService.generate(voiceGen);
```
