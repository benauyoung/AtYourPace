import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'location_service.dart';

/// Provider for the geofence service
final geofenceServiceProvider = Provider<GeofenceService>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return GeofenceService(locationService);
});

/// Provider for geofence events stream
final geofenceEventsProvider = StreamProvider<GeofenceEvent>((ref) {
  final geofenceService = ref.watch(geofenceServiceProvider);
  return geofenceService.eventStream;
});

/// Represents a geofence region
class Geofence {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final Map<String, dynamic>? data;

  const Geofence({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.data,
  });

  /// Calculate distance from a position to the geofence center
  double distanceFrom(double lat, double lng) {
    return Geolocator.distanceBetween(latitude, longitude, lat, lng);
  }

  /// Check if a position is inside this geofence
  bool contains(double lat, double lng) {
    return distanceFrom(lat, lng) <= radiusMeters;
  }
}

/// Types of geofence events
enum GeofenceEventType {
  enter,
  exit,
  dwell,
}

/// Represents a geofence event
class GeofenceEvent {
  final Geofence geofence;
  final GeofenceEventType type;
  final Position position;
  final DateTime timestamp;

  const GeofenceEvent({
    required this.geofence,
    required this.type,
    required this.position,
    required this.timestamp,
  });
}

/// Service for managing geofences and detecting enter/exit events
class GeofenceService {
  final LocationService _locationService;

  final StreamController<GeofenceEvent> _eventController =
      StreamController<GeofenceEvent>.broadcast();

  final Map<String, Geofence> _geofences = {};
  final Set<String> _insideGeofences = {};
  final Map<String, DateTime> _dwellTimers = {};

  StreamSubscription<Position>? _positionSubscription;
  bool _isMonitoring = false;

  /// Duration to trigger dwell event (default 30 seconds)
  Duration dwellDuration = const Duration(seconds: 30);

  GeofenceService(this._locationService);

  /// Stream of geofence events
  Stream<GeofenceEvent> get eventStream => _eventController.stream;

  /// Whether geofencing is currently active
  bool get isMonitoring => _isMonitoring;

  /// List of currently registered geofences
  List<Geofence> get geofences => _geofences.values.toList();

  /// IDs of geofences the user is currently inside
  Set<String> get insideGeofences => Set.from(_insideGeofences);

  /// Add a geofence to monitor
  void addGeofence(Geofence geofence) {
    _geofences[geofence.id] = geofence;
  }

  /// Add multiple geofences
  void addGeofences(List<Geofence> geofences) {
    for (final geofence in geofences) {
      _geofences[geofence.id] = geofence;
    }
  }

  /// Remove a geofence
  void removeGeofence(String id) {
    _geofences.remove(id);
    _insideGeofences.remove(id);
    _dwellTimers.remove(id);
  }

  /// Clear all geofences
  void clearGeofences() {
    _geofences.clear();
    _insideGeofences.clear();
    _dwellTimers.clear();
  }

  /// Start monitoring geofences
  Future<bool> startMonitoring({
    int distanceFilter = 5,
  }) async {
    if (_isMonitoring) return true;

    final started = await _locationService.startTracking(
      distanceFilter: distanceFilter,
    );

    if (!started) return false;

    _positionSubscription = _locationService.positionStream.listen(
      _onPositionUpdate,
    );

    _isMonitoring = true;
    return true;
  }

  /// Stop monitoring geofences
  void stopMonitoring() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationService.stopTracking();
    _isMonitoring = false;
    _insideGeofences.clear();
    _dwellTimers.clear();
  }

  /// Check geofences against a specific position
  void checkPosition(Position position) {
    _onPositionUpdate(position);
  }

  void _onPositionUpdate(Position position) {
    final now = DateTime.now();

    for (final geofence in _geofences.values) {
      final isInside = geofence.contains(position.latitude, position.longitude);
      final wasInside = _insideGeofences.contains(geofence.id);

      if (isInside && !wasInside) {
        // Enter event
        _insideGeofences.add(geofence.id);
        _dwellTimers[geofence.id] = now;

        _eventController.add(GeofenceEvent(
          geofence: geofence,
          type: GeofenceEventType.enter,
          position: position,
          timestamp: now,
        ));
      } else if (!isInside && wasInside) {
        // Exit event
        _insideGeofences.remove(geofence.id);
        _dwellTimers.remove(geofence.id);

        _eventController.add(GeofenceEvent(
          geofence: geofence,
          type: GeofenceEventType.exit,
          position: position,
          timestamp: now,
        ));
      } else if (isInside && wasInside) {
        // Check for dwell
        final enteredAt = _dwellTimers[geofence.id];
        if (enteredAt != null && now.difference(enteredAt) >= dwellDuration) {
          // Dwell event - only trigger once
          _dwellTimers.remove(geofence.id);

          _eventController.add(GeofenceEvent(
            geofence: geofence,
            type: GeofenceEventType.dwell,
            position: position,
            timestamp: now,
          ));
        }
      }
    }
  }

  /// Get the nearest geofence and distance
  ({Geofence geofence, double distance})? getNearestGeofence(
    double lat,
    double lng,
  ) {
    if (_geofences.isEmpty) return null;

    Geofence? nearest;
    double minDistance = double.infinity;

    for (final geofence in _geofences.values) {
      final distance = geofence.distanceFrom(lat, lng);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = geofence;
      }
    }

    if (nearest == null) return null;
    return (geofence: nearest, distance: minDistance);
  }

  /// Get all geofences within a certain distance
  List<({Geofence geofence, double distance})> getGeofencesWithinDistance(
    double lat,
    double lng,
    double maxDistance,
  ) {
    final results = <({Geofence geofence, double distance})>[];

    for (final geofence in _geofences.values) {
      final distance = geofence.distanceFrom(lat, lng);
      if (distance <= maxDistance) {
        results.add((geofence: geofence, distance: distance));
      }
    }

    results.sort((a, b) => a.distance.compareTo(b.distance));
    return results;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _eventController.close();
  }
}
