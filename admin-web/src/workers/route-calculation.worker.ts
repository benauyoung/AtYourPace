/* eslint-disable no-restricted-globals */

// Types needed for the worker
export interface RouteWaypoint {
    id: string;
    lat: number;
    lng: number;
    segmentIndex: number;
}

export interface StopModel {
    id: string;
    order: number;
    location: {
        latitude: number;
        longitude: number;
    };
}

// Input message format
export type WorkerMessage = {
    type: 'CALCULATE_COORDINATES';
    stops: StopModel[];
    waypoints: RouteWaypoint[];
    prevGeometryCoords?: number[][]; // [lng, lat][]
    maxCoordinates?: number;
};


// --- Helper Functions (Moved from hook) ---

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

function distanceAlongLine(
    waypointLng: number,
    waypointLat: number,
    routeCoordinates: number[][]
): number {
    let cumulativeDistance = 0;
    let minDistanceToLine = Infinity;
    let distanceAtClosest = 0;

    for (let i = 0; i < routeCoordinates.length - 1; i++) {
        const [lng1, lat1] = routeCoordinates[i];
        const [lng2, lat2] = routeCoordinates[i + 1];

        const segmentLength = haversineDistance(lat1, lng1, lat2, lng2);

        if (segmentLength === 0) {
            const distToPoint = haversineDistance(waypointLat, waypointLng, lat1, lng1);
            if (distToPoint < minDistanceToLine) {
                minDistanceToLine = distToPoint;
                distanceAtClosest = cumulativeDistance;
            }
        } else {
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
                distanceAtClosest =
                    cumulativeDistance + haversineDistance(lat1, lng1, closestLat, closestLng);
            }
        }

        cumulativeDistance += segmentLength;
    }

    return distanceAtClosest;
}

function extractSegmentGeometry(
    routeCoordinates: number[][],
    startLng: number,
    startLat: number,
    endLng: number,
    endLat: number
): number[][] {
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

    if (startIdx > endIdx) {
        [startIdx, endIdx] = [endIdx, startIdx];
    }

    return routeCoordinates.slice(startIdx, endIdx + 1);
}

function douglasPeuckerSimplify(
    waypoints: RouteWaypoint[],
    targetCount: number
): RouteWaypoint[] {
    if (waypoints.length <= targetCount) return waypoints;
    if (waypoints.length <= 2) return waypoints;

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

    const scores: Array<{ wp: RouteWaypoint; score: number }> = [];

    for (let i = 1; i < waypoints.length - 1; i++) {
        const score = perpendicularDistance(waypoints[i], waypoints[0], waypoints[waypoints.length - 1]);
        scores.push({ wp: waypoints[i], score });
    }

    scores.sort((a, b) => b.score - a.score);

    const keepCount = targetCount - 2;
    const keptWaypoints = new Set([waypoints[0].id, waypoints[waypoints.length - 1].id]);

    for (let i = 0; i < Math.min(keepCount, scores.length); i++) {
        keptWaypoints.add(scores[i].wp.id);
    }

    return waypoints.filter((wp) => keptWaypoints.has(wp.id));
}

function simplifyWaypointsToFit(
    waypointsBySegment: Map<number, RouteWaypoint[]>,
    stopCount: number,
    maxCoordinates: number
): { simplified: Map<number, RouteWaypoint[]>; wasSimplified: boolean } {
    let totalWaypoints = 0;
    waypointsBySegment.forEach((wps) => {
        totalWaypoints += wps.length;
    });

    const totalCoordinates = stopCount + totalWaypoints;

    if (totalCoordinates <= maxCoordinates) {
        return { simplified: waypointsBySegment, wasSimplified: false };
    }

    const availableForWaypoints = maxCoordinates - stopCount;
    if (availableForWaypoints <= 0) {
        return { simplified: new Map(), wasSimplified: true };
    }

    const simplified = new Map<number, RouteWaypoint[]>();
    const segmentCount = waypointsBySegment.size;

    if (segmentCount === 0) {
        return { simplified, wasSimplified: true };
    }

    const allocations: Array<{ segmentIndex: number; waypoints: RouteWaypoint[]; allocation: number }> = [];
    waypointsBySegment.forEach((waypoints, segmentIndex) => {
        const proportion = waypoints.length / totalWaypoints;
        const allocation = Math.max(0, Math.floor(proportion * availableForWaypoints));
        allocations.push({ segmentIndex, waypoints, allocation });
    });

    let allocated = allocations.reduce((sum, a) => sum + a.allocation, 0);
    let remaining = availableForWaypoints - allocated;

    allocations.sort((a, b) => b.waypoints.length - a.waypoints.length);
    for (let i = 0; remaining > 0 && i < allocations.length; i++) {
        if (allocations[i].allocation < allocations[i].waypoints.length) {
            allocations[i].allocation++;
            remaining--;
        }
    }

    allocations.forEach(({ segmentIndex, waypoints, allocation }) => {
        if (allocation >= waypoints.length) {
            simplified.set(segmentIndex, waypoints);
        } else if (allocation > 0) {
            simplified.set(segmentIndex, douglasPeuckerSimplify(waypoints, allocation));
        }
    });

    return { simplified, wasSimplified: true };
}

function buildCoordinatesWithWaypoints(
    sortedStops: StopModel[],
    customWaypoints: RouteWaypoint[],
    prevGeometryCoords?: number[][]
): number[][] {
    if (sortedStops.length < 2) return [];

    const waypointsBySegment = new Map<number, RouteWaypoint[]>();
    customWaypoints.forEach((wp) => {
        const existing = waypointsBySegment.get(wp.segmentIndex) || [];
        existing.push(wp);
        waypointsBySegment.set(wp.segmentIndex, existing);
    });

    const coordinates: number[][] = [];

    for (let i = 0; i < sortedStops.length; i++) {
        const stop = sortedStops[i];
        coordinates.push([stop.location.longitude, stop.location.latitude]);

        if (i < sortedStops.length - 1) {
            const segmentWaypoints = waypointsBySegment.get(i) || [];
            const startStop = sortedStops[i];
            const endStop = sortedStops[i + 1];

            if (segmentWaypoints.length > 1 && prevGeometryCoords) {
                const segmentCoords = extractSegmentGeometry(
                    prevGeometryCoords,
                    startStop.location.longitude,
                    startStop.location.latitude,
                    endStop.location.longitude,
                    endStop.location.latitude
                );

                if (segmentCoords.length >= 2) {
                    segmentWaypoints.sort((a, b) => {
                        const distA = distanceAlongLine(a.lng, a.lat, segmentCoords);
                        const distB = distanceAlongLine(b.lng, b.lat, segmentCoords);
                        return distA - distB;
                    });
                } else {
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
}


// --- Main Message Listener ---

self.onmessage = (event: MessageEvent<WorkerMessage>) => {
    const { type, stops, waypoints, prevGeometryCoords, maxCoordinates } = event.data;

    if (type === 'CALCULATE_COORDINATES') {
        const sortedStops = [...stops].sort((a, b) => a.order - b.order);

        // 1. Initial build
        let coordinates = buildCoordinatesWithWaypoints(sortedStops, waypoints, prevGeometryCoords);
        let wasSimplified = false;
        let simplifiedWaypoints: RouteWaypoint[] = [...waypoints];

        // 2. Check limits and simplify if needed
        if (maxCoordinates && coordinates.length > maxCoordinates) {
            const waypointsBySegment = new Map<number, RouteWaypoint[]>();
            waypoints.forEach((wp) => {
                const existing = waypointsBySegment.get(wp.segmentIndex) || [];
                existing.push(wp);
                waypointsBySegment.set(wp.segmentIndex, existing);
            });

            const { simplified, wasSimplified: didSimplify } = simplifyWaypointsToFit(
                waypointsBySegment,
                sortedStops.length,
                maxCoordinates
            );
            wasSimplified = didSimplify;

            // Re-flatten simplified waypoints
            simplifiedWaypoints = [];
            simplified.forEach((wps) => {
                simplifiedWaypoints.push(...wps);
            });

            // Re-build coordinates
            coordinates = buildCoordinatesWithWaypoints(sortedStops, simplifiedWaypoints, prevGeometryCoords);
        }

        self.postMessage({
            coordinates,
            wasSimplified,
            simplifiedWaypoints, // Send back so main thread knows what was kept (optional)
        });
    }
};
