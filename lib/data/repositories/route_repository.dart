import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_constants.dart';
import '../models/route_model.dart';
import '../models/waypoint_model.dart';

/// Repository for managing route data including waypoints.
class RouteRepository {
  final FirebaseFirestore _firestore;

  RouteRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Gets the route document reference.
  DocumentReference<Map<String, dynamic>> _routeRef(
    String versionId,
    String routeId,
  ) {
    return _firestore
        .collection(FirestoreCollections.versions)
        .doc(versionId)
        .collection(FirestoreCollections.routes)
        .doc(routeId);
  }

  /// Gets the routes collection reference for a version.
  CollectionReference<Map<String, dynamic>> _routesCollectionRef(
    String versionId,
  ) {
    return _firestore
        .collection(FirestoreCollections.versions)
        .doc(versionId)
        .collection(FirestoreCollections.routes);
  }

  /// Gets the waypoints collection reference for a route.
  CollectionReference<Map<String, dynamic>> _waypointsCollectionRef(
    String versionId,
    String routeId,
  ) {
    return _routeRef(versionId, routeId)
        .collection(FirestoreCollections.waypoints);
  }

  /// Creates a new route with waypoints.
  Future<RouteModel> create({
    required String tourId,
    required String versionId,
    required RouteModel route,
  }) async {
    final docRef = _routesCollectionRef(versionId).doc();
    final now = DateTime.now();

    final routeWithId = route.copyWith(
      id: docRef.id,
      tourId: tourId,
      versionId: versionId,
      createdAt: now,
      updatedAt: now,
    );

    final batch = _firestore.batch();

    // Save route document (without embedded waypoints for Firestore)
    final routeData = routeWithId.toFirestore();
    routeData.remove('waypoints'); // Store waypoints in subcollection
    batch.set(docRef, routeData);

    // Save waypoints as subcollection
    for (final waypoint in routeWithId.waypoints) {
      final waypointRef = _waypointsCollectionRef(versionId, docRef.id).doc();
      final waypointWithId = waypoint.copyWith(
        id: waypointRef.id,
        routeId: docRef.id,
        createdAt: now,
        updatedAt: now,
      );
      batch.set(waypointRef, waypointWithId.toJson());
    }

    await batch.commit();
    return routeWithId;
  }

  /// Gets a route with all its waypoints.
  Future<RouteModel?> get({
    required String versionId,
    required String routeId,
  }) async {
    final doc = await _routeRef(versionId, routeId).get();
    if (!doc.exists) return null;

    final routeData = doc.data()!;
    routeData['id'] = doc.id;

    // Load waypoints from subcollection
    final waypointsSnapshot = await _waypointsCollectionRef(versionId, routeId)
        .orderBy('order')
        .get();

    final waypoints = waypointsSnapshot.docs.map((waypointDoc) {
      return WaypointModel.fromFirestore(waypointDoc);
    }).toList();

    return RouteModel.fromJson({
      ...routeData,
      'waypoints': waypoints.map((w) => w.toJson()).toList(),
    });
  }

  /// Gets the route for a tour version (usually one per version).
  Future<RouteModel?> getRouteForVersion(String versionId) async {
    final snapshot = await _routesCollectionRef(versionId).limit(1).get();
    if (snapshot.docs.isEmpty) return null;

    final routeId = snapshot.docs.first.id;
    return get(versionId: versionId, routeId: routeId);
  }

  /// Updates a route and optionally its waypoints.
  Future<RouteModel> update({
    required String versionId,
    required String routeId,
    required RouteModel route,
    bool updateWaypoints = true,
  }) async {
    final updated = route.copyWith(
      updatedAt: DateTime.now(),
    );

    final batch = _firestore.batch();

    // Update route document
    final routeData = updated.toFirestore();
    routeData.remove('waypoints');
    batch.update(_routeRef(versionId, routeId), routeData);

    if (updateWaypoints) {
      // Delete existing waypoints
      final existingWaypoints =
          await _waypointsCollectionRef(versionId, routeId).get();
      for (final doc in existingWaypoints.docs) {
        batch.delete(doc.reference);
      }

      // Add new waypoints
      for (final waypoint in updated.waypoints) {
        final waypointRef = _waypointsCollectionRef(versionId, routeId).doc();
        final waypointWithId = waypoint.copyWith(
          id: waypointRef.id,
          routeId: routeId,
          updatedAt: DateTime.now(),
        );
        batch.set(waypointRef, waypointWithId.toJson());
      }
    }

    await batch.commit();
    return updated;
  }

  /// Updates route metadata without touching waypoints.
  Future<void> updateMetadata({
    required String versionId,
    required String routeId,
    required Map<String, dynamic> metadata,
  }) async {
    await _routeRef(versionId, routeId).update({
      'metadata': metadata,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates route statistics (distance, duration).
  Future<void> updateStatistics({
    required String versionId,
    required String routeId,
    required double totalDistance,
    required int estimatedDuration,
  }) async {
    await _routeRef(versionId, routeId).update({
      'totalDistance': totalDistance,
      'estimatedDuration': estimatedDuration,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates the route polyline.
  Future<void> updatePolyline({
    required String versionId,
    required String routeId,
    required List<LatLng> polyline,
  }) async {
    final polylineData = polyline
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList();

    await _routeRef(versionId, routeId).update({
      'routePolyline': polylineData,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates snap mode for the route.
  Future<void> updateSnapMode({
    required String versionId,
    required String routeId,
    required RouteSnapMode snapMode,
  }) async {
    await _routeRef(versionId, routeId).update({
      'snapMode': snapMode.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a route and all its waypoints.
  Future<void> delete({
    required String versionId,
    required String routeId,
  }) async {
    final batch = _firestore.batch();

    // Delete all waypoints
    final waypoints = await _waypointsCollectionRef(versionId, routeId).get();
    for (final doc in waypoints.docs) {
      batch.delete(doc.reference);
    }

    // Delete route
    batch.delete(_routeRef(versionId, routeId));

    await batch.commit();
  }

  // ==================== Waypoint Operations ====================

  /// Adds a waypoint to a route.
  Future<WaypointModel> addWaypoint({
    required String versionId,
    required String routeId,
    required WaypointModel waypoint,
  }) async {
    final docRef = _waypointsCollectionRef(versionId, routeId).doc();
    final now = DateTime.now();

    final waypointWithId = waypoint.copyWith(
      id: docRef.id,
      routeId: routeId,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(waypointWithId.toJson());

    // Update route timestamp
    await _routeRef(versionId, routeId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return waypointWithId;
  }

  /// Updates a waypoint.
  Future<WaypointModel> updateWaypoint({
    required String versionId,
    required String routeId,
    required String waypointId,
    required WaypointModel waypoint,
  }) async {
    final updated = waypoint.copyWith(
      updatedAt: DateTime.now(),
    );

    await _waypointsCollectionRef(versionId, routeId)
        .doc(waypointId)
        .update(updated.toJson());

    // Update route timestamp
    await _routeRef(versionId, routeId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return updated;
  }

  /// Updates waypoint position.
  Future<void> updateWaypointPosition({
    required String versionId,
    required String routeId,
    required String waypointId,
    required LatLng location,
    bool manualPosition = false,
  }) async {
    await _waypointsCollectionRef(versionId, routeId).doc(waypointId).update({
      'location': {'lat': location.latitude, 'lng': location.longitude},
      'manualPosition': manualPosition,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates waypoint trigger radius.
  Future<void> updateWaypointTriggerRadius({
    required String versionId,
    required String routeId,
    required String waypointId,
    required int triggerRadius,
  }) async {
    await _waypointsCollectionRef(versionId, routeId).doc(waypointId).update({
      'triggerRadius': triggerRadius,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates waypoint order (for reordering).
  Future<void> updateWaypointOrder({
    required String versionId,
    required String routeId,
    required String waypointId,
    required int order,
  }) async {
    await _waypointsCollectionRef(versionId, routeId).doc(waypointId).update({
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reorders all waypoints.
  Future<void> reorderWaypoints({
    required String versionId,
    required String routeId,
    required List<String> waypointIds,
  }) async {
    final batch = _firestore.batch();

    for (var i = 0; i < waypointIds.length; i++) {
      final ref =
          _waypointsCollectionRef(versionId, routeId).doc(waypointIds[i]);
      batch.update(ref, {
        'order': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // Update route timestamp
    batch.update(_routeRef(versionId, routeId), {
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Deletes a waypoint.
  Future<void> deleteWaypoint({
    required String versionId,
    required String routeId,
    required String waypointId,
  }) async {
    await _waypointsCollectionRef(versionId, routeId)
        .doc(waypointId)
        .delete();

    // Update route timestamp
    await _routeRef(versionId, routeId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Gets all waypoints for a route.
  Future<List<WaypointModel>> getWaypoints({
    required String versionId,
    required String routeId,
  }) async {
    final snapshot = await _waypointsCollectionRef(versionId, routeId)
        .orderBy('order')
        .get();

    return snapshot.docs.map((doc) => WaypointModel.fromFirestore(doc)).toList();
  }

  /// Watches route changes.
  Stream<RouteModel?> watchRoute({
    required String versionId,
    required String routeId,
  }) {
    return _routeRef(versionId, routeId).snapshots().asyncMap((doc) async {
      if (!doc.exists) return null;
      return get(versionId: versionId, routeId: doc.id);
    });
  }

  /// Watches waypoint changes.
  Stream<List<WaypointModel>> watchWaypoints({
    required String versionId,
    required String routeId,
  }) {
    return _waypointsCollectionRef(versionId, routeId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => WaypointModel.fromFirestore(doc)).toList();
    });
  }
}
