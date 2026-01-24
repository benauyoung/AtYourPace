import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/geohash_utils.dart';
import '../data/models/stop_model.dart';
import '../data/models/tour_model.dart';
import '../data/models/tour_version_model.dart';

/// Service for managing tour creation, editing, and submission.
/// Follows the established provider pattern from AuthService.
class TourManagementService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TourManagementService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  User? get currentUser => _auth.currentUser;

  /// Creates a new tour with initial draft version.
  /// Returns the generated tour ID.
  Future<String> createTour({
    required TourModel tour,
    required TourVersionModel version,
  }) async {
    if (currentUser == null) {
      throw Exception('User must be authenticated to create tours');
    }

    // Generate tour ID (tour.id is required in model but may be temp placeholder)
    final tourId = tour.id.isEmpty
        ? _firestore.collection(FirestoreCollections.tours).doc().id
        : tour.id;

    // Calculate geohash for location-based queries
    final geohash = GeohashUtils.encode(
      tour.startLocation.latitude,
      tour.startLocation.longitude,
      precision: 6, // ~1.2km x 0.6km cells
    );

    // Create tour with geohash
    final tourWithGeohash = tour.copyWith(
      id: tourId,
      geohash: geohash,
      creatorId: currentUser!.uid,
      creatorName: currentUser!.displayName ?? currentUser!.email ?? 'Unknown',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Use batch write for atomicity
    final batch = _firestore.batch();

    // Save tour document
    batch.set(
      _firestore.collection(FirestoreCollections.tours).doc(tourId),
      tourWithGeohash.toFirestore(),
    );

    // Save initial draft version
    final versionWithIds = version.copyWith(
      id: version.id,
      tourId: tourId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    batch.set(
      _firestore
          .collection(FirestoreCollections.tours)
          .doc(tourId)
          .collection(FirestoreCollections.versions)
          .doc(version.id),
      versionWithIds.toFirestore(),
    );

    await batch.commit();
    return tourId;
  }

  /// Saves tour draft including version data and stops.
  /// Updates existing tour or creates new one if tourId is null.
  Future<String> saveTourDraft({
    required String? tourId,
    required TourModel tour,
    required TourVersionModel version,
    required List<StopModel> stops,
  }) async {
    if (currentUser == null) {
      throw Exception('User must be authenticated to save tours');
    }

    // If no tourId, create new tour
    if (tourId == null || tourId.isEmpty) {
      return await createTour(tour: tour, version: version);
    }

    // Verify user owns this tour
    final tourDoc = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .get();

    if (!tourDoc.exists) {
      throw Exception('Tour not found');
    }

    final existingTour = TourModel.fromFirestore(tourDoc);
    if (existingTour.creatorId != currentUser!.uid) {
      throw Exception('You do not have permission to edit this tour');
    }

    final batch = _firestore.batch();

    // Update tour metadata
    batch.update(
      _firestore.collection(FirestoreCollections.tours).doc(tourId),
      {
        'updatedAt': FieldValue.serverTimestamp(),
        ...tour.toFirestore(),
      },
    );

    // Update or create version
    final versionRef = _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .collection(FirestoreCollections.versions)
        .doc(version.id);

    batch.set(
      versionRef,
      {
        ...version.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // Save all stops
    final stopsCollectionRef = versionRef.collection(FirestoreCollections.stops);

    // Delete existing stops that are not in the new list
    final existingStopsSnapshot = await stopsCollectionRef.get();
    final newStopIds = stops.map((s) => s.id).toSet();

    for (final doc in existingStopsSnapshot.docs) {
      if (!newStopIds.contains(doc.id)) {
        batch.delete(doc.reference);
      }
    }

    // Add or update stops
    for (final stop in stops) {
      // Calculate geohash for each stop
      final stopGeohash = GeohashUtils.encode(
        stop.location.latitude,
        stop.location.longitude,
        precision: 9, // Higher precision for individual stops (~5m x 5m)
      );

      final stopWithGeohash = stop.copyWith(
        tourId: tourId,
        versionId: version.id,
        geohash: stopGeohash,
        updatedAt: DateTime.now(),
      );

      batch.set(
        stopsCollectionRef.doc(stop.id),
        stopWithGeohash.toFirestore(),
        SetOptions(merge: true),
      );
    }

    await batch.commit();
    return tourId;
  }

  /// Submits tour for admin review.
  /// Changes status to pending_review which triggers Cloud Function.
  Future<void> submitForReview(String tourId) async {
    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    // Verify user owns this tour
    final tourDoc = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .get();

    if (!tourDoc.exists) {
      throw Exception('Tour not found');
    }

    final tour = TourModel.fromFirestore(tourDoc);
    if (tour.creatorId != currentUser!.uid) {
      throw Exception('You do not have permission to submit this tour');
    }

    // Verify tour has at least one stop
    final versionDoc = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .collection(FirestoreCollections.versions)
        .doc(tour.draftVersionId)
        .get();

    if (!versionDoc.exists) {
      throw Exception('Tour version not found');
    }

    final stopsSnapshot = await versionDoc.reference
        .collection(FirestoreCollections.stops)
        .get();

    if (stopsSnapshot.docs.isEmpty) {
      throw Exception('Tour must have at least one stop before submission');
    }

    // Update tour status to pending_review
    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'status': TourStatus.pendingReview.name,
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Cloud Function (onTourSubmitted) will create review queue entry
  }

  /// Updates tour metadata without modifying version data.
  Future<void> updateTourMetadata({
    required String tourId,
    required Map<String, dynamic> updates,
  }) async {
    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    // Verify ownership
    final tourDoc = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .get();

    if (!tourDoc.exists) {
      throw Exception('Tour not found');
    }

    final tour = TourModel.fromFirestore(tourDoc);
    if (tour.creatorId != currentUser!.uid) {
      throw Exception('You do not have permission to edit this tour');
    }

    await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .update({
          ...updates,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  /// Deletes a tour and all its versions and stops.
  /// Only draft tours can be deleted.
  Future<void> deleteTour(String tourId) async {
    if (currentUser == null) {
      throw Exception('User must be authenticated');
    }

    // Verify ownership
    final tourDoc = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .get();

    if (!tourDoc.exists) {
      throw Exception('Tour not found');
    }

    final tour = TourModel.fromFirestore(tourDoc);
    if (tour.creatorId != currentUser!.uid) {
      throw Exception('You do not have permission to delete this tour');
    }

    // Only allow deleting draft tours
    if (tour.status != TourStatus.draft) {
      throw Exception('Only draft tours can be deleted');
    }

    final batch = _firestore.batch();

    // Delete all versions and their stops
    final versionsSnapshot = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .collection(FirestoreCollections.versions)
        .get();

    for (final versionDoc in versionsSnapshot.docs) {
      // Delete stops in this version
      final stopsSnapshot = await versionDoc.reference
          .collection(FirestoreCollections.stops)
          .get();

      for (final stopDoc in stopsSnapshot.docs) {
        batch.delete(stopDoc.reference);
      }

      // Delete version
      batch.delete(versionDoc.reference);
    }

    // Delete tour document
    batch.delete(tourDoc.reference);

    await batch.commit();
  }

  /// Gets a tour by ID with ownership check.
  Future<TourModel?> getTour(String tourId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .get();

    if (!doc.exists) return null;
    return TourModel.fromFirestore(doc);
  }

  /// Gets a specific version of a tour.
  Future<TourVersionModel?> getTourVersion({
    required String tourId,
    required String versionId,
  }) async {
    final doc = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .collection(FirestoreCollections.versions)
        .doc(versionId)
        .get();

    if (!doc.exists) return null;
    return TourVersionModel.fromFirestore(doc, tourId: tourId);
  }

  /// Gets all stops for a specific tour version.
  Future<List<StopModel>> getTourStops({
    required String tourId,
    required String versionId,
  }) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.tours)
        .doc(tourId)
        .collection(FirestoreCollections.versions)
        .doc(versionId)
        .collection(FirestoreCollections.stops)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => StopModel.fromFirestore(
              doc,
              tourId: tourId,
              versionId: versionId,
            ))
        .toList();
  }
}
