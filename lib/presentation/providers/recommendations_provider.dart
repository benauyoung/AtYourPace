import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tour_model.dart';
import 'favorites_provider.dart';
import 'tour_history_provider.dart';
import 'tour_providers.dart';

/// Provider for personalized tour recommendations
final recommendedToursProvider = FutureProvider<List<TourRecommendation>>((ref) async {
  final allTours = await ref.watch(featuredToursProvider.future);
  final history = ref.watch(tourHistoryProvider);
  final favorites = ref.watch(favoriteTourIdsProvider);

  // Get completed tour IDs and favorite tour IDs to exclude from recommendations
  final completedIds = history.where((r) => r.completed).map((r) => r.tourId).toSet();
  final viewedIds = history.map((r) => r.tourId).toSet();

  // Calculate user preferences based on history and favorites
  final preferences = _calculatePreferences(allTours, history, favorites);

  // Score and rank tours
  final recommendations = <TourRecommendation>[];

  for (final tour in allTours) {
    // Skip completed tours
    if (completedIds.contains(tour.id)) continue;

    final score = _calculateRecommendationScore(tour, preferences, favorites.contains(tour.id), viewedIds.contains(tour.id));
    final reasons = _getRecommendationReasons(tour, preferences, favorites.contains(tour.id));

    if (score > 0) {
      recommendations.add(TourRecommendation(
        tour: tour,
        score: score,
        reasons: reasons,
      ));
    }
  }

  // Sort by score descending
  recommendations.sort((a, b) => b.score.compareTo(a.score));

  // Return top 10
  return recommendations.take(10).toList();
});

/// Recommendation with reasoning
class TourRecommendation {
  final TourModel tour;
  final double score;
  final List<String> reasons;

  TourRecommendation({
    required this.tour,
    required this.score,
    required this.reasons,
  });
}

/// User preferences derived from history
class UserPreferences {
  final Map<TourCategory, double> categoryScores;
  final Map<TourType, double> typeScores;
  final double avgRatingPreference;

  UserPreferences({
    required this.categoryScores,
    required this.typeScores,
    required this.avgRatingPreference,
  });
}

UserPreferences _calculatePreferences(
  List<TourModel> allTours,
  List<TourViewRecord> history,
  Set<String> favorites,
) {
  final categoryScores = <TourCategory, double>{};
  final typeScores = <TourType, double>{};
  double totalRating = 0;
  int ratedCount = 0;

  // Initialize with small base scores
  for (final category in TourCategory.values) {
    categoryScores[category] = 0.1;
  }
  for (final type in TourType.values) {
    typeScores[type] = 0.1;
  }

  // Score based on history and favorites
  for (final tour in allTours) {
    final isFavorite = favorites.contains(tour.id);
    final historyRecord = history.where((r) => r.tourId == tour.id).firstOrNull;

    double weight = 0;
    if (isFavorite) weight += 2.0;
    if (historyRecord != null) {
      weight += 1.0;
      if (historyRecord.completed) weight += 1.5;
    }

    if (weight > 0) {
      categoryScores[tour.category] = (categoryScores[tour.category] ?? 0) + weight;
      typeScores[tour.tourType] = (typeScores[tour.tourType] ?? 0) + weight;

      if (tour.stats.averageRating > 0) {
        totalRating += tour.stats.averageRating * weight;
        ratedCount++;
      }
    }
  }

  // Normalize scores
  final maxCategoryScore = categoryScores.values.fold<double>(1, (max, v) => v > max ? v : max);
  final maxTypeScore = typeScores.values.fold<double>(1, (max, v) => v > max ? v : max);

  for (final category in TourCategory.values) {
    categoryScores[category] = (categoryScores[category] ?? 0) / maxCategoryScore;
  }
  for (final type in TourType.values) {
    typeScores[type] = (typeScores[type] ?? 0) / maxTypeScore;
  }

  return UserPreferences(
    categoryScores: categoryScores,
    typeScores: typeScores,
    avgRatingPreference: ratedCount > 0 ? totalRating / ratedCount : 4.0,
  );
}

double _calculateRecommendationScore(
  TourModel tour,
  UserPreferences preferences,
  bool isFavorite,
  bool isViewed,
) {
  double score = 0;

  // Category preference (0-40 points)
  score += (preferences.categoryScores[tour.category] ?? 0) * 40;

  // Type preference (0-20 points)
  score += (preferences.typeScores[tour.tourType] ?? 0) * 20;

  // High rating bonus (0-20 points)
  if (tour.stats.averageRating >= 4.5) {
    score += 20;
  } else if (tour.stats.averageRating >= 4.0) {
    score += 15;
  } else if (tour.stats.averageRating >= 3.5) {
    score += 10;
  }

  // Popular tours bonus (0-10 points)
  if (tour.stats.totalPlays > 1000) {
    score += 10;
  } else if (tour.stats.totalPlays > 500) {
    score += 7;
  } else if (tour.stats.totalPlays > 100) {
    score += 4;
  }

  // Featured bonus (10 points)
  if (tour.featured) {
    score += 10;
  }

  // Penalty for already viewed (but not completed)
  if (isViewed) {
    score *= 0.7;
  }

  return score;
}

List<String> _getRecommendationReasons(
  TourModel tour,
  UserPreferences preferences,
  bool isFavorite,
) {
  final reasons = <String>[];

  // Check if category matches preferences
  if ((preferences.categoryScores[tour.category] ?? 0) > 0.5) {
    reasons.add('Based on your interest in ${tour.category.displayName.toLowerCase()} tours');
  }

  // High rating
  if (tour.stats.averageRating >= 4.5) {
    reasons.add('Highly rated (${tour.stats.averageRating.toStringAsFixed(1)} stars)');
  }

  // Popular
  if (tour.stats.totalPlays > 500) {
    reasons.add('Popular with ${_formatCount(tour.stats.totalPlays)} plays');
  }

  // Featured
  if (tour.featured) {
    reasons.add('Featured tour');
  }

  // Type match
  if ((preferences.typeScores[tour.tourType] ?? 0) > 0.5) {
    reasons.add('Great for ${tour.tourType.displayName.toLowerCase()} exploration');
  }

  // If no specific reasons, add a generic one
  if (reasons.isEmpty) {
    reasons.add('Recommended for you');
  }

  return reasons.take(2).toList();
}

String _formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}

/// Recommendations by category
final recommendationsByCategoryProvider = FutureProvider<Map<TourCategory, List<TourModel>>>((ref) async {
  final allTours = await ref.watch(featuredToursProvider.future);
  final completedIds = ref.watch(tourHistoryProvider)
      .where((r) => r.completed)
      .map((r) => r.tourId)
      .toSet();

  final result = <TourCategory, List<TourModel>>{};

  for (final category in TourCategory.values) {
    final categoryTours = allTours
        .where((t) => t.category == category && !completedIds.contains(t.id))
        .toList()
      ..sort((a, b) => b.stats.averageRating.compareTo(a.stats.averageRating));

    if (categoryTours.isNotEmpty) {
      result[category] = categoryTours.take(5).toList();
    }
  }

  return result;
});
