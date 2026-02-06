import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/theme/colors.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isCreatingProfile = false;
  String? _createError;

  Future<void> _createMissingUserDocument() async {
    if (_isCreatingProfile) return;

    setState(() {
      _isCreatingProfile = true;
      _createError = null;
    });

    final authService = ref.read(authServiceProvider);
    final firebaseUser = authService.currentUser;
    if (firebaseUser == null) {
      setState(() {
        _isCreatingProfile = false;
        _createError = 'No authenticated user found';
      });
      return;
    }

    try {
      final firestore = ref.read(firestoreProvider);
      final userDoc = await firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        final user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'User',
          photoUrl: firebaseUser.photoURL,
          role: UserRole.user,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await firestore.collection('users').doc(user.uid).set(user.toFirestore());
      }
      // Refresh the provider to pick up the new document
      ref.invalidate(currentUserProvider);
    } catch (e) {
      debugPrint('Error creating user document: $e');
      if (mounted) {
        setState(() {
          _createError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error loading profile: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(currentUserProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        data: (user) {
          // If Firebase user exists but Firestore document doesn't, create it
          if (user == null && authState.valueOrNull != null) {
            // Show error if creation failed
            if (_createError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    const Text('Failed to create profile'),
                    const SizedBox(height: 8),
                    Text(_createError!, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _createMissingUserDocument,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Trigger creation only once
            if (!_isCreatingProfile) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _createMissingUserDocument();
              });
            }

            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Setting up your profile...'),
                ],
              ),
            );
          }

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildProfileContent(context, ref, user);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, WidgetRef ref, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header
          _ProfileAvatar(photoUrl: user.photoUrl, displayName: user.displayName, radius: 50),
          const SizedBox(height: 16),
          Text(user.displayName, style: context.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(user.role.name.toUpperCase()),
            backgroundColor: context.colorScheme.primaryContainer,
          ),
          const SizedBox(height: 24),

          // Menu items
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.editProfile),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_outline),
                  title: const Text('My Favorites'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.favorites),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Tour History'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.tourHistory),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Downloaded Tours'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.downloads),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.emoji_events_outlined),
                  title: const Text('Achievements'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.achievements),
                ),
                // Reviews hidden for now
                // const Divider(height: 1),
                // ListTile(
                //   leading: const Icon(Icons.star_outline),
                //   title: const Text('My Reviews'),
                //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                //   onTap: () => context.push(RouteNames.myReviews),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Creator/Admin sections
          if (user.isCreator) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Creator Dashboard'),
                subtitle: const Text('Manage your tours'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(RouteNames.creatorDashboard),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (user.isAdmin) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Dashboard'),
                subtitle: const Text('Manage users and tours'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(RouteNames.adminDashboard),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Logout button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ref.read(authStateNotifierProvider.notifier).signOut();
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colorScheme.error,
                side: BorderSide(color: context.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cached profile avatar widget
class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String displayName;
  final double radius;

  const _ProfileAvatar({required this.photoUrl, required this.displayName, this.radius = 50});

  @override
  Widget build(BuildContext context) {
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    if (photoUrl == null || photoUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        child: Text(initial, style: Theme.of(context).textTheme.headlineLarge),
      );
    }

    return CachedNetworkImage(
      imageUrl: photoUrl!,
      imageBuilder:
          (context, imageProvider) => CircleAvatar(radius: radius, backgroundImage: imageProvider),
      placeholder:
          (context, url) => CircleAvatar(radius: radius, child: const CircularProgressIndicator()),
      errorWidget:
          (context, url, error) => CircleAvatar(
            radius: radius,
            child: Text(initial, style: Theme.of(context).textTheme.headlineLarge),
          ),
    );
  }
}
