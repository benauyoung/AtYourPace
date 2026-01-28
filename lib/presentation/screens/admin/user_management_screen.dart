import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_config.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/user_model.dart';
import '../../providers/tour_providers.dart';
import '../../providers/user_providers.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _searchQuery = '';
  UserRole? _roleFilter;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allUsersProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<UserRole?>(
                  value: _roleFilter,
                  hint: const Text('All Roles'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Roles'),
                    ),
                    ...UserRole.values.map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _roleFilter = value);
                  },
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: usersAsync.when(
              data: (users) => Row(
                children: [
                  _StatChip(
                    label: 'Total',
                    value: users.length.toString(),
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Admins',
                    value: users.where((u) => u.role == UserRole.admin).length.toString(),
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Creators',
                    value: users.where((u) => u.role == UserRole.creator).length.toString(),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: 'Users',
                    value: users.where((u) => u.role == UserRole.user).length.toString(),
                    color: Colors.green,
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 16),

          // User list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filteredUsers = users.where((user) {
                  final matchesSearch = _searchQuery.isEmpty ||
                      user.displayName.toLowerCase().contains(_searchQuery) ||
                      user.email.toLowerCase().contains(_searchQuery);
                  final matchesRole = _roleFilter == null || user.role == _roleFilter;
                  return matchesSearch && matchesRole;
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: context.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _UserCard(
                      key: ValueKey(user.uid),
                      user: user,
                      isLoading: _isLoading,
                      onRoleChange: (newRole) => _changeUserRole(user, newRole),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: context.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(allUsersProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeUserRole(UserModel user, UserRole newRole) async {
    if (user.role == newRole) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Text(
          'Are you sure you want to change ${user.displayName}\'s role from '
          '${user.role.displayName} to ${newRole.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Change'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      if (AppConfig.demoMode) {
        await Future.delayed(const Duration(seconds: 1));
      } else {
        // Call AdminService to update user role
        final adminService = ref.read(adminServiceProvider);
        await adminService.updateUserRole(user.uid, newRole);
      }

      if (mounted) {
        context.showSuccessSnackBar('User role updated successfully');
        ref.invalidate(allUsersProvider);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to update role: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(label),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final bool isLoading;
  final void Function(UserRole) onRoleChange;

  const _UserCard({
    super.key,
    required this.user,
    required this.isLoading,
    required this.onRoleChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            _UserAvatar(user: user),
            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _RoleBadge(role: user.role),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Joined ${_formatDate(user.createdAt)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Actions
            PopupMenuButton<UserRole>(
              enabled: !isLoading,
              icon: const Icon(Icons.more_vert),
              tooltip: 'Change Role',
              onSelected: onRoleChange,
              itemBuilder: (context) => UserRole.values.map((role) {
                final isCurrentRole = user.role == role;
                return PopupMenuItem(
                  value: role,
                  enabled: !isCurrentRole,
                  child: Row(
                    children: [
                      Icon(
                        role.icon,
                        color: isCurrentRole
                            ? context.colorScheme.primary
                            : null,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        role.displayName,
                        style: TextStyle(
                          fontWeight:
                              isCurrentRole ? FontWeight.bold : null,
                          color: isCurrentRole
                              ? context.colorScheme.primary
                              : null,
                        ),
                      ),
                      if (isCurrentRole) ...[
                        const Spacer(),
                        const Icon(Icons.check, size: 18),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _UserAvatar extends StatelessWidget {
  final UserModel user;

  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: user.photoUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 28,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: 28,
          backgroundColor: context.colorScheme.primaryContainer,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 28,
          backgroundColor: context.colorScheme.primaryContainer,
          child: Text(
            user.displayName.isNotEmpty
                ? user.displayName[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: 20,
              color: context.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: context.colorScheme.primaryContainer,
      child: Text(
        user.displayName.isNotEmpty
            ? user.displayName[0].toUpperCase()
            : '?',
        style: TextStyle(
          fontSize: 20,
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    switch (role) {
      case UserRole.admin:
        backgroundColor = Colors.purple;
      case UserRole.creator:
        backgroundColor = Colors.blue;
      case UserRole.user:
        backgroundColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(role.icon, size: 14, color: backgroundColor),
          const SizedBox(width: 4),
          Text(
            role.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: backgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}

extension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.creator:
        return 'Creator';
      case UserRole.user:
        return 'User';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.creator:
        return Icons.create;
      case UserRole.user:
        return Icons.person;
    }
  }
}
