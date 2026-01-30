import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../../../data/models/route_model.dart';
import '../../../../../data/models/waypoint_model.dart';
import '../../../../../data/repositories/route_repository.dart'
    show RouteRepository, routeRepositoryProvider;
import '../../../../../services/route_snapping_service.dart'
    show RouteSnappingService, routeSnappingServiceProvider;

/// State for the Route Editor
class RouteEditorState {
  final String? routeId;
  final String tourId;
  final String versionId;
  final List<WaypointModel> waypoints;
  final List<LatLng> polyline;
  final RouteSnapMode snapMode;
  final double totalDistance;
  final int estimatedDuration;
  final bool isLoading;
  final bool isSaving;
  final bool isSnapping;
  final String? error;
  final int? selectedWaypointIndex;
  final List<RouteEditorAction> undoStack;
  final List<RouteEditorAction> redoStack;
  final bool hasUnsavedChanges;

  const RouteEditorState({
    this.routeId,
    required this.tourId,
    required this.versionId,
    this.waypoints = const [],
    this.polyline = const [],
    this.snapMode = RouteSnapMode.roads,
    this.totalDistance = 0,
    this.estimatedDuration = 0,
    this.isLoading = false,
    this.isSaving = false,
    this.isSnapping = false,
    this.error,
    this.selectedWaypointIndex,
    this.undoStack = const [],
    this.redoStack = const [],
    this.hasUnsavedChanges = false,
  });

  RouteEditorState copyWith({
    String? routeId,
    String? tourId,
    String? versionId,
    List<WaypointModel>? waypoints,
    List<LatLng>? polyline,
    RouteSnapMode? snapMode,
    double? totalDistance,
    int? estimatedDuration,
    bool? isLoading,
    bool? isSaving,
    bool? isSnapping,
    String? error,
    int? selectedWaypointIndex,
    bool clearSelectedWaypoint = false,
    List<RouteEditorAction>? undoStack,
    List<RouteEditorAction>? redoStack,
    bool? hasUnsavedChanges,
  }) {
    return RouteEditorState(
      routeId: routeId ?? this.routeId,
      tourId: tourId ?? this.tourId,
      versionId: versionId ?? this.versionId,
      waypoints: waypoints ?? this.waypoints,
      polyline: polyline ?? this.polyline,
      snapMode: snapMode ?? this.snapMode,
      totalDistance: totalDistance ?? this.totalDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSnapping: isSnapping ?? this.isSnapping,
      error: error,
      selectedWaypointIndex: clearSelectedWaypoint ? null : (selectedWaypointIndex ?? this.selectedWaypointIndex),
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  /// Get the currently selected waypoint
  WaypointModel? get selectedWaypoint {
    if (selectedWaypointIndex == null ||
        selectedWaypointIndex! < 0 ||
        selectedWaypointIndex! >= waypoints.length) {
      return null;
    }
    return waypoints[selectedWaypointIndex!];
  }

  /// Check if the route has waypoints
  bool get hasWaypoints => waypoints.isNotEmpty;

  /// Check if the route has a polyline
  bool get hasPolyline => polyline.isNotEmpty;

  /// Get the number of stops (waypoints with content)
  int get stopCount => waypoints.where((w) => w.isStop).length;

  /// Check if snapping is enabled
  bool get isSnappingEnabled =>
      snapMode == RouteSnapMode.roads || snapMode == RouteSnapMode.walking;

  /// Check if undo is available
  bool get canUndo => undoStack.isNotEmpty;

  /// Check if redo is available
  bool get canRedo => redoStack.isNotEmpty;

  /// Get overlapping waypoint pairs
  List<(WaypointModel, WaypointModel)> get overlappingWaypoints {
    final overlaps = <(WaypointModel, WaypointModel)>[];
    for (var i = 0; i < waypoints.length; i++) {
      for (var j = i + 1; j < waypoints.length; j++) {
        if (waypoints[i].hasOverlapWith(waypoints[j])) {
          overlaps.add((waypoints[i], waypoints[j]));
        }
      }
    }
    return overlaps;
  }

  /// Check if any waypoints overlap
  bool get hasOverlappingWaypoints => overlappingWaypoints.isNotEmpty;

  /// Get indices of overlapping waypoints (for UI highlighting)
  Set<int> get overlappingWaypointIndices {
    final indices = <int>{};
    for (var i = 0; i < waypoints.length; i++) {
      for (var j = i + 1; j < waypoints.length; j++) {
        if (waypoints[i].hasOverlapWith(waypoints[j])) {
          indices.add(i);
          indices.add(j);
        }
      }
    }
    return indices;
  }

  /// Alias for hasUnsavedChanges for consistency
  bool get hasChanges => hasUnsavedChanges;

  /// Format distance for display
  String get distanceFormatted {
    if (totalDistance < 1000) {
      return '${totalDistance.toStringAsFixed(0)}m';
    }
    return '${(totalDistance / 1000).toStringAsFixed(1)}km';
  }

  /// Format duration for display
  String get durationFormatted {
    final hours = estimatedDuration ~/ 3600;
    final minutes = (estimatedDuration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}

/// Action types for undo/redo
enum RouteEditorActionType {
  addWaypoint,
  removeWaypoint,
  moveWaypoint,
  reorderWaypoints,
  updateTriggerRadius,
  changeSnapMode,
}

/// Represents an action for undo/redo
class RouteEditorAction {
  final RouteEditorActionType type;
  final List<WaypointModel> previousWaypoints;
  final List<LatLng> previousPolyline;
  final RouteSnapMode previousSnapMode;
  final double previousDistance;
  final int previousDuration;

  const RouteEditorAction({
    required this.type,
    required this.previousWaypoints,
    required this.previousPolyline,
    required this.previousSnapMode,
    required this.previousDistance,
    required this.previousDuration,
  });
}

/// Route Editor Notifier
class RouteEditorNotifier extends StateNotifier<RouteEditorState> {
  final RouteRepository _routeRepository;
  final RouteSnappingService _snappingService;
  final Uuid _uuid = const Uuid();

  RouteEditorNotifier({
    required String tourId,
    required String versionId,
    required RouteRepository routeRepository,
    required RouteSnappingService snappingService,
    String? routeId,
  })  : _routeRepository = routeRepository,
        _snappingService = snappingService,
        super(RouteEditorState(
          tourId: tourId,
          versionId: versionId,
          routeId: routeId,
        ));

  /// Initialize the editor with existing route data
  Future<void> initialize() async {
    if (state.routeId == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final route = await _routeRepository.get(
        versionId: state.versionId,
        routeId: state.routeId!,
      );

      if (route != null) {
        state = state.copyWith(
          waypoints: route.waypoints,
          polyline: route.routePolyline,
          snapMode: route.snapMode,
          totalDistance: route.totalDistance,
          estimatedDuration: route.estimatedDuration,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Route not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load route: $e',
      );
    }
  }

  /// Add a waypoint at the given location
  Future<void> addWaypoint(LatLng location, {String? name, WaypointType type = WaypointType.stop}) async {
    _saveUndoState(RouteEditorActionType.addWaypoint);

    final now = DateTime.now();
    final newWaypoint = WaypointModel(
      id: _uuid.v4(),
      routeId: state.routeId ?? '',
      order: state.waypoints.length,
      location: location,
      name: name ?? 'Stop ${state.waypoints.length + 1}',
      type: type,
      createdAt: now,
      updatedAt: now,
    );

    final updatedWaypoints = [...state.waypoints, newWaypoint];
    state = state.copyWith(
      waypoints: updatedWaypoints,
      hasUnsavedChanges: true,
      redoStack: [],
    );

    await _recalculateRoute();
  }

  /// Remove a waypoint by index
  Future<void> removeWaypoint(int index) async {
    if (index < 0 || index >= state.waypoints.length) return;

    _saveUndoState(RouteEditorActionType.removeWaypoint);

    final updatedWaypoints = [...state.waypoints];
    updatedWaypoints.removeAt(index);

    // Update order for remaining waypoints
    for (var i = index; i < updatedWaypoints.length; i++) {
      updatedWaypoints[i] = updatedWaypoints[i].copyWith(order: i);
    }

    state = state.copyWith(
      waypoints: updatedWaypoints,
      hasUnsavedChanges: true,
      redoStack: [],
      clearSelectedWaypoint: state.selectedWaypointIndex == index,
    );

    await _recalculateRoute();
  }

  /// Move a waypoint to a new position
  Future<void> moveWaypoint(int index, LatLng newLocation) async {
    if (index < 0 || index >= state.waypoints.length) return;

    _saveUndoState(RouteEditorActionType.moveWaypoint);

    final updatedWaypoints = [...state.waypoints];
    updatedWaypoints[index] = updatedWaypoints[index].copyWith(
      location: newLocation,
      manualPosition: true,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      waypoints: updatedWaypoints,
      hasUnsavedChanges: true,
      redoStack: [],
    );

    await _recalculateRoute();
  }

  /// Reorder waypoints (drag and drop)
  Future<void> reorderWaypoints(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= state.waypoints.length) return;
    if (newIndex < 0 || newIndex > state.waypoints.length) return;

    _saveUndoState(RouteEditorActionType.reorderWaypoints);

    final updatedWaypoints = [...state.waypoints];
    final waypoint = updatedWaypoints.removeAt(oldIndex);

    // Adjust newIndex if needed after removal
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    updatedWaypoints.insert(adjustedNewIndex, waypoint);

    // Update order for all waypoints
    for (var i = 0; i < updatedWaypoints.length; i++) {
      updatedWaypoints[i] = updatedWaypoints[i].copyWith(order: i);
    }

    state = state.copyWith(
      waypoints: updatedWaypoints,
      hasUnsavedChanges: true,
      redoStack: [],
    );

    await _recalculateRoute();
  }

  /// Update trigger radius for a waypoint
  void updateTriggerRadius(int index, int radius) {
    if (index < 0 || index >= state.waypoints.length) return;

    _saveUndoState(RouteEditorActionType.updateTriggerRadius);

    final updatedWaypoints = [...state.waypoints];
    updatedWaypoints[index] = updatedWaypoints[index].copyWith(
      triggerRadius: radius,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      waypoints: updatedWaypoints,
      hasUnsavedChanges: true,
      redoStack: [],
    );
  }

  /// Update waypoint name
  void updateWaypointName(int index, String name) {
    if (index < 0 || index >= state.waypoints.length) return;

    final updatedWaypoints = [...state.waypoints];
    updatedWaypoints[index] = updatedWaypoints[index].copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      waypoints: updatedWaypoints,
      hasUnsavedChanges: true,
    );
  }

  /// Update waypoint type
  void updateWaypointType(int index, WaypointType type) {
    if (index < 0 || index >= state.waypoints.length) return;

    final updatedWaypoints = [...state.waypoints];
    updatedWaypoints[index] = updatedWaypoints[index].copyWith(
      type: type,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(
      waypoints: updatedWaypoints,
      hasUnsavedChanges: true,
    );
  }

  /// Select a waypoint
  void selectWaypoint(int? index) {
    if (index != null && (index < 0 || index >= state.waypoints.length)) {
      return;
    }
    state = state.copyWith(
      selectedWaypointIndex: index,
      clearSelectedWaypoint: index == null,
    );
  }

  /// Toggle snap mode
  Future<void> setSnapMode(RouteSnapMode mode) async {
    if (state.snapMode == mode) return;

    _saveUndoState(RouteEditorActionType.changeSnapMode);

    state = state.copyWith(
      snapMode: mode,
      hasUnsavedChanges: true,
      redoStack: [],
    );

    await _recalculateRoute();
  }

  /// Recalculate the route based on waypoints and snap mode
  Future<void> _recalculateRoute() async {
    if (state.waypoints.length < 2) {
      state = state.copyWith(
        polyline: [],
        totalDistance: 0,
        estimatedDuration: 0,
      );
      return;
    }

    state = state.copyWith(isSnapping: true, error: null);

    try {
      final result = await _snappingService.snapToRoads(
        waypoints: state.waypoints,
        mode: state.snapMode,
      );

      if (result.hasError) {
        state = state.copyWith(
          isSnapping: false,
          error: result.errorMessage,
        );
        return;
      }

      state = state.copyWith(
        polyline: result.snappedPolyline,
        totalDistance: result.totalDistance,
        estimatedDuration: result.estimatedDuration,
        isSnapping: false,
      );
    } catch (e) {
      // Fallback to direct line if snapping fails
      final directResult = _calculateDirectRoute();
      state = state.copyWith(
        polyline: directResult.polyline,
        totalDistance: directResult.distance,
        estimatedDuration: directResult.duration,
        isSnapping: false,
        error: 'Route snapping failed, showing direct path',
      );
    }
  }

  /// Calculate a direct line route (fallback)
  ({List<LatLng> polyline, double distance, int duration}) _calculateDirectRoute() {
    if (state.waypoints.length < 2) {
      return (polyline: <LatLng>[], distance: 0.0, duration: 0);
    }

    final polyline = state.waypoints.map((w) => w.location).toList();
    final distanceCalc = const Distance();
    var totalDistance = 0.0;

    for (var i = 0; i < polyline.length - 1; i++) {
      totalDistance += distanceCalc.as(
        LengthUnit.Meter,
        polyline[i],
        polyline[i + 1],
      );
    }

    // Estimate 5 km/h walking speed
    final duration = (totalDistance / 5000 * 3600).round();

    return (polyline: polyline, distance: totalDistance, duration: duration);
  }

  /// Clear all waypoints
  Future<void> clearRoute() async {
    _saveUndoState(RouteEditorActionType.removeWaypoint);

    state = state.copyWith(
      waypoints: [],
      polyline: [],
      totalDistance: 0,
      estimatedDuration: 0,
      hasUnsavedChanges: true,
      redoStack: [],
      clearSelectedWaypoint: true,
    );
  }

  /// Undo the last action
  Future<void> undo() async {
    if (!state.canUndo) return;

    final lastAction = state.undoStack.last;
    final newUndoStack = [...state.undoStack]..removeLast();

    // Save current state to redo stack
    final redoAction = RouteEditorAction(
      type: lastAction.type,
      previousWaypoints: state.waypoints,
      previousPolyline: state.polyline,
      previousSnapMode: state.snapMode,
      previousDistance: state.totalDistance,
      previousDuration: state.estimatedDuration,
    );

    state = state.copyWith(
      waypoints: lastAction.previousWaypoints,
      polyline: lastAction.previousPolyline,
      snapMode: lastAction.previousSnapMode,
      totalDistance: lastAction.previousDistance,
      estimatedDuration: lastAction.previousDuration,
      undoStack: newUndoStack,
      redoStack: [...state.redoStack, redoAction],
      hasUnsavedChanges: true,
    );
  }

  /// Redo the last undone action
  Future<void> redo() async {
    if (!state.canRedo) return;

    final lastAction = state.redoStack.last;
    final newRedoStack = [...state.redoStack]..removeLast();

    // Save current state to undo stack
    final undoAction = RouteEditorAction(
      type: lastAction.type,
      previousWaypoints: state.waypoints,
      previousPolyline: state.polyline,
      previousSnapMode: state.snapMode,
      previousDistance: state.totalDistance,
      previousDuration: state.estimatedDuration,
    );

    state = state.copyWith(
      waypoints: lastAction.previousWaypoints,
      polyline: lastAction.previousPolyline,
      snapMode: lastAction.previousSnapMode,
      totalDistance: lastAction.previousDistance,
      estimatedDuration: lastAction.previousDuration,
      undoStack: [...state.undoStack, undoAction],
      redoStack: newRedoStack,
      hasUnsavedChanges: true,
    );
  }

  /// Save undo state before an action
  void _saveUndoState(RouteEditorActionType type) {
    final action = RouteEditorAction(
      type: type,
      previousWaypoints: state.waypoints,
      previousPolyline: state.polyline,
      previousSnapMode: state.snapMode,
      previousDistance: state.totalDistance,
      previousDuration: state.estimatedDuration,
    );

    // Limit undo stack to 50 actions
    var newUndoStack = [...state.undoStack, action];
    if (newUndoStack.length > 50) {
      newUndoStack = newUndoStack.sublist(newUndoStack.length - 50);
    }

    state = state.copyWith(undoStack: newUndoStack);
  }

  /// Save the route to Firestore
  Future<bool> save() async {
    if (state.waypoints.isEmpty) {
      state = state.copyWith(error: 'Cannot save an empty route');
      return false;
    }

    state = state.copyWith(isSaving: true, error: null);

    try {
      final now = DateTime.now();
      final route = RouteModel(
        id: state.routeId ?? _uuid.v4(),
        tourId: state.tourId,
        versionId: state.versionId,
        waypoints: state.waypoints,
        routePolyline: state.polyline,
        snapMode: state.snapMode,
        totalDistance: state.totalDistance,
        estimatedDuration: state.estimatedDuration,
        createdAt: now,
        updatedAt: now,
      );

      if (state.routeId == null) {
        final newRoute = await _routeRepository.create(
          tourId: state.tourId,
          versionId: state.versionId,
          route: route,
        );
        state = state.copyWith(
          routeId: newRoute.id,
          isSaving: false,
          hasUnsavedChanges: false,
        );
      } else {
        await _routeRepository.update(
          versionId: state.versionId,
          routeId: state.routeId!,
          route: route,
        );
        state = state.copyWith(
          isSaving: false,
          hasUnsavedChanges: false,
        );
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to save route: $e',
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for route editor state
final routeEditorProvider = StateNotifierProvider.autoDispose.family<
    RouteEditorNotifier,
    RouteEditorState,
    ({String tourId, String versionId, String? routeId})>((ref, params) {
  final routeRepository = ref.watch(routeRepositoryProvider);
  final snappingService = ref.watch(routeSnappingServiceProvider);

  return RouteEditorNotifier(
    tourId: params.tourId,
    versionId: params.versionId,
    routeId: params.routeId,
    routeRepository: routeRepository,
    snappingService: snappingService,
  );
});
