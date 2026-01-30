import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/annotations.dart';

import 'package:ayp_tour_guide/data/models/collection_model.dart';
import 'package:ayp_tour_guide/data/models/pricing_model.dart';
import 'package:ayp_tour_guide/data/models/publishing_submission_model.dart';
import 'package:ayp_tour_guide/data/models/review_feedback_model.dart';
import 'package:ayp_tour_guide/data/models/route_model.dart';
import 'package:ayp_tour_guide/data/models/stop_model.dart';
import 'package:ayp_tour_guide/data/models/tour_analytics_model.dart';
import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/data/models/tour_version_model.dart';
import 'package:ayp_tour_guide/data/models/user_model.dart';
import 'package:ayp_tour_guide/data/models/voice_generation_model.dart';
import 'package:ayp_tour_guide/data/models/waypoint_model.dart';
import 'package:ayp_tour_guide/services/location_service.dart';

// Generate mocks with: dart run build_runner build
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  FirebaseStorage,
  FirebaseFunctions,
  User,
  UserCredential,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  CollectionReference,
  Reference,
  UploadTask,
  TaskSnapshot,
  HttpsCallable,
  HttpsCallableResult,
  LocationService,
  WriteBatch,
])
void main() {}

// Test data factories

/// Creates a test TourModel with sensible defaults.
TourModel createTestTour({
  String? id,
  TourStatus status = TourStatus.draft,
  String creatorId = 'test_creator',
  String creatorName = 'Test Creator',
  String city = 'San Francisco',
  String? region,
  String country = 'USA',
  TourCategory category = TourCategory.history,
  TourType tourType = TourType.walking,
  double latitude = 37.7749,
  double longitude = -122.4194,
  String geohash = '9q8yy',
  String draftVersionId = 'draft_v1',
  int draftVersion = 1,
  String? liveVersionId,
  int? liveVersion,
  bool featured = false,
}) {
  return TourModel(
    id: id ?? 'test_tour_1',
    creatorId: creatorId,
    creatorName: creatorName,
    status: status,
    category: category,
    tourType: tourType,
    startLocation: GeoPoint(latitude, longitude),
    geohash: geohash,
    city: city,
    region: region,
    country: country,
    draftVersionId: draftVersionId,
    draftVersion: draftVersion,
    liveVersionId: liveVersionId,
    liveVersion: liveVersion,
    featured: featured,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a test UserModel with sensible defaults.
UserModel createTestUser({
  String? uid,
  UserRole role = UserRole.user,
  String email = 'test@example.com',
  String displayName = 'Test User',
  String? photoUrl,
}) {
  return UserModel(
    uid: uid ?? 'test_user_1',
    email: email,
    displayName: displayName,
    role: role,
    photoUrl: photoUrl,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
    creatorProfile: role == UserRole.creator
        ? const CreatorProfile(
            bio: 'Test creator bio',
            verified: true,
            totalTours: 5,
            totalDownloads: 100,
          )
        : null,
  );
}

/// Creates a test StopModel with sensible defaults.
StopModel createTestStop({
  String? id,
  String tourId = 'test_tour_1',
  String versionId = 'draft_v1',
  int order = 0,
  String name = 'Test Stop',
  String description = 'Test stop description',
  double latitude = 37.7749,
  double longitude = -122.4194,
  String? geohash,
  int triggerRadius = 30,
  String? audioUrl,
  AudioSource audioSource = AudioSource.uploaded,
  String? audioText,
}) {
  return StopModel(
    id: id ?? 'stop_$order',
    tourId: tourId,
    versionId: versionId,
    order: order,
    name: '$name $order',
    description: '$description $order',
    location: GeoPoint(latitude, longitude),
    geohash: geohash ?? '9q8yy$order',
    triggerRadius: triggerRadius,
    media: StopMedia(
      audioUrl: audioUrl ?? 'https://example.com/audio_$order.mp3',
      audioSource: audioSource,
      audioText: audioText ?? 'This is the audio script for $name $order',
      images: const [],
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a test TourVersionModel with sensible defaults.
TourVersionModel createTestTourVersion({
  String? id,
  String tourId = 'test_tour_1',
  int versionNumber = 1,
  VersionType versionType = VersionType.draft,
  String title = 'Test Tour',
  String description = 'Test tour description',
  String? coverImageUrl,
  String? duration,
  String? distance,
  TourDifficulty difficulty = TourDifficulty.easy,
  List<String> languages = const ['en'],
}) {
  return TourVersionModel(
    id: id ?? 'version_$versionNumber',
    tourId: tourId,
    versionNumber: versionNumber,
    versionType: versionType,
    title: title,
    description: description,
    coverImageUrl: coverImageUrl,
    duration: duration ?? '60 minutes',
    distance: distance ?? '2.5 km',
    difficulty: difficulty,
    languages: languages,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a list of test stops with sequential ordering.
List<StopModel> createTestStops({
  int count = 5,
  String tourId = 'test_tour_1',
  String versionId = 'draft_v1',
  double startLat = 37.7749,
  double startLon = -122.4194,
}) {
  return List.generate(
    count,
    (index) => createTestStop(
      tourId: tourId,
      versionId: versionId,
      order: index,
      name: 'Stop',
      latitude: startLat + (index * 0.001),
      longitude: startLon + (index * 0.001),
    ),
  );
}

/// Creates a test admin user.
UserModel createTestAdmin({String uid = 'admin_1'}) {
  return createTestUser(
    uid: uid,
    role: UserRole.admin,
    email: 'admin@ayp.com',
    displayName: 'Admin User',
  );
}

/// Creates a test creator user.
UserModel createTestCreator({String uid = 'creator_1'}) {
  return createTestUser(
    uid: uid,
    role: UserRole.creator,
    email: 'creator@ayp.com',
    displayName: 'Creator User',
  );
}

/// Creates a complete test tour with version and stops.
Map<String, dynamic> createTestTourWithData({
  String? tourId,
  String? versionId,
  int stopCount = 5,
}) {
  final tid = tourId ?? 'test_tour_complete';
  final vid = versionId ?? 'draft_v1';

  final tour = createTestTour(
    id: tid,
    draftVersionId: vid,
  );

  final version = createTestTourVersion(
    id: vid,
    tourId: tid,
  );

  final stops = createTestStops(
    count: stopCount,
    tourId: tid,
    versionId: vid,
  );

  return {
    'tour': tour,
    'version': version,
    'stops': stops,
  };
}

// =============================================================================
// TEST FACTORIES FOR NEW TOUR MANAGER MODELS
// =============================================================================

/// Creates a test PricingModel with sensible defaults.
PricingModel createTestPricing({
  String? id,
  String tourId = 'test_tour_1',
  PricingType type = PricingType.free,
  double? price,
  String currency = 'EUR',
  bool allowPayWhatYouWant = false,
  double? suggestedPrice,
  double? minimumPrice,
  List<PricingTier>? tiers,
}) {
  return PricingModel(
    id: id ?? 'pricing_1',
    tourId: tourId,
    type: type,
    price: price,
    currency: currency,
    allowPayWhatYouWant: allowPayWhatYouWant,
    suggestedPrice: suggestedPrice,
    minimumPrice: minimumPrice,
    tiers: tiers ?? [],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a test WaypointModel with sensible defaults.
WaypointModel createTestWaypoint({
  String? id,
  String routeId = 'route_1',
  int order = 0,
  double latitude = 48.8566,
  double longitude = 2.3522,
  String name = 'Test Waypoint',
  int triggerRadius = 30,
  WaypointType type = WaypointType.stop,
  String? stopId,
  bool manualPosition = false,
}) {
  return WaypointModel(
    id: id ?? 'waypoint_$order',
    routeId: routeId,
    order: order,
    location: LatLng(latitude, longitude),
    name: '$name $order',
    triggerRadius: triggerRadius,
    type: type,
    stopId: stopId,
    manualPosition: manualPosition,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a list of test waypoints with sequential ordering.
List<WaypointModel> createTestWaypoints({
  int count = 5,
  String routeId = 'route_1',
  double startLat = 48.8566,
  double startLng = 2.3522,
}) {
  return List.generate(
    count,
    (index) => createTestWaypoint(
      routeId: routeId,
      order: index,
      name: 'Waypoint',
      latitude: startLat + (index * 0.001),
      longitude: startLng + (index * 0.001),
    ),
  );
}

/// Creates a test RouteModel with sensible defaults.
RouteModel createTestRoute({
  String? id,
  String tourId = 'test_tour_1',
  String versionId = 'draft_v1',
  List<WaypointModel>? waypoints,
  List<LatLng>? routePolyline,
  RouteSnapMode snapMode = RouteSnapMode.roads,
  double totalDistance = 2500,
  int estimatedDuration = 3600,
}) {
  return RouteModel(
    id: id ?? 'route_1',
    tourId: tourId,
    versionId: versionId,
    waypoints: waypoints ?? createTestWaypoints(count: 3),
    routePolyline: routePolyline ?? [],
    snapMode: snapMode,
    totalDistance: totalDistance,
    estimatedDuration: estimatedDuration,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a test ReviewFeedbackModel with sensible defaults.
ReviewFeedbackModel createTestReviewFeedback({
  String? id,
  String submissionId = 'submission_1',
  String reviewerId = 'admin_1',
  String reviewerName = 'Admin User',
  FeedbackType type = FeedbackType.suggestion,
  String message = 'Test feedback message',
  String? stopId,
  String? stopName,
  FeedbackPriority priority = FeedbackPriority.medium,
  bool resolved = false,
  DateTime? resolvedAt,
  String? resolvedBy,
  String? resolutionNote,
}) {
  return ReviewFeedbackModel(
    id: id ?? 'feedback_1',
    submissionId: submissionId,
    reviewerId: reviewerId,
    reviewerName: reviewerName,
    type: type,
    message: message,
    stopId: stopId,
    stopName: stopName,
    priority: priority,
    resolved: resolved,
    resolvedAt: resolvedAt,
    resolvedBy: resolvedBy,
    resolutionNote: resolutionNote,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  );
}

/// Creates a test PublishingSubmissionModel with sensible defaults.
PublishingSubmissionModel createTestPublishingSubmission({
  String? id,
  String tourId = 'test_tour_1',
  String versionId = 'draft_v1',
  String creatorId = 'creator_1',
  String creatorName = 'Test Creator',
  SubmissionStatus status = SubmissionStatus.submitted,
  DateTime? submittedAt,
  DateTime? reviewedAt,
  String? reviewerId,
  String? reviewerName,
  List<ReviewFeedbackModel>? feedback,
  String? rejectionReason,
  int resubmissionCount = 0,
  String? tourTitle,
}) {
  return PublishingSubmissionModel(
    id: id ?? 'submission_1',
    tourId: tourId,
    versionId: versionId,
    creatorId: creatorId,
    creatorName: creatorName,
    status: status,
    submittedAt: submittedAt ?? DateTime.now().subtract(const Duration(hours: 2)),
    reviewedAt: reviewedAt,
    reviewerId: reviewerId,
    reviewerName: reviewerName,
    feedback: feedback ?? [],
    rejectionReason: rejectionReason,
    resubmissionCount: resubmissionCount,
    tourTitle: tourTitle ?? 'Test Tour',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a test VoiceGenerationModel with sensible defaults.
VoiceGenerationModel createTestVoiceGeneration({
  String? id,
  String stopId = 'stop_1',
  String tourId = 'test_tour_1',
  String script = 'This is a test script for voice generation.',
  String voiceId = 'voice_sophie',
  String voiceName = 'Sophie',
  String? audioUrl,
  int? audioDuration,
  VoiceGenerationStatus status = VoiceGenerationStatus.pending,
  String? errorMessage,
  int regenerationCount = 0,
}) {
  return VoiceGenerationModel(
    id: id ?? 'voice_gen_1',
    stopId: stopId,
    tourId: tourId,
    script: script,
    voiceId: voiceId,
    voiceName: voiceName,
    audioUrl: audioUrl,
    audioDuration: audioDuration,
    status: status,
    errorMessage: errorMessage,
    regenerationCount: regenerationCount,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a test CollectionModel with sensible defaults.
CollectionModel createTestCollection({
  String? id,
  String name = 'Test Collection',
  String description = 'A test collection of tours',
  String? coverImageUrl,
  List<String>? tourIds,
  bool isCurated = true,
  String? curatorId,
  String? curatorName,
  bool isFeatured = false,
  List<String>? tags,
  CollectionType type = CollectionType.geographic,
  int sortOrder = 0,
  String? city,
  String? country,
}) {
  return CollectionModel(
    id: id ?? 'collection_1',
    name: name,
    description: description,
    coverImageUrl: coverImageUrl,
    tourIds: tourIds ?? [],
    isCurated: isCurated,
    curatorId: curatorId ?? 'admin_1',
    curatorName: curatorName ?? 'Admin User',
    isFeatured: isFeatured,
    tags: tags ?? ['test', 'sample'],
    type: type,
    sortOrder: sortOrder,
    city: city ?? 'Paris',
    country: country ?? 'France',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now(),
  );
}

/// Creates a test TourAnalyticsModel with sensible defaults.
TourAnalyticsModel createTestTourAnalytics({
  String? id,
  String tourId = 'test_tour_1',
  AnalyticsPeriod period = AnalyticsPeriod.week,
  DateTime? startDate,
  DateTime? endDate,
  int totalPlays = 100,
  int uniquePlays = 75,
  int completions = 50,
  double completionRate = 0.5,
  int totalDownloads = 30,
  int totalFavorites = 20,
  double averageRating = 4.5,
  int totalReviews = 15,
}) {
  final now = DateTime.now();
  return TourAnalyticsModel(
    id: id ?? 'analytics_1',
    tourId: tourId,
    period: period,
    startDate: startDate ?? now.subtract(const Duration(days: 7)),
    endDate: endDate ?? now,
    plays: PlayMetrics(
      total: totalPlays,
      unique: uniquePlays,
      averageDuration: 1800,
      completions: completions,
      completionRate: completionRate,
      changeFromPrevious: 10.5,
    ),
    downloads: DownloadMetrics(
      total: totalDownloads,
      unique: totalDownloads,
      storageUsed: 50000,
      changeFromPrevious: 5.0,
    ),
    favorites: FavoriteMetrics(
      total: totalFavorites,
      changeFromPrevious: 2.0,
    ),
    revenue: const RevenueMetrics(
      total: 0,
      transactions: 0,
      averageTransaction: 0,
      byPricingTier: {},
      changeFromPrevious: 0,
    ),
    completion: CompletionMetrics(
      completionRate: completionRate,
      dropOffByStop: const {2: 10, 3: 15},
      averageCompletionTime: 2700,
    ),
    geographic: const GeographicMetrics(
      byCity: {'Paris': 50, 'London': 25, 'New York': 25},
      byCountry: {'France': 50, 'UK': 25, 'USA': 25},
    ),
    timeSeries: TimeSeriesData(
      plays: [
        TimeSeriesPoint(date: now.subtract(const Duration(days: 6)), value: 10),
        TimeSeriesPoint(date: now.subtract(const Duration(days: 5)), value: 15),
        TimeSeriesPoint(date: now.subtract(const Duration(days: 4)), value: 12),
      ],
      downloads: const [],
      favorites: const [],
    ),
    feedback: UserFeedbackMetrics(
      averageRating: averageRating,
      totalReviews: totalReviews,
      ratingDistribution: const {5: 10, 4: 3, 3: 1, 2: 1, 1: 0},
    ),
    generatedAt: now,
    cachedUntil: now.add(const Duration(minutes: 5)),
  );
}
