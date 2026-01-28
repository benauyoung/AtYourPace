import { MAPBOX_TOKEN } from './config';

export interface GeocodingResult {
  placeName: string;
  shortName: string;
  address?: string;
  city?: string;
  region?: string;
  country?: string;
  postcode?: string;
}

/**
 * Reverse geocode coordinates to get place name
 */
export async function reverseGeocode(
  longitude: number,
  latitude: number
): Promise<GeocodingResult | null> {
  if (!MAPBOX_TOKEN) {
    console.warn('Mapbox token not configured');
    return null;
  }

  try {
    const response = await fetch(
      `https://api.mapbox.com/geocoding/v5/mapbox.places/${longitude},${latitude}.json?access_token=${MAPBOX_TOKEN}&types=poi,address,place`
    );

    if (!response.ok) {
      throw new Error(`Geocoding failed: ${response.statusText}`);
    }

    const data = await response.json();

    if (!data.features || data.features.length === 0) {
      return null;
    }

    const feature = data.features[0];
    const context = feature.context || [];

    // Extract components from context
    const getContextValue = (type: string) => {
      const item = context.find((c: { id: string; text: string }) => c.id.startsWith(type));
      return item?.text || undefined;
    };

    // Generate a short name for the stop
    let shortName = feature.text || 'Unknown Location';

    // If it's a POI, use the POI name
    if (feature.place_type.includes('poi')) {
      shortName = feature.text;
    } else if (feature.place_type.includes('address')) {
      // For addresses, use the address number and street
      shortName = feature.address
        ? `${feature.address} ${feature.text}`
        : feature.text;
    }

    return {
      placeName: feature.place_name,
      shortName,
      address: feature.place_type.includes('address') ? feature.place_name.split(',')[0] : undefined,
      city: getContextValue('place'),
      region: getContextValue('region'),
      country: getContextValue('country'),
      postcode: getContextValue('postcode'),
    };
  } catch (error) {
    console.error('Reverse geocoding error:', error);
    return null;
  }
}

/**
 * Forward geocode a search query to coordinates
 */
export async function forwardGeocode(
  query: string,
  proximity?: [number, number]
): Promise<Array<{
  name: string;
  coordinates: [number, number];
  placeName: string;
}>> {
  if (!MAPBOX_TOKEN) {
    console.warn('Mapbox token not configured');
    return [];
  }

  try {
    let url = `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=${MAPBOX_TOKEN}&limit=5`;

    if (proximity) {
      url += `&proximity=${proximity[0]},${proximity[1]}`;
    }

    const response = await fetch(url);

    if (!response.ok) {
      throw new Error(`Geocoding failed: ${response.statusText}`);
    }

    const data = await response.json();

    return (data.features || []).map((feature: {
      text: string;
      center: [number, number];
      place_name: string;
    }) => ({
      name: feature.text,
      coordinates: feature.center,
      placeName: feature.place_name,
    }));
  } catch (error) {
    console.error('Forward geocoding error:', error);
    return [];
  }
}

/**
 * Snap a coordinate to the nearest road using Mapbox Map Matching API
 * @param lng - Longitude
 * @param lat - Latitude
 * @param profile - Routing profile ('walking' or 'driving')
 * @returns Snapped coordinate or original if snapping fails
 */
export async function snapToRoad(
  lng: number,
  lat: number,
  profile: 'walking' | 'driving' = 'walking'
): Promise<{ lng: number; lat: number; snapped: boolean }> {
  if (!MAPBOX_TOKEN) {
    return { lng, lat, snapped: false };
  }

  try {
    // Map Matching API requires at least 2 coordinates, so we create a tiny segment
    // Use a small offset (~5 meters) in a random direction
    const offsetLng = lng + 0.00005;
    const offsetLat = lat + 0.00005;

    const coordinates = `${lng},${lat};${offsetLng},${offsetLat}`;
    const response = await fetch(
      `https://api.mapbox.com/matching/v5/mapbox/${profile}/${coordinates}?access_token=${MAPBOX_TOKEN}&geometries=geojson&radiuses=50;50`
    );

    if (!response.ok) {
      console.warn('Map Matching API request failed:', response.statusText);
      return { lng, lat, snapped: false };
    }

    const data = await response.json();

    if (!data.matchings || data.matchings.length === 0 || !data.tracepoints) {
      // No match found, return original
      return { lng, lat, snapped: false };
    }

    // Get the snapped location for the first point
    const tracepoint = data.tracepoints[0];
    if (tracepoint && tracepoint.location) {
      return {
        lng: tracepoint.location[0],
        lat: tracepoint.location[1],
        snapped: true,
      };
    }

    return { lng, lat, snapped: false };
  } catch (error) {
    console.error('Map Matching API error:', error);
    return { lng, lat, snapped: false };
  }
}

/**
 * Get directions between two points using Mapbox Directions API
 */
export async function getDirections(
  coordinates: Array<[number, number]>,
  profile: 'walking' | 'driving' = 'walking'
): Promise<{
  geometry: GeoJSON.LineString;
  distance: number; // meters
  duration: number; // seconds
} | null> {
  if (!MAPBOX_TOKEN || coordinates.length < 2) {
    return null;
  }

  try {
    const coordinatesString = coordinates.map((c) => c.join(',')).join(';');
    const response = await fetch(
      `https://api.mapbox.com/directions/v5/mapbox/${profile}/${coordinatesString}?access_token=${MAPBOX_TOKEN}&geometries=geojson&overview=full`
    );

    if (!response.ok) {
      throw new Error(`Directions API failed: ${response.statusText}`);
    }

    const data = await response.json();

    if (!data.routes || data.routes.length === 0) {
      return null;
    }

    const route = data.routes[0];
    return {
      geometry: route.geometry,
      distance: route.distance,
      duration: route.duration,
    };
  } catch (error) {
    console.error('Directions API error:', error);
    return null;
  }
}
