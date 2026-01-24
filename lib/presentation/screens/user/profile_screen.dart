import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(RouteNames.settings),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : '?',
                            style: context.textTheme.headlineLarge,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName,
                    style: context.textTheme.headlineSmall,
                  ),
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
                          onTap: () => context.go(RouteNames.editProfile),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.favorite_outline),
                          title: const Text('My Favorites'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => context.go(RouteNames.favorites),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('Tour History'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => context.go(RouteNames.tourHistory),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.download_outlined),
                          title: const Text('Downloaded Tours'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => context.go(RouteNames.downloads),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.emoji_events_outlined),
                          title: const Text('Achievements'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => context.go(RouteNames.achievements),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.star_outline),
                          title: const Text('My Reviews'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // TODO: Navigate to reviews
                          },
                        ),
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
                        onTap: () => context.go(RouteNames.creatorDashboard),
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
                        onTap: () => context.go(RouteNames.adminDashboard),
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
                          builder: (context) => AlertDialog(
                            title: const Text('Sign Out'),
                            content: const Text(
                              'Are you sure you want to sign out?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ref
                                      .read(authStateNotifierProvider.notifier)
                                      .signOut();
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
            ),
    );
  }
}
