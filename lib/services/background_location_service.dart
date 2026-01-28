import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'geofence_service.dart';

/// Provider for background location service
final backgroundLocationServiceProvider = Provider<BackgroundLocationService>((ref) {
  return BackgroundLocationService(ref);
});

/// Provider for background service running state
final isBackgroundServiceRunningProvider = StateProvider<bool>((ref) => false);

/// Data passed to the background task
class BackgroundTaskData {
  final List<Map<String, dynamic>> geofences;
  final String tourId;
  final String tourName;

  BackgroundTaskData({
    required this.geofences,
    required this.tourId,
    required this.tourName,
  });

  Map<String, dynamic> toJson() => {
        'geofences': geofences,
        'tourId': tourId,
        'tourName': tourName,
      };

  factory BackgroundTaskData.fromJson(Map<String, dynamic> json) {
    return BackgroundTaskData(
      geofences: List<Map<String, dynamic>>.from(json['geofences'] ?? []),
      tourId: json['tourId'] ?? '',
      tourName: json['tourName'] ?? '',
    );
  }
}

/// Callback for handling geofence events from background
typedef GeofenceCallback = void Function(String geofenceId, String eventType);

/// Service for managing background location tracking with foreground service
class BackgroundLocationService {
  final Ref _ref;
  static GeofenceCallback? _geofenceCallback;

  BackgroundLocationService(this._ref);

  /// Set callback for geofence events
  static void setGeofenceCallback(GeofenceCallback callback) {
    _geofenceCallback = callback;
  }

  /// Initialize the foreground task
  Future<void> initialize() async {
    FlutterForegroundTask.initCommunicationPort();

    // Set up callback handler using addTaskDataCallback
    FlutterForegroundTask.addTaskDataCallback((data) {
      if (data is Map<String, dynamic>) {
        final type = data['type'] as String?;
        if (type == 'geofence_event') {
          final geofenceId = data['geofenceId'] as String;
          final eventType = data['eventType'] as String;
          _geofenceCallback?.call(geofenceId, eventType);
        }
      }
    });
  }

  /// Start background location tracking for a tour
  Future<bool> startTracking({
    required List<Geofence> geofences,
    required String tourId,
    required String tourName,
  }) async {
    // Check permissions first
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    // Request notification permission for Android 13+
    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    // Initialize foreground task
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'tour_tracking',
        channelName: 'Tour Tracking',
        channelDescription: 'Tracks your location during tour playback',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000), // Every 5 seconds
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    // Prepare geofence data
    final geofenceData = geofences
        .map((g) => {
              'id': g.id,
              'name': g.name,
              'latitude': g.latitude,
              'longitude': g.longitude,
              'radiusMeters': g.radiusMeters,
            })
        .toList();

    final taskData = BackgroundTaskData(
      geofences: geofenceData,
      tourId: tourId,
      tourName: tourName,
    );

    // Start the foreground service
    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Tour Active: $tourName',
      notificationText: 'Tracking your location for GPS-triggered stops',
      notificationButtons: [
        const NotificationButton(id: 'stop', text: 'Stop Tour'),
      ],
      callback: startBackgroundTask,
    );

    // Check if service started successfully
    if (result is ServiceRequestSuccess) {
      // Send geofence data to the task
      FlutterForegroundTask.sendDataToTask(taskData.toJson());
      _ref.read(isBackgroundServiceRunningProvider.notifier).state = true;
      return true;
    }

    return false;
  }

  /// Stop background location tracking
  Future<void> stopTracking() async {
    await FlutterForegroundTask.stopService();
    _ref.read(isBackgroundServiceRunningProvider.notifier).state = false;
  }

  /// Check if the service is running
  Future<bool> isRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  /// Update notification text
  Future<void> updateNotification({
    required String title,
    required String text,
  }) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
    );
  }

  /// Restart service after app is killed
  Future<bool> restartServiceIfNeeded() async {
    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }
    return false;
  }

  /// Dispose resources
  void dispose() {
    _geofenceCallback = null;
  }
}

// ============================================
// BACKGROUND TASK HANDLER
// ============================================

/// Entry point for the background task (must be top-level function)
@pragma('vm:entry-point')
void startBackgroundTask() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

/// Handler for background location tracking
class LocationTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionSubscription;
  final Map<String, Map<String, dynamic>> _geofences = {};
  final Set<String> _insideGeofences = {};
  String _tourName = '';
  DateTime? _lastNotificationTime;

  // Cooldown to prevent rapid re-triggering
  static const Duration _notificationCooldown = Duration(minutes: 5);

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('BackgroundTask: Started at $timestamp');
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Get current position
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      _checkGeofences(position);
    } catch (e) {
      debugPrint('BackgroundTask: Error getting position: $e');
    }
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      _tourName = data['tourName'] ?? '';

      final geofenceList = data['geofences'] as List<dynamic>? ?? [];
      _geofences.clear();
      for (final g in geofenceList) {
        if (g is Map<String, dynamic>) {
          final id = g['id'] as String;
          _geofences[id] = g;
        }
      }

      debugPrint(
          'BackgroundTask: Received ${_geofences.length} geofences for tour: $_tourName');
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    if (id == 'stop') {
      FlutterForegroundTask.stopService();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    _positionSubscription?.cancel();
    debugPrint('BackgroundTask: Destroyed at $timestamp');
  }

  void _checkGeofences(Position position) {
    final now = DateTime.now();

    for (final entry in _geofences.entries) {
      final id = entry.key;
      final geofence = entry.value;

      final lat = geofence['latitude'] as double;
      final lng = geofence['longitude'] as double;
      final radius = geofence['radiusMeters'] as double;
      final name = geofence['name'] as String? ?? 'Stop';

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );

      final isInside = distance <= radius;
      final wasInside = _insideGeofences.contains(id);

      if (isInside && !wasInside) {
        // Entered geofence
        _insideGeofences.add(id);

        // Check cooldown
        if (_lastNotificationTime == null ||
            now.difference(_lastNotificationTime!) > _notificationCooldown) {
          _lastNotificationTime = now;

          // Send event to main app
          FlutterForegroundTask.sendDataToMain({
            'type': 'geofence_event',
            'geofenceId': id,
            'eventType': 'enter',
          });

          // Update notification
          FlutterForegroundTask.updateService(
            notificationTitle: 'Arrived at: $name',
            notificationText: 'Tap to hear the audio guide',
          );

          debugPrint('BackgroundTask: Entered geofence $id ($name)');
        }
      } else if (!isInside && wasInside) {
        // Exited geofence
        _insideGeofences.remove(id);

        FlutterForegroundTask.sendDataToMain({
          'type': 'geofence_event',
          'geofenceId': id,
          'eventType': 'exit',
        });

        // Reset notification
        FlutterForegroundTask.updateService(
          notificationTitle: 'Tour Active: $_tourName',
          notificationText: 'Tracking your location for GPS-triggered stops',
        );

        debugPrint('BackgroundTask: Exited geofence $id ($name)');
      }
    }
  }
}
