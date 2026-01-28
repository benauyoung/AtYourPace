'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';
import { MapPin, Search, Loader2, Navigation, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from '@/components/ui/dialog';
import {
  MAPBOX_TOKEN,
  DEFAULT_MAP_CONFIG,
  MAP_STYLES,
  MARKER_COLORS,
} from '@/lib/mapbox/config';
import { forwardGeocode, reverseGeocode } from '@/lib/mapbox/geocoding';

// Set access token - warn if not configured
if (!MAPBOX_TOKEN) {
  console.warn('Mapbox token not configured. Set NEXT_PUBLIC_MAPBOX_TOKEN in .env.local');
} else {
  mapboxgl.accessToken = MAPBOX_TOKEN;
}

interface LocationPickerProps {
  latitude: number;
  longitude: number;
  onLocationChange: (lat: number, lng: number, locationInfo?: LocationInfo) => void;
  disabled?: boolean;
}

export interface LocationInfo {
  city?: string;
  region?: string;
  country?: string;
  address?: string;
}

interface SearchResult {
  name: string;
  coordinates: [number, number];
  placeName: string;
}

export function LocationPicker({
  latitude,
  longitude,
  onLocationChange,
  disabled,
}: LocationPickerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [activeTab, setActiveTab] = useState<'map' | 'address' | 'coordinates'>('map');
  const [tempLat, setTempLat] = useState(latitude.toString());
  const [tempLng, setTempLng] = useState(longitude.toString());
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [selectedLocation, setSelectedLocation] = useState<{ lat: number; lng: number } | null>(null);
  const [locationPreview, setLocationPreview] = useState<string>('');

  const [mapError, setMapError] = useState<string | null>(null);

  // Map refs
  const mapContainer = useRef<HTMLDivElement>(null);
  const mapRef = useRef<mapboxgl.Map | null>(null);
  const markerRef = useRef<mapboxgl.Marker | null>(null);

  // Initialize selected location from props
  useEffect(() => {
    if (latitude && longitude) {
      setSelectedLocation({ lat: latitude, lng: longitude });
      setTempLat(latitude.toString());
      setTempLng(longitude.toString());
    }
  }, [latitude, longitude]);

  // Initialize map when dialog opens on map tab
  useEffect(() => {
    if (!isOpen || activeTab !== 'map' || !mapContainer.current || mapRef.current) return;

    // Check for token before initializing
    if (!MAPBOX_TOKEN) {
      setMapError('Mapbox token not configured. Please use Address or Coordinates tab instead.');
      return;
    }

    try {
      const center: [number, number] = selectedLocation
        ? [selectedLocation.lng, selectedLocation.lat]
        : DEFAULT_MAP_CONFIG.center;

      const map = new mapboxgl.Map({
        container: mapContainer.current,
        style: MAP_STYLES.streets,
        center,
        zoom: selectedLocation ? 14 : DEFAULT_MAP_CONFIG.zoom,
      });

      map.on('error', (e) => {
        console.error('Mapbox error:', e);
        setMapError('Failed to load map. Please use Address or Coordinates tab instead.');
      });

      map.addControl(new mapboxgl.NavigationControl(), 'bottom-right');

      // Add marker at current location
      if (selectedLocation) {
        const marker = new mapboxgl.Marker({ color: MARKER_COLORS.selected })
          .setLngLat([selectedLocation.lng, selectedLocation.lat])
          .addTo(map);
        markerRef.current = marker;
      }

      // Handle click to set location
      map.on('click', async (e) => {
        const { lng, lat } = e.lngLat;
        setSelectedLocation({ lat, lng });
        setTempLat(lat.toFixed(6));
        setTempLng(lng.toFixed(6));

        // Update or create marker
        if (markerRef.current) {
          markerRef.current.setLngLat([lng, lat]);
        } else {
          const marker = new mapboxgl.Marker({ color: MARKER_COLORS.selected })
            .setLngLat([lng, lat])
            .addTo(map);
          markerRef.current = marker;
        }

        // Reverse geocode for preview
        const result = await reverseGeocode(lng, lat);
        if (result) {
          setLocationPreview(result.placeName);
        }
      });

      mapRef.current = map;
      setMapError(null);

      return () => {
        map.remove();
        mapRef.current = null;
        markerRef.current = null;
      };
    } catch (error) {
      console.error('Failed to initialize map:', error);
      setMapError('Failed to initialize map. Please use Address or Coordinates tab instead.');
    }
  }, [isOpen, activeTab, selectedLocation]);

  // Handle address search
  const handleSearch = useCallback(async () => {
    if (!searchQuery.trim()) return;

    setIsSearching(true);
    try {
      const results = await forwardGeocode(searchQuery);
      setSearchResults(results);
    } finally {
      setIsSearching(false);
    }
  }, [searchQuery]);

  // Handle search result selection
  const handleSelectResult = async (result: SearchResult) => {
    const [lng, lat] = result.coordinates;
    setSelectedLocation({ lat, lng });
    setTempLat(lat.toFixed(6));
    setTempLng(lng.toFixed(6));
    setLocationPreview(result.placeName);
    setSearchResults([]);
    setSearchQuery(result.placeName);
  };

  // Handle coordinate input change
  const handleCoordinateChange = () => {
    const lat = parseFloat(tempLat);
    const lng = parseFloat(tempLng);

    if (!isNaN(lat) && !isNaN(lng) && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      setSelectedLocation({ lat, lng });
    }
  };

  // Handle using current device location
  const handleUseCurrentLocation = () => {
    if (!navigator.geolocation) return;

    navigator.geolocation.getCurrentPosition(
      async (position) => {
        const { latitude: lat, longitude: lng } = position.coords;
        setSelectedLocation({ lat, lng });
        setTempLat(lat.toFixed(6));
        setTempLng(lng.toFixed(6));

        // Update map if visible
        if (mapRef.current && markerRef.current) {
          mapRef.current.flyTo({ center: [lng, lat], zoom: 14 });
          markerRef.current.setLngLat([lng, lat]);
        } else if (mapRef.current) {
          mapRef.current.flyTo({ center: [lng, lat], zoom: 14 });
          const marker = new mapboxgl.Marker({ color: MARKER_COLORS.selected })
            .setLngLat([lng, lat])
            .addTo(mapRef.current);
          markerRef.current = marker;
        }

        // Reverse geocode
        const result = await reverseGeocode(lng, lat);
        if (result) {
          setLocationPreview(result.placeName);
        }
      },
      (error) => {
        console.error('Geolocation error:', error);
      }
    );
  };

  // Handle confirm
  const handleConfirm = async () => {
    if (!selectedLocation) return;

    // Get location info from reverse geocoding
    const result = await reverseGeocode(selectedLocation.lng, selectedLocation.lat);
    const locationInfo: LocationInfo | undefined = result
      ? {
          city: result.city,
          region: result.region,
          country: result.country,
          address: result.address,
        }
      : undefined;

    onLocationChange(selectedLocation.lat, selectedLocation.lng, locationInfo);
    setIsOpen(false);
  };

  // Handle dialog close - reset map
  const handleOpenChange = (open: boolean) => {
    setIsOpen(open);
    if (!open) {
      // Clean up map on close
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
        markerRef.current = null;
      }
      // Reset to current values
      setTempLat(latitude.toString());
      setTempLng(longitude.toString());
      setSelectedLocation(latitude && longitude ? { lat: latitude, lng: longitude } : null);
      setSearchQuery('');
      setSearchResults([]);
    }
  };

  // Format display text
  const displayText =
    latitude && longitude
      ? `${latitude.toFixed(4)}, ${longitude.toFixed(4)}`
      : 'Click to set location';

  return (
    <Dialog open={isOpen} onOpenChange={handleOpenChange}>
      <DialogTrigger asChild>
        <Button
          type="button"
          variant="outline"
          className="w-full justify-start text-left font-normal h-auto py-3"
          disabled={disabled}
        >
          <MapPin className="mr-2 h-4 w-4 shrink-0 text-muted-foreground" />
          <div className="flex flex-col items-start gap-0.5">
            <span className="text-sm">{displayText}</span>
            {latitude && longitude && (
              <span className="text-xs text-muted-foreground">Click to change location</span>
            )}
          </div>
        </Button>
      </DialogTrigger>

      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle>Set Start Location</DialogTitle>
          <DialogDescription>
            Choose the starting point for your tour using the map, an address search, or coordinates.
          </DialogDescription>
        </DialogHeader>

        <Tabs value={activeTab} onValueChange={(v) => setActiveTab(v as typeof activeTab)}>
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="map">Map</TabsTrigger>
            <TabsTrigger value="address">Address</TabsTrigger>
            <TabsTrigger value="coordinates">Coordinates</TabsTrigger>
          </TabsList>

          <TabsContent value="map" className="space-y-4">
            <div className="flex items-center gap-2">
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={handleUseCurrentLocation}
              >
                <Navigation className="mr-2 h-4 w-4" />
                Use My Location
              </Button>
              {locationPreview && (
                <span className="text-sm text-muted-foreground truncate flex-1">
                  {locationPreview}
                </span>
              )}
            </div>
            {mapError ? (
              <div className="h-[400px] w-full rounded-lg border flex items-center justify-center bg-muted">
                <div className="text-center p-4">
                  <MapPin className="h-10 w-10 mx-auto mb-2 text-muted-foreground" />
                  <p className="text-sm text-muted-foreground">{mapError}</p>
                </div>
              </div>
            ) : (
              <div
                ref={mapContainer}
                className="h-[400px] w-full rounded-lg border overflow-hidden"
              />
            )}
            <p className="text-sm text-muted-foreground">
              Click on the map to set the start location
            </p>
          </TabsContent>

          <TabsContent value="address" className="space-y-4">
            <div className="space-y-2">
              <Label>Search for an address or place</Label>
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <Input
                    placeholder="e.g., Times Square, New York"
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
                  />
                  {searchQuery && (
                    <Button
                      type="button"
                      variant="ghost"
                      size="icon"
                      className="absolute right-1 top-1/2 -translate-y-1/2 h-7 w-7"
                      onClick={() => {
                        setSearchQuery('');
                        setSearchResults([]);
                      }}
                    >
                      <X className="h-4 w-4" />
                    </Button>
                  )}
                </div>
                <Button type="button" onClick={handleSearch} disabled={isSearching}>
                  {isSearching ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Search className="h-4 w-4" />
                  )}
                </Button>
              </div>
            </div>

            {searchResults.length > 0 && (
              <div className="border rounded-lg divide-y max-h-[300px] overflow-auto">
                {searchResults.map((result, index) => (
                  <button
                    key={index}
                    type="button"
                    className="w-full px-4 py-3 text-left hover:bg-muted transition-colors"
                    onClick={() => handleSelectResult(result)}
                  >
                    <div className="font-medium">{result.name}</div>
                    <div className="text-sm text-muted-foreground truncate">
                      {result.placeName}
                    </div>
                  </button>
                ))}
              </div>
            )}

            {selectedLocation && (
              <div className="p-4 bg-muted rounded-lg">
                <div className="text-sm font-medium">Selected Location</div>
                <div className="text-sm text-muted-foreground">
                  {locationPreview || `${selectedLocation.lat.toFixed(6)}, ${selectedLocation.lng.toFixed(6)}`}
                </div>
              </div>
            )}

            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handleUseCurrentLocation}
            >
              <Navigation className="mr-2 h-4 w-4" />
              Use My Current Location
            </Button>
          </TabsContent>

          <TabsContent value="coordinates" className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="space-y-2">
                <Label htmlFor="latitude">Latitude</Label>
                <Input
                  id="latitude"
                  type="number"
                  step="any"
                  placeholder="e.g., 40.7580"
                  value={tempLat}
                  onChange={(e) => setTempLat(e.target.value)}
                  onBlur={handleCoordinateChange}
                />
                <p className="text-xs text-muted-foreground">Range: -90 to 90</p>
              </div>
              <div className="space-y-2">
                <Label htmlFor="longitude">Longitude</Label>
                <Input
                  id="longitude"
                  type="number"
                  step="any"
                  placeholder="e.g., -73.9855"
                  value={tempLng}
                  onChange={(e) => setTempLng(e.target.value)}
                  onBlur={handleCoordinateChange}
                />
                <p className="text-xs text-muted-foreground">Range: -180 to 180</p>
              </div>
            </div>

            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={handleUseCurrentLocation}
            >
              <Navigation className="mr-2 h-4 w-4" />
              Use My Current Location
            </Button>

            {selectedLocation && (
              <div className="p-4 bg-muted rounded-lg">
                <div className="text-sm font-medium">Preview</div>
                <div className="text-sm text-muted-foreground">
                  Latitude: {selectedLocation.lat.toFixed(6)}, Longitude: {selectedLocation.lng.toFixed(6)}
                </div>
              </div>
            )}
          </TabsContent>
        </Tabs>

        <DialogFooter>
          <Button type="button" variant="outline" onClick={() => handleOpenChange(false)}>
            Cancel
          </Button>
          <Button
            type="button"
            onClick={handleConfirm}
            disabled={!selectedLocation}
          >
            Confirm Location
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
