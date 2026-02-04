import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../../config/mapbox_config.dart';
import '../../../../../core/constants/route_names.dart';
import '../../../../../data/models/tour_model.dart';
import '../view_models/marketplace_view_model.dart';

class MarketplaceMapView extends ConsumerStatefulWidget {
  const MarketplaceMapView({super.key});

  @override
  ConsumerState<MarketplaceMapView> createState() => _MarketplaceMapViewState();
}

class _MarketplaceMapViewState extends ConsumerState<MarketplaceMapView> {
  MapboxMap? _mapboxMap;

  // IDs for map layers and sources
  static const String sourceId = "tours-source";
  static const String clusterLayerId = "tours-clusters";
  static const String clusterCountLayerId = "tours-cluster-count";
  static const String unclusteredLayerId = "tours-unclustered";

  @override
  Widget build(BuildContext context) {
    // Watch filtered tours to update map
    final toursAsync = ref.watch(marketplaceProvider.select((s) => s.filteredTours));

    // Listen to changes to update the source
    ref.listen(marketplaceProvider.select((s) => s.filteredTours), (previous, next) {
      next.whenData((tours) {
        _updateMapSource(tours);
      });
    });

    return Stack(
      children: [
        MapWidget(
          key: const ValueKey('marketplace_map'),
          resourceOptions: ResourceOptions(accessToken: MapboxConfig.accessToken),
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(MapboxConfig.defaultLongitude, MapboxConfig.defaultLatitude),
            ),
            zoom: 3.0, // Start zoomed out to see world
          ),
          styleUri: MapboxConfig.defaultStyle,
          onMapCreated: _onMapCreated,
          onTapListener: _onMapTapped,
        ),

        // Loading indicator overlay
        if (toursAsync.isLoading)
          const Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _setupMapLayers();
  }

  void _onMapTapped(MapContentGestureContext context) async {
    if (_mapboxMap == null) return;

    final point = context.touchPosition;

    try {
      // Query rendered features at the tapped point
      final features = await _mapboxMap!.queryRenderedFeatures(
        RenderedQueryGeometry(
          value: ScreenBox(
            min: ScreenCoordinate(x: point.x - 10, y: point.y - 10),
            max: ScreenCoordinate(x: point.x + 10, y: point.y + 10),
          ),
        ),
        RenderedQueryOptions(layerIds: [clusterLayerId, unclusteredLayerId]),
      );

      if (features.isEmpty) return;

      final feature = features.first;
      final properties = feature.queriedFeature.feature.properties;

      if (properties != null) {
        if (properties.containsKey('cluster') && properties['cluster'] == true) {
          // Cluster clicked - zoom in
          _handleClusterClick(feature);
        } else if (properties.containsKey('id')) {
          // Unclustered tour clicked - navigate to details
          final String tourId = properties['id'] as String;
          // Manually pushing route since context might be tricky in async callback,
          // but keeping it simple for now.
          if (mounted) {
            _navigateToTour(tourId);
          }
        }
      }
    } catch (e) {
      debugPrint("Error handling map tap: $e");
    }
  }

  void _navigateToTour(String tourId) {
    context.push(RouteNames.tourDetailsPath(tourId));
  }

  Future<void> _handleClusterClick(QueriedRenderedFeature feature) async {
    try {
      final camera = await _mapboxMap!.getCameraState();
      final geometry = feature.queriedFeature.feature.geometry;

      if (geometry != null && geometry.type == 'Point') {
        // Cast to Point if possible or just use current center with higher zoom
        // Geometry handling in mapbox_maps_flutter can be generic
        // For simplicity, we just zoom in at current camera center or tap location

        await _mapboxMap!.flyTo(
          CameraOptions(
            zoom: (camera.zoom + 2).clamp(0, 20),
            // If we could parse geometry safely we would set center here
          ),
          MapAnimationOptions(duration: 500),
        );
      }
    } catch (e) {
      debugPrint("Cluster click error: $e");
    }
  }

  Future<void> _setupMapLayers() async {
    if (_mapboxMap == null) return;

    // 1. Add GeoJSON Source with Clustering enabled
    final emptyGeoJson = jsonEncode({"type": "FeatureCollection", "features": []});

    await _mapboxMap!.style.addSource(
      GeoJsonSource(
        id: sourceId,
        data: emptyGeoJson,
        cluster: true,
        clusterMaxZoom: 14,
        clusterRadius: 50,
      ),
    );

    // 2. Add Layer for Clusters (Circles)
    await _mapboxMap!.style.addLayer(
      CircleLayer(
        id: clusterLayerId,
        sourceId: sourceId,
        circleColor: Colors.blue.value,
        circleRadius: 18.0,
        circleStrokeColor: Colors.white.value,
        circleStrokeWidth: 2.0,
        filter: ["has", "point_count"],
      ),
    );

    // 3. Add Layer for Cluster Counts (Text)
    await _mapboxMap!.style.addLayer(
      SymbolLayer(
        id: clusterCountLayerId,
        sourceId: sourceId,
        textField: "{point_count_abbreviated}",
        textSize: 12.0,
        textColor: Colors.white.value,
        filter: ["has", "point_count"],
      ),
    );

    // 4. Add Layer for Unclustered Points (Individual Tours)
    await _mapboxMap!.style.addLayer(
      CircleLayer(
        id: unclusteredLayerId,
        sourceId: sourceId,
        circleColor: Colors.redAccent.value,
        circleRadius: 8.0,
        circleStrokeWidth: 2.0,
        circleStrokeColor: Colors.white.value,
        filter: [
          "!",
          ["has", "point_count"],
        ],
      ),
    );

    // Initial load of data if available
    final tours = ref.read(marketplaceProvider).filteredTours.valueOrNull;
    if (tours != null) {
      _updateMapSource(tours);
    }
  }

  Future<void> _updateMapSource(List<TourModel> tours) async {
    if (_mapboxMap == null) return;

    final features =
        tours.map((tour) {
          return {
            "type": "Feature",
            "id": tour.id,
            "properties": {"id": tour.id, "title": tour.city ?? "Tour", "imageUrl": ""},
            "geometry": {
              "type": "Point",
              "coordinates": [tour.startLocation.longitude, tour.startLocation.latitude],
            },
          };
        }).toList();

    final geoJson = jsonEncode({"type": "FeatureCollection", "features": features});

    try {
      // Use style.setStyleSourceProperty to update data
      await _mapboxMap!.style.setStyleSourceProperty(sourceId, "data", geoJson);
    } catch (e) {
      debugPrint("Error updating map source: $e");
    }
  }
}
