# Architecture Overview

Technical architecture documentation for the AYP Tour Guide application.

## Table of Contents

- [High-Level Architecture](#high-level-architecture)
- [Layer Architecture](#layer-architecture)
- [State Management](#state-management)
- [Navigation](#navigation)
- [Data Flow](#data-flow)
- [Offline Architecture](#offline-architecture)
- [Services](#services)
- [Data Models](#data-models)
- [Security](#security)

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Mobile    │  │     Web     │  │      Desktop        │  │
│  │  (iOS/And)  │  │  (Creator/  │  │     (Future)        │  │
│  │             │  │   Admin)    │  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                    Firebase Backend                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────────┐  │
│  │   Auth   │  │ Firestore│  │ Storage  │  │  Functions  │  │
│  └──────────┘  └──────────┘  └──────────┘  └─────────────┘  │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                   External Services                          │
│  ┌──────────────┐  ┌────────────────┐                       │
│  │    Mapbox    │  │   ElevenLabs   │                       │
│  │  Maps + Nav  │  │   AI Audio     │                       │
│  └──────────────┘  └────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer Architecture

The app follows a modified Clean Architecture pattern:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │   Widgets   │  │      Providers      │  │
│  │   (Pages)   │  │ (Components)│  │  (State Mgmt)       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                      Domain Layer                            │
│  ┌─────────────────────┐  ┌─────────────────────────────┐   │
│  │      Entities       │  │         Use Cases           │   │
│  │  (Business Objects) │  │     (Business Logic)        │   │
│  └─────────────────────┘  └─────────────────────────────┘   │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                       Data Layer                             │
│  ┌──────────┐  ┌──────────────┐  ┌────────────────────────┐ │
│  │  Models  │  │ Repositories │  │      Data Sources      │ │
│  │ (Freezed)│  │              │  │  (Remote + Local)      │ │
│  └──────────┘  └──────────────┘  └────────────────────────┘ │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                     Services Layer                           │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Audio │ Location │ Geofence │ Storage │ Connectivity  │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Directory Mapping

```
lib/
├── presentation/     # UI Layer
│   ├── screens/      # Full-page widgets
│   ├── widgets/      # Reusable components
│   ├── providers/    # Riverpod providers
│   └── router/       # Navigation
├── domain/           # Business Logic (minimal currently)
│   ├── entities/     # Core business objects
│   └── usecases/     # Business operations
├── data/             # Data Layer
│   ├── models/       # Freezed data classes
│   ├── repositories/ # Data access abstraction
│   └── local/        # Local storage (Hive)
├── services/         # Platform Services
│   ├── audio_service.dart
│   ├── location_service.dart
│   └── ...
├── core/             # Shared Utilities
│   ├── constants/
│   ├── extensions/
│   ├── errors/
│   └── utils/
└── config/           # Configuration
```

---

## State Management

### Riverpod Architecture

The app uses Riverpod for reactive state management:

```dart
// Provider types used:

// 1. Simple providers (static data)
final configProvider = Provider((ref) => AppConfig());

// 2. State providers (mutable state)
final counterProvider = StateProvider((ref) => 0);

// 3. Async providers (Future data)
final userProvider = FutureProvider((ref) async {
  return await fetchUser();
});

// 4. Stream providers (real-time data)
final toursProvider = StreamProvider((ref) {
  return firestore.collection('tours').snapshots();
});

// 5. Notifier providers (complex state)
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// 6. Family providers (parameterized)
final tourProvider = FutureProvider.family<TourModel, String>((ref, id) {
  return fetchTour(id);
});
```

### Provider Organization

```
providers/
├── auth_provider.dart         # Authentication state
├── playback_provider.dart     # Tour playback state
├── tour_providers.dart        # Tour data (featured, nearby, etc.)
├── favorites_provider.dart    # User favorites
├── tour_history_provider.dart # Completed tours
├── achievements_provider.dart # User achievements
├── review_providers.dart      # Tour reviews
├── recommendations_provider.dart # Personalized recommendations
├── user_providers.dart        # User profiles
├── demo_auth_provider.dart    # Demo mode auth
└── demo_tour_providers.dart   # Demo mode tours
```

---

## Navigation

### GoRouter Configuration

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // Auth-based redirects
      final isLoggedIn = ref.read(authProvider).isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/auth/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => RegisterScreen()),

      // Main shell with bottom navigation
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
          GoRoute(path: '/discover', builder: (_, __) => DiscoverScreen()),
          GoRoute(path: '/profile', builder: (_, __) => ProfileScreen()),
          // Nested routes...
        ],
      ),

      // Creator routes (role-guarded)
      GoRoute(
        path: '/creator',
        redirect: (_, __) => _guardCreatorRoute(ref),
        routes: [...],
      ),

      // Admin routes (role-guarded)
      GoRoute(
        path: '/admin',
        redirect: (_, __) => _guardAdminRoute(ref),
        routes: [...],
      ),
    ],
  );
});
```

### Route Structure

```
/
├── /auth
│   ├── /login
│   └── /register
├── /home
├── /discover
├── /profile
│   ├── /favorites
│   ├── /history
│   ├── /achievements
│   ├── /settings
│   └── /downloads
├── /tour/:id
│   ├── /details
│   └── /play
├── /creator (requires creator role)
│   ├── /dashboard
│   ├── /analytics
│   ├── /create
│   └── /edit/:id
└── /admin (requires admin role)
    ├── /dashboard
    ├── /reviews
    ├── /users
    ├── /tours
    └── /settings
```

---

## Data Flow

### Tour Playback Flow

```
┌──────────┐     ┌──────────────┐     ┌────────────────┐
│  User    │────▶│ PlaybackPage │────▶│ PlaybackProvider│
│  Action  │     │              │     │                │
└──────────┘     └──────────────┘     └───────┬────────┘
                                              │
                 ┌────────────────────────────┼────────────────────┐
                 │                            │                    │
                 ▼                            ▼                    ▼
        ┌────────────────┐         ┌──────────────────┐   ┌──────────────┐
        │ LocationService│         │  GeofenceService │   │ AudioService │
        │                │         │                  │   │              │
        └───────┬────────┘         └────────┬─────────┘   └──────┬───────┘
                │                           │                     │
                │  Position Stream          │ Geofence Events     │ Audio State
                │                           │                     │
                └───────────────────────────┴─────────────────────┘
                                            │
                                            ▼
                                   ┌─────────────────┐
                                   │  UI Updates     │
                                   │  (Map, Audio,   │
                                   │   Progress)     │
                                   └─────────────────┘
```

### Data Sync Flow

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Remote    │◀────▶│  Repository │◀────▶│    Local    │
│  Firestore  │      │             │      │    Hive     │
└─────────────┘      └──────┬──────┘      └─────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   Provider    │
                    │ (Cached Data) │
                    └───────┬───────┘
                            │
                            ▼
                    ┌───────────────┐
                    │      UI       │
                    └───────────────┘
```

---

## Offline Architecture

### Storage Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                    OfflineStorageService                     │
│                         (Hive)                               │
├─────────────────────────────────────────────────────────────┤
│  Box: tours                                                  │
│  ├── tour_id -> TourModel (JSON)                            │
│  └── cached_at -> DateTime                                   │
├─────────────────────────────────────────────────────────────┤
│  Box: versions                                               │
│  ├── tour_id_version_id -> TourVersionModel                 │
│  └── cached_at -> DateTime                                   │
├─────────────────────────────────────────────────────────────┤
│  Box: stops                                                  │
│  ├── tour_id_version_id -> List<StopModel>                  │
│  └── cached_at -> DateTime                                   │
├─────────────────────────────────────────────────────────────┤
│  Box: downloads                                              │
│  ├── tour_id -> DownloadStatus                              │
│  └── file_paths -> List<String>                             │
├─────────────────────────────────────────────────────────────┤
│  Box: progress                                               │
│  └── tour_id -> UserProgress                                 │
├─────────────────────────────────────────────────────────────┤
│  Box: settings                                               │
│  └── key -> value                                            │
└─────────────────────────────────────────────────────────────┘
```

### Download Manager

```dart
enum DownloadStatus {
  idle,
  downloading,
  complete,
  failed,
}

class DownloadState {
  final DownloadStatus status;
  final double progress;
  final int fileSize;
  final String? error;
}

// Download flow:
// 1. Check if already downloaded
// 2. Fetch tour metadata
// 3. Download audio files
// 4. Cache images
// 5. Store in Hive
// 6. Update download status
```

---

## Services

### Service Dependencies

```
┌──────────────────────────────────────────────────────────────┐
│                        App Startup                            │
└────────────────────────────┬─────────────────────────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────────┐
│  Firebase Init  │ │   Hive Init     │ │  Permissions Check  │
└────────┬────────┘ └────────┬────────┘ └──────────┬──────────┘
         │                   │                      │
         └───────────────────┼──────────────────────┘
                             ▼
                    ┌─────────────────┐
                    │  Services Init  │
                    └────────┬────────┘
                             │
    ┌────────────────────────┼────────────────────────┐
    ▼                        ▼                        ▼
┌────────────┐      ┌────────────────┐      ┌──────────────────┐
│  Location  │      │     Audio      │      │   Connectivity   │
│  Service   │      │    Service     │      │     Service      │
└─────┬──────┘      └───────┬────────┘      └────────┬─────────┘
      │                     │                        │
      │                     ▼                        │
      │            ┌────────────────┐                │
      └───────────▶│   Geofence     │◀───────────────┘
                   │    Service     │
                   └────────────────┘
```

### Service Interfaces

```dart
// Location Service
abstract class LocationService {
  Stream<Position> get positionStream;
  Future<Position?> getCurrentPosition();
  Future<bool> requestPermission();
  double distanceBetween(lat1, lon1, lat2, lon2);
}

// Audio Service
abstract class AudioService {
  Stream<AudioState> get stateStream;
  Stream<Duration> get positionStream;
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<Duration?> loadUrl(String url);
}

// Geofence Service
abstract class GeofenceService {
  Stream<GeofenceEvent> get eventStream;
  Future<void> startMonitoring(List<Geofence> geofences);
  Future<void> stopMonitoring();
}
```

---

## Data Models

### Core Models (Freezed)

```dart
@freezed
class TourModel with _$TourModel {
  const factory TourModel({
    required String id,
    required String creatorId,
    required String creatorName,
    required TourCategory category,
    required TourType tourType,
    @Default(TourStatus.draft) TourStatus status,
    @Default(false) bool featured,
    @GeoPointConverter() required GeoPoint startLocation,
    required String geohash,
    String? city,
    String? region,
    String? country,
    String? liveVersionId,
    int? liveVersion,
    required String draftVersionId,
    required int draftVersion,
    @Default(TourStats()) TourStats stats,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _TourModel;
}

@freezed
class StopModel with _$StopModel {
  const factory StopModel({
    required String id,
    required String tourId,
    required String versionId,
    required int order,
    required String name,
    @Default('') String description,
    @GeoPointConverter() required GeoPoint location,
    required String geohash,
    @Default(30) int triggerRadius,
    @Default(StopMedia()) StopMedia media,
    StopNavigation? navigation,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _StopModel;
}
```

### Enums

```dart
enum TourStatus { draft, pendingReview, approved, rejected, hidden }
enum TourCategory { history, art, nature, food, architecture, culture, nightlife, shopping }
enum TourType { walking, driving, cycling, transit }
enum UserRole { user, creator, admin }
enum TriggerMode { automatic, manual }
enum AudioState { idle, loading, playing, paused, completed, error }
```

---

## Security

### Firebase Security Rules

```javascript
// Firestore rules summary:
// - Users can only write their own profile
// - Tours readable by all, writable by creator/admin
// - Reviews writable by authenticated users
// - Admin collections restricted to admin role
// - Audit logs admin-only
```

### App Security

```dart
// Role-based access in routes
redirect: (context, state) {
  final user = ref.read(authProvider);

  // Admin routes require admin role
  if (state.matchedLocation.startsWith('/admin')) {
    if (user.role != UserRole.admin) {
      return '/home';
    }
  }

  // Creator routes require creator or admin role
  if (state.matchedLocation.startsWith('/creator')) {
    if (user.role == UserRole.user) {
      return '/home';
    }
  }

  return null;
}
```

### Data Validation

```dart
// All data validated before Firestore writes
// - Required fields checked
// - Enum values validated
// - Coordinates within valid ranges
// - File sizes within limits
```

---

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Tours loaded on-demand with pagination
2. **Image Caching**: CachedNetworkImage for efficient image loading
3. **Query Optimization**: Geohash-based queries for nearby tours
4. **State Caching**: Riverpod providers cache computed state
5. **Offline First**: Hive cache checked before network requests

### Memory Management

```dart
// Providers auto-dispose when not in use
@riverpod
class TourDetails extends _$TourDetails {
  @override
  Future<TourModel> build(String id) async {
    // Auto-disposed when widget is unmounted
    return fetchTour(id);
  }
}
```
