# API Integrations Documentation

**Last Updated**: January 30, 2026  
**Purpose**: Complete specification for all external API integrations in the Tour Manager rebuild

---

## Table of Contents

1. [Overview](#overview)
2. [Mapbox Integration](#mapbox-integration)
3. [ElevenLabs Integration](#elevenlabs-integration)
4. [Stripe Integration](#stripe-integration)
5. [Firebase Cloud Functions](#firebase-cloud-functions)
6. [Error Handling](#error-handling)
7. [Rate Limiting](#rate-limiting)
8. [Security](#security)

---

## Overview

The Tour Manager rebuild integrates with three primary external services:

1. **Mapbox** - Route editing, snapping, and visualization
2. **ElevenLabs** - AI voice generation for tour narration
3. **Stripe** - Payment processing (placeholder for future)

Additionally, we use **Firebase Cloud Functions** for server-side processing.

---

## Mapbox Integration

### Purpose
- Visual route editing with interactive maps
- Auto-snapping routes to roads/walking paths
- Route distance and duration calculation
- Geocoding and reverse geocoding

### APIs Used

#### 1. Mapbox GL JS
**Purpose**: Interactive map rendering

**Implementation**:
```dart
// lib/presentation/screens/modules/route_editor/widgets/interactive_map.dart

import 'package:mapbox_gl/mapbox_gl.dart';

class InteractiveMap extends StatefulWidget {
  final List<LatLng> waypoints;
  final Function(LatLng) onWaypointAdded;
  final Function(String, LatLng) onWaypointMoved;
  
  @override
  _InteractiveMapState createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  MapboxMapController? _mapController;
  
  @override
  Widget build(BuildContext context) {
    return MapboxMap(
      accessToken: MapboxConfig.accessToken,
      styleString: MapboxStyles.MAPBOX_STREETS,
      initialCameraPosition: CameraPosition(
        target: LatLng(48.8566, 2.3522), // Paris
        zoom: 12.0,
      ),
      onMapCreated: _onMapCreated,
      onMapClick: _onMapClick,
    );
  }
  
  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
    _drawWaypoints();
    _drawRoute();
  }
  
  void _onMapClick(Point<double> point, LatLng coordinates) {
    widget.onWaypointAdded(coordinates);
  }
}
```

**Configuration**:
```dart
// lib/core/config/mapbox_config.dart

class MapboxConfig {
  static const String accessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '', // Set in .env file
  );
  
  static const String styleUrl = 'mapbox://styles/mapbox/streets-v11';
  
  static const double defaultZoom = 12.0;
  static const LatLng defaultCenter = LatLng(48.8566, 2.3522); // Paris
}
```

#### 2. Mapbox Directions API
**Purpose**: Route snapping and optimization

**Endpoint**: `https://api.mapbox.com/directions/v5/mapbox/{profile}/{coordinates}`

**Profiles**:
- `walking` - For walking tours
- `driving` - For driving tours

**Implementation**:
```dart
// lib/data/services/route_snapping_service.dart

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class RouteSnappingService {
  final Dio _dio;
  
  RouteSnappingService(this._dio);
  
  Future<RouteSnapResult> snapToRoads(
    List<LatLng> waypoints,
    TourType tourType,
  ) async {
    final profile = tourType == TourType.walking ? 'walking' : 'driving';
    
    // Format coordinates as "lng,lat;lng,lat;..."
    final coordinates = waypoints
        .map((w) => '${w.longitude},${w.latitude}')
        .join(';');
    
    try {
      final response = await _dio.get(
        'https://api.mapbox.com/directions/v5/mapbox/$profile/$coordinates',
        queryParameters: {
          'access_token': MapboxConfig.accessToken,
          'geometries': 'geojson',
          'overview': 'full',
          'steps': true,
          'alternatives': false,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final route = data['routes'][0];
        
        // Extract polyline
        final geometry = route['geometry']['coordinates'] as List;
        final polyline = geometry
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();
        
        // Extract distance and duration
        final distance = route['distance'] as double; // meters
        final duration = route['duration'] as int; // seconds
        
        return RouteSnapResult(
          polyline: polyline,
          distance: distance,
          duration: duration,
          success: true,
        );
      }
      
      throw Exception('Failed to snap route: ${response.statusCode}');
    } catch (e) {
      return RouteSnapResult(
        polyline: waypoints, // Fallback to straight lines
        distance: _calculateStraightDistance(waypoints),
        duration: _estimateDuration(waypoints, tourType),
        success: false,
        error: e.toString(),
      );
    }
  }
  
  double _calculateStraightDistance(List<LatLng> waypoints) {
    double total = 0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      total += Distance().as(
        LengthUnit.Meter,
        waypoints[i],
        waypoints[i + 1],
      );
    }
    return total;
  }
  
  int _estimateDuration(List<LatLng> waypoints, TourType tourType) {
    final distance = _calculateStraightDistance(waypoints);
    final speed = tourType == TourType.walking ? 1.4 : 13.9; // m/s
    return (distance / speed).round();
  }
}

class RouteSnapResult {
  final List<LatLng> polyline;
  final double distance;
  final int duration;
  final bool success;
  final String? error;
  
  RouteSnapResult({
    required this.polyline,
    required this.distance,
    required this.duration,
    required this.success,
    this.error,
  });
}
```

**Rate Limits**:
- Free tier: 100,000 requests/month
- Monitor usage in Mapbox dashboard
- Implement caching for repeated routes

**Error Handling**:
```dart
try {
  final result = await routeSnappingService.snapToRoads(waypoints, tourType);
  if (!result.success) {
    // Show warning but allow manual route
    showSnackBar('Route snapping failed. Using manual mode.');
  }
} catch (e) {
  // Fallback to straight lines
  showSnackBar('Unable to snap route. Drawing straight lines.');
}
```

---

## ElevenLabs Integration

### Purpose
- AI voice generation for tour stop narration
- Text-to-speech with natural-sounding voices
- Multiple voice options (4 regional voices)

### API Details

**Base URL**: `https://api.elevenlabs.io/v1`

**Authentication**: API Key in header
```
xi-api-key: YOUR_API_KEY
```

**Endpoints Used**:
1. `/text-to-speech/{voice_id}` - Generate audio from text
2. `/voices` - List available voices

### Implementation

```dart
// lib/data/services/voice_generation_service.dart

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VoiceGenerationService {
  final Dio _dio;
  final FirebaseStorage _storage;
  
  static const String baseUrl = 'https://api.elevenlabs.io/v1';
  static const String apiKey = String.fromEnvironment('ELEVENLABS_API_KEY');
  
  VoiceGenerationService(this._dio, this._storage) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['xi-api-key'] = apiKey;
  }
  
  Future<VoiceGenerationResult> generateVoice({
    required String script,
    required String voiceId,
    required String stopId,
  }) async {
    try {
      // Step 1: Generate audio via ElevenLabs
      final response = await _dio.post(
        '/text-to-speech/$voiceId',
        data: {
          'text': script,
          'model_id': 'eleven_monolingual_v1',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
          },
        },
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      
      if (response.statusCode == 200) {
        final audioBytes = response.data as List<int>;
        
        // Step 2: Upload to Firebase Storage
        final fileName = 'voice_${stopId}_${DateTime.now().millisecondsSinceEpoch}.mp3';
        final ref = _storage.ref().child('tour_audio/$fileName');
        
        await ref.putData(
          Uint8List.fromList(audioBytes),
          SettableMetadata(contentType: 'audio/mpeg'),
        );
        
        final downloadUrl = await ref.getDownloadURL();
        
        // Step 3: Get audio duration (estimate from script)
        final duration = _estimateDuration(script);
        
        return VoiceGenerationResult(
          audioUrl: downloadUrl,
          duration: duration,
          success: true,
        );
      }
      
      throw Exception('Failed to generate voice: ${response.statusCode}');
    } catch (e) {
      return VoiceGenerationResult(
        audioUrl: null,
        duration: 0,
        success: false,
        error: e.toString(),
      );
    }
  }
  
  int _estimateDuration(String script) {
    final wordCount = script.split(' ').length;
    return (wordCount / 150 * 60).round(); // 150 words per minute
  }
  
  Future<List<VoiceInfo>> getAvailableVoices() async {
    try {
      final response = await _dio.get('/voices');
      
      if (response.statusCode == 200) {
        final voices = (response.data['voices'] as List)
            .map((v) => VoiceInfo.fromJson(v))
            .toList();
        return voices;
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }
}

class VoiceGenerationResult {
  final String? audioUrl;
  final int duration;
  final bool success;
  final String? error;
  
  VoiceGenerationResult({
    required this.audioUrl,
    required this.duration,
    required this.success,
    this.error,
  });
}

class VoiceInfo {
  final String voiceId;
  final String name;
  final String description;
  
  VoiceInfo({
    required this.voiceId,
    required this.name,
    required this.description,
  });
  
  factory VoiceInfo.fromJson(Map<String, dynamic> json) {
    return VoiceInfo(
      voiceId: json['voice_id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }
}
```

### Voice Configuration

**Predefined Voices**:
```dart
// lib/core/config/voice_config.dart

class VoiceConfig {
  static const List<VoiceOption> availableVoices = [
    VoiceOption(
      id: 'EXAVITQu4vr4xnSDxMaL', // Example ID
      name: 'Sophie',
      description: 'Warm, friendly female voice',
      accent: 'French',
      gender: 'Female',
    ),
    VoiceOption(
      id: 'ErXwobaYiN019PkySvjV', // Example ID
      name: 'Pierre',
      description: 'Professional male voice',
      accent: 'French',
      gender: 'Male',
    ),
    VoiceOption(
      id: 'ThT5KcBeYPX3keUQqHPh', // Example ID
      name: 'Emma',
      description: 'Clear, articulate female voice',
      accent: 'British English',
      gender: 'Female',
    ),
    VoiceOption(
      id: 'pNInz6obpgDQGcFmaJgB', // Example ID
      name: 'James',
      description: 'Engaging male narrator',
      accent: 'American English',
      gender: 'Male',
    ),
  ];
}
```

### Rate Limits & Costs

**Free Tier**:
- 10,000 characters/month
- ~30 minutes of audio

**Paid Tier** (Starter - $5/month):
- 30,000 characters/month
- ~90 minutes of audio

**Character Limit**:
- Max 1000 characters per request
- Enforce in UI to prevent exceeding limits

**Cost Estimation**:
```dart
class VoiceCostEstimator {
  static const int charactersPerDollar = 6000; // Approximate
  
  static double estimateCost(String script) {
    final charCount = script.length;
    return charCount / charactersPerDollar;
  }
  
  static String formatCost(double cost) {
    if (cost < 0.01) return 'Less than $0.01';
    return '\$${cost.toStringAsFixed(2)}';
  }
}
```

### Error Handling

```dart
try {
  final result = await voiceGenerationService.generateVoice(
    script: script,
    voiceId: voiceId,
    stopId: stopId,
  );
  
  if (!result.success) {
    if (result.error?.contains('quota') ?? false) {
      showError('Voice generation quota exceeded. Please upgrade your plan.');
    } else if (result.error?.contains('invalid_api_key') ?? false) {
      showError('Voice generation service unavailable. Please contact support.');
    } else {
      showError('Failed to generate voice. Please try again.');
    }
  }
} catch (e) {
  showError('Voice generation failed: ${e.toString()}');
}
```

---

## Stripe Integration

### Purpose
- Payment processing for paid tours (future feature)
- Subscription management (future feature)
- Revenue tracking

### Status
**PLACEHOLDER ONLY** - Not implementing in initial rebuild

### Planned Implementation

**Stripe Elements** for web:
```dart
// Future implementation
class StripePaymentService {
  // Placeholder for future Stripe integration
  
  Future<PaymentResult> processPayment({
    required String tourId,
    required double amount,
    required String currency,
  }) async {
    // TODO: Implement Stripe payment processing
    throw UnimplementedError('Stripe integration coming soon');
  }
}
```

**Pricing Model** already supports Stripe:
```dart
@freezed
class PricingModel with _$PricingModel {
  const factory PricingModel({
    required String tourId,
    @Default(PricingType.free) PricingType type,
    double? price,
    @Default('EUR') String currency,
    // Stripe fields ready for future use
    String? stripeProductId,
    String? stripePriceId,
    @Default([]) List<PricingTier> tiers,
  }) = _PricingModel;
}
```

---

## Firebase Cloud Functions

### Purpose
- Analytics aggregation (batch processing)
- Tour submission notifications
- Automated cleanup tasks

### Functions to Create

#### 1. Analytics Aggregation
```javascript
// functions/src/analytics/aggregateTourAnalytics.js

const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.aggregateTourAnalytics = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = new Date();
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
    
    // Get all tours
    const toursSnapshot = await db.collection('tours').get();
    
    for (const tourDoc of toursSnapshot.docs) {
      const tourId = tourDoc.id;
      
      // Aggregate plays
      const playsSnapshot = await db
        .collection('tour_plays')
        .where('tourId', '==', tourId)
        .where('startedAt', '>=', oneHourAgo)
        .get();
      
      const plays = playsSnapshot.size;
      const uniqueUsers = new Set(playsSnapshot.docs.map(d => d.data().userId)).size;
      
      // Aggregate downloads
      const downloadsSnapshot = await db
        .collection('tour_downloads')
        .where('tourId', '==', tourId)
        .where('downloadedAt', '>=', oneHourAgo)
        .get();
      
      const downloads = downloadsSnapshot.size;
      
      // Store aggregated data
      await db
        .collection('analytics')
        .doc(tourId)
        .collection('hourly')
        .doc(now.toISOString())
        .set({
          tourId,
          period: 'hour',
          startDate: oneHourAgo,
          endDate: now,
          plays: {
            total: plays,
            unique: uniqueUsers,
          },
          downloads: {
            total: downloads,
          },
          generatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    }
    
    console.log('Analytics aggregation completed');
  });
```

#### 2. Submission Notifications
```javascript
// functions/src/publishing/onSubmissionCreated.js

exports.onSubmissionCreated = functions.firestore
  .document('publishing_submissions/{submissionId}')
  .onCreate(async (snap, context) => {
    const submission = snap.data();
    
    // Get admin users
    const adminsSnapshot = await admin
      .firestore()
      .collection('users')
      .where('role', '==', 'admin')
      .get();
    
    // Send notification to each admin (placeholder)
    // TODO: Implement email/push notifications
    
    console.log(`New submission ${context.params.submissionId} created`);
  });
```

---

## Error Handling

### Global Error Handler

```dart
// lib/core/error/api_error_handler.dart

class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
        case DioErrorType.sendTimeout:
        case DioErrorType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        
        case DioErrorType.response:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Authentication failed. Please check your API keys.';
          } else if (statusCode == 429) {
            return 'Rate limit exceeded. Please try again later.';
          } else if (statusCode == 500) {
            return 'Server error. Please try again later.';
          }
          return 'Request failed: ${error.response?.statusMessage}';
        
        case DioErrorType.cancel:
          return 'Request cancelled.';
        
        default:
          return 'Network error. Please check your connection.';
      }
    }
    
    return error.toString();
  }
}
```

---

## Rate Limiting

### Client-Side Rate Limiting

```dart
// lib/core/utils/rate_limiter.dart

class RateLimiter {
  final Map<String, List<DateTime>> _requests = {};
  
  bool canMakeRequest(String key, {
    required int maxRequests,
    required Duration window,
  }) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    
    // Clean old requests
    _requests[key]?.removeWhere((time) => time.isBefore(windowStart));
    
    // Check limit
    final recentRequests = _requests[key] ?? [];
    if (recentRequests.length >= maxRequests) {
      return false;
    }
    
    // Add new request
    _requests[key] = [...recentRequests, now];
    return true;
  }
  
  Duration getWaitTime(String key, {
    required int maxRequests,
    required Duration window,
  }) {
    final requests = _requests[key] ?? [];
    if (requests.isEmpty || requests.length < maxRequests) {
      return Duration.zero;
    }
    
    final oldestRequest = requests.first;
    final windowEnd = oldestRequest.add(window);
    final now = DateTime.now();
    
    if (windowEnd.isAfter(now)) {
      return windowEnd.difference(now);
    }
    
    return Duration.zero;
  }
}

// Usage
final rateLimiter = RateLimiter();

if (!rateLimiter.canMakeRequest('mapbox_directions', 
    maxRequests: 10, 
    window: Duration(minutes: 1))) {
  final waitTime = rateLimiter.getWaitTime('mapbox_directions',
      maxRequests: 10,
      window: Duration(minutes: 1));
  showError('Rate limit exceeded. Please wait ${waitTime.inSeconds}s.');
  return;
}
```

---

## Security

### API Key Management

**Environment Variables**:
```env
# .env file (NOT committed to git)
MAPBOX_ACCESS_TOKEN=pk.eyJ1...
ELEVENLABS_API_KEY=sk_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
```

**Configuration**:
```dart
// lib/core/config/env_config.dart

class EnvConfig {
  static const String mapboxToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );
  
  static const String elevenLabsKey = String.fromEnvironment(
    'ELEVENLABS_API_KEY',
    defaultValue: '',
  );
  
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );
  
  static bool get isConfigured {
    return mapboxToken.isNotEmpty && elevenLabsKey.isNotEmpty;
  }
}
```

**Build Command**:
```bash
flutter build web --dart-define=MAPBOX_ACCESS_TOKEN=$MAPBOX_TOKEN \
                  --dart-define=ELEVENLABS_API_KEY=$ELEVENLABS_KEY
```

### Request Signing (Future)

For sensitive operations, implement request signing:
```dart
// Future implementation for Stripe webhooks
class RequestSigner {
  static String sign(String payload, String secret) {
    final hmac = Hmac(sha256, utf8.encode(secret));
    final digest = hmac.convert(utf8.encode(payload));
    return digest.toString();
  }
  
  static bool verify(String payload, String signature, String secret) {
    final expectedSignature = sign(payload, secret);
    return signature == expectedSignature;
  }
}
```

---

## Testing

### Mock Services

```dart
// test/mocks/mock_route_snapping_service.dart

class MockRouteSnappingService extends Mock implements RouteSnappingService {
  @override
  Future<RouteSnapResult> snapToRoads(
    List<LatLng> waypoints,
    TourType tourType,
  ) async {
    return RouteSnapResult(
      polyline: waypoints,
      distance: 1000.0,
      duration: 600,
      success: true,
    );
  }
}

// test/mocks/mock_voice_generation_service.dart

class MockVoiceGenerationService extends Mock implements VoiceGenerationService {
  @override
  Future<VoiceGenerationResult> generateVoice({
    required String script,
    required String voiceId,
    required String stopId,
  }) async {
    return VoiceGenerationResult(
      audioUrl: 'https://example.com/audio.mp3',
      duration: 45,
      success: true,
    );
  }
}
```

---

## Monitoring

### API Usage Tracking

```dart
// lib/core/monitoring/api_usage_tracker.dart

class ApiUsageTracker {
  static final Map<String, int> _usage = {};
  
  static void trackRequest(String service) {
    _usage[service] = (_usage[service] ?? 0) + 1;
  }
  
  static Map<String, int> getUsage() => Map.from(_usage);
  
  static void reset() => _usage.clear();
}

// Usage
ApiUsageTracker.trackRequest('mapbox_directions');
ApiUsageTracker.trackRequest('elevenlabs_tts');

// Check usage
final usage = ApiUsageTracker.getUsage();
print('Mapbox requests: ${usage['mapbox_directions']}');
print('ElevenLabs requests: ${usage['elevenlabs_tts']}');
```

---

## Summary

### API Integration Checklist

- [x] Mapbox GL JS for map rendering
- [x] Mapbox Directions API for route snapping
- [x] ElevenLabs API for voice generation
- [x] Firebase Storage for audio hosting
- [ ] Stripe API (placeholder only)
- [x] Firebase Cloud Functions for analytics
- [x] Error handling for all APIs
- [x] Rate limiting implementation
- [x] API key security
- [x] Mock services for testing

### Cost Estimates (Monthly)

**Mapbox**:
- Free tier: 100,000 requests/month
- Estimated usage: ~5,000 requests/month
- Cost: $0

**ElevenLabs**:
- Starter plan: $5/month (30,000 characters)
- Estimated usage: ~20,000 characters/month
- Cost: $5/month

**Firebase**:
- Spark plan (free tier)
- Estimated usage: Within free limits
- Cost: $0

**Total Monthly Cost**: ~$5

---

**Next Steps**: Implement services with proper error handling and rate limiting. Monitor usage and upgrade plans as needed.
