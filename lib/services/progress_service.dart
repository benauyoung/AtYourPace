import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';

/// Service for tracking user progress through tours.
/// Handles saving progress, marking completions, and retrieving tour history.
class ProgressService {
  final FirebaseFirestore _firestore;
  final String userId;

  ProgressService({
    required FirebaseFirestore firestore,
    required this.userId,
  }) : _firestore = firestore;

  /// Saves user progress for a tour.
  Future<void> saveProgress({
    required String tourId,
    required int currentStopIndex,
    required int progressPercent,
    int? totalStops,
  }) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('progress')
        .doc(tourId)
        .set({
      'tourId': tourId,
      'currentStopIndex': currentStopIndex,
      'progressPercent': progressPercent,
      'totalStops': totalStops,
      'lastPlayedAt': FieldValue.serverTimestamp(),
      'completed': false,
    }, SetOptions(merge: true));
  }

  /// Marks a tour as completed and updates tour stats.
  Future<void> markCompleted({
    required String tourId,
    int? durationSeconds,
  }) async {
    final batch = _firestore.batch();

    // Update user progress
    batch.set(
      _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('progress')
          .doc(tourId),
      {
        'completed': true,
        'completedAt': FieldValue.serverTimestamp(),
        'progressPercent': 100,
        if (durationSeconds != null) 'durationSeconds': durationSeconds,
      },
      SetOptions(merge: true),
    );

    // Increment tour completion stats
    batch.update(
      _firestore.collection(FirestoreCollections.tours).doc(tourId),
      {
        'stats.completions': FieldValue.increment(1),
      },
    );

    await batch.commit();
  }

  /// Gets progress for a specific tour.
  Future<Map<String, dynamic>?> getProgress(String tourId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('progress')
        .doc(tourId)
        .get();

    if (!doc.exists) return null;
    return doc.data();
  }

  /// Gets all completed tours for the user.
  Future<List<Map<String, dynamic>>> getCompletedTours() async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('progress')
        .where('completed', isEqualTo: true)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Gets in-progress tours for the user.
  Future<List<Map<String, dynamic>>> getInProgressTours() async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('progress')
        .where('completed', isEqualTo: false)
        .orderBy('lastPlayedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Records that a tour was started (increments play count).
  Future<void> recordTourStart(String tourId) async {
    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'stats.totalPlays': FieldValue.increment(1),
    });

    // Also create initial progress entry if it doesn't exist
    final progressDoc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('progress')
        .doc(tourId)
        .get();

    if (!progressDoc.exists) {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .collection('progress')
          .doc(tourId)
          .set({
        'tourId': tourId,
        'currentStopIndex': 0,
        'progressPercent': 0,
        'lastPlayedAt': FieldValue.serverTimestamp(),
        'completed': false,
        'startedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Records that a tour was downloaded (increments download count).
  Future<void> recordTourDownload(String tourId) async {
    await _firestore.collection(FirestoreCollections.tours).doc(tourId).update({
      'stats.totalDownloads': FieldValue.increment(1),
    });
  }

  /// Deletes progress for a specific tour.
  Future<void> deleteProgress(String tourId) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('progress')
        .doc(tourId)
        .delete();
  }

  /// Clears all progress data for the user.
  Future<void> clearAllProgress() async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('progress')
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
