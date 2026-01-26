'use client';

import { useRef, useEffect, useState } from 'react';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import { MapPin, Maximize2, Minimize2 } from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { MAPBOX_TOKEN, MAP_STYLES, MARKER_COLORS, ROUTE_LINE_STYLE } from '@/lib/mapbox/config';
import { StopModel, GeoPoint } from '@/types';
import { cn } from '@/lib/utils';

interface TourMapPreviewProps {
  stops: StopModel[];
  startLocation?: GeoPoint;
  className?: string;
}

export function TourMapPreview({
  stops,
  startLocation,
  className,
}: TourMapPreviewProps) {
  const mapContainer = useRef<HTMLDivElement>(null);
  const map = useRef<mapboxgl.Map | null>(null);
  const markersRef = useRef<mapboxgl.Marker[]>([]);
  const [isExpanded, setIsExpanded] = useState(false);
  const [isMapReady, setIsMapReady] = useState(false);

  const sortedStops = [...stops].sort((a, b) => a.order - b.order);

  // Initialize map
  useEffect(() => {
    if (!mapContainer.current || !MAPBOX_TOKEN) return;

    mapboxgl.accessToken = MAPBOX_TOKEN;

    const mapInstance = new mapboxgl.Map({
      container: mapContainer.current,
      style: MAP_STYLES.streets,
      center: startLocation
        ? [startLocation.longitude, startLocation.latitude]
        : sortedStops.length > 0
        ? [sortedStops[0].location.longitude, sortedStops[0].location.latitude]
        : [-122.4194, 37.7749],
      zoom: 14,
      attributionControl: false,
    });

    mapInstance.addControl(new mapboxgl.NavigationControl(), 'top-right');

    mapInstance.on('load', () => {
      setIsMapReady(true);
    });

    map.current = mapInstance;

    return () => {
      markersRef.current.forEach((marker) => marker.remove());
      markersRef.current = [];
      mapInstance.remove();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [startLocation, stops]);

  // Add markers and route when map is ready
  useEffect(() => {
    if (!map.current || !isMapReady || sortedStops.length === 0) return;

    // Clear existing markers
    markersRef.current.forEach((marker) => marker.remove());
    markersRef.current = [];

    // Add stop markers
    sortedStops.forEach((stop, index) => {
      const el = document.createElement('div');
      el.className = 'stop-marker';
      el.innerHTML = `
        <div style="
          width: 28px;
          height: 28px;
          background: ${MARKER_COLORS.default};
          border: 2px solid white;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-weight: bold;
          font-size: 12px;
          box-shadow: 0 2px 6px rgba(0,0,0,0.3);
        ">${index + 1}</div>
      `;

      const popup = new mapboxgl.Popup({
        offset: 25,
        closeButton: false,
      }).setHTML(`
        <div style="padding: 8px;">
          <strong>${stop.name}</strong>
          ${stop.description ? `<p style="margin-top: 4px; font-size: 12px; color: #666;">${stop.description.slice(0, 100)}${stop.description.length > 100 ? '...' : ''}</p>` : ''}
          <div style="margin-top: 8px; font-size: 11px; color: #888;">
            ${stop.media.audioUrl ? '🎧 Audio' : ''}
            ${stop.media.images?.length ? ` 📷 ${stop.media.images.length} images` : ''}
          </div>
        </div>
      `);

      const marker = new mapboxgl.Marker(el)
        .setLngLat([stop.location.longitude, stop.location.latitude])
        .setPopup(popup)
        .addTo(map.current!);

      markersRef.current.push(marker);
    });

    // Add route line
    const coordinates = sortedStops.map((stop) => [
      stop.location.longitude,
      stop.location.latitude,
    ]);

    if (coordinates.length > 1) {
      // Remove existing route layer if it exists
      if (map.current.getSource('route')) {
        map.current.removeLayer('route-line');
        map.current.removeSource('route');
      }

      map.current.addSource('route', {
        type: 'geojson',
        data: {
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'LineString',
            coordinates,
          },
        },
      });

      map.current.addLayer({
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

    // Fit bounds to show all stops
    if (sortedStops.length > 0) {
      const bounds = new mapboxgl.LngLatBounds();
      sortedStops.forEach((stop) => {
        bounds.extend([stop.location.longitude, stop.location.latitude]);
      });
      map.current.fitBounds(bounds, {
        padding: 50,
        maxZoom: 15,
      });
    }
  }, [sortedStops, isMapReady]);

  // Handle resize when expanded
  useEffect(() => {
    if (map.current) {
      setTimeout(() => {
        map.current?.resize();
      }, 100);
    }
  }, [isExpanded]);

  if (!MAPBOX_TOKEN) {
    return (
      <Card className={className}>
        <CardContent className="flex items-center justify-center h-48 text-muted-foreground">
          <p>Map preview requires Mapbox token</p>
        </CardContent>
      </Card>
    );
  }

  if (stops.length === 0) {
    return (
      <Card className={className}>
        <CardContent className="flex items-center justify-center h-48 text-muted-foreground">
          <MapPin className="h-8 w-8 mr-2 opacity-50" />
          <p>No stops to display</p>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={cn(className, isExpanded && 'fixed inset-4 z-50')}>
      <CardHeader className="pb-2 flex flex-row items-center justify-between">
        <CardTitle className="text-base flex items-center gap-2">
          <MapPin className="h-4 w-4" />
          Tour Route ({sortedStops.length} stops)
        </CardTitle>
        <Button
          variant="ghost"
          size="icon"
          onClick={() => setIsExpanded(!isExpanded)}
          className="h-8 w-8"
        >
          {isExpanded ? (
            <Minimize2 className="h-4 w-4" />
          ) : (
            <Maximize2 className="h-4 w-4" />
          )}
        </Button>
      </CardHeader>
      <CardContent className="p-0">
        <div
          ref={mapContainer}
          className={cn(
            'w-full rounded-b-lg',
            isExpanded ? 'h-[calc(100%-60px)]' : 'h-64'
          )}
        />
      </CardContent>
    </Card>
  );
}
