import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'package:ayp_tour_guide/services/audio_service.dart';
import 'package:ayp_tour_guide/services/location_service.dart';
import 'package:ayp_tour_guide/data/local/offline_storage_service.dart';
import 'package:ayp_tour_guide/data/models/tour_model.dart';
import 'package:ayp_tour_guide/data/models/tour_version_model.dart';
import 'package:ayp_tour_guide/data/models/stop_model.dart';

/// Fake AudioService for testing that doesn't require actual audio playback.
/// This is a standalone fake that doesn't extend AudioService to avoid
/// creating a real AudioPlayer which requires Flutter bindings.
class FakeAudioService {
  final StreamController<AudioState> _stateController =
      StreamController<AudioState>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController =
      StreamController<Duration?>.broadcast();

  AudioState _currentState = AudioState.idle;
  Duration _position = Duration.zero;
  Duration? _duration;
  bool _isPlaying = false;
  double _speed = 1.0;
  double _volume = 1.0;
  String? _loadedUrl;
  String? _loadedFile;
  String? _loadedAsset;
  String? _currentAudioId;

  Stream<AudioState> get stateStream => _stateController.stream;

  Stream<Duration> get positionStream => _positionController.stream;

  Stream<Duration?> get durationStream => _durationController.stream;

  bool get isPlaying => _isPlaying;

  Duration get position => _position;

  Duration? get duration => _duration;

  AudioState get currentState => _currentState;

  /// Alias for currentState - for compatibility with tests
  AudioState get state => _currentState;

  String? get currentAudioId => _currentAudioId;

  /// Get the URL that was loaded (for test verification)
  String? get loadedUrl => _loadedUrl;

  /// Get the file path that was loaded (for test verification)
  String? get loadedFile => _loadedFile;

  /// Get the asset path that was loaded (for test verification)
  String? get loadedAsset => _loadedAsset;

  /// Get the current playback speed (for test verification)
  double get speed => _speed;

  /// Get the current volume (for test verification)
  double get volumeLevel => _volume;

  void _setState(AudioState state) {
    _currentState = state;
    _stateController.add(state);
  }

  void _setPosition(Duration position) {
    _position = position;
    _positionController.add(position);
  }

  Future<Duration?> loadUrl(String url, {String? audioId}) async {
    _setState(AudioState.loading);
    _loadedUrl = url;
    _currentAudioId = audioId;
    _duration = const Duration(minutes: 3);
    _position = Duration.zero;
    _durationController.add(_duration);
    _setState(AudioState.idle);
    return _duration;
  }

  Future<Duration?> loadFile(String filePath, {String? audioId}) async {
    _setState(AudioState.loading);
    _loadedFile = filePath;
    _currentAudioId = audioId;
    _duration = const Duration(minutes: 2);
    _position = Duration.zero;
    _durationController.add(_duration);
    _setState(AudioState.idle);
    return _duration;
  }

  Future<Duration?> loadAsset(String assetPath, {String? audioId}) async {
    _setState(AudioState.loading);
    _loadedAsset = assetPath;
    _currentAudioId = audioId;
    _duration = const Duration(minutes: 1);
    _position = Duration.zero;
    _durationController.add(_duration);
    _setState(AudioState.idle);
    return _duration;
  }

  Future<void> play() async {
    _isPlaying = true;
    _setState(AudioState.playing);
  }

  Future<void> pause() async {
    _isPlaying = false;
    _setState(AudioState.paused);
  }

  Future<void> stop() async {
    _isPlaying = false;
    _position = Duration.zero;
    _currentAudioId = null;
    _setPosition(_position);
    _setState(AudioState.idle);
  }

  Future<void> seek(Duration position) async {
    final max = _duration ?? Duration.zero;
    if (position < Duration.zero) {
      _position = Duration.zero;
    } else if (position > max) {
      _position = max;
    } else {
      _position = position;
    }
    _setPosition(_position);
  }

  Future<void> skipForward(Duration duration) async {
    final newPosition = _position + duration;
    final max = _duration ?? Duration.zero;
    await seek(newPosition > max ? max : newPosition);
  }

  Future<void> skipBackward(Duration duration) async {
    final newPosition = _position - duration;
    await seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  Future<void> setSpeed(double speed) async {
    _speed = speed;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
  }

  Future<void> playUrl(String url, {String? audioId}) async {
    await loadUrl(url, audioId: audioId);
    await play();
  }

  Future<void> playFile(String filePath, {String? audioId}) async {
    await loadFile(filePath, audioId: audioId);
    await play();
  }

  String getFormattedPosition() {
    final minutes = _position.inMinutes;
    final seconds = _position.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getFormattedDuration() {
    final dur = _duration ?? Duration.zero;
    final minutes = dur.inMinutes;
    final seconds = dur.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double getProgress() {
    if (_duration == null || _duration!.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration!.inMilliseconds;
  }

  /// Simulate audio completion for testing
  void simulateCompletion() {
    _isPlaying = false;
    _position = _duration ?? Duration.zero;
    _setPosition(_position);
    _setState(AudioState.completed);
  }

  /// Simulate an error for testing
  void simulateError() {
    _isPlaying = false;
    _setState(AudioState.error);
  }

  /// Simulate a state change for testing
  void simulateStateChange(AudioState state) {
    if (state == AudioState.playing) {
      _isPlaying = true;
    } else if (state == AudioState.paused ||
        state == AudioState.idle ||
        state == AudioState.completed ||
        state == AudioState.error) {
      _isPlaying = false;
    }
    _setState(state);
  }

  /// Simulate a position update for testing
  void simulatePosition(Duration position) {
    _setPosition(position);
  }

  /// Reset state for testing
  void reset() {
    _isPlaying = false;
    _position = Duration.zero;
    _duration = null;
    _loadedUrl = null;
    _loadedFile = null;
    _loadedAsset = null;
    _speed = 1.0;
    _volume = 1.0;
    _setState(AudioState.idle);
  }

  Future<void> dispose() async {
    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
  }
}

/// Fake LocationService for testing that doesn't require actual GPS.
class FakeLocationService extends LocationService {
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();

  LocationPermission _permission = LocationPermission.whileInUse;
  bool _serviceEnabled = true;
  bool _isTracking = false;
  Position? _currentPosition;

  @override
  Stream<Position> get positionStream => _positionController.stream;

  /// Set the permission status for testing
  void setPermission(LocationPermission permission) {
    _permission = permission;
  }

  /// Set whether location services are enabled
  void setServiceEnabled(bool enabled) {
    _serviceEnabled = enabled;
  }

  /// Set the current position for testing
  void setCurrentPosition(Position position) {
    _currentPosition = position;
    if (_isTracking) {
      _positionController.add(position);
    }
  }

  /// Emit a position update for testing
  void emitPosition(Position position) {
    _currentPosition = position;
    _positionController.add(position);
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return _serviceEnabled;
  }

  @override
  Future<LocationPermission> checkPermission() async {
    return _permission;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    if (_permission == LocationPermission.denied) {
      // Simulate granting permission
      _permission = LocationPermission.whileInUse;
    }
    return _permission;
  }

  @override
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    if (!_serviceEnabled) return null;
    if (_permission == LocationPermission.denied ||
        _permission == LocationPermission.deniedForever) {
      return null;
    }
    return _currentPosition ?? _createDefaultPosition();
  }

  @override
  Future<bool> startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) async {
    if (!_serviceEnabled) return false;
    if (_permission == LocationPermission.denied ||
        _permission == LocationPermission.deniedForever) {
      return false;
    }
    _isTracking = true;
    return true;
  }

  @override
  void stopTracking() {
    _isTracking = false;
  }

  bool get isTracking => _isTracking;

  @override
  double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    // Use Haversine formula for approximate distance
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  @override
  double bearingBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }

  @override
  Future<bool> openLocationSettings() async {
    return true;
  }

  @override
  Future<bool> openAppSettings() async {
    return true;
  }

  Position _createDefaultPosition() {
    return Position(
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );
  }

  @override
  void dispose() {
    _positionController.close();
    super.dispose();
  }
}

/// Creates a Position object for testing
Position createTestPosition({
  double latitude = 37.7749,
  double longitude = -122.4194,
  double accuracy = 10.0,
  double altitude = 0.0,
  double heading = 0.0,
  double speed = 0.0,
  DateTime? timestamp,
}) {
  return Position(
    latitude: latitude,
    longitude: longitude,
    timestamp: timestamp ?? DateTime.now(),
    accuracy: accuracy,
    altitude: altitude,
    altitudeAccuracy: 0.0,
    heading: heading,
    headingAccuracy: 0.0,
    speed: speed,
    speedAccuracy: 0.0,
  );
}

/// Fake OfflineStorageService for testing that uses in-memory storage.
class FakeOfflineStorageService extends OfflineStorageService {
  // Store models directly instead of JSON to avoid serialization issues with GeoPoint
  final Map<String, ({TourModel tour, DateTime cachedAt})> _tours = {};
  final Map<String, ({TourVersionModel version, DateTime cachedAt})> _versions = {};
  final Map<String, ({List<StopModel> stops, DateTime cachedAt})> _stops = {};
  final Map<String, Map<String, dynamic>> _downloads = {};
  final Map<String, Map<String, dynamic>> _progress = {};
  final Map<String, dynamic> _settings = {};

  @override
  Future<void> initialize() async {
    // No-op for fake implementation
  }

  // Tours
  @override
  Future<void> cacheTour(TourModel tour) async {
    _tours[tour.id] = (tour: tour, cachedAt: DateTime.now());
  }

  @override
  TourModel? getCachedTour(String tourId) {
    final cached = _tours[tourId];
    if (cached == null) return null;

    // Check cache expiration (1 hour)
    if (DateTime.now().difference(cached.cachedAt).inHours > 1) {
      return null;
    }
    return cached.tour;
  }

  @override
  Future<void> clearTourCache() async {
    _tours.clear();
  }

  // Versions
  @override
  Future<void> cacheVersion(TourVersionModel version) async {
    final key = '${version.tourId}_${version.id}';
    _versions[key] = (version: version, cachedAt: DateTime.now());
  }

  @override
  TourVersionModel? getCachedVersion(String tourId, String versionId) {
    final key = '${tourId}_$versionId';
    final cached = _versions[key];
    if (cached == null) return null;
    return cached.version;
  }

  // Stops
  @override
  Future<void> cacheStops(String tourId, String versionId, List<StopModel> stops) async {
    final key = '${tourId}_$versionId';
    _stops[key] = (stops: stops, cachedAt: DateTime.now());
  }

  @override
  List<StopModel>? getCachedStops(String tourId, String versionId) {
    final key = '${tourId}_$versionId';
    final cached = _stops[key];
    if (cached == null) return null;
    return cached.stops;
  }

  // Downloads
  @override
  Future<void> startDownload(String tourId, String versionId) async {
    _downloads[tourId] = {
      'tourId': tourId,
      'versionId': versionId,
      'status': 'downloading',
      'progress': 0.0,
      'startedAt': DateTime.now().toIso8601String(),
      'fileSize': 0,
    };
  }

  @override
  Future<void> updateDownloadProgress(String tourId, double progress, {int? fileSize}) async {
    final data = _downloads[tourId];
    if (data == null) return;
    data['progress'] = progress;
    if (fileSize != null) data['fileSize'] = fileSize;
  }

  @override
  Future<void> completeDownload(String tourId, int fileSize) async {
    final data = _downloads[tourId];
    if (data == null) return;
    data['status'] = 'complete';
    data['progress'] = 1.0;
    data['fileSize'] = fileSize;
    data['completedAt'] = DateTime.now().toIso8601String();
    data['expiresAt'] = DateTime.now().add(const Duration(days: 30)).toIso8601String();
  }

  @override
  Future<void> failDownload(String tourId, String error) async {
    final data = _downloads[tourId];
    if (data == null) return;
    data['status'] = 'failed';
    data['error'] = error;
  }

  @override
  bool isDownloaded(String tourId) {
    final data = _downloads[tourId];
    if (data == null) return false;
    return data['status'] == 'complete';
  }

  @override
  Map<String, dynamic>? getDownloadStatus(String tourId) {
    return _downloads[tourId];
  }

  @override
  List<String> getDownloadedTourIds() {
    return _downloads.entries
        .where((e) => e.value['status'] == 'complete')
        .map((e) => e.key)
        .toList();
  }

  @override
  Future<void> deleteDownload(String tourId) async {
    _downloads.remove(tourId);
    _tours.remove(tourId);
    _versions.removeWhere((key, _) => key.startsWith('${tourId}_'));
    _stops.removeWhere((key, _) => key.startsWith('${tourId}_'));
  }

  // Progress
  @override
  Future<void> saveProgress({
    required String tourId,
    required String versionId,
    required int currentStopIndex,
    required List<int> completedStops,
    required String status,
  }) async {
    _progress[tourId] = {
      'tourId': tourId,
      'versionId': versionId,
      'currentStopIndex': currentStopIndex,
      'completedStops': completedStops,
      'status': status,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  @override
  Map<String, dynamic>? getProgress(String tourId) {
    return _progress[tourId];
  }

  @override
  Future<void> clearProgress(String tourId) async {
    _progress.remove(tourId);
  }

  @override
  List<String> getInProgressTourIds() {
    return _progress.entries
        .where((e) => e.value['status'] == 'in_progress')
        .map((e) => e.key)
        .toList();
  }

  // Settings
  @override
  Future<void> saveSetting(String key, dynamic value) async {
    _settings[key] = value;
  }

  @override
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settings[key] as T? ?? defaultValue;
  }

  @override
  Future<void> cleanupExpired() async {
    // No-op for fake
  }

  @override
  Future<int> getCacheSize() async {
    return 0;
  }

  @override
  Future<void> clearAll() async {
    _tours.clear();
    _versions.clear();
    _stops.clear();
    _downloads.clear();
    _progress.clear();
    _settings.clear();
  }

  @override
  Future<void> close() async {
    // No-op for fake
  }

  // ============================================================
  // Additional methods for integration testing
  // ============================================================

  final Set<String> _downloaded = {};
  final Set<String> _pendingSync = {};
  final Set<String> _expiredCache = {};
  final Map<String, TourProgress> _progressSimple = {};
  bool _readFailure = false;
  bool _writeFailure = false;

  /// Mark a tour as downloaded
  Future<void> markDownloaded(String tourId) async {
    _downloaded.add(tourId);
  }

  /// Check if cache is expired for a tour
  Future<bool> isCacheExpired(String tourId) async {
    return _expiredCache.contains(tourId);
  }

  /// Simulate cache expiration for testing
  void simulateCacheExpiration(String tourId) {
    _expiredCache.add(tourId);
  }

  /// Mark progress as pending sync
  Future<void> markProgressPendingSync(String tourId) async {
    _pendingSync.add(tourId);
  }

  /// Check if tour has pending sync
  Future<bool> hasPendingSync(String tourId) async {
    return _pendingSync.contains(tourId);
  }

  /// Clear pending sync for a tour
  Future<void> clearPendingSync(String tourId) async {
    _pendingSync.remove(tourId);
  }

  /// Get all tour IDs with pending sync
  Future<List<String>> getPendingSyncTourIds() async {
    return _pendingSync.toList();
  }

  /// Clear all cache (alias for clearAll)
  Future<void> clearAllCache() async {
    await clearAll();
    _downloaded.clear();
    _pendingSync.clear();
    _expiredCache.clear();
    _progressSimple.clear();
  }

  /// Simulate read failure for testing
  void simulateReadFailure() {
    _readFailure = true;
  }

  /// Clear read failure simulation
  void clearReadFailure() {
    _readFailure = false;
  }

  /// Simulate write failure for testing
  void simulateWriteFailure() {
    _writeFailure = true;
  }

  /// Clear write failure simulation
  void clearWriteFailure() {
    _writeFailure = false;
  }
}

/// Extended FakeOfflineStorageService for integration tests with simplified API.
/// This doesn't extend OfflineStorageService to allow simpler method signatures.
class FakeOfflineStorageServiceSimple {
  final Map<String, ({TourModel tour, DateTime cachedAt})> _tours = {};
  final Map<String, ({TourVersionModel version, DateTime cachedAt})> _versions = {};
  final Map<String, ({List<StopModel> stops, DateTime cachedAt})> _stops = {};
  final Map<String, TourProgress> _progress = {};
  final Set<String> _downloaded = {};
  final Set<String> _pendingSync = {};
  final Set<String> _expiredCache = {};
  bool _readFailure = false;
  bool _writeFailure = false;

  // Tours
  Future<void> cacheTour(TourModel tour) async {
    if (_writeFailure) throw Exception('Write failure');
    _tours[tour.id] = (tour: tour, cachedAt: DateTime.now());
    _expiredCache.remove(tour.id);
  }

  Future<TourModel?> getCachedTour(String tourId) async {
    if (_readFailure) throw Exception('Read failure');
    return _tours[tourId]?.tour;
  }

  // Versions - simplified signature (tourId, version)
  Future<void> cacheVersion(String tourId, TourVersionModel version) async {
    if (_writeFailure) throw Exception('Write failure');
    final key = '${tourId}_${version.id}';
    _versions[key] = (version: version, cachedAt: DateTime.now());
  }

  Future<TourVersionModel?> getCachedVersion(String tourId, String versionId) async {
    if (_readFailure) throw Exception('Read failure');
    final key = '${tourId}_$versionId';
    return _versions[key]?.version;
  }

  // Stops - simplified signature (tourId, stops)
  Future<void> cacheStops(String tourId, List<StopModel> stops) async {
    if (_writeFailure) throw Exception('Write failure');
    _stops[tourId] = (stops: stops, cachedAt: DateTime.now());
  }

  Future<List<StopModel>> getCachedStops(String tourId) async {
    if (_readFailure) throw Exception('Read failure');
    return _stops[tourId]?.stops ?? [];
  }

  // Download tracking
  Future<void> markDownloaded(String tourId) async {
    _downloaded.add(tourId);
  }

  Future<bool> isDownloaded(String tourId) async {
    return _downloaded.contains(tourId);
  }

  // Progress - simplified signature (Set instead of List)
  Future<void> saveProgress({
    required String tourId,
    required int currentStopIndex,
    required Set<int> completedStops,
  }) async {
    _progress[tourId] = TourProgress(
      currentStopIndex: currentStopIndex,
      completedStops: completedStops,
    );
  }

  Future<TourProgress?> getProgress(String tourId) async {
    return _progress[tourId];
  }

  // Sync management
  Future<void> markProgressPendingSync(String tourId) async {
    _pendingSync.add(tourId);
  }

  Future<bool> hasPendingSync(String tourId) async {
    return _pendingSync.contains(tourId);
  }

  Future<void> clearPendingSync(String tourId) async {
    _pendingSync.remove(tourId);
  }

  Future<List<String>> getPendingSyncTourIds() async {
    return _pendingSync.toList();
  }

  // Cache expiration
  Future<bool> isCacheExpired(String tourId) async {
    return _expiredCache.contains(tourId);
  }

  void simulateCacheExpiration(String tourId) {
    _expiredCache.add(tourId);
  }

  // Cache management
  Future<void> clearTourCache(String tourId) async {
    _tours.remove(tourId);
    _versions.removeWhere((key, _) => key.startsWith('${tourId}_'));
    _stops.remove(tourId);
    _expiredCache.remove(tourId);
    // Note: progress is preserved
  }

  Future<void> clearAllCache() async {
    _tours.clear();
    _versions.clear();
    _stops.clear();
    _downloaded.clear();
    _pendingSync.clear();
    _expiredCache.clear();
    _progress.clear();
  }

  // Error simulation
  void simulateReadFailure() {
    _readFailure = true;
  }

  void clearReadFailure() {
    _readFailure = false;
  }

  void simulateWriteFailure() {
    _writeFailure = true;
  }

  void clearWriteFailure() {
    _writeFailure = false;
  }
}

/// Simple progress tracking class for integration tests
class TourProgress {
  final int currentStopIndex;
  final Set<int> completedStops;

  TourProgress({
    required this.currentStopIndex,
    required this.completedStops,
  });
}

/// Fake ConnectivityService for testing network connectivity changes.
class FakeConnectivityService {
  final StreamController<bool> _onlineController =
      StreamController<bool>.broadcast();

  bool _isOnline = true;

  /// Stream of online status changes
  Stream<bool> get onlineStream => _onlineController.stream;

  /// Current online status
  bool get isOnline => _isOnline;

  /// Set the online status (for testing)
  void setOnline(bool online) {
    _isOnline = online;
    _onlineController.add(online);
  }

  /// Dispose resources
  void dispose() {
    _onlineController.close();
  }
}
