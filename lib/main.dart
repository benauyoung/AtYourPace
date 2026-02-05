import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'config/firebase_options.dart';
import 'config/mapbox_config.dart';
import 'data/local/offline_storage_service.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'services/offline_map_service.dart';

/// Global error handler for uncaught Flutter errors
void _handleFlutterError(FlutterErrorDetails details) {
  FlutterError.presentError(details);
  if (kDebugMode) {
    // In debug mode, print full stack trace
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  } else {
    // In release mode, log to crash reporting service
    // TODO: Log to Crashlytics when configured
    debugPrint('Error logged: ${details.exception}');
  }
}

/// Global error handler for uncaught async errors
bool _handlePlatformError(Object error, StackTrace stack) {
  if (kDebugMode) {
    debugPrint('Uncaught async error: $error');
    debugPrint('Stack: $stack');
  } else {
    // TODO: Log to Crashlytics when configured
    debugPrint('Async error logged: $error');
  }
  return true; // Prevents app crash
}

/// Initialize services in background after app starts
Future<void> _initializeServicesInBackground() async {
  // Wait for the first frame to render before initializing services
  // This ensures the Activity context is fully ready
  await Future.delayed(const Duration(milliseconds: 500));

  // Initialize local notifications
  try {
    await initNotifications();
    debugPrint('Notification service initialized successfully');
  } catch (e, stack) {
    debugPrint('Failed to initialize notifications: $e');
    if (kDebugMode) {
      debugPrint('Stack: $stack');
    }
  }

  // Initialize audio service for background playback
  try {
    await initAudioService();
    debugPrint('Audio service initialized successfully');
  } catch (e, stack) {
    debugPrint('Failed to initialize audio service: $e');
    if (kDebugMode) {
      debugPrint('Stack: $stack');
    }
  }

  // Initialize foreground task communication for background location
  try {
    FlutterForegroundTask.initCommunicationPort();
    debugPrint('Background location service initialized successfully');
  } catch (e, stack) {
    debugPrint('Failed to initialize background location service: $e');
    if (kDebugMode) {
      debugPrint('Stack: $stack');
    }
  }

  // Initialize offline map service
  try {
    final storageService = OfflineStorageService();
    await storageService.initialize();
    final offlineMapService = OfflineMapService(storageService);
    await offlineMapService.initialize();
    // Clean up expired tiles on startup
    await offlineMapService.cleanupExpiredTiles();
    debugPrint('Offline map service initialized successfully');
  } catch (e, stack) {
    debugPrint('Failed to initialize offline map service: $e');
    if (kDebugMode) {
      debugPrint('Stack: $stack');
    }
  }
}

Future<void> main() async {
  // Set up global error handlers
  FlutterError.onError = _handleFlutterError;
  PlatformDispatcher.instance.onError = _handlePlatformError;

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (needed for analytics, crashlytics, etc. even in demo mode)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Mapbox with access token
  MapboxOptions.setAccessToken(MapboxConfig.accessToken);

  // Run the app first - services will initialize in background
  runApp(
    const ProviderScope(
      child: AYPTourGuideApp(),
    ),
  );

  // Initialize services in background after app starts
  // This prevents crashes from blocking app startup
  _initializeServicesInBackground();
}
