import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import 'auth_provider.dart';

/// Provider for fetching all users (admin only)
final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  if (AppConfig.demoMode) {
    // Return demo data
    await Future.delayed(const Duration(milliseconds: 500));
    return _demoUsers;
  }

  // Implement actual Firestore query
  final firestore = ref.watch(firestoreProvider);
  final snapshot = await firestore
      .collection(FirestoreCollections.users)
      .orderBy('createdAt', descending: true)
      .get();

  return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
});

/// Provider for fetching users by role
final usersByRoleProvider = FutureProvider.family<List<UserModel>, UserRole>((ref, role) async {
  final allUsers = await ref.watch(allUsersProvider.future);
  return allUsers.where((user) => user.role == role).toList();
});

/// Provider for searching users
final searchUsersProvider = FutureProvider.family<List<UserModel>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }

  final allUsers = await ref.watch(allUsersProvider.future);
  final lowerQuery = query.toLowerCase();

  return allUsers.where((user) =>
    user.displayName.toLowerCase().contains(lowerQuery) ||
    user.email.toLowerCase().contains(lowerQuery)
  ).toList();
});

/// Provider for getting a single user by ID
final userByIdProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  if (AppConfig.demoMode) {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoUsers.firstWhere(
      (user) => user.uid == userId,
      orElse: () => _demoUsers.first,
    );
  }

  // Implement actual Firestore query
  final firestore = ref.watch(firestoreProvider);
  final doc = await firestore
      .collection(FirestoreCollections.users)
      .doc(userId)
      .get();

  if (doc.exists) {
    return UserModel.fromFirestore(doc);
  }
  return null;
});

/// Demo users for testing
final _demoUsers = [
  UserModel(
    uid: 'admin-1',
    email: 'admin@ayp.com',
    displayName: 'Admin User',
    role: UserRole.admin,
    createdAt: DateTime.now().subtract(const Duration(days: 365)),
    updatedAt: DateTime.now(),
  ),
  UserModel(
    uid: 'creator-1',
    email: 'sarah@tours.com',
    displayName: 'Sarah Johnson',
    role: UserRole.creator,
    creatorProfile: const CreatorProfile(
      bio: 'Professional tour guide with 10 years experience',
      verified: true,
      totalTours: 5,
      totalDownloads: 1250,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
    updatedAt: DateTime.now(),
  ),
  UserModel(
    uid: 'creator-2',
    email: 'mike@historytours.com',
    displayName: 'Mike Thompson',
    role: UserRole.creator,
    creatorProfile: const CreatorProfile(
      bio: 'History enthusiast and local guide',
      verified: true,
      totalTours: 3,
      totalDownloads: 850,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 120)),
    updatedAt: DateTime.now(),
  ),
  UserModel(
    uid: 'creator-3',
    email: 'emma@foodwalks.com',
    displayName: 'Emma Wilson',
    role: UserRole.creator,
    creatorProfile: const CreatorProfile(
      bio: 'Food blogger and culinary tour guide',
      verified: false,
      totalTours: 2,
      totalDownloads: 320,
    ),
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    updatedAt: DateTime.now(),
  ),
  UserModel(
    uid: 'user-1',
    email: 'john@example.com',
    displayName: 'John Smith',
    role: UserRole.user,
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    updatedAt: DateTime.now(),
  ),
  UserModel(
    uid: 'user-2',
    email: 'alice@example.com',
    displayName: 'Alice Brown',
    role: UserRole.user,
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
    updatedAt: DateTime.now(),
  ),
  UserModel(
    uid: 'user-3',
    email: 'bob@example.com',
    displayName: 'Bob Davis',
    role: UserRole.user,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    updatedAt: DateTime.now(),
  ),
  UserModel(
    uid: 'user-4',
    email: 'carol@example.com',
    displayName: 'Carol White',
    role: UserRole.user,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    updatedAt: DateTime.now(),
  ),
  UserModel(
    uid: 'user-5',
    email: 'david@example.com',
    displayName: 'David Lee',
    role: UserRole.user,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
  ),
];
