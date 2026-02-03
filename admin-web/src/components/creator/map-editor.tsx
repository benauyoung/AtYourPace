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
import { memo, useCallback, useEffect, useRef, useState } from 'react';

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

export const MapEditor = memo(function MapEditor({
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
  const [mapStatus, setMapStatus] = useState<'idle' | 'loading' | 'loaded' | 'error'>('idle');
  const [mapErrorMessage, setMapErrorMessage] = useState<string | null>(null);
  const [containerSize, setContainerSize] = useState<{ width: number; height: number } | null>(null);
  const [layersReady, setLayersReady] = useState(false);
  const prevMapStyleRef = useRef<MapStyleKey | null>(null);
  const [showDebug, setShowDebug] = useState(false);
  const [webglSupported, setWebglSupported] = useState<boolean | null>(null);
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
  const tourTypeRef = useRef(tourType);
  const routeGeometryRef = useRef<GeoJSON.LineString | null>(null);
  const stopsForRadiusRef = useRef<StopModel[]>([]);
  const draggingStopIdRef = useRef<string | null>(null);
  const dragDebounceRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const params = new URLSearchParams(window.location.search);
    const debugEnabled = params.get('mapDebug') === '1' || localStorage.getItem('mapDebug') === 'true';
    setShowDebug(debugEnabled);
    setWebglSupported(mapboxgl.supported());
  }, []);

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

  useEffect(() => {
    tourTypeRef.current = tourType;
  }, [tourType]);

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

    // Add directional arrows layer
    if (!map.getLayer('route-arrows')) {
      // Load arrow image if not exists
      if (!map.hasImage('arrow')) {
        // Simple arrow SVG
        const arrow = new Image(20, 20);
        arrow.onload = () => {
          if (!map.hasImage('arrow')) map.addImage('arrow', arrow);
        };
        arrow.src = 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0iIzU1NCIgd2lkdGg9IjIwIiBoZWlnaHQ9IjIwIj48cGF0aCBkPSZNMTIgNEw0IDE4bDggLTJsOCAyVjR6Ii8+PC9zdmc+'; // White/Grey arrow
      }

      map.addLayer({
        id: 'route-arrows',
        type: 'symbol',
        source: 'route',
        layout: {
          'symbol-placement': 'line',
          'symbol-spacing': 100,
          'icon-image': 'arrow',
          'icon-size': 0.6,
          'icon-allow-overlap': true,
          'icon-ignore-placement': true,
          'visibility': 'none',
        },
        paint: {
          'icon-opacity': 0.8,
        },
      });
    }

    // Add route line layer (start hidden, show when geometry ready)
    if (!map.getLayer('route-line')) {
      map.addLayer({
        id: 'route-line',
        type: 'line',
        source: 'route',
        layout: {
          'line-join': 'round',
          'line-cap': 'round',
          'visibility': 'none',
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
          'fill-color': MARKER_COLORS.selected, // Use accent color for audio zones
          'fill-opacity': 0.15,
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
          'line-color': MARKER_COLORS.selected, // Match fill color
          'line-width': 2,
          'line-opacity': 0.8,
          'line-dasharray': [2, 2],
        },
      });
    }
  }, []);

  // Initialize map
  useEffect(() => {
    if (!mapContainer.current) return;

    // Skip if map already exists (prevents double-init in React Strict Mode)
    if (mapRef.current) {
      return;
    }

    if (!mapboxgl.supported()) {
      setMapStatus('error');
      setMapErrorMessage('WebGL is not supported in this browser.');
      return;
    }

    // Cancellation flag for cleanup
    let cancelled = false;

    const updateContainerSize = () => {
      if (!mapContainer.current) return;
      const rect = mapContainer.current.getBoundingClientRect();
      setContainerSize({ width: Math.round(rect.width), height: Math.round(rect.height) });
      return rect;
    };

    const initializeMap = () => {
      // Check cancellation flag first
      if (cancelled) {
        return;
      }

      if (!mapContainer.current || mapRef.current) return;

      const rect = updateContainerSize();

      // Wait for container to have non-zero dimensions
      if (!rect || rect.width === 0 || rect.height === 0) {
        requestAnimationFrame(initializeMap);
        return;
      }

      setMapStatus('loading');

      const center = centerLocation
        ? [centerLocation.longitude, centerLocation.latitude] as [number, number]
        : DEFAULT_MAP_CONFIG.center;

      const map = new mapboxgl.Map({
        container: mapContainer.current,
        style: MAP_STYLES[mapStyle],
        center,
        zoom: DEFAULT_MAP_CONFIG.zoom,
      });

      // Store ref immediately to prevent double-init
      mapRef.current = map;

      map.addControl(new mapboxgl.NavigationControl(), 'bottom-right');

      map.on('load', () => {
        // Check if this map instance is still the active one
        if (cancelled || mapRef.current !== map) {
          return;
        }
        setIsMapLoaded(true);
        setMapStatus('loaded');
        setMapErrorMessage(null);
        addMapSourcesAndLayers(map);
        setLayersReady(true);
        // Delay resize to ensure CSS has fully settled
        setTimeout(() => {
          if (mapRef.current === map) {
            map.resize();
          }
        }, 200);
      });

      map.on('error', (e) => {
        if (cancelled || mapRef.current !== map) return;
        console.error('[MapEditor] Mapbox error:', e.error);
        const error = e.error as { message?: string; status?: number } | undefined;
        const message = error?.message || (error?.status ? `HTTP ${error.status}` : 'Unknown Mapbox error');
        setMapStatus('error');
        setMapErrorMessage(message);
      });
    };

    // Handle container resize to prevent blank map issues
    let resizeTimeout: NodeJS.Timeout | null = null;
    const resizeObserver = new ResizeObserver(() => {
      if (cancelled) return;
      updateContainerSize();
      // Debounce resize calls to wait for CSS transitions to complete
      if (resizeTimeout) clearTimeout(resizeTimeout);
      resizeTimeout = setTimeout(() => {
        if (mapRef.current && !cancelled) {
          mapRef.current.resize();
        }
      }, 100);
    });

    if (mapContainer.current) {
      resizeObserver.observe(mapContainer.current);
    }

    // Start initialization (will wait for non-zero size)
    initializeMap();

    return () => {
      cancelled = true;
      if (resizeTimeout) clearTimeout(resizeTimeout);
      resizeObserver.disconnect();
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update map style (only when style actually changes, not on initial load)
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;

    // Skip if this is the initial load (style already set during map creation)
    if (prevMapStyleRef.current === null) {
      prevMapStyleRef.current = mapStyle;
      return;
    }

    // Skip if style hasn't actually changed
    if (prevMapStyleRef.current === mapStyle) return;
    prevMapStyleRef.current = mapStyle;

    const map = mapRef.current;

    map.setStyle(MAP_STYLES[mapStyle]);
    setLayersReady(false);

    // Re-add sources and layers after style change
    map.once('style.load', () => {
      addMapSourcesAndLayers(map);
      setLayersReady(true);

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

  // Ghost marker for Add Mode
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;
    const map = mapRef.current;

    const ghostEl = document.createElement('div');
    ghostEl.className = 'w-6 h-6 rounded-full bg-primary/50 border-2 border-primary shadow-lg pointer-events-none transition-opacity duration-200';
    ghostEl.style.opacity = '0'; // Start hidden

    const ghostMarker = new mapboxgl.Marker({
      element: ghostEl,
      offset: [0, 0], // Center
    })
      .setLngLat([0, 0])
      .addTo(map);

    const handleMouseMove = (e: mapboxgl.MapMouseEvent) => {
      if (!isAddModeRef.current) {
        ghostEl.style.opacity = '0';
        return;
      }
      ghostEl.style.opacity = '1';
      ghostMarker.setLngLat(e.lngLat);
    };

    const handleMouseLeave = () => {
      ghostEl.style.opacity = '0';
    };

    map.on('mousemove', handleMouseMove);
    map.on('mouseout', handleMouseLeave);

    return () => {
      map.off('mousemove', handleMouseMove);
      map.off('mouseout', handleMouseLeave);
      ghostMarker.remove();
    };
  }, [isMapLoaded, isAddMode]); // Re-run when mode changes to ensure visibility update

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
    if (!mapRef.current || !isMapLoaded || !layersReady) return;
    const map = mapRef.current;

    // Ensure source and layer exist before any operations
    const source = map.getSource('route') as mapboxgl.GeoJSONSource | undefined;
    const layer = map.getLayer('route-line');
    if (!source || !layer) return;

    // Check if we have valid route geometry
    if (!routeGeometry || !routeGeometry.coordinates?.length || stops.length < 2) {
      map.setLayoutProperty('route-line', 'visibility', 'none');
      return;
    }

    // Update geometry and show route layer
    source.setData({
      type: 'Feature',
      properties: {},
      geometry: routeGeometry,
    });
    map.setLayoutProperty('route-line', 'visibility', 'visible');

    // Show arrows if we have route
    if (map.getLayer('route-arrows')) {
      map.setLayoutProperty('route-arrows', 'visibility', 'visible');
    }
  }, [stops, routeGeometry, isMapLoaded, layersReady]);

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

        // Handle drag with optional snap-to-road
        marker.on('dragend', async () => {
          let lngLat = marker.getLngLat();

          if (snapToRoadsRef.current) {
            setIsSnapping(true);
            try {
              const snapped = await snapToRoad(lngLat.lng, lngLat.lat, tourTypeRef.current);
              if (snapped.snapped) {
                lngLat = new mapboxgl.LngLat(snapped.lng, snapped.lat);
                marker.setLngLat(lngLat);
              }
            } finally {
              setIsSnapping(false);
            }
          }

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
    <div className="absolute inset-0 overflow-hidden bg-slate-200" style={{ width: '100%', height: '100%' }}>
      {/* Map container */}
      <div ref={mapContainer} className="absolute inset-0 z-0" style={{ width: '100%', height: '100%' }} />

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

      {showDebug && (
        <div className="absolute top-4 right-4 mt-36 z-30 max-w-xs rounded-lg border bg-background/95 p-3 text-xs shadow-md backdrop-blur">
          <div className="text-xs font-semibold text-foreground">Mapbox Debug</div>
          <div className="mt-2 space-y-1 text-muted-foreground">
            <div>
              Token:{' '}
              {MAPBOX_TOKEN
                ? `set (${MAPBOX_TOKEN.slice(0, 4)}…${MAPBOX_TOKEN.slice(-4)})`
                : 'missing'}
            </div>
            <div>Status: {mapStatus}</div>
            <div>
              WebGL:{' '}
              {webglSupported === null
                ? 'unknown'
                : webglSupported
                  ? 'supported'
                  : 'not supported'}
            </div>
            <div>
              Container:{' '}
              {containerSize ? `${containerSize.width}x${containerSize.height}` : 'unknown'}
            </div>
            <div>Style: {MAP_STYLES[mapStyle]}</div>
            {mapErrorMessage && (
              <div className="text-red-600">Error: {mapErrorMessage}</div>
            )}
          </div>
          <div className="mt-2 text-[10px] text-muted-foreground">
            Enable with ?mapDebug=1 or localStorage.mapDebug=true
          </div>
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
});

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
