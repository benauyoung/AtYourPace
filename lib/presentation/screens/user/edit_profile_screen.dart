import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/app_config.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tour_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isSaving = false;
  String? _newPhotoPath;

  // Preferences
  late bool _autoPlayAudio;
  late TriggerMode _triggerMode;
  late bool _offlineEnabled;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _displayNameController.text = user.displayName;
      _bioController.text = user.creatorProfile?.bio ?? '';
      _autoPlayAudio = user.preferences.autoPlayAudio;
      _triggerMode = user.preferences.triggerMode;
      _offlineEnabled = user.preferences.offlineEnabled;
    } else {
      _autoPlayAudio = true;
      _triggerMode = TriggerMode.geofence;
      _offlineEnabled = true;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile photo section
            Center(
              child: Stack(
                children: [
                  _ProfilePhotoAvatar(
                    newPhotoPath: _newPhotoPath,
                    photoUrl: user.photoUrl,
                    displayName: user.displayName,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: context.colorScheme.primary,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 20),
                        color: context.colorScheme.onPrimary,
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Basic Info Section
            Text(
              'Basic Information',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your display name';
                }
                if (value.length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              enabled: false,
              initialValue: user.email,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                helperText: 'Email cannot be changed',
              ),
            ),
            const SizedBox(height: 16),

            // Creator bio (only for creators)
            if (user.isCreator) ...[
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                  helperText: 'Tell users about yourself as a tour creator',
                ),
              ),
              const SizedBox(height: 24),
            ],

            // App Preferences Section
            Text(
              'App Preferences',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Auto-play Audio'),
                    subtitle: const Text(
                      'Automatically play audio when arriving at stops',
                    ),
                    value: _autoPlayAudio,
                    onChanged: (value) {
                      setState(() => _autoPlayAudio = value);
                    },
                    secondary: const Icon(Icons.play_circle_outline),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Offline Mode'),
                    subtitle: const Text(
                      'Enable downloading tours for offline use',
                    ),
                    value: _offlineEnabled,
                    onChanged: (value) {
                      setState(() => _offlineEnabled = value);
                    },
                    secondary: const Icon(Icons.download_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Account Actions
            Text(
              'Account',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.password),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _changePassword,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.delete_forever,
                      color: context.colorScheme.error,
                    ),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(color: context.colorScheme.error),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Demo mode indicator
            if (AppConfig.demoMode)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Demo Mode: Changes are simulated only',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => _newPhotoPath = pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to pick image: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authService = ref.read(authServiceProvider);
      final currentUser = ref.read(currentUserProvider).value;
      String? newPhotoUrl;

      // Upload new photo if selected
      if (_newPhotoPath != null && currentUser != null) {
        final storageService = ref.read(storageServiceProvider);
        newPhotoUrl = await storageService.uploadUserAvatarFile(
          userId: currentUser.uid,
          imageFile: File(_newPhotoPath!),
        );
      }

      // Build preferences object
      final preferences = UserPreferences(
        autoPlayAudio: _autoPlayAudio,
        triggerMode: _triggerMode,
        offlineEnabled: _offlineEnabled,
        preferredVoice: currentUser?.preferences.preferredVoice,
      );

      // Update profile in Firestore
      await authService.updateFullProfile(
        displayName: _displayNameController.text.trim(),
        photoUrl: newPhotoUrl,
        bio: currentUser?.isCreator == true ? _bioController.text.trim() : null,
        preferences: preferences,
      );

      if (mounted) {
        context.showSuccessSnackBar('Profile updated successfully');
        GoRouter.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to update profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _changePassword() {
    final userEmail = ref.read(currentUserProvider).value?.email ?? '';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'We will send a password reset link to your email address.',
            ),
            const SizedBox(height: 16),
            Text(
              userEmail,
              style: dialogContext.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final authService = ref.read(authServiceProvider);
                await authService.sendPasswordResetEmail(userEmail);
                if (mounted) {
                  context.showSuccessSnackBar('Password reset email sent');
                }
              } catch (e) {
                if (mounted) {
                  context.showErrorSnackBar('Failed to send reset email: $e');
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Delete Account',
          style: TextStyle(color: dialogContext.colorScheme.error),
        ),
        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performAccountDeletion();
            },
            style: FilledButton.styleFrom(
              backgroundColor: dialogContext.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion() async {
    setState(() => _isSaving = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.deleteAccount();

      if (mounted) {
        // Navigate to login screen after deletion
        GoRouter.of(context).go('/login');
      }
    } catch (e) {
      if (mounted) {
        // Firebase requires recent authentication for sensitive operations
        if (e.toString().contains('requires-recent-login')) {
          context.showErrorSnackBar(
            'Please sign out and sign in again before deleting your account',
          );
        } else {
          context.showErrorSnackBar('Failed to delete account: $e');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ProfilePhotoAvatar extends StatelessWidget {
  final String? newPhotoPath;
  final String? photoUrl;
  final String displayName;

  const _ProfilePhotoAvatar({
    required this.newPhotoPath,
    required this.photoUrl,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    // If there's a new local photo selected
    if (newPhotoPath != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(newPhotoPath!)),
      );
    }

    // If there's a network photo URL
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 60,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: 60,
          backgroundColor: context.colorScheme.primaryContainer,
          child: const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackAvatar(context),
      );
    }

    // Fallback to initials
    return _buildFallbackAvatar(context);
  }

  Widget _buildFallbackAvatar(BuildContext context) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: context.colorScheme.primaryContainer,
      child: Text(
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
        style: context.textTheme.headlineLarge?.copyWith(
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
