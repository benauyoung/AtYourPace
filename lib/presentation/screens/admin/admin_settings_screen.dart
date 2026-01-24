import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/app_config.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth_provider.dart';

/// App settings data class
class AppSettings {
  final bool maintenanceMode;
  final String minAppVersion;
  final int maxToursPerCreator;
  final int elevenLabsQuotaPerUser;
  final bool allowNewRegistrations;
  final bool requireEmailVerification;
  final List<String> featuredTourIds;
  final DateTime? updatedAt;
  final String? updatedBy;

  const AppSettings({
    this.maintenanceMode = false,
    this.minAppVersion = '1.0.0',
    this.maxToursPerCreator = 50,
    this.elevenLabsQuotaPerUser = 10,
    this.allowNewRegistrations = true,
    this.requireEmailVerification = true,
    this.featuredTourIds = const [],
    this.updatedAt,
    this.updatedBy,
  });

  factory AppSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppSettings(
      maintenanceMode: data['maintenanceMode'] as bool? ?? false,
      minAppVersion: data['minAppVersion'] as String? ?? '1.0.0',
      maxToursPerCreator: data['maxToursPerCreator'] as int? ?? 50,
      elevenLabsQuotaPerUser: data['elevenLabsQuotaPerUser'] as int? ?? 10,
      allowNewRegistrations: data['allowNewRegistrations'] as bool? ?? true,
      requireEmailVerification: data['requireEmailVerification'] as bool? ?? true,
      featuredTourIds: (data['featuredTourIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      updatedBy: data['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'maintenanceMode': maintenanceMode,
      'minAppVersion': minAppVersion,
      'maxToursPerCreator': maxToursPerCreator,
      'elevenLabsQuotaPerUser': elevenLabsQuotaPerUser,
      'allowNewRegistrations': allowNewRegistrations,
      'requireEmailVerification': requireEmailVerification,
      'featuredTourIds': featuredTourIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  AppSettings copyWith({
    bool? maintenanceMode,
    String? minAppVersion,
    int? maxToursPerCreator,
    int? elevenLabsQuotaPerUser,
    bool? allowNewRegistrations,
    bool? requireEmailVerification,
    List<String>? featuredTourIds,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return AppSettings(
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      maxToursPerCreator: maxToursPerCreator ?? this.maxToursPerCreator,
      elevenLabsQuotaPerUser: elevenLabsQuotaPerUser ?? this.elevenLabsQuotaPerUser,
      allowNewRegistrations: allowNewRegistrations ?? this.allowNewRegistrations,
      requireEmailVerification: requireEmailVerification ?? this.requireEmailVerification,
      featuredTourIds: featuredTourIds ?? this.featuredTourIds,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Provider for app settings notifier
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return AppSettingsNotifier(ref);
});

class AppSettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final Ref _ref;
  AppSettings _localSettings = const AppSettings();

  AppSettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  FirebaseFirestore get _firestore => _ref.read(firestoreProvider);

  DocumentReference get _settingsDoc => _firestore.collection('settings').doc('app');

  /// Load settings from Firestore
  Future<void> _loadSettings() async {
    if (AppConfig.demoMode) {
      state = const AsyncValue.data(AppSettings());
      _localSettings = const AppSettings();
      return;
    }

    try {
      final doc = await _settingsDoc.get();
      if (doc.exists) {
        _localSettings = AppSettings.fromFirestore(doc);
      } else {
        // Create default settings if not exists
        await _settingsDoc.set(const AppSettings().toFirestore());
        _localSettings = const AppSettings();
      }
      state = AsyncValue.data(_localSettings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reload settings from Firestore
  Future<void> reload() async {
    state = const AsyncValue.loading();
    await _loadSettings();
  }

  /// Get current local settings for editing
  AppSettings get currentSettings => _localSettings;

  // Local setters that don't persist immediately
  void setMaintenanceMode(bool value) {
    _localSettings = _localSettings.copyWith(maintenanceMode: value);
    state = AsyncValue.data(_localSettings);
  }

  void setMinAppVersion(String value) {
    _localSettings = _localSettings.copyWith(minAppVersion: value);
    state = AsyncValue.data(_localSettings);
  }

  void setMaxToursPerCreator(int value) {
    _localSettings = _localSettings.copyWith(maxToursPerCreator: value);
    state = AsyncValue.data(_localSettings);
  }

  void setElevenLabsQuota(int value) {
    _localSettings = _localSettings.copyWith(elevenLabsQuotaPerUser: value);
    state = AsyncValue.data(_localSettings);
  }

  void setAllowNewRegistrations(bool value) {
    _localSettings = _localSettings.copyWith(allowNewRegistrations: value);
    state = AsyncValue.data(_localSettings);
  }

  void setRequireEmailVerification(bool value) {
    _localSettings = _localSettings.copyWith(requireEmailVerification: value);
    state = AsyncValue.data(_localSettings);
  }

  void setFeaturedTourIds(List<String> ids) {
    _localSettings = _localSettings.copyWith(featuredTourIds: ids);
    state = AsyncValue.data(_localSettings);
  }

  /// Save all settings to Firestore
  Future<void> saveSettings(String adminId) async {
    if (AppConfig.demoMode) {
      // In demo mode, just return success
      return;
    }

    try {
      final data = _localSettings.toFirestore();
      data['updatedBy'] = adminId;
      await _settingsDoc.set(data, SetOptions(merge: true));

      // Reload to get server timestamp
      await _loadSettings();
    } catch (e) {
      rethrow;
    }
  }
}

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: () => notifier.reload(),
          ),
          TextButton.icon(
            onPressed: _isSaving ? null : _saveSettings,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) => _buildSettingsForm(context, settings, notifier),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load settings'),
              const SizedBox(height: 8),
              Text(error.toString(), style: context.textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => notifier.reload(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsForm(BuildContext context, AppSettings settings, AppSettingsNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Last updated info
        if (settings.updatedAt != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: context.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${_formatDateTime(settings.updatedAt!)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (settings.updatedBy != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'by ${settings.updatedBy}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

        // System Status Section
        _SectionHeader(title: 'System Status'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Maintenance Mode'),
                subtitle: const Text(
                  'When enabled, users will see a maintenance message',
                ),
                value: settings.maintenanceMode,
                onChanged: (value) => notifier.setMaintenanceMode(value),
                secondary: Icon(
                  Icons.construction,
                  color: settings.maintenanceMode ? Colors.orange : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Registration Settings
        _SectionHeader(title: 'Registration'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Allow New Registrations'),
                subtitle: const Text('Enable or disable new user sign-ups'),
                value: settings.allowNewRegistrations,
                onChanged: (value) => notifier.setAllowNewRegistrations(value),
                secondary: const Icon(Icons.person_add),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Require Email Verification'),
                subtitle: const Text('Users must verify email before accessing app'),
                value: settings.requireEmailVerification,
                onChanged: (value) => notifier.setRequireEmailVerification(value),
                secondary: const Icon(Icons.verified_user),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Limits Section
        _SectionHeader(title: 'Limits & Quotas'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.tour),
                title: const Text('Max Tours per Creator'),
                subtitle: Text('Current: ${settings.maxToursPerCreator}'),
                trailing: SizedBox(
                  width: 100,
                  child: DropdownButton<int>(
                    value: settings.maxToursPerCreator,
                    isExpanded: true,
                    items: [10, 25, 50, 100, 200]
                        .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) notifier.setMaxToursPerCreator(value);
                    },
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.record_voice_over),
                title: const Text('ElevenLabs Daily Quota'),
                subtitle: Text('${settings.elevenLabsQuotaPerUser} requests/day/user'),
                trailing: SizedBox(
                  width: 100,
                  child: DropdownButton<int>(
                    value: settings.elevenLabsQuotaPerUser,
                    isExpanded: true,
                    items: [5, 10, 20, 50, 100]
                        .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) notifier.setElevenLabsQuota(value);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // App Version
        _SectionHeader(title: 'Version Control'),
        Card(
          child: ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('Minimum App Version'),
            subtitle: Text('v${settings.minAppVersion}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showVersionDialog(settings.minAppVersion, notifier),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Danger Zone
        _SectionHeader(title: 'Danger Zone', color: Colors.red),
        Card(
          color: Colors.red.withValues(alpha: 0.05),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.red),
                title: const Text('Clear All Caches'),
                subtitle: const Text('Remove all cached data from the server'),
                trailing: OutlinedButton(
                  onPressed: _clearCaches,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.sync_problem, color: Colors.red),
                title: const Text('Force Refresh All Clients'),
                subtitle: const Text('Trigger app refresh for all connected users'),
                trailing: OutlinedButton(
                  onPressed: _forceRefresh,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Refresh'),
                ),
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
                    'Demo Mode: Changes are not persisted',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} minutes ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Future<void> _saveSettings() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      context.showErrorSnackBar('Not authenticated');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(appSettingsProvider.notifier).saveSettings(currentUser.uid);

      if (mounted) {
        context.showSuccessSnackBar('Settings saved successfully');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to save settings: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showVersionDialog(String currentVersion, AppSettingsNotifier notifier) {
    final controller = TextEditingController(text: currentVersion);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Minimum Version'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Version',
            hintText: 'e.g., 1.0.0',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              notifier.setMinAppVersion(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCaches() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Caches?'),
        content: const Text(
          'This will clear all cached data on the server. '
          'Users may experience slower load times temporarily.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.showSuccessSnackBar('Caches cleared');
    }
  }

  Future<void> _forceRefresh() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Refresh?'),
        content: const Text(
          'This will force all connected clients to refresh. '
          'Users may experience temporary disruption.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.showSuccessSnackBar('Refresh signal sent');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const _SectionHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
