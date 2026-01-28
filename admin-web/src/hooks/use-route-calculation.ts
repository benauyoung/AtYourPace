'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import { getDirections } from '@/lib/mapbox/geocoding';
import { StopModel, GeoPoint } from '@/types';

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
function haversineDistance(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number
): number {
  const R = 6371000; // Earth's radius in meters
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

/**
 * Find the distance along a route line to the closest point to a given waypoint
 * Returns the cumulative distance from the start of the route to the projected point
 */
function distanceAlongLine(
  waypointLng: number,
  waypointLat: number,
  routeCoordinates: Array<[number, number]>
): number {
  let cumulativeDistance = 0;
  let minDistanceToLine = Infinity;
  let distanceAtClosest = 0;

  for (let i = 0; i < routeCoordinates.length - 1; i++) {
    const [lng1, lat1] = routeCoordinates[i];
    const [lng2, lat2] = routeCoordinates[i + 1];

    // Calculate distance from waypoint to this segment
    const segmentLength = haversineDistance(lat1, lng1, lat2, lng2);

    if (segmentLength === 0) {
      // Degenerate segment
      const distToPoint = haversineDistance(waypointLat, waypointLng, lat1, lng1);
      if (distToPoint < minDistanceToLine) {
        minDistanceToLine = distToPoint;
        distanceAtClosest = cumulativeDistance;
      }
    } else {
      // Project waypoint onto line segment
      // Using normalized dot product to find projection parameter t
      const dx = lng2 - lng1;
      const dy = lat2 - lat1;
      const t = Math.max(
        0,
        Math.min(
          1,
          ((waypointLng - lng1) * dx + (waypointLat - lat1) * dy) /
            (dx * dx + dy * dy)
        )
      );

      // Closest point on segment
      const closestLng = lng1 + t * dx;
      const closestLat = lat1 + t * dy;
      const distToLine = haversineDistance(
        waypointLat,
        waypointLng,
        closestLat,
        closestLng
      );

      if (distToLine < minDistanceToLine) {
        minDistanceToLine = distToLine;
        // Distance along route = cumulative distance + distance to projection point
        distanceAtClosest =
          cumulativeDistance + haversineDistance(lat1, lng1, closestLat, closestLng);
      }
    }

    cumulativeDistance += segmentLength;
  }

  return distanceAtClosest;
}

/**
 * Extract the portion of route geometry between two stops
 */
function extractSegmentGeometry(
  routeCoordinates: Array<[number, number]>,
  startLng: number,
  startLat: number,
  endLng: number,
  endLat: number
): Array<[number, number]> {
  // Find indices closest to start and end stops
  let startIdx = 0;
  let endIdx = routeCoordinates.length - 1;
  let minStartDist = Infinity;
  let minEndDist = Infinity;

  for (let i = 0; i < routeCoordinates.length; i++) {
    const [lng, lat] = routeCoordinates[i];
    const startDist = haversineDistance(startLat, startLng, lat, lng);
    const endDist = haversineDistance(endLat, endLng, lat, lng);

    if (startDist < minStartDist) {
      minStartDist = startDist;
      startIdx = i;
    }
    if (endDist < minEndDist) {
      minEndDist = endDist;
      endIdx = i;
    }
  }

  // Ensure start comes before end
  if (startIdx > endIdx) {
    [startIdx, endIdx] = [endIdx, startIdx];
  }

  return routeCoordinates.slice(startIdx, endIdx + 1);
}

/**
 * Douglas-Peucker algorithm to simplify a list of waypoints
 * Keeps the most significant waypoints while reducing count
 */
function douglasPeuckerSimplify(
  waypoints: RouteWaypoint[],
  targetCount: number
): RouteWaypoint[] {
  if (waypoints.length <= targetCount) {
    return waypoints;
  }

  if (waypoints.length <= 2) {
    return waypoints;
  }

  // Calculate perpendicular distance from point to line
  const perpendicularDistance = (
    point: RouteWaypoint,
    lineStart: RouteWaypoint,
    lineEnd: RouteWaypoint
  ): number => {
    const dx = lineEnd.lng - lineStart.lng;
    const dy = lineEnd.lat - lineStart.lat;
    const lengthSquared = dx * dx + dy * dy;

    if (lengthSquared === 0) {
      return haversineDistance(point.lat, point.lng, lineStart.lat, lineStart.lng);
    }

    const t = Math.max(
      0,
      Math.min(
        1,
        ((point.lng - lineStart.lng) * dx + (point.lat - lineStart.lat) * dy) / lengthSquared
      )
    );
    const projLng = lineStart.lng + t * dx;
    const projLat = lineStart.lat + t * dy;

    return haversineDistance(point.lat, point.lng, projLat, projLng);
  };

  // Score each waypoint by its perpendicular distance (importance)
  const scores: Array<{ wp: RouteWaypoint; score: number }> = [];

  for (let i = 1; i < waypoints.length - 1; i++) {
    const score = perpendicularDistance(waypoints[i], waypoints[0], waypoints[waypoints.length - 1]);
    scores.push({ wp: waypoints[i], score });
  }

  // Sort by score descending (most important first)
  scores.sort((a, b) => b.score - a.score);

  // Keep first and last, plus the top scoring waypoints
  const keepCount = targetCount - 2; // Reserve 2 for first and last
  const keptWaypoints = new Set([waypoints[0].id, waypoints[waypoints.length - 1].id]);

  for (let i = 0; i < Math.min(keepCount, scores.length); i++) {
    keptWaypoints.add(scores[i].wp.id);
  }

  // Return waypoints in original order
  return waypoints.filter((wp) => keptWaypoints.has(wp.id));
}

/**
 * Simplify waypoints across all segments to fit within coordinate limit
 * Distributes available slots proportionally across segments
 */
function simplifyWaypointsToFit(
  waypointsBySegment: Map<number, RouteWaypoint[]>,
  stopCount: number,
  maxCoordinates: number
): { simplified: Map<number, RouteWaypoint[]>; wasSimplified: boolean } {
  // Calculate total waypoint count
  let totalWaypoints = 0;
  waypointsBySegment.forEach((wps) => {
    totalWaypoints += wps.length;
  });

  const totalCoordinates = stopCount + totalWaypoints;

  if (totalCoordinates <= maxCoordinates) {
    return { simplified: waypointsBySegment, wasSimplified: false };
  }

  // We need to reduce waypoints
  const availableForWaypoints = maxCoordinates - stopCount;
  if (availableForWaypoints <= 0) {
    // Can't fit any waypoints
    return { simplified: new Map(), wasSimplified: true };
  }

  // Distribute available slots proportionally
  const simplified = new Map<number, RouteWaypoint[]>();
  const segmentCount = waypointsBySegment.size;

  if (segmentCount === 0) {
    return { simplified, wasSimplified: true };
  }

  // Calculate proportional allocation
  const allocations: Array<{ segmentIndex: number; waypoints: RouteWaypoint[]; allocation: number }> = [];
  waypointsBySegment.forEach((waypoints, segmentIndex) => {
    const proportion = waypoints.length / totalWaypoints;
    const allocation = Math.max(0, Math.floor(proportion * availableForWaypoints));
    allocations.push({ segmentIndex, waypoints, allocation });
  });

  // Distribute any remaining slots to segments with the most waypoints
  let allocated = allocations.reduce((sum, a) => sum + a.allocation, 0);
  let remaining = availableForWaypoints - allocated;

  // Sort by original count descending for fair distribution of remaining
  allocations.sort((a, b) => b.waypoints.length - a.waypoints.length);
  for (let i = 0; remaining > 0 && i < allocations.length; i++) {
    if (allocations[i].allocation < allocations[i].waypoints.length) {
      allocations[i].allocation++;
      remaining--;
    }
  }

  // Apply Douglas-Peucker simplification to each segment
  allocations.forEach(({ segmentIndex, waypoints, allocation }) => {
    if (allocation >= waypoints.length) {
      simplified.set(segmentIndex, waypoints);
    } else if (allocation > 0) {
      simplified.set(segmentIndex, douglasPeuckerSimplify(waypoints, allocation));
    }
    // If allocation is 0, don't add the segment
  });

  return { simplified, wasSimplified: true };
}

/**
 * Hook for calculating routes between stops with optional custom waypoints
 * @param stops - Array of tour stops
 * @param tourType - 'walking' or 'driving' profile for routing
 * @param debounceMs - Debounce delay in milliseconds (default 500ms)
 */
export function useRouteCalculation(
  stops: StopModel[],
  tourType: 'walking' | 'driving' = 'walking',
  debounceMs = 500
): RouteCalculationResult {
  const [geometry, setGeometry] = useState<GeoJSON.LineString | null>(null);
  const [routeInfo, setRouteInfo] = useState<RouteInfo | null>(null);
  const [isCalculating, setIsCalculating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [waypoints, setWaypoints] = useState<RouteWaypoint[]>([]);

  const debounceTimer = useRef<NodeJS.Timeout | null>(null);
  const abortController = useRef<AbortController | null>(null);
  // Store previous route geometry for route-aware waypoint ordering
  const prevRouteGeometryRef = useRef<GeoJSON.LineString | null>(null);

  // Generate unique ID for waypoints
  const generateId = () => `wp_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

  // Add a new waypoint
  const addWaypoint = useCallback((lat: number, lng: number, segmentIndex: number) => {
    const newWaypoint: RouteWaypoint = {
      id: generateId(),
      lat,
      lng,
      segmentIndex,
    };
    setWaypoints((prev) => [...prev, newWaypoint]);
  }, []);

  // Update an existing waypoint's position
  const updateWaypoint = useCallback((id: string, lat: number, lng: number) => {
    setWaypoints((prev) =>
      prev.map((wp) => (wp.id === id ? { ...wp, lat, lng } : wp))
    );
  }, []);

  // Remove a waypoint
  const removeWaypoint = useCallback((id: string) => {
    setWaypoints((prev) => prev.filter((wp) => wp.id !== id));
  }, []);

  // Clear all waypoints
  const clearWaypoints = useCallback(() => {
    setWaypoints([]);
  }, []);

  // Build coordinates array with waypoints inserted at correct positions
  const buildCoordinatesWithWaypoints = useCallback(
    (sortedStops: StopModel[], customWaypoints: RouteWaypoint[]): Array<[number, number]> => {
      if (sortedStops.length < 2) return [];

      // Group waypoints by segment
      const waypointsBySegment = new Map<number, RouteWaypoint[]>();
      customWaypoints.forEach((wp) => {
        const existing = waypointsBySegment.get(wp.segmentIndex) || [];
        existing.push(wp);
        waypointsBySegment.set(wp.segmentIndex, existing);
      });

      const coordinates: Array<[number, number]> = [];
      const prevGeometry = prevRouteGeometryRef.current;

      for (let i = 0; i < sortedStops.length; i++) {
        const stop = sortedStops[i];
        coordinates.push([stop.location.longitude, stop.location.latitude]);

        // Add waypoints for the segment after this stop
        if (i < sortedStops.length - 1) {
          const segmentWaypoints = waypointsBySegment.get(i) || [];
          const startStop = sortedStops[i];
          const endStop = sortedStops[i + 1];

          if (segmentWaypoints.length > 1 && prevGeometry?.coordinates) {
            // Use route-aware ordering: project waypoints onto route geometry
            // Extract the portion of the route for this segment
            const segmentCoords = extractSegmentGeometry(
              prevGeometry.coordinates as Array<[number, number]>,
              startStop.location.longitude,
              startStop.location.latitude,
              endStop.location.longitude,
              endStop.location.latitude
            );

            if (segmentCoords.length >= 2) {
              // Sort by distance along the segment geometry
              segmentWaypoints.sort((a, b) => {
                const distA = distanceAlongLine(a.lng, a.lat, segmentCoords);
                const distB = distanceAlongLine(b.lng, b.lat, segmentCoords);
                return distA - distB;
              });
            } else {
              // Fallback to Euclidean distance if segment extraction fails
              segmentWaypoints.sort((a, b) => {
                const distA = Math.hypot(
                  a.lng - startStop.location.longitude,
                  a.lat - startStop.location.latitude
                );
                const distB = Math.hypot(
                  b.lng - startStop.location.longitude,
                  b.lat - startStop.location.latitude
                );
                return distA - distB;
              });
            }
          } else if (segmentWaypoints.length > 1) {
            // No previous geometry available - use Euclidean distance as fallback
            segmentWaypoints.sort((a, b) => {
              const distA = Math.hypot(
                a.lng - startStop.location.longitude,
                a.lat - startStop.location.latitude
              );
              const distB = Math.hypot(
                b.lng - startStop.location.longitude,
                b.lat - startStop.location.latitude
              );
              return distA - distB;
            });
          }

          segmentWaypoints.forEach((wp) => {
            coordinates.push([wp.lng, wp.lat]);
          });
        }
      }

      return coordinates;
    },
    []
  );

  // Calculate route with debouncing
  useEffect(() => {
    // Clear any existing timer
    if (debounceTimer.current) {
      clearTimeout(debounceTimer.current);
    }

    // Abort any in-flight request
    if (abortController.current) {
      abortController.current.abort();
    }

    // Need at least 2 stops to calculate a route
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

    debounceTimer.current = setTimeout(async () => {
      abortController.current = new AbortController();

      try {
        let coordinates = buildCoordinatesWithWaypoints(sortedStops, waypoints);
        let wasSimplified = false;

        // Mapbox Directions API supports max 25 coordinates
        if (coordinates.length > 25) {
          // Apply intelligent simplification instead of showing error
          const waypointsBySegment = new Map<number, RouteWaypoint[]>();
          waypoints.forEach((wp) => {
            const existing = waypointsBySegment.get(wp.segmentIndex) || [];
            existing.push(wp);
            waypointsBySegment.set(wp.segmentIndex, existing);
          });

          const { simplified, wasSimplified: didSimplify } = simplifyWaypointsToFit(
            waypointsBySegment,
            sortedStops.length,
            25
          );
          wasSimplified = didSimplify;

          // Rebuild coordinates with simplified waypoints
          const simplifiedWaypoints: RouteWaypoint[] = [];
          simplified.forEach((wps) => {
            simplifiedWaypoints.push(...wps);
          });

          coordinates = buildCoordinatesWithWaypoints(sortedStops, simplifiedWaypoints);
        }

        console.log('[useRouteCalculation] Calling getDirections:', {
          coordinatesCount: coordinates.length,
          tourType,
          firstCoord: coordinates[0],
          lastCoord: coordinates[coordinates.length - 1],
          wasSimplified,
        });

        const result = await getDirections(coordinates, tourType);

        console.log('[useRouteCalculation] getDirections result:', {
          success: !!result,
          geometryPoints: result?.geometry?.coordinates?.length || 0,
          distance: result?.distance,
        });

        if (result) {
          setGeometry(result.geometry);
          setRouteInfo({
            distance: result.distance,
            duration: result.duration,
          });
          // Show info message if waypoints were simplified, otherwise clear error
          if (wasSimplified) {
            setError('Route simplified to fit API limits. Some waypoints were merged.');
          } else {
            setError(null);
          }
          // Store geometry for route-aware waypoint ordering on next calculation
          prevRouteGeometryRef.current = result.geometry;
        } else {
          // Fall back to straight lines if routing fails
          setGeometry({
            type: 'LineString',
            coordinates,
          });
          setRouteInfo(null);
          setError('Could not calculate route. Showing straight lines.');
        }
      } catch (err) {
        // Fall back to straight lines on error
        const coordinates = buildCoordinatesWithWaypoints(sortedStops, waypoints);
        setGeometry({
          type: 'LineString',
          coordinates,
        });
        setRouteInfo(null);
        setError('Route calculation failed. Showing straight lines.');
        console.error('Route calculation error:', err);
      } finally {
        setIsCalculating(false);
      }
    }, debounceMs);

    return () => {
      if (debounceTimer.current) {
        clearTimeout(debounceTimer.current);
      }
      if (abortController.current) {
        abortController.current.abort();
      }
    };
  }, [stops, tourType, waypoints, debounceMs, buildCoordinatesWithWaypoints]);

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
