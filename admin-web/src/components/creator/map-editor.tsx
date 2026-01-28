'use client';

import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { findSegmentIndex, useRouteCalculation } from '@/hooks/use-route-calculation';
import {
  DEFAULT_MAP_CONFIG,
  MAP_STYLES,
  MAPBOX_TOKEN,
  MapStyleKey,
  MARKER_COLORS,
  ROUTE_LINE_STYLE,
} from '@/lib/mapbox/config';
import { snapToRoad } from '@/lib/mapbox/geocoding';
import { GeoPoint, StopModel } from '@/types';
import { AlertCircle, Layers, Loader2, Locate, Navigation, Plus, ZoomIn, ZoomOut } from 'lucide-react';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import { useCallback, useEffect, useRef, useState } from 'react';

// Set the token globally
mapboxgl.accessToken = MAPBOX_TOKEN;

interface MapEditorProps {
  stops: StopModel[];
  selectedStopId: string | null;
  onStopSelect: (stopId: string | null) => void;
  onStopAdd: (location: GeoPoint, name: string) => void;
  onStopMove: (stopId: string, location: GeoPoint) => void;
  centerLocation?: GeoPoint;
  isAddMode?: boolean;
  onAddModeChange?: (isAddMode: boolean) => void;
  tourType?: 'walking' | 'driving';
}

export function MapEditor({
  stops,
  selectedStopId,
  onStopSelect,
  onStopAdd,
  onStopMove,
  centerLocation,
  isAddMode = false,
  onAddModeChange,
  tourType = 'walking',
}: MapEditorProps) {
  const mapContainer = useRef<HTMLDivElement>(null);
  const mapRef = useRef<mapboxgl.Map | null>(null);
  const markersRef = useRef<Map<string, mapboxgl.Marker>>(new Map());
  const waypointMarkersRef = useRef<Map<string, mapboxgl.Marker>>(new Map());
  const isAddModeRef = useRef(isAddMode);
  const stopsRef = useRef(stops);
  const [mapStyle, setMapStyle] = useState<MapStyleKey>('streets');
  const [isMapLoaded, setIsMapLoaded] = useState(false);
  const [snapToRoads, setSnapToRoads] = useState<boolean>(() => {
    // Load preference from localStorage
    if (typeof window !== 'undefined') {
      const saved = localStorage.getItem('mapEditor_snapToRoads');
      return saved === 'true';
    }
    return false;
  });
  const [isSnapping, setIsSnapping] = useState(false);
  const snapToRoadsRef = useRef(snapToRoads);
  const routeGeometryRef = useRef<GeoJSON.LineString | null>(null);
  const stopsForRadiusRef = useRef<StopModel[]>([]);
  const draggingStopIdRef = useRef<string | null>(null);
  const dragDebounceRef = useRef<NodeJS.Timeout | null>(null);

  // Route calculation hook
  const {
    geometry: routeGeometry,
    routeInfo,
    isCalculating,
    error: routeError,
    waypoints,
    addWaypoint,
    updateWaypoint,
    removeWaypoint,
  } = useRouteCalculation(stops, tourType);

  // Save snap preference to localStorage
  useEffect(() => {
    localStorage.setItem('mapEditor_snapToRoads', snapToRoads.toString());
  }, [snapToRoads]);

  // Keep refs in sync with props for use in event handlers
  useEffect(() => {
    isAddModeRef.current = isAddMode;
  }, [isAddMode]);

  useEffect(() => {
    stopsRef.current = stops;
  }, [stops]);

  useEffect(() => {
    snapToRoadsRef.current = snapToRoads;
  }, [snapToRoads]);

  // Keep refs in sync for style reload
  useEffect(() => {
    routeGeometryRef.current = routeGeometry;
  }, [routeGeometry]);

  useEffect(() => {
    stopsForRadiusRef.current = stops;
  }, [stops]);

  // Helper function to add map sources and layers
  const addMapSourcesAndLayers = useCallback((map: mapboxgl.Map) => {
    // Add route line source
    if (!map.getSource('route')) {
      map.addSource('route', {
        type: 'geojson',
        data: {
          type: 'Feature',
          properties: {},
          geometry: routeGeometryRef.current || {
            type: 'LineString',
            coordinates: [],
          },
        },
      });
    }

    // Add route line layer
    if (!map.getLayer('route-line')) {
      map.addLayer({
        id: 'route-line',
        type: 'line',
        source: 'route',
        layout: {
          'line-join': 'round',
          'line-cap': 'round',
        },
        paint: {
          'line-color': ROUTE_LINE_STYLE.color,
          'line-width': ROUTE_LINE_STYLE.width,
          'line-opacity': ROUTE_LINE_STYLE.opacity,
        },
      });
    }

    // Add trigger radius source
    if (!map.getSource('trigger-radius')) {
      map.addSource('trigger-radius', {
        type: 'geojson',
        data: {
          type: 'FeatureCollection',
          features: [],
        },
      });
    }

    // Add trigger radius fill layer
    if (!map.getLayer('trigger-radius-fill')) {
      map.addLayer({
        id: 'trigger-radius-fill',
        type: 'fill',
        source: 'trigger-radius',
        paint: {
          'fill-color': MARKER_COLORS.default,
          'fill-opacity': 0.1,
        },
      });
    }

    // Add trigger radius stroke layer
    if (!map.getLayer('trigger-radius-stroke')) {
      map.addLayer({
        id: 'trigger-radius-stroke',
        type: 'line',
        source: 'trigger-radius',
        paint: {
          'line-color': MARKER_COLORS.default,
          'line-width': 2,
          'line-opacity': 0.5,
          'line-dasharray': [2, 2],
        },
      });
    }
  }, []);

  // Initialize map
  useEffect(() => {
    if (!mapContainer.current || mapRef.current) return;

    const center = centerLocation
      ? [centerLocation.longitude, centerLocation.latitude] as [number, number]
      : DEFAULT_MAP_CONFIG.center;

    const map = new mapboxgl.Map({
      container: mapContainer.current,
      style: MAP_STYLES[mapStyle],
      center,
      zoom: DEFAULT_MAP_CONFIG.zoom,
    });

    console.log('[MapEditor] Initializing map with:', {
      container: mapContainer.current?.getBoundingClientRect(),
      style: MAP_STYLES[mapStyle],
      center,
      tokenExists: !!MAPBOX_TOKEN
    });

    map.addControl(new mapboxgl.NavigationControl(), 'bottom-right');

    map.on('load', () => {
      console.log('[MapEditor] Map loaded successfully');
      setIsMapLoaded(true);
      addMapSourcesAndLayers(map);
      // Force immediate resize to ensure map tiles render correctly in the container
      map.resize();
    });

    map.on('error', (e) => {
      console.error('[MapEditor] Mapbox error:', e.error);
    });

    // Handle container resize to prevent blank map issues
    const resizeObserver = new ResizeObserver(() => {
      if (mapRef.current) {
        console.log('[MapEditor] Container resized, calling map.resize()');
        mapRef.current.resize();
      }
    });

    if (mapContainer.current) {
      resizeObserver.observe(mapContainer.current);
    }

    mapRef.current = map;

    return () => {
      resizeObserver.disconnect();
      map.remove();
      mapRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update map style
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;
    const map = mapRef.current;

    map.setStyle(MAP_STYLES[mapStyle]);

    // Re-add sources and layers after style change
    map.once('style.load', () => {
      addMapSourcesAndLayers(map);

      // Re-apply route geometry
      const routeSource = map.getSource('route') as mapboxgl.GeoJSONSource;
      if (routeSource && routeGeometryRef.current) {
        routeSource.setData({
          type: 'Feature',
          properties: {},
          geometry: routeGeometryRef.current,
        });
      }

      // Re-apply trigger radius circles
      updateTriggerRadiusCircles(map, stopsForRadiusRef.current);

      // Ensure map tiles fill the container after style change
      map.resize();
    });
  }, [mapStyle, isMapLoaded, addMapSourcesAndLayers]);

  // Update cursor based on add mode
  useEffect(() => {
    if (!mapRef.current) return;
    mapRef.current.getCanvas().style.cursor = isAddMode ? 'crosshair' : '';
  }, [isAddMode]);

  // Handle map click for adding stops
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;
    const map = mapRef.current;

    const handleMapClick = (e: mapboxgl.MapMouseEvent) => {
      if (!isAddModeRef.current) return;

      const { lng, lat } = e.lngLat;
      const stopNumber = stopsRef.current.length + 1;
      const defaultName = `Stop ${stopNumber}`;

      onStopAdd({ longitude: lng, latitude: lat }, defaultName);
      onAddModeChange?.(false); // Exit add mode after adding
    };

    map.on('click', handleMapClick);

    return () => {
      map.off('click', handleMapClick);
    };
  }, [isMapLoaded, onStopAdd, onAddModeChange]);

  // Update markers when stops change
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;

    const currentMarkerIds = new Set(markersRef.current.keys());
    const newStopIds = new Set(stops.map((s) => s.id));

    // Remove markers for deleted stops
    currentMarkerIds.forEach((id) => {
      if (!newStopIds.has(id)) {
        const marker = markersRef.current.get(id);
        marker?.remove();
        markersRef.current.delete(id);
      }
    });

    // Sort stops by order and create index map for marker numbers
    const sortedStops = [...stops].sort((a, b) => a.order - b.order);
    const stopIndexMap = new Map<string, number>();
    sortedStops.forEach((stop, index) => {
      stopIndexMap.set(stop.id, index + 1); // 1-based numbering
    });

    // Update or add markers
    stops.forEach((stop) => {
      const isSelected = stop.id === selectedStopId;
      const markerNumber = stopIndexMap.get(stop.id) || 0;

      if (markersRef.current.has(stop.id)) {
        const marker = markersRef.current.get(stop.id)!;
        marker.setLngLat([stop.location.longitude, stop.location.latitude]);

        // Update marker visual if selection changed
        const el = marker.getElement();
        const innerEl = (el as any)._innerEl;
        if (innerEl) {
          innerEl.style.backgroundColor = isSelected ? MARKER_COLORS.selected : MARKER_COLORS.default;
          innerEl.textContent = markerNumber.toString();
        }
      } else {
        const el = createMarkerElement(markerNumber, isSelected);
        const marker = new mapboxgl.Marker({ element: el, draggable: true })
          .setLngLat([stop.location.longitude, stop.location.latitude])
          .addTo(mapRef.current!);

        marker.on('dragend', () => {
          const lngLat = marker.getLngLat();
          onStopMove?.(stop.id, { longitude: lngLat.lng, latitude: lngLat.lat });
        });

        el.addEventListener('click', (e) => {
          e.stopPropagation();
          onStopSelect?.(stop.id);
        });

        markersRef.current.set(stop.id, marker);
      }
    });
  }, [stops, isMapLoaded, selectedStopId, onStopMove, onStopSelect]);

  // Update route visibility and geometry
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;
    const map = mapRef.current;

    // Check if we have route geometry
    if (!routeGeometryRef.current || stops.length < 2) {
      if (map.getLayer('route')) map.setLayoutProperty('route', 'visibility', 'none');
      if (map.getLayer('route-casing')) map.setLayoutProperty('route-casing', 'visibility', 'none');
      return;
    }

    // Show route layers
    if (map.getLayer('route')) map.setLayoutProperty('route', 'visibility', 'visible');
    if (map.getLayer('route-casing')) map.setLayoutProperty('route-casing', 'visibility', 'visible');

    // Update geometry
    const source = map.getSource('route') as mapboxgl.GeoJSONSource;
    if (source) {
      source.setData({
        type: 'Feature',
        properties: {},
        geometry: routeGeometryRef.current,
      });
    }
  }, [stops, isMapLoaded]);

  // Update trigger radius circles when stops change
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;
    updateTriggerRadiusCircles(mapRef.current, stops);
  }, [stops, isMapLoaded]);

  // Update waypoint markers
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;

    const currentWaypointIds = new Set(waypointMarkersRef.current.keys());
    const newWaypointIds = new Set(waypoints.map((wp) => wp.id));

    // Remove markers for deleted waypoints
    currentWaypointIds.forEach((id) => {
      if (!newWaypointIds.has(id)) {
        const marker = waypointMarkersRef.current.get(id);
        marker?.remove();
        waypointMarkersRef.current.delete(id);
      }
    });

    // Add or update waypoint markers
    waypoints.forEach((wp) => {
      const existingMarker = waypointMarkersRef.current.get(wp.id);

      if (existingMarker) {
        // Update position
        existingMarker.setLngLat([wp.lng, wp.lat]);
      } else {
        // Create new waypoint marker with remove callback for long-press
        const el = createWaypointElement(() => removeWaypoint(wp.id));

        const marker = new mapboxgl.Marker({
          element: el,
          draggable: true,
        })
          .setLngLat([wp.lng, wp.lat])
          .addTo(mapRef.current!);

        // Handle drag
        marker.on('dragend', () => {
          const lngLat = marker.getLngLat();
          updateWaypoint(wp.id, lngLat.lat, lngLat.lng);
        });

        // Handle double-click to remove (desktop)
        el.addEventListener('dblclick', (e) => {
          e.stopPropagation();
          removeWaypoint(wp.id);
        });

        waypointMarkersRef.current.set(wp.id, marker);
      }
    });
  }, [waypoints, isMapLoaded, updateWaypoint, removeWaypoint]);

  // Handle click on route line to add waypoint
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;

    const map = mapRef.current;

    const handleRouteClick = async (e: mapboxgl.MapLayerMouseEvent) => {
      // Don't add waypoint if in add stop mode
      if (isAddModeRef.current) return;

      // Need at least 2 stops to add waypoints
      if (stopsRef.current.length < 2) return;

      let { lng, lat } = e.lngLat;
      const segmentIndex = findSegmentIndex({ lng, lat }, stopsRef.current);

      // Snap to road if enabled
      if (snapToRoadsRef.current) {
        setIsSnapping(true);
        try {
          const snapped = await snapToRoad(lng, lat, tourType);
          if (snapped.snapped) {
            lng = snapped.lng;
            lat = snapped.lat;
          }
        } finally {
          setIsSnapping(false);
        }
      }

      addWaypoint(lat, lng, segmentIndex);
    };

    // Change cursor on route hover
    const handleRouteMouseEnter = () => {
      if (!isAddModeRef.current) {
        map.getCanvas().style.cursor = 'copy';
      }
    };

    const handleRouteMouseLeave = () => {
      if (!isAddModeRef.current) {
        map.getCanvas().style.cursor = '';
      }
    };

    map.on('click', 'route-line', handleRouteClick);
    map.on('mouseenter', 'route-line', handleRouteMouseEnter);
    map.on('mouseleave', 'route-line', handleRouteMouseLeave);

    return () => {
      map.off('click', 'route-line', handleRouteClick);
      map.off('mouseenter', 'route-line', handleRouteMouseEnter);
      map.off('mouseleave', 'route-line', handleRouteMouseLeave);
    };
  }, [isMapLoaded, addWaypoint]);

  // Fit bounds to show all stops
  const fitToStops = useCallback(() => {
    if (!mapRef.current || stops.length === 0) return;

    if (stops.length === 1) {
      mapRef.current.flyTo({
        center: [stops[0].location.longitude, stops[0].location.latitude],
        zoom: 15,
      });
      return;
    }

    const bounds = new mapboxgl.LngLatBounds();
    stops.forEach((stop) => {
      bounds.extend([stop.location.longitude, stop.location.latitude]);
    });

    mapRef.current.fitBounds(bounds, { padding: 50 });
  }, [stops]);

  // Zoom controls
  const handleZoomIn = () => mapRef.current?.zoomIn();
  const handleZoomOut = () => mapRef.current?.zoomOut();

  // Locate user
  const handleLocate = () => {
    if (!mapRef.current || !navigator.geolocation) return;

    navigator.geolocation.getCurrentPosition(
      (position) => {
        mapRef.current?.flyTo({
          center: [position.coords.longitude, position.coords.latitude],
          zoom: 15,
        });
      },
      (error) => console.error('Geolocation error:', error)
    );
  };

  return (
    <div className="absolute inset-0 overflow-hidden bg-slate-200">
      {/* Map container */}
      <div ref={mapContainer} className="absolute inset-0 z-0" />

      {/* Map controls */}
      <div className="absolute top-4 left-4 flex flex-col gap-2 z-10">
        {/* Add stop button */}
        <Button
          size="sm"
          variant={isAddMode ? 'default' : 'secondary'}
          onClick={() => onAddModeChange?.(!isAddMode)}
          className="shadow-md min-h-[44px]"
        >
          <Plus className="mr-2 h-4 w-4" />
          <span className="hidden sm:inline">{isAddMode ? 'Click map to add stop' : 'Add Stop'}</span>
          <span className="sm:hidden">{isAddMode ? 'Tap to add' : 'Add'}</span>
        </Button>

        {/* Style selector */}
        <Select value={mapStyle} onValueChange={(v) => setMapStyle(v as MapStyleKey)}>
          <SelectTrigger className="w-[140px] sm:w-[140px] bg-background shadow-md min-h-[44px]">
            <Layers className="mr-2 h-4 w-4" />
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="streets">Streets</SelectItem>
            <SelectItem value="outdoors">Outdoors</SelectItem>
            <SelectItem value="light">Light</SelectItem>
            <SelectItem value="dark">Dark</SelectItem>
            <SelectItem value="satellite">Satellite</SelectItem>
          </SelectContent>
        </Select>

        {/* Snap to roads toggle */}
        <Button
          size="sm"
          variant={snapToRoads ? 'default' : 'secondary'}
          onClick={() => setSnapToRoads(!snapToRoads)}
          className="shadow-md min-h-[44px]"
          title={snapToRoads ? 'Snap to roads: ON' : 'Snap to roads: OFF'}
        >
          <Navigation className={`mr-2 h-4 w-4 ${snapToRoads ? '' : 'opacity-50'}`} />
          <span className="hidden sm:inline">Snap to roads</span>
          <span className="sm:hidden">Snap</span>
        </Button>
      </div>

      {/* Zoom and location controls */}
      <div className="absolute top-4 right-4 flex flex-col gap-1">
        <Button size="icon" variant="secondary" onClick={handleZoomIn} className="shadow-md min-h-[44px] min-w-[44px]">
          <ZoomIn className="h-5 w-5" />
        </Button>
        <Button size="icon" variant="secondary" onClick={handleZoomOut} className="shadow-md min-h-[44px] min-w-[44px]">
          <ZoomOut className="h-5 w-5" />
        </Button>
        <Button size="icon" variant="secondary" onClick={handleLocate} className="shadow-md min-h-[44px] min-w-[44px]">
          <Locate className="h-5 w-5" />
        </Button>
        {stops.length > 0 && (
          <Button size="icon" variant="secondary" onClick={fitToStops} className="shadow-md min-h-[44px] min-w-[44px]" title="Fit to stops">
            <svg className="h-5 w-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="3" y="3" width="18" height="18" rx="2" />
              <circle cx="12" cy="12" r="3" />
            </svg>
          </Button>
        )}
      </div>

      {/* Route info display */}
      {routeInfo && stops.length >= 2 && !isAddMode && (
        <div className="absolute bottom-4 left-4 bg-background/95 backdrop-blur-sm px-3 py-2 rounded-lg shadow-md text-sm">
          <div className="flex items-center gap-3">
            <span className="text-muted-foreground">
              {(routeInfo.distance / 1000).toFixed(1)} km
            </span>
            <span className="text-muted-foreground">
              {Math.round(routeInfo.duration / 60)} min
            </span>
            {waypoints.length > 0 && (
              <span className="text-muted-foreground">
                {waypoints.length} waypoint{waypoints.length !== 1 ? 's' : ''}
              </span>
            )}
          </div>
        </div>
      )}

      {/* Route calculating indicator */}
      {isCalculating && (
        <div className="absolute bottom-4 right-4 bg-background/95 backdrop-blur-sm px-3 py-2 rounded-lg shadow-md text-sm flex items-center gap-2">
          <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
          <span className="text-muted-foreground">Calculating route...</span>
        </div>
      )}

      {/* Snapping indicator */}
      {isSnapping && (
        <div className="absolute bottom-4 right-4 bg-background/95 backdrop-blur-sm px-3 py-2 rounded-lg shadow-md text-sm flex items-center gap-2">
          <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
          <span className="text-muted-foreground">Snapping to road...</span>
        </div>
      )}

      {/* Route error indicator */}
      {routeError && !isCalculating && (
        <div className="absolute bottom-4 right-4 bg-amber-50 dark:bg-amber-950/50 text-amber-700 dark:text-amber-300 px-3 py-2 rounded-lg shadow-md text-sm flex items-center gap-2">
          <AlertCircle className="h-4 w-4" />
          <span>{routeError}</span>
        </div>
      )}

      {/* Add mode indicator */}
      {isAddMode && (
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-primary text-primary-foreground px-4 py-2 rounded-full shadow-lg text-sm font-medium">
          Click on the map to add a new stop
        </div>
      )}

      {/* No token warning */}
      {!MAPBOX_TOKEN && (
        <div className="absolute inset-0 flex items-center justify-center bg-muted/80">
          <div className="text-center p-4">
            <p className="text-lg font-medium">Mapbox token not configured</p>
            <p className="text-sm text-muted-foreground mt-1">
              Set NEXT_PUBLIC_MAPBOX_TOKEN in your environment variables
            </p>
          </div>
        </div>
      )}
    </div>
  );
}

// Helper function to create custom marker element
function createMarkerElement(number: number, isSelected: boolean): HTMLDivElement {
  // Outer wrapper for 44px touch target (accessibility standard)
  const wrapper = document.createElement('div');
  wrapper.className = 'flex items-center justify-center cursor-pointer';
  wrapper.style.width = '44px';
  wrapper.style.height = '44px';
  wrapper.style.touchAction = 'none';

  // Inner visual element (40px for better touch targets)
  const el = document.createElement('div');
  el.className = 'flex items-center justify-center transition-all';
  el.style.width = '40px';
  el.style.height = '40px';
  el.style.borderRadius = '50%';
  el.style.backgroundColor = isSelected ? MARKER_COLORS.selected : MARKER_COLORS.default;
  el.style.color = 'white';
  el.style.fontWeight = 'bold';
  el.style.fontSize = '16px';
  el.style.boxShadow = '0 2px 4px rgba(0,0,0,0.3)';
  el.style.border = '2px solid white';
  el.textContent = number.toString();

  wrapper.appendChild(el);

  wrapper.addEventListener('mouseenter', () => {
    if (!isSelected) {
      el.style.backgroundColor = MARKER_COLORS.hover;
      el.style.transform = 'scale(1.1)';
    }
  });

  wrapper.addEventListener('mouseleave', () => {
    if (!isSelected) {
      el.style.backgroundColor = MARKER_COLORS.default;
      el.style.transform = 'scale(1)';
    }
  });

  // Store reference to inner element for color updates
  (wrapper as HTMLDivElement & { _innerEl: HTMLDivElement })._innerEl = el;

  return wrapper;
}

// Helper function to create waypoint marker element with touch support
function createWaypointElement(onRemove: () => void): HTMLDivElement {
  // Outer wrapper for 44px touch target
  const wrapper = document.createElement('div');
  wrapper.className = 'cursor-grab active:cursor-grabbing';
  wrapper.style.width = '44px';
  wrapper.style.height = '44px';
  wrapper.style.display = 'flex';
  wrapper.style.alignItems = 'center';
  wrapper.style.justifyContent = 'center';
  wrapper.style.touchAction = 'none';

  // Inner visual element (24px for better visibility)
  const el = document.createElement('div');
  el.className = 'transition-all';
  el.style.width = '24px';
  el.style.height = '24px';
  el.style.borderRadius = '50%';
  el.style.backgroundColor = 'white';
  el.style.border = `3px solid ${ROUTE_LINE_STYLE.color}`;
  el.style.boxShadow = '0 2px 4px rgba(0,0,0,0.3)';
  el.title = 'Drag to adjust route, double-click or long-press to remove';

  wrapper.appendChild(el);

  // Long-press handling for touch devices
  let longPressTimer: NodeJS.Timeout | null = null;
  let isLongPressing = false;

  const startLongPress = () => {
    isLongPressing = false;
    el.style.transition = 'transform 0.5s ease-out, background-color 0.5s ease-out';
    el.style.transform = 'scale(1.5)';
    el.style.backgroundColor = '#ef4444'; // Red to indicate deletion

    longPressTimer = setTimeout(() => {
      isLongPressing = true;
      // Haptic feedback if available
      if (navigator.vibrate) {
        navigator.vibrate(50);
      }
      onRemove();
    }, 500);
  };

  const cancelLongPress = () => {
    if (longPressTimer) {
      clearTimeout(longPressTimer);
      longPressTimer = null;
    }
    if (!isLongPressing) {
      el.style.transition = 'transform 0.15s ease-out, background-color 0.15s ease-out';
      el.style.transform = 'scale(1)';
      el.style.backgroundColor = 'white';
    }
  };

  wrapper.addEventListener('touchstart', (e) => {
    e.preventDefault();
    startLongPress();
  }, { passive: false });

  wrapper.addEventListener('touchend', cancelLongPress);
  wrapper.addEventListener('touchcancel', cancelLongPress);
  wrapper.addEventListener('touchmove', cancelLongPress);

  // Mouse hover effects
  wrapper.addEventListener('mouseenter', () => {
    if (!longPressTimer) {
      el.style.transform = 'scale(1.3)';
      el.style.backgroundColor = ROUTE_LINE_STYLE.color;
    }
  });

  wrapper.addEventListener('mouseleave', () => {
    if (!longPressTimer) {
      el.style.transform = 'scale(1)';
      el.style.backgroundColor = 'white';
    }
  });

  // Store reference to inner element
  (wrapper as HTMLDivElement & { _innerEl: HTMLDivElement })._innerEl = el;

  return wrapper;
}

// Helper function to create a GeoJSON circle from a center point and radius
function createCirclePolygon(
  centerLng: number,
  centerLat: number,
  radiusMeters: number,
  points = 64
): GeoJSON.Feature<GeoJSON.Polygon> {
  const coords: [number, number][] = [];

  // Convert radius from meters to degrees (approximate)
  // At the equator, 1 degree = ~111,320 meters
  // Adjust for latitude
  const latRadians = (centerLat * Math.PI) / 180;
  const metersPerDegreeLat = 111320;
  const metersPerDegreeLng = 111320 * Math.cos(latRadians);

  const radiusLat = radiusMeters / metersPerDegreeLat;
  const radiusLng = radiusMeters / metersPerDegreeLng;

  for (let i = 0; i <= points; i++) {
    const angle = (i / points) * 2 * Math.PI;
    const lng = centerLng + radiusLng * Math.cos(angle);
    const lat = centerLat + radiusLat * Math.sin(angle);
    coords.push([lng, lat]);
  }

  return {
    type: 'Feature',
    properties: {},
    geometry: {
      type: 'Polygon',
      coordinates: [coords],
    },
  };
}

// Helper function to update trigger radius circles on the map
function updateTriggerRadiusCircles(map: mapboxgl.Map, stops: StopModel[]) {
  const source = map.getSource('trigger-radius') as mapboxgl.GeoJSONSource;
  if (!source) return;

  const features = stops.map((stop) =>
    createCirclePolygon(
      stop.location.longitude,
      stop.location.latitude,
      stop.triggerRadius
    )
  );

  source.setData({
    type: 'FeatureCollection',
    features,
  });
}
