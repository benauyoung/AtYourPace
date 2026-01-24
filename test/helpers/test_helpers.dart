import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mockito/annotations.dart';

import 'package:ayp_tour_guide/data/models/stop_model.dart';
import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/data/models/tour_version_model.dart';
import 'package:ayp_tour_guide/data/models/user_model.dart';
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
    geohash: geohash ?? '9q8yy${order}',
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
