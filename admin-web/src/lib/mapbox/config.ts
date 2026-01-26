// Mapbox configuration
// Note: In production, this should be stored as an environment variable
export const MAPBOX_TOKEN = process.env.NEXT_PUBLIC_MAPBOX_TOKEN || '';

// Map styles
export const MAP_STYLES = {
  streets: 'mapbox://styles/mapbox/streets-v12',
  outdoors: 'mapbox://styles/mapbox/outdoors-v12',
  light: 'mapbox://styles/mapbox/light-v11',
  dark: 'mapbox://styles/mapbox/dark-v11',
  satellite: 'mapbox://styles/mapbox/satellite-streets-v12',
} as const;

export type MapStyleKey = keyof typeof MAP_STYLES;

// Default map settings
export const DEFAULT_MAP_CONFIG = {
  style: MAP_STYLES.streets,
  center: [-122.4194, 37.7749] as [number, number], // San Francisco
  zoom: 13,
  minZoom: 3,
  maxZoom: 20,
};

// Marker colors for different states
export const MARKER_COLORS = {
  default: '#3D7A8C', // Primary teal
  selected: '#E8967A', // Accent coral
  hover: '#5A9AAD', // Lighter teal
  inactive: '#A0AEC0', // Muted gray
} as const;

// Route line styling
export const ROUTE_LINE_STYLE = {
  color: '#3D7A8C',
  width: 4,
  opacity: 0.8,
  dashArray: [2, 1], // Dashed line for draft routes
} as const;

// Default trigger radius in meters
export const DEFAULT_TRIGGER_RADIUS = 50;
export const MIN_TRIGGER_RADIUS = 10;
export const MAX_TRIGGER_RADIUS = 500;
