import 'dart:math';

class GeohashUtils {
  GeohashUtils._();

  static const String _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Encodes a latitude and longitude into a geohash string.
  ///
  /// [precision] determines the length of the geohash (1-12).
  /// Higher precision = smaller area.
  /// - precision 1: ~5000km x 5000km
  /// - precision 5: ~5km x 5km
  /// - precision 6: ~1.2km x 0.6km
  /// - precision 7: ~150m x 150m
  /// - precision 8: ~40m x 20m
  /// - precision 9: ~5m x 5m
  static String encode(double latitude, double longitude, {int precision = 9}) {
    double minLat = -90.0;
    double maxLat = 90.0;
    double minLon = -180.0;
    double maxLon = 180.0;

    StringBuffer hash = StringBuffer();
    int bit = 0;
    int ch = 0;
    bool isEven = true;

    while (hash.length < precision) {
      if (isEven) {
        double mid = (minLon + maxLon) / 2;
        if (longitude >= mid) {
          ch |= (1 << (4 - bit));
          minLon = mid;
        } else {
          maxLon = mid;
        }
      } else {
        double mid = (minLat + maxLat) / 2;
        if (latitude >= mid) {
          ch |= (1 << (4 - bit));
          minLat = mid;
        } else {
          maxLat = mid;
        }
      }

      isEven = !isEven;
      bit++;

      if (bit == 5) {
        hash.write(_base32[ch]);
        bit = 0;
        ch = 0;
      }
    }

    return hash.toString();
  }

  /// Decodes a geohash into a bounding box.
  /// Returns [minLat, minLon, maxLat, maxLon].
  static List<double> decode(String geohash) {
    double minLat = -90.0;
    double maxLat = 90.0;
    double minLon = -180.0;
    double maxLon = 180.0;

    bool isEven = true;

    for (int i = 0; i < geohash.length; i++) {
      int ch = _base32.indexOf(geohash[i]);
      for (int bit = 4; bit >= 0; bit--) {
        int mask = 1 << bit;
        if (isEven) {
          double mid = (minLon + maxLon) / 2;
          if ((ch & mask) != 0) {
            minLon = mid;
          } else {
            maxLon = mid;
          }
        } else {
          double mid = (minLat + maxLat) / 2;
          if ((ch & mask) != 0) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }
        isEven = !isEven;
      }
    }

    return [minLat, minLon, maxLat, maxLon];
  }

  /// Returns the center point of a geohash.
  static ({double latitude, double longitude}) decodeCenter(String geohash) {
    final bounds = decode(geohash);
    return (
      latitude: (bounds[0] + bounds[2]) / 2,
      longitude: (bounds[1] + bounds[3]) / 2,
    );
  }

  /// Returns all neighboring geohashes including the center one.
  /// Useful for geospatial queries to ensure coverage at boundaries.
  static List<String> neighbors(String geohash) {
    final center = decodeCenter(geohash);
    final bounds = decode(geohash);

    final latDelta = bounds[2] - bounds[0];
    final lonDelta = bounds[3] - bounds[1];

    final List<String> result = [];

    for (int latOffset = -1; latOffset <= 1; latOffset++) {
      for (int lonOffset = -1; lonOffset <= 1; lonOffset++) {
        final lat = center.latitude + (latOffset * latDelta);
        final lon = center.longitude + (lonOffset * lonDelta);

        // Validate bounds
        if (lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
          result.add(encode(lat, lon, precision: geohash.length));
        }
      }
    }

    return result.toSet().toList(); // Remove duplicates
  }

  /// Returns the appropriate geohash precision for a given radius in meters.
  /// Useful for determining query precision based on search radius.
  static int precisionForRadius(double radiusMeters) {
    // Approximate cell sizes at equator (worst case)
    const precisionToMeters = [
      5000000.0, // 1
      1250000.0, // 2
      156000.0,  // 3
      39000.0,   // 4
      5000.0,    // 5
      1200.0,    // 6
      150.0,     // 7
      40.0,      // 8
      5.0,       // 9
    ];

    for (int i = 0; i < precisionToMeters.length; i++) {
      if (radiusMeters >= precisionToMeters[i]) {
        return i + 1;
      }
    }
    return 9; // Maximum precision
  }

  /// Calculates the distance between two points in meters using Haversine formula.
  static double distanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
