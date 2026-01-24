import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tour_history_provider.dart';
import 'favorites_provider.dart';

/// Achievement definition
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requirement; // Number needed to unlock
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requirement,
    required this.category,
  });
}

enum AchievementCategory {
  tours,
  exploration,
  social,
  collection,
}

extension AchievementCategoryExtension on AchievementCategory {
  String get displayName {
    switch (this) {
      case AchievementCategory.tours:
        return 'Tours';
      case AchievementCategory.exploration:
        return 'Exploration';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.collection:
        return 'Collection';
    }
  }

  IconData get icon {
    switch (this) {
      case AchievementCategory.tours:
        return Icons.tour;
      case AchievementCategory.exploration:
        return Icons.explore;
      case AchievementCategory.social:
        return Icons.people;
      case AchievementCategory.collection:
        return Icons.collections_bookmark;
    }
  }
}

/// User's achievement progress
class AchievementProgress {
  final Achievement achievement;
  final int currentProgress;
  final bool unlocked;
  final DateTime? unlockedAt;

  AchievementProgress({
    required this.achievement,
    required this.currentProgress,
    required this.unlocked,
    this.unlockedAt,
  });

  double get progressPercent =>
      (currentProgress / achievement.requirement).clamp(0.0, 1.0);
}

/// All available achievements
final allAchievements = [
  // Tour completion achievements
  const Achievement(
    id: 'first_tour',
    name: 'First Steps',
    description: 'Complete your first tour',
    icon: Icons.flag,
    color: Colors.green,
    requirement: 1,
    category: AchievementCategory.tours,
  ),
  const Achievement(
    id: 'five_tours',
    name: 'Explorer',
    description: 'Complete 5 tours',
    icon: Icons.hiking,
    color: Colors.blue,
    requirement: 5,
    category: AchievementCategory.tours,
  ),
  const Achievement(
    id: 'ten_tours',
    name: 'Adventurer',
    description: 'Complete 10 tours',
    icon: Icons.landscape,
    color: Colors.purple,
    requirement: 10,
    category: AchievementCategory.tours,
  ),
  const Achievement(
    id: 'twenty_five_tours',
    name: 'Globetrotter',
    description: 'Complete 25 tours',
    icon: Icons.public,
    color: Colors.orange,
    requirement: 25,
    category: AchievementCategory.tours,
  ),
  const Achievement(
    id: 'fifty_tours',
    name: 'Tour Master',
    description: 'Complete 50 tours',
    icon: Icons.emoji_events,
    color: Colors.amber,
    requirement: 50,
    category: AchievementCategory.tours,
  ),

  // Category-based achievements
  const Achievement(
    id: 'history_buff',
    name: 'History Buff',
    description: 'Complete 3 history tours',
    icon: Icons.account_balance,
    color: Colors.brown,
    requirement: 3,
    category: AchievementCategory.exploration,
  ),
  const Achievement(
    id: 'nature_lover',
    name: 'Nature Lover',
    description: 'Complete 3 nature tours',
    icon: Icons.park,
    color: Colors.green,
    requirement: 3,
    category: AchievementCategory.exploration,
  ),
  const Achievement(
    id: 'foodie',
    name: 'Foodie',
    description: 'Complete 3 food & drink tours',
    icon: Icons.restaurant,
    color: Colors.red,
    requirement: 3,
    category: AchievementCategory.exploration,
  ),
  const Achievement(
    id: 'ghost_hunter',
    name: 'Ghost Hunter',
    description: 'Complete 3 ghost tours',
    icon: Icons.nightlight,
    color: Colors.deepPurple,
    requirement: 3,
    category: AchievementCategory.exploration,
  ),
  const Achievement(
    id: 'art_enthusiast',
    name: 'Art Enthusiast',
    description: 'Complete 3 art tours',
    icon: Icons.palette,
    color: Colors.pink,
    requirement: 3,
    category: AchievementCategory.exploration,
  ),

  // Collection achievements
  const Achievement(
    id: 'collector',
    name: 'Collector',
    description: 'Add 5 tours to favorites',
    icon: Icons.favorite,
    color: Colors.red,
    requirement: 5,
    category: AchievementCategory.collection,
  ),
  const Achievement(
    id: 'curator',
    name: 'Curator',
    description: 'Add 15 tours to favorites',
    icon: Icons.bookmarks,
    color: Colors.indigo,
    requirement: 15,
    category: AchievementCategory.collection,
  ),

  // Social achievements
  const Achievement(
    id: 'first_review',
    name: 'Critic',
    description: 'Write your first review',
    icon: Icons.rate_review,
    color: Colors.teal,
    requirement: 1,
    category: AchievementCategory.social,
  ),
  const Achievement(
    id: 'five_reviews',
    name: 'Reviewer',
    description: 'Write 5 reviews',
    icon: Icons.star_rate,
    color: Colors.amber,
    requirement: 5,
    category: AchievementCategory.social,
  ),
  const Achievement(
    id: 'share_tour',
    name: 'Ambassador',
    description: 'Share a tour with friends',
    icon: Icons.share,
    color: Colors.blue,
    requirement: 1,
    category: AchievementCategory.social,
  ),
];

/// Provider for user stats used in achievements
final userStatsProvider = Provider<UserStats>((ref) {
  final completedCount = ref.watch(completedToursCountProvider);
  final favoritesCount = ref.watch(favoritesCountProvider);

  // Demo stats for other counters
  return UserStats(
    completedTours: completedCount,
    historyTours: 3, // Demo
    natureTours: 1, // Demo
    foodTours: 2, // Demo
    ghostTours: 0, // Demo
    artTours: 1, // Demo
    favoritesCount: favoritesCount,
    reviewsCount: 2, // Demo
    sharesCount: 1, // Demo
  );
});

class UserStats {
  final int completedTours;
  final int historyTours;
  final int natureTours;
  final int foodTours;
  final int ghostTours;
  final int artTours;
  final int favoritesCount;
  final int reviewsCount;
  final int sharesCount;

  UserStats({
    required this.completedTours,
    required this.historyTours,
    required this.natureTours,
    required this.foodTours,
    required this.ghostTours,
    required this.artTours,
    required this.favoritesCount,
    required this.reviewsCount,
    required this.sharesCount,
  });
}

/// Provider for achievement progress
final achievementProgressProvider = Provider<List<AchievementProgress>>((ref) {
  final stats = ref.watch(userStatsProvider);

  return allAchievements.map((achievement) {
    final progress = _getProgressForAchievement(achievement.id, stats);
    final unlocked = progress >= achievement.requirement;

    return AchievementProgress(
      achievement: achievement,
      currentProgress: progress,
      unlocked: unlocked,
      unlockedAt: unlocked ? DateTime.now().subtract(const Duration(days: 1)) : null,
    );
  }).toList();
});

int _getProgressForAchievement(String achievementId, UserStats stats) {
  switch (achievementId) {
    case 'first_tour':
    case 'five_tours':
    case 'ten_tours':
    case 'twenty_five_tours':
    case 'fifty_tours':
      return stats.completedTours;
    case 'history_buff':
      return stats.historyTours;
    case 'nature_lover':
      return stats.natureTours;
    case 'foodie':
      return stats.foodTours;
    case 'ghost_hunter':
      return stats.ghostTours;
    case 'art_enthusiast':
      return stats.artTours;
    case 'collector':
    case 'curator':
      return stats.favoritesCount;
    case 'first_review':
    case 'five_reviews':
      return stats.reviewsCount;
    case 'share_tour':
      return stats.sharesCount;
    default:
      return 0;
  }
}

/// Unlocked achievements
final unlockedAchievementsProvider = Provider<List<AchievementProgress>>((ref) {
  final all = ref.watch(achievementProgressProvider);
  return all.where((a) => a.unlocked).toList();
});

/// Locked achievements
final lockedAchievementsProvider = Provider<List<AchievementProgress>>((ref) {
  final all = ref.watch(achievementProgressProvider);
  return all.where((a) => !a.unlocked).toList();
});

/// Total achievement points
final achievementPointsProvider = Provider<int>((ref) {
  final unlocked = ref.watch(unlockedAchievementsProvider);
  return unlocked.length * 100; // 100 points per achievement
});
