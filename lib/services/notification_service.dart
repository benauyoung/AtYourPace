import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Notification channel IDs
  static const String tourAudioChannelId = 'tour_audio';
  static const String geofenceChannelId = 'geofence_alerts';
  static const String generalChannelId = 'general';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _isInitialized = true;
    debugPrint('NotificationService: Initialized');
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Geofence alerts channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        geofenceChannelId,
        'Tour Stop Alerts',
        description: 'Notifications when you arrive at tour stops',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // General notifications channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        generalChannelId,
        'General Notifications',
        description: 'General app notifications',
        importance: Importance.defaultImportance,
      ),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped - ${response.payload}');
    // Handle notification tap - could navigate to specific screen
    // based on payload
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }

    return false;
  }

  /// Show a geofence entry notification
  Future<void> showGeofenceEntryNotification({
    required String stopId,
    required String stopName,
    required String tourName,
    String? description,
  }) async {
    if (!_isInitialized || kIsWeb) return;

    await _plugin.show(
      stopId.hashCode,
      'You\'ve arrived at $stopName',
      description ?? 'Part of "$tourName" - Tap to start listening',
      NotificationDetails(
        android: AndroidNotificationDetails(
          geofenceChannelId,
          'Tour Stop Alerts',
          channelDescription: 'Notifications when you arrive at tour stops',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            description ?? 'You\'ve entered the area for this tour stop. Tap to hear the audio guide.',
            contentTitle: 'You\'ve arrived at $stopName',
            summaryText: tourName,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'geofence:$stopId',
    );

    debugPrint('NotificationService: Showed geofence notification for $stopName');
  }

  /// Show a tour completion notification
  Future<void> showTourCompleteNotification({
    required String tourId,
    required String tourName,
  }) async {
    if (!_isInitialized || kIsWeb) return;

    await _plugin.show(
      tourId.hashCode,
      'Tour Complete!',
      'You\'ve finished "$tourName". Don\'t forget to leave a review!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          generalChannelId,
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'tour_complete:$tourId',
    );
  }

  /// Show a general notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized || kIsWeb) return;

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          generalChannelId,
          'General Notifications',
          channelDescription: 'General app notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }
}

/// Initialize notifications - call in main.dart
Future<void> initNotifications() async {
  if (kIsWeb) return;

  final service = NotificationService();
  await service.initialize();
  // Don't request permissions at startup - do it when needed
  // This avoids null context issues on Android
}
