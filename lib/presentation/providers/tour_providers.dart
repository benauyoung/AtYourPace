import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/geohash_utils.dart';
import '../../data/models/tour_model.dart';
import '../../data/models/tour_version_model.dart';
import '../../data/models/stop_model.dart';
import '../../services/admin_service.dart';
import '../../services/cloud_functions_service.dart';
import '../../services/progress_service.dart';
import '../../services/storage_service.dart';
import '../../services/tour_management_service.dart';
import 'auth_provider.dart';
import 'demo_tour_providers.dart';

// Firebase Storage instance provider
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// Storage Service Provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(
    storage: ref.watch(firebaseStorageProvider),
  );
});

// Tour Management Service Provider
final tourManagementServiceProvider = Provider<TourManagementService>((ref) {
  return TourManagementService(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

// Progress Service Provider (requires authenticated user)
final progressServiceProvider = Provider<ProgressService?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  return ProgressService(
    firestore: ref.watch(firestoreProvider),
    userId: user.uid,
  );
});

// Firebase Functions instance provider
final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

// Cloud Functions Service Provider
final cloudFunctionsServiceProvider = Provider<CloudFunctionsService>((ref) {
  return CloudFunctionsService(
    functions: ref.watch(firebaseFunctionsProvider),
  );
});

// Tours near a location
final nearbyToursProvider = FutureProvider.family<List<TourModel>, ({double lat, double lng, double radiusKm})>((ref, params) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    return ref.watch(demoNearbyToursProvider(params).future);
  }

  final firestore = ref.watch(firestoreProvider);

  // Calculate geohash precision based on radius
  final precision = GeohashUtils.precisionForRadius(params.radiusKm * 1000);
  final centerHash = GeohashUtils.encode(params.lat, params.lng, precision: precision);
  final neighborHashes = GeohashUtils.neighbors(centerHash);

  final List<TourModel> tours = [];

  for (final hash in neighborHashes) {
    final snapshot = await firestore
        .collection(FirestoreCollections.tours)
        .where('status', isEqualTo: 'approved')
        .where('geohash', isGreaterThanOrEqualTo: hash)
        .where('geohash', isLessThan: '${hash}z')
        .limit(AppConstants.toursPerPage)
        .get();

    for (final doc in snapshot.docs) {
      final tour = TourModel.fromFirestore(doc);

      // Verify actual distance
      final distance = GeohashUtils.distanceInMeters(
        params.lat,
        params.lng,
        tour.startLocation.latitude,
        tour.startLocation.longitude,
      );

      if (distance <= params.radiusKm * 1000) {
        tours.add(tour);
      }
    }
  }

  // Remove duplicates and sort by distance
  final uniqueTours = tours.toSet().toList();
  uniqueTours.sort((a, b) {
    final distA = GeohashUtils.distanceInMeters(
      params.lat, params.lng, a.startLocation.latitude, a.startLocation.longitude,
    );
    final distB = GeohashUtils.distanceInMeters(
      params.lat, params.lng, b.startLocation.latitude, b.startLocation.longitude,
    );
    return distA.compareTo(distB);
  });

  return uniqueTours;
});

// Tours by category
final toursByCategoryProvider = FutureProvider.family<List<TourModel>, TourCategory>((ref, category) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    return ref.watch(demoToursByCategoryProvider(category).future);
  }

  final firestore = ref.watch(firestoreProvider);

  final snapshot = await firestore
      .collection(FirestoreCollections.tours)
      .where('status', isEqualTo: 'approved')
      .where('category', isEqualTo: category.name)
      .orderBy('stats.totalPlays', descending: true)
      .limit(AppConstants.toursPerPage)
      .get();

  return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
});

// Featured tours
final featuredToursProvider = FutureProvider<List<TourModel>>((ref) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    return ref.watch(demoFeaturedToursProvider.future);
  }

  final firestore = ref.watch(firestoreProvider);

  final snapshot = await firestore
      .collection(FirestoreCollections.tours)
      .where('status', isEqualTo: 'approved')
      .where('featured', isEqualTo: true)
      .orderBy('stats.totalPlays', descending: true)
      .limit(10)
      .get();

  return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
});

// Single tour by ID
final tourByIdProvider = FutureProvider.family<TourModel?, String>((ref, tourId) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    return ref.watch(demoTourByIdProvider(tourId).future);
  }

  final firestore = ref.watch(firestoreProvider);

  final doc = await firestore
      .collection(FirestoreCollections.tours)
      .doc(tourId)
      .get();

  if (!doc.exists) return null;
  return TourModel.fromFirestore(doc);
});

// Tour version
final tourVersionProvider = FutureProvider.family<TourVersionModel?, ({String tourId, String versionId})>((ref, params) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    return ref.watch(demoTourVersionProvider(params).future);
  }

  final firestore = ref.watch(firestoreProvider);

  final doc = await firestore
      .collection(FirestoreCollections.tours)
      .doc(params.tourId)
      .collection(FirestoreCollections.versions)
      .doc(params.versionId)
      .get();

  if (!doc.exists) return null;
  return TourVersionModel.fromFirestore(doc, tourId: params.tourId);
});

// Stops for a version
final stopsProvider = FutureProvider.family<List<StopModel>, ({String tourId, String versionId})>((ref, params) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    return ref.watch(demoStopsProvider(params).future);
  }

  final firestore = ref.watch(firestoreProvider);

  final snapshot = await firestore
      .collection(FirestoreCollections.tours)
      .doc(params.tourId)
      .collection(FirestoreCollections.versions)
      .doc(params.versionId)
      .collection(FirestoreCollections.stops)
      .orderBy('order')
      .get();

  return snapshot.docs.map((doc) => StopModel.fromFirestore(
    doc,
    tourId: params.tourId,
    versionId: params.versionId,
  )).toList();
});

// Creator's tours
final creatorToursProvider = FutureProvider<List<TourModel>>((ref) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    return ref.watch(demoCreatorToursProvider.future);
  }

  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(currentUserProvider).value;

  if (user == null) return [];

  final snapshot = await firestore
      .collection(FirestoreCollections.tours)
      .where('creatorId', isEqualTo: user.uid)
      .orderBy('updatedAt', descending: true)
      .get();

  return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
});

// Creator's tours by status
final creatorToursByStatusProvider = FutureProvider.family<List<TourModel>, TourStatus>((ref, status) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    final tours = await ref.watch(demoCreatorToursProvider.future);
    return tours.where((t) => t.status == status).toList();
  }

  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(currentUserProvider).value;

  if (user == null) return [];

  final snapshot = await firestore
      .collection(FirestoreCollections.tours)
      .where('creatorId', isEqualTo: user.uid)
      .where('status', isEqualTo: status.name)
      .orderBy('updatedAt', descending: true)
      .get();

  return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
});

// Admin review queue
final reviewQueueProvider = StreamProvider<List<TourModel>>((ref) {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    // Return pending tours from demo data
    final allTours = ref.watch(demoAllToursProvider);
    return allTours.when(
      data: (tours) => Stream.value(
        tours.where((t) => t.status == TourStatus.pendingReview).toList(),
      ),
      loading: () => Stream.value([]),
      error: (_, __) => Stream.value([]),
    );
  }

  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(currentUserProvider).value;

  if (user == null || !user.isAdmin) {
    return Stream.value([]);
  }

  return firestore
      .collection(FirestoreCollections.tours)
      .where('status', isEqualTo: 'pending_review')
      .orderBy('updatedAt')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList());
});

// All tours for admin (includes all statuses)
final allToursAdminProvider = FutureProvider<List<TourModel>>((ref) async {
  // Use demo provider in demo mode
  if (AppConfig.demoMode) {
    return ref.watch(demoAllToursProvider.future);
  }

  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(currentUserProvider).value;

  if (user == null || !user.isAdmin) {
    return [];
  }

  final snapshot = await firestore
      .collection(FirestoreCollections.tours)
      .orderBy('updatedAt', descending: true)
      .limit(100)
      .get();

  return snapshot.docs.map((doc) => TourModel.fromFirestore(doc)).toList();
});
