# AYP Tour Guide

A GPS-triggered audio tour guide application built with Flutter, Firebase, and Mapbox.

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth%20%7C%20Storage-orange.svg)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Tests-504%20passing-brightgreen.svg)](#testing)
[![Coverage](https://img.shields.io/badge/Coverage-31.5%25-yellow.svg)](#testing)

## Overview

AYP Tour Guide enables users to discover and experience location-based audio tours. Creators can build immersive tours with geofenced audio triggers, and administrators manage content through a review workflow.

### Key Features

- **GPS-Triggered Audio**: Automatic audio playback when entering geofenced areas
- **Multiple Tour Types**: Walking and driving tours with appropriate navigation
- **Offline Support**: Download tours for offline playback
- **Creator Tools**: Build tours with audio recording or AI-generated narration
- **Admin Portal**: Content moderation and user management
- **Demo Mode**: Full app functionality without backend connection

## User Roles

| Role | Capabilities |
|------|-------------|
| **User** | Discover tours, playback with geofencing, favorites, history, reviews |
| **Creator** | All user features + create/edit tours, analytics dashboard |
| **Admin** | All features + review queue, user management, content moderation |

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.7+ |
| State Management | Riverpod 2.6 |
| Backend | Firebase (Auth, Firestore, Storage, Functions) |
| Maps | Mapbox Maps SDK |
| Audio | just_audio, record |
| Local Storage | Hive |
| Code Generation | Freezed, json_serializable |
| Routing | GoRouter |

## Quick Start

### Prerequisites

- Flutter SDK 3.7.0+
- Dart SDK 3.0+
- Node.js 20+ (for Cloud Functions)
- Firebase CLI
- Mapbox account

### Installation

```bash
# Clone repository
git clone <repository-url>
cd AYP

# Install dependencies
flutter pub get

# Generate code (models, mocks)
dart run build_runner build --delete-conflicting-outputs

# Run in demo mode (no backend required)
flutter run
```

### Demo Mode

The app supports **demo mode** for development and testing without requiring Firebase configuration.

Demo mode is currently **disabled** (production mode). To enable demo mode, update `lib/config/app_config.dart`:
```dart
static const bool demoMode = true;
```

See [docs/SETUP.md](docs/SETUP.md) for full configuration instructions.

## Project Structure

```
lib/
├── main.dart                 # Entry point with initialization
├── app.dart                  # Root MaterialApp with router
├── config/                   # Configuration
│   ├── app_config.dart       # App settings & demo mode toggle
│   ├── firebase_options.dart # Firebase configuration
│   ├── mapbox_config.dart    # Mapbox access token
│   └── theme/                # App theming
├── core/                     # Core utilities
│   ├── constants/            # App constants, routes, collections
│   ├── errors/               # Exception handling
│   ├── extensions/           # Dart extensions
│   └── utils/                # Geohash, formatting utilities
├── data/                     # Data layer
│   ├── models/               # Freezed data models
│   ├── local/                # Hive offline storage
│   └── repositories/         # Repository implementations
├── presentation/             # UI layer
│   ├── providers/            # Riverpod state management
│   ├── router/               # GoRouter navigation
│   ├── screens/              # Screen widgets
│   │   ├── auth/             # Login, register
│   │   ├── user/             # Home, discover, profile, playback
│   │   ├── creator/          # Dashboard, tour editor, analytics
│   │   └── admin/            # Review queue, user management
│   └── widgets/              # Reusable components
├── services/                 # Background services
│   ├── audio_service.dart    # Audio playback with background support
│   ├── location_service.dart # GPS tracking
│   ├── geofence_service.dart # Geofence monitoring with reliability improvements
│   ├── background_location_service.dart  # Foreground service for background GPS
│   ├── battery_optimization_service.dart # Battery exemption handling
│   ├── notification_service.dart         # Local notifications
│   ├── connectivity_service.dart         # Network monitoring & offline sync
│   ├── download_manager.dart # Offline downloads
│   └── ...
└── domain/                   # Domain layer (entities, usecases)

functions/                    # Firebase Cloud Functions
├── src/
│   ├── audio/                # AI audio generation
│   ├── tours/                # Tour workflow triggers
│   └── scheduled/            # Cleanup jobs
├── package.json
└── tsconfig.json

admin-web/                    # Web Admin Panel (Next.js)
├── src/
│   ├── app/                  # App router pages
│   ├── components/           # React components
│   ├── lib/firebase/         # Firebase integration
│   ├── hooks/                # TanStack Query hooks
│   └── types/                # TypeScript models
└── package.json

test/                         # Test suite
├── helpers/                  # Test utilities & mocks
├── unit/                     # Unit tests
│   ├── models/               # Model serialization
│   ├── services/             # Service tests
│   └── providers/            # Provider tests
├── widgets/                  # Widget tests
├── screens/                  # Screen tests
└── integration/              # Integration flow tests
```

## Testing

The project includes a comprehensive test suite with 504 tests.

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/services/geofence_service_test.dart

# Run integration tests
flutter test test/integration/
```

### Test Coverage

| Category | Coverage |
|----------|----------|
| Services | 40-100% |
| Models | 73-96% |
| Widgets | 84-87% |
| Overall | 31.5% |

### Test Categories

- **Unit Tests**: Models, services, providers
- **Widget Tests**: UI components, screens
- **Integration Tests**: End-to-end flows (playback, offline, creation, admin)

## Screens Overview

### User Screens
- **Home**: Featured tours, recommendations, quick access
- **Discover**: Search and filter tours by location, category
- **Tour Details**: Tour info, reviews, download option
- **Tour Playback**: Map view, audio controls, geofence/manual triggers
- **Profile**: User info, favorites, history, achievements

### Creator Screens
- **Dashboard**: Tour management, draft/published counts
- **Tour Editor**: Create/edit tours, add stops
- **Stop Editor**: Location, audio (record/TTS), images
- **Analytics**: Tour performance metrics

### Admin Screens
- **Dashboard**: Quick stats, pending reviews
- **Review Queue**: Approve/reject tour submissions
- **User Management**: Role changes, moderation
- **All Tours**: Browse and manage all content

## Data Models

Core models use Freezed for immutability and JSON serialization:

- **UserModel**: Profile, role, preferences, creator profile
- **TourModel**: Metadata, versioning, geolocation, stats
- **TourVersionModel**: Draft/live content, review status
- **StopModel**: Location, geofence radius, media
- **ProgressModel**: User tour progress tracking
- **ReviewModel**: Ratings and comments

## Key Services

| Service | Purpose |
|---------|---------|
| `AudioService` | Audio playback with just_audio |
| `LocationService` | GPS tracking with geolocator |
| `GeofenceService` | Geofence monitoring and triggers |
| `BackgroundLocationService` | Foreground service for background GPS |
| `BatteryOptimizationService` | Battery exemption handling |
| `DownloadManager` | Tour downloads for offline use |
| `OfflineStorageService` | Hive-based local caching |
| `ConnectivityService` | Network monitoring and offline sync |
| `ProgressService` | Track user tour completion |
| `AdminService` | Admin operations and audit logging |
| `NotificationService` | Local notifications for geofence triggers |

## Documentation

- [Setup Guide](docs/SETUP.md) - Detailed configuration instructions
- [Architecture](docs/ARCHITECTURE.md) - Technical architecture overview
- [Testing Guide](docs/TESTING.md) - Testing strategy and patterns
- [Completion Plan](docs/COMPLETION_PLAN.md) - Remaining work and roadmap
- [Session Log](docs/SESSION_LOG.md) - Development session notes
- [Admin Web Panel](admin-web/README.md) - Web admin panel documentation

## Development Status

**Current Status: Mobile App Has Critical Issues** (Updated February 4, 2026)

### Blocking Issues (Must Fix)

| Issue | Status |
|-------|--------|
| Map tiles not rendering | 3 fixes applied, untested |
| Audio not playing | Data issue - Firestore has null audioUrls |
| Tour cover images not loading | Not investigated |
| Center-on-user button broken | Not investigated |
| Dead-end buttons everywhere | Not fixed |

### What Works
- Core architecture and navigation
- Authentication (email/password, Google)
- Tour list displays (with placeholder images)
- Tour playback screen structure (minus map tiles)
- Web Admin Panel (Next.js)
- Tour Manager rebuild modules (Route Editor, Content Editor, Voice Gen, Publishing)

### Tour Manager Rebuild (~65%)
- Route Editor: Complete
- Content Editor: Complete
- Voice Generation: Complete
- Tour Manager: Complete
- Publishing Workflow: Complete
- Marketplace: Disabled (API compat issues)
- Analytics Dashboard: Not started

See [docs/PROJECT_STATUS.md](docs/PROJECT_STATUS.md) for current issues and next steps.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`flutter test`)
4. Commit changes (`git commit -m 'Add amazing feature'`)
5. Push to branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## License

Proprietary - All rights reserved.

## Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Firebase](https://firebase.google.com) - Backend services
- [Mapbox](https://www.mapbox.com) - Maps and navigation
- [Riverpod](https://riverpod.dev) - State management
- [ElevenLabs](https://elevenlabs.io) - AI voice generation
