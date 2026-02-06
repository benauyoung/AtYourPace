class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'AYP Tour Guide';
  static const String appVersion = '1.0.0';

  // Geofencing defaults
  static const double defaultTriggerRadius = 30.0; // meters
  static const double minTriggerRadius = 10.0;
  static const double maxTriggerRadius = 100.0;

  // Audio settings
  static const int maxAudioDuration = 600; // 10 minutes in seconds
  static const int defaultAudioBitrate = 128000;

  // Offline settings
  static const int downloadExpirationDays = 30;
  static const int maxOfflineTours = 10;

  // ElevenLabs
  static const int elevenLabsRateLimitMinutes = 1;
  static const int elevenLabsMaxTextLength = 5000;

  // Map settings
  static const double defaultMapZoom = 15.0;
  static const double minMapZoom = 5.0;
  static const double maxMapZoom = 20.0;

  // Pagination
  static const int toursPerPage = 20;
  static const int reviewsPerPage = 10;

  // Cache durations
  static const Duration tourCacheDuration = Duration(hours: 24);
  static const Duration imageCacheDuration = Duration(days: 7);
}

class StorageKeys {
  StorageKeys._();

  // Hive box names
  static const String userBox = 'user_box';
  static const String toursBox = 'tours_box';
  static const String downloadedToursBox = 'downloaded_tours_box';
  static const String progressBox = 'progress_box';
  static const String settingsBox = 'settings_box';

  // Settings keys
  static const String triggerMode = 'trigger_mode';
  static const String autoPlayAudio = 'auto_play_audio';
  static const String offlineEnabled = 'offline_enabled';
  static const String preferredVoice = 'preferred_voice';
  static const String lastSyncTime = 'last_sync_time';
}

class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String tours = 'tours';
  static const String versions = 'versions';
  static const String stops = 'stops';
  static const String reviews = 'reviews';
  static const String reviewQueue = 'reviewQueue';
  static const String rateLimits = 'rateLimits';
  static const String config = 'config';
  static const String tourProgress = 'tourProgress';
  static const String downloads = 'downloads';

  // New collections for Tour Manager rebuild
  static const String pricing = 'pricing';
  static const String routes = 'routes';
  static const String waypoints = 'waypoints';
  static const String publishingSubmissions = 'publishingSubmissions';
  static const String reviewFeedback = 'reviewFeedback';
  static const String voiceGenerations = 'voiceGenerations';
  static const String collections = 'collections';
  static const String analytics = 'analytics';
  static const String analyticsPeriods = 'periods';
}

class StoragePaths {
  StoragePaths._();

  static String tourCover(String tourId) => 'tours/$tourId/cover';
  static String tourAudio(String tourId, String stopId) => 'tours/$tourId/audio/$stopId';
  static String tourImage(String tourId, String stopId, int index) =>
      'tours/$tourId/images/$stopId/$index';
  static String tourVideo(String tourId, String stopId) => 'tours/$tourId/video/$stopId';
  static String userAvatar(String userId) => 'users/$userId/profile/avatar';
}
