import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/app_config.dart';
import '../../../config/theme/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/extensions/context_extensions.dart';

/// Provider for user notification settings
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
      return NotificationSettingsNotifier();
    });

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool newToursNearby;
  final bool tourUpdates;
  final bool promotions;
  final bool achievementAlerts;
  final bool weeklyDigest;

  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.newToursNearby = true,
    this.tourUpdates = true,
    this.promotions = false,
    this.achievementAlerts = true,
    this.weeklyDigest = true,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? newToursNearby,
    bool? tourUpdates,
    bool? promotions,
    bool? achievementAlerts,
    bool? weeklyDigest,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      newToursNearby: newToursNearby ?? this.newToursNearby,
      tourUpdates: tourUpdates ?? this.tourUpdates,
      promotions: promotions ?? this.promotions,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings());

  void setPushEnabled(bool value) => state = state.copyWith(pushEnabled: value);
  void setEmailEnabled(bool value) => state = state.copyWith(emailEnabled: value);
  void setNewToursNearby(bool value) => state = state.copyWith(newToursNearby: value);
  void setTourUpdates(bool value) => state = state.copyWith(tourUpdates: value);
  void setPromotions(bool value) => state = state.copyWith(promotions: value);
  void setAchievementAlerts(bool value) => state = state.copyWith(achievementAlerts: value);
  void setWeeklyDigest(bool value) => state = state.copyWith(weeklyDigest: value);
}

/// Provider for app appearance settings
final appearanceSettingsProvider =
    StateNotifierProvider<AppearanceSettingsNotifier, AppearanceSettings>((ref) {
      return AppearanceSettingsNotifier();
    });

class AppearanceSettings {
  final ThemeMode themeMode;
  final bool useDynamicColors;
  final double mapZoomLevel;
  final String distanceUnit; // 'km' or 'mi'

  const AppearanceSettings({
    this.themeMode = ThemeMode.system,
    this.useDynamicColors = true,
    this.mapZoomLevel = 15.0,
    this.distanceUnit = 'km',
  });

  AppearanceSettings copyWith({
    ThemeMode? themeMode,
    bool? useDynamicColors,
    double? mapZoomLevel,
    String? distanceUnit,
  }) {
    return AppearanceSettings(
      themeMode: themeMode ?? this.themeMode,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      mapZoomLevel: mapZoomLevel ?? this.mapZoomLevel,
      distanceUnit: distanceUnit ?? this.distanceUnit,
    );
  }
}

class AppearanceSettingsNotifier extends StateNotifier<AppearanceSettings> {
  AppearanceSettingsNotifier() : super(const AppearanceSettings());

  void setThemeMode(ThemeMode mode) => state = state.copyWith(themeMode: mode);
  void setUseDynamicColors(bool value) => state = state.copyWith(useDynamicColors: value);
  void setMapZoomLevel(double value) => state = state.copyWith(mapZoomLevel: value);
  void setDistanceUnit(String value) => state = state.copyWith(distanceUnit: value);
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final notificationNotifier = ref.read(notificationSettingsProvider.notifier);
    final appearanceSettings = ref.watch(appearanceSettingsProvider);
    final appearanceNotifier = ref.read(appearanceSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive push notifications on your device'),
                  value: notificationSettings.pushEnabled,
                  onChanged: notificationNotifier.setPushEnabled,
                  secondary: const Icon(Icons.notifications),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive updates via email'),
                  value: notificationSettings.emailEnabled,
                  onChanged: notificationNotifier.setEmailEnabled,
                  secondary: const Icon(Icons.email),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notification Types
          _SectionHeader(title: 'Notification Types'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('New Tours Nearby'),
                  subtitle: const Text('Get notified when new tours are available near you'),
                  value: notificationSettings.newToursNearby,
                  onChanged:
                      notificationSettings.pushEnabled || notificationSettings.emailEnabled
                          ? notificationNotifier.setNewToursNearby
                          : null,
                  secondary: const Icon(Icons.location_on),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Tour Updates'),
                  subtitle: const Text('Updates to tours you\'ve saved or completed'),
                  value: notificationSettings.tourUpdates,
                  onChanged:
                      notificationSettings.pushEnabled || notificationSettings.emailEnabled
                          ? notificationNotifier.setTourUpdates
                          : null,
                  secondary: const Icon(Icons.update),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Achievement Alerts'),
                  subtitle: const Text('Get notified when you unlock achievements'),
                  value: notificationSettings.achievementAlerts,
                  onChanged:
                      notificationSettings.pushEnabled || notificationSettings.emailEnabled
                          ? notificationNotifier.setAchievementAlerts
                          : null,
                  secondary: const Icon(Icons.emoji_events),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Weekly Digest'),
                  subtitle: const Text('Weekly summary of new tours and activity'),
                  value: notificationSettings.weeklyDigest,
                  onChanged:
                      notificationSettings.emailEnabled
                          ? notificationNotifier.setWeeklyDigest
                          : null,
                  secondary: const Icon(Icons.calendar_today),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Promotions'),
                  subtitle: const Text('Deals and special offers'),
                  value: notificationSettings.promotions,
                  onChanged:
                      notificationSettings.pushEnabled || notificationSettings.emailEnabled
                          ? notificationNotifier.setPromotions
                          : null,
                  secondary: const Icon(Icons.local_offer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _SectionHeader(title: 'Appearance'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeModeText(appearanceSettings.themeMode)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showThemeDialog(context, appearanceSettings, appearanceNotifier),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Dynamic Colors'),
                  subtitle: const Text('Use colors from your wallpaper (Android 12+)'),
                  value: appearanceSettings.useDynamicColors,
                  onChanged: appearanceNotifier.setUseDynamicColors,
                  secondary: const Icon(Icons.color_lens),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Units Section
          _SectionHeader(title: 'Units & Display'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: const Text('Distance Unit'),
                  subtitle: Text(appearanceSettings.distanceUnit == 'km' ? 'Kilometers' : 'Miles'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'km', label: Text('km')),
                      ButtonSegment(value: 'mi', label: Text('mi')),
                    ],
                    selected: {appearanceSettings.distanceUnit},
                    onSelectionChanged:
                        (values) => appearanceNotifier.setDistanceUnit(values.first),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Default Map Zoom'),
                  subtitle: Slider(
                    value: appearanceSettings.mapZoomLevel,
                    min: 10,
                    max: 20,
                    divisions: 10,
                    label: appearanceSettings.mapZoomLevel.toStringAsFixed(0),
                    onChanged: appearanceNotifier.setMapZoomLevel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data & Storage Section
          _SectionHeader(title: 'Data & Storage'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Clear Cache'),
                  subtitle: const Text('Free up space by clearing cached data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showClearCacheDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Manage Downloads'),
                  subtitle: const Text('View and manage downloaded tours'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.downloads),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: 'About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  subtitle: Text('${AppConstants.appVersion} (${AppConstants.appName})'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.termsOfService),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.privacyPolicy),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteNames.help),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Demo mode indicator
          if (AppConfig.demoMode)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Demo Mode: Settings are not persisted',
                        style: context.textTheme.bodyMedium?.copyWith(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    AppearanceSettings settings,
    AppearanceSettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System default'),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) notifier.setThemeMode(value);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) notifier.setThemeMode(value);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value != null) notifier.setThemeMode(value);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Cache?'),
            content: const Text(
              'This will remove cached images and data. Downloaded tours will not be affected.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }
}
