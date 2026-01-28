import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/review_model.dart';
import 'auth_provider.dart';

/// Provider for fetching reviews for a tour
final tourReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, tourId) async {
  if (AppConfig.demoMode) {
    await Future.delayed(const Duration(milliseconds: 300));
    return _getDemoReviews(tourId);
  }

  // Implement actual Firestore query
  final firestore = ref.watch(firestoreProvider);
  final snapshot = await firestore
      .collection(FirestoreCollections.reviews)
      .where('tourId', isEqualTo: tourId)
      .orderBy('createdAt', descending: true)
      .limit(AppConstants.reviewsPerPage)
      .get();

  return snapshot.docs
      .map((doc) => ReviewModel.fromFirestore(doc, tourId: tourId))
      .toList();
});

/// Provider for user's reviews
final userReviewsProvider = FutureProvider.family<List<ReviewModel>, String>((ref, userId) async {
  if (AppConfig.demoMode) {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoReviews.where((r) => r.userId == userId).toList();
  }

  // Implement actual Firestore query
  final firestore = ref.watch(firestoreProvider);
  final snapshot = await firestore
      .collection(FirestoreCollections.reviews)
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(AppConstants.reviewsPerPage)
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    final tourId = data['tourId'] as String;
    return ReviewModel.fromFirestore(doc, tourId: tourId);
  }).toList();
});

/// Provider to check if user has reviewed a tour
final hasUserReviewedProvider = FutureProvider.family<bool, ({String tourId, String userId})>((ref, params) async {
  final reviews = await ref.watch(tourReviewsProvider(params.tourId).future);
  return reviews.any((r) => r.userId == params.userId);
});

/// Provider for user's review on a specific tour
final userTourReviewProvider = FutureProvider.family<ReviewModel?, ({String tourId, String userId})>((ref, params) async {
  final reviews = await ref.watch(tourReviewsProvider(params.tourId).future);
  try {
    return reviews.firstWhere((r) => r.userId == params.userId);
  } catch (_) {
    return null;
  }
});

/// Provider for submitting a review
final submitReviewProvider = Provider((ref) {
  return SubmitReviewService(ref);
});

/// Provider for deleting a review
final deleteReviewProvider = Provider((ref) {
  return DeleteReviewService(ref);
});

class SubmitReviewService {
  final Ref _ref;

  SubmitReviewService(this._ref);

  Future<void> submitReview({
    required String tourId,
    required int rating,
    String? comment,
  }) async {
    final currentUser = _ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('User must be logged in to submit a review');
    }

    if (AppConfig.demoMode) {
      // In demo mode, just simulate success
      await Future.delayed(const Duration(seconds: 1));
      return;
    }

    final firestore = _ref.read(firestoreProvider);
    final now = DateTime.now();

    // Check if user already has a review for this tour
    final existingReviews = await firestore
        .collection(FirestoreCollections.reviews)
        .where('tourId', isEqualTo: tourId)
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    if (existingReviews.docs.isNotEmpty) {
      // Update existing review
      await firestore
          .collection(FirestoreCollections.reviews)
          .doc(existingReviews.docs.first.id)
          .update({
        'rating': rating,
        'comment': comment,
        'updatedAt': now,
      });
    } else {
      // Create new review
      await firestore.collection(FirestoreCollections.reviews).add({
        'tourId': tourId,
        'userId': currentUser.uid,
        'userName': currentUser.displayName,
        'userPhotoUrl': currentUser.photoUrl,
        'rating': rating,
        'comment': comment,
        'createdAt': now,
        'updatedAt': now,
      });

      // Update tour stats
      await _updateTourStats(tourId, rating);
    }

    // Invalidate the reviews provider to refresh the list
    _ref.invalidate(tourReviewsProvider(tourId));
  }

  Future<void> _updateTourStats(String tourId, int newRating) async {
    final firestore = _ref.read(firestoreProvider);

    await firestore.runTransaction((transaction) async {
      final tourDoc = await transaction.get(
        firestore.collection(FirestoreCollections.tours).doc(tourId),
      );

      if (!tourDoc.exists) return;

      final data = tourDoc.data()!;
      final stats = data['stats'] as Map<String, dynamic>? ?? {};
      final currentTotalRatings = (stats['totalRatings'] as int?) ?? 0;
      final currentAverageRating = (stats['averageRating'] as num?)?.toDouble() ?? 0.0;

      final newTotalRatings = currentTotalRatings + 1;
      final newAverageRating =
          ((currentAverageRating * currentTotalRatings) + newRating) / newTotalRatings;

      transaction.update(tourDoc.reference, {
        'stats.totalRatings': newTotalRatings,
        'stats.averageRating': newAverageRating,
      });
    });
  }
}

class DeleteReviewService {
  final Ref _ref;

  DeleteReviewService(this._ref);

  Future<void> deleteReview({
    required String tourId,
    required String reviewId,
  }) async {
    final currentUser = _ref.read(currentUserProvider).value;
    if (currentUser == null) {
      throw Exception('User must be logged in to delete a review');
    }

    if (AppConfig.demoMode) {
      // In demo mode, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      _ref.invalidate(userReviewsProvider(currentUser.uid));
      return;
    }

    final firestore = _ref.read(firestoreProvider);

    // Verify the review belongs to the current user
    final reviewDoc = await firestore
        .collection(FirestoreCollections.reviews)
        .doc(reviewId)
        .get();

    if (!reviewDoc.exists) {
      throw Exception('Review not found');
    }

    final reviewData = reviewDoc.data()!;
    if (reviewData['userId'] != currentUser.uid) {
      throw Exception('You can only delete your own reviews');
    }

    // Delete the review
    await firestore
        .collection(FirestoreCollections.reviews)
        .doc(reviewId)
        .delete();

    // Update tour stats
    await _updateTourStatsAfterDelete(tourId, reviewData['rating'] as int);

    // Invalidate providers to refresh
    _ref.invalidate(tourReviewsProvider(tourId));
    _ref.invalidate(userReviewsProvider(currentUser.uid));
  }

  Future<void> _updateTourStatsAfterDelete(String tourId, int deletedRating) async {
    final firestore = _ref.read(firestoreProvider);

    await firestore.runTransaction((transaction) async {
      final tourDoc = await transaction.get(
        firestore.collection(FirestoreCollections.tours).doc(tourId),
      );

      if (!tourDoc.exists) return;

      final data = tourDoc.data()!;
      final stats = data['stats'] as Map<String, dynamic>? ?? {};
      final currentTotalRatings = (stats['totalRatings'] as int?) ?? 0;
      final currentAverageRating = (stats['averageRating'] as num?)?.toDouble() ?? 0.0;

      if (currentTotalRatings <= 1) {
        // No more reviews, reset stats
        transaction.update(tourDoc.reference, {
          'stats.totalRatings': 0,
          'stats.averageRating': 0.0,
        });
      } else {
        final newTotalRatings = currentTotalRatings - 1;
        final newAverageRating =
            ((currentAverageRating * currentTotalRatings) - deletedRating) / newTotalRatings;

        transaction.update(tourDoc.reference, {
          'stats.totalRatings': newTotalRatings,
          'stats.averageRating': newAverageRating,
        });
      }
    });
  }
}

/// Get demo reviews for a tour
List<ReviewModel> _getDemoReviews(String tourId) {
  return _demoReviews.where((r) => r.tourId == tourId).toList();
}

/// Demo review data
final List<ReviewModel> _demoReviews = [
  ReviewModel(
    id: 'review-1',
    tourId: 'demo-tour-1',
    userId: 'user-1',
    userName: 'John Smith',
    rating: 5,
    comment: 'Amazing tour! The audio commentary was really informative and the stops were well-planned. Highly recommend for anyone visiting San Francisco!',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
  ReviewModel(
    id: 'review-2',
    tourId: 'demo-tour-1',
    userId: 'user-2',
    userName: 'Alice Brown',
    rating: 4,
    comment: 'Great experience overall. The GPS triggers worked perfectly. Would love to see more stops at the historic ships.',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  ReviewModel(
    id: 'review-3',
    tourId: 'demo-tour-1',
    userId: 'user-3',
    userName: 'Bob Davis',
    rating: 5,
    comment: 'Perfect for a morning walk. The sea lions were a highlight!',
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
    updatedAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
  ReviewModel(
    id: 'review-4',
    tourId: 'demo-tour-2',
    userId: 'user-1',
    userName: 'John Smith',
    rating: 4,
    comment: 'Beautiful park tour. The Japanese Tea Garden stop was my favorite.',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    updatedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  ReviewModel(
    id: 'review-5',
    tourId: 'demo-tour-2',
    userId: 'user-4',
    userName: 'Carol White',
    rating: 5,
    comment: 'Loved learning about the history of the park. Very peaceful walk!',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  ReviewModel(
    id: 'review-6',
    tourId: 'demo-tour-3',
    userId: 'user-2',
    userName: 'Alice Brown',
    rating: 5,
    comment: 'Best food tour ever! The fortune cookie factory was such a fun experience. The guide\'s recommendations were spot on.',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];
