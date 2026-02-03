'use client';

import { getDirections } from '@/lib/mapbox/geocoding';
import { StopModel } from '@/types';
import { useCallback, useEffect, useRef, useState } from 'react';

export interface RouteWaypoint {
  id: string;
  lat: number;
  lng: number;
  segmentIndex: number; // Which stop-to-stop segment this waypoint belongs to (0 = between stop 0 and 1)
}

export interface RouteInfo {
  distance: number; // meters
  duration: number; // seconds
}

export interface RouteCalculationResult {
  geometry: GeoJSON.LineString | null;
  routeInfo: RouteInfo | null;
  isCalculating: boolean;
  error: string | null;
  waypoints: RouteWaypoint[];
  addWaypoint: (lat: number, lng: number, segmentIndex: number) => void;
  updateWaypoint: (id: string, lat: number, lng: number) => void;
  removeWaypoint: (id: string) => void;
  clearWaypoints: () => void;
}

/**
 * Calculate haversine distance between two points in meters
 */
/**
 * Hook for calculating routes between stops with optional custom waypoints
 * Uses a Web Worker to offload heavy geometric calculations
 */
export function useRouteCalculation(
  stops: StopModel[],
  tourType: 'walking' | 'driving' = 'walking',
  debounceMs = 300 // Reduced debounce for snappier feel
): RouteCalculationResult {
  const [geometry, setGeometry] = useState<GeoJSON.LineString | null>(null);
  const [routeInfo, setRouteInfo] = useState<RouteInfo | null>(null);
  const [isCalculating, setIsCalculating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [waypoints, setWaypoints] = useState<RouteWaypoint[]>([]);

  const workerRef = useRef<Worker | null>(null);
  const debounceTimer = useRef<NodeJS.Timeout | null>(null);
  const prevRouteGeometryRef = useRef<GeoJSON.LineString | null>(null);

  // Initialize worker
  useEffect(() => {
    workerRef.current = new Worker(new URL('../workers/route-calculation.worker.ts', import.meta.url));

    return () => {
      workerRef.current?.terminate();
    };
  }, []);

  // Generate unique ID for waypoints
  const generateId = () => `wp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  const addWaypoint = useCallback((lat: number, lng: number, segmentIndex: number) => {
    setWaypoints((prev) => [...prev, { id: generateId(), lat, lng, segmentIndex }]);
  }, []);

  const updateWaypoint = useCallback((id: string, lat: number, lng: number) => {
    setWaypoints((prev) => prev.map((wp) => (wp.id === id ? { ...wp, lat, lng } : wp)));
  }, []);

  const removeWaypoint = useCallback((id: string) => {
    setWaypoints((prev) => prev.filter((wp) => wp.id !== id));
  }, []);

  const clearWaypoints = useCallback(() => {
    setWaypoints([]);
  }, []);

  // Calculate route with debouncing
  useEffect(() => {
    if (debounceTimer.current) clearTimeout(debounceTimer.current);

    const sortedStops = [...stops].sort((a, b) => a.order - b.order);
    if (sortedStops.length < 2) {
      setGeometry(null);
      setRouteInfo(null);
      setError(null);
      setIsCalculating(false);
      return;
    }

    setIsCalculating(true);
    setError(null);

    debounceTimer.current = setTimeout(() => {
      if (!workerRef.current) return;

      const handleWorkerMessage = async (event: MessageEvent) => {
        const { coordinates, wasSimplified } = event.data;

        // Clean up listener for this request
        workerRef.current?.removeEventListener('message', handleWorkerMessage);

        try {
          console.log('[useRouteCalculation] Worker returned coordinates:', coordinates.length);

          const result = await getDirections(coordinates, tourType);

          if (result) {
            setGeometry(result.geometry);
            setRouteInfo({
              distance: result.distance,
              duration: result.duration,
            });
            prevRouteGeometryRef.current = result.geometry;
            if (wasSimplified) {
              setError('Route simplified to fit API limits.');
            } else {
              setError(null);
            }
          } else {
            // Fallback to straight lines
            setGeometry({ type: 'LineString', coordinates });
            setRouteInfo(null);
            setError('Could not calculate route. Showing straight lines.');
          }
        } catch (err) {
          console.error('Route calculation error:', err);
          // Fallback
          setGeometry({ type: 'LineString', coordinates });
          setRouteInfo(null);
          setError('Route calculation error.');
        } finally {
          setIsCalculating(false);
        }
      };

      workerRef.current.addEventListener('message', handleWorkerMessage);

      // Extract raw coordinates for worker (avoid passing entire geometry object if possible)
      const prevCoords = prevRouteGeometryRef.current?.coordinates as number[][] | undefined;

      workerRef.current.postMessage({
        type: 'CALCULATE_COORDINATES',
        stops: sortedStops,
        waypoints,
        prevGeometryCoords: prevCoords,
        maxCoordinates: 25,
      });

    }, debounceMs);

    return () => {
      if (debounceTimer.current) clearTimeout(debounceTimer.current);
    };
  }, [stops, tourType, waypoints, debounceMs]);

  return {
    geometry,
    routeInfo,
    isCalculating,
    error,
    waypoints,
    addWaypoint,
    updateWaypoint,
    removeWaypoint,
    clearWaypoints,
  };
}

/**
 * Utility to determine which segment a point on the route belongs to
 * (Kept main thread for instant click feedback, lightweight enough)
 */

export function findSegmentIndex(
  clickLngLat: { lng: number; lat: number },
  stops: StopModel[]
): number {
  const sortedStops = [...stops].sort((a, b) => a.order - b.order);
  if (sortedStops.length < 2) return 0;

  let closestSegment = 0;
  let minDistance = Infinity;

  for (let i = 0; i < sortedStops.length - 1; i++) {
    const start = sortedStops[i].location;
    const end = sortedStops[i + 1].location;

    // Calculate distance from point to line segment
    const distance = pointToSegmentDistance(
      clickLngLat.lng,
      clickLngLat.lat,
      start.longitude,
      start.latitude,
      end.longitude,
      end.latitude
    );

    if (distance < minDistance) {
      minDistance = distance;
      closestSegment = i;
    }
  }

  return closestSegment;
}

/**
 * Calculate distance from point to line segment
 */
function pointToSegmentDistance(
  px: number,
  py: number,
  x1: number,
  y1: number,
  x2: number,
  y2: number
): number {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const lengthSquared = dx * dx + dy * dy;

  if (lengthSquared === 0) {
    // Segment is a point
    return Math.hypot(px - x1, py - y1);
  }

  // Project point onto line, clamped to segment
  const t = Math.max(0, Math.min(1, ((px - x1) * dx + (py - y1) * dy) / lengthSquared));
  const projX = x1 + t * dx;
  const projY = y1 + t * dy;

  return Math.hypot(px - projX, py - projY);
}
