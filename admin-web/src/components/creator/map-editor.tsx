'use client';

import { useEffect, useRef, useState, useCallback } from 'react';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import { StopModel, GeoPoint } from '@/types';
import {
  MAPBOX_TOKEN,
  DEFAULT_MAP_CONFIG,
  MARKER_COLORS,
  ROUTE_LINE_STYLE,
  MAP_STYLES,
  MapStyleKey,
} from '@/lib/mapbox/config';
import { reverseGeocode } from '@/lib/mapbox/geocoding';
import { Button } from '@/components/ui/button';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Layers, Plus, ZoomIn, ZoomOut, Locate } from 'lucide-react';

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
}: MapEditorProps) {
  const mapContainer = useRef<HTMLDivElement>(null);
  const mapRef = useRef<mapboxgl.Map | null>(null);
  const markersRef = useRef<Map<string, mapboxgl.Marker>>(new Map());
  const [mapStyle, setMapStyle] = useState<MapStyleKey>('streets');
  const [isMapLoaded, setIsMapLoaded] = useState(false);

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

    map.addControl(new mapboxgl.NavigationControl(), 'bottom-right');

    map.on('load', () => {
      setIsMapLoaded(true);

      // Add route line source
      map.addSource('route', {
        type: 'geojson',
        data: {
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'LineString',
            coordinates: [],
          },
        },
      });

      // Add route line layer
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
    });

    // Handle click to add stops
    map.on('click', async (e) => {
      if (!isAddMode) return;

      const { lng, lat } = e.lngLat;
      const location: GeoPoint = { latitude: lat, longitude: lng };

      // Reverse geocode to get a suggested name
      const geocodeResult = await reverseGeocode(lng, lat);
      const suggestedName = geocodeResult?.shortName || `Stop ${stops.length + 1}`;

      onStopAdd(location, suggestedName);
      onAddModeChange?.(false);
    });

    mapRef.current = map;

    return () => {
      map.remove();
      mapRef.current = null;
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Update map style
  useEffect(() => {
    if (!mapRef.current || !isMapLoaded) return;
    mapRef.current.setStyle(MAP_STYLES[mapStyle]);
  }, [mapStyle, isMapLoaded]);

  // Update cursor based on add mode
  useEffect(() => {
    if (!mapRef.current) return;
    mapRef.current.getCanvas().style.cursor = isAddMode ? 'crosshair' : '';
  }, [isAddMode]);

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

    // Add or update markers for stops
    stops.forEach((stop) => {
      const existingMarker = markersRef.current.get(stop.id);

      if (existingMarker) {
        // Update position if changed
        const currentPos = existingMarker.getLngLat();
        if (
          currentPos.lng !== stop.location.longitude ||
          currentPos.lat !== stop.location.latitude
        ) {
          existingMarker.setLngLat([stop.location.longitude, stop.location.latitude]);
        }

        // Update color based on selection
        const el = existingMarker.getElement();
        const isSelected = stop.id === selectedStopId;
        el.style.backgroundColor = isSelected ? MARKER_COLORS.selected : MARKER_COLORS.default;
      } else {
        // Create new marker
        const el = createMarkerElement(stop.order + 1, stop.id === selectedStopId);

        const marker = new mapboxgl.Marker({
          element: el,
          draggable: true,
        })
          .setLngLat([stop.location.longitude, stop.location.latitude])
          .addTo(mapRef.current!);

        // Handle marker click
        el.addEventListener('click', (e) => {
          e.stopPropagation();
          onStopSelect(stop.id);
        });

        // Handle marker drag
        marker.on('dragend', () => {
          const lngLat = marker.getLngLat();
          onStopMove(stop.id, { latitude: lngLat.lat, longitude: lngLat.lng });
        });

        markersRef.current.set(stop.id, marker);
      }
    });

    // Update route line
    updateRouteLine(stops);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [stops, selectedStopId, isMapLoaded, onStopSelect, onStopMove]);

  // Update route line coordinates
  const updateRouteLine = useCallback((currentStops: StopModel[]) => {
    if (!mapRef.current || !isMapLoaded) return;

    const source = mapRef.current.getSource('route') as mapboxgl.GeoJSONSource;
    if (!source) return;

    const coordinates = currentStops
      .sort((a, b) => a.order - b.order)
      .map((stop) => [stop.location.longitude, stop.location.latitude]);

    source.setData({
      type: 'Feature',
      properties: {},
      geometry: {
        type: 'LineString',
        coordinates,
      },
    });
  }, [isMapLoaded]);

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
    <div className="relative h-full w-full">
      {/* Map container */}
      <div ref={mapContainer} className="h-full w-full" />

      {/* Map controls */}
      <div className="absolute top-4 left-4 flex flex-col gap-2">
        {/* Add stop button */}
        <Button
          size="sm"
          variant={isAddMode ? 'default' : 'secondary'}
          onClick={() => onAddModeChange?.(!isAddMode)}
          className="shadow-md"
        >
          <Plus className="mr-2 h-4 w-4" />
          {isAddMode ? 'Click map to add stop' : 'Add Stop'}
        </Button>

        {/* Style selector */}
        <Select value={mapStyle} onValueChange={(v) => setMapStyle(v as MapStyleKey)}>
          <SelectTrigger className="w-[140px] bg-background shadow-md">
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
      </div>

      {/* Zoom and location controls */}
      <div className="absolute top-4 right-4 flex flex-col gap-1">
        <Button size="icon" variant="secondary" onClick={handleZoomIn} className="shadow-md">
          <ZoomIn className="h-4 w-4" />
        </Button>
        <Button size="icon" variant="secondary" onClick={handleZoomOut} className="shadow-md">
          <ZoomOut className="h-4 w-4" />
        </Button>
        <Button size="icon" variant="secondary" onClick={handleLocate} className="shadow-md">
          <Locate className="h-4 w-4" />
        </Button>
        {stops.length > 0 && (
          <Button size="icon" variant="secondary" onClick={fitToStops} className="shadow-md" title="Fit to stops">
            <svg className="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <rect x="3" y="3" width="18" height="18" rx="2" />
              <circle cx="12" cy="12" r="3" />
            </svg>
          </Button>
        )}
      </div>

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
  const el = document.createElement('div');
  el.className = 'flex items-center justify-center cursor-pointer transition-all';
  el.style.width = '32px';
  el.style.height = '32px';
  el.style.borderRadius = '50%';
  el.style.backgroundColor = isSelected ? MARKER_COLORS.selected : MARKER_COLORS.default;
  el.style.color = 'white';
  el.style.fontWeight = 'bold';
  el.style.fontSize = '14px';
  el.style.boxShadow = '0 2px 4px rgba(0,0,0,0.3)';
  el.style.border = '2px solid white';
  el.textContent = number.toString();

  el.addEventListener('mouseenter', () => {
    if (!isSelected) {
      el.style.backgroundColor = MARKER_COLORS.hover;
      el.style.transform = 'scale(1.1)';
    }
  });

  el.addEventListener('mouseleave', () => {
    if (!isSelected) {
      el.style.backgroundColor = MARKER_COLORS.default;
      el.style.transform = 'scale(1)';
    }
  });

  return el;
}
