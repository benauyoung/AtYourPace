import 'package:latlong2/latlong.dart';

class MapboxConfig {
  MapboxConfig._();

  // Mapbox access token
  // Get your token from: https://account.mapbox.com/access-tokens/
  static const String accessToken = 'pk.eyJ1IjoiYmVueTg5IiwiYSI6ImNtOHhjZTdsMDAxcTUya3F4Zjk4em1xeXEifQ.Jpq3Q_E3DblgtbMFDFeKbQ';

  // Map styles
  // You can create custom styles at: https://studio.mapbox.com/
  static const String defaultStyle = 'mapbox://styles/mapbox/streets-v12';
  static const String styleStreets = 'mapbox://styles/mapbox/streets-v12';
  static const String outdoorStyle = 'mapbox://styles/mapbox/outdoors-v12';
  static const String satelliteStyle = 'mapbox://styles/mapbox/satellite-streets-v12';
  static const String darkStyle = 'mapbox://styles/mapbox/dark-v11';
  static const String lightStyle = 'mapbox://styles/mapbox/light-v11';

  // TODO: Add your custom style URL if you have one
  static const String customStyle = 'mapbox://styles/YOUR_USERNAME/YOUR_STYLE_ID';

  // Default map settings
  static const double defaultZoom = 15.0;
  static const double minZoom = 5.0;
  static const double maxZoom = 20.0;

  // Default center (will be overridden by user location)
  static const double defaultLatitude = 40.7128;  // New York City
  static const double defaultLongitude = -74.0060;

  /// Default center as LatLng
  static LatLng get defaultCenter => LatLng(defaultLatitude, defaultLongitude);

  // Navigation settings
  static const String navigationProfile = 'mapbox/driving-traffic';
  static const String walkingProfile = 'mapbox/walking';

  // Offline settings
  static const int maxOfflineTiles = 6000;
  static const double offlineMinZoom = 10.0;
  static const double offlineMaxZoom = 16.0;

  // Offline tile storage settings
  static const int maxOfflineDiskQuotaMB = 500;
  static const int tileExpirationDays = 30;

  /// Generate a unique tile region ID for a tour
  static String tileRegionId(String tourId) => 'tour_$tourId';

  /// Bounding box padding percentage (10% on each side)
  static const double boundingBoxPaddingPercent = 0.10;
}
